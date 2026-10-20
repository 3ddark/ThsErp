unit ufrmGridBase;

// Liste ekranlarının tipten bağımsız tabanı. TfrmGrid<TE, TS> yalnız Service / Table köprüsünü ekler;
// sayfalama, hızlı filtre, alt toplam, kolon düzeni, dışa aktarım ve kolon seçici Grid.* birimlerindedir.
// Form CreateNew ile kodda kurulur (DFM yüklenmez).

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.StrUtils,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ComCtrls, Vcl.Grids,
  Vcl.ExtCtrls, Vcl.DBGrids, Vcl.Samples.Spin, Data.DB,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Option,
  Ths.Helper.Edit, LocalizationManager, SharedFormTypes, ufrmBase, UnitOfWork,
  Grid.Types, Grid.Footer, Grid.Paging, Grid.PagingBar, Grid.QuickFilter;

type
  TfrmGridBase = class(TForm, ILocalizable)
  private
    FQry: TFDQuery;
    FDataSource: TDataSource;
    FGrd: THackDBGrid;

    //for use HelperForm
    FIsHelper: Boolean;
    FDataTransfer: Boolean;
    FCleanAndClose: Boolean;

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

    FFooter: TGridFooter;
    FPager: TGridPager;
    FPagingBar: TGridPagingBar;
    FQuickBar: TGridQuickFilterBar;
    FSearchTimer: TTimer;
    FPageReload: Boolean;

    procedure PrepareForm;
    procedure CreatePanelMain;
    procedure CreatePanelHeader;
    procedure CreatePanelSidebar;
    procedure CreatePanelButtons;
    procedure CreatePanelContent;
    procedure CreateGridControl;
    procedure CreatePanelFooter;
    procedure CreateFilterEdit;
    procedure CreateBtnSpin;
    procedure CreateBtnClose;
    procedure CreateButtonAdd;
    procedure PrepareStatusBar;

    procedure FilterApply;
    procedure ApplyFilterLinesToQuery;
    procedure AddSelectedFieldFilter(const AOperator: string);
    procedure EdtFilterChange(Sender: TObject);
    procedure EdtFilterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SearchTimerTimer(Sender: TObject);

    procedure OpenPageData(AQuiet: Boolean);
    procedure UpdatePagingControls;
    procedure RestoreColumnStates(const AStates: TArray<TGridColumnState>);
    procedure ApplyQuickSqlToQuery;
    procedure PagingBarGoToPage(APageIndex: Integer);
    procedure PagingBarPageSize(APageSize: Integer);
    procedure QuickFilterSelected(AIndex: Integer);
    procedure FocusGrid;
    function HasIdField: Boolean;
    function IsConnected: Boolean;

    function GetPagingEnabled: Boolean;
    procedure SetPagingEnabled(AValue: Boolean);
    function GetPageSize: Integer;
    function GetPageIndex: Integer;
    function GetTotalCount: Int64;
    function GetQuickFilterIndex: Integer;
    function GetQuickFilterCount: Integer;
  protected
    // TfrmGrid<TE, TS> köprüsü
    function CreateGridQuery: TFDQuery; virtual; abstract;
    function GetUoW: TUnitOfWork; virtual; abstract;
    function EntityClass: TClass; virtual; abstract;
    // Seçili / son işlenen kayıt (Table.Id; yoksa 0): yenilemede o kayda konumlanılır
    function CurrentRecordId: Int64; virtual; abstract;
    function IsAuthorizedFor(APermissionType: TPermissionType): Boolean; virtual; abstract;
    // Sorgu ve veri kaynağı serbest bırakılır (servisten önce; tekrar çağrılabilir)
    procedure ReleaseGridData;
    // Filtreye uyan tüm kayıtlar (sayfa değil) üzerinde açılmış sorgu:
    // SELECT ASelectList FROM (filtreli liste SQL'i) pg_t [GROUP BY] [ORDER BY]; çağıran serbest bırakır.
    // Sayfasız modda nil.
    function OpenFilteredQuery(const ASelectList: string; const AGroupBy: string = ''; const AOrderBy: string = ''): TFDQuery;
    // Sayfa verisi ve alt toplamlar yüklendi (filtre / arama / hızlı filtre / yenileme sonrası); alt sınıf özet gösterir
    procedure FilteredDataLoaded; virtual;
  public
    property Grd: THackDBGrid read FGrd write FGrd;
    property Qry: TFDQuery read FQry write FQry;

    //for use HelperForm
    property IsHelper: Boolean read FIsHelper write FIsHelper default False;
    property DataTransfer: Boolean read FDataTransfer write FDataTransfer;
    property CleanAndClose: Boolean read FCleanAndClose write FCleanAndClose default False;

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
    property PagingEnabled: Boolean read GetPagingEnabled write SetPagingEnabled;
    property PageSize: Integer read GetPageSize;
    property PageIndex: Integer read GetPageIndex;
    property TotalCount: Int64 read GetTotalCount;
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
    property QuickFilterIndex: Integer read GetQuickFilterIndex;
    property QuickFilterCount: Integer read GetQuickFilterCount;

    constructor CreateGrid(AOwner: TComponent; ACreateNewBase, AUseHelper: Boolean);
    destructor Destroy; override;

    procedure SetSelectedItem; virtual; abstract;
    procedure ShowInputForm(Sender: TObject; AFormType: TInputFormMode); virtual; abstract;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; virtual;

    procedure MoveUp; virtual;
    procedure MoveDown; virtual;
    procedure AddFooterColumn(const AColumnFieldName: string; AAggregateType: TAggregateType; const ADisplayFormat: string = '');
    procedure DefineFooterColumns; virtual;
    procedure LoadFooterColumnsFromDB; virtual;
    procedure DefineColumnWidths; virtual;
    // Miktar / fiyat / tutar / kur kolonlarına sys_decimal_place haneleri (DefineColumnWidths'ten önce)
    procedure ApplyDecimalFormats;
    procedure SetColumnProperty(const AFieldName: string; AWidth: Integer; AColumnTitle: string = '');
    procedure SetColumnTitle(const AFieldName: string; AColumnTitle: string);
    procedure BuildFooter;
    procedure CreateFooterPanel;
    procedure UpdateFooterLayout;
    procedure PreparePopupMenu; virtual;

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

    function GetGridViewName: string; virtual;
    procedure AutoPopulateSysGridColumns(const AViewName: string); virtual;
    procedure ApplyDynamicFilterAndSort; virtual;
    procedure LoadColumnWidthsFromDB; virtual;
    procedure SaveColumnWidthsToDB; virtual;
    procedure AdjustFormWidth; virtual;

    procedure RefreshData;
    //***query***
    procedure AfterDatasetOpen(Dataset: TDataset); virtual;
    //***status bar***
    procedure RefreshStatusRecordCount;
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
    procedure mniColumnsClick(Sender: TObject); virtual;
    function GridTableName: string;

    //***footer button events***
    procedure BtnSpinDownClick(Sender: TObject); virtual;
    procedure BtnSpinUpClick(Sender: TObject); virtual;
    procedure BtnCloseClick(Sender: TObject); virtual;
    procedure BtnAddClick(Sender: TObject); virtual;
    // Yetkisi olmayan işlemler UI'da baştan pasif; backend (Business*) yine kontrol eder
    procedure ApplyPermissionState; virtual;

    procedure RefreshParentGrid(AFocusSelectedItem: Boolean);

    /// <summary>
    /// Grid sorgusuna kalıcı eşitlik filtresi ekler (ör. seçili şablonun hakları).
    /// Form gösterilmeden (FormShow / Open öncesi) çağrılmalıdır.
    /// </summary>
    procedure AddFixedFilter(const AFieldName: string; const AValue: Variant);
  end;

