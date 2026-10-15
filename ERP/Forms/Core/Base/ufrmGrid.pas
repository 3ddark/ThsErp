unit ufrmGrid;

interface

uses
  Winapi.Windows, Winapi.Messages,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Option, FireDAC.Stan.Param,
  System.SysUtils, System.Variants, System.Classes, System.StrUtils,
  System.Rtti, System.TypInfo, System.Generics.Collections,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Menus, Vcl.ComCtrls, Vcl.Grids, Vcl.ExtCtrls, Vcl.Clipbrd, Vcl.CheckLst,
  Vcl.DBGrids, Vcl.Samples.Spin, Data.DB, Vcl.DBCtrls, LocalizationManager,
  udm, Ths.Constants, Ths.Globals, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  SharedFormTypes, ufrmBase, Entity, EntityAttributes, Service, AppContext, UserContext, FilterCriterion;

const
  DB_STATUS_RECORD_COUNT = 0;
  DB_STATUS_SQL_SERVER   = 1;
  DB_STATUS_PERIOD       = 2;
  DB_STATUS_USER         = 3;
  DB_STATUS_KEY_F6       = 4;
  DB_STATUS_KEY_F7       = 5;
  DB_STATUS_KEY_F11      = 6;

type
  TAggregateType = SharedFormTypes.TAggregateType;

  TSortType = (stNone, stAsc, stDesc);

  TFooterColumn = class
  public
    ColumnFieldName: string;
    AggregateType: TAggregateType;
    DisplayFormat: string;
    AggregateField: TFDAggregate;
    ServerValue: Variant;       // sayfalı modda tüm (filtreli) kayıtlar üzerinden SQL ile hesaplanan değer
    DisplayControl: TLabel;
    constructor Create(const AColumnFieldName: string; AAggregateType: TAggregateType; const ADisplayFormat: string = '');
  end;

  // Hızlı filtre seçeneği (başlık çubuğunda radyo düğmesi); Sql boş = koşulsuz
  TQuickFilter = class
  public
    Sql: string;
    Params: TArray<Variant>;     // Sql içinde :qc0, :qc1 …
    Button: TRadioButton;
  end;

  THackDBGrid = class(TDBGrid)
  private
    FOnColWidthsChanged: TNotifyEvent;
  protected
    procedure ColWidthsChanged; override;
  public
    property OnColWidthsChanged: TNotifyEvent read FOnColWidthsChanged write FOnColWidthsChanged;
  end;

  // Kayıt geçmişi (işlem geçmişi) kancası: ufrmSysAuditLogs initialization'da bağlanır (ufrmGrid ona bağımlı olmasın)
  TRecordHistoryAvailable = function(const ATableName: string): Boolean;
  TRecordHistoryShow = procedure(AOwner: TComponent; const ATableName: string; ARowId: Int64; const ARecordCaption: string);

  // Sayfa değişiminde kullanıcının o anki kolon düzeni (genişlik / görünürlük / sıra / başlık) korunur
  TGridColumnState = record
    FieldName: string;
    Width: Integer;
    Visible: Boolean;
    Caption: string;
  end;

  TfrmGrid<TE: TEntity, constructor; TS: TCrudService<TE>> = class(TForm, ILocalizable)
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
    FDataTransfer: Boolean;
    FCleanAndClose: Boolean;
    //for use HelperForm

    FFilterStringFields: TStringList;
    FFilterNumericFields: TStringList;
    FFilterDateFields: TStringList;
    FFilterBoolFields: TStringList;
    FFilterGrid: TStringList;

    FGridPopMenu: TPopupMenu;
    FmniPreview: TMenuItem;
    FmniDuplicate: TMenuItem;
    FmniFilter: TMenuItem;
    FmniFilterExclude: TMenuItem;
    FmniFilterBack: TMenuItem;
    FmniFilterRemove: TMenuItem;
    FmniExportExcel: TMenuItem;
    FmniExportCsv: TMenuItem;
    FmniPrint: TMenuItem;
    FmniRemoveGridSort: TMenuItem;
    FmniRecordHistory: TMenuItem;

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

    // Sayfalama (sunucu tarafı): hızlı filtre, popup filtre, başlık sıralaması ve alt toplamlar
    // tüm kayıtlar üzerinden SQL ile; ekrana yalnız seçili sayfa (LIMIT / OFFSET) gelir
    FPagingEnabled: Boolean;
    FPagingReady: Boolean;
    FPageReload: Boolean;
    FPageSize: Integer;          // 0 = tümü
    FPageIndex: Integer;         // 0 tabanlı
    FTotalCount: Int64;
    FBaseSql: string;            // ORDER BY olmadan (sabit + dinamik filtreler dahil)
    FBaseOrderBy: string;
    FBaseParams: TFDParams;
    FSortFields: string;         // başlık sıralaması: 'alan:A;alan:D'
    FSearchSql: string;          // hızlı filtre koşulu (FSearchText parametreleriyle)
    FSearchText: string;
    FSearchTimer: TTimer;
    FPanelPaging: TPanel;
    FBtnFirstPage: TButton;
    FBtnPrevPage: TButton;
    FBtnNextPage: TButton;
    FBtnLastPage: TButton;
    FEdtPage: TEdit;
    FLblPageCount: TLabel;
    FLblPageInfo: TLabel;
    FCbbPageSize: TComboBox;

    // Hızlı filtre: taban sorguya AND ile eklenen çalışma anı koşulu (sayfa, sayım, toplamlar, dışa aktarım dahil)
    FQuickSql: string;
    FQuickParams: TArray<Variant>;
    FQuickFilters: TObjectList<TQuickFilter>;
    FQuickFilterIndex: Integer;
    FQuickFilterUpdating: Boolean;
    FPanelQuickFilter: TPanel;

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

    procedure FilterApply;
    procedure PrepareFilteredColumns;
    procedure EdtFilterChange(Sender: TObject);
    procedure EdtFilterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PrepareStatusBar;
    procedure BuildFilterExpression(AOperator: string);

    procedure CreatePanelPaging;
    function NewPagingButton(const ACaption: string; AOnClick: TNotifyEvent; ALeft: Integer): TButton;
    procedure OpenPageData(AQuiet: Boolean);
    procedure CapturePagingBaseSql;
    procedure ApplyPagingParams(AQuery: TFDQuery);
    function PagingFilteredSql: string;
    function PagingOrderBy: string;
    function PageCount: Integer;
    procedure LoadPagingTotals;
    function FindPageOfId(AId: Int64): Integer;
    procedure UpdatePagingControls;
    procedure ApplyPagingLocalization;
    function SaveColumnStates: TArray<TGridColumnState>;
    procedure RestoreColumnStates(const AStates: TArray<TGridColumnState>);
    function BuildSearchSql(const AText: string): string;
    function SqlLiteral(AField: TField): string;
    function CreatePagingQuery(const ASql: string): TFDQuery;
    procedure SearchTimerTimer(Sender: TObject);
    procedure BtnFirstPageClick(Sender: TObject);
    procedure BtnPrevPageClick(Sender: TObject);
    procedure BtnNextPageClick(Sender: TObject);
    procedure BtnLastPageClick(Sender: TObject);
    procedure EdtPageKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CbbPageSizeChange(Sender: TObject);
    function AddWhereCondition(const ASql, ACond: string): string;
    procedure ApplyQuickSqlToQuery;
    procedure LayoutQuickFilters;
    procedure QuickFilterClick(Sender: TObject);
    function GetQuickFilterCount: Integer;
  public
    property Service: TS read FService write FService;
    property Table: TE read FTable write FTable;
    property Grd: THackDBGrid read FGrd write FGrd;
    property Qry: TFDQuery read FQry write FQry;

    //for use HelperForm
    property IsHelper: Boolean read FIsHelper write FIsHelper default False;
    property DataTransfer: Boolean read FDataTransfer write FDataTransfer;
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
    property mniDuplicate: TMenuItem read FmniDuplicate write FmniDuplicate;
    property mniFilter: TMenuItem read FmniFilter write FmniFilter;
    property mniFilterExclude: TMenuItem read FmniFilterExclude write FmniFilterExclude;
    property mniFilterBack: TMenuItem read FmniFilterBack write FmniFilterBack;
    property mniFilterRemove: TMenuItem read FmniFilterRemove write FmniFilterRemove;
    property mniExportExcel: TMenuItem read FmniExportExcel write FmniExportExcel;
    property mniExportCsv: TMenuItem read FmniExportCsv write FmniExportCsv;
    property mniPrint: TMenuItem read FmniPrint write FmniPrint;
    property mniRemoveGridSort: TMenuItem read FmniRemoveGridSort write FmniRemoveGridSort;
    property mniRecordHistory: TMenuItem read FmniRecordHistory write FmniRecordHistory;

    // False (FormShow öncesi): eski davranış, tüm kayıtlar belleğe alınır, filtre / sıralama istemcide
    property PagingEnabled: Boolean read FPagingEnabled write FPagingEnabled;
    property PageSize: Integer read FPageSize;
    property PageIndex: Integer read FPageIndex;
    property TotalCount: Int64 read FTotalCount;
    function IsPaged: Boolean;
    // Geçerli sayfayı (filtre / sıralama ile) yeniden okur; AFocusId > 0 ise o kaydın sayfasına gidip kayda konumlanır
    procedure LoadPage(AKeepLayout: Boolean; AFocusId: Int64 = 0);
    procedure GoToPage(AIndex: Integer);
    // Ekrandaki ilk kayıt korunarak sayfa boyutu değişir; ASaveSetting: kullanıcı ayarına yazılır
    procedure ChangePageSize(AValue: Integer; ASaveSetting: Boolean = True);
    // Yazılıp henüz uygulanmamış hızlı filtre hemen çalışır
    procedure FlushPendingSearch;

    // Taban sorguya AND ile eklenen koşul (parametreler :qc0, :qc1 …; ASql boş = koşul yok). Sayfa, kayıt sayısı,
    // alt toplamlar, Excel / CSV ve CollectVisibleIds bu koşulla çalışır; FormShow öncesi çağrılırsa ilk açılışta uygulanır
    procedure SetQuickCondition(const ASql: string; const AParams: array of Variant);
    // Başlık çubuğuna radyo düğmesi ekler (FormShow öncesi); ilk eklenen seçili gelir. Sonuç: seçenek no (0 tabanlı)
    function AddQuickFilter(const ACaption, ASql: string; const AParams: array of Variant): Integer;
    procedure SetQuickFilterCaption(AIndex: Integer; const ACaption: string);
    procedure SelectQuickFilter(AIndex: Integer);
    property QuickFilterIndex: Integer read FQuickFilterIndex;
    property QuickFilterCount: Integer read GetQuickFilterCount;

    constructor Create(AOwner: TComponent; AService: TS; ATable: TE; ACreateNewBase: Boolean = True; AUseHelper: Boolean = False); reintroduce; overload;
    destructor Destroy; override;

    procedure SetSelectedItem; virtual;
    procedure FillNotMappedFromDataSet;
    //for use HelperForm
    function getFilterEditData(): string; virtual;
    //for use HelperForm
    procedure ShowInputForm(Sender: TObject; AFormType: TInputFormMode); virtual;

    procedure MoveUp(); virtual;
    procedure MoveDown(); virtual;
    procedure AddFooterColumn(const AColumnFieldName: string; AAggregateType: TAggregateType; const ADisplayFormat: string = '');
    procedure DefineFooterColumns; virtual;
    procedure LoadFooterColumnsFromDB; virtual;
    procedure DefineColumnWidths; virtual;
    procedure SetColumnProperty(const AFieldName: string; AWidth: Integer; AColumnTitle: string = '');
    procedure SetColumnTitle(const AFieldName: string; AColumnTitle: string);
    procedure BuildFooter;
    procedure CreateFooterPanel;
    procedure UpdateFooterLayout;
    procedure PreparePopupMenu(); virtual;

    //***form***
    procedure FormCreate(Sender: TObject); virtual;
    procedure FormDestroy(Sender: TObject); virtual;
    procedure FormShow(Sender: TObject); virtual;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); virtual;
    procedure ApplyLocalization; virtual;
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

    function  GetGridViewName: string; virtual;
    procedure AutoPopulateSysGridColumns(const AViewName: string); virtual;
    procedure AutoPopulateSysGridFilter(const AViewName: string); virtual;
    procedure AutoPopulateSysGridSort(const AViewName: string); virtual;
    procedure ApplyDynamicFilterAndSort; virtual;
    procedure LoadColumnWidthsFromDB; virtual;
    procedure SaveColumnWidthsToDB; virtual;
    procedure AdjustFormWidth; virtual;

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
    procedure mniDuplicateClick(Sender: TObject); virtual;
    procedure mniFilterClick(Sender: TObject); virtual;
    procedure mniFilterExcludeClick(Sender: TObject); virtual;
    procedure mniFilterBackClick(Sender: TObject); virtual;
    procedure mniFilterRemoveClick(Sender: TObject); virtual;
    function CollectVisibleIds: TArray<Int64>; virtual;
    procedure mniExportExcelClick(Sender: TObject); virtual;
    procedure mniExportCsvClick(Sender: TObject); virtual;
    procedure mniPrintClick(Sender: TObject); virtual;
    procedure mniRemoveSortClick(Sender: TObject); virtual;
    procedure mniRecordHistoryClick(Sender: TObject); virtual;
    function GridTableName: string;

    procedure mniColumnsClick(Sender: TObject); virtual;

    //***footer button events***
    procedure BtnSpinDownClick(Sender: TObject); virtual;
    procedure BtnSpinUpClick(Sender: TObject); virtual;
    procedure BtnCloseClick(Sender: TObject); virtual;
    procedure BtnAddClick(Sender: TObject); virtual;
    // Yetkisi olmayan işlemler UI'da baştan pasif; backend (Business*) yine kontrol eder
    procedure ApplyPermissionState; virtual;

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; virtual;

    procedure RefreshParentGrid(AFocusSelectedItem: Boolean);

    /// <summary>
    /// Grid sorgusuna kalıcı eşitlik filtresi ekler (ör. seçili şablonun hakları).
    /// Form gösterilmeden (FormShow / Open öncesi) çağrılmalıdır.
    /// </summary>
    procedure AddFixedFilter(const AFieldName: string; const AValue: Variant);
  end;

  TfrmColumnSelector = class(TForm)
  private
    FEditSearch: TEdit;
    FCheckListBox: TCheckListBox;
    FColumns: TList<TColumn>;
    FCheckedStates: TDictionary<TColumn, Boolean>;
    procedure EditSearchChange(Sender: TObject);
    procedure CheckListBoxClickCheck(Sender: TObject);
    procedure RebuildList;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  public
    constructor Create(AOwner: TComponent; AColumns: TList<TColumn>); reintroduce;
    destructor Destroy; override;
    function GetCheckedState(AColumn: TColumn): Boolean;
  end;

  function UpperCaseTr(S: string): string;
  function LowerCaseTr(S: string): string;
  function CsvSafe(const S: string): string;
  // Liste sayfa boyutu kullanıcı başına tek ayar (sys_user_setting 'grid.page_size'; 0 = tümü)
  function GridPageSize: Integer;
  procedure SetGridPageSize(AValue: Integer);
  function LikeEscape(const S: string): string;

