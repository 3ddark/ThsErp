unit ufrmGrid;

interface

uses
  Winapi.Windows, Winapi.Messages, FireDAC.Comp.Client,
  System.SysUtils, System.Variants, System.Classes, System.StrUtils,
  System.Rtti, System.TypInfo, System.Generics.Collections,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Menus, Vcl.ComCtrls, Vcl.Grids, Vcl.ExtCtrls, Vcl.Clipbrd,
  Vcl.DBGrids, Data.DB,
  Ths.Helper.BaseTypes, Ths.Helper.Edit,
  Ths.Orm.Table, Ths.Orm.Manager, Ths.Orm.ManagerStack;

type
  TfrmGrid<T> = class(TForm)
    FDataSource: TDataSource;
    status: TStatusBar;
  private
    FContext: PTEntityManager;
    FTable: T;
    FPTable: PThsTable;
    FQry: TFDQuery;
    FGrd: TDBGrid;

    FFilterStringFields: TStringList;
    FFilterNumericFields: TStringList;
    FFilterDateFields: TStringList;
    FFilterBoolFields: TStringList;
    FFilterGrid: TStringList;

    FGridPopMenu: TPopupMenu;
    FmniPreview: TMenuItem;
    FmniFilter: TMenuItem;
    FmniFilterExclude: TMenuItem;
    FmniFilterBack: TMenuItem;
    FmniFilterRemove: TMenuItem;
    FmniExportExcel: TMenuItem;
    FmniExportCsv: TMenuItem;
    FmniPrint: TMenuItem;
    FmniRemoveGridSort: TMenuItem;

    FContainer: TPanel;
    FGrdContainer: TPanel;
    FHeader: TPanel;
    FFooter: TPanel;
    FEdtFilter: TEdit;
    procedure PrepareForm();
    procedure PrepareGrid();
    procedure PreparePopupMenu();
    procedure SetQry(const Value: TFDQuery);
    procedure SetTable(const Value: T);
    procedure SetPTable(const Value: PThsTable);
    procedure SetGrd(const Value: TDBGrid);

    procedure SetPopupMenu(const Value: TPopupMenu);
    procedure SetmniPreview(const Value: TMenuItem);
    procedure SetmniFilter(const Value: TMenuItem);
    procedure SetmniFilterBack(const Value: TMenuItem);
    procedure SetmniFilterExclude(const Value: TMenuItem);
    procedure SetmniFilterRemove(const Value: TMenuItem);
    procedure SetmniExportExcel(const Value: TMenuItem);
    procedure SetmniExportCsv(const Value: TMenuItem);
    procedure SetmniPrint(const Value: TMenuItem);
    procedure SetmniRemoveGridSort(const Value: TMenuItem);

    procedure SetContainer(const Value: TPanel);
    procedure SetGrdContainer(const Value: TPanel);
    procedure SetHeader(const Value: TPanel);
    procedure SetFooter(const Value: TPanel);
    procedure SetEdtFilter(const Value: TEdit);

    procedure FilterApply;
    procedure PrepareFilteredColumns;
    procedure EdtFilterChange(Sender: TObject);

    procedure SetSelectedItem;
    procedure SetContext(const Value: PTEntityManager);
  public
    property Context: PTEntityManager read FContext write SetContext;
    property Qry: TFDQuery read FQry write SetQry;
    property Table: T read FTable write SetTable;
    property PTable: PThsTable read FPTable write SetPTable;
    property Grd: TDBGrid read FGrd write SetGrd;
    property Container: TPanel read FContainer write SetContainer;
    property GrdContainer: TPanel read FGrdContainer write SetGrdContainer;
    property EdtFilter: TEdit read FEdtFilter write SetEdtFilter;
    property Header: TPanel read FHeader write SetHeader;
    property Footer: TPanel read FFooter write SetFooter;

    property GridPopMenu: TPopupMenu read FGridPopMenu write SetPopupMenu;
    property mniPreview: TMenuItem read FmniPreview write SetmniPreview;
    property mniFilter: TMenuItem read FmniFilter write SetmniFilter;
    property mniFilterExclude: TMenuItem read FmniFilterExclude write SetmniFilterExclude;
    property mniFilterBack: TMenuItem read FmniFilterBack write SetmniFilterBack;
    property mniFilterRemove: TMenuItem read FmniFilterRemove write SetmniFilterRemove;
    property mniExportExcel: TMenuItem read FmniExportExcel write SetmniExportExcel;
    property mniExportCsv: TMenuItem read FmniExportCsv write SetmniExportCsv;
    property mniPrint: TMenuItem read FmniPrint write SetmniPrint;
    property mniRemoveGridSort: TMenuItem read FmniRemoveGridSort write SetmniRemoveGridSort;

    constructor Create(AOwner: TComponent; AContext: PTEntityManager; ATable: T; ASQL: string; ACreateNewBase: Boolean = True); reintroduce; overload;
    destructor Destroy; override;

    procedure ShowInputForm(Sender: TObject; AFormType: TInputFormMode); virtual;
    procedure AddNewClick(Sender: TObject);
  published
    //***form***
    procedure FormCreate(Sender: TObject); virtual;
    procedure FormShow(Sender: TObject); virtual;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); virtual;
    procedure FormKeyPress(Sender: TObject; var Key: Char); virtual;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    //***dbgrid***
    procedure grdDblClick(Sender: TObject); virtual;
    procedure grdCellClick(Column: TColumn); virtual;
    procedure grdKeyPress(Sender: TObject; var Key: Char); virtual;
    procedure grdKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure grdKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure grdTitleClick(Column: TColumn); virtual;
    procedure grdDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState); virtual;
    procedure SortGridTitle(Sender: TObject);
    //***query***
    procedure AfterDatasetOpen(Dataset: TDataset); virtual;
    procedure OnFilterDataset(Dataset: TDataset; var Accept: Boolean); virtual;
    //***datasource***
    procedure DataSourceDataChange(Sender: TObject; Field: TField);
    //***status bar***
    procedure RefreshStatucRecorCount();
    //***menu***
    function AddMenu(ATitle, AMenuName: string; AClickEvent: TNotifyEvent;
      AVibisle: Boolean = True; AShortCut: TShortCut = 0;
      AParentMenu: TMenuItem = nil): TMenuItem;
    procedure AddPopupMenuSpliter(AParentMenu: TMenuItem = nil);
    procedure mniPreviewClick(Sender: TObject); virtual;
    procedure mniFilterClick(Sender: TObject); virtual;
    procedure mniFilterExcludeClick(Sender: TObject); virtual;
    procedure mniFilterBackClick(Sender: TObject); virtual;
    procedure mniFilterRemoveClick(Sender: TObject); virtual;
    procedure mniExportExcelClick(Sender: TObject); virtual;
    procedure mniExportCsvClick(Sender: TObject); virtual;
    procedure mniPrintClick(Sender: TObject); virtual;
    procedure mniRemoveSortClick(Sender: TObject); virtual;

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; virtual;
  end;

  function UpperCaseTr(S: string): string;
  function LowerCaseTr(S: string): string;