implementation

uses
  Vcl.Clipbrd, FireDAC.Stan.Param, udm, Ths.Constants, Ths.Globals, Logger, AppContext, EntitySchemaCache,
  Grid.Sql, Grid.Columns, Grid.Export, Grid.ColumnSelector, Db.ErrorTranslator, SysDecimalPlace.Cache;

{ TfrmGridBase - kurulum }

constructor TfrmGridBase.CreateGrid(AOwner: TComponent; ACreateNewBase, AUseHelper: Boolean);
begin
  if ACreateNewBase then
    CreateNew(AOwner);

  GLogger.InfoFmt('Open Grid Form %s: %s %s', [IfThen(AUseHelper, 'with Helper Mode', ''), Self.ClassName, EntityClass.ClassName]);

  FIsHelper := AUseHelper;

  Self.Caption := 'Base Title';
  Self.Constraints.MinHeight := 600;

  FQry := CreateGridQuery;
  FQry.FetchOptions.Mode := fmAll;
  FQry.AfterOpen := AfterDatasetOpen;

  FDataSource := TDataSource.Create(Self);
  FDataSource.DataSet := FQry;

  FFooter := TGridFooter.Create;
  FPager := TGridPager.Create;
  FPager.PageSize := GridPageSize;

  FSearchTimer := TTimer.Create(Self);
  FSearchTimer.Enabled := False;
  FSearchTimer.Interval := 350;   // yazarken her tuşta sorgu atılmasın
  FSearchTimer.OnTimer := SearchTimerTimer;

  PrepareForm;

  DefineFooterColumns;

  Self.ActiveControl := Grd;
end;

destructor TfrmGridBase.Destroy;
begin
  ReleaseGridData;
  FreeAndNil(FQuickBar);
  FreeAndNil(FPagingBar);
  FreeAndNil(FPager);
  FreeAndNil(FFooter);
  inherited;
end;

procedure TfrmGridBase.ReleaseGridData;
begin
  // DataSource önce ayrılır (grid kapanan sorguyu çizmeye çalışmasın)
  if Assigned(FDataSource) then
    FDataSource.DataSet := nil;
  if Assigned(FQry) then
    FQry.Close;
  FreeAndNil(FQry);
  FreeAndNil(FDataSource);
end;

procedure TfrmGridBase.PrepareForm;
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

  PreparePopupMenu;

  CreatePanelMain;
    CreatePanelHeader;
      CreateFilterEdit;
    CreatePanelContent;
      CreateGridControl;
      CreatePanelButtons;
        CreateButtonAdd;
    CreatePanelSidebar;
  CreatePanelFooter;
    CreateBtnSpin;
    CreateBtnClose;
  CreateFooterPanel;

  FPagingBar := TGridPagingBar.Create(PanelFooter);
  FPagingBar.OnGoToPage := PagingBarGoToPage;
  FPagingBar.OnPageSize := PagingBarPageSize;

  FQuickBar := TGridQuickFilterBar.Create(FPanelButtons);
  FQuickBar.OnSelect := QuickFilterSelected;

  FStatusBase := TStatusBar.Create(Self);
  FStatusBase.Align := alBottom;
  FStatusBase.Parent := Self;
  FStatusBase.OnDrawPanel := StatusBarDrawPanel;
  FStatusBase.Font.Size := 8;
end;

procedure TfrmGridBase.CreatePanelMain;
begin
  PanelMain := TPanel.Create(Self);
  PanelMain.Parent := Self;
  PanelMain.Align := alClient;
  PanelMain.BevelOuter := bvNone;
  PanelMain.ParentColor := True;
  PanelMain.Visible := True;
end;

procedure TfrmGridBase.CreatePanelContent;
begin
  PanelContent := TPanel.Create(PanelMain);
  PanelContent.Parent := PanelMain;
  PanelContent.Align := alClient;
  PanelContent.BevelOuter := bvNone;
  PanelContent.ParentColor := True;
  PanelContent.Visible := True;
end;

procedure TfrmGridBase.CreatePanelHeader;
begin
  PanelHeader := TPanel.Create(PanelMain);
  PanelHeader.Parent := PanelMain;
  PanelHeader.Align := alTop;
  PanelHeader.BevelOuter := bvNone;
  PanelHeader.Height := 30;
  PanelHeader.ParentColor := True;
  PanelHeader.Visible := True;
end;

procedure TfrmGridBase.CreatePanelSidebar;
begin
  PanelSidebar := TPanel.Create(PanelMain);
  PanelSidebar.Parent := PanelMain;
  PanelSidebar.Align := alLeft;
  PanelSidebar.BevelOuter := bvNone;
  PanelSidebar.Height := 70;
  PanelSidebar.ParentColor := True;
  PanelSidebar.Visible := True;
end;

procedure TfrmGridBase.CreatePanelButtons;
begin
  FPanelButtons := TPanel.Create(PanelContent);
  FPanelButtons.Parent := PanelContent;
  FPanelButtons.Align := alBottom;
  FPanelButtons.BevelOuter := bvNone;
  FPanelButtons.Height := 70;
  FPanelButtons.ParentColor := True;
  FPanelButtons.Visible := True;
end;

procedure TfrmGridBase.CreatePanelFooter;
begin
  PanelFooter := TPanel.Create(PanelMain);
  PanelFooter.Parent := PanelMain;
  PanelFooter.Align := alBottom;
  PanelFooter.BevelOuter := bvNone;
  PanelFooter.Height := 28;
  PanelFooter.ParentColor := True;
  PanelFooter.Visible := True;
end;

procedure TfrmGridBase.CreateGridControl;
begin
  Grd := THackDBGrid.Create(PanelContent);
  Grd.Parent := PanelContent;
  Grd.Align := alClient;
  Grd.DataSource := FDataSource;
  Grd.Options := Grd.Options - [dgEditing, dgConfirmDelete];

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

procedure TfrmGridBase.CreateFilterEdit;
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