const
  GRID_PAGE_SIZES: array[0..5] of Integer = (50, 100, 250, 500, 1000, 0);
  GRID_DEFAULT_PAGE_SIZE = 100;
  GRID_PAGE_SIZE_KEY = 'grid.page_size';

var
  GRecordHistoryAvailable: TRecordHistoryAvailable = nil;
  GRecordHistoryShow: TRecordHistoryShow = nil;
  GGridPageSize: Integer = -1;   // -1: henüz okunmadı

implementation
 
uses Winapi.ShellAPI, System.Threading, ufrmInputSimpleDB, Logger,
  SysGridColumn, SysGridColumn.Repository,
  SysGridFilter, SysGridFilter.Repository,
  SysGridSort, SysGridSort.Repository,
  EntitySchemaCache, ExcelExportTask, ufrmExportProgress, SysUserSetting.Service;

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
var
  i: Integer;
begin
  if FFooterColumns = nil then
    FFooterColumns := TObjectList<TFooterColumn>.Create(True);

  for i := FFooterColumns.Count - 1 downto 0 do
  begin
    if SameText(FFooterColumns[i].ColumnFieldName, AColumnFieldName) then
    begin
      FFooterColumns.Delete(i);
      Break;
    end;
  end;

  FFooterColumns.Add(TFooterColumn.Create(AColumnFieldName, AAggregateType, ADisplayFormat));
end;

function GridPageSize: Integer;
var
  LService: TSysUserSettingService;
  LValues: TDictionary<string, string>;
  LText: string;
  LValue, i: Integer;
begin
  if GGridPageSize < 0 then
  begin
    GGridPageSize := GRID_DEFAULT_PAGE_SIZE;
    try
      LService := TSysUserSettingService.Create;
      try
        LValues := LService.GetValues(GRID_PAGE_SIZE_KEY);
        try
          if LValues.TryGetValue(GRID_PAGE_SIZE_KEY, LText) and TryStrToInt(LText, LValue) then
            for i := Low(GRID_PAGE_SIZES) to High(GRID_PAGE_SIZES) do
              if GRID_PAGE_SIZES[i] = LValue then
                GGridPageSize := LValue;
        finally
          LValues.Free;
        end;
      finally
        LService.Free;
      end;
    except
      on E: Exception do
        GLogger.WarningFmt('Sayfa boyutu okunamadı: %s', [E.Message]);
    end;
  end;
  Result := GGridPageSize;
end;

procedure SetGridPageSize(AValue: Integer);
var
  LService: TSysUserSettingService;
begin
  if AValue = GGridPageSize then
    Exit;
  GGridPageSize := AValue;
  try
    LService := TSysUserSettingService.Create;
    try
      LService.SetValue(GRID_PAGE_SIZE_KEY, IntToStr(AValue));
    finally
      LService.Free;
    end;
  except
    on E: Exception do
      GLogger.WarningFmt('Sayfa boyutu kaydedilemedi: %s', [E.Message]);
  end;
end;

// LIKE desenindeki joker karakterler (\ % _) kullanıcı metninde düz karakter sayılır
function LikeEscape(const S: string): string;
begin
  Result := StringReplace(S, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '%', '\%', [rfReplaceAll]);
  Result := StringReplace(Result, '_', '\_', [rfReplaceAll]);
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
var
  I: Integer;
  LCol: TColumn;
begin
  // Sayfa değişimi: kolon düzeni LoadPage içinde kullanıcının o anki hâline geri yüklenir
  if FPageReload then
    Exit;

  Grd.Columns.RestoreDefaults;

  for I := 0 to Grd.Columns.Count-1 do
  begin
    LCol := Grd.Columns.Items[I];

    LCol.Title.Font.Style := [fsBold];
    LCol.Title.Alignment := TAlignment.taCenter;
  end;

  DefineColumnWidths;         // subclass'ın kod tanımlı genişlikleri
  LoadColumnWidthsFromDB;     // DB'deki kayıtlı genişlikler (önceliklidir)
  AdjustFormWidth;
  RefreshStatusRecordCount;
end;

procedure TfrmGrid<TE, TS>.BtnCloseClick(Sender: TObject);
begin
  if FIsHelper then
  begin
    FDataTransfer := True;
    FCleanAndClose := True;
    if Owner is TEdit then
      TEdit(Owner).Clear;
  end;
  Self.Close;
end;

procedure TfrmGrid<TE, TS>.ApplyPermissionState;
var
  LCanAdd: Boolean;
begin
  try
    LCanAdd := Service.IsAuthorized(ptAddRecord, True);
  except
    on E: Exception do
    begin
      // Yetki okunamazsa UI kısıtlanmaz; kayıt sırasında backend yine kontrol eder
      GLogger.ErrorFmt('Yetki durumu okunamadı [%s]: %s', [Self.ClassName, E.Message]);
      LCanAdd := True;
    end;
  end;

  if Assigned(BtnAdd) then
    BtnAdd.Enabled := LCanAdd;
  if Assigned(mniDuplicate) then
    mniDuplicate.Enabled := LCanAdd;
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
  if (Grd.SelectedField <> nil) and (not Grd.SelectedField.IsNull) and IsPaged then
  begin
    // Sayfalı mod: koşul SQL'e gider (tarih ISO, ondalık nokta, tırnaklı kolon adı)
    LFilterVal := SqlLiteral(Grd.SelectedField);
    if LFilterVal = '' then
      Exit;
    // zaman damgası DB'de mikro saniyeli, ekrandaki değer saniyeli: saniyeye yuvarlanarak karşılaştırılır
    if Grd.SelectedField.DataType in [ftDateTime, ftTimeStamp, ftOraTimeStamp] then
      FFilterGrid.Add(LFilterBefore + 'date_trunc(''second'', ' + AnsiQuotedStr(Grd.SelectedField.FieldName, '"') + ')' + AOperator + LFilterVal)
    else
      FFilterGrid.Add(LFilterBefore + AnsiQuotedStr(Grd.SelectedField.FieldName, '"') + AOperator + LFilterVal);
  end
  else if (Grd.SelectedField <> nil) and (not Grd.SelectedField.IsNull) then
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
  if Assigned(FFooterPanel) then
  begin
    while FFooterPanel.ControlCount > 0 do
      FFooterPanel.Controls[0].Free;
  end;

  if (FFooterColumns = nil) or (FFooterColumns.Count = 0) then
  begin
    if Assigned(FFooterPanel) then
      FFooterPanel.Visible := False;
    Exit;
  end;

  if FQry.Active then
    raise Exception.Create('BuildFooter: Query must be closed before creating aggregate fields');

  FQry.Aggregates.Clear;

  for FooterCol in FFooterColumns do
  begin
    // Sayfalı modda toplamlar sayfanın değil tüm kayıtların: LoadPagingTotals SQL ile hesaplar
    if not FPagingEnabled then
    begin
      AggregateFuncName := AggregateTypeToSqlFunc(FooterCol.AggregateType);

      FooterCol.AggregateField := FQry.Aggregates.Add;
      FooterCol.AggregateField.Name := Format('AGG_%s_%s', [AggregateFuncName, FooterCol.ColumnFieldName]);
      FooterCol.AggregateField.Expression := Format('%s(%s)', [AggregateFuncName, FooterCol.ColumnFieldName]);
      FooterCol.AggregateField.Active := True;
    end;
    FooterCol.ServerValue := Null;

    FooterCol.DisplayControl := TLabel.Create(FFooterPanel);
    FooterCol.DisplayControl.Parent := FFooterPanel;
    FooterCol.DisplayControl.Font.Style := [fsBold];
    FooterCol.DisplayControl.Font.Size := 8;
    FooterCol.DisplayControl.Font.Color := clBlack;
    FooterCol.DisplayControl.AutoSize := True;
    FooterCol.DisplayControl.Caption := '';
  end;

  FFooterPanel.Visible := True;
  FQry.AggregatesActive := not FPagingEnabled;
end;

procedure TfrmGrid<TE, TS>.LoadFooterColumnsFromDB;
var
  LViewName: string;
  LSysRepo : ISysGridColumnRepository;
  LColumns : TList<TSysGridColumn>;
  LCol     : TSysGridColumn;
  LAggType : TAggregateType;
  LFormat  : string;
begin
  // Kodda (DefineFooterColumns) tanımlananlar korunur; aynı kolon DB'de de varsa AddFooterColumn DB'dekini alır
  if FFooterColumns = nil then
    FFooterColumns := TObjectList<TFooterColumn>.Create(True);

  LViewName := GetGridViewName;
  if LViewName = '' then Exit;
  if not Assigned(Service) or not Assigned(Service.UoW) or (Service.UoW.Connection = nil) or not Service.UoW.Connection.Connected then Exit;

  try
    LSysRepo := Service.UoW.GetRepository<TSysGridColumn, TSysGridColumnRepository> as ISysGridColumnRepository;
    if LSysRepo = nil then Exit;

    LColumns := LSysRepo.LoadColumns(LViewName);
    try
      for LCol in LColumns do
      begin
        if IntToAggregateType(LCol.AggregateType, LAggType) then
        begin
          LFormat := LCol.DataFormat;
          if LFormat = '' then
            LFormat := AggregateTypeToDefaultFormat(LAggType);
          AddFooterColumn(LCol.ColumnName, LAggType, LFormat);
        end;
      end;
    finally
      LColumns.Free;
    end;
  except
    on E: Exception do
      GLogger.WarningFmt('LoadFooterColumnsFromDB hatası [%s]: %s', [LViewName, E.Message]);
  end;
end;

constructor TfrmGrid<TE, TS>.Create(AOwner: TComponent; AService: TS; ATable: TE; ACreateNewBase, AUseHelper: Boolean);
begin
  if ACreateNewBase then
    CreateNew(AOwner);

  GLogger.InfoFmt('Open Grid Form %s: %s %s', [IfThen(AUseHelper, 'with Helper Mode', ''), Self.ClassName, ATable.ClassName]);

  FService := AService;
  FTable := ATable;

  FIsHelper := AUseHelper;

  Self.Caption := 'Base Title';
  Self.Constraints.MinHeight := 600;

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

  FPagingEnabled := True;
  FPageSize := GridPageSize;
  FPageIndex := 0;
  FSearchTimer := TTimer.Create(Self);
  FSearchTimer.Enabled := False;
  FSearchTimer.Interval := 350;   // yazarken her tuşta sorgu atılmasın
  FSearchTimer.OnTimer := SearchTimerTimer;
  FQuickFilters := TObjectList<TQuickFilter>.Create(True);
  FQuickFilterIndex := -1;

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
  EdtFilter.TextHint := TLocalizationManager.Translate(TLangKeys.TGeneral.FilterHint, 'Filter');
  EdtFilter.TabStop := False;
  EdtFilter.OnChange := EdtFilterChange;
  EdtFilter.OnKeyDown := EdtFilterKeyDown;
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
  BtnClose.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.Close, 'Close');
  BtnClose.OnClick := BtnCloseClick;
  BtnClose.Align := alRight;
  BtnClose.Margins.Right := 8;
  BtnClose.AlignWithMargins := True;
end;

procedure TfrmGrid<TE, TS>.CreateButtonAdd;
begin
  BtnAdd := TButton.Create(FPanelButtons);
  BtnAdd.Parent := FPanelButtons;
  BtnAdd.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.AddRecord, 'Add Record');
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
  FreeAndNil(FBaseParams);
  FreeAndNil(FQuickFilters);

  // FIX: DataSource'u önce ayır
  if Assigned(FDataSource) then
    FDataSource.DataSet := nil;

  if Assigned(FQry) then
    FQry.Close;
  FreeAndNil(FQry);

  FreeAndNil(FDataSource);
  FreeAndNil(FService);
  FreeAndNil(FTable);
  inherited;
end;

procedure TfrmGrid<TE, TS>.FilterApply;
begin
  if IsPaged then
  begin
    mniFilterRemove.Enabled := FFilterGrid.Count > 0;
    mniFilterBack.Enabled := mniFilterRemove.Enabled;
    FPageIndex := 0;
    LoadPage(True);
    Exit;
  end;

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
  n1            : Integer;
  LIntValue     : Integer;
  LDoubleValue  : Double;
  LDateTimeValue: TDateTime;
  LFilter       : string;