implementation

uses ufrmInput;

function UpperCaseTr(S: string): string;
begin
  Result := AnsiUpperCase(StringReplace(StringReplace(S, 'ı', 'I', [rfReplaceAll]), 'i', 'İ', [rfReplaceAll]));
end;

function LowerCaseTr(S: string): string;
begin
  Result := AnsiLowerCase(StringReplace(StringReplace(S, 'I', 'ı', [rfReplaceAll]), 'İ', 'i', [rfReplaceAll]));
end;

function TfrmGrid<T>.AddMenu(ATitle, AMenuName: string; AClickEvent: TNotifyEvent;
  AVibisle: Boolean; AShortCut: TShortCut; AParentMenu: TMenuItem): TMenuItem;
begin
  if AParentMenu <> nil then
  begin
    Result := TMenuItem.Create(AParentMenu);
    Result.Caption := ATitle;
    Result.Name := AMenuName;
    Result.ShortCut := AShortCut;
    Result.OnClick := AClickEvent;
    Result.Visible := AVibisle;
    AParentMenu.Add(Result);
  end
  else
  begin
    Result := TMenuItem.Create(Self.GridPopMenu);
    Result.Caption := ATitle;
    Result.Name := AMenuName;
    Result.ShortCut := AShortCut;
    Result.OnClick := AClickEvent;
    Result.Visible := AVibisle;
    Self.GridPopMenu.Items.Add(Result);
  end;
end;

procedure TfrmGrid<T>.AddNewClick(Sender: TObject);
begin
  ShowInputForm(Sender, ifmNewRecord);
end;

procedure TfrmGrid<T>.AddPopupMenuSpliter(AParentMenu: TMenuItem);
var
  LMenu: TMenuItem;
begin
  if Assigned(AParentMenu) then
  begin
    LMenu := TMenuItem.Create(AParentMenu);
    LMenu.Caption := '-';
    AParentMenu.Add(LMenu);
  end
  else
  begin
    LMenu := TMenuItem.Create(GridPopMenu);
    LMenu.Caption := '-';
    GridPopMenu.Items.Add(LMenu);
  end;
end;

procedure TfrmGrid<T>.AfterDatasetOpen(Dataset: TDataset);
begin
  RefreshStatucRecorCount();
end;

constructor TfrmGrid<T>.Create(AOwner: TComponent; AContext: PTEntityManager; ATable: T; ASQL: string; ACreateNewBase: Boolean);
begin
  if ACreateNewBase then
    CreateNew(Owner);

  Self.Caption := 'Base Title';

  Context := AContext;
  FTable := ATable;
  PTable := @Table;

  FQry := AppDbContext.NewQuery;
  FQry.AfterOpen := AfterDatasetOpen;
  FQry.OnFilterRecord := OnFilterDataset;
  FQry.SQL.Text := ASQL;

  FDataSource := TDataSource.Create(Self);
  FDataSource.DataSet := FQry;
  FDataSource.OnDataChange := DataSourceDataChange;

  FFilterStringFields := TStringList.Create;
  FFilterNumericFields := TStringList.Create;
  FFilterDateFields := TStringList.Create;
  FFilterBoolFields := TStringList.Create;
  FFilterGrid := TStringList.Create;

  PrepareForm();

  Self.ActiveControl := Grd;