procedure TfrmGridBase.CreateBtnSpin;
begin
  BtnSpin := TSpinButton.Create(PanelFooter);
  BtnSpin.Parent := PanelFooter;
  BtnSpin.OnUpClick := BtnSpinUpClick;
  BtnSpin.OnDownClick := BtnSpinDownClick;
  BtnSpin.Align := alLeft;
  BtnSpin.Margins.Left := 8;
  BtnSpin.AlignWithMargins := True;
end;

procedure TfrmGridBase.CreateBtnClose;
begin
  BtnClose := TButton.Create(PanelFooter);
  BtnClose.Parent := PanelFooter;
  BtnClose.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.Close, 'Close');
  BtnClose.OnClick := BtnCloseClick;
  BtnClose.Align := alRight;
  BtnClose.Margins.Right := 8;
  BtnClose.AlignWithMargins := True;
end;

procedure TfrmGridBase.CreateButtonAdd;
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

procedure TfrmGridBase.CreateFooterPanel;
begin
  FFooter.CreatePanel(PanelContent);
end;

procedure TfrmGridBase.PreparePopupMenu;
begin
  GridPopMenu := TPopupMenu.Create(Self);
  mniPreview := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.Preview, 'Preview'), 'mniPreview', mniPreviewClick, True, TextToShortCut('Ctrl+Enter'));
  mniDuplicate := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.Duplicate, 'Duplicate'), 'mniDuplicate', mniDuplicateClick, False, TextToShortCut('Ctrl+D'));
  AddPopupMenuSpliter;
  mniFilter := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.Filter, 'Filter'), 'mniFilter', mniFilterClick, True, TextToShortCut('F3'));
  mniFilterExclude := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.FilterExclude, 'Filter Exclude'), 'mniFilterExclude', mniFilterExcludeClick, True, TextToShortCut('Ctrl+F3'));
  mniFilterBack := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.FilterBack, 'Filter Back'), 'mniFilterBack', mniFilterBackClick, True, TextToShortCut('Ctrl+F8'));
  mniFilterBack.Enabled := False;
  mniFilterRemove := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.FilterRemove, 'Remove Filter'), 'mniFilterRemove', mniFilterRemoveClick, True, TextToShortCut('F8'));
  mniFilterRemove.Enabled := False;
  AddPopupMenuSpliter;
  mniExportExcel := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.ExportExcel, 'Export to Excel'), 'mniExportExcel', mniExportExcelClick, True, TextToShortCut('Ctrl+E'));
  mniExportCsv := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.ExportCsv, 'Export to CSV'), 'mniExportCsv', mniExportCsvClick, True, TextToShortCut('Ctrl+Shift+E'));
  mniPrint := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.Print, 'Print'), 'mniPrint', mniPrintClick, True, TextToShortCut('Ctrl+P'));
  mniRemoveGridSort := AddMenu(TLocalizationManager.Translate(TLangKeys.TPopupMenu.RemoveSort, 'Remove Sort'), 'mniRemoveGridSort', mniRemoveSortClick);
  mniRemoveGridSort.Enabled := False;
  AddPopupMenuSpliter;
  AddMenu(TLocalizationManager.Translate('popup.columns', 'Columns'), 'mniColumns', mniColumnsClick);
  // Görünürlüğü FormShow'da: tablo işlem geçmişi tutuyorsa ve okuma yetkisi varsa
  mniRecordHistory := AddMenu(TLocalizationManager.Translate(TLangKeys.TSysAuditLog.MenuRecordHistory, 'Audit Log'),
    'mniRecordHistory', mniRecordHistoryClick, False, TextToShortCut('Ctrl+H'));
end;

function TfrmGridBase.AddMenu(ATitle, AMenuName: string; AClickEvent: TNotifyEvent; AVibisle: Boolean;
  AShortCut: TShortCut; AParentMenu: TMenuItem): TMenuItem;
begin
  if AParentMenu <> nil then
    Result := TMenuItem.Create(AParentMenu)
  else
    Result := TMenuItem.Create(Self.GridPopMenu);
  Result.Caption := ATitle;
  Result.Name := AMenuName;
  Result.ShortCut := AShortCut;
  Result.OnClick := AClickEvent;
  Result.Visible := AVibisle;
  if AParentMenu <> nil then
    AParentMenu.Add(Result)
  else
    Self.GridPopMenu.Items.Add(Result);
end;

procedure TfrmGridBase.AddPopupMenuSpliter(AParentMenu: TMenuItem);
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

{ Form olayları }

procedure TfrmGridBase.FormCreate(Sender: TObject);
begin
//
end;

procedure TfrmGridBase.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmGridBase.FormShow(Sender: TObject);
var
  LCanRead: Boolean;
begin
  // Okuma yetkisi yoksa sorgu hiç açılmaz, ekran kapanır (menü, popup, helper — hangi yoldan açılırsa)
  try
    LCanRead := IsAuthorizedFor(ptRead);
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

  if Assigned(FQry) and not FQry.Active then
  begin
    ApplyDynamicFilterAndSort;
    try
      // gövde istemci tarafı modda da saklanır: hızlı filtre koşulu bu gövdeye eklenerek sorgu yeniden açılır
      FPager.Capture(FQry);
      if FPager.Enabled then
        LoadPage(False)
      else
      begin
        if FPager.QuickSql <> '' then
          ApplyQuickSqlToQuery;
        FQry.Open;
      end;
    except
      on E: Exception do
      begin
        GLogger.ErrorFmt('Grid sorgusu açılamadı [%s]: %s', [Self.ClassName, E.Message]);
        ShowMessage(TLocalizationManager.Translate(TLangKeys.TMessage.DataIsNotLoaded, 'Data could not be loaded: ') + TDbErrorTranslator.FriendlyMessage(E));
        Exit;
      end;
    end;
  end;

  AdjustFormWidth;
  FPagingBar.Panel.Visible := IsPaged;
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

procedure TfrmGridBase.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  GLogger.InfoFmt('Close Grid Form %s: %s %s', [IfThen(FIsHelper, 'with Helper Mode', ''), Self.ClassName, EntityClass.ClassName]);
  if not FIsHelper then
    SaveColumnWidthsToDB;
  Action := caFree;
end;

procedure TfrmGridBase.ApplyLocalization;
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

  if Assigned(FPagingBar) then
    FPagingBar.ApplyLocalization;
  UpdatePagingControls;
  PrepareStatusBar;
end;

procedure TfrmGridBase.FormKeyPress(Sender: TObject; var Key: Char);
begin
//
end;

procedure TfrmGridBase.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//
end;

