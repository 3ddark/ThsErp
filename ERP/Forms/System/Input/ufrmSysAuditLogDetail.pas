unit ufrmSysAuditLogDetail;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.JSON, System.Generics.Collections, System.Generics.Defaults,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids,
  ufrmBase, LocalizationManager, SysAuditLog;

type
  // Tek işlem geçmişi satırı: başlık bilgileri + alan / eski değer / yeni değer tablosu (salt okunur).
  // I: yeni satırın tüm alanları, D: silinen satırın tüm alanları, U: yalnız değişen alanlar.
  TfrmSysAuditLogDetail = class(TfrmBase)
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure FormResize(Sender: TObject); override;
  private
    FEntry: TSysAuditLog;
    FPnlHeader: TPanel;
    FLblLine1: TLabel;
    FLblLine2: TLabel;
    FLblLine3: TLabel;
    FGrdChanges: TStringGrid;
    procedure BuildControls;
    procedure FillChanges;
    procedure GrdChangesDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure GrdChangesResize(Sender: TObject);
  public
    // AEntry form'a geçer (form kapanınca serbest bırakılır)
    constructor CreateFor(AOwner: TComponent; AEntry: TSysAuditLog);
    destructor Destroy; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

const
  NULL_TEXT = 'NULL';

function JsonValueText(AValue: TJSONValue): string;
begin
  if (AValue = nil) or (AValue is TJSONNull) then
    Result := NULL_TEXT
  else if AValue is TJSONString then
    Result := TJSONString(AValue).Value
  else
    Result := AValue.ToJSON;
end;

// JSON nesnesi -> alan adı / metin sözlüğü (nesne değilse boş)
function ParseObject(const AJson: string): TDictionary<string, string>;
var
  LValue: TJSONValue;
  LPair: TJSONPair;
begin
  Result := TDictionary<string, string>.Create;
  if Trim(AJson) = '' then
    Exit;
  LValue := TJSONObject.ParseJSONValue(AJson);
  try
    if LValue is TJSONObject then
      for LPair in TJSONObject(LValue) do
        Result.AddOrSetValue(LPair.JsonString.Value, JsonValueText(LPair.JsonValue));
  finally
    LValue.Free;
  end;
end;

constructor TfrmSysAuditLogDetail.CreateFor(AOwner: TComponent; AEntry: TSysAuditLog);
begin
  FEntry := AEntry;
  inherited Create(AOwner);
end;

destructor TfrmSysAuditLogDetail.Destroy;
begin
  FEntry.Free;
  inherited;
end;

procedure TfrmSysAuditLogDetail.FormCreate(Sender: TObject);
begin
  inherited;
  BorderIcons := [biSystemMenu, biMaximize];
  BuildControls;
end;

procedure TfrmSysAuditLogDetail.BuildControls;

  function NewLabel(ATop: Integer; ABold: Boolean): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent := FPnlHeader;
    Result.Left := 8;
    Result.Top := ATop;
    Result.AutoSize := True;
    if ABold then
      Result.Font.Style := [fsBold];
  end;

begin
  FPnlHeader := TPanel.Create(Self);
  FPnlHeader.Parent := pnlMain;
  FPnlHeader.Align := alTop;
  FPnlHeader.Height := 66;
  FPnlHeader.BevelOuter := bvNone;
  FPnlHeader.ParentColor := True;

  FLblLine1 := NewLabel(6, True);
  FLblLine2 := NewLabel(26, False);
  FLblLine3 := NewLabel(44, False);

  FGrdChanges := TStringGrid.Create(Self);
  FGrdChanges.Parent := pnlMain;
  FGrdChanges.Align := alClient;
  FGrdChanges.AlignWithMargins := True;
  FGrdChanges.ColCount := 3;
  FGrdChanges.FixedCols := 0;
  FGrdChanges.RowCount := 2;
  FGrdChanges.FixedRows := 1;
  FGrdChanges.DefaultRowHeight := 20;
  FGrdChanges.Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect, goThumbTracking];
  FGrdChanges.OnDrawCell := GrdChangesDrawCell;
end;

procedure TfrmSysAuditLogDetail.FormResize(Sender: TObject);
begin
  inherited;
  if Assigned(FGrdChanges) then
    GrdChangesResize(FGrdChanges);
end;

procedure TfrmSysAuditLogDetail.GrdChangesResize(Sender: TObject);
var
  LWidth: Integer;
begin
  LWidth := FGrdChanges.ClientWidth - 6;
  FGrdChanges.ColWidths[0] := LWidth * 24 div 100;
  FGrdChanges.ColWidths[1] := LWidth * 38 div 100;
  FGrdChanges.ColWidths[2] := LWidth - FGrdChanges.ColWidths[0] - FGrdChanges.ColWidths[1];
end;

procedure TfrmSysAuditLogDetail.GrdChangesDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  LCanvas: TCanvas;
  LText: string;