end;

function TfrmGrid<T>.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
end;

procedure TfrmGrid<T>.DataSourceDataChange(Sender: TObject; Field: TField);
begin
//
end;

destructor TfrmGrid<T>.Destroy;
begin
  FFilterStringFields.Free;
  FFilterNumericFields.Free;
  FFilterDateFields.Free;
  FFilterBoolFields.Free;
  FFilterGrid.Free;

  FQry.Close;
  FQry.Free;
  FDataSource.Free;

  PTable.Free;

  inherited;
end;

procedure TfrmGrid<T>.FilterApply;
begin
  if FFilterGrid.Count > 0 then
  begin
    Grd.DataSource.DataSet.Filtered := False;
    Grd.DataSource.DataSet.Filter := FFilterGrid.Text;
    Grd.DataSource.DataSet.Filtered := True;
  end
  else
  begin
    Grd.DataSource.DataSet.Filtered := False;
    Grd.DataSource.DataSet.Filter := '';
  end;
  mniFilterRemove.Enabled := (Grd.DataSource.DataSet.Filter <> '');
  mniFilterBack.Enabled := mniFilterRemove.Enabled;
  RefreshStatucRecorCount();
end;

procedure TfrmGrid<T>.EdtFilterChange(Sender: TObject);
var
  n1: Integer;
  LIntValue: Integer;
  LDoubleValue: Double;
  LDateTimeValue: TDateTime;
  LFilter: string;
begin
  LFilter := '';
  grd.DataSource.DataSet.Filter := LFilter;
  grd.DataSource.DataSet.Filtered := False;

  if EdtFilter.Text <> '' then
  begin
    if TryStrToInt(EdtFilter.Text, LIntValue)
    or TryStrToFloat(EdtFilter.Text, LDoubleValue)
    then
    begin
      for n1 := 0 to FFilterNumericFields.Count-1 do
      begin
        if LFilter <> '' then
          LFilter := LFilter + ' OR ';
        LFilter := LFilter + FFilterNumericFields.Strings[n1] + ' LIKE ' + QuotedStr('%' + EdtFilter.Text + '%');
      end;
    end;

    if (UpperCaseTr(EdtFilter.Text) = 'TRUE')
    or (LowerCaseTr(EdtFilter.Text) = 'true')
    or (UpperCaseTr(EdtFilter.Text) = 'FALSE')
    or (LowerCaseTr(EdtFilter.Text) = 'false')
    then
    begin
      for n1 := 0 to FFilterBoolFields.Count-1 do
      begin
        if LFilter <> '' then
          LFilter := LFilter + ' OR ';
        LFilter := LFilter + FFilterBoolFields.Strings[n1] + '=' + UpperCaseTr(EdtFilter.Text);
      end;
    end;

    if TryStrToDate(EdtFilter.Text, LDateTimeValue)
    or TryStrToTime(EdtFilter.Text, LDateTimeValue)
    or TryStrToDateTime(EdtFilter.Text, LDateTimeValue)
    then
    begin
      for n1 := 0 to FFilterNumericFields.Count-1 do
      begin
        if LFilter <> '' then
          LFilter := LFilter + ' OR ';
        LFilter := LFilter + FFilterNumericFields.Strings[n1] + '=' + EdtFilter.Text;
      end;
    end;

    if EdtFilter.Text <> '' then
    begin
      for n1 := 0 to FFilterStringFields.Count-1 do
      begin
        if LFilter <> '' then
          LFilter := LFilter + ' OR ';
        LFilter := LFilter + FFilterStringFields.Strings[n1] + ' LIKE ' + QuotedStr('%' + UpperCaseTr(EdtFilter.Text) + '%');
        LFilter := LFilter + ' OR ' + FFilterStringFields.Strings[n1] + ' LIKE ' + QuotedStr('%' + LowerCaseTr(EdtFilter.Text) + '%');
      end;
    end;

    grd.DataSource.DataSet.Filter := LFilter;
    grd.DataSource.DataSet.Filtered := True;
  end;
  Self.RefreshStatucRecorCount;
end;

procedure TfrmGrid<T>.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmGrid<T>.FormCreate(Sender: TObject);
begin
//
end;

procedure TfrmGrid<T>.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F6 then
  begin
    Self.Close;
  end
  else if Key = VK_F7 then
  begin
    ShowMessage('not implemented yet!' + sLineBreak + 'Shortcut F7 (Add New Record)');
  end
  else if Key = VK_F11 then
  begin
    Self.AlphaBlend := not Self.AlphaBlend;
    Self.AlphaBlendValue := 50;
  end