procedure TfrmGridBase.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) or (Key = VK_F6) then
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
    // saydamlık: 255 -> 150 -> 80 -> 255
    case Self.AlphaBlendValue of
      255:
        begin
          Self.AlphaBlend := True;
          Self.AlphaBlendValue := 150;
        end;
      150:
        Self.AlphaBlendValue := 80;
    else
      Self.AlphaBlend := False;
      Self.AlphaBlendValue := 255;
    end;
  end
  else if IsPaged and (Shift = [ssCtrl]) and (Key = VK_NEXT) then
  begin
    Key := 0;
    GoToPage(PageIndex + 1);
  end
  else if IsPaged and (Shift = [ssCtrl]) and (Key = VK_PRIOR) then
  begin
    Key := 0;
    GoToPage(PageIndex - 1);
  end
  else if (ssCtrl in Shift) and (Key = Ord('F')) then
  begin
    Key := 0;
    if EdtFilter.Focused then
      ActiveControl := Grd
    else
      ActiveControl := EdtFilter;
  end;
end;

{ Grid olayları }

procedure TfrmGridBase.grdCellClick(Column: TColumn);
begin
//
end;

procedure TfrmGridBase.grdKeyPress(Sender: TObject; var Key: Char);
begin
//
end;

procedure TfrmGridBase.grdKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//
end;

procedure TfrmGridBase.grdMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
//
end;

procedure TfrmGridBase.grdColumnMoved(Sender: TObject; FromIndex, ToIndex: Integer);
begin
  UpdateFooterLayout;
end;

procedure TfrmGridBase.GridColWidthsChanged(Sender: TObject);
begin
  UpdateFooterLayout;
end;

procedure TfrmGridBase.grdDblClick(Sender: TObject);
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

procedure TfrmGridBase.grdTitleClick(Column: TColumn);
begin
  SortGridTitle(Column);
end;

procedure TfrmGridBase.grdDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
const
  COLOR_ACTIVE = 9539955;
  COLOR_EVEN = 12189695;
  COLOR_ODD = 13158655;
  CHECK_STATE: array[Boolean] of Integer = (DFCS_BUTTONCHECK, DFCS_BUTTONCHECK or DFCS_CHECKED);
var
  LGrid: THackDBGrid;
  LBmp: TBitmap;
begin
  LGrid := THackDBGrid(Sender);
  // aktif satır / çift-tek satır renkleri
  if LGrid.ActiveRecord = LGrid.Row - 1 then
    LGrid.Canvas.Brush.Color := COLOR_ACTIVE
  else if LGrid.DataSource.DataSet.RecNo mod 2 = 0 then
    LGrid.Canvas.Brush.Color := COLOR_EVEN
  else
    LGrid.Canvas.Brush.Color := COLOR_ODD;

  LGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);

  if Column.Field = nil then
    Exit;
  if Column.Field.DataType = ftBoolean then
  begin
    LGrid.Canvas.FillRect(Rect);
    if Column.Field.IsNull then
      DrawFrameControl(LGrid.Canvas.Handle, Rect, DFC_BUTTON, DFCS_BUTTONCHECK or DFCS_INACTIVE)
    else
      DrawFrameControl(LGrid.Canvas.Handle, Rect, DFC_BUTTON, CHECK_STATE[Column.Field.AsBoolean]);
  end
  else if Column.Field is TGraphicField then
  begin
    LBmp := TBitmap.Create;
    try
      LBmp.Assign(Column.Field);
      LGrid.Canvas.StretchDraw(Rect, LBmp);
    finally
      LBmp.Free;
    end;
  end;
end;

procedure TfrmGridBase.grdKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if not (Sender is THackDBGrid) or not THackDBGrid(Sender).Focused then
    Exit;

  // Ctrl+Shift+C: satırın ilk alanı, Ctrl+C: seçili hücre panoya
  if (Shift = [ssCtrl, ssShift]) and (Key = Ord('C')) then
  begin
    Clipboard.Clear;
    Clipboard.SetTextBuf(PWideChar(Grd.DataSource.DataSet.Fields.Fields[0].AsString + sLineBreak));
  end
  else if Shift = [ssCtrl] then
  begin
    if Key = VK_DELETE then
      Key := 0
    else if (Key = Ord('C')) and (Grd.SelectedField <> nil) then
    begin
      Clipboard.Clear;
      Clipboard.SetTextBuf(PWideChar(Grd.SelectedField.AsString + sLineBreak));
    end;
  end;
end;

procedure TfrmGridBase.SortGridTitle(Sender: TObject);
var
  LCurrent, LOrder: string;
begin
  if not (Sender is TColumn) then
    Exit;

  if IsPaged then
    LCurrent := FPager.SortFields
  else
    LCurrent := FQry.IndexFieldNames;
  LOrder := ToggleSortFields(LCurrent, TColumn(Sender).FieldName, isCtrlDown);

  mniRemoveGridSort.Visible := True;
  mniRemoveGridSort.Enabled := True;

  // Sayfalı mod: sıralama sunucuda (tüm kayıtlar), ilk sayfadan başlanır
  if IsPaged then
  begin
    FPager.SortFields := LOrder;
    FPager.PageIndex := 0;
    LoadPage(True);
  end
  else
    FQry.IndexFieldNames := LOrder;

  Grd.InvalidateTitleRow;
end;

{ Dataset / yenileme }

procedure TfrmGridBase.AfterDatasetOpen(Dataset: TDataset);
begin
  // Sayfa değişimi: kolon düzeni LoadPage içinde kullanıcının o anki hâline geri yüklenir
  if FPageReload then
    Exit;

  Grd.Columns.RestoreDefaults;
  TGridColumns.SetTitleStyle(Grd);

  ApplyDecimalFormats;
  DefineColumnWidths;         // subclass'ın kod tanımlı genişlikleri
  LoadColumnWidthsFromDB;     // DB'deki kayıtlı genişlikler (önceliklidir)
  AdjustFormWidth;
  RefreshStatusRecordCount;
end;

procedure TfrmGridBase.RefreshData;
begin
  if not Assigned(FQry) or not FQry.Active then
    Exit;

  mniFilterRemove.Enabled := FPager.FilterLines.Count > 0;
  mniFilterBack.Enabled := mniFilterRemove.Enabled;

  // Sayfalı mod: veri yeniden okunur (toplu işlem sonrası da güncel), seçili kayda konumlanır
  if IsPaged then
  begin
    LoadPage(True, CurrentRecordId);
    Exit;
  end;

  if CurrentRecordId > 0 then
    FQry.Locate('id', CurrentRecordId, []);
  ApplyFilterLinesToQuery;
  RefreshStatusRecordCount;
end;

procedure TfrmGridBase.RefreshParentGrid(AFocusSelectedItem: Boolean);
begin
  if not Assigned(FQry) then
    Exit;

  // Sayfalı mod: kayıt (yeni eklenen dahil) hangi sayfadaysa oraya gidilir; kolon düzeni korunur
  if IsPaged then
  begin
    if AFocusSelectedItem then
      LoadPage(True, CurrentRecordId)
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
    if AFocusSelectedItem and (CurrentRecordId > 0) then
      FQry.Locate('id', CurrentRecordId, []);
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

