unit ufrmGrid;

interface

uses
  Winapi.Windows, Winapi.Messages, FireDAC.Comp.Client,
  System.SysUtils, System.Variants, System.Classes, System.StrUtils,
  System.Rtti, System.TypInfo, System.Generics.Collections,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Menus, Vcl.ComCtrls, Vcl.Grids, Vcl.ExtCtrls, Vcl.Clipbrd,
  Vcl.DBGrids, Vcl.Samples.Spin, Data.DB,
  udm, Ths.Constants, Ths.Globals, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  SharedFormTypes, BaseEntity, BaseService;

const
  DB_STATUS_RECORD_COUNT = 0;
  DB_STATUS_SQL_SERVER   = 1;
  DB_STATUS_PERIOD       = 2;
  DB_STATUS_USER         = 3;
  DB_STATUS_KEY_F6       = 4;
  DB_STATUS_KEY_F7       = 5;
  DB_STATUS_KEY_F11      = 6;

type
  TfrmGrid<TE: TEntity; TS: TBaseService<TE>> = class(TForm)
  private
    FService: TS;
    FTable: TE;
    FQry: TFDQuery;
    FDataSource: TDataSource;
    FGrd: TDBGrid;

    //for use HelperForm
    FIsHelper: Boolean;
    FDataAktar: Boolean;
    FCleanAndClose: Boolean;
    //for use HelperForm

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

    FPanelMain: TPanel;
    FPanelContent: TPanel;
    FPanelHeader: TPanel;
    FPanelSidebar: TPanel;
    FPanelButtons: TPanel;
    FPanelFooter: TPanel;
    FStatusBase: TStatusBar;
    FEdtFilter: TEdit;
    FBtnSpin: TSpinButton;
    FBtnClose: TButton;
    FBtnAdd: TButton;

    procedure PrepareForm;
    procedure CreatePanelMain;
    procedure CreatePanelHeader;
    procedure CreatePanelSidebar;
    procedure CreatePanelButtons;
    procedure CreatePanelContent;
    procedure CreateGrid;
    procedure CreatePanelFooter;
    procedure CreateFilterEdit();
    procedure CreateBtnSpin;
    procedure CreateBtnClose;
    procedure CreateButtonAdd;
    procedure PreparePopupMenu();

    procedure SetQry(const Value: TFDQuery);
    procedure SetGrd(const Value: TDBGrid);
    procedure SetTable(Value: TE);
    procedure SetService(const Value: TS);

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

    procedure SetPanelMain(const Value: TPanel);
    procedure SetPanelContent(const Value: TPanel);
    procedure SetPanelHeader(const Value: TPanel);
    procedure SetPanelSidebar(const Value: TPanel);
    procedure SetPanelButtons(const Value: TPanel);
    procedure SetPanelFooter(const Value: TPanel);

    procedure SetEdtFilter(const Value: TEdit);

    procedure FilterApply;
    procedure PrepareFilteredColumns;
    procedure EdtFilterChange(Sender: TObject);
    procedure PrepareStatusBar;
  public
    property Service: TS read FService write SetService;
    property Table: TE read FTable write SetTable;
    property Grd: TDBGrid read FGrd write SetGrd;
    property Qry: TFDQuery read FQry write SetQry;

    //for use HelperForm
    property IsHelper: Boolean read FIsHelper write FIsHelper default False;
    property DataAktar: Boolean read FDataAktar write FDataAktar;
    property CleanAndClose: Boolean read FCleanAndClose write FCleanAndClose default False;
    //for use HelperForm

    property PanelMain: TPanel read FPanelMain write SetPanelMain;
    property PanelContent: TPanel read FPanelContent write SetPanelContent;
    property PanelHeader: TPanel read FPanelHeader write SetPanelHeader;
    property PanelSidebar: TPanel read FPanelSidebar write SetPanelSidebar;
    property PanelButtons: TPanel read FPanelButtons write SetPanelButtons;
    property PanelFooter: TPanel read FPanelFooter write SetPanelFooter;
    property StatusBase: TStatusBar read FStatusBase write FStatusBase;
    property EdtFilter: TEdit read FEdtFilter write SetEdtFilter;
    property BtnSpin: TSpinButton read FBtnSpin write FBtnSpin;
    property BtnClose: TButton read FBtnClose write FBtnClose;
    property BtnAdd: TButton read FBtnAdd write FBtnAdd;

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

    constructor Create(AOwner: TComponent; AService: TS; ATable: TE; ACreateNewBase: Boolean = True); reintroduce; overload;
    destructor Destroy; override;

    procedure SetSelectedItem; virtual;
    //for use HelperForm
    function getFilterEditData(): string; virtual;
    //for use HelperForm
    procedure ShowInputForm(Sender: TObject; AFormType: TInputFormMode); virtual;

    procedure MoveUp(); virtual;
    procedure MoveDown(); virtual;
  published
    //***form***
    procedure FormCreate(Sender: TObject); virtual;
    procedure FormDestroy(Sender: TObject); virtual;
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
    procedure grdDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState); virtual;
    procedure SortGridTitle(Sender: TObject);

    procedure RefreshDataFirst();
    procedure RefreshData();
    //***query***
    procedure AfterDatasetOpen(Dataset: TDataset); virtual;
    procedure OnFilterDataset(Dataset: TDataset; var Accept: Boolean); virtual;
    //***datasource***
    procedure DataSourceDataChange(Sender: TObject; Field: TField);
    //***status bar***
    procedure RefreshStatusRecorCount();
    procedure StatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
    procedure StatusBarAddPanel(AWidth: Integer; AStyle: TStatusPanelStyle);
    //***menu***
    function AddMenu(ATitle, AMenuName: string; AClickEvent: TNotifyEvent; AVibisle: Boolean = True; AShortCut: TShortCut = 0; AParentMenu: TMenuItem = nil): TMenuItem;
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

    //***footer button events***
    procedure BtnSpinDownClick(Sender: TObject); virtual;
    procedure BtnSpinUpClick(Sender: TObject); virtual;
    procedure BtnCloseClick(Sender: TObject); virtual;
    procedure BtnAddClick(Sender: TObject); virtual;

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; virtual;

    procedure RefreshParentGrid(AFocusSelectedItem: Boolean);
  end;

  function UpperCaseTr(S: string): string;
  function LowerCaseTr(S: string): string;