begin
  // Sayfalı mod: arama SQL ile, yazma durunca (zamanlayıcı) çalışır
  if IsPaged then
  begin
    FSearchTimer.Enabled := False;
    FSearchTimer.Enabled := True;
    Exit;
  end;

  LFilter := '';
  FQry.Filter   := '';
  FQry.Filtered := False;

  if EdtFilter.Text = '' then
  begin
    Self.RefreshStatusRecordCount;
    Exit;
  end;

  if TryStrToInt(EdtFilter.Text, LIntValue) or TryStrToFloat(EdtFilter.Text, LDoubleValue) then
  begin
    for n1 := 0 to FFilterNumericFields.Count - 1 do
    begin
      if LFilter <> '' then
        LFilter := LFilter + ' OR ';
      LFilter := LFilter + FFilterNumericFields[n1] + ' = ' + StringReplace(EdtFilter.Text, ',', '.', [rfReplaceAll]);
    end;
  end;

  if SameText(EdtFilter.Text, 'TRUE') or SameText(EdtFilter.Text, 'FALSE') then
  begin
    for n1 := 0 to FFilterBoolFields.Count - 1 do
    begin
      if LFilter <> '' then
        LFilter := LFilter + ' OR ';
      LFilter := LFilter + FFilterBoolFields[n1] + ' = ' + UpperCase(EdtFilter.Text);
    end;
  end;

  if TryStrToDate(EdtFilter.Text, LDateTimeValue) or TryStrToTime(EdtFilter.Text, LDateTimeValue) or TryStrToDateTime(EdtFilter.Text, LDateTimeValue) then
  begin
    for n1 := 0 to FFilterDateFields.Count - 1 do
    begin
      if LFilter <> '' then
        LFilter := LFilter + ' OR ';
      LFilter := LFilter + FFilterDateFields[n1] + ' = ' + QuotedStr(EdtFilter.Text);
    end;
  end;

  for n1 := 0 to FFilterStringFields.Count - 1 do
  begin
    if LFilter <> '' then
      LFilter := LFilter + ' OR ';
    LFilter := LFilter + FFilterStringFields[n1] + ' LIKE ' + QuotedStr('%' + UpperCaseTr(EdtFilter.Text) + '%') +
                ' OR ' + FFilterStringFields[n1] + ' LIKE ' + QuotedStr('%' + LowerCaseTr(EdtFilter.Text) + '%');
  end;

  if LFilter <> '' then
  begin
    FQry.Filter   := LFilter;
    FQry.Filtered := True;
  end;

  Self.RefreshStatusRecordCount;
end;

procedure TfrmGrid<TE, TS>.EdtFilterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
      begin
        // yazılan ama henüz uygulanmamış arama önce çalışsın (helper doğru satırı seçsin)
        FlushPendingSearch;
        if FIsHelper then
        begin
          SetSelectedItem();
          DataTransfer := True;
          ModalResult := mrYes;
          Self.Close;
        end;
      end;
    VK_UP:
      begin
        Key := 0;
        BtnSpinUpClick(BtnSpin)
      end;
    VK_DOWN:
      begin
        Key := 0;
        BtnSpinDownClick(BtnSpin)
      end;
    VK_PRIOR, VK_NEXT:
      begin
        SendMessage(Grd.Handle, WM_KEYDOWN, Key, MapVirtualKey(Key, MAPVK_VK_TO_VSC) shl 16 or 1);
        Key := 0;
      end;
  end;
end;

procedure TfrmGrid<TE, TS>.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  GLogger.InfoFmt('Close Grid Form %s: %s %s', [IfThen(FIsHelper, 'with Helper Mode', ''), Self.ClassName, Table.ClassName]);
  if not FIsHelper then
    SaveColumnWidthsToDB;
  Action := caFree;
end;

procedure TfrmGrid<TE, TS>.ApplyLocalization;
begin
  inherited;
  if Assigned(EdtFilter) then
    EdtFilter.TextHint := TLocalizationManager.Translate(TLangKeys.TGeneral.FilterHint, 'Filter');

  if Assigned(BtnClose) then
    BtnClose.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.Close, 'Close');

  if Assigned(BtnAdd) then
    BtnAdd.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.AddRecord, 'Add Record');

  if Assigned(mniPreview) then
    mniPreview.Caption := TLocalizationManager.Translate(TLangKeys.TPopupMenu.Preview, 'Preview');
  if Assigned(mniDuplicate) then
    mniDuplicate.Caption := TLocalizationManager.Translate(TLangKeys.TPopupMenu.Duplicate, 'Duplicate');
  if Assigned(mniFilter) then
    mniFilter.Caption := TLocalizationManager.Translate(TLangKeys.TPopupMenu.Filter, 'Filter');
  if Assigned(mniFilterExclude) then
    mniFilterExclude.Caption := TLocalizationManager.Translate(TLangKeys.TPopupMenu.FilterExclude, 'Filter Exclude');
  if Assigned(mniFilterBack) then
    mniFilterBack.Caption := TLocalizationManager.Translate(TLangKeys.TPopupMenu.FilterBack, 'Filter Back');
  if Assigned(mniFilterRemove) then
    mniFilterRemove.Caption := TLocalizationManager.Translate(TLangKeys.TPopupMenu.FilterRemove, 'Remove Filter');
  if Assigned(mniExportExcel) then
    mniExportExcel.Caption := TLocalizationManager.Translate(TLangKeys.TPopupMenu.ExportExcel, 'Export to Excel');
  if Assigned(mniExportCsv) then
    mniExportCsv.Caption := TLocalizationManager.Translate(TLangKeys.TPopupMenu.ExportCsv, 'Export to CSV');
  if Assigned(mniPrint) then
    mniPrint.Caption := TLocalizationManager.Translate(TLangKeys.TPopupMenu.Print, 'Print');
  if Assigned(mniRemoveGridSort) then
    mniRemoveGridSort.Caption := TLocalizationManager.Translate(TLangKeys.TPopupMenu.RemoveSort, 'Remove Sort');
  if Assigned(mniRecordHistory) then
    mniRecordHistory.Caption := TLocalizationManager.Translate(TLangKeys.TSysAuditLog.MenuRecordHistory, 'Audit Log');

  ApplyPagingLocalization;
  PrepareStatusBar;
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
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    Self.Close;
  end
  else if Key = VK_F6 then
  begin
    Key := 0;
    Self.Close;
  end
  else if Key = VK_F7 then
  begin
    Key := 0;
    BtnAddClick(BtnAdd);
  end
  else if Key = VK_F11 then
  begin
    Key := 0;
    case Self.AlphaBlendValue of
      255:
        begin
          Self.AlphaBlend := True;
          Self.AlphaBlendValue := 150;
        end;
      150:
        begin
          Self.AlphaBlendValue := 80;
        end;
      80:
        begin
          Self.AlphaBlend := False;
          Self.AlphaBlendValue := 255;
        end
    else
      Self.AlphaBlend := False;
      Self.AlphaBlendValue := 255;
    end;
  end
  else if IsPaged and (Shift = [ssCtrl]) and (Key = VK_NEXT) then
  begin
    Key := 0;
    BtnNextPageClick(nil);
  end
  else if IsPaged and (Shift = [ssCtrl]) and (Key = VK_PRIOR) then
  begin
    Key := 0;
    BtnPrevPageClick(nil);
  end
  else if (ssCtrl in Shift) and (Key = Ord('F')) then
  begin
    Key := 0;
    if EdtFilter.Focused then
    begin
      ActiveControl := Grd;
    end
    else
    begin
      ActiveControl := EdtFilter;
    end;
  end;
end;

procedure TfrmGrid<TE, TS>.FormKeyPress(Sender: TObject; var Key: Char);
begin
//
end;

procedure TfrmGrid<TE, TS>.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//
end;

procedure TfrmGrid<TE, TS>.FormShow(Sender: TObject);
var
  LCanRead: Boolean;
begin
  // Okuma yetkisi yoksa sorgu hiç açılmaz, ekran kapanır (menü, popup, helper — hangi yoldan açılırsa)
  try
    LCanRead := Service.IsAuthorized(ptRead, True);
  except
    on E: Exception do
    begin
      GLogger.ErrorFmt('Okuma yetkisi okunamadı [%s]: %s', [Self.ClassName, E.Message]);
      LCanRead := False;
    end;
  end;
  if not LCanRead then
  begin
    ShowMessage(TLocalizationManager.Translate(TLangKeys.TSysAccessRight.MsgNoAccessRightToRead, 'You do not have permission to read the records!'));
    PostMessage(Self.Handle, WM_CLOSE, 0, 0);
    Exit;
  end;

  LoadFooterColumnsFromDB;
  BuildFooter;

  // FIX: Tek Open çağrısı, korumalı
  if Assigned(FQry) and not FQry.Active then
  begin
    ApplyDynamicFilterAndSort;
    try
      if FPagingEnabled then
      begin
        CapturePagingBaseSql;
        LoadPage(False);
      end
      else
      begin
        // istemci tarafı: gövde yine saklanır, hızlı filtre koşulu bu gövdeye eklenerek sorgu yeniden açılır
        CapturePagingBaseSql;
        if FQuickSql <> '' then
          ApplyQuickSqlToQuery;
        FQry.Open;
      end;
    except
      on E: Exception do
      begin
        GLogger.ErrorFmt('Grid sorgusu açılamadı [%s]: %s', [Self.ClassName, E.Message]);
        ShowMessage(TLocalizationManager.Translate(TLangKeys.TMessage.DataIsNotLoaded, 'Data could not be loaded: ') + E.Message);
        Exit;
      end;
    end;
  end;

  AdjustFormWidth;
  PrepareFilteredColumns;
  FPanelPaging.Visible := IsPaged;
  UpdatePagingControls;
  PanelSidebar.Visible := False;
  PrepareStatusBar;
  ApplyPermissionState;

  if Assigned(mniRecordHistory) then
  try
    mniRecordHistory.Visible := not FIsHelper and Assigned(GRecordHistoryAvailable) and GRecordHistoryAvailable(GridTableName);
  except
    on E: Exception do
    begin
      mniRecordHistory.Visible := False;
      GLogger.WarningFmt('İşlem geçmişi menüsü [%s]: %s', [Self.ClassName, E.Message]);
    end;
  end;

  if FIsHelper then
    EdtFilter.SetFocus
  else
    Self.ActiveControl := Grd;
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
  UpdateFooterLayout;
end;

procedure TfrmGrid<TE, TS>.grdDblClick(Sender: TObject);
begin
  if FIsHelper then
  begin
    SetSelectedItem;
    DataTransfer := True;
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
//  nValue, nWidth1, nLeft2: Integer;
//  clActualPenColor, clActualBrushColor: TColor;
//  bEmptyDS: Boolean;
//  DrawRect: TRect;
//  sValue: string;

  Bmp: TBitmap;

  LColorActive: TColor;
  LColor1: TColor;
  LColor2: TColor;
begin
  LColorActive := 9539955;
  LColor1 := 12189695;
  LColor2 := 13158655;

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
      if (Key = Ord('C')) then
      begin
        Clipboard.Clear;
        Clipboard.SetTextBuf(PWideChar(Grd.DataSource.DataSet.Fields.Fields[0].AsString + sLineBreak));
      end;
    end
    else if Shift = [ssCtrl] then
    begin
      if (Key = VK_DELETE) then
      begin
        Key := 0;
      end
      else if (Key = Ord('C')) then
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

    if Assigned(FooterCol) and Assigned(FooterCol.DisplayControl) then
    begin
      if GridCol.Visible then
      begin
        FooterCol.DisplayControl.Visible := True;
        FooterCol.DisplayControl.Left := CurrentLeft;
        FooterCol.DisplayControl.Width := GridCol.Width;
        FooterCol.DisplayControl.Height := 20;
        FooterCol.DisplayControl.Top := 5;

        if FPagingEnabled or not Assigned(FooterCol.AggregateField) then
          Value := FooterCol.ServerValue
        else
          Value := FooterCol.AggregateField.Value;
        if not VarIsNull(Value) then
        begin
          if FooterCol.DisplayFormat <> '' then
            FormatText := FooterCol.DisplayFormat
          else if FooterCol.AggregateType = atCount then
            FormatText := '#,##0'
          else
            FormatText := '#,##0.00';

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
                FooterCol.DisplayControl.Caption := FormatFloat(FormatText, Value);
              end;

            ftDate,
            ftTime,
            ftDateTime,
            ftTimeStamp:
              begin
                if FooterCol.DisplayFormat <> '' then
                  FooterCol.DisplayControl.Caption := FormatDateTime(FooterCol.DisplayFormat, Value)
                else
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

function TfrmGrid<TE, TS>.CollectVisibleIds: TArray<Int64>;
var
  Bkm: TBookmark;
  IdList: TList<Int64>;
  LQ: TFDQuery;
begin
  IdList := TList<Int64>.Create;
  try
    // Sayfalı mod: yalnız ekrandaki sayfa değil, filtreye uyan tüm kayıtlar
    if IsPaged then
    begin
      LQ := CreatePagingQuery('SELECT pg_x.id FROM (' + PagingFilteredSql + ') pg_x');
      try
        LQ.Open;
        while not LQ.Eof do
        begin
          IdList.Add(LQ.Fields[0].AsLargeInt);
          LQ.Next;
        end;
      finally
        LQ.Free;
      end;
    end
    else if Assigned(FQry) and FQry.Active then
    begin
      FQry.DisableControls;
      try
        Bkm := FQry.GetBookmark;
        try
          FQry.First;
          while not FQry.Eof do
          begin
            if FQry.FindField('id') <> nil then
              IdList.Add(FQry.FieldByName('id').AsLargeInt);
            FQry.Next;
          end;
        finally
          if FQry.BookmarkValid(Bkm) then
            FQry.GotoBookmark(Bkm);
          FQry.FreeBookmark(Bkm);
        end;
      finally
        FQry.EnableControls;
      end;
    end;
    Result := IdList.ToArray;
  finally
    IdList.Free;
  end;
end;

procedure TfrmGrid<TE, TS>.mniExportExcelClick(Sender: TObject);
var
  SavePath: string;
  VisibleIds: TArray<Int64>;
  Strategy: TExportStrategy;
  ExportTask: TExcelExportTask;
  ProgForm: TfrmExportProgress;
  ColList: TList<TExportColumnInfo>;
  ColInfo: TExportColumnInfo;
  ParamArray: TList<TExportParamInfo>;
  ParamInfo: TExportParamInfo;
  i: Integer;
  TableName: string;
  WhereClause: string;