procedure TfrmGridBase.AddFixedFilter(const AFieldName: string; const AValue: Variant);
var
  LParamName: string;
begin
  if not Assigned(FQry) then
    Exit;
  if FQry.Active then
    FQry.Close;

  LParamName := 'fixed_' + AFieldName;
  FQry.SQL.Text := AddWhereCondition(FQry.SQL.Text, AFieldName + ' = :' + LParamName);
  FQry.ParamByName(LParamName).Value := AValue;
end;

function TfrmGridBase.HasIdField: Boolean;
begin
  Result := Assigned(FQry) and (FQry.FindField('id') <> nil);
end;

function TfrmGridBase.IsConnected: Boolean;
var
  LUoW: TUnitOfWork;
begin
  LUoW := GetUoW;
  Result := Assigned(LUoW) and (LUoW.Connection <> nil) and LUoW.Connection.Connected;
end;

procedure TfrmGridBase.FocusGrid;
begin
  if Grd.CanFocus then
    Grd.SetFocus;
end;

{ Popup filtre (Filtrele / Hariç tut / Geri al / Kaldır) }

procedure TfrmGridBase.AddSelectedFieldFilter(const AOperator: string);
begin
  FPager.AddFilter(FieldFilterExpression(Grd.SelectedField, AOperator, IsPaged));
end;

procedure TfrmGridBase.ApplyFilterLinesToQuery;
begin
  FQry.Filtered := False;
  FQry.Filter := FPager.FilterLines.Text;
  FQry.Filtered := FQry.Filter <> '';
  mniFilterRemove.Enabled := FQry.Filter <> '';
  mniFilterBack.Enabled := mniFilterRemove.Enabled;
end;

procedure TfrmGridBase.FilterApply;
begin
  if IsPaged then
  begin
    mniFilterRemove.Enabled := FPager.FilterLines.Count > 0;
    mniFilterBack.Enabled := mniFilterRemove.Enabled;
    FPager.PageIndex := 0;
    LoadPage(True);
    Exit;
  end;

  ApplyFilterLinesToQuery;
  RefreshStatusRecordCount;
end;

procedure TfrmGridBase.mniFilterClick(Sender: TObject);
begin
  AddSelectedFieldFilter('=');
  FilterApply;
end;

procedure TfrmGridBase.mniFilterExcludeClick(Sender: TObject);
begin
  AddSelectedFieldFilter('<>');
  FilterApply;
end;

procedure TfrmGridBase.mniFilterBackClick(Sender: TObject);
begin
  if FPager.FilterLines.Count > 0 then
  begin
    FPager.FilterLines.Delete(FPager.FilterLines.Count - 1);
    FilterApply;
  end;
end;

procedure TfrmGridBase.mniFilterRemoveClick(Sender: TObject);
begin
  if FPager.FilterLines.Count > 0 then
  begin
    FPager.FilterLines.Clear;
    FilterApply;
  end;
end;

{ Hızlı arama (filtre kutusu) }

procedure TfrmGridBase.EdtFilterChange(Sender: TObject);
var
  LFilter: string;
begin
  // Sayfalı mod: arama SQL ile, yazma durunca (zamanlayıcı) çalışır
  if IsPaged then
  begin
    FSearchTimer.Enabled := False;
    FSearchTimer.Enabled := True;
    Exit;
  end;

  FQry.Filtered := False;
  FQry.Filter := '';
  LFilter := BuildClientSearchFilter(Grd.Columns, EdtFilter.Text);
  if LFilter <> '' then
  begin
    FQry.Filter := LFilter;
    FQry.Filtered := True;
  end;
  RefreshStatusRecordCount;
end;

procedure TfrmGridBase.EdtFilterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
      begin
        // yazılan ama henüz uygulanmamış arama önce çalışsın (helper doğru satırı seçsin)
        FlushPendingSearch;
        if FIsHelper then
        begin
          SetSelectedItem;
          DataTransfer := True;
          ModalResult := mrYes;
          Self.Close;
        end;
      end;
    VK_UP:
      begin
        Key := 0;
        BtnSpinUpClick(BtnSpin);
      end;
    VK_DOWN:
      begin
        Key := 0;
        BtnSpinDownClick(BtnSpin);
      end;
    VK_PRIOR, VK_NEXT:
      begin
        SendMessage(Grd.Handle, WM_KEYDOWN, Key, MapVirtualKey(Key, MAPVK_VK_TO_VSC) shl 16 or 1);
        Key := 0;
      end;
  end;
end;

procedure TfrmGridBase.SearchTimerTimer(Sender: TObject);
var
  LText: string;
begin
  FSearchTimer.Enabled := False;
  if not IsPaged then
    Exit;
  LText := Trim(EdtFilter.Text);
  FPager.SetSearch(LText, BuildSearchSql(Grd.Columns, LText));
  FPager.PageIndex := 0;
  LoadPage(True);
end;

procedure TfrmGridBase.FlushPendingSearch;
begin
  if IsPaged and FSearchTimer.Enabled then
    SearchTimerTimer(FSearchTimer);
end;

{ Sayfalama }

function TfrmGridBase.IsPaged: Boolean;
begin
  Result := FPager.IsPaged;
end;

function TfrmGridBase.GetPagingEnabled: Boolean;
begin
  Result := FPager.Enabled;
end;

procedure TfrmGridBase.SetPagingEnabled(AValue: Boolean);
begin
  FPager.Enabled := AValue;
end;

function TfrmGridBase.GetPageSize: Integer;
begin
  Result := FPager.PageSize;
end;

function TfrmGridBase.GetPageIndex: Integer;
begin
  Result := FPager.PageIndex;
end;

function TfrmGridBase.GetTotalCount: Int64;
begin
  Result := FPager.TotalCount;
end;

procedure TfrmGridBase.UpdatePagingControls;
begin
  if Assigned(FPagingBar) then
    FPagingBar.Update(FPager.PageIndex, FPager.PageCount, FPager.PageSize, FPager.TotalCount);
end;

procedure TfrmGridBase.OpenPageData(AQuiet: Boolean);
begin
  // AQuiet: kolonlar varsayılana dönmesin, AfterDatasetOpen (DB'den genişlik, form genişliği) çalışmasın
  FPageReload := AQuiet;
  if AQuiet then
    FQry.DisableControls;
  try
    FQry.Close;
    FQry.SQL.Text := FPager.PageSql;
    FPager.ApplyParams(FQry);
    FQry.Open;
  finally
    if AQuiet then
      FQry.EnableControls;
    FPageReload := False;
  end;
end;