end;

procedure TfrmGrid<T>.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Chr(VK_ESCAPE) then
  begin
    Self.Close;
  end;
end;

procedure TfrmGrid<T>.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//
end;

procedure TfrmGrid<T>.FormShow(Sender: TObject);
begin
  FQry.Open;

  PrepareFilteredColumns;
end;

procedure TfrmGrid<T>.grdCellClick(Column: TColumn);
begin
//
end;

procedure TfrmGrid<T>.grdDblClick(Sender: TObject);
begin
//
end;

procedure TfrmGrid<T>.grdDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
//
end;

procedure TfrmGrid<T>.grdKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  AGrid: TDBGrid;
begin
  if not (Sender is TDBGrid) then
    Exit;

  AGrid := (Sender as TDBGrid);
  if AGrid.Focused then
  begin
    if Shift = [ssCtrl, ssShift] then
    begin
      if (UpCase(Char(Key)) = 'C') then
      begin
        Clipboard.Clear;
        Clipboard.SetTextBuf(PWideChar(Grd.DataSource.DataSet.Fields.Fields[0].AsString + sLineBreak));
      end;
    end
    else if Shift = [ssCtrl] then
    begin
      if (Key = VK_DELETE) then //Cancel Delete Record with CTRL+DELETE key conbination
      begin
        Key := 0;
      end
      else if (UpCase(Char(Key)) = 'C') then
      begin
        Clipboard.Clear;
        Clipboard.SetTextBuf(PWideChar(Grd.SelectedField.AsString + sLineBreak));
      end;
    end;
  end;
end;

procedure TfrmGrid<T>.grdKeyPress(Sender: TObject; var Key: Char);
begin
//
end;

procedure TfrmGrid<T>.grdKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//
end;

procedure TfrmGrid<T>.grdTitleClick(Column: TColumn);
begin
  SortGridTitle(Column);
end;

procedure TfrmGrid<T>.SetQry(const Value: TFDQuery);
begin
  FQry := Value;
end;

procedure TfrmGrid<T>.SetSelectedItem;
var
  AField: TField;
  n1, n2: Integer;
begin
  if Grd.DataSource.DataSet.RecordCount > 0 then
  begin
    AField := grd.DataSource.DataSet.FindField(PTable.Id.FieldName);
    if not Assigned(AField) or (AField = nil) or AField.IsNull then
      Exit;

    PTable.Id.Value := VarToStr(AField.Value).ToInteger;

    for n1 := 0 to Length(PTable.Fields)-1 do
    begin
      for n2 := 0 to grd.Columns.Count-1 do
      begin
        if PTable.Fields[n1].FieldName = grd.Columns.Items[n2].Field.FieldName then
        begin
          PTable.Fields[n1].Value := grd.Columns.Items[n2].Field.Value;
          PTable.Fields[n1].IsNullable := not grd.Columns.Items[n2].Field.Required;
          Break;
        end;
      end;
    end;
  end;
end;

procedure TfrmGrid<T>.SetTable(const Value: T);
begin
  FTable := Value;
end;

procedure TfrmGrid<T>.ShowInputForm(Sender: TObject; AFormType: TInputFormMode);
var
  LForm: TForm;
begin
  if (AFormType = ifmRewiev)
  or ((not FQry.Connection.InTransaction) and ((AFormType = ifmNewRecord) or (AFormType = ifmCopyNewRecord)))
  then
  begin
    if (AFormType = ifmRewiev) or (AFormType = ifmCopyNewRecord) then
      PTable.BusinessSelect(PTable.Id.QryName + '=' + PTable.Id.AsString, False, False);
    LForm := CreateInputForm(Sender, AFormType);
//    if Table is TTableDetailed then
//      PTable.FreeDetayListContent;
    LForm.Show;
  end
  else
    raise Exception.Create('Başka bir pencere giriş veya güncelleme için açılmış, önce bu işlemi tamamlayın.');
end;

procedure TfrmGrid<T>.SetContainer(const Value: TPanel);
begin
  FContainer := Value;
end;

procedure TfrmGrid<T>.SetContext(const Value: PTEntityManager);
begin
  FContext := Value;
end;

procedure TfrmGrid<T>.SetEdtFilter(const Value: TEdit);
begin
  FEdtFilter := Value;
end;

procedure TfrmGrid<T>.SetFooter(const Value: TPanel);
begin
  FFooter := Value;
end;

procedure TfrmGrid<T>.SetGrd(const Value: TDBGrid);
begin
  FGrd := Value;
end;

procedure TfrmGrid<T>.SetGrdContainer(const Value: TPanel);
begin
  FGrdContainer := Value;
end;

procedure TfrmGrid<T>.SetHeader(const Value: TPanel);
begin
  FHeader := Value;
end;

procedure TfrmGrid<T>.SetPopupMenu(const Value: TPopupMenu);
begin
  FGridPopMenu := Value;
