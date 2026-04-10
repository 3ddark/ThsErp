unit ufrmGrid;

interface

uses
  Winapi.Windows, Winapi.Messages,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Option,
  System.SysUtils, System.Variants, System.Classes, System.StrUtils,
  System.Rtti, System.TypInfo, System.Generics.Collections,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Menus, Vcl.ComCtrls, Vcl.Grids, Vcl.ExtCtrls, Vcl.Clipbrd,
  Vcl.DBGrids, Vcl.Samples.Spin, Data.DB, Vcl.DBCtrls,
  udm, Ths.Constants, Ths.Globals, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  SharedFormTypes, Entity, Service, AppContext, UserContext, FilterCriterion;

const
  DB_STATUS_RECORD_COUNT = 0;
  DB_STATUS_SQL_SERVER   = 1;
  DB_STATUS_PERIOD       = 2;
  DB_STATUS_USER         = 3;
  DB_STATUS_KEY_F6       = 4;
  DB_STATUS_KEY_F7       = 5;
  DB_STATUS_KEY_F11      = 6;

type
  TAggregateType = (atSum, atCount, atAverage, atMin, atMax);

  TSortType = (stNone, stAsc, stDesc);

  TFooterColumn = class
  public
    ColumnFieldName: string;
    AggregateType: TAggregateType;
    DisplayFormat: string;
    AggregateField: TFDAggregate;
    DisplayControl: TLabel;
    constructor Create(const AColumnFieldName: string; AAggregateType: TAggregateType; const ADisplayFormat: string = '');
  end;

  THackDBGrid = class(TDBGrid)
  private
    FOnColWidthsChanged: TNotifyEvent;
  protected
    procedure ColWidthsChanged; override;
  public
    property OnColWidthsChanged: TNotifyEvent read FOnColWidthsChanged write FOnColWidthsChanged;
  end;

  TfrmGrid<TE: TEntity, constructor; TS: TCrudService<TE>> = class(TForm)
  private
    FFooterPanel: TPanel;
    FFooterColumns: TObjectList<TFooterColumn>;
    FService: TS;
    FTable: TE;
    FQry: TFDQuery;
    FDataSource: TDataSource;
    FGrd: THackDBGrid;

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

    procedure FilterApply;
    procedure PrepareFilteredColumns;
    procedure EdtFilterChange(Sender: TObject);
    procedure PrepareStatusBar;
    procedure BuildFilterExpression(AOperator: string);
  public
    property Service: TS read FService write FService;
    property Table: TE read FTable write FTable;
    property Grd: THackDBGrid read FGrd write FGrd;
    property Qry: TFDQuery read FQry write FQry;

    //for use HelperForm
    property IsHelper: Boolean read FIsHelper write FIsHelper default False;
    property DataAktar: Boolean read FDataAktar write FDataAktar;
    property CleanAndClose: Boolean read FCleanAndClose write FCleanAndClose default False;
    //for use HelperForm

    property PanelMain: TPanel read FPanelMain write FPanelMain;
    property PanelContent: TPanel read FPanelContent write FPanelContent;
    property PanelHeader: TPanel read FPanelHeader write FPanelHeader;
    property PanelSidebar: TPanel read FPanelSidebar write FPanelSidebar;
    property PanelButtons: TPanel read FPanelButtons write FPanelButtons;
    property PanelFooter: TPanel read FPanelFooter write FPanelFooter;
    property StatusBase: TStatusBar read FStatusBase write FStatusBase;
    property EdtFilter: TEdit read FEdtFilter write FEdtFilter;
    property BtnSpin: TSpinButton read FBtnSpin write FBtnSpin;
    property BtnClose: TButton read FBtnClose write FBtnClose;
    property BtnAdd: TButton read FBtnAdd write FBtnAdd;

    property GridPopMenu: TPopupMenu read FGridPopMenu write FGridPopMenu;
    property mniPreview: TMenuItem read FmniPreview write FmniPreview;
    property mniFilter: TMenuItem read FmniFilter write FmniFilter;
    property mniFilterExclude: TMenuItem read FmniFilterExclude write FmniFilterExclude;
    property mniFilterBack: TMenuItem read FmniFilterBack write FmniFilterBack;
    property mniFilterRemove: TMenuItem read FmniFilterRemove write FmniFilterRemove;
    property mniExportExcel: TMenuItem read FmniExportExcel write FmniExportExcel;
    property mniExportCsv: TMenuItem read FmniExportCsv write FmniExportCsv;
    property mniPrint: TMenuItem read FmniPrint write FmniPrint;
    property mniRemoveGridSort: TMenuItem read FmniRemoveGridSort write FmniRemoveGridSort;

    constructor Create(AOwner: TComponent; AService: TS; ATable: TE; ACreateNewBase: Boolean = True; AUseHelper: Boolean = False); reintroduce; overload;
    destructor Destroy; override;

    procedure SetSelectedItem; virtual;
    //for use HelperForm
    function getFilterEditData(): string; virtual;
    //for use HelperForm
    procedure ShowInputForm(Sender: TObject; AFormType: TInputFormMode); virtual;

    procedure MoveUp(); virtual;
    procedure MoveDown(); virtual;
    procedure AddFooterColumn(const AColumnFieldName: string; AAggregateType: TAggregateType; const ADisplayFormat: string = '');
    procedure DefineFooterColumns; virtual;
    procedure DefineColumnWidths; virtual;
    procedure SetColumnProperty(const AFieldName: string; AWidth: Integer; AColumnTitle: string);
    procedure BuildFooter;
    procedure CreateFooterPanel;
    procedure UpdateFooterLayout;

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
    procedure grdColumnMoved(Sender: TObject; FromIndex, ToIndex: Integer); virtual;
    procedure grdMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure GridColWidthsChanged(Sender: TObject);
    procedure SortGridTitle(Sender: TObject);

    procedure RefreshDataFirst();
    procedure RefreshData();
    //***query***
    procedure AfterDatasetOpen(Dataset: TDataset); virtual;
    procedure OnFilterDataset(Dataset: TDataset; var Accept: Boolean); virtual;
    //***datasource***
    procedure DataSourceDataChange(Sender: TObject; Field: TField);
    //***status bar***
    procedure RefreshStatusRecordCount();
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
  function CsvSafe(const S: string): string;