implementation

uses ufrmBaseInput;

function UpperCaseTr(S: string): string;
begin
  Result := AnsiUpperCase(StringReplace(StringReplace(S, 'ı', 'I', [rfReplaceAll]), 'i', 'İ', [rfReplaceAll]));
end;

function LowerCaseTr(S: string): string;
begin
  Result := AnsiLowerCase(StringReplace(StringReplace(S, 'I', 'ı', [rfReplaceAll]), 'İ', 'i', [rfReplaceAll]));
end;

function TfrmGrid<TE, TS>.AddMenu(ATitle, AMenuName: string; AClickEvent: TNotifyEvent;
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

procedure TfrmGrid<TE, TS>.AddPopupMenuSpliter(AParentMenu: TMenuItem);
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

procedure TfrmGrid<TE, TS>.AfterDatasetOpen(Dataset: TDataset);
begin
  RefreshStatusRecorCount();
end;

procedure TfrmGrid<TE, TS>.BtnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmGrid<TE, TS>.BtnAddClick(Sender: TObject);
begin
  ShowInputForm(Sender, ifmNewRecord);
end;

procedure TfrmGrid<TE, TS>.BtnSpinDownClick(Sender: TObject);
begin
  MoveUp;
end;

procedure TfrmGrid<TE, TS>.BtnSpinUpClick(Sender: TObject);
begin
  MoveDown;
end;

constructor TfrmGrid<TE, TS>.Create(AOwner: TComponent; AService: TS; ATable: TE; ACreateNewBase: Boolean);
begin
  if ACreateNewBase then
    CreateNew(Owner);

  SetService(AService);
  SetTable(ATable);

  Self.Caption := 'Base Title';

  FQry := TFDQuery.Create(nil);
  FQry.Connection := Service.Uow.Connection;
  FQry.AfterOpen := AfterDatasetOpen;
  FQry.OnFilterRecord := OnFilterDataset;
  FQry.SQL.Text := AService.CreateQueryForUI('');

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

function TfrmGrid<TE, TS>.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
end;

procedure TfrmGrid<TE, TS>.CreatePanelMain;
begin
  PanelMain := TPanel.Create(Self);
  PanelMain.Parent := Self;
  PanelMain.Align := alClient;
  PanelMain.BevelOuter := bvNone;
  PanelMain.ParentColor := True;
  PanelMain.Visible := True;
end;

procedure TfrmGrid<TE, TS>.CreatePanelContent();
begin
  PanelContent := TPanel.Create(PanelMain);
  PanelContent.Parent := PanelMain;
  PanelContent.Align := alClient;
  PanelContent.BevelOuter := bvNone;
  PanelContent.ParentColor := True;
  PanelContent.Visible := True;
end;

procedure TfrmGrid<TE, TS>.CreatePanelHeader;
begin
  PanelHeader := TPanel.Create(PanelMain);
  PanelHeader.Parent := PanelMain;
  PanelHeader.Align := alTop;
  PanelHeader.BevelOuter := bvNone;
  PanelHeader.Height := 30;
  PanelHeader.ParentColor := True;
  PanelHeader.Visible := True;
end;

procedure TfrmGrid<TE, TS>.CreatePanelSidebar;
begin
  PanelSidebar := TPanel.Create(PanelMain);
  PanelSidebar.Parent := PanelMain;
  PanelSidebar.Align := alLeft;
  PanelSidebar.BevelOuter := bvNone;
  PanelSidebar.Height := 70;
  PanelSidebar.ParentColor := True;
  PanelSidebar.Visible := True;
end;

procedure TfrmGrid<TE, TS>.CreatePanelButtons;
begin
  FPanelButtons := TPanel.Create(PanelContent);
  FPanelButtons.Parent := PanelContent;
  FPanelButtons.Align := alBottom;
  FPanelButtons.BevelOuter := bvNone;
  FPanelButtons.Height := 70;
  FPanelButtons.ParentColor := True;
  FPanelButtons.Visible := True;
end;

procedure TfrmGrid<TE, TS>.CreatePanelFooter;
begin
  PanelFooter := TPanel.Create(PanelMain);
  PanelFooter.Parent := PanelMain;
  PanelFooter.Align := alBottom;
  PanelFooter.BevelOuter := bvNone;
  PanelFooter.Height := 28;
  PanelFooter.ParentColor := True;
  PanelFooter.Visible := True;
end;

procedure TfrmGrid<TE, TS>.CreateGrid();
begin
  Grd := TDBGrid.Create(PanelContent);
  Grd.Parent := PanelContent;
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

procedure TfrmGrid<TE, TS>.CreateFilterEdit();
begin
  EdtFilter := TEdit.Create(PanelHeader);
  EdtFilter.Parent := PanelHeader;
  EdtFilter.Align := alClient;
  EdtFilter.AlignWithMargins := True;
  EdtFilter.Margins.Left := 3;
  EdtFilter.Margins.Right := 3;
  EdtFilter.Margins.Top := 3;
  EdtFilter.Margins.Bottom := 3;
  EdtFilter.TextHint := 'Filter';
  EdtFilter.TabStop := False;
  EdtFilter.OnChange := EdtFilterChange;
end;

procedure TfrmGrid<TE, TS>.CreateBtnSpin;
begin
  BtnSpin := TSpinButton.Create(PanelFooter);
  BtnSpin.Parent := PanelFooter;
  BtnSpin.OnUpClick := BtnSpinUpClick;
  BtnSpin.OnDownClick := BtnSpinDownClick;
  BtnSpin.Align := alLeft;
end;

procedure TfrmGrid<TE, TS>.CreateBtnClose;
begin
  BtnClose := TButton.Create(PanelFooter);
  BtnClose.Parent := PanelFooter;
  BtnClose.Caption := 'Kapat';
  BtnClose.OnClick := BtnCloseClick;
  BtnClose.Align := alRight;
end;

procedure TfrmGrid<TE, TS>.CreateButtonAdd;
begin
  BtnAdd := TButton.Create(FPanelButtons);
  BtnAdd.Parent := FPanelButtons;
  BtnAdd.Caption := 'Kayıt Ekle';
  BtnAdd.OnClick := BtnAddClick;
  BtnAdd.Align := alNone;
  BtnAdd.Width := 80;
  BtnAdd.Left := 2;
  BtnAdd.Top := 2;
end;

procedure TfrmGrid<TE, TS>.DataSourceDataChange(Sender: TObject; Field: TField);
begin
//
end;

destructor TfrmGrid<TE, TS>.Destroy;
var
  n1: Integer;
begin
  FFilterStringFields.Free;
  FFilterNumericFields.Free;
  FFilterDateFields.Free;
  FFilterBoolFields.Free;
  FFilterGrid.Free;

  FQry.Close;
  FQry.Free;
  FreeAndNil(FDataSource);

  for n1 := 0 to Table.Fields.Count-1 do
  begin
    if Table.Fields[n1].OwnerEntity <> nil then
      Table.Fields[n1].OwnerEntity := nil;
  end;
  FTable := nil;
  inherited;
end;

procedure TfrmGrid<TE, TS>.FilterApply;
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
  RefreshStatusRecorCount();
end;

procedure TfrmGrid<TE, TS>.EdtFilterChange(Sender: TObject);
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
  Self.RefreshStatusRecorCount;
end;

procedure TfrmGrid<TE, TS>.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmGrid<TE, TS>.FormCreate(Sender: TObject);
begin
//
end;

procedure TfrmGrid<TE, TS>.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmGrid<TE, TS>.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//
end;

procedure TfrmGrid<TE, TS>.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Chr(VK_ESCAPE) then
  begin
    Self.Close;
  end;
end;

procedure TfrmGrid<TE, TS>.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F6 then
  begin
    Self.Close;
  end
  else if Key = VK_F7 then
  begin
    BtnAddClick(BtnAdd);
  end
  else if Key = VK_F11 then
  begin
    if (Self.AlphaBlendValue = 255) or (Self.AlphaBlendValue = 80) then
    begin
      Self.AlphaBlend := not Self.AlphaBlend;
      if not Self.AlphaBlend then
      begin
        Self.AlphaBlendValue := 255;
        Exit;
      end;
    end;

    case Self.AlphaBlendValue of
      255: Self.AlphaBlendValue := 150;
      150: Self.AlphaBlendValue := 80;
    end;
  end
end;

procedure TfrmGrid<TE, TS>.FormShow(Sender: TObject);
begin
  FQry.Open;

  PrepareFilteredColumns;
  PrepareStatusBar;
  PanelSidebar.Visible := False;
end;

function TfrmGrid<TE, TS>.getFilterEditData: string;
begin

end;

procedure TfrmGrid<TE, TS>.grdCellClick(Column: TColumn);
begin
//
end;

procedure TfrmGrid<TE, TS>.grdDblClick(Sender: TObject);
begin
  if FIsHelper then
    SetSelectedItem
  else
    mniPreviewClick(Grd);
end;

procedure TfrmGrid<TE, TS>.grdDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
//
end;

procedure TfrmGrid<TE, TS>.grdKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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

procedure TfrmGrid<TE, TS>.grdKeyPress(Sender: TObject; var Key: Char);
begin
//
end;

procedure TfrmGrid<TE, TS>.grdKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//
end;

procedure TfrmGrid<TE, TS>.grdTitleClick(Column: TColumn);
begin
  SortGridTitle(Column);
end;

procedure TfrmGrid<TE, TS>.SetQry(const Value: TFDQuery);
begin
  FQry := Value;
end;

procedure TfrmGrid<TE, TS>.SetSelectedItem;
{var
  AField: TField;
  n1, n2: Integer;}
begin
{  if Grd.DataSource.DataSet.RecordCount > 0 then
  begin
    AField := Grd.DataSource.DataSet.FindField(Table.Id.FieldName);
    if not Assigned(AField) or (AField = nil) or AField.IsNull then
      Exit;

    Table.Id.Value := VarToStr(AField.Value).ToInteger;

    for n1 := 0 to Table.Fields.Count-1 do
    begin
      for n2 := 0 to grd.Columns.Count-1 do
      begin
        if (Table.Fields.Items[n1]).FieldName = grd.Columns.Items[n2].Field.FieldName then
        begin
          Table.Fields[n1].Value := grd.Columns.Items[n2].Field.Value;
          Table.Fields[n1].IsNullable := not grd.Columns.Items[n2].Field.Required;
          Break;
        end;
      end;
    end;
  end;
}
end;

procedure TfrmGrid<TE, TS>.SetTable(Value: TE);
begin
  FTable := Value;
end;

procedure TfrmGrid<TE, TS>.ShowInputForm(Sender: TObject; AFormType: TInputFormMode);
var
  LForm: TForm;
  LOldTable: TE;
  n1: Integer;
begin
  if (AFormType = ifmRewiev)
  or ((not FQry.Connection.InTransaction) and ((AFormType = ifmNewRecord) or (AFormType = ifmCopyNewRecord)))
  then
  begin
    if (AFormType = ifmRewiev) or (AFormType = ifmCopyNewRecord) then
    begin
      LOldTable := Table;
      Table := Service.FindById(Table.Id.Value, False);
      for n1 := 0 to LOldTable.fields.Count-1 do
        LOldTable.fields[n1].OwnerEntity := nil;
    end;

    LForm := CreateInputForm(Sender, AFormType);
//    if Table is TTableDetailed then
//      PTable.FreeDetayListContent;
    LForm.Show;
  end
  else
    raise Exception.Create('Başka bir pencere giriş veya güncelleme için açılmış, önce bu işlemi tamamlayın.');
end;

procedure TfrmGrid<TE, TS>.SetPanelMain(const Value: TPanel);
begin
  FPanelMain := Value;
end;

procedure TfrmGrid<TE, TS>.SetService(const Value: TS);
begin
  FService := Value;
end;

procedure TfrmGrid<TE, TS>.SetEdtFilter(const Value: TEdit);
begin
  FEdtFilter := Value;
end;

procedure TfrmGrid<TE, TS>.SetPanelFooter(const Value: TPanel);
begin
  FPanelFooter := Value;
end;

procedure TfrmGrid<TE, TS>.SetGrd(const Value: TDBGrid);
begin
  FGrd := Value;
end;

procedure TfrmGrid<TE, TS>.SetPanelContent(const Value: TPanel);
begin
  FPanelContent := Value;
end;

procedure TfrmGrid<TE, TS>.SetPanelHeader(const Value: TPanel);
begin
  FPanelHeader := Value;
end;

procedure TfrmGrid<TE, TS>.SetPanelSidebar(const Value: TPanel);
begin
  FPanelSidebar := Value;
end;

procedure TfrmGrid<TE, TS>.SetPanelButtons(const Value: TPanel);
begin
  FPanelButtons := Value;
end;

procedure TfrmGrid<TE, TS>.SetPopupMenu(const Value: TPopupMenu);
begin
  FGridPopMenu := Value;
end;

procedure TfrmGrid<TE, TS>.SetmniExportCsv(const Value: TMenuItem);
begin
  FmniExportCsv := Value;
end;

procedure TfrmGrid<TE, TS>.SetmniExportExcel(const Value: TMenuItem);
begin
  FmniExportExcel := Value;
end;

procedure TfrmGrid<TE, TS>.SetmniFilter(const Value: TMenuItem);
begin
  FmniFilter := Value;
end;

procedure TfrmGrid<TE, TS>.SetmniFilterBack(const Value: TMenuItem);
begin
  FmniFilterBack := Value;
end;

procedure TfrmGrid<TE, TS>.SetmniFilterExclude(const Value: TMenuItem);
begin
  FmniFilterExclude := Value;
end;

procedure TfrmGrid<TE, TS>.SetmniFilterRemove(const Value: TMenuItem);
begin
  FmniFilterRemove := Value;
end;

procedure TfrmGrid<TE, TS>.SetmniPreview(const Value: TMenuItem);
begin
  FmniPreview := Value;
end;

procedure TfrmGrid<TE, TS>.SetmniPrint(const Value: TMenuItem);
begin
  FmniPrint := Value;
end;

procedure TfrmGrid<TE, TS>.SetmniRemoveGridSort(const Value: TMenuItem);
begin
  FmniRemoveGridSort := Value;
end;

procedure TfrmGrid<TE, TS>.mniExportExcelClick(Sender: TObject);
begin
  ShowMessage('not implemented yet!' + sLineBreak + 'Export Excel');
end;

procedure TfrmGrid<TE, TS>.mniFilterBackClick(Sender: TObject);
begin
  if FFilterGrid.Count > 0 then
  begin
    FFilterGrid.Delete(FFilterGrid.Count-1);
    FilterApply;
  end;
end;

procedure TfrmGrid<TE, TS>.mniFilterClick(Sender: TObject);
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

procedure TfrmGrid<TE, TS>.mniFilterExcludeClick(Sender: TObject);
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

procedure TfrmGrid<TE, TS>.mniFilterRemoveClick(Sender: TObject);
begin
  if FFilterGrid.Count > 0 then
  begin
    FFilterGrid.Clear;
    FilterApply;
  end;
end;

procedure TfrmGrid<TE, TS>.mniExportCsvClick(Sender: TObject);
begin
  ShowMessage('not implemented yet!' + sLineBreak + 'Export Csv');
end;

procedure TfrmGrid<TE, TS>.mniPreviewClick(Sender: TObject);
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

procedure TfrmGrid<TE, TS>.mniPrintClick(Sender: TObject);
begin
  ShowMessage('not implemented yet!' + sLineBreak + 'Print');
end;

procedure TfrmGrid<TE, TS>.mniRemoveSortClick(Sender: TObject);
begin
  if Qry.IndexFieldNames <> '' then
    Qry.IndexFieldNames := '';
end;

procedure TfrmGrid<TE, TS>.MoveDown;
begin
  Grd.DataSource.DataSet.Prior;
  SetSelectedItem();
end;

procedure TfrmGrid<TE, TS>.MoveUp;
begin
  Grd.DataSource.DataSet.Next;
  SetSelectedItem();
end;

procedure TfrmGrid<TE, TS>.OnFilterDataset(Dataset: TDataset; var Accept: Boolean);
begin
  //
end;

procedure TfrmGrid<TE, TS>.PrepareFilteredColumns;
var
  n1: Integer;
begin
  for n1 := 0 to Grd.Columns.Count - 1 do
  begin
    if Grd.Columns[n1].FieldName = 'id' then
      Continue;

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

procedure TfrmGrid<TE, TS>.PrepareForm;
begin
  Self.Position := poOwnerFormCenter;
  Self.KeyPreview := True;
  Self.Constraints.MinWidth := 720;
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

  PreparePopupMenu();

  CreatePanelMain;
    CreatePanelHeader;
      CreateFilterEdit;
    CreatePanelContent;
      CreateGrid;
      CreatePanelButtons;
        CreateButtonAdd;
    CreatePanelSidebar;
  CreatePanelFooter;
    CreateBtnSpin;
    CreateBtnClose;

  FStatusBase := TStatusBar.Create(Self);
  FStatusBase.Align := alBottom;
  FStatusBase.Parent := Self;
  FStatusBase.OnDrawPanel := StatusBarDrawPanel;
  FStatusBase.Font.Size := 8;
end;

procedure TfrmGrid<TE, TS>.PreparePopupMenu;
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

procedure TfrmGrid<TE, TS>.PrepareStatusBar;
begin
  //Status Bar content for Output DBGrid Forms
  //NumberOfRecords | SQL Server IP | Period | FirmTitle
  //Total: 2 | 127.0.0.1 | 2018 | JOHNDOE | F6 | F7 | F77

  StatusBarAddPanel(80, psOwnerDraw);
  StatusBarAddPanel(80, psOwnerDraw);
  StatusBarAddPanel(80, psOwnerDraw);
  StatusBarAddPanel(80, psOwnerDraw);
  StatusBarAddPanel(80, psOwnerDraw);
  StatusBarAddPanel(80, psOwnerDraw);
  StatusBarAddPanel(80, psOwnerDraw);


  if Service.Uow.Connection.Connected then
    RefreshStatusRecorCount;

  if Service.Uow.Connection.Connected then
    FStatusBase.Panels.Items[DB_STATUS_SQL_SERVER].Text := Service.Uow.Connection.Params.Values['Server'];

  FStatusBase.Panels.Items[DB_STATUS_PERIOD].Text := 'Dönem:2025';//TranslateText('Dönem', FrameworkLang.GeneralPeriod, LngGeneral, LngSystem) + ' ' + GSysApplicationSetting.Donem.AsString;

  if Service.Uow.Connection.Connected then
    FStatusBase.Panels.Items[DB_STATUS_USER].Text := GSysKullanici.AdSoyad.AsString;

  FStatusBase.Panels.Items[DB_STATUS_KEY_F6].Text := 'F6 İPTAL/KAPAT';
  FStatusBase.Panels.Items[DB_STATUS_KEY_F7].Text := 'F7 KAYIT EKLE';
  FStatusBase.Panels.Items[DB_STATUS_KEY_F11].Text := 'F11 ŞEFFAFLIK';
end;

procedure TfrmGrid<TE, TS>.RefreshData;
begin
  if (Table <> nil) and (Table.Id.Value > 0) then
    grd.DataSource.DataSet.Locate(Table.Id.FieldName, Table.Id.Value,[]);

  if FFilterGrid.Text <> '' then
  begin
    grd.DataSource.DataSet.Filter := FFilterGrid.Text;
    grd.DataSource.DataSet.Filtered := True;
    mniFilterRemove.Visible := True;
    mniFilterBack.Visible := True;
  end
  else
  begin
    grd.DataSource.DataSet.Filtered := False;
    grd.DataSource.DataSet.Filter := '';
    mniFilterRemove.Visible := False;
    mniFilterBack.Visible := False;
  end;

  RefreshStatusRecorCount;
end;

procedure TfrmGrid<TE, TS>.RefreshDataFirst;
begin

end;

procedure TfrmGrid<TE, TS>.RefreshParentGrid(AFocusSelectedItem: Boolean);
begin
  Grd.DataSource.DataSet.Refresh;
  if AFocusSelectedItem then
  begin
    Table.Id.Value := Table.Id.Value;
    Grd.DataSource.DataSet.Locate(Table.Id.FieldName, Table.Id.Value, [loCaseInsensitive]);
  end;
end;

procedure TfrmGrid<TE, TS>.RefreshStatusRecorCount();
begin
  if FStatusBase.Panels.Count > 0 then
    FStatusBase.Panels.Items[DB_STATUS_RECORD_COUNT].Text := Format('Records: %d', [Grd.DataSource.DataSet.RecordCount]);
end;

procedure TfrmGrid<TE, TS>.SortGridTitle(Sender: TObject);
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

procedure TfrmGrid<TE, TS>.StatusBarAddPanel(AWidth: Integer; AStyle: TStatusPanelStyle);
begin
  with FStatusBase.Panels.Add do
  begin
    Width := AWidth;
    Style := AStyle;
  end;
end;

procedure TfrmGrid<TE, TS>.StatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
var
  vIco: Integer;
begin
  FStatusBase.Canvas.Font.Name := DefaultFontName;
  FStatusBase.Canvas.Font.Style := [fsBold];

  FStatusBase.Canvas.TextRect(Rect,
    Rect.Left + dm.il16.Width,
    Rect.Top + (FStatusBase.Height-Canvas.TextHeight(Panel.Text)) div 2 - 2,
    Panel.Text);

  vIco := -1;
  case Panel.Index of
    DB_STATUS_RECORD_COUNT: vIco := IMG_SUM;
    DB_STATUS_SQL_SERVER: vIco := IMG_SERVER;
    DB_STATUS_PERIOD: vIco := IMG_CALENDAR;
    DB_STATUS_USER: vIco := IMG_USER_HE;
    DB_STATUS_KEY_F6: vIco := IMG_FAVORITE;
    DB_STATUS_KEY_F7: vIco := IMG_FAVORITE;
    DB_STATUS_KEY_F11: vIco := IMG_FAVORITE;
  end;

  if vIco > -1 then
  begin
    dm.il16.Draw(StatusBar.Canvas, Rect.Left, Rect.Top, vIco);
    Panel.Width := FStatusBase.Canvas.TextWidth(Panel.Text)+ dm.il16.Width + 16;
  end;
end;

end.