end;

procedure TfrmGrid<T>.SetPTable(const Value: PThsTable);
begin
  FPTable := Value;
end;

procedure TfrmGrid<T>.SetmniExportCsv(const Value: TMenuItem);
begin
  FmniExportCsv := Value;
end;

procedure TfrmGrid<T>.SetmniExportExcel(const Value: TMenuItem);
begin
  FmniExportExcel := Value;
end;

procedure TfrmGrid<T>.SetmniFilter(const Value: TMenuItem);
begin
  FmniFilter := Value;
end;

procedure TfrmGrid<T>.SetmniFilterBack(const Value: TMenuItem);
begin
  FmniFilterBack := Value;
end;

procedure TfrmGrid<T>.SetmniFilterExclude(const Value: TMenuItem);
begin
  FmniFilterExclude := Value;
end;

procedure TfrmGrid<T>.SetmniFilterRemove(const Value: TMenuItem);
begin
  FmniFilterRemove := Value;
end;

procedure TfrmGrid<T>.SetmniPreview(const Value: TMenuItem);
begin
  FmniPreview := Value;
end;

procedure TfrmGrid<T>.SetmniPrint(const Value: TMenuItem);
begin
  FmniPrint := Value;
end;

procedure TfrmGrid<T>.SetmniRemoveGridSort(const Value: TMenuItem);
begin
  FmniRemoveGridSort := Value;
end;

procedure TfrmGrid<T>.mniExportExcelClick(Sender: TObject);
begin
  ShowMessage('not implemented yet!' + sLineBreak + 'Export Excel');
end;

procedure TfrmGrid<T>.mniFilterBackClick(Sender: TObject);
begin
  if FFilterGrid.Count > 0 then
  begin
    FFilterGrid.Delete(FFilterGrid.Count-1);
    FilterApply;
  end;
end;

procedure TfrmGrid<T>.mniFilterClick(Sender: TObject);
var
  LFilterBefore, LFilterVal: string;
begin
  LFilterBefore := '';
  if FFilterGrid.Count > 0 then
    LFilterBefore := ' AND ';
  if (Grd.SelectedField <> nil) and (not Grd.SelectedField.IsNull) then
  begin
    case Grd.SelectedField.DataType of
      ftUnknown: ;
      ftString:       LFilterVal := Grd.SelectedField.FieldName + '=' + QuotedStr(Grd.SelectedField.AsString);
      ftSmallint:     LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftInteger:      LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftWord:         LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftBoolean:      LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftFloat:        LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftCurrency:     LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftBCD:          LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftDate:         LFilterVal := Grd.SelectedField.FieldName + '=' + QuotedStr(Grd.SelectedField.AsString);
      ftTime:         LFilterVal := Grd.SelectedField.FieldName + '=' + QuotedStr(Grd.SelectedField.AsString);
      ftDateTime:     LFilterVal := Grd.SelectedField.FieldName + '=' + QuotedStr(Grd.SelectedField.AsString);
      ftBytes:        LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftVarBytes:     LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftAutoInc:      LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftBlob:         LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftMemo:         LFilterVal := Grd.SelectedField.FieldName + '=' + QuotedStr(Grd.SelectedField.AsString);
      ftGraphic:      LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftFmtMemo:      LFilterVal := Grd.SelectedField.FieldName + '=' + QuotedStr(Grd.SelectedField.AsString);
      ftParadoxOle: ;
      ftDBaseOle: ;
      ftTypedBinary: ;
      ftCursor: ;
      ftFixedChar:    LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftWideString:   LFilterVal := Grd.SelectedField.FieldName + '=' + QuotedStr(Grd.SelectedField.AsString);
      ftLargeint:     LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftADT: ;
      ftArray:        LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftReference: ;
      ftDataSet: ;
      ftOraBlob: ;
      ftOraClob: ;
      ftVariant: ;
      ftInterface: ;
      ftIDispatch: ;
      ftGuid: ;
      ftTimeStamp:    LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftFMTBcd:       LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftFixedWideChar:LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftWideMemo:     LFilterVal := Grd.SelectedField.FieldName + '=' + QuotedStr(Grd.SelectedField.AsString);
      ftOraTimeStamp: LFilterVal := Grd.SelectedField.FieldName + '=' + QuotedStr(Grd.SelectedField.AsString);
      ftOraInterval: ;
      ftLongWord:     LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftShortint:     LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftByte:         LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftExtended:     LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
      ftConnection: ;
      ftParams: ;
      ftStream: ;
      ftTimeStampOffset: ;
      ftObject: ;
      ftSingle:       LFilterVal := Grd.SelectedField.FieldName + '=' + Grd.SelectedField.AsString;
    end;

    FFilterGrid.Add(LFilterBefore + LFilterVal);
  end;
  FilterApply;
end;