procedure TfrmGridBase.LoadPage(AKeepLayout: Boolean; AFocusId: Int64);
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
      LStates := TGridColumns.SaveStates(Grd)
    else
      LStates := nil;

    OpenPageData(LQuiet);
    FPager.LoadTotals(FQry.Connection, FQry, FFooter);
    FilteredDataLoaded;

    // Kayıt silinip sayfa sayısı azaldıysa son sayfa; odaklanacak kayıt başka sayfadaysa o sayfa
    LPage := FPager.PageIndex;
    if LPage > FPager.PageCount - 1 then
      LPage := FPager.PageCount - 1;
    if (AFocusId > 0) and (FPager.PageSize > 0) and HasIdField and not FQry.Locate('id', AFocusId, []) then
    begin
      LFocusPage := FPager.FindPageOfId(FQry.Connection, AFocusId);
      if LFocusPage >= 0 then
        LPage := LFocusPage;
    end;
    if LPage <> FPager.PageIndex then
    begin
      FPager.PageIndex := LPage;
      OpenPageData(LQuiet);
    end;
    if (AFocusId > 0) and HasIdField then
      FQry.Locate('id', AFocusId, []);

    if LQuiet then
      RestoreColumnStates(LStates);
  finally
    Screen.Cursor := LCursor;
  end;

  UpdatePagingControls;
  RefreshStatusRecordCount;
end;

procedure TfrmGridBase.RestoreColumnStates(const AStates: TArray<TGridColumnState>);
begin
  TGridColumns.SetTitleStyle(Grd);
  // yeniden oluşan alanlara alan olayları (OnGetText vb.) yeniden bağlansın
  ApplyDecimalFormats;
  DefineColumnWidths;
  TGridColumns.RestoreStates(Grd, AStates);
  UpdateFooterLayout;
end;

procedure TfrmGridBase.GoToPage(AIndex: Integer);
begin
  if not IsPaged then
    Exit;
  if AIndex > FPager.PageCount - 1 then
    AIndex := FPager.PageCount - 1;
  if AIndex < 0 then
    AIndex := 0;
  if AIndex = FPager.PageIndex then
  begin
    UpdatePagingControls;
    Exit;
  end;
  FPager.PageIndex := AIndex;
  LoadPage(True);
end;

procedure TfrmGridBase.ChangePageSize(AValue: Integer; ASaveSetting: Boolean);
begin
  if AValue < 0 then
    AValue := 0;
  if ASaveSetting then
    SetGridPageSize(AValue);
  if AValue = FPager.PageSize then
    Exit;

  FPager.ChangePageSize(AValue);
  if IsPaged then
    LoadPage(True)
  else
    UpdatePagingControls;
end;

procedure TfrmGridBase.PagingBarGoToPage(APageIndex: Integer);
begin
  GoToPage(APageIndex);
  FocusGrid;
end;

procedure TfrmGridBase.PagingBarPageSize(APageSize: Integer);
begin
  ChangePageSize(APageSize);
  FocusGrid;
end;

{ Hızlı filtre (radyo düğmeleri) }

// İstemci tarafı mod: gövde + hızlı filtre koşulu + taban sıralama (sorgu kapalı bırakılır)
procedure TfrmGridBase.ApplyQuickSqlToQuery;
begin
  FQry.Close;
  FQry.SQL.Text := FPager.ClientSql;
  FPager.ApplyParams(FQry);
end;

procedure TfrmGridBase.SetQuickCondition(const ASql: string; const AParams: array of Variant);
begin
  FPager.SetQuickCondition(ASql, AParams);

  // FormShow henüz çalışmadıysa ilk açılışta uygulanır
  if not FPager.Ready or not Assigned(FQry) or not FQry.Active then
    Exit;

  FPager.PageIndex := 0;
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

function TfrmGridBase.AddQuickFilter(const ACaption, ASql: string; const AParams: array of Variant): Integer;
begin
  Result := FQuickBar.Add(ACaption, ASql, AParams);
  if Result = 0 then
    SetQuickCondition(FQuickBar[0].Sql, FQuickBar[0].Params);
end;

procedure TfrmGridBase.SetQuickFilterCaption(AIndex: Integer; const ACaption: string);
begin
  FQuickBar.SetCaption(AIndex, ACaption);
end;

procedure TfrmGridBase.SelectQuickFilter(AIndex: Integer);
begin
  if FQuickBar.Check(AIndex) then
    SetQuickCondition(FQuickBar[AIndex].Sql, FQuickBar[AIndex].Params);
end;

procedure TfrmGridBase.QuickFilterSelected(AIndex: Integer);
begin
  SelectQuickFilter(AIndex);
  FocusGrid;
end;

function TfrmGridBase.GetQuickFilterIndex: Integer;
begin
  Result := FQuickBar.ItemIndex;
end;

function TfrmGridBase.GetQuickFilterCount: Integer;
begin
  Result := FQuickBar.Count;
end;

{ Alt toplamlar }

procedure TfrmGridBase.AddFooterColumn(const AColumnFieldName: string; AAggregateType: TAggregateType; const ADisplayFormat: string);
begin
  FFooter.Add(AColumnFieldName, AAggregateType, ADisplayFormat);
end;

procedure TfrmGridBase.DefineFooterColumns;
begin
//
end;

procedure TfrmGridBase.LoadFooterColumnsFromDB;
begin
  FFooter.LoadFromDB(GetUoW, GetGridViewName);
end;

procedure TfrmGridBase.BuildFooter;
begin
  FFooter.Build(FQry, FPager.Enabled);
end;

procedure TfrmGridBase.UpdateFooterLayout;
begin
  if Assigned(FFooter) and Assigned(Grd) then
    FFooter.UpdateLayout(Grd, FPager.Enabled);
end;

{ Kolonlar }

procedure TfrmGridBase.DefineColumnWidths;
begin
//
end;

function TfrmGridBase.OpenFilteredQuery(const ASelectList, AGroupBy, AOrderBy: string): TFDQuery;
var
  LSql: string;
begin
  Result := nil;
  if not IsPaged or not Assigned(FQry) then
    Exit;
  LSql := 'SELECT ' + ASelectList + ' FROM (' + FPager.FilteredSql + ') pg_t';
  if AGroupBy <> '' then
    LSql := LSql + ' GROUP BY ' + AGroupBy;
  if AOrderBy <> '' then
    LSql := LSql + ' ORDER BY ' + AOrderBy;
  Result := FPager.CreateQuery(FQry.Connection, LSql);
  try
    Result.Open;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

procedure TfrmGridBase.FilteredDataLoaded;
begin
//
end;

procedure TfrmGridBase.ApplyDecimalFormats;
var
  LDataSet: TDataSet;
  i, LDigits: Integer;