implementation

uses ufrmInputSimpleDB, Logger;

{ TFooterColumn }

constructor TFooterColumn.Create(const AColumnFieldName: string;
  AAggregateType: TAggregateType; const ADisplayFormat: string);
begin
  inherited Create;
  ColumnFieldName := AColumnFieldName;
  AggregateType := AAggregateType;
  DisplayFormat := ADisplayFormat;
end;

{ THackDBGrid }

procedure THackDBGrid.ColWidthsChanged;
begin
  inherited;
  if Assigned(FOnColWidthsChanged) then
    FOnColWidthsChanged(Self);
end;

{ TfrmGrid }

procedure TfrmGrid<TE, TS>.AddFooterColumn(const AColumnFieldName: string; AAggregateType: TAggregateType; const ADisplayFormat: string);
begin
  if FFooterColumns = nil then
    FFooterColumns := TObjectList<TFooterColumn>.Create(True);
  FFooterColumns.Add(TFooterColumn.Create(AColumnFieldName, AAggregateType, ADisplayFormat));
end;

function UpperCaseTr(S: string): string;
begin
  Result := AnsiUpperCase(StringReplace(StringReplace(S, 'ı', 'I', [rfReplaceAll]), 'i', 'İ', [rfReplaceAll]));
end;

function LowerCaseTr(S: string): string;
begin
  Result := AnsiLowerCase(StringReplace(StringReplace(S, 'I', 'ı', [rfReplaceAll]), 'İ', 'i', [rfReplaceAll]));
end;

