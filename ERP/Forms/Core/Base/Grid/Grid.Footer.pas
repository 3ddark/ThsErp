unit Grid.Footer;

// Liste alt toplamları: kod (AddFooterColumn) + sys_grid_column.aggregate_type tanımları, etiket paneli,
// istemci modunda TFDAggregate, sayfalı modda sunucu değeri (ServerValue)

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.DBGrids, Data.DB,
  FireDAC.Comp.Client, UnitOfWork, Grid.Types;

type
  TGridFooter = class
  private
    FPanel: TPanel;
    FColumns: TObjectList<TFooterColumn>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure CreatePanel(AParent: TWinControl);
    // Aynı kolon varsa önceki tanım silinir (sonra eklenen kazanır)
    procedure Add(const AColumnFieldName: string; AAggregateType: TAggregateType; const ADisplayFormat: string = '');
    procedure LoadFromDB(AUoW: TUnitOfWork; const AViewName: string);
    // AServerTotals: sayfalı mod, toplamlar LoadServerTotals ile SQL'den; değilse sorgu kapalıyken TFDAggregate kurulur
    procedure Build(AQry: TFDQuery; AServerTotals: Boolean);
    procedure UpdateLayout(AGrid: TDBGrid; AServerTotals: Boolean);
    // 'count(*) AS pg_total' sonrası eklenecek toplamlar (', sum("x") AS pg_a0' …); sorguda olmayan kolon atlanır
    function AggregateSelectList(AQry: TDataSet): string;
    procedure AssignServerValues(AResult: TDataSet);

    property Panel: TPanel read FPanel;
    property Columns: TObjectList<TFooterColumn> read FColumns;
  end;

implementation

uses
  Logger, SharedFormTypes, SysGridColumn, SysGridColumn.Repository;

constructor TGridFooter.Create;
begin
  inherited Create;
  FColumns := TObjectList<TFooterColumn>.Create(True);
end;

destructor TGridFooter.Destroy;
begin
  FColumns.Free;
  inherited;
end;

procedure TGridFooter.CreatePanel(AParent: TWinControl);
begin
  FPanel := TPanel.Create(AParent);
  FPanel.Parent := AParent;
  FPanel.Align := alTop;
  FPanel.Height := 30;
  FPanel.BevelOuter := bvNone;
  FPanel.Color := $00F0F0F0;
  FPanel.Font.Color := clBlack;
  FPanel.Font.Style := [fsBold];
  FPanel.Visible := False;
end;

procedure TGridFooter.Add(const AColumnFieldName: string; AAggregateType: TAggregateType; const ADisplayFormat: string);
var
  i: Integer;
begin
  for i := FColumns.Count - 1 downto 0 do
    if SameText(FColumns[i].ColumnFieldName, AColumnFieldName) then
    begin
      FColumns.Delete(i);
      Break;
    end;
  FColumns.Add(TFooterColumn.Create(AColumnFieldName, AAggregateType, ADisplayFormat));
end;

procedure TGridFooter.LoadFromDB(AUoW: TUnitOfWork; const AViewName: string);
var
  LRepo: ISysGridColumnRepository;
  LColumns: TList<TSysGridColumn>;
  LCol: TSysGridColumn;
  LAggType: TAggregateType;
  LFormat: string;
begin
  // Kodda tanımlananlar korunur; aynı kolon DB'de de varsa DB'deki alınır
  if (AViewName = '') or not Assigned(AUoW) or (AUoW.Connection = nil) or not AUoW.Connection.Connected then
    Exit;

  try
    LRepo := AUoW.GetRepository<TSysGridColumn, TSysGridColumnRepository> as ISysGridColumnRepository;
    if LRepo = nil then
      Exit;

    LColumns := LRepo.LoadColumns(AViewName);
    try
      for LCol in LColumns do
        if IntToAggregateType(LCol.AggregateType, LAggType) then
        begin
          LFormat := LCol.DataFormat;
          if LFormat = '' then
            LFormat := AggregateTypeToDefaultFormat(LAggType);
          Add(LCol.ColumnName, LAggType, LFormat);
        end;
    finally
      LColumns.Free;
    end;
  except
    on E: Exception do
      GLogger.WarningFmt('LoadFooterColumnsFromDB hatası [%s]: %s', [AViewName, E.Message]);
  end;
end;

procedure TGridFooter.Build(AQry: TFDQuery; AServerTotals: Boolean);
var
  LCol: TFooterColumn;
  LFunc: string;