begin
  if not Assigned(Grd.DataSource) or not Assigned(Grd.DataSource.DataSet) then
    Exit;
  LDataSet := Grd.DataSource.DataSet;
  for i := 0 to LDataSet.Fields.Count - 1 do
    if LDataSet.Fields[i] is TNumericField then
    begin
      LDigits := TDecimalPlaces.DigitsForField(GetGridViewName, LDataSet.Fields[i].FieldName);
      if LDigits >= 0 then
        TNumericField(LDataSet.Fields[i]).DisplayFormat := TDecimalPlaces.DisplayFormat(LDigits);
    end;
end;

procedure TfrmGridBase.SetColumnProperty(const AFieldName: string; AWidth: Integer; AColumnTitle: string);
begin
  TGridColumns.SetColumnProperty(Grd, AFieldName, AWidth, AColumnTitle);
end;

procedure TfrmGridBase.SetColumnTitle(const AFieldName: string; AColumnTitle: string);
begin
  TGridColumns.SetColumnTitle(Grd, AFieldName, AColumnTitle);
end;

function TfrmGridBase.GetGridViewName: string;
begin
  Result := '';
  if Assigned(FQry) and (FQry.SQL.Count > 0) then
    Result := ExtractViewName(FQry.SQL.Text);
end;

procedure TfrmGridBase.AutoPopulateSysGridColumns(const AViewName: string);
begin
  TGridColumns.AutoPopulate(GetUoW, AViewName, Grd);
end;

procedure TfrmGridBase.ApplyDynamicFilterAndSort;
var
  LSql: string;
begin
  LSql := TGridColumns.ApplyFilterAndSort(GetUoW, GetGridViewName, FQry.SQL.Text);
  if LSql <> FQry.SQL.Text then
    FQry.SQL.Text := LSql;
end;

procedure TfrmGridBase.LoadColumnWidthsFromDB;
begin
  TGridColumns.LoadLayout(GetUoW, GetGridViewName, Grd);
end;

procedure TfrmGridBase.SaveColumnWidthsToDB;
begin
  TGridColumns.SaveUserLayout(GetUoW, GetGridViewName, Grd);
end;

procedure TfrmGridBase.AdjustFormWidth;
var
  LTotalWidth: Integer;
begin
  LTotalWidth := TGridColumns.VisibleWidth(Grd) + (Self.Width - Self.ClientWidth) + 30;
  if (Self.Constraints.MinWidth > 0) and (LTotalWidth < Self.Constraints.MinWidth) then
    LTotalWidth := Self.Constraints.MinWidth;
  if (Self.Constraints.MaxWidth > 0) and (LTotalWidth > Self.Constraints.MaxWidth) then
    LTotalWidth := Self.Constraints.MaxWidth;
  Self.Width := LTotalWidth;
end;

procedure TfrmGridBase.mniColumnsClick(Sender: TObject);
begin
  if TfrmColumnSelector.Execute(Self, Grd) then
  begin
    AdjustFormWidth;
    SaveColumnWidthsToDB;
  end;
end;

{ Durum çubuğu }

procedure TfrmGridBase.StatusBarAddPanel(AWidth: Integer; AStyle: TStatusPanelStyle);
var
  LPanel: TStatusPanel;
begin
  LPanel := FStatusBase.Panels.Add;
  LPanel.Width := AWidth;
  LPanel.Style := AStyle;
end;

procedure TfrmGridBase.PrepareStatusBar;
var
  i: Integer;
  LConnected: Boolean;
begin
  if FStatusBase.Panels.Count = 0 then
    for i := DB_STATUS_RECORD_COUNT to DB_STATUS_KEY_F11 do
      StatusBarAddPanel(80, psOwnerDraw);

  LConnected := IsConnected;
  if LConnected then
    FStatusBase.Panels[DB_STATUS_SQL_SERVER].Text := GetUoW.Connection.Params.Values['Server'];
  FStatusBase.Panels[DB_STATUS_PERIOD].Text := TLocalizationManager.Translate(TLangKeys.TGeneral.Period, 'Period') + ':2025';
  if Assigned(TAppContext.Instance.CurrentUser) then
    FStatusBase.Panels[DB_STATUS_USER].Text := TAppContext.Instance.CurrentUser.GetUsername;
  FStatusBase.Panels[DB_STATUS_KEY_F6].Text := TLocalizationManager.Translate(TLangKeys.TGeneral.KeyF6, 'F6 Cancel / Close');
  FStatusBase.Panels[DB_STATUS_KEY_F7].Text := TLocalizationManager.Translate(TLangKeys.TGeneral.KeyF7, 'F7 Add Record');
  FStatusBase.Panels[DB_STATUS_KEY_F11].Text := TLocalizationManager.Translate(TLangKeys.TGeneral.KeyF11, 'F11 Transparency');

  if LConnected then
    RefreshStatusRecordCount;
end;

procedure TfrmGridBase.RefreshStatusRecordCount;
var
  LCount: Int64;
begin
  if FStatusBase.Panels.Count > DB_STATUS_RECORD_COUNT then
  begin
    // Sayfalı modda filtreye uyan toplam kayıt (yalnız ekrandaki sayfa değil)
    if IsPaged then
      LCount := FPager.TotalCount
    else if Assigned(FQry) and FQry.Active then
      LCount := FQry.RecordCount
    else
      LCount := 0;
    FStatusBase.Panels[DB_STATUS_RECORD_COUNT].Text :=
      Format(TLocalizationManager.Translate(TLangKeys.TGeneral.RecordsCount, 'Records: %d'), [LCount]);
  end;
  UpdateFooterLayout;
end;

procedure TfrmGridBase.StatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
var
  LIcon: Integer;
begin
  FStatusBase.Canvas.Font.Name := DefaultFontName;
  FStatusBase.Canvas.Font.Style := [fsBold];

  FStatusBase.Canvas.TextRect(Rect,
    Rect.Left + dm.il16.Width + 2,
    Rect.Top + (FStatusBase.Height - Canvas.TextHeight(Panel.Text)) div 2 - 1,
    Panel.Text);

  case Panel.Index of
    DB_STATUS_RECORD_COUNT: LIcon := IMG_SUM;
    DB_STATUS_SQL_SERVER: LIcon := IMG_SERVER;
    DB_STATUS_PERIOD: LIcon := IMG_CALENDAR;
    DB_STATUS_USER: LIcon := IMG_USER_HE;
    DB_STATUS_KEY_F6, DB_STATUS_KEY_F7, DB_STATUS_KEY_F11: LIcon := IMG_FAVORITE;
  else
    LIcon := -1;
  end;

  if LIcon > -1 then
  begin
    dm.il16.Draw(StatusBar.Canvas, Rect.Left, Rect.Top, LIcon);
    Panel.Width := FStatusBase.Canvas.TextWidth(Panel.Text) + dm.il16.Width + 8;
  end;
end;

{ Kayıt işlemleri / popup }

function TfrmGridBase.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
end;