procedure TfrmGrid<T>.mniFilterExcludeClick(Sender: TObject);
var
  LFilterBefore, LFilterVal: string;
begin
  LFilterBefore := '';
  if FFilterGrid.Count > 0 then
    LFilterBefore := ' AND ';
  if (Grd.SelectedField <> nil) and (not Grd.SelectedField.IsNull) then
  begin
    case Grd.SelectedField.DataType of
      ftUnknown: ;
      ftString:       LFilterVal := Grd.SelectedField.FieldName + '<>' + QuotedStr(Grd.SelectedField.AsString);
      ftSmallint:     LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftInteger:      LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftWord:         LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftBoolean:      LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftFloat:        LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftCurrency:     LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftBCD:          LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftDate:         LFilterVal := Grd.SelectedField.FieldName + '<>' + QuotedStr(Grd.SelectedField.AsString);
      ftTime:         LFilterVal := Grd.SelectedField.FieldName + '<>' + QuotedStr(Grd.SelectedField.AsString);
      ftDateTime:     LFilterVal := Grd.SelectedField.FieldName + '<>' + QuotedStr(Grd.SelectedField.AsString);
      ftBytes:        LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftVarBytes:     LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftAutoInc:      LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftBlob:         LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftMemo:         LFilterVal := Grd.SelectedField.FieldName + '<>' + QuotedStr(Grd.SelectedField.AsString);
      ftGraphic:      LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftFmtMemo:      LFilterVal := Grd.SelectedField.FieldName + '<>' + QuotedStr(Grd.SelectedField.AsString);
      ftParadoxOle: ;
      ftDBaseOle: ;
      ftTypedBinary: ;
      ftCursor: ;
      ftFixedChar:    LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftWideString:   LFilterVal := Grd.SelectedField.FieldName + '<>' + QuotedStr(Grd.SelectedField.AsString);
      ftLargeint:     LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftADT: ;
      ftArray:        LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftReference: ;
      ftDataSet: ;
      ftOraBlob: ;
      ftOraClob: ;
      ftVariant: ;
      ftInterface: ;
      ftIDispatch: ;
      ftGuid: ;
      ftTimeStamp:    LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftFMTBcd:       LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftFixedWideChar:LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftWideMemo:     LFilterVal := Grd.SelectedField.FieldName + '<>' + QuotedStr(Grd.SelectedField.AsString);
      ftOraTimeStamp: LFilterVal := Grd.SelectedField.FieldName + '<>' + QuotedStr(Grd.SelectedField.AsString);
      ftOraInterval: ;
      ftLongWord:     LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftShortint:     LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftByte:         LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftExtended:     LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
      ftConnection: ;
      ftParams: ;
      ftStream: ;
      ftTimeStampOffset: ;
      ftObject: ;
      ftSingle:       LFilterVal := Grd.SelectedField.FieldName + '<>' + Grd.SelectedField.AsString;
    end;

    FFilterGrid.Add(LFilterBefore + LFilterVal);
  end;
  FilterApply;
end;

procedure TfrmGrid<T>.mniFilterRemoveClick(Sender: TObject);
begin
  if FFilterGrid.Count > 0 then
  begin
    FFilterGrid.Clear;
    FilterApply;
  end;
end;

procedure TfrmGrid<T>.mniExportCsvClick(Sender: TObject);
begin
  ShowMessage('not implemented yet!' + sLineBreak + 'Export Csv');
end;

procedure TfrmGrid<T>.mniPreviewClick(Sender: TObject);
begin
  if mniPreview.Visible then
  begin
    if (Grd.DataSource.DataSet.RecordCount <> 0) and (Grd.DataSource.DataSet.RecordCount > 0) then
    begin
      SetSelectedItem();
      ShowInputForm(mniPreview, ifmRewiev);
    end;
  end;
end;

procedure TfrmGrid<T>.mniPrintClick(Sender: TObject);
begin
  ShowMessage('not implemented yet!' + sLineBreak + 'Print');
end;

procedure TfrmGrid<T>.mniRemoveSortClick(Sender: TObject);
begin
  if Qry.IndexFieldNames <> '' then
    Qry.IndexFieldNames := '';
end;

procedure TfrmGrid<T>.OnFilterDataset(Dataset: TDataset; var Accept: Boolean);
begin
  //
end;

procedure TfrmGrid<T>.PrepareFilteredColumns;
var
  n1: Integer;