begin
  if not Assigned(FQry) or not FQry.Active then
  begin
    ShowMessage(TLocalizationManager.Translate('msg.no_data_to_export', 'No data found to export.'));
    Exit;
  end;

  SavePath := GetDialogSave(GetGridViewName + '.xlsx', TLocalizationManager.Translate('dialog.excel_filter', 'Excel Files (*.xlsx)|*.xlsx'));
  if SavePath = '' then Exit;

  VisibleIds := CollectVisibleIds;
  if Length(VisibleIds) = 0 then
  begin
    ShowMessage(TLocalizationManager.Translate('msg.no_records_displayed', 'No displayed records found.'));
    Exit;
  end;

  if Length(VisibleIds) <= 5000 then
    Strategy := esSmall
  else if Length(VisibleIds) <= 100000 then
    Strategy := esMedium
  else
    Strategy := esLarge;

  ColList := TList<TExportColumnInfo>.Create;
  try
    for i := 0 to Grd.Columns.Count - 1 do
    begin
      if Grd.Columns[i].Visible and Assigned(Grd.Columns[i].Field) then
      begin
        ColInfo.FieldName := Grd.Columns[i].FieldName;
        ColInfo.Caption := Grd.Columns[i].Title.Caption;
        ColList.Add(ColInfo);
      end;
    end;

    ParamArray := TList<TExportParamInfo>.Create;
    try
      for i := 0 to FQry.Params.Count - 1 do
      begin
        ParamInfo.Name := FQry.Params[i].Name;
        ParamInfo.Value := FQry.Params[i].Value;
        ParamArray.Add(ParamInfo);
      end;

      TableName := GetGridViewName;
      if TableName = '' then
        TableName := 'vw_' + TEntitySchemaCache.GetSchema(TE).TableName;

      WhereClause := '';
      if IsPaged then
      begin
        // LIMIT / OFFSET olmadan filtreli sorgunun koşulu
        var LFullSql := PagingFilteredSql;
        if Pos('WHERE', UpperCase(LFullSql)) > 0 then
          WhereClause := LFullSql.Substring(Pos('WHERE', UpperCase(LFullSql)) - 1);
      end
      else if Pos('WHERE', UpperCase(FQry.SQL.Text)) > 0 then
        WhereClause := FQry.SQL.Text.Substring(Pos('WHERE', UpperCase(FQry.SQL.Text)) - 1);

      ExportTask := TExcelExportTask.Create(
        FService.UoW.Connection.Params,
        VisibleIds,
        Strategy,
        TableName,
        WhereClause,
        ParamArray.ToArray,
        ColList.ToArray,
        SavePath
      );
    finally
      ParamArray.Free;
    end;
  finally
    ColList.Free;
  end;

  ProgForm := TfrmExportProgress.Create(Self);
  ProgForm.Show;

  ExportTask.OnProgress := procedure(ACurrent, ATotal: Integer; const AStatus: string)
  begin
    if Assigned(ProgForm) then
      ProgForm.UpdateProgress(ACurrent, ATotal, AStatus);
  end;

  ExportTask.OnComplete := procedure(ASuccess: Boolean; const AErrorMsg: string)
  begin
    if Assigned(ProgForm) then
      ProgForm.Close;

    if ASuccess then
    begin
      if FileExists(SavePath) then
        ShellExecute(0, 'open', PChar(SavePath), nil, nil, SW_SHOWNORMAL);
    end
    else if AErrorMsg <> '' then
      ShowMessage(TLocalizationManager.Translate('msg.export_error', 'Export Error: ') + AErrorMsg);

    FreeAndNil(ExportTask);
  end;

  ProgForm.OnCancel := procedure
  begin
    if Assigned(ExportTask) then
      ExportTask.Cancel;
  end;

  var RunTaskProc: TProc := procedure
  begin
    ExportTask.Execute;
  end;
  TTask.Run(RunTaskProc);
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
  LData: TDataSet;
  LFull: TFDQuery;
  LField: TField;
begin
  // Sayfalı mod: filtreye uyan tüm kayıtlar ayrı sorguyla okunur
  LFull := nil;
  if IsPaged then
  begin
    LFull := CreatePagingQuery(PagingFilteredSql + ' ORDER BY ' + PagingOrderBy);
    LFull.Open;
    LData := LFull;
  end
  else
    LData := Grd.DataSource.DataSet;

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

    LData.DisableControls;
    try
      LData.First;
      while not LData.Eof do
      begin
        Line := '';
        for j := 0 to Grd.Columns.Count - 1 do
        begin
          LField := LData.FindField(Grd.Columns[j].FieldName);
          if Assigned(LField) then
            Line := Line + CsvSafe(LField.AsString);
          if j < Grd.Columns.Count - 1 then
            Line := Line + ',';
        end;
        SL.Add(Line);

        LData.Next;
      end;
    finally
      LData.EnableControls;
    end;

    SL.SaveToFile('export.csv', TEncoding.UTF8);
    ShowMessage(TLocalizationManager.Translate('msg.csv_export_completed', 'CSV export completed!'));
  finally
    SL.Free;
    LFull.Free;
  end;
end;

procedure TfrmGrid<TE, TS>.mniPreviewClick(Sender: TObject);
begin
  if mniPreview.Visible then
  begin
    if (Grd.DataSource.DataSet.RecordCount > 0) then
    begin
      SetSelectedItem();
      if FIsHelper then
      begin
        DataTransfer := True;
        ModalResult := mrYes;
        Self.Close;
      end
      else
        ShowInputForm(mniPreview, ifmRewiev);
    end;
  end;
end;

procedure TfrmGrid<TE, TS>.mniDuplicateClick(Sender: TObject);
begin
  if mniDuplicate.Visible then
  begin
    if (Grd.DataSource.DataSet.RecordCount > 0) then
    begin
      SetSelectedItem();
      ShowInputForm(mniDuplicate, ifmCopyNewRecord);
    end;
  end;
end;

procedure TfrmGrid<TE, TS>.mniPrintClick(Sender: TObject);
begin
  ShowMessage('not implemented yet!' + sLineBreak + 'Print');
end;

procedure TfrmGrid<TE, TS>.mniRemoveSortClick(Sender: TObject);
begin
  if IsPaged then
  begin
    if FSortFields <> '' then
    begin
      FSortFields := '';
      FPageIndex := 0;
      LoadPage(True);
    end;
    mniRemoveGridSort.Enabled := False;
    THackDBGrid(Grd).InvalidateTitles;
    Exit;
  end;

  if Qry.IndexFieldNames <> '' then
    Qry.IndexFieldNames := '';
  mniRemoveGridSort.Enabled := False;
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
  n1  : Integer;
  Col : TColumn;
  Fld : TField;
begin
  FFilterStringFields.Clear;
  FFilterNumericFields.Clear;
  FFilterDateFields.Clear;
  FFilterBoolFields.Clear;

  for n1 := 0 to Grd.Columns.Count - 1 do
  begin
    Col := Grd.Columns[n1];

    if Col.FieldName = 'id' then
      Continue;

    Fld := Col.Field;
    if not Assigned(Fld) then
      Continue;

    case Fld.DataType of
      ftString, ftWideString, ftMemo, ftWideMemo:
        FFilterStringFields.Add(Col.FieldName);

      ftWord, ftLongWord, ftByte, ftShortint, ftSmallint,
      ftInteger, ftLargeint, ftFloat, ftCurrency, ftBCD, ftSingle:
        FFilterNumericFields.Add(Col.FieldName);

      ftBoolean:
        FFilterBoolFields.Add(Col.FieldName);

      ftDate, ftTime, ftDateTime:
        FFilterDateFields.Add(Col.FieldName);
    end;
  end;
end;

procedure TfrmGrid<TE, TS>.PrepareForm;
begin
  Self.Position := poOwnerFormCenter;
  Self.KeyPreview := True;
  Self.Constraints.MinWidth := 720;
  Self.Constraints.MaxWidth := Monitor.Width;
  Self.Constraints.MinHeight := 600;
  Self.Constraints.MaxHeight := Monitor.Height;
  Self.Height := 600;

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
    CreatePanelPaging;
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
  mniPreview := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.Preview, 'Preview'), 'mniPreview', mniPreviewClick, True, TextToShortCut('Ctrl+Enter'));
  mniDuplicate := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.Duplicate, 'Duplicate'), 'mniDuplicate', mniDuplicateClick, False, TextToShortCut('Ctrl+D'));
  AddPopupMenuSpliter();
  mniFilter := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.Filter, 'Filter'), 'mniFilter', mniFilterClick, True, TextToShortCut('F3'));
  mniFilterExclude := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.FilterExclude, 'Filter Exclude'), 'mniFilterExclude', mniFilterExcludeClick, True, TextToShortCut('Ctrl+F3'));
  mniFilterBack := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.FilterBack, 'Filter Back'), 'mniFilterBack', mniFilterBackClick, True, TextToShortCut('Ctrl+F8'));
  mniFilterBack.Enabled := False;
  mniFilterRemove := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.FilterRemove, 'Remove Filter'), 'mniFilterRemove', mniFilterRemoveClick, True, TextToShortCut('F8'));
  mniFilterRemove.Enabled := False;
  AddPopupMenuSpliter();
  mniExportExcel := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.ExportExcel, 'Export to Excel'), 'mniExportExcel', mniExportExcelClick, True, TextToShortCut('Ctrl+E'));
  mniExportCsv := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.ExportCsv, 'Export to CSV'), 'mniExportCsv', mniExportCsvClick, True, TextToShortCut('Ctrl+Shift+E'));
  mniPrint := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.Print, 'Print'), 'mniPrint', mniPrintClick, True, TextToShortCut('Ctrl+P'));
  mniRemoveGridSort := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.RemoveSort, 'Remove Sort'), 'mniRemoveGridSort', mniRemoveSortClick);
  mniRemoveGridSort.Enabled := False;
  AddPopupMenuSpliter();
  AddMenu(TLocalizationManager.Translate('popup.columns', 'Columns'), 'mniColumns', mniColumnsClick);
  // Görünürlüğü FormShow'da: tablo işlem geçmişi tutuyorsa ve okuma yetkisi varsa
  mniRecordHistory := AddMenu(TLocalizationManager.Translate(TLangKeys.TSysAuditLog.MenuRecordHistory, 'Audit Log'),
    'mniRecordHistory', mniRecordHistoryClick, False, TextToShortCut('Ctrl+H'));
end;

function TfrmGrid<TE, TS>.GridTableName: string;
begin
  Result := '';
  if Assigned(Table) then
    Result := TEntitySchemaCache.GetSchema(Table.ClassType).TableName;
end;

procedure TfrmGrid<TE, TS>.mniRecordHistoryClick(Sender: TObject);
var
  LRowId: Int64;
begin
  if not Assigned(GRecordHistoryShow) or not Assigned(FQry) or not FQry.Active or FQry.IsEmpty
  or (FQry.FindField('id') = nil) then
    Exit;
  LRowId := FQry.FieldByName('id').AsLargeInt;
  GRecordHistoryShow(Self, GridTableName, LRowId, Self.Caption + ' #' + LRowId.ToString);
end;

procedure TfrmGrid<TE, TS>.mniColumnsClick(Sender: TObject);
var
  LColumns: TList<TColumn>;
  i: Integer;
  LSelector: TfrmColumnSelector;
  LCol: TColumn;
begin
  LColumns := TList<TColumn>.Create;
  try
    for i := 0 to Grd.Columns.Count - 1 do
      LColumns.Add(Grd.Columns[i]);

    LSelector := TfrmColumnSelector.Create(Self, LColumns);
    try
      if LSelector.ShowModal = mrOk then
      begin
        for LCol in LColumns do
          LCol.Visible := LSelector.GetCheckedState(LCol);

        AdjustFormWidth;
        SaveColumnWidthsToDB;
      end;
    finally
      LSelector.Free;
    end;
  finally
    LColumns.Free;
  end;
end;

constructor TfrmColumnSelector.Create(AOwner: TComponent; AColumns: TList<TColumn>);
var
  LPanelButtons: TPanel;
  LBtnOk, LBtnCancel: TButton;
  LCol: TColumn;
begin
  inherited CreateNew(AOwner);

  Self.OnKeyPress := FormKeyPress;

  FColumns := AColumns;
  FCheckedStates := TDictionary<TColumn, Boolean>.Create;
  for LCol in FColumns do
    FCheckedStates.Add(LCol, LCol.Visible);

  KeyPreview := True;
  Caption := TLocalizationManager.Translate('column_selector.title', 'Column Selection');
  Position := poOwnerFormCenter;
  Width := 450;
  Height := 500;
  BorderStyle := bsSizeable;

  FEditSearch := TEdit.Create(Self);
  FEditSearch.Parent := Self;
  FEditSearch.Align := alTop;
  FEditSearch.Height := 24;
  FEditSearch.Margins.SetBounds(8, 8, 8, 8);
  FEditSearch.AlignWithMargins := True;
  FEditSearch.TextHint := TLocalizationManager.Translate('column_selector.search_hint', 'Search Column...');
  FEditSearch.OnChange := EditSearchChange;

  LPanelButtons := TPanel.Create(Self);
  LPanelButtons.Parent := Self;
  LPanelButtons.Align := alBottom;
  LPanelButtons.Height := 40;
  LPanelButtons.BevelOuter := bvNone;

  LBtnCancel := TButton.Create(Self);
  LBtnCancel.Parent := LPanelButtons;
  LBtnCancel.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.Cancel, 'Cancel');
  LBtnCancel.ModalResult := mrCancel;
  LBtnCancel.Left := Self.ClientWidth - LBtnCancel.Width - 12;
  LBtnCancel.Top := 8;
  LBtnCancel.Anchors := [akRight, akBottom];

  LBtnOk := TButton.Create(Self);
  LBtnOk.Parent := LPanelButtons;
  LBtnOk.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.OK, 'OK');
  LBtnOk.ModalResult := mrOk;
  LBtnOk.Default := True;
  LBtnOk.Left := LBtnCancel.Left - LBtnOk.Width - 8;
  LBtnOk.Top := 8;
  LBtnOk.Anchors := [akRight, akBottom];

  FCheckListBox := TCheckListBox.Create(Self);
  FCheckListBox.Parent := Self;
  FCheckListBox.Align := alClient;
  FCheckListBox.Margins.SetBounds(8, 0, 8, 0);
  FCheckListBox.AlignWithMargins := True;
  FCheckListBox.OnClickCheck := CheckListBoxClickCheck;

  RebuildList;
end;

destructor TfrmColumnSelector.Destroy;
begin
  FCheckedStates.Free;
  inherited;
end;

procedure TfrmColumnSelector.EditSearchChange(Sender: TObject);
begin
  RebuildList;
end;