begin
  LCanvas := FGrdChanges.Canvas;
  LText := FGrdChanges.Cells[ACol, ARow];
  if ARow = 0 then
  begin
    LCanvas.Brush.Color := clBtnFace;
    LCanvas.Font.Style := [fsBold];
    LCanvas.Font.Color := clWindowText;
  end
  else
  begin
    LCanvas.Font.Style := [];
    if gdSelected in State then
    begin
      LCanvas.Brush.Color := clHighlight;
      LCanvas.Font.Color := clHighlightText;
    end
    else
    begin
      LCanvas.Brush.Color := clWindow;
      LCanvas.Font.Color := clWindowText;
      // güncellemede eski değer kırmızımsı, yeni değer yeşilimsi; NULL gri
      if (FEntry.Action = AUDIT_ACTION_UPDATE) and (ACol = 1) then
        LCanvas.Brush.Color := $00E6E6FF
      else if (FEntry.Action = AUDIT_ACTION_UPDATE) and (ACol = 2) then
        LCanvas.Brush.Color := $00E6FFE6;
      if (ACol > 0) and (LText = NULL_TEXT) then
        LCanvas.Font.Color := clGrayText;
    end;
    if ACol = 0 then
      LCanvas.Font.Style := [fsBold];
  end;
  LCanvas.FillRect(Rect);
  LCanvas.TextRect(Rect, Rect.Left + 4, Rect.Top + 3, LText);
end;

procedure TfrmSysAuditLogDetail.FillChanges;
var
  LOld, LNew: TDictionary<string, string>;
  LKeys: TList<string>;
  LKey, LValue: string;
  I: Integer;
begin
  LOld := ParseObject(FEntry.OldData);
  LNew := ParseObject(FEntry.NewData);
  LKeys := TList<string>.Create;
  try
    for LKey in LOld.Keys do
      LKeys.Add(LKey);
    for LKey in LNew.Keys do
      if not LKeys.Contains(LKey) then
        LKeys.Add(LKey);
    // id başta, diğerleri alfabetik
    LKeys.Sort(TComparer<string>.Construct(
      function(const A, B: string): Integer
      begin
        if A = B then
          Result := 0
        else if A = 'id' then
          Result := -1
        else if B = 'id' then
          Result := 1
        else
          Result := CompareText(A, B);
      end));

    if LKeys.Count = 0 then
    begin
      FGrdChanges.RowCount := 2;
      FGrdChanges.Cells[0, 1] := TLocalizationManager.Translate(TLangKeys.TSysAuditLog.MsgNoChanges, 'No changed fields.');
      FGrdChanges.Cells[1, 1] := '';
      FGrdChanges.Cells[2, 1] := '';
      Exit;
    end;

    FGrdChanges.RowCount := LKeys.Count + 1;
    for I := 0 to LKeys.Count - 1 do
    begin
      LKey := LKeys[I];
      FGrdChanges.Cells[0, I + 1] := LKey;
      if LOld.TryGetValue(LKey, LValue) then
        FGrdChanges.Cells[1, I + 1] := LValue
      else
        FGrdChanges.Cells[1, I + 1] := '';
      if LNew.TryGetValue(LKey, LValue) then
        FGrdChanges.Cells[2, I + 1] := LValue
      else
        FGrdChanges.Cells[2, I + 1] := '';
    end;
  finally
    LKeys.Free;
    LOld.Free;
    LNew.Free;
  end;
end;

procedure TfrmSysAuditLogDetail.FormShow(Sender: TObject);
begin
  FillChanges;
  ApplyLocalization;
  inherited;
  GrdChangesResize(FGrdChanges);
  if FGrdChanges.CanFocus then
    FGrdChanges.SetFocus;
end;

procedure TfrmSysAuditLogDetail.ApplyLocalization;

  function T(const AKey, ADefault: string): string;
  begin
    Result := TLocalizationManager.Translate(AKey, ADefault);
  end;

begin
  inherited;
  Self.Caption := T(TLangKeys.TSysAuditLog.TitleSingular, 'Audit Entry');
  if not Assigned(FEntry) or not Assigned(FLblLine1) then
    Exit;

  FLblLine1.Caption := Format('%s: %s    %s: %s    %s: %d', [
    T(TLangKeys.TSysAuditLog.ColAction, 'Action'), TSysAuditLog.ActionText(FEntry.Action),
    T(TLangKeys.TSysAuditLog.ColTableName, 'Table'), FEntry.TableName,
    T(TLangKeys.TSysAuditLog.ColRecordNo, 'Record Id'), FEntry.RecordNo]);
  FLblLine2.Caption := Format('%s: %s    %s: %s    %s: %s    %s: %s', [
    T(TLangKeys.TSysAuditLog.ColChangedAt, 'Date / Time'), FormatDateTime('dd.mm.yyyy hh:nn:ss', FEntry.ChangedAt),
    T(TLangKeys.TSysAuditLog.ColAppUser, 'User'), FEntry.AppUser,
    T(TLangKeys.TSysAuditLog.ColDbUser, 'DB User'), FEntry.DbUser,
    T(TLangKeys.TSysAuditLog.ColClientAddr, 'IP Address'), FEntry.ClientAddr]);
  FLblLine3.Caption := Format('%s: %d    %s: %s    %s: %d    %s: %s', [
    T(TLangKeys.TSysAuditLog.ColPeriodYear, 'Period'), FEntry.PeriodYear,
    T(TLangKeys.TSysAuditLog.ColDbName, 'Database'), FEntry.DbName,
    T(TLangKeys.TSysAuditLog.ColTransactionId, 'Transaction Id'), FEntry.TransactionId,
    T(TLangKeys.TSysAuditLog.ColApplicationName, 'Application'), FEntry.ApplicationName]);

  FGrdChanges.Cells[0, 0] := T(TLangKeys.TSysAuditLog.ColField, 'Field');
  FGrdChanges.Cells[1, 0] := T(TLangKeys.TSysAuditLog.ColOldValue, 'Old Value');
  FGrdChanges.Cells[2, 0] := T(TLangKeys.TSysAuditLog.ColNewValue, 'New Value');
end;

end.