begin
  for n1 := 0 to Grd.Columns.Count - 1 do
  begin
    if (Grd.Columns[n1].Field.DataType = Data.DB.ftString)
    or (Grd.Columns[n1].Field.DataType = Data.DB.ftWideString)
    or (Grd.Columns[n1].Field.DataType = Data.DB.ftMemo)
    or (Grd.Columns[n1].Field.DataType = Data.DB.ftWideMemo)
    then begin
      FFilterStringFields.Add(Grd.Columns[n1].FieldName);
    end else
    if (Grd.Columns[n1].Field.DataType = Data.DB.ftWord)
    or (Grd.Columns[n1].Field.DataType = Data.DB.ftLongWord)
    or (Grd.Columns[n1].Field.DataType = Data.DB.ftByte)
    or (Grd.Columns[n1].Field.DataType = Data.DB.ftShortint)
    or (Grd.Columns[n1].Field.DataType = Data.DB.ftSmallint)
    or (Grd.Columns[n1].Field.DataType = Data.DB.ftInteger)
    or (Grd.Columns[n1].Field.DataType = Data.DB.ftLargeint)
    or (Grd.Columns[n1].Field.DataType = Data.DB.ftFloat)
    or (Grd.Columns[n1].Field.DataType = Data.DB.ftCurrency)
    or (Grd.Columns[n1].Field.DataType = Data.DB.ftBCD)
    or (Grd.Columns[n1].Field.DataType = Data.DB.ftSingle)
    then begin
      if Grd.Columns[n1].FieldName <> 'id' then
        FFilterNumericFields.Add(Grd.Columns[n1].FieldName);
    end
    else if (Grd.Columns[n1].Field.DataType = Data.DB.ftBoolean) then begin
      FFilterBoolFields.Add(Grd.Columns[n1].FieldName);
    end else
    if (Grd.Columns[n1].Field.DataType = Data.DB.ftDate)
    or (Grd.Columns[n1].Field.DataType = Data.DB.ftTime)
    or (Grd.Columns[n1].Field.DataType = Data.DB.ftDateTime)
    then begin
      FFilterDateFields.Add(Grd.Columns[n1].FieldName);
    end;
  end;
end;

procedure TfrmGrid<T>.PrepareForm;
begin
  Self.Position := poOwnerFormCenter;
  Self.KeyPreview := True;
  Self.Constraints.MinWidth := 640;
  Self.Constraints.MaxWidth := Monitor.Width;
  Self.Constraints.MinHeight := 480;
  Self.Constraints.MaxHeight := Monitor.Height;

  //form event
  Self.OnCreate := FormCreate;
  Self.OnShow := FormShow;
  Self.OnClose := FormClose;
  Self.OnKeyPress := FormKeyPress;
  Self.OnKeyDown := FormKeyDown;
  Self.OnKeyUp := FormKeyUp;

  Container := TPanel.Create(Self);
  Container.Parent := Self;
  Container.Align := alClient;
  Container.BevelOuter := bvNone;
  Container.ParentColor := True;
  Container.Visible := True;

  PrepareGrid;

  Header := TPanel.Create(Container);
  Header.Parent := Container;
  Header.Align := alTop;
  Header.BevelOuter := bvNone;
  Header.Height := 70;
  Header.ParentColor := True;
  Header.Visible := False;

  Footer := TPanel.Create(Container);
  Footer.Parent := Container;
  Footer.Align := alBottom;
  Footer.BevelOuter := bvNone;
  Footer.Height := 70;
  Footer.ParentColor := True;
  Footer.Visible := False;

  status := TStatusBar.Create(Self);
  status.Align := alBottom;
  status.Parent := Self;
  with status.Panels.Add do
  begin
    Width := 100;
  end;
end;

procedure TfrmGrid<T>.PrepareGrid;
begin
  PreparePopupMenu();

  GrdContainer := TPanel.Create(Self);
  GrdContainer.Parent := Self;
  GrdContainer.Align := alClient;
  GrdContainer.BevelOuter := bvNone;
  GrdContainer.ParentColor := True;
  GrdContainer.Visible := True;

  EdtFilter := TEdit.Create(GrdContainer);
  EdtFilter.Parent := GrdContainer;
  EdtFilter.Align := alTop;
  EdtFilter.AlignWithMargins := True;
  EdtFilter.Margins.Left := 1;
  EdtFilter.Margins.Right := 1;
  EdtFilter.Margins.Top := 1;
  EdtFilter.Margins.Bottom := 1;
  EdtFilter.TextHint := 'Filter';
  EdtFilter.TabStop := False;
  EdtFilter.OnChange := EdtFilterChange;

  Grd := TDBGrid.Create(GrdContainer);
  Grd.Parent := GrdContainer;
  Grd.Align := alClient;
  Grd.DataSource := FDataSource;
  Grd.Options := Grd.Options - [dgEditing, dgConfirmDelete];
  //grd events
  Grd.OnDblClick := grdDblClick;
  Grd.OnCellClick := grdCellClick;
  Grd.OnKeyPress := grdKeyPress;
  Grd.OnKeyDown := grdKeyDown;
  Grd.OnKeyUp := grdKeyUp;
  Grd.OnTitleClick := grdTitleClick;
  Grd.OnDrawColumnCell := grdDrawColumnCell;
  Grd.PopupMenu := Self.GridPopMenu;
end;