procedure TfrmColumnSelector.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Chr(VK_ESCAPE) then
  begin
    Key := #0;
    Self.Close;
  end;
end;

procedure TfrmColumnSelector.CheckListBoxClickCheck(Sender: TObject);
var
  I: Integer;
  LCol: TColumn;
begin
  for I := 0 to FCheckListBox.Items.Count - 1 do
  begin
    LCol := TColumn(FCheckListBox.Items.Objects[I]);
    FCheckedStates[LCol] := FCheckListBox.Checked[I];
  end;
end;

function TfrmColumnSelector.GetCheckedState(AColumn: TColumn): Boolean;
begin
  Result := FCheckedStates[AColumn];
end;

procedure TfrmColumnSelector.RebuildList;
var
  LCol: TColumn;
  LSearchText: string;
  LIndex: Integer;
  LText: string;
begin
  FCheckListBox.Items.BeginUpdate;
  try
    FCheckListBox.Items.Clear;
    LSearchText := Trim(FEditSearch.Text);
    
    for LCol in FColumns do
    begin
      LText := LCol.Title.Caption;
      if LText = '' then
        LText := LCol.FieldName;
        
      if (LSearchText = '') or (Pos(LowerCaseTr(LSearchText), LowerCaseTr(LText)) > 0) then
      begin
        LIndex := FCheckListBox.Items.AddObject(LText, LCol);
        FCheckListBox.Checked[LIndex] := FCheckedStates[LCol];
      end;
    end;
  finally
    FCheckListBox.Items.EndUpdate;
  end;
end;

procedure TfrmGrid<TE, TS>.PrepareStatusBar;
begin
  if FStatusBase.Panels.Count > 0 then
  begin
    if FStatusBase.Panels.Count > DB_STATUS_SQL_SERVER then
      if Service.UoW.Connection.Connected then
        FStatusBase.Panels.Items[DB_STATUS_SQL_SERVER].Text := Service.UoW.Connection.Params.Values['Server'];

    if FStatusBase.Panels.Count > DB_STATUS_PERIOD then
      FStatusBase.Panels.Items[DB_STATUS_PERIOD].Text := TLocalizationManager.Translate(TLangKeys.TGeneral.Period, 'Period') + ':2025';

    if FStatusBase.Panels.Count > DB_STATUS_USER then
      if Assigned(TAppContext.Instance.CurrentUser) then
        FStatusBase.Panels.Items[DB_STATUS_USER].Text := TAppContext.Instance.CurrentUser.GetUsername;

    if FStatusBase.Panels.Count > DB_STATUS_KEY_F6 then
      FStatusBase.Panels.Items[DB_STATUS_KEY_F6].Text := TLocalizationManager.Translate(TLangKeys.TGeneral.KeyF6, 'F6 Cancel / Close');

    if FStatusBase.Panels.Count > DB_STATUS_KEY_F7 then
      FStatusBase.Panels.Items[DB_STATUS_KEY_F7].Text := TLocalizationManager.Translate(TLangKeys.TGeneral.KeyF7, 'F7 Add Record');

    if FStatusBase.Panels.Count > DB_STATUS_KEY_F11 then
      FStatusBase.Panels.Items[DB_STATUS_KEY_F11].Text := TLocalizationManager.Translate(TLangKeys.TGeneral.KeyF11, 'F11 Transparency');

    if Service.UoW.Connection.Connected then
      RefreshStatusRecordCount;

    Exit;
  end;

  StatusBarAddPanel(80, psOwnerDraw); // DB_STATUS_RECORD_COUNT = 0
  StatusBarAddPanel(80, psOwnerDraw); // DB_STATUS_SQL_SERVER   = 1
  StatusBarAddPanel(80, psOwnerDraw); // DB_STATUS_PERIOD       = 2
  StatusBarAddPanel(80, psOwnerDraw); // DB_STATUS_USER         = 3
  StatusBarAddPanel(80, psOwnerDraw); // DB_STATUS_KEY_F6       = 4
  StatusBarAddPanel(80, psOwnerDraw); // DB_STATUS_KEY_F7       = 5
  StatusBarAddPanel(80, psOwnerDraw); // DB_STATUS_KEY_F11      = 6

  if Service.UoW.Connection.Connected then
  begin
    RefreshStatusRecordCount;
    FStatusBase.Panels.Items[DB_STATUS_SQL_SERVER].Text := Service.UoW.Connection.Params.Values['Server'];
  end;

  FStatusBase.Panels.Items[DB_STATUS_PERIOD].Text := TLocalizationManager.Translate(TLangKeys.TGeneral.Period, 'Period') + ':2025';

  if Assigned(TAppContext.Instance.CurrentUser) then
    FStatusBase.Panels.Items[DB_STATUS_USER].Text := TAppContext.Instance.CurrentUser.GetUsername;

  FStatusBase.Panels.Items[DB_STATUS_KEY_F6].Text := TLocalizationManager.Translate(TLangKeys.TGeneral.KeyF6, 'F6 Cancel / Close');
  FStatusBase.Panels.Items[DB_STATUS_KEY_F7].Text := TLocalizationManager.Translate(TLangKeys.TGeneral.KeyF7, 'F7 Add Record');
  FStatusBase.Panels.Items[DB_STATUS_KEY_F11].Text := TLocalizationManager.Translate(TLangKeys.TGeneral.KeyF11, 'F11 Transparency');
end;

procedure TfrmGrid<TE, TS>.RefreshData;
begin
  if not Assigned(FQry) or not FQry.Active then
    Exit;

  // Sayfalı mod: veri yeniden okunur (toplu işlem sonrası da güncel), seçili kayda konumlanır
  if IsPaged then
  begin
    mniFilterRemove.Enabled := FFilterGrid.Count > 0;
    mniFilterBack.Enabled := mniFilterRemove.Enabled;
    if Assigned(FTable) then
      LoadPage(True, FTable.Id)
    else
      LoadPage(True);
    Exit;
  end;

  if Assigned(FTable) and (FTable.Id > 0) then
    FQry.Locate('id', FTable.Id, []);


  if FFilterGrid.Text <> '' then
  begin
    FQry.Filter    := FFilterGrid.Text;
    FQry.Filtered  := True;
    mniFilterRemove.Enabled := True;
    mniFilterBack.Enabled   := True;
  end
  else
  begin
    FQry.Filtered  := False;
    FQry.Filter    := '';
    mniFilterRemove.Enabled := False;
    mniFilterBack.Enabled   := False;
  end;

  RefreshStatusRecordCount;
end;

procedure TfrmGrid<TE, TS>.RefreshDataFirst;
begin
//
end;

procedure TfrmGrid<TE, TS>.RefreshParentGrid(AFocusSelectedItem: Boolean);
begin
  if not Assigned(FQry) then
    Exit;

  // Sayfalı mod: kayıt (yeni eklenen dahil) hangi sayfadaysa oraya gidilir; kolon düzeni korunur
  if IsPaged then
  begin
    if AFocusSelectedItem and Assigned(FTable) then
      LoadPage(True, FTable.Id)
    else
      LoadPage(True);
    ApplyLocalization;
    UpdateFooterLayout;
    Exit;
  end;

  FQry.DisableControls;
  try
    FQry.Close;
    FQry.Open;

    if AFocusSelectedItem and Assigned(FTable) and (FTable.Id > 0) then
      FQry.Locate('id', FTable.Id, []);
  finally
    FQry.EnableControls;
  end;

  // DisableControls içindeki AfterOpen ayarları EnableControls'ta varsayılan kolonlarla eziliyor:
  // kolon genişlik/başlıkları yeniden uygulanır
  AfterDatasetOpen(FQry);
  ApplyLocalization;

  UpdateFooterLayout;
  RefreshStatusRecordCount;
end;

procedure TfrmGrid<TE, TS>.AddFixedFilter(const AFieldName: string; const AValue: Variant);
var
  LParamName: string;
begin
  if not Assigned(FQry) then
    Exit;

  if FQry.Active then
    FQry.Close;

  LParamName := 'fixed_' + AFieldName;
  if Pos('WHERE', UpperCase(FQry.SQL.Text)) > 0 then
    FQry.SQL.Text := FQry.SQL.Text + ' AND ' + AFieldName + ' = :' + LParamName
  else
    FQry.SQL.Text := FQry.SQL.Text + ' WHERE ' + AFieldName + ' = :' + LParamName;

  FQry.ParamByName(LParamName).Value := AValue;
end;

procedure TfrmGrid<TE, TS>.RefreshStatusRecordCount();
begin
  if (FStatusBase.Panels.Count > DB_STATUS_RECORD_COUNT) then
  begin
    // Sayfalı modda filtreye uyan toplam kayıt (yalnız ekrandaki sayfa değil)
    if IsPaged then
      FStatusBase.Panels.Items[DB_STATUS_RECORD_COUNT].Text :=
        Format(TLocalizationManager.Translate(TLangKeys.TGeneral.RecordsCount, 'Records: %d'), [FTotalCount])
    else
      FStatusBase.Panels.Items[DB_STATUS_RECORD_COUNT].Text :=
        Format(TLocalizationManager.Translate(TLangKeys.TGeneral.RecordsCount, 'Records: %d'), [FQry.RecordCount]);
  end;

  UpdateFooterLayout;
end;

procedure TfrmGrid<TE, TS>.SetColumnProperty(const AFieldName: string; AWidth: Integer; AColumnTitle: string = '');
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
      if AColumnTitle <> '' then
        Grd.Columns[i].Title.Caption := AColumnTitle;
      Break;
    end;
  end;
end;

procedure TfrmGrid<TE, TS>.SetColumnTitle(const AFieldName: string; AColumnTitle: string);
var
  i: Integer;
begin
  for i := 0 to Grd.Columns.Count - 1 do
  begin
    if SameText(Grd.Columns[i].FieldName, AFieldName) then
    begin
      Grd.Columns[i].Title.Caption := AColumnTitle;
      Break;
    end;
  end;
end;

procedure TfrmGrid<TE, TS>.SetSelectedItem;
begin
  Service.FillEntityFromDataSet(Qry, Table);
  FillNotMappedFromDataSet;
end;

// [NotMapped] metin özelliklerini (görünen adlar: UomName, CountryName ...) aynı adlı snake_case
// grid kolonundan doldurur; helper dönüşünde edit'e yazılan ad override unutulsa da boş kalmaz
procedure TfrmGrid<TE, TS>.FillNotMappedFromDataSet;
var
  LCtx: TRttiContext;
  LProp: TRttiProperty;
  LAttr: TCustomAttribute;
  LIsNotMapped: Boolean;
  LField: TField;
  LName: string;
  i: Integer;
begin
  if not Assigned(Qry) or not Qry.Active or Qry.IsEmpty or not Assigned(Table) then
    Exit;

  for LProp in LCtx.GetType(TClass(TE)).GetProperties do
  begin
    if not LProp.IsWritable or (LProp.PropertyType.TypeKind <> tkUString) then
      Continue;

    LIsNotMapped := False;
    for LAttr in LProp.GetAttributes do
      if LAttr is NotMapped then
        LIsNotMapped := True;
    if not LIsNotMapped then
      Continue;

    LName := '';
    for i := 1 to Length(LProp.Name) do
      if CharInSet(LProp.Name[i], ['A'..'Z']) then
      begin
        if i > 1 then
          LName := LName + '_';
        LName := LName + LowerCase(LProp.Name[i]);
      end
      else
        LName := LName + LProp.Name[i];

    LField := Qry.FindField(LName);
    if Assigned(LField) then
      LProp.SetValue(TObject(Table), LField.AsString);
  end;
end;

procedure TfrmGrid<TE, TS>.ShowInputForm(Sender: TObject; AFormType: TInputFormMode);
var
  LForm: TForm;
  LId: Int64;
begin
  // Yetki yoksa form açılmadan uyar (F7 / menü / buton hangisiyle gelinirse gelsin)
  if (AFormType = ifmNewRecord) or (AFormType = ifmCopyNewRecord) then
    Service.UoW.EnsureAuthorized(Service.PermissionCode, ptAddRecord, True);

  if (AFormType = ifmRewiev)
  or ((not Service.UoW.InTransaction) and ((AFormType = ifmNewRecord) or (AFormType = ifmCopyNewRecord)))
  then
  begin
    if (AFormType = ifmRewiev) or (AFormType = ifmCopyNewRecord) then
    begin
      LId := Table.Id;
      FreeAndNil(Table);
      Table := Service.BusinessFindById(LId, False, False, True);
    end;
    LForm := CreateInputForm(Sender, AFormType);
    // Salt okunur listelerde giriş formu yok (CreateInputForm = nil): çift tık / Enter AV vermesin
    if LForm = nil then
      Exit;
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
      sl.StrictDelimiter := True;
      if IsPaged then
      begin
        if FSortFields <> '' then
          sl.DelimitedText := FSortFields;
      end
      else if AQuery.IndexFieldNames <> '' then
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
      begin
        mniRemoveGridSort.Visible := True;
        mniRemoveGridSort.Enabled := True;
      end;

      // Sayfalı mod: sıralama sunucuda (tüm kayıtlar), ilk sayfadan başlanır
      if IsPaged then
      begin
        FSortFields := LOrderList;
        FPageIndex := 0;
        LoadPage(True);
      end
      else
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
    Rect.Left + dm.il16.Width + 2,
    Rect.Top + (FStatusBase.Height-Canvas.TextHeight(Panel.Text)) div 2 - 1,
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
    Panel.Width := FStatusBase.Canvas.TextWidth(Panel.Text)+ dm.il16.Width + 8;
  end;
end;

function TfrmGrid<TE, TS>.GetGridViewName: string;
var
  sql, upper : string;
  fromPos    : Integer;
  endPos     : Integer;
  dotPos     : Integer;