function CsvSafe(const S: string): string;
begin
  Result := StringReplace(S, '"', '""', [rfReplaceAll]);
  if (Pos(',', Result) > 0) or (Pos('"', Result) > 0) or (Pos(#13, Result) > 0) or (Pos(#10, Result) > 0) then
    Result := '"' + Result + '"';
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
  DefineColumnWidths;
  RefreshStatusRecordCount();
end;

procedure TfrmGrid<TE, TS>.BtnCloseClick(Sender: TObject);
begin
  if FIsHelper then
  begin
    FDataAktar := True;
    FCleanAndClose := True;
    if Owner is TEdit then
      TEdit(Owner).Clear;
    btnCloseClick(btnClose);
  end;
  Self.Close;
end;

procedure TfrmGrid<TE, TS>.BtnAddClick(Sender: TObject);
begin
  ShowInputForm(Sender, ifmNewRecord);
end;

procedure TfrmGrid<TE, TS>.BtnSpinDownClick(Sender: TObject);
begin
  MoveDown;
end;

procedure TfrmGrid<TE, TS>.BtnSpinUpClick(Sender: TObject);
begin
  MoveUp;
end;

procedure TfrmGrid<TE, TS>.BuildFilterExpression(AOperator: string);
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
      ftString:       LFilterVal := Grd.SelectedField.FieldName + AOperator + QuotedStr(Grd.SelectedField.AsString);
      ftSmallint:     LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftInteger:      LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftWord:         LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftBoolean:      LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftFloat:        LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftCurrency:     LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftBCD:          LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftDate:         LFilterVal := Grd.SelectedField.FieldName + AOperator + QuotedStr(Grd.SelectedField.AsString);
      ftTime:         LFilterVal := Grd.SelectedField.FieldName + AOperator + QuotedStr(Grd.SelectedField.AsString);
      ftDateTime:     LFilterVal := Grd.SelectedField.FieldName + AOperator + QuotedStr(Grd.SelectedField.AsString);
      ftBytes:        LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftVarBytes:     LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftAutoInc:      LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftBlob:         LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftMemo:         LFilterVal := Grd.SelectedField.FieldName + AOperator + QuotedStr(Grd.SelectedField.AsString);
      ftGraphic:      LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftFmtMemo:      LFilterVal := Grd.SelectedField.FieldName + AOperator + QuotedStr(Grd.SelectedField.AsString);
      ftParadoxOle: ;
      ftDBaseOle: ;
      ftTypedBinary: ;
      ftCursor: ;
      ftFixedChar:    LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftWideString:   LFilterVal := Grd.SelectedField.FieldName + AOperator + QuotedStr(Grd.SelectedField.AsString);
      ftLargeint:     LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftADT: ;
      ftArray:        LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftReference: ;
      ftDataSet: ;
      ftOraBlob: ;
      ftOraClob: ;
      ftVariant: ;
      ftInterface: ;
      ftIDispatch: ;
      ftGuid: ;
      ftTimeStamp:    LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftFMTBcd:       LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftFixedWideChar:LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftWideMemo:     LFilterVal := Grd.SelectedField.FieldName + AOperator + QuotedStr(Grd.SelectedField.AsString);
      ftOraTimeStamp: LFilterVal := Grd.SelectedField.FieldName + AOperator + QuotedStr(Grd.SelectedField.AsString);
      ftOraInterval: ;
      ftLongWord:     LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftShortint:     LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftByte:         LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftExtended:     LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
      ftConnection: ;
      ftParams: ;
      ftStream: ;
      ftTimeStampOffset: ;
      ftObject: ;
      ftSingle:       LFilterVal := Grd.SelectedField.FieldName + AOperator + Grd.SelectedField.AsString;
    end;

    FFilterGrid.Add(LFilterBefore + LFilterVal);
  end;

end;

procedure TfrmGrid<TE, TS>.BuildFooter;
var
  FooterCol: TFooterColumn;
  AggregateFuncName: string;
begin
  if (FFooterColumns = nil) or (FFooterColumns.Count = 0) then
    Exit;

  if FQry.Active then
    raise Exception.Create('BuildFooter: Query must be closed before creating aggregate fields');

  for FooterCol in FFooterColumns do
  begin
    case FooterCol.AggregateType of
      atSum: AggregateFuncName := 'SUM';
      atCount: AggregateFuncName := 'COUNT';
      atAverage: AggregateFuncName := 'AVG';
      atMin: AggregateFuncName := 'MIN';
      atMax: AggregateFuncName := 'MAX';
    else
      AggregateFuncName := 'SUM';
    end;


    FooterCol.AggregateField := FQry.Aggregates.Add;
    FooterCol.AggregateField.Name := Format('AGG_%s_%s', [AggregateFuncName, FooterCol.ColumnFieldName]);
    FooterCol.AggregateField.Expression := Format('%s(%s)', [AggregateFuncName, FooterCol.ColumnFieldName]);
    FooterCol.AggregateField.Active := True;

    FooterCol.DisplayControl := TLabel.Create(FFooterPanel);
    FooterCol.DisplayControl.Parent := FFooterPanel;
    FooterCol.DisplayControl.Font.Style := [fsBold];
    FooterCol.DisplayControl.Font.Size := 8;
    FooterCol.DisplayControl.Font.Color := clBlack;
    FooterCol.DisplayControl.AutoSize := True;
    FooterCol.DisplayControl.Caption := FooterCol.AggregateField.Name;
  end;

  FFooterPanel.Visible := True;
  FQry.AggregatesActive := True;
end;

constructor TfrmGrid<TE, TS>.Create(AOwner: TComponent; AService: TS; ATable: TE; ACreateNewBase, AUseHelper: Boolean);
begin
  if ACreateNewBase then
    CreateNew(AOwner);

  GLogger.InfoFmt('Created Grid Form %s: %s %s', [IfThen(AUseHelper, 'with Helper Mode', ''), Self.ClassName, ATable.ClassName]);

  FService := AService;
  FTable := ATable;

  FIsHelper := AUseHelper;

  Self.Caption := 'Base Title';

  FQry := FService.CreateQueryForUI(nil);
  FQry.FetchOptions.Mode := fmAll;
  FQry.AfterOpen := AfterDatasetOpen;
  FQry.OnFilterRecord := OnFilterDataset;

  FDataSource := TDataSource.Create(Self);
  FDataSource.DataSet := FQry;
  FDataSource.OnDataChange := DataSourceDataChange;

  FFooterColumns := TObjectList<TFooterColumn>.Create(True);
  FFilterStringFields := TStringList.Create;
  FFilterNumericFields := TStringList.Create;
  FFilterDateFields := TStringList.Create;
  FFilterBoolFields := TStringList.Create;
  FFilterGrid := TStringList.Create;

  PrepareForm();

  DefineFooterColumns;

  Self.ActiveControl := Grd;
end;

function TfrmGrid<TE, TS>.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
end;

procedure TfrmGrid<TE, TS>.CreateFooterPanel;
begin
  FFooterPanel := TPanel.Create(PanelContent);
  FFooterPanel.Parent := Self.PanelContent; // PanelMain yerine PanelContent
  FFooterPanel.Align := alTop;
  FFooterPanel.Height := 30; // 125 çok fazla, 30 yeterli
  FFooterPanel.BevelOuter := bvNone;
  FFooterPanel.Color := $00F0F0F0; // Açık gri
  FFooterPanel.Font.Color := clBlack;
  FFooterPanel.Font.Style := [fsBold];
  FFooterPanel.Visible := False;
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
  Grd := THackDBGrid.Create(PanelContent);
  Grd.Parent := PanelContent;
  Grd.Align := alClient;
  Grd.DataSource := FDataSource;
  Grd.Options := Grd.Options - [dgEditing, dgConfirmDelete];

  // Events
  Grd.OnDblClick := grdDblClick;
  Grd.OnCellClick := grdCellClick;
  Grd.OnKeyPress := grdKeyPress;
  Grd.OnKeyDown := grdKeyDown;
  Grd.OnKeyUp := grdKeyUp;
  Grd.OnTitleClick := grdTitleClick;
  Grd.OnDrawColumnCell := grdDrawColumnCell;
  Grd.OnColumnMoved := grdColumnMoved;
  Grd.OnMouseUp := grdMouseUp;
  Grd.OnColWidthsChanged := GridColWidthsChanged;
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
  BtnSpin.Margins.Left := 8;
  BtnSpin.AlignWithMargins := True;
end;

procedure TfrmGrid<TE, TS>.CreateBtnClose;
begin
  BtnClose := TButton.Create(PanelFooter);
  BtnClose.Parent := PanelFooter;
  BtnClose.Caption := 'Kapat';
  BtnClose.OnClick := BtnCloseClick;
  BtnClose.Align := alRight;
  BtnClose.Margins.Right := 8;
  BtnClose.AlignWithMargins := True;
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

procedure TfrmGrid<TE, TS>.DefineColumnWidths;
begin
//
end;

procedure TfrmGrid<TE, TS>.DefineFooterColumns;
begin
//
end;

destructor TfrmGrid<TE, TS>.Destroy;
begin
  FreeAndNil(FFooterColumns);
  FreeAndNil(FFilterStringFields);
  FreeAndNil(FFilterNumericFields);
  FreeAndNil(FFilterDateFields);
  FreeAndNil(FFilterBoolFields);
  FreeAndNil(FFilterGrid);

  FQry.Close;
  FQry.Free;
  FreeAndNil(FDataSource);

  FService.Free;
  FreeAndNil(FTable);
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
  RefreshStatusRecordCount();
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
      for n1 := 0 to FFilterDateFields.Count-1 do
      begin
        if LFilter <> '' then
          LFilter := LFilter + ' OR ';
        LFilter := LFilter + FFilterDateFields.Strings[n1] + '=' + EdtFilter.Text;
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
  Self.RefreshStatusRecordCount;
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
  BuildFooter;
  FQry.Open;

  PrepareFilteredColumns;
  PanelSidebar.Visible := False;
  PrepareStatusBar;

  if FIsHelper then
  begin
    EdtFilter.SetFocus;
  end;
end;

function TfrmGrid<TE, TS>.getFilterEditData: string;
begin

end;

procedure TfrmGrid<TE, TS>.grdCellClick(Column: TColumn);
begin
//
end;

procedure TfrmGrid<TE, TS>.grdColumnMoved(Sender: TObject; FromIndex, ToIndex: Integer);
begin
//
end;

procedure TfrmGrid<TE, TS>.grdDblClick(Sender: TObject);
begin
  if FIsHelper then
  begin
    SetSelectedItem;
    DataAktar := True;
    ModalResult := mrYes;
    Self.Close;
  end
  else
    mniPreviewClick(Grd);
end;

procedure TfrmGrid<TE, TS>.grdDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
const
  CtrlState: array[Boolean] of integer = (DFCS_BUTTONCHECK, DFCS_BUTTONCHECK or DFCS_CHECKED) ;
  sEMPTY = '';

var
  nValue, nWidth1, nLeft2: Integer;
  clActualPenColor, clActualBrushColor: TColor;
  bEmptyDS: Boolean;
  DrawRect: TRect;
  sValue: string;

  Bmp: TBitmap;

  LColorActive: TColor;
  LColor1: TColor;
  LColor2: TColor;
begin
  //Satırı renklendir.
  LColorActive := 4752;
  LColor1 := 5435345;
  LColor2 := 3543;

  if THackDBGrid(Sender).DataLink.ActiveRecord = THackDBGrid(Sender).Row - 1 then
  begin
    if LColorActive > 0 then  THackDBGrid(Sender).Canvas.Brush.Color := LColorActive
  end
  else if (THackDBGrid(Sender).DataSource.DataSet.RecNo mod 2 = 0) then
  begin
    if LColor1 > 0 then THackDBGrid(Sender).Canvas.Brush.Color := LColor1
  end
  else if THackDBGrid(Sender).DataSource.DataSet.RecNo mod 2 = 1 then
  begin
    if LColor2 > 0 then THackDBGrid(Sender).Canvas.Brush.Color := LColor2;
  end;

  THackDBGrid(Sender).DefaultDrawColumnCell(Rect, DataCol, Column, State);

  //boolean tipler için checkbox çiz
  if (Column.Field.DataType = ftBoolean) then
  begin
    THackDBGrid(Sender).Canvas.FillRect(Rect);
    if Column.Field.IsNull then
      DrawFrameControl(THackDBGrid(Sender).Canvas.Handle, Rect, DFC_BUTTON, DFCS_BUTTONCHECK or DFCS_INACTIVE)
    else
      DrawFrameControl(THackDBGrid(Sender).Canvas.Handle, Rect, DFC_BUTTON, CtrlState[Column.Field.AsBoolean]);
  end
  else if Column.Field is TGraphicField then
  begin
    Bmp := TBitmap.Create;
    try
      Bmp.Assign(Column.Field);
      THackDBGrid(Sender).Canvas.StretchDraw(Rect, Bmp);
    finally
      Bmp.Free;
    end
  end
  else
  begin
{    if IsYuzdeCizimAlaniVar(Column.FieldName) then
    begin
      begin
        bEmptyDS := ((TDBGrid(Sender).DataSource.DataSet.EoF) and (TDBGrid(Sender).DataSource.DataSet.Bof));

        if (Column.Field.IsNull) then
        begin
          nValue := -1;
          sValue := sEMPTY;
        end
        else
        begin
          nValue := Column.Field.AsInteger;
          sValue := IntToStr(nValue);// + ' ' + chPERCENT;
        end;

        DrawRect := Rect;
        InflateRect(DrawRect, -1, -1);

        nWidth1 := (((DrawRect.Right - DrawRect.Left) * nValue) DIV Trunc(GetPercentMaxVal(Column.Field)) );

        clActualPenColor := TDBGrid(Sender).Canvas.Pen.Color;
        clActualBrushColor := TDBGrid(Sender).Canvas.Brush.Color;

        TDBGrid(Sender).Canvas.Pen.Color := clBlack;
        TDBGrid(Sender).Canvas.Brush.Color := ColorBarBack;
        if THackDBGrid(Sender).DataLink.ActiveRecord = THackDBGrid(Sender).Row - 1 then
          TDBGrid(Sender).Canvas.Font.Color := FColorBarTextActive// clActualFontColor
        else
          TDBGrid(Sender).Canvas.Font.Color := FColorBarText;

        TDBGrid(Sender).Canvas.Rectangle(DrawRect);

        if (nValue > 0) then
        begin
          TDBGrid(Sender).Canvas.Pen.Color := ColorBar;
          TDBGrid(Sender).Canvas.Brush.Color := ColorBar;
          DrawRect.Right := DrawRect.Left + nWidth1;
          InflateRect(DrawRect, -1, -1);
          TDBGrid(Sender).Canvas.Rectangle(DrawRect);
        end;

        if not (bEmptyDS) then
        begin
          DrawRect := Rect;
          InflateRect(DrawRect, -2, -2);
          TDBGrid(Sender).Canvas.Brush.Style := bsClear;
          nLeft2 := DrawRect.Left + (DrawRect.Right - DrawRect.Left) shr 1 -
                    (TDBGrid(Sender).Canvas.TextWidth(sValue) shr 1);
          TDBGrid(Sender).Canvas.TextRect(DrawRect, nLeft2, DrawRect.Top, sValue);
        end;

        TDBGrid(Sender).Canvas.Pen.Color := clActualPenColor;
        TDBGrid(Sender).Canvas.Brush.Color := clActualBrushColor;
      end;
    end
    else if IsRenkliRakamVar(Column.FieldName) then
    begin
//      clActualBrushColor := TDBGrid(Sender).Canvas.Brush.Color;
//
//      TDBGrid(Sender).Canvas.Brush.Color := GetLowHighEqual(Column.Field, TDBGrid(Sender).Canvas.Brush.Color);
//
//      TDBGrid(Sender).DefaultDrawColumnCell(Rect, DataCol, Column, State);
//      TDBGrid(Sender).Canvas.Brush.Color := clActualBrushColor;
    end;  }
  end;

{
  if  (Column.Visible) and (Pos(Column.FieldName, TFDQuery(THackDBGrid(Sender).DataSource.DataSet).IndexFieldNames) > 0) then
  begin
    sValue := '';
    if Pos(Column.FieldName + ':A', TFDQuery(THackDBGrid(Sender).DataSource.DataSet).IndexFieldNames) > 0 then
      sValue := MidStr(
        TFDQuery(THackDBGrid(Sender).DataSource.DataSet).IndexFieldNames,
        Pos(Column.FieldName + ':A', TFDQuery(THackDBGrid(Sender).DataSource.DataSet).IndexFieldNames),
        Length(Column.FieldName + ':A'))
    else if Pos(Column.FieldName + ':D', TFDQuery(THackDBGrid(Sender).DataSource.DataSet).IndexFieldNames) > 0 then
      sValue := MidStr(
        TFDQuery(THackDBGrid(Sender).DataSource.DataSet).IndexFieldNames,
        Pos(Column.FieldName + ':D', TFDQuery(THackDBGrid(Sender).DataSource.DataSet).IndexFieldNames),
        Length(Column.FieldName + ':D'));

    if Pos(':A', sValue) > 0 then //yukarý yöndeki ok ASC
      drawTriangleInRect(THackDBGrid(Sender).CellRect(DataCol+1, 0), stAsc, taLeftJustify)
    else if Pos(':D', sValue) > 0 then  //aþaðý yöndeki ok DESC
      drawTriangleInRect(THackDBGrid(Sender).CellRect(DataCol+1, 0), stDesc, taLeftJustify);
  end;
}
end;

procedure TfrmGrid<TE, TS>.grdKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  AGrid: THackDBGrid;
begin
  if not (Sender is THackDBGrid) then
    Exit;

  AGrid := (Sender as THackDBGrid);
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

procedure TfrmGrid<TE, TS>.grdMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
//
end;

procedure TfrmGrid<TE, TS>.grdTitleClick(Column: TColumn);
begin
  SortGridTitle(Column);
end;

procedure TfrmGrid<TE, TS>.GridColWidthsChanged(Sender: TObject);
begin
  UpdateFooterLayout;
end;

procedure TfrmGrid<TE, TS>.UpdateFooterLayout;
var
  FooterCol: TFooterColumn;
  GridCol: TColumn;
  i: Integer;
  CurrentLeft: Integer;
  fc: TFooterColumn;
  FormatText: string;
  Value: Variant;
begin
  if (FFooterPanel = nil) or not FFooterPanel.Visible then
    Exit;
  if FFooterColumns = nil then
    Exit;

  CurrentLeft := 0;
  if dgIndicator in Grd.Options then
    CurrentLeft := IndicatorWidth;

  for i := 0 to Grd.Columns.Count - 1 do
  begin
    GridCol := Grd.Columns[i];
    FooterCol := nil;

    for fc in FFooterColumns do
    begin
      if SameText(fc.ColumnFieldName, GridCol.FieldName) then
      begin
        FooterCol := fc;
        Break;
      end;
    end;

    // Footer varsa konumlandır
    if Assigned(FooterCol) and Assigned(FooterCol.DisplayControl) then
    begin
      if GridCol.Visible then
      begin
        FooterCol.DisplayControl.Visible := True;
        FooterCol.DisplayControl.Left := CurrentLeft;
        FooterCol.DisplayControl.Width := GridCol.Width;
        FooterCol.DisplayControl.Height := 20;
        FooterCol.DisplayControl.Top := 5;

        Value := FooterCol.AggregateField.Value;
        if not VarIsNull(Value) then
        begin
          case GridCol.Field.DataType of
            ftByte,
            ftWord,
            ftLongWord,
            ftShortint,
            ftSmallint,
            ftInteger,
            ftLargeint,
            ftFloat,
            ftCurrency,
            ftBCD,
            ftFMTBcd,
            ftExtended,
            ftSingle:
              begin
                FormatText := '0.00';
                FooterCol.DisplayControl.Caption := FormatFloat(FormatText, Value);
              end;

            ftDate,
            ftTime,
            ftDateTime,
            ftTimeStamp:
              begin
                FooterCol.DisplayControl.Caption := FormatDateTime('dd.mm.yyyy hh:nn:ss', Value);
              end;

          else
            FooterCol.DisplayControl.Caption := VarToStr(Value);
          end;
        end
        else
          FooterCol.DisplayControl.Caption := '';

        case GridCol.Alignment of
          taLeftJustify:  FooterCol.DisplayControl.Alignment := taLeftJustify;
          taRightJustify: FooterCol.DisplayControl.Alignment := taRightJustify;
          taCenter:       FooterCol.DisplayControl.Alignment := taCenter;
        end;
      end
      else
        FooterCol.DisplayControl.Visible := False;
    end;

    if GridCol.Visible then
      CurrentLeft := CurrentLeft + GridCol.Width;
  end;
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
begin
  BuildFilterExpression('=');
  FilterApply;
end;

procedure TfrmGrid<TE, TS>.mniFilterExcludeClick(Sender: TObject);
begin
  BuildFilterExpression('<>');
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
var
  SL: TStringList;
  i, j: Integer;
  Line: string;
begin
  SL := TStringList.Create;
  try
    Line := '';
    for i := 0 to Grd.Columns.Count - 1 do
    begin
      Line := Line + Grd.Columns[i].Title.Caption;
      if i < Grd.Columns.Count - 1 then
        Line := Line + ',';
    end;
    SL.Add(Line);

    Grd.DataSource.DataSet.DisableControls;
    try
      Grd.DataSource.DataSet.First;
      while not Grd.DataSource.DataSet.Eof do
      begin
        Line := '';
        for j := 0 to Grd.Columns.Count - 1 do
        begin
          Line := Line + CsvSafe(Grd.Columns[j].Field.AsString);
          if j < Grd.Columns.Count - 1 then
            Line := Line + ',';
        end;
        SL.Add(Line);

        Grd.DataSource.DataSet.Next;
      end;
    finally
      Grd.DataSource.DataSet.EnableControls;
    end;

    SL.SaveToFile('export.csv', TEncoding.UTF8);
    ShowMessage('CSV export tamamlandı!');
  finally
    SL.Free;
  end;
end;

procedure TfrmGrid<TE, TS>.mniPreviewClick(Sender: TObject);
begin
  if mniPreview.Visible then
  begin
    if (Grd.DataSource.DataSet.RecordCount > 0) then
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
  Grd.DataSource.DataSet.Next;
  SetSelectedItem();
end;

procedure TfrmGrid<TE, TS>.MoveUp;
begin
  Grd.DataSource.DataSet.Prior;
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
  CreateFooterPanel;

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
    RefreshStatusRecordCount;

  if Service.Uow.Connection.Connected then
    FStatusBase.Panels.Items[DB_STATUS_SQL_SERVER].Text := Service.Uow.Connection.Params.Values['Server'];

  FStatusBase.Panels.Items[DB_STATUS_PERIOD].Text := 'Dönem:2025';//TranslateText('Dönem', FrameworkLang.GeneralPeriod, LngGeneral, LngSystem) + ' ' + GSysApplicationSetting.Donem.AsString;

  if Service.Uow.Connection.Connected then
    FStatusBase.Panels.Items[DB_STATUS_USER].Text := TAppContext.Instance.CurrentUser.User.Person.FullName;

  FStatusBase.Panels.Items[DB_STATUS_KEY_F6].Text := 'F6 İPTAL/KAPAT';
  FStatusBase.Panels.Items[DB_STATUS_KEY_F7].Text := 'F7 KAYIT EKLE';
  FStatusBase.Panels.Items[DB_STATUS_KEY_F11].Text := 'F11 ŞEFFAFLIK';
end;

procedure TfrmGrid<TE, TS>.RefreshData;
begin
  if (Table <> nil) and (Table.Id > 0) then
    grd.DataSource.DataSet.Locate('id', Table.Id,[]);

  if FFilterGrid.Text <> '' then
  begin
    grd.DataSource.DataSet.Filter := FFilterGrid.Text;
    grd.DataSource.DataSet.Filtered := True;
    mniFilterRemove.Enabled := True;
    mniFilterBack.Enabled := True;
  end
  else
  begin
    grd.DataSource.DataSet.Filtered := False;
    grd.DataSource.DataSet.Filter := '';
    mniFilterRemove.Enabled := False;
    mniFilterBack.Enabled := False;
  end;

  RefreshStatusRecordCount;
end;

procedure TfrmGrid<TE, TS>.RefreshDataFirst;
begin
//
end;

procedure TfrmGrid<TE, TS>.RefreshParentGrid(AFocusSelectedItem: Boolean);
begin
  Grd.DataSource.DataSet.Refresh;
  if AFocusSelectedItem then
  begin
    Grd.DataSource.DataSet.Locate('id', Table.Id, [loCaseInsensitive]);
  end;
  UpdateFooterLayout;
end;

procedure TfrmGrid<TE, TS>.RefreshStatusRecordCount();
begin
  if FStatusBase.Panels.Count > 0 then
    FStatusBase.Panels.Items[DB_STATUS_RECORD_COUNT].Text := Format('Records: %d', [Grd.DataSource.DataSet.RecordCount]);
  UpdateFooterLayout;
end;

procedure TfrmGrid<TE, TS>.SetColumnProperty(const AFieldName: string; AWidth: Integer; AColumnTitle: string);
var
  i: Integer;
begin
  for i := 0 to Grd.Columns.Count - 1 do
  begin
    if SameText(Grd.Columns[i].FieldName, AFieldName) then
    begin
      if AWidth <= 0 then
        Grd.Columns[i].Visible := False
      else
        Grd.Columns[i].Width := AWidth;
      Grd.Columns[i].Title.Caption := AColumnTitle;
      Break;
    end;
  end;
end;

procedure TfrmGrid<TE, TS>.SetSelectedItem;
begin
  Service.FillEntityFromDataSet(Qry, Table);
end;

procedure TfrmGrid<TE, TS>.ShowInputForm(Sender: TObject; AFormType: TInputFormMode);
var
  LForm: TForm;
  LId: Int64;
begin
  if (AFormType = ifmRewiev)
  or ((not Service.UoW.InTransaction) and ((AFormType = ifmNewRecord) or (AFormType = ifmCopyNewRecord)))
  then
  begin
    if (AFormType = ifmRewiev) or (AFormType = ifmCopyNewRecord) then
    begin
      LId := Table.Id;
      FreeAndNil(Table);
      Table := Service.FindById(LId, False, True);
    end;
    LForm := CreateInputForm(Sender, AFormType);
    LForm.Show;
  end
  else
    raise Exception.Create('Başka bir pencere giriş veya güncelleme için açılmış, önce bu işlemi tamamlayın.');
end;

procedure TfrmGrid<TE, TS>.SortGridTitle(Sender: TObject);
var
  sl: TStringList;
  LOrderList: string;
  LOrderedColumn, LIsCTRLKeyPress: Boolean;
  nIndex: Integer;
  LColumn: TColumn;
  AQuery: TFDQuery;
begin
  if Sender is TColumn then
    LColumn := Sender as TColumn
  else
    Exit;

  LOrderedColumn := False;
  LIsCTRLKeyPress := False;
  sl := TStringList.Create;
  try
    AQuery := TFDQuery(grd.DataSource.DataSet);
    begin
      if isCtrlDown then
        LIsCTRLKeyPress := True;
      //sort düzenle
      sl.Delimiter := ';';
      if AQuery.IndexFieldNames <> '' then
        sl.DelimitedText := AQuery.IndexFieldNames;

      if LIsCTRLKeyPress then
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
        mniRemoveGridSort.Visible := True;

      AQuery.IndexFieldNames := LOrderList;
    end;

    THackDBGrid(grd).InvalidateTitles;
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