procedure TfrmGrid<T>.PreparePopupMenu;
begin
  GridPopMenu := TPopupMenu.Create(Self);
  mniPreview := AddMenu('Preview', 'mniPreview', mniPreviewClick, True, TextToShortCut('Ctrl+Enter'));
  AddPopupMenuSpliter();
  mniFilter := AddMenu('Filter', 'mniFilter', mniFilterClick, True, TextToShortCut('F3'));
  mniFilterExclude := AddMenu('Exclude Filter', 'mniFilterExclude', mniFilterExcludeClick, True, TextToShortCut('Ctrl+F3'));
  mniFilterBack := AddMenu('Filter Back', 'mniFilterBack', mniFilterBackClick, True, TextToShortCut('Ctrl+F8'));
  mniFilterBack.Enabled := False;
  mniFilterRemove := AddMenu('Remove Filter', 'mniFilterRemove', mniFilterRemoveClick, True, TextToShortCut('F8'));
  mniFilterRemove.Enabled := False;
  AddPopupMenuSpliter();
  mniExportExcel := AddMenu('Export Excel', 'mniExportExcel', mniExportExcelClick, True, TextToShortCut('Ctrl+E'));
  mniExportCsv := AddMenu('Export Csv File', 'mniExportCsv', mniExportCsvClick, True, TextToShortCut('Ctrl+Shift+E'));
  mniPrint := AddMenu('Print', 'mniPrint', mniPrintClick, True, TextToShortCut('Ctrl+P'));
  mniRemoveGridSort := AddMenu('Remove Sort', 'mniRemoveGridSort', mniRemoveSortClick);
  mniRemoveGridSort.Enabled := False;
end;

procedure TfrmGrid<T>.RefreshStatucRecorCount();
begin
  if status.Panels.Count > 0 then
    status.Panels.Items[0].Text := Format('Records: %d', [Grd.DataSource.DataSet.RecordCount]);
end;

procedure TfrmGrid<T>.SortGridTitle(Sender: TObject);
var
  sl: TStringList;
  LOrderList: string;
  LOrderedColumn: Boolean;
  nIndex: Integer;
  LColumn: TColumn;
  AQuery: TFDQuery;
begin
  if Sender is TColumn then
    LColumn := Sender as TColumn
  else
    Exit;

  LOrderedColumn := False;
  sl := TStringList.Create;
  try
    AQuery := TFDQuery(Grd.DataSource.DataSet);
    begin
      //sort düzenle
      sl.Delimiter := ';';
      if AQuery.IndexFieldNames <> '' then
        sl.DelimitedText := AQuery.IndexFieldNames;

      if KeyboardStateToShiftState() = [ssCtrl] then
      begin
        //CTRL tuşuna basılmışsa
        for nIndex := 0 to sl.Count-1 do
          if (LColumn.FieldName + ':A' = sl.Strings[nIndex]) or (LColumn.FieldName + ':D' = sl.Strings[nIndex]) then
            LOrderedColumn := True;

        if LOrderedColumn then
        begin
          //listede zaten varsa ASC DESC değişimi yap
          for nIndex := 0 to sl.Count-1 do
          begin
            if (LColumn.FieldName + ':A' = sl.Strings[nIndex]) then
              sl.Strings[nIndex] := LColumn.FieldName + ':D'
            else if (LColumn.FieldName + ':D' = sl.Strings[nIndex]) then
              sl.Strings[nIndex] := LColumn.FieldName + ':A';
          end;
        end
        else
        begin
          //listede yoksa direkt ASC olarak ekle
          if sl.Count > 0 then
            sl.Add(LColumn.FieldName + ':A');
        end;
      end
      else
      begin
        //CTRL tuşuna basılmamışsa hepsini sil ve direkt olarak ekle
        if sl.Count = 0 then
          LOrderList := LColumn.FieldName + ':A'
        else
        begin
          for nIndex := 0 to sl.Count-1 do
            if (LColumn.FieldName + ':A' = sl.Strings[nIndex]) or (LColumn.FieldName + ':D' = sl.Strings[nIndex]) then
              LOrderedColumn := True;

          if LOrderedColumn then
          begin
            for nIndex := 0 to sl.Count-1 do
              if (LColumn.FieldName + ':A' = sl.Strings[nIndex]) then
                LOrderList := LColumn.FieldName + ':D'
              else if (LColumn.FieldName + ':D' = sl.Strings[nIndex]) then
                LOrderList := LColumn.FieldName + ':A';
          end
          else
            LOrderList := LColumn.FieldName + ':A';
        end;
        sl.Clear;
        sl.Add(LOrderList);
      end;

      LOrderList := '';

      for nIndex := 0 to sl.Count-1 do
      begin
        LOrderList := LOrderList + sl.Strings[nIndex] + ';';
        if nIndex = sl.Count-1 then
          LOrderList := LeftStr(LOrderList, Length(LOrderList)-1);
      end;

      if LOrderList <> '' then
        mniRemoveGridSort.Enabled := True;

      AQuery.IndexFieldNames := LOrderList;
    end;
  finally
    sl.Free;
  end;
end;

end.