begin
  Result := '';
  if not Assigned(FQry) or (FQry.SQL.Count = 0) then Exit;

  sql   := FQry.SQL.Text;
  upper := UpperCase(sql);

  fromPos := Pos(' FROM ', upper);
  if fromPos = 0 then Exit;
  Inc(fromPos, 6);

  endPos := fromPos;
  while endPos <= Length(sql) do
  begin
    if CharInSet(sql[endPos], [' ', #9, #13, #10]) then Break;
    Inc(endPos);
  end;

  Result := LowerCase(Trim(Copy(sql, fromPos, endPos - fromPos)));

  dotPos := LastDelimiter('.', Result);
  if dotPos > 0 then
    Result := Copy(Result, dotPos + 1, MaxInt);
end;

procedure TfrmGrid<TE, TS>.AutoPopulateSysGridColumns(const AViewName: string);
var
  LSysRepo : ISysGridColumnRepository;
  LAutoCols: TObjectList<TSysGridColumn>;
  LCol     : TSysGridColumn;
  i        : Integer;
begin
  if (AViewName = '') or (Grd.Columns.Count = 0) then Exit;
  if not Assigned(Service) or not Assigned(Service.UoW) or (Service.UoW.Connection = nil) or not Service.UoW.Connection.Connected then Exit;

  LSysRepo := Service.UoW.GetRepository<TSysGridColumn, TSysGridColumnRepository> as ISysGridColumnRepository;
  if LSysRepo = nil then Exit;

  // Güvenlik kontrolü: Tabloda 1 veya daha fazla kayıt varsa AutoPopulate ASLA çalışmamalı
  if LSysRepo.HasTableColumns(AViewName) then Exit;

  LAutoCols := TObjectList<TSysGridColumn>.Create(True);
  try
    for i := 0 to Grd.Columns.Count - 1 do
    begin
      if Grd.Columns[i].FieldName = '' then Continue;

      LCol             := TSysGridColumn.Create;
      LCol.TableName   := AViewName;
      LCol.ColumnName  := Grd.Columns[i].FieldName;
      LCol.ColumnOrder := Grd.Columns[i].Index + 1;
      LCol.ColumnWidth := Grd.Columns[i].Width;
      LCol.IsShow      := Grd.Columns[i].Visible;
      LCol.IsShowHelper:= False;
      LCol.IsFetch     := True;
      LAutoCols.Add(LCol);
    end;

    if LAutoCols.Count > 0 then
    begin
      LSysRepo.SaveColumns(AViewName, LAutoCols);
      GLogger.InfoFmt('sys_grid_column: [%s] tablosu için %d kolon otomatik eklendi.', [AViewName, LAutoCols.Count]);
    end;
  finally
    LAutoCols.Free;
  end;
end;

procedure TfrmGrid<TE, TS>.AutoPopulateSysGridFilter(const AViewName: string);
begin
  // sys_grid_filter için otomatik kayıt ekleme kaldırıldı (isteğe bağlı CRUD)
end;

procedure TfrmGrid<TE, TS>.AutoPopulateSysGridSort(const AViewName: string);
begin
  // sys_grid_sort için otomatik kayıt ekleme kaldırıldı (isteğe bağlı CRUD)
end;

procedure TfrmGrid<TE, TS>.ApplyDynamicFilterAndSort;
var
  LViewName: string;
  LFilterRepo: ISysGridFilterRepository;
  LSortRepo  : ISysGridSortRepository;
  LFilter    : TSysGridFilter;
  LSort      : TSysGridSort;
  LFilterContent: string;
  LSortContent  : string;
begin
  LViewName := GetGridViewName;
  if LViewName = '' then Exit;
  if not Assigned(Service) or not Assigned(Service.UoW) or (Service.UoW.Connection = nil) or not Service.UoW.Connection.Connected then Exit;

  try
    LFilterRepo := Service.UoW.GetRepository<TSysGridFilter, TSysGridFilterRepository> as ISysGridFilterRepository;
    if LFilterRepo <> nil then
    begin
      LFilter := LFilterRepo.LoadFilter(LViewName);
      if LFilter <> nil then
      begin
        try
          LFilterContent := Trim(LFilter.FilterContent);
          if LFilterContent <> '' then
          begin
            if Pos('WHERE', UpperCase(FQry.SQL.Text)) > 0 then
              FQry.SQL.Text := FQry.SQL.Text + ' AND (' + LFilterContent + ')'
            else
              FQry.SQL.Text := FQry.SQL.Text + ' WHERE (' + LFilterContent + ')';
          end;
        finally
          LFilter.Free;
        end;
      end;
    end;
  except
    on E: Exception do
      GLogger.WarningFmt('ApplyDynamicFilterAndSort (Filter) hatası [%s]: %s', [LViewName, E.Message]);
  end;

  try
    LSortRepo := Service.UoW.GetRepository<TSysGridSort, TSysGridSortRepository> as ISysGridSortRepository;
    if LSortRepo <> nil then
    begin
      LSort := LSortRepo.LoadSort(LViewName);
      if LSort <> nil then
      begin
        try
          LSortContent := Trim(LSort.SortContent);
          if LSortContent <> '' then
          begin
            if Pos('ORDER BY', UpperCase(FQry.SQL.Text)) = 0 then
            begin
              if UpperCase(Copy(LSortContent, 1, 8)) = 'ORDER BY' then
                FQry.SQL.Text := FQry.SQL.Text + ' ' + LSortContent
              else
                FQry.SQL.Text := FQry.SQL.Text + ' ORDER BY ' + LSortContent;
            end;
          end;
        finally
          LSort.Free;
        end;
      end;
    end;
  except
    on E: Exception do
      GLogger.WarningFmt('ApplyDynamicFilterAndSort (Sort) hatası [%s]: %s', [LViewName, E.Message]);
  end;

  // Tanımlı sıralama yoksa satır sırası sabit kalsın (güncellenen kayıt yenilemede sona kaymasın)
  if Pos('ORDER BY', UpperCase(FQry.SQL.Text)) = 0 then
    FQry.SQL.Text := FQry.SQL.Text + ' ORDER BY id';
end;

procedure TfrmGrid<TE, TS>.LoadColumnWidthsFromDB;
var
  LViewName: string;
  LSysRepo : ISysGridColumnRepository;
  LColumns : TList<TSysGridColumn>;
  LCol     : TSysGridColumn;
  LColMap  : TDictionary<string, Integer>;
  LColIndex: Integer;
  i, j     : Integer;
  LUserId  : Int64;
begin
  LViewName := GetGridViewName;
  if LViewName = '' then Exit;
  if not Service.UoW.Connection.Connected then Exit;

  LSysRepo := Service.UoW.GetRepository<TSysGridColumn, TSysGridColumnRepository> as ISysGridColumnRepository;
  if LSysRepo = nil then Exit;

  // sys_grid_column içinde bu forma ait hiç kayıt yoksa tüm alanları otomatik ekle
  if not LSysRepo.HasTableColumns(LViewName) then
    AutoPopulateSysGridColumns(LViewName);

  LUserId := 0;
  if (TAppContext.Instance.CurrentUser <> nil) then
    LUserId := TAppContext.Instance.CurrentUser.GetUserId;

  if LUserId > 0 then
    LColumns := LSysRepo.LoadUserColumns(LViewName, LUserId)
  else
    LColumns := LSysRepo.LoadColumns(LViewName);

  try
    if LColumns.Count = 0 then Exit;

    LColMap := TDictionary<string, Integer>.Create(Grd.Columns.Count);
    try
      for i := 0 to Grd.Columns.Count - 1 do
        LColMap.AddOrSetValue(LowerCase(Grd.Columns[i].FieldName), i);

      // Veritabanında (sys_grid_column) tanımlı olmayan DFM kolonlarını gizle
      for i := 0 to Grd.Columns.Count - 1 do
      begin
        var LFound := False;
        for LCol in LColumns do
        begin
          if SameText(LCol.ColumnName, Grd.Columns[i].FieldName) then
          begin
            LFound := True;
            Break;
          end;
        end;
        if not LFound then
          Grd.Columns[i].Visible := False;
      end;

      for LCol in LColumns do
      begin
        if not LColMap.TryGetValue(LowerCase(LCol.ColumnName), LColIndex) then
          Continue;
        if not LCol.IsShow then
          Grd.Columns[LColIndex].Visible := False
        else
        begin
          Grd.Columns[LColIndex].Visible := True;
          if LCol.ColumnWidth > 0 then
            Grd.Columns[LColIndex].Width := LCol.ColumnWidth;
        end;
      end;

      j := 0;
      for LCol in LColumns do
      begin
        if not LCol.IsShow then Continue;
        if not LColMap.TryGetValue(LowerCase(LCol.ColumnName), LColIndex) then
          Continue;
        if not Grd.Columns[LColIndex].Visible then Continue;
        if Grd.Columns[LColIndex].Index <> j then
          Grd.Columns[LColIndex].Index := j;
        Inc(j);
      end;
    finally
      LColMap.Free;
    end;
  finally
    LColumns.Free;
  end;
end;

procedure TfrmGrid<TE, TS>.AdjustFormWidth;
var
  n1, LTotalWidth: Integer;
begin
  LTotalWidth := 0;
  for n1 := 0 to Grd.Columns.Count - 1 do
  begin
    if Grd.Columns[n1].Visible then
    begin
      LTotalWidth := LTotalWidth + Grd.Columns[n1].Width;
      if dgColLines in Grd.Options then
        LTotalWidth := LTotalWidth + 1;
    end;
  end;

  if dgIndicator in Grd.Options then
    LTotalWidth := LTotalWidth + IndicatorWidth;

  LTotalWidth := LTotalWidth + (Self.Width - Self.ClientWidth) + 30;

  if (Self.Constraints.MinWidth > 0) and (LTotalWidth < Self.Constraints.MinWidth) then
    LTotalWidth := Self.Constraints.MinWidth;

  if (Self.Constraints.MaxWidth > 0) and (LTotalWidth > Self.Constraints.MaxWidth) then
    LTotalWidth := Self.Constraints.MaxWidth;

  Self.Width := LTotalWidth;
end;

procedure TfrmGrid<TE, TS>.SaveColumnWidthsToDB;
var
  LViewName : string;
  LSysRepo  : ISysGridColumnRepository;
  LColumns  : TObjectList<TSysGridColumn>;
  LCol      : TSysGridColumn;
  i         : Integer;
  LUserId   : Int64;
begin
  LViewName := GetGridViewName;
  if LViewName = '' then Exit;
  if Service.UoW.InTransaction then Exit;

  LUserId := 0;
  if (TAppContext.Instance.CurrentUser <> nil) then
    LUserId := TAppContext.Instance.CurrentUser.GetUserId;

  // Yalnızca oturum açmış kullanıcının kişiselleştirmelerini (sys_user_grid_column) kaydet
  // Form kapanırken sys_grid_column sistem tablosunu ezme
  if LUserId <= 0 then Exit;

  LColumns := TObjectList<TSysGridColumn>.Create(True);
  try
    for i := 0 to Grd.Columns.Count - 1 do
    begin
      LCol             := TSysGridColumn.Create;
      LCol.TableName   := LViewName;
      LCol.ColumnName  := Grd.Columns[i].FieldName;
      LCol.ColumnOrder := Grd.Columns[i].Index;
      LCol.ColumnWidth := Grd.Columns[i].Width;
      LCol.IsShow      := Grd.Columns[i].Visible;
      LColumns.Add(LCol);
    end;

    LSysRepo := Service.UoW.GetRepository<TSysGridColumn, TSysGridColumnRepository> as ISysGridColumnRepository;
    LSysRepo.SaveUserColumns(LViewName, LUserId, LColumns);
  finally
    LColumns.Free;
  end;
end;

{ Sayfalama }

function TfrmGrid<TE, TS>.IsPaged: Boolean;
begin
  Result := FPagingEnabled and FPagingReady;
end;

function TfrmGrid<TE, TS>.NewPagingButton(const ACaption: string; AOnClick: TNotifyEvent; ALeft: Integer): TButton;
begin
  Result := TButton.Create(FPanelPaging);
  Result.Parent := FPanelPaging;
  Result.Left := ALeft;
  Result.Width := 26;
  Result.Align := alLeft;
  Result.AlignWithMargins := True;
  Result.Margins.SetBounds(1, 2, 1, 2);
  Result.Caption := ACaption;
  Result.TabStop := False;
  Result.OnClick := AOnClick;
end;

procedure TfrmGrid<TE, TS>.CreatePanelPaging;
var
  i: Integer;
begin
  FPanelPaging := TPanel.Create(PanelFooter);
  FPanelPaging.Parent := PanelFooter;
  FPanelPaging.Align := alClient;
  FPanelPaging.BevelOuter := bvNone;
  FPanelPaging.ParentColor := True;
  FPanelPaging.ShowHint := True;
  FPanelPaging.Visible := False;

  // Hizalama sırası Left değerine göre: kontroller tek seferde hizalansın
  FPanelPaging.DisableAlign;
  try
    FBtnFirstPage := NewPagingButton(#$00AB, BtnFirstPageClick, 10000);
    FBtnPrevPage := NewPagingButton(#$2039, BtnPrevPageClick, 10010);

    FEdtPage := TEdit.Create(FPanelPaging);
    FEdtPage.Parent := FPanelPaging;
    FEdtPage.Left := 10020;
    FEdtPage.Width := 44;
    FEdtPage.Align := alLeft;
    FEdtPage.AlignWithMargins := True;
    FEdtPage.Margins.SetBounds(4, 3, 2, 3);
    FEdtPage.NumbersOnly := True;
    FEdtPage.Alignment := taCenter;
    FEdtPage.TabStop := False;
    FEdtPage.OnKeyDown := EdtPageKeyDown;

    FLblPageCount := TLabel.Create(FPanelPaging);
    FLblPageCount.Parent := FPanelPaging;
    FLblPageCount.Left := 10030;
    FLblPageCount.Align := alLeft;
    FLblPageCount.AlignWithMargins := True;
    FLblPageCount.Margins.SetBounds(2, 3, 4, 3);
    FLblPageCount.Layout := tlCenter;

    FBtnNextPage := NewPagingButton(#$203A, BtnNextPageClick, 10040);
    FBtnLastPage := NewPagingButton(#$00BB, BtnLastPageClick, 10050);

    FLblPageInfo := TLabel.Create(FPanelPaging);
    FLblPageInfo.Parent := FPanelPaging;
    FLblPageInfo.Left := 10060;
    FLblPageInfo.Align := alLeft;
    FLblPageInfo.AlignWithMargins := True;
    FLblPageInfo.Margins.SetBounds(10, 3, 4, 3);
    FLblPageInfo.Layout := tlCenter;

    FCbbPageSize := TComboBox.Create(FPanelPaging);
    FCbbPageSize.Parent := FPanelPaging;
    FCbbPageSize.Align := alRight;
    FCbbPageSize.AlignWithMargins := True;
    FCbbPageSize.Margins.SetBounds(4, 3, 8, 3);
    FCbbPageSize.Style := csDropDownList;
    FCbbPageSize.Width := 70;
    FCbbPageSize.TabStop := False;
    for i := Low(GRID_PAGE_SIZES) to High(GRID_PAGE_SIZES) do
      if GRID_PAGE_SIZES[i] > 0 then
        FCbbPageSize.Items.Add(IntToStr(GRID_PAGE_SIZES[i]))
      else
        FCbbPageSize.Items.Add('All');
    FCbbPageSize.OnChange := CbbPageSizeChange;
  finally
    FPanelPaging.EnableAlign;
  end;

  ApplyPagingLocalization;
end;

procedure TfrmGrid<TE, TS>.ApplyPagingLocalization;
var
  LIndex: Integer;
begin
  if not Assigned(FPanelPaging) then
    Exit;

  FBtnFirstPage.Hint := TLocalizationManager.Translate(TLangKeys.TGeneral.PageFirst, 'First page');
  FBtnPrevPage.Hint := TLocalizationManager.Translate(TLangKeys.TGeneral.PagePrevious, 'Previous page (Ctrl+PgUp)');
  FBtnNextPage.Hint := TLocalizationManager.Translate(TLangKeys.TGeneral.PageNext, 'Next page (Ctrl+PgDn)');
  FBtnLastPage.Hint := TLocalizationManager.Translate(TLangKeys.TGeneral.PageLast, 'Last page');
  FEdtPage.Hint := TLocalizationManager.Translate(TLangKeys.TGeneral.PageNumber, 'Page number (Enter)');
  FCbbPageSize.Hint := TLocalizationManager.Translate(TLangKeys.TGeneral.PageSize, 'Rows per page');

  LIndex := FCbbPageSize.ItemIndex;
  FCbbPageSize.Items[FCbbPageSize.Items.Count - 1] := TLocalizationManager.Translate(TLangKeys.TGeneral.PageAll, 'All');
  FCbbPageSize.ItemIndex := LIndex;

  UpdatePagingControls;
end;

function TfrmGrid<TE, TS>.PageCount: Integer;
begin
  if (FPageSize <= 0) or (FTotalCount <= 0) then
    Result := 1
  else
    Result := Integer((FTotalCount + FPageSize - 1) div FPageSize);
end;

procedure TfrmGrid<TE, TS>.UpdatePagingControls;
var
  LPages, i: Integer;
  LFrom, LTo: Int64;
begin
  if not Assigned(FPanelPaging) then
    Exit;

  LPages := PageCount;
  FEdtPage.Text := IntToStr(FPageIndex + 1);
  FEdtPage.Enabled := LPages > 1;
  FLblPageCount.Caption := '/ ' + IntToStr(LPages);
  FBtnFirstPage.Enabled := FPageIndex > 0;
  FBtnPrevPage.Enabled := FPageIndex > 0;
  FBtnNextPage.Enabled := FPageIndex < LPages - 1;
  FBtnLastPage.Enabled := FPageIndex < LPages - 1;

  if FTotalCount = 0 then
    LFrom := 0
  else if FPageSize > 0 then
    LFrom := Int64(FPageIndex) * FPageSize + 1
  else
    LFrom := 1;
  LTo := FTotalCount;
  if (FPageSize > 0) and (Int64(FPageIndex + 1) * FPageSize < LTo) then
    LTo := Int64(FPageIndex + 1) * FPageSize;
  FLblPageInfo.Caption := Format(TLocalizationManager.Translate(TLangKeys.TGeneral.PageInfo, '%s - %s of %s'),
    [FormatFloat('#,##0', LFrom), FormatFloat('#,##0', LTo), FormatFloat('#,##0', FTotalCount)]);

  for i := Low(GRID_PAGE_SIZES) to High(GRID_PAGE_SIZES) do
    if GRID_PAGE_SIZES[i] = FPageSize then
      FCbbPageSize.ItemIndex := i;
end;

// FormShow'da (sabit + dinamik filtreler eklendikten sonra) sorgunun ORDER BY'sız gövdesi ve parametreleri saklanır;
// her sayfa / arama / sıralama bu gövdeden yeniden kurulur
procedure TfrmGrid<TE, TS>.CapturePagingBaseSql;
var
  LSql, LTail: string;
  LPos, LDepth, i: Integer;
begin
  LSql := TrimRight(FQry.SQL.Text);
  FBaseOrderBy := '';
  LPos := UpperCase(LSql).LastIndexOf('ORDER BY');
  if LPos >= 0 then
  begin
    LTail := LSql.Substring(LPos + Length('ORDER BY'));
    // parantez dengesi bozuksa ORDER BY bir alt sorguya / pencere fonksiyonuna aittir
    LDepth := 0;
    for i := 1 to Length(LTail) do
      if LTail[i] = '(' then
        Inc(LDepth)
      else if LTail[i] = ')' then
        Dec(LDepth);
    if LDepth = 0 then
    begin
      FBaseOrderBy := Trim(LTail);
      LSql := TrimRight(LSql.Substring(0, LPos));
    end;
  end;
  FBaseSql := LSql;

  FreeAndNil(FBaseParams);
  FBaseParams := TFDParams.Create;
  FBaseParams.Assign(FQry.Params);
  FPagingReady := True;
end;

procedure TfrmGrid<TE, TS>.ApplyPagingParams(AQuery: TFDQuery);
var
  i: Integer;
  LParam: TFDParam;
begin
  if Assigned(FBaseParams) then
    for i := 0 to FBaseParams.Count - 1 do
    begin
      LParam := AQuery.Params.FindParam(FBaseParams[i].Name);
      if Assigned(LParam) then
      begin
        LParam.DataType := FBaseParams[i].DataType;
        LParam.Value := FBaseParams[i].Value;
      end;
    end;

  LParam := AQuery.Params.FindParam('pg_s');
  if Assigned(LParam) then
    LParam.AsWideString := '%' + LikeEscape(FSearchText) + '%';
  LParam := AQuery.Params.FindParam('pg_su');
  if Assigned(LParam) then
    LParam.AsWideString := '%' + LikeEscape(UpperCaseTr(FSearchText)) + '%';
  LParam := AQuery.Params.FindParam('pg_sl');
  if Assigned(LParam) then
    LParam.AsWideString := '%' + LikeEscape(LowerCaseTr(FSearchText)) + '%';

  for i := 0 to High(FQuickParams) do
  begin
    LParam := AQuery.Params.FindParam('qc' + IntToStr(i));
    if Assigned(LParam) then
      LParam.Value := FQuickParams[i];
  end;
end;

function TfrmGrid<TE, TS>.CreatePagingQuery(const ASql: string): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  try
    Result.Connection := FQry.Connection;
    Result.SQL.Text := ASql;
    ApplyPagingParams(Result);
  except
    Result.Free;
    raise;
  end;
end;

function TfrmGrid<TE, TS>.PagingFilteredSql: string;
var
  LCond: string;
begin
  LCond := '';
  if FQuickSql <> '' then
    LCond := '(' + FQuickSql + ')';
  if FSearchSql <> '' then
  begin
    if LCond <> '' then
      LCond := LCond + ' AND ';
    LCond := LCond + '(' + FSearchSql + ')';
  end;
  if FFilterGrid.Count > 0 then
  begin
    if LCond <> '' then
      LCond := LCond + ' AND ';
    // satırlar ' AND ' önekiyle tutulur (BuildFilterExpression)
    LCond := LCond + '(' + Trim(FFilterGrid.Text) + ')';
  end;

  Result := AddWhereCondition(FBaseSql, LCond);
end;

function TfrmGrid<TE, TS>.AddWhereCondition(const ASql, ACond: string): string;
begin
  Result := ASql;
  if ACond = '' then
    Exit;
  if Pos('WHERE', UpperCase(Result)) > 0 then
    Result := Result + ' AND ' + ACond
  else
    Result := Result + ' WHERE ' + ACond;
end;

function TfrmGrid<TE, TS>.PagingOrderBy: string;
var
  LList: TStringList;
  LName, LDir, LLower: string;
  i: Integer;
begin
  Result := '';
  if FSortFields <> '' then
  begin
    LList := TStringList.Create;
    try
      LList.Delimiter := ';';
      LList.StrictDelimiter := True;
      LList.DelimitedText := FSortFields;
      for i := 0 to LList.Count - 1 do
      begin
        LName := LList[i];
        LDir := 'ASC';
        if EndsText(':D', LName) then
          LDir := 'DESC';
        if (Length(LName) > 2) and (LName[Length(LName) - 1] = ':') then
          SetLength(LName, Length(LName) - 2);
        if LName = '' then
          Continue;
        if Result <> '' then
          Result := Result + ', ';
        Result := Result + AnsiQuotedStr(LName, '"') + ' ' + LDir;
      end;
    finally
      LList.Free;
    end;
  end;

  if FBaseOrderBy <> '' then
  begin
    if Result <> '' then
      Result := Result + ', ';
    Result := Result + FBaseOrderBy;
  end;

  // Aynı değerli satırlar sayfalar arasında kaymasın / tekrar etmesin
  LLower := LowerCase(Trim(Result));
  if Result = '' then
    Result := 'id'
  else if not (EndsText(' id', ' ' + LLower) or EndsText(' id asc', ' ' + LLower) or EndsText(' id desc', ' ' + LLower)) then
    Result := Result + ', id';
end;

procedure TfrmGrid<TE, TS>.OpenPageData(AQuiet: Boolean);
var
  LSql: string;
begin
  if FPageIndex < 0 then
    FPageIndex := 0;

  LSql := PagingFilteredSql + ' ORDER BY ' + PagingOrderBy;
  if FPageSize > 0 then
    LSql := LSql + Format(' LIMIT %d OFFSET %d', [FPageSize, Int64(FPageIndex) * FPageSize]);

  // AQuiet: kolonlar varsayılana dönmesin, AfterDatasetOpen (DB'den genişlik, form genişliği) çalışmasın
  FPageReload := AQuiet;
  if AQuiet then
    FQry.DisableControls;
  try
    FQry.Close;
    FQry.SQL.Text := LSql;
    ApplyPagingParams(FQry);
    FQry.Open;
  finally
    if AQuiet then
      FQry.EnableControls;
    FPageReload := False;
  end;
end;

// Kayıt sayısı + alt toplamlar tek sorguda, filtreye uyan tüm kayıtlar üzerinden
procedure TfrmGrid<TE, TS>.LoadPagingTotals;
var
  LSelect: string;
  LQ: TFDQuery;
  LFooterCol: TFooterColumn;
  LField: TField;
  i: Integer;
begin
  LSelect := 'count(*) AS pg_total';
  i := 0;
  if Assigned(FFooterColumns) then
    for LFooterCol in FFooterColumns do
    begin
      // sorguda olmayan kolon toplamı SQL hatası (açık işlemi de bozar) vermesin
      if FQry.FindField(LFooterCol.ColumnFieldName) <> nil then
        LSelect := LSelect + Format(', %s(%s) AS pg_a%d',
          [AggregateTypeToSqlFunc(LFooterCol.AggregateType), AnsiQuotedStr(LFooterCol.ColumnFieldName, '"'), i]);
      Inc(i);
    end;

  LQ := CreatePagingQuery('SELECT ' + LSelect + ' FROM (' + PagingFilteredSql + ') pg_t');
  try
    LQ.Open;
    FTotalCount := LQ.FieldByName('pg_total').AsLargeInt;
    i := 0;
    if Assigned(FFooterColumns) then
      for LFooterCol in FFooterColumns do
      begin
        LField := LQ.FindField('pg_a' + IntToStr(i));
        if Assigned(LField) then
          LFooterCol.ServerValue := LField.Value
        else
          LFooterCol.ServerValue := Null;
        Inc(i);
      end;
  finally
    LQ.Free;
  end;
end;

// Kaydın sıralı / filtreli listedeki sırası -> sayfa no (0 tabanlı); bulunamazsa -1
function TfrmGrid<TE, TS>.FindPageOfId(AId: Int64): Integer;
var
  LSql: string;
  LQ: TFDQuery;
begin
  Result := -1;
  if (FPageSize <= 0) or (AId <= 0) or (FQry.FindField('id') = nil) then
    Exit;

  LSql := TrimLeft(PagingFilteredSql);
  if not StartsText('SELECT ', LSql) or StartsText('SELECT DISTINCT', LSql) then
    Exit;
  LSql := 'SELECT row_number() OVER (ORDER BY ' + PagingOrderBy + ') AS pg_rn, ' + LSql.Substring(Length('SELECT '));

  LQ := CreatePagingQuery('SELECT pg_r.pg_rn FROM (' + LSql + ') pg_r WHERE pg_r.id = ' + IntToStr(AId));
  try
    LQ.Open;
    if not LQ.IsEmpty then
      Result := (LQ.Fields[0].AsLargeInt - 1) div FPageSize;
  finally
    LQ.Free;
  end;
end;

procedure TfrmGrid<TE, TS>.LoadPage(AKeepLayout: Boolean; AFocusId: Int64);
var
  LStates: TArray<TGridColumnState>;
  LQuiet: Boolean;
  LPage, LFocusPage: Integer;
  LCursor: TCursor;
begin
  if not IsPaged then
    Exit;

  LCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    LQuiet := AKeepLayout and FQry.Active and (Grd.Columns.Count > 0);
    if LQuiet then
      LStates := SaveColumnStates
    else
      LStates := nil;

    OpenPageData(LQuiet);
    LoadPagingTotals;

    // Kayıt silinip sayfa sayısı azaldıysa son sayfa; odaklanacak kayıt başka sayfadaysa o sayfa
    LPage := FPageIndex;
    if LPage > PageCount - 1 then
      LPage := PageCount - 1;
    if (AFocusId > 0) and (FPageSize > 0) and (FQry.FindField('id') <> nil) and not FQry.Locate('id', AFocusId, []) then
    begin
      LFocusPage := FindPageOfId(AFocusId);
      if LFocusPage >= 0 then
        LPage := LFocusPage;
    end;
    if LPage <> FPageIndex then
    begin
      FPageIndex := LPage;
      OpenPageData(LQuiet);
    end;
    if (AFocusId > 0) and (FQry.FindField('id') <> nil) then
      FQry.Locate('id', AFocusId, []);

    if LQuiet then
      RestoreColumnStates(LStates);
  finally
    Screen.Cursor := LCursor;
  end;

  UpdatePagingControls;
  RefreshStatusRecordCount;
end;

procedure TfrmGrid<TE, TS>.GoToPage(AIndex: Integer);
begin
  if not IsPaged then
    Exit;
  if AIndex > PageCount - 1 then
    AIndex := PageCount - 1;
  if AIndex < 0 then
    AIndex := 0;
  if AIndex = FPageIndex then
  begin
    UpdatePagingControls;
    Exit;
  end;
  FPageIndex := AIndex;
  LoadPage(True);
end;

function TfrmGrid<TE, TS>.SaveColumnStates: TArray<TGridColumnState>;
var
  i: Integer;
begin
  SetLength(Result, Grd.Columns.Count);
  for i := 0 to Grd.Columns.Count - 1 do
  begin
    Result[i].FieldName := Grd.Columns[i].FieldName;
    Result[i].Width := Grd.Columns[i].Width;
    Result[i].Visible := Grd.Columns[i].Visible;
    Result[i].Caption := Grd.Columns[i].Title.Caption;
  end;
end;

procedure TfrmGrid<TE, TS>.RestoreColumnStates(const AStates: TArray<TGridColumnState>);
var
  i, j, LIndex: Integer;
  LCol: TColumn;
begin
  for i := 0 to Grd.Columns.Count - 1 do
  begin
    Grd.Columns[i].Title.Font.Style := [fsBold];
    Grd.Columns[i].Title.Alignment := TAlignment.taCenter;
  end;
  // yeniden oluşan alanlara alan olayları (OnGetText vb.) yeniden bağlansın
  DefineColumnWidths;

  Grd.Columns.BeginUpdate;
  try
    LIndex := 0;
    for i := 0 to High(AStates) do
      for j := 0 to Grd.Columns.Count - 1 do
        if SameText(Grd.Columns[j].FieldName, AStates[i].FieldName) then
        begin
          LCol := Grd.Columns[j];
          LCol.Visible := AStates[i].Visible;
          LCol.Width := AStates[i].Width;
          LCol.Title.Caption := AStates[i].Caption;
          if LCol.Index <> LIndex then
            LCol.Index := LIndex;
          Inc(LIndex);
          Break;
        end;
  finally
    Grd.Columns.EndUpdate;
  end;
  UpdateFooterLayout;
end;

// SQL değişmezi (popup "Filtrele"): tarih ISO, ondalık nokta, metin tırnaklı; desteklenmeyen tip boş
function TfrmGrid<TE, TS>.SqlLiteral(AField: TField): string;
begin
  Result := '';
  case AField.DataType of
    ftString, ftWideString, ftMemo, ftWideMemo, ftFmtMemo, ftFixedChar, ftFixedWideChar, ftGuid:
      Result := QuotedStr(AField.AsString);
    ftSmallint, ftInteger, ftWord, ftLargeint, ftAutoInc, ftLongWord, ftShortint, ftByte:
      Result := AField.AsString;
    ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftExtended, ftSingle:
      Result := FloatToStr(AField.AsFloat, TFormatSettings.Invariant);
    ftBoolean:
      Result := IfThen(AField.AsBoolean, 'true', 'false');
    ftDate:
      Result := 'DATE ' + QuotedStr(FormatDateTime('yyyy-mm-dd', AField.AsDateTime));
    ftTime:
      Result := 'TIME ' + QuotedStr(FormatDateTime('hh:nn:ss', AField.AsDateTime));
    ftDateTime, ftTimeStamp, ftOraTimeStamp:
      Result := 'TIMESTAMP ' + QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', AField.AsDateTime));
  end;
end;

// Hızlı filtre: görünen kolonlarda; metin her yerde (büyük / küçük harf, Türkçe İ/ı dahil), sayı / tarih / mantıksal eşitlik
function TfrmGrid<TE, TS>.BuildSearchSql(const AText: string): string;
var
  i: Integer;
  LCol: TColumn;
  LField: TField;
  LName: string;
  LFloat: Double;
  LDate: TDateTime;
  LIsNumber, LIsDate, LIsBool: Boolean;
  LParts: TStringList;
begin
  Result := '';
  if AText = '' then
    Exit;

  LIsNumber := TryStrToFloat(AText, LFloat);
  LIsDate := TryStrToDate(AText, LDate);
  LIsBool := SameText(AText, 'TRUE') or SameText(AText, 'FALSE');

  LParts := TStringList.Create;
  try
    for i := 0 to Grd.Columns.Count - 1 do
    begin
      LCol := Grd.Columns[i];
      LField := LCol.Field;
      if not LCol.Visible or not Assigned(LField) or SameText(LCol.FieldName, 'id') then
        Continue;
      LName := AnsiQuotedStr(LCol.FieldName, '"');
      case LField.DataType of
        ftString, ftWideString, ftMemo, ftWideMemo, ftFixedChar, ftFixedWideChar:
          LParts.Add(Format('(%0:s ILIKE :pg_s OR %0:s LIKE :pg_su OR %0:s LIKE :pg_sl)', [LName]));
        ftSmallint, ftInteger, ftWord, ftLargeint, ftLongWord, ftShortint, ftByte,
        ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftExtended, ftSingle:
          if LIsNumber then
            LParts.Add(LName + ' = ' + FloatToStr(LFloat, TFormatSettings.Invariant));
        ftBoolean:
          if LIsBool then
            LParts.Add(LName + ' = ' + LowerCase(AText));
        ftDate, ftDateTime, ftTimeStamp:
          if LIsDate then
            LParts.Add(Format('CAST(%s AS date) = DATE %s', [LName, QuotedStr(FormatDateTime('yyyy-mm-dd', LDate))]));
      end;
    end;

    // aranabilir kolon yoksa hiçbir kayıt eşleşmez
    if LParts.Count = 0 then
      Result := '1 = 0'
    else
      Result := string.Join(' OR ', LParts.ToStringArray);
  finally
    LParts.Free;
  end;
end;

procedure TfrmGrid<TE, TS>.SearchTimerTimer(Sender: TObject);
begin
  FSearchTimer.Enabled := False;
  if not IsPaged then
    Exit;
  FSearchText := Trim(EdtFilter.Text);
  FSearchSql := BuildSearchSql(FSearchText);
  FPageIndex := 0;
  LoadPage(True);
end;

procedure TfrmGrid<TE, TS>.FlushPendingSearch;
begin
  if IsPaged and FSearchTimer.Enabled then
    SearchTimerTimer(FSearchTimer);
end;

procedure TfrmGrid<TE, TS>.BtnFirstPageClick(Sender: TObject);
begin
  GoToPage(0);
  if (Sender <> nil) and Grd.CanFocus then
    Grd.SetFocus;
end;

procedure TfrmGrid<TE, TS>.BtnPrevPageClick(Sender: TObject);
begin
  GoToPage(FPageIndex - 1);
  if (Sender <> nil) and Grd.CanFocus then
    Grd.SetFocus;
end;

procedure TfrmGrid<TE, TS>.BtnNextPageClick(Sender: TObject);
begin
  GoToPage(FPageIndex + 1);
  if (Sender <> nil) and Grd.CanFocus then
    Grd.SetFocus;
end;

procedure TfrmGrid<TE, TS>.BtnLastPageClick(Sender: TObject);
begin
  GoToPage(PageCount - 1);
  if (Sender <> nil) and Grd.CanFocus then
    Grd.SetFocus;
end;

procedure TfrmGrid<TE, TS>.EdtPageKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    GoToPage(StrToIntDef(FEdtPage.Text, FPageIndex + 1) - 1);
    if Grd.CanFocus then
      Grd.SetFocus;
  end;
end;

procedure TfrmGrid<TE, TS>.CbbPageSizeChange(Sender: TObject);
begin
  if FCbbPageSize.ItemIndex < 0 then
    Exit;
  ChangePageSize(GRID_PAGE_SIZES[FCbbPageSize.ItemIndex]);
  if Grd.CanFocus then
    Grd.SetFocus;
end;

procedure TfrmGrid<TE, TS>.ChangePageSize(AValue: Integer; ASaveSetting: Boolean);
var
  LFirstRow: Int64;
begin
  if AValue < 0 then
    AValue := 0;
  if ASaveSetting then
    SetGridPageSize(AValue);
  if AValue = FPageSize then
    Exit;

  // ekrandaki ilk kayıt yeni sayfa boyutunda da görünsün
  LFirstRow := Int64(FPageIndex) * FPageSize;
  FPageSize := AValue;
  if FPageSize > 0 then
    FPageIndex := Integer(LFirstRow div FPageSize)
  else
    FPageIndex := 0;
  if IsPaged then
    LoadPage(True)
  else
    UpdatePagingControls;
end;

// İstemci tarafı mod: gövde + hızlı filtre koşulu + taban sıralama (sorgu kapalı bırakılır)
procedure TfrmGrid<TE, TS>.ApplyQuickSqlToQuery;
var
  LSql: string;
begin
  LSql := FBaseSql;
  if FQuickSql <> '' then
    LSql := AddWhereCondition(LSql, '(' + FQuickSql + ')');
  if FBaseOrderBy <> '' then
    LSql := LSql + ' ORDER BY ' + FBaseOrderBy;
  FQry.Close;
  FQry.SQL.Text := LSql;
  ApplyPagingParams(FQry);
end;

procedure TfrmGrid<TE, TS>.SetQuickCondition(const ASql: string; const AParams: array of Variant);
var
  i: Integer;
begin
  FQuickSql := Trim(ASql);
  SetLength(FQuickParams, Length(AParams));
  for i := 0 to High(AParams) do
    FQuickParams[i] := AParams[i];

  // FormShow henüz çalışmadıysa ilk açılışta uygulanır
  if not FPagingReady or not Assigned(FQry) or not FQry.Active then
    Exit;

  FPageIndex := 0;
  if IsPaged then
  begin
    LoadPage(True);
    UpdateFooterLayout;
  end
  else
  begin
    ApplyQuickSqlToQuery;
    RefreshParentGrid(False);
  end;
end;

function TfrmGrid<TE, TS>.AddQuickFilter(const ACaption, ASql: string; const AParams: array of Variant): Integer;
var
  LItem: TQuickFilter;
  i: Integer;
begin
  if FPanelQuickFilter = nil then
  begin
    FPanelQuickFilter := TPanel.Create(PanelHeader);
    FPanelQuickFilter.Parent := PanelHeader;
    FPanelQuickFilter.Align := alRight;
    FPanelQuickFilter.BevelOuter := bvNone;
    FPanelQuickFilter.ParentColor := True;
  end;

  LItem := TQuickFilter.Create;
  LItem.Sql := Trim(ASql);
  SetLength(LItem.Params, Length(AParams));
  for i := 0 to High(AParams) do
    LItem.Params[i] := AParams[i];
  Result := FQuickFilters.Add(LItem);

  LItem.Button := TRadioButton.Create(FPanelQuickFilter);
  LItem.Button.Parent := FPanelQuickFilter;
  LItem.Button.Left := 10000 + Result * 10;   // alLeft sırası eklenme sırası
  LItem.Button.Align := alLeft;
  LItem.Button.AlignWithMargins := True;
  LItem.Button.Margins.SetBounds(6, 3, 2, 3);
  LItem.Button.Caption := ACaption;
  LItem.Button.Tag := Result;
  LItem.Button.TabStop := False;
  if Result = 0 then
  begin
    // OnClick henüz bağlı değil: Checked ataması sorgu açtırmaz
    LItem.Button.Checked := True;
    FQuickFilterIndex := 0;
    SetQuickCondition(LItem.Sql, LItem.Params);
  end;
  LItem.Button.OnClick := QuickFilterClick;
  LayoutQuickFilters;
end;

procedure TfrmGrid<TE, TS>.SetQuickFilterCaption(AIndex: Integer; const ACaption: string);
begin
  if (AIndex < 0) or (AIndex >= FQuickFilters.Count) then
    Exit;
  FQuickFilters[AIndex].Button.Caption := ACaption;
  LayoutQuickFilters;
end;

procedure TfrmGrid<TE, TS>.SelectQuickFilter(AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= FQuickFilters.Count) or (AIndex = FQuickFilterIndex) then
    Exit;
  FQuickFilterIndex := AIndex;
  FQuickFilterUpdating := True;
  try
    FQuickFilters[AIndex].Button.Checked := True;
  finally
    FQuickFilterUpdating := False;
  end;
  SetQuickCondition(FQuickFilters[AIndex].Sql, FQuickFilters[AIndex].Params);
end;

procedure TfrmGrid<TE, TS>.QuickFilterClick(Sender: TObject);
begin
  if FQuickFilterUpdating or not (Sender is TRadioButton) or not TRadioButton(Sender).Checked then
    Exit;
  SelectQuickFilter(TRadioButton(Sender).Tag);
  if Grd.CanFocus then
    Grd.SetFocus;
end;

// Düğme genişliği metne göre (dil değişince de); panel düğmelerin toplamı kadar
procedure TfrmGrid<TE, TS>.LayoutQuickFilters;
var
  LItem: TQuickFilter;
  LWidth: Integer;
begin
  if FPanelQuickFilter = nil then
    Exit;
  Canvas.Font.Assign(FPanelQuickFilter.Font);
  LWidth := 6;
  for LItem in FQuickFilters do
  begin
    LItem.Button.Width := Canvas.TextWidth(LItem.Button.Caption) + 24;
    Inc(LWidth, LItem.Button.Width + LItem.Button.Margins.Left + LItem.Button.Margins.Right);
  end;
  FPanelQuickFilter.Width := LWidth;
end;

function TfrmGrid<TE, TS>.GetQuickFilterCount: Integer;
begin
  Result := FQuickFilters.Count;
end;

end.