procedure TfrmGridBase.ApplyPermissionState;
var
  LCanAdd: Boolean;
begin
  try
    LCanAdd := IsAuthorizedFor(ptAddRecord);
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

procedure TfrmGridBase.BtnCloseClick(Sender: TObject);
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

procedure TfrmGridBase.BtnAddClick(Sender: TObject);
begin
  ShowInputForm(Sender, ifmNewRecord);
end;

procedure TfrmGridBase.BtnSpinDownClick(Sender: TObject);
begin
  MoveDown;
end;

procedure TfrmGridBase.BtnSpinUpClick(Sender: TObject);
begin
  MoveUp;
end;

procedure TfrmGridBase.MoveDown;
begin
  Grd.DataSource.DataSet.Next;
  SetSelectedItem;
end;

procedure TfrmGridBase.MoveUp;
begin
  Grd.DataSource.DataSet.Prior;
  SetSelectedItem;
end;

procedure TfrmGridBase.mniPreviewClick(Sender: TObject);
begin
  if not mniPreview.Visible or (Grd.DataSource.DataSet.RecordCount = 0) then
    Exit;
  SetSelectedItem;
  if FIsHelper then
  begin
    DataTransfer := True;
    ModalResult := mrYes;
    Self.Close;
  end
  else
    ShowInputForm(mniPreview, ifmRewiev);
end;

procedure TfrmGridBase.mniDuplicateClick(Sender: TObject);
begin
  if not mniDuplicate.Visible or (Grd.DataSource.DataSet.RecordCount = 0) then
    Exit;
  SetSelectedItem;
  ShowInputForm(mniDuplicate, ifmCopyNewRecord);
end;

procedure TfrmGridBase.mniPrintClick(Sender: TObject);
begin
  ShowMessage('not implemented yet!' + sLineBreak + 'Print');
end;

procedure TfrmGridBase.mniRemoveSortClick(Sender: TObject);
begin
  if IsPaged then
  begin
    if FPager.SortFields <> '' then
    begin
      FPager.SortFields := '';
      FPager.PageIndex := 0;
      LoadPage(True);
    end;
    Grd.InvalidateTitleRow;
  end
  else if FQry.IndexFieldNames <> '' then
    FQry.IndexFieldNames := '';
  mniRemoveGridSort.Enabled := False;
end;

function TfrmGridBase.GridTableName: string;
begin
  Result := TEntitySchemaCache.GetSchema(EntityClass).TableName;
end;

procedure TfrmGridBase.mniRecordHistoryClick(Sender: TObject);
var
  LRowId: Int64;
begin
  if not Assigned(GRecordHistoryShow) or not Assigned(FQry) or not FQry.Active or FQry.IsEmpty or not HasIdField then
    Exit;
  LRowId := FQry.FieldByName('id').AsLargeInt;
  GRecordHistoryShow(Self, GridTableName, LRowId, Self.Caption + ' #' + LRowId.ToString);
end;

{ Dışa aktarım }

function TfrmGridBase.CollectVisibleIds: TArray<Int64>;
var
  LBookmark: TBookmark;
  LIds: TArray<Int64>;
  LCount: Integer;
  LQ: TFDQuery;

  procedure AddId(AId: Int64);
  begin
    if LCount = Length(LIds) then
      SetLength(LIds, LCount * 2 + 64);
    LIds[LCount] := AId;
    Inc(LCount);
  end;

begin
  LCount := 0;
  LIds := nil;
  // Sayfalı mod: yalnız ekrandaki sayfa değil, filtreye uyan tüm kayıtlar
  if IsPaged then
  begin
    LQ := FPager.CreateQuery(FQry.Connection, 'SELECT pg_x.id FROM (' + FPager.FilteredSql + ') pg_x');
    try
      LQ.Open;
      while not LQ.Eof do
      begin
        AddId(LQ.Fields[0].AsLargeInt);
        LQ.Next;
      end;
    finally
      LQ.Free;
    end;
  end
  else if Assigned(FQry) and FQry.Active and HasIdField then
  begin
    FQry.DisableControls;
    try
      LBookmark := FQry.GetBookmark;
      try
        FQry.First;
        while not FQry.Eof do
        begin
          AddId(FQry.FieldByName('id').AsLargeInt);
          FQry.Next;
        end;
      finally
        if FQry.BookmarkValid(LBookmark) then
          FQry.GotoBookmark(LBookmark);
        FQry.FreeBookmark(LBookmark);
      end;
    finally
      FQry.EnableControls;
    end;
  end;
  SetLength(LIds, LCount);
  Result := LIds;
end;

procedure TfrmGridBase.mniExportExcelClick(Sender: TObject);
var
  LSavePath, LTableName, LSql, LWhere: string;
  LIds: TArray<Int64>;
  LPos: Integer;
begin
  if not Assigned(FQry) or not FQry.Active then
  begin
    ShowMessage(TLocalizationManager.Translate('msg.no_data_to_export', 'No data found to export.'));
    Exit;
  end;

  LSavePath := GetDialogSave(GetGridViewName + '.xlsx', TLocalizationManager.Translate('dialog.excel_filter', 'Excel Files (*.xlsx)|*.xlsx'));
  if LSavePath = '' then
    Exit;

  LIds := CollectVisibleIds;
  if Length(LIds) = 0 then
  begin
    ShowMessage(TLocalizationManager.Translate('msg.no_records_displayed', 'No displayed records found.'));
    Exit;
  end;

  LTableName := GetGridViewName;
  if LTableName = '' then
    LTableName := 'vw_' + GridTableName;

  // LIMIT / OFFSET olmadan filtreli sorgunun koşulu
  if IsPaged then
    LSql := FPager.FilteredSql
  else
    LSql := FQry.SQL.Text;
  LWhere := '';
  LPos := Pos('WHERE', UpperCase(LSql));
  if LPos > 0 then
    LWhere := LSql.Substring(LPos - 1);

  TGridExport.ToExcel(Self, GetUoW.Connection.Params, Grd, FQry.Params, LIds, LTableName, LWhere, LSavePath);
end;

procedure TfrmGridBase.mniExportCsvClick(Sender: TObject);
var
  LFull: TFDQuery;
  LData: TDataSet;
begin
  // Sayfalı mod: filtreye uyan tüm kayıtlar ayrı sorguyla okunur
  LFull := nil;
  try
    if IsPaged then
    begin
      LFull := FPager.CreateQuery(FQry.Connection, FPager.FilteredSql + ' ORDER BY ' + FPager.OrderBy);
      LFull.Open;
      LData := LFull;
    end
    else
      LData := Grd.DataSource.DataSet;

    TGridExport.ToCsv(Grd, LData, 'export.csv');
    ShowMessage(TLocalizationManager.Translate('msg.csv_export_completed', 'CSV export completed!'));
  finally
    LFull.Free;
  end;
end;

end.