begin
  if Assigned(FPanel) then
    while FPanel.ControlCount > 0 do
      FPanel.Controls[0].Free;

  if FColumns.Count = 0 then
  begin
    if Assigned(FPanel) then
      FPanel.Visible := False;
    Exit;
  end;

  if AQry.Active then
    raise Exception.Create('BuildFooter: Query must be closed before creating aggregate fields');

  AQry.Aggregates.Clear;
  for LCol in FColumns do
  begin
    // Sayfalı modda toplamlar sayfanın değil tüm kayıtların: sunucuda hesaplanır
    LCol.AggregateField := nil;
    if not AServerTotals then
    begin
      LFunc := AggregateTypeToSqlFunc(LCol.AggregateType);
      LCol.AggregateField := AQry.Aggregates.Add;
      LCol.AggregateField.Name := Format('AGG_%s_%s', [LFunc, LCol.ColumnFieldName]);
      LCol.AggregateField.Expression := Format('%s(%s)', [LFunc, LCol.ColumnFieldName]);
      LCol.AggregateField.Active := True;
    end;
    LCol.ServerValue := Null;

    LCol.DisplayControl := TLabel.Create(FPanel);
    LCol.DisplayControl.Parent := FPanel;
    LCol.DisplayControl.Font.Style := [fsBold];
    LCol.DisplayControl.Font.Size := 8;
    LCol.DisplayControl.Font.Color := clBlack;
    LCol.DisplayControl.AutoSize := True;
    LCol.DisplayControl.Caption := '';
  end;

  FPanel.Visible := True;
  AQry.AggregatesActive := not AServerTotals;
end;

function FormatFooterValue(ACol: TFooterColumn; AField: TField; const AValue: Variant): string;
var
  LFormat: string;
begin
  if VarIsNull(AValue) then
    Exit('');

  if ACol.DisplayFormat <> '' then
    LFormat := ACol.DisplayFormat
  else if ACol.AggregateType = atCount then
    LFormat := '#,##0'
  else
    LFormat := '#,##0.00';

  case AField.DataType of
    ftByte, ftWord, ftLongWord, ftShortint, ftSmallint, ftInteger, ftLargeint,
    ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftExtended, ftSingle:
      Result := FormatFloat(LFormat, AValue);
    ftDate, ftTime, ftDateTime, ftTimeStamp:
      if ACol.DisplayFormat <> '' then
        Result := FormatDateTime(ACol.DisplayFormat, AValue)
      else
        Result := FormatDateTime('dd.mm.yyyy hh:nn:ss', AValue);
  else
    Result := VarToStr(AValue);
  end;
end;

procedure TGridFooter.UpdateLayout(AGrid: TDBGrid; AServerTotals: Boolean);
var
  LFooterCol, LCol: TFooterColumn;
  LGridCol: TColumn;
  LLeft, i: Integer;
  LValue: Variant;
begin
  if (FPanel = nil) or not FPanel.Visible then
    Exit;

  LLeft := 0;
  if dgIndicator in AGrid.Options then
    LLeft := IndicatorWidth;

  for i := 0 to AGrid.Columns.Count - 1 do
  begin
    LGridCol := AGrid.Columns[i];
    LFooterCol := nil;
    for LCol in FColumns do
      if SameText(LCol.ColumnFieldName, LGridCol.FieldName) then
      begin
        LFooterCol := LCol;
        Break;
      end;

    if Assigned(LFooterCol) and Assigned(LFooterCol.DisplayControl) then
    begin
      if LGridCol.Visible and Assigned(LGridCol.Field) then
      begin
        LFooterCol.DisplayControl.Visible := True;
        LFooterCol.DisplayControl.Left := LLeft;
        LFooterCol.DisplayControl.Width := LGridCol.Width;
        LFooterCol.DisplayControl.Height := 20;
        LFooterCol.DisplayControl.Top := 5;

        if AServerTotals or not Assigned(LFooterCol.AggregateField) then
          LValue := LFooterCol.ServerValue
        else
          LValue := LFooterCol.AggregateField.Value;
        LFooterCol.DisplayControl.Caption := FormatFooterValue(LFooterCol, LGridCol.Field, LValue);
        LFooterCol.DisplayControl.Alignment := LGridCol.Alignment;
      end
      else
        LFooterCol.DisplayControl.Visible := False;
    end;

    if LGridCol.Visible then
      Inc(LLeft, LGridCol.Width);
  end;
end;

function TGridFooter.AggregateSelectList(AQry: TDataSet): string;
var
  LCol: TFooterColumn;
  i: Integer;
begin
  Result := '';
  // sorguda olmayan kolon toplamı SQL hatası (açık işlemi de bozar) vermesin
  for i := 0 to FColumns.Count - 1 do
  begin
    LCol := FColumns[i];
    if AQry.FindField(LCol.ColumnFieldName) <> nil then
      Result := Result + Format(', %s(%s) AS pg_a%d',
        [AggregateTypeToSqlFunc(LCol.AggregateType), AnsiQuotedStr(LCol.ColumnFieldName, '"'), i]);
  end;
end;

procedure TGridFooter.AssignServerValues(AResult: TDataSet);
var
  LField: TField;
  i: Integer;
begin
  for i := 0 to FColumns.Count - 1 do
  begin
    LField := AResult.FindField('pg_a' + IntToStr(i));
    if Assigned(LField) then
      FColumns[i].ServerValue := LField.Value
    else
      FColumns[i].ServerValue := Null;
  end;
end;

end.
