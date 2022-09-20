﻿unit ufrmBaseDBGrid;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Types,
  System.Classes,
  System.Math,
  System.StrUtils,
  System.UITypes,
  System.Rtti,
  System.Diagnostics,
  System.TimeSpan,
  System.TypInfo,
  System.Actions,
  System.Generics.Collections,
  Vcl.ImgList,
  Vcl.Menus,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Grids,
  Vcl.DBGrids,
  Vcl.AppEvnts,
  Vcl.StdCtrls,
  Vcl.Samples.Spin,
  Vcl.Clipbrd,
  Vcl.ActnList,
  System.Win.ComObj,
  Data.DB,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Phys,
  FireDAC.Phys.Intf,
  FireDAC.Phys.PG,
  FireDAC.Phys.PGDef,
  frxClass,
  frxUtils,
  frxExportPDF,
  frxPreview,
  frxExportBaseDialog,
  frxDBSet,
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  udm,
  ufrmBase,
  ufrmBaseOutput,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SysGridKolon,
  ufrmSysGridKolon,
  Ths.Erp.Constants,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.TableDetailed,
  Ths.Erp.Database.Table.SysLisanDataIcerik,
  ufrmSysLisanDataIcerik,
  Ths.Erp.Database.Table.SysLisanGuiIcerik,
  ufrmSysLisanGuiIcerik;

type
  TSortType = (stNone, stAsc, stDesc);

type
  THackDBGrid = class(TCustomDBGrid);

type
  TColColor = record
    FieldName: string;
    MinValue: Double;
    MinColor: Integer;
    MaxValue: Double;
    MaxColor: Integer;
    EqualColor: Integer;
  end;

type
  TColPercent = record
    FieldName: string;
    MaxValue: Double;
    ColorBar: Integer;
    ColorBarBack: Integer;
    ColorBarText: Integer;
  end;

type
  TValLowHigh = (vlLow, vlHigh, vlEqual);


type
  ThreadRefresh = class(TThread)
  private
    FOwner: TForm;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TForm; ACreateSuspended: Boolean); overload;
  end;

type
  TfrmBaseDBGrid = class(TfrmBaseOutput)
    pnlButtons: TPanel;
    mniexport_excel: TMenuItem;
    mnipreview: TMenuItem;
    mniprint: TMenuItem;
    mniSeperator1: TMenuItem;
    mniSeperator2: TMenuItem;
    mnisort_remove: TMenuItem;
    mnifilter: TMenuItem;
    mnifilter_remove: TMenuItem;
    mniSeperator3: TMenuItem;
    mnicopy_record: TMenuItem;
    mniLangDataContent: TMenuItem;
    mnifilter_exclude: TMenuItem;
    mniexport_excel_all: TMenuItem;
    mniColumnTitleByLang: TMenuItem;
    mniUpdateColWidth: TMenuItem;
    mniFormTitleByLang: TMenuItem;
    mnifilter_back: TMenuItem;
    mniSeperator4: TMenuItem;
    mniColumnSummary: TMenuItem;
    frxrprtBase: TfrxReport;
    frxpdfxprtBase: TfrxPDFExport;
    frxdbdtstBase: TfrxDBDataset;
    pnlButtonRight: TPanel;
    pnlButtonLeft: TPanel;
    btnAddNew: TButton;
    edtFilterHelper: TEdit;
    lblFilterHelper: TLabel;
    mniSeperator5: TMenuItem;
    mnicopy_to_clipboard: TMenuItem;
    dlgSave: TSaveDialog;
    grd: TDBGrid;
    dsbase: TDataSource;
    qrybase: TFDQuery;
    actlstgrd: TActionList;
    actfilter_init: TAction;
    actfilter: TAction;
    actfilter_back: TAction;
    actsort: TAction;
    actsort_remove: TAction;
    actsort_init: TAction;
    actfilter_exclude: TAction;
    actfilter_remove: TAction;
    Timer1: TTimer;
    pb1: TProgressBar;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure FormResize(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure FormPaint(Sender: TObject); override;
    procedure FormKeyPress(Sender: TObject; var Key: Char); override;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;

    procedure ResizeForm(); virtual;
    function ResizeDBGrid(Sender: TObject):Integer; virtual;

    procedure btnAddNewClick(Sender: TObject);
    procedure btnSpinUpClick(Sender: TObject); override;
    procedure btnSpinDownClick(Sender: TObject); override;

    procedure DataSourceDataChange(Sender: TObject; Field: TField); virtual;
    procedure grdTitleClick(Column: TColumn);
    procedure grdCellClick(Column: TColumn);
    procedure grdColEnter(Sender: TObject);
    procedure grdColExit(Sender: TObject);
    procedure grdColumnMoved(Sender: TObject; FromIndex, ToIndex: Integer);
    procedure grdDblClick(Sender: TObject);
    procedure grdDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure grdDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure grdDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState); virtual;
    procedure grdDrawDataCell(Sender: TObject; const Rect: TRect; Field: TField; State: TGridDrawState); virtual;
    procedure grdEnter(Sender: TObject);
    procedure grdExit(Sender: TObject);
    procedure grdKeyPress(Sender: TObject; var Key: Char);
    procedure grdKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure grdKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure grdMouseLeave(Sender: TObject);
    procedure grdMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure grdMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure grdMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure grdMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure grdMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);

    procedure edtFilterHelperChange(Sender: TObject);
    procedure edtFilterHelperKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtFilterHelperKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure frxrprtBasePreview(Sender: TObject);

    procedure mnipreviewClick(Sender: TObject);
    procedure mniexport_excelClick(Sender: TObject);
    procedure mniprintClick(Sender: TObject);
    procedure mnisort_removeClick(Sender: TObject);
    procedure mnifilter_removeClick(Sender: TObject);
    procedure mnicopy_recordClick(Sender: TObject); virtual;
    procedure mniLangDataContentClick(Sender: TObject);
    procedure mniexport_excel_allClick(Sender: TObject);
    procedure mniColumnTitleByLangClick(Sender: TObject);
    procedure mniUpdateColWidthClick(Sender: TObject);
    procedure mniFormTitleByLangClick(Sender: TObject);
    procedure mniColumnSummaryClick(Sender: TObject);
    procedure mnicopy_to_clipboardClick(Sender: TObject);
    procedure pmDBPopup(Sender: TObject); virtual;
    procedure pmDBChange(Sender: TObject; Source: TMenuItem; Rebuild: Boolean); virtual;
    procedure actfilter_initExecute(Sender: TObject);
    procedure actfilterExecute(Sender: TObject);
    procedure actfilter_backExecute(Sender: TObject);
    procedure actsortExecute(Sender: TObject);
    procedure actsort_removeExecute(Sender: TObject);
    procedure actsort_initExecute(Sender: TObject);
    procedure actfilter_removeExecute(Sender: TObject);
    procedure actfilter_excludeExecute(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    //for use HelperForm
    FIsHelper: Boolean;
    FDataAktar: Boolean;

    FFilterStringFields: TStringList;
    FFilterNumericFields: TStringList;
    FFilterDateFields: TStringList;
    FFilterBoolFields: TStringList;
    FCleanAndClose: Boolean;
    FTableHelper: TTable;
    //for use HelperForm


    FColoredPercentColNames: TArray<TColPercent>;
    FPercentMaxValue: Integer;
    FColorHigh: TColor;
    FColorLow: TColor;
    FColorEqual: TColor;

    FColoredNumericColNames: TArray<TColColor>;
    FColorBar: TColor;
    FColorBarBack: TColor;
    FColorBarText: TColor;
    FColorBarTextActive: TColor;

    FStopwatch: TStopwatch;
  protected
    FQryFiltreVarsayilan,
    FQryFiltreVarsayilanKullanici,
    FQrySiralamaVarsayilan: string;
    FFiltreGrid: TStringList;

    procedure TransferToExcel(AAllColumn: Boolean = False);
    procedure TransferToExcelAll();

    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm;virtual;
    procedure DrawTriangleInRect(ARect: TRect; ASort: TSortType; AAlignment: TAlignment); virtual;
    function IsYuzdeCizimAlaniVar(pFieldName: string): Boolean; virtual;
    function IsRenkliRakamVar(pFieldName: string): Boolean; virtual;

//    procedure EventAlerterAlert(ASender: TFDCustomEventAlerter; const AEventName: string; const AArgument: Variant);
  public
    spDS: TFDStoredProc;

    //for use HelperForm
    property IsHelper: Boolean read FIsHelper write FIsHelper default False;
    property DataAktar: Boolean read FDataAktar write FDataAktar;
    property CleanAndClose: Boolean read FCleanAndClose write FCleanAndClose default False;
    property TableHelper: TTable read FTableHelper write FTableHelper;
    //for use HelperForm

    property ColoredPercentColNames: TArray<TColPercent> read FColoredPercentColNames write FColoredPercentColNames;
    property YuzdeMaxVal: Integer read FPercentMaxValue write FPercentMaxValue;
    property ColorBar: TColor read FColorBar write FColorBar;
    property ColorBarBack: TColor read FColorBarBack write FColorBarBack;
    property ColorBarText: TColor read FColorBarText write FColorBarText;
    property ColorBarTextActive: TColor read FColorBarTextActive write FColorBarTextActive;

    property ColoredNumericColNames: TArray<TColColor> read FColoredNumericColNames write FColoredNumericColNames;
    property ColorHigh: TColor read FColorHigh write FColorHigh;
    property ColorLow: TColor read FColorLow write FColorLow;
    property ColorEqual: TColor read FColorEqual write FColorEqual;
    function GetLowHighEqual(pField: TField; pDefaultColor: TColor): Integer;virtual;
    function GetPercentMaxVal(pField: TField): Double;virtual;

    property QryFiltreVarsayilan: string read FQryFiltreVarsayilan write FQryFiltreVarsayilan;
    property QryFiltreVarsayilanKullanici: string read FQryFiltreVarsayilanKullanici write FQryFiltreVarsayilanKullanici;
    property QueryDefaultOrder: string read FQrySiralamaVarsayilan write FQrySiralamaVarsayilan;
    property FiltreGrid: TStringList read FFiltreGrid write FFiltreGrid;

    constructor Create(
      AOwner: TComponent;
      AParentForm: TForm = nil;
      ATable: TTable = nil;
      AFormDecimalMode: TFormDecimalMode = fomNormal;
      AHelperForm: Boolean = False);reintroduce;overload;

    procedure RefreshDataFirst();
    procedure RefreshData();
    procedure RefreshGrid();virtual;

    procedure ShowInputForm(Sender: TObject; pFormType: TInputFormMode); virtual;
    procedure SetSelectedItem; virtual;
    procedure MoveUp();virtual;
    procedure MoveDown();virtual;

    function GetFieldByFieldName(pFieldName: string; pGridColumns: TDBGridColumns): TField;
    procedure SetColVisible(pFieldName: string; pVisible: Boolean);

    procedure StatusBarDuzenle();
  published
    FRefresher: ThreadRefresh;

    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);override;
    procedure stbBaseDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect); override;
    procedure WmAfterShow(var Msg: TMessage); message WM_AFTER_SHOW;
    procedure btnAcceptClick(Sender: TObject); override;

    procedure WriteRecordCount(pCount: Integer);
    procedure SetTitleFromLangContent();

    //for use HelperForm
    procedure SelectCurrentRecord();
    function getFilterEditData(): string; virtual;
    //for use HelperForm
  end;

implementation

uses
  Ths.Erp.Globals,
  ufrmBaseInputDB,
  ufrmFilterDBGrid,
  FireDAC.Phys.PGWrapper,
  Ths.Erp.Database.Table.SysKaliteFormTipi;

{$R *.dfm}

procedure TfrmBaseDBGrid.actfilterExecute(Sender: TObject);
var
  LFilterBefore, LFilterVal: string;
begin
  LFilterBefore := '';
  if FiltreGrid.Count > 0 then
    LFilterBefore := ' AND ';
  if (grd.SelectedField <> nil) and (not grd.SelectedField.IsNull) then
  begin
    case grd.SelectedField.DataType of
      ftUnknown: ;
      ftString:       LFilterVal := grd.SelectedField.FieldName + '=' + QuotedStr(grd.SelectedField.AsString);
      ftSmallint:     LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftInteger:      LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftWord:         LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftBoolean:      LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftFloat:        LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftCurrency:     LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftBCD:          LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftDate:         LFilterVal := grd.SelectedField.FieldName + '=' + QuotedStr(grd.SelectedField.AsString);
      ftTime:         LFilterVal := grd.SelectedField.FieldName + '=' + QuotedStr(grd.SelectedField.AsString);
      ftDateTime:     LFilterVal := grd.SelectedField.FieldName + '=' + QuotedStr(grd.SelectedField.AsString);
      ftBytes:        LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftVarBytes:     LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftAutoInc:      LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftBlob:         LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftMemo:         LFilterVal := grd.SelectedField.FieldName + '=' + QuotedStr(grd.SelectedField.AsString);
      ftGraphic:      LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftFmtMemo:      LFilterVal := grd.SelectedField.FieldName + '=' + QuotedStr(grd.SelectedField.AsString);
      ftParadoxOle: ;
      ftDBaseOle: ;
      ftTypedBinary: ;
      ftCursor: ;
      ftFixedChar:    LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftWideString:   LFilterVal := grd.SelectedField.FieldName + '=' + QuotedStr(grd.SelectedField.AsString);
      ftLargeint:     LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftADT: ;
      ftArray:        LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftReference: ;
      ftDataSet: ;
      ftOraBlob: ;
      ftOraClob: ;
      ftVariant: ;
      ftInterface: ;
      ftIDispatch: ;
      ftGuid: ;
      ftTimeStamp:    LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftFMTBcd:       LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftFixedWideChar:LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftWideMemo:     LFilterVal := grd.SelectedField.FieldName + '=' + QuotedStr(grd.SelectedField.AsString);
      ftOraTimeStamp: LFilterVal := grd.SelectedField.FieldName + '=' + QuotedStr(grd.SelectedField.AsString);
      ftOraInterval: ;
      ftLongWord:     LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftShortint:     LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftByte:         LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftExtended:     LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
      ftConnection: ;
      ftParams: ;
      ftStream: ;
      ftTimeStampOffset: ;
      ftObject: ;
      ftSingle:       LFilterVal := grd.SelectedField.FieldName + '=' + grd.SelectedField.AsString;
    end;

    FiltreGrid.Add(LFilterBefore + LFilterVal);
    RefreshData;
  end;
end;

procedure TfrmBaseDBGrid.actfilter_backExecute(Sender: TObject);
begin
  if FiltreGrid.Count > 0 then
  begin
    FiltreGrid.Delete(FiltreGrid.Count-1);
    RefreshData;
  end;
end;

procedure TfrmBaseDBGrid.actfilter_excludeExecute(Sender: TObject);
var
  LFilterBefore, LFilterVal: string;
begin
  LFilterBefore := '';
  if FiltreGrid.Count > 0 then
    LFilterBefore := ' AND ';
  if (grd.SelectedField <> nil) and (not grd.SelectedField.IsNull) then
  begin
    case grd.SelectedField.DataType of
      ftUnknown: ;
      ftString:       LFilterVal := grd.SelectedField.FieldName + '!=' + QuotedStr(grd.SelectedField.AsString);
      ftSmallint:     LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftInteger:      LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftWord:         LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftBoolean:      LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftFloat:        LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftCurrency:     LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftBCD:          LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftDate:         LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftTime:         LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftDateTime:     LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftBytes:        LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftVarBytes:     LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftAutoInc:      LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftBlob:         LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftMemo:         LFilterVal := grd.SelectedField.FieldName + '!=' + QuotedStr(grd.SelectedField.AsString);
      ftGraphic:      LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftFmtMemo:      LFilterVal := grd.SelectedField.FieldName + '!=' + QuotedStr(grd.SelectedField.AsString);
      ftParadoxOle: ;
      ftDBaseOle: ;
      ftTypedBinary: ;
      ftCursor: ;
      ftFixedChar:    LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftWideString:   LFilterVal := grd.SelectedField.FieldName + '!=' + QuotedStr(grd.SelectedField.AsString);
      ftLargeint:     LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftADT: ;
      ftArray:        LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftReference: ;
      ftDataSet: ;
      ftOraBlob: ;
      ftOraClob: ;
      ftVariant: ;
      ftInterface: ;
      ftIDispatch: ;
      ftGuid: ;
      ftTimeStamp:    LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftFMTBcd:       LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftFixedWideChar:LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftWideMemo:     LFilterVal := grd.SelectedField.FieldName + '!=' + QuotedStr(grd.SelectedField.AsString);
      ftOraTimeStamp: LFilterVal := grd.SelectedField.FieldName + '!=' + QuotedStr(grd.SelectedField.AsString);
      ftOraInterval: ;
      ftLongWord:     LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftShortint:     LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftByte:         LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftExtended:     LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
      ftConnection: ;
      ftParams: ;
      ftStream: ;
      ftTimeStampOffset: ;
      ftObject: ;
      ftSingle:       LFilterVal := grd.SelectedField.FieldName + '!=' + grd.SelectedField.AsString;
    end;

    FiltreGrid.Add(LFilterBefore + LFilterVal);
    RefreshData;
  end;
end;

procedure TfrmBaseDBGrid.actfilter_initExecute(Sender: TObject);
begin
  mnifilter.Visible := True;
  mnifilter_remove.Visible := False;
  mnifilter_back.Visible := False;
end;

procedure TfrmBaseDBGrid.actfilter_removeExecute(Sender: TObject);
begin
  FFiltreGrid.Clear;
  grd.DataSource.DataSet.Filter := '';
  grd.DataSource.DataSet.Filtered := False;
  grd.SelectedField := nil;

  mnifilter_remove.Visible := False;
  mnifilter_back.Visible := False;

  edtFilterHelper.Visible := False;

  WriteRecordCount(grd.DataSource.DataSet.RecordCount);
end;

procedure TfrmBaseDBGrid.actsortExecute(Sender: TObject);
var
  sl: TStringList;
  LOrderList: string;
  LOrderedColumn, LIsCTRLKeyPress: Boolean;
  nIndex: Integer;
  LColumn: TColumn;
begin
  if Sender is TColumn then
    LColumn := Sender as TColumn
  else
    Exit;

  LOrderedColumn := False;
  LIsCTRLKeyPress := False;
  sl := TStringList.Create;
  try
    with TFDQuery(grd.DataSource.DataSet) do
    begin
      if isCtrlDown then
        LIsCTRLKeyPress := True;

      sl.Delimiter := ';';
      if IndexFieldNames <> '' then
        sl.DelimitedText := IndexFieldNames;

      if LIsCTRLKeyPress then
      begin
        //CTRL tuþuna basýlmýþsa
        for nIndex := 0 to sl.Count-1 do
          if (LColumn.FieldName + ':A' = sl.Strings[nIndex]) or (LColumn.FieldName + ':D' = sl.Strings[nIndex]) then
            LOrderedColumn := True;

        if LOrderedColumn then
        begin
          //listede zaten varsa ASC DESC deðiþimi yap
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
        //CTRL tuþuna basýlmamýþsa hepsini sil ve direkt olarak ekle
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
        mnisort_remove.Visible := True;

      IndexFieldNames := LOrderList;
    end;

    THackDBGrid(grd).InvalidateTitles;
  finally
    sl.Free;
  end;
end;

procedure TfrmBaseDBGrid.actsort_initExecute(Sender: TObject);
begin
  mnisort_remove.Visible := False;
end;

procedure TfrmBaseDBGrid.actsort_removeExecute(Sender: TObject);
begin
  TFDQuery(grd.DataSource.DataSet).IndexFieldNames := '';
  mnisort_remove.Visible := False;
end;

procedure TfrmBaseDBGrid.btnAcceptClick(Sender: TObject);
begin
  inherited;

  if FIsHelper then
  begin
    FDataAktar := True;
    TableHelper := Table.Clone;
    TableHelper.Clear;
    FCleanAndClose := True;
    if Owner is TEdit then
      TEdit(Owner).Clear;
    btnCloseClick(btnClose);
  end;
end;

procedure TfrmBaseDBGrid.btnAddNewClick(Sender: TObject);
begin
  ShowInputForm(Sender, ifmNewRecord);
end;

procedure TfrmBaseDBGrid.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FIsHelper then
  begin
    if DataAktar then
    begin
      if Assigned(Owner) then
        if (Owner.ClassType = TEdit) then
          if ParentForm.ClassParent = TfrmBaseInputDB then
          begin
            if ((ParentForm as TfrmBaseInputDB).FormMode = ifmNewRecord)
            or ((ParentForm as TfrmBaseInputDB).FormMode = ifmCopyNewRecord)
            or ((ParentForm as TfrmBaseInputDB).FormMode = ifmUpdate)
            then
            begin
              TEdit(Owner).Text := getFilterEditData;
              TEdit(Owner).SelStart := Length(TEdit(Owner).Text);
            end;
          end;
      if FCleanAndClose then
        TEdit(Owner).Clear;
      inherited;
    end
    else
    begin
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmBaseDBGrid.FormCreate(Sender: TObject);
begin
  FStopwatch := TStopwatch.StartNew;

  inherited;

  pnlHeader.Visible := False;
  if FIsHelper then
  begin
    if Assigned(Table) then
      Table.QueryOfDS.FetchOptions.Mode := fmOnDemand;

    pnlHeader.Visible := True;
    lblFilterHelper.Caption := 'Filter';
  end;


  actfilter_initExecute(actfilter_init);
  actsort_initExecute(actsort_init);

  //bazen status bar panelin üzerinde çıkıyor bunu engellemek için bu kod yazıldı
  pnlBottom.Visible := False;
  stbBase.Visible := True;
  pnlBottom.Visible := True;
  //----------


  //grid varsayılan font ve datasource tanımla
  grd.DataSource := Table.DataSource;


  //ondalık haneleri getir
  GSysOndalikHane.SelectToList('', False, False);


  FQryFiltreVarsayilan := GetGridDefaultOrderFilter( ReplaceRealColOrTableNameTo(Table.TableName), False);
  FQrySiralamaVarsayilan := GetGridDefaultOrderFilter( ReplaceRealColOrTableNameTo(Table.TableName), True);
  FFiltreGrid := TStringList.Create;

  btnAddNew.Visible := True;

  PostMessage(self.Handle, WM_AFTER_CREATE, 0, 0);
end;

procedure TfrmBaseDBGrid.FormDestroy(Sender: TObject);
begin
//  FRefresher.Terminate;
//  Sleep(50);
//  Table.Unlisten;

//  if not FIsHelper then
//  begin
//    Table.Database.EventAlerter.Active := False;
//    Table.Database.EventAlerter.Names.Delete(Table.Database.EventAlerter.Names.IndexOf(Table.TableName));
//  end;

  if FIsHelper then
  begin
    if Assigned(TableHelper) then
      TableHelper.Free;
    FFilterStringFields.Free;
    FFilterNumericFields.Free;
    FFilterDateFields.Free;
    FFilterBoolFields.Free;
  end;

  SetLength(FColoredPercentColNames, 0);
  SetLength(FColoredNumericColNames, 0);

  FFiltreGrid.Free;

  if Assigned(spDS) then
    spDS.free;
  inherited;
end;

procedure TfrmBaseDBGrid.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  begin
    if (Key = VK_RETURN) then //Enter (Return) Preview Click for Show Input form
    begin
      if (grd.Focused) then
      begin
        Key := 0;
        if (not FIsHelper) then
          mniPreview.Click;
      end;
    end
    else if  (Key = Ord('T')) then  //CTRL + SHIFT + ALT + T show all columns(show hide columns)
    begin
      if Shift = [ssCtrl, ssShift, ssAlt] then
      begin

      end;
    end
    else if (Key = Ord('F')) then //CTRL + F key combination show Filter form
    begin
      if Shift = [ssCtrl] then
      begin
        Key := 0;
        grd.SetFocus;
      end;
    end
    else if Key = VK_F7 then  //F7 Key Show Inputform for New record(Add New Record)
    begin
      if (not FIsHelper) then
      begin
        Key := 0;
        if btnAddNew.Visible and btnAddNew.Enabled then
          btnAddNew.Click;
      end;
    end
    else
      inherited;
  end;
end;

procedure TfrmBaseDBGrid.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = Char(VK_ESCAPE)) and FIsHelper then //Escape (Close dont do any process)
  begin
    Key := #0;
    FDataAktar := False;
    btnCloseClick(btnClose);
  end
  else if (Key = Char(VK_RETURN)) then //Enter (Return)
  begin
    Key := #0;
    if FIsHelper then
      SelectCurrentRecord;
  end
  else
    inherited;
end;

procedure TfrmBaseDBGrid.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if FIsHelper then
  begin
    if Key = VK_F5 then
      Key := 0;
  end
  else
  begin
    if (Key = Ord('F')) then //CTRL + F key combination show Filter form
    begin
      if Shift = [ssCtrl] then
      begin
        Key := 0;
        TfrmFilterDBGrid.Create(Application, Self).ShowModal;
        if FiltreGrid.Count > 0 then
          RefreshData;
      end;
    end
    else
      inherited;
  end;
end;

procedure TfrmBaseDBGrid.FormPaint(Sender: TObject);
begin
  inherited;
  //
end;

procedure TfrmBaseDBGrid.btnSpinDownClick(Sender: TObject);
begin
  MoveDown();
end;

procedure TfrmBaseDBGrid.btnSpinUpClick(Sender: TObject);
begin
  MoveUp();
end;

constructor TfrmBaseDBGrid.Create(
  AOwner: TComponent;
  AParentForm: TForm;
  ATable: TTable;
  AFormDecimalMode: TFormDecimalMode;
  AHelperForm: Boolean);
begin
  inherited Create(AOwner, AParentForm, ATable, ifmNone, AFormDecimalMode);
  FIsHelper := AHelperForm;
end;

function TfrmBaseDBGrid.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
end;

procedure TfrmBaseDBGrid.DataSourceDataChange(Sender: TObject; Field: TField);
begin
  WriteRecordCount(Table.DataSource.DataSet.RecordCount);
end;

procedure TfrmBaseDBGrid.grdCellClick(Column: TColumn);
begin
  SetSelectedItem;
end;

procedure TfrmBaseDBGrid.grdColEnter(Sender: TObject);
begin
  inherited;
  //
end;

procedure TfrmBaseDBGrid.grdColExit(Sender: TObject);
begin
  inherited;
  grd.Repaint;
end;

procedure TfrmBaseDBGrid.grdColumnMoved(Sender: TObject; FromIndex, ToIndex: Integer);
begin
  inherited;
  //
end;

procedure TfrmBaseDBGrid.grdDblClick(Sender: TObject);
begin
  if FIsHelper then
  begin
    //ferhat
    SelectCurrentRecord;
  end
  else
    mniPreviewClick(grd);
end;

procedure TfrmBaseDBGrid.grdDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  inherited;
  //
end;

procedure TfrmBaseDBGrid.grdDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  inherited;
  //
end;

procedure TfrmBaseDBGrid.grdDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
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
  LColorActive := VarToInt(FormatedVariantVal(GSysUygulamaAyari.GridColorActive));
  LColor1 := VarToInt(FormatedVariantVal(GSysUygulamaAyari.GridColor1));
  LColor2 := VarToInt(FormatedVariantVal(GSysUygulamaAyari.GridColor2));

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

    THackDBGrid(Sender).Canvas.FillRect(Rect);
    if (VarIsNull(Column.Field.Value)) then
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
    if IsYuzdeCizimAlaniVar(Column.FieldName) then
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
    end;
  end;


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
end;

procedure TfrmBaseDBGrid.grdDrawDataCell(Sender: TObject; const Rect: TRect; Field: TField; State: TGridDrawState);
begin
  inherited;
  //
end;

procedure TfrmBaseDBGrid.grdEnter(Sender: TObject);
begin
  inherited;
  //
end;

procedure TfrmBaseDBGrid.grdExit(Sender: TObject);
begin
  inherited;
  //
end;

procedure TfrmBaseDBGrid.grdKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  //CTRL + DELETE konbinasyonu ile kayıtları silmeyi engellemek için yapıldı. Aksi halde kontrol kayıt silme işlemi yapılabilir.
  if (Key = VK_DELETE) and (Shift = [ssCtrl]) then
    Key := 0;
end;

procedure TfrmBaseDBGrid.grdKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  //
end;

procedure TfrmBaseDBGrid.grdKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
  //
end;

procedure TfrmBaseDBGrid.grdMouseLeave(Sender: TObject);
begin
  inherited;
  grd.Repaint;
end;

procedure TfrmBaseDBGrid.grdMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  grd.Repaint;
end;

procedure TfrmBaseDBGrid.grdMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  grd.Repaint;
end;

procedure TfrmBaseDBGrid.grdMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  inherited;
//
end;

procedure TfrmBaseDBGrid.grdMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  inherited;
//
end;

procedure TfrmBaseDBGrid.grdMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  inherited;
//
end;

procedure TfrmBaseDBGrid.grdTitleClick(Column: TColumn);
begin
  //
  actsortExecute(Column);
end;

procedure TfrmBaseDBGrid.drawTriangleInRect(ARect: TRect; ASort: TSortType; AAlignment: TAlignment);
const
  OFFSET = 2;
var
  goLeft: integer;
begin
  //if IsRightToLeft then
  begin
    if AAlignment = taLeftJustify then
      goLeft := 0
    else
      goLeft := ARect.Right - ARect.Left - 17;
  end;

  // draw triangle
  grd.Canvas.Brush.Color := clRed;
  grd.Canvas.Pen.Color := clRed;
  if ASort = stAsc then
    grd.Canvas.Polygon([point(ARect.Right - 2 - goLeft, ARect.top + 10),
      point(ARect.Right - 7 - goLeft, ARect.top + 5), point(ARect.Right - 12 - goLeft, ARect.top + 10)])

  else if ASort = stDesc then
    grd.Canvas.Polygon([point(ARect.Right - 2 - goLeft, ARect.top + 5),
      Point(ARect.Right - 7 - goLeft, ARect.top + 10), point(ARect.Right - 12 - goLeft, ARect.top + 5)]);
end;

procedure TfrmBaseDBGrid.edtFilterHelperChange(Sender: TObject);
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

  if edtFilterHelper.Text <> '' then
  begin
    if TryStrToInt(edtFilterHelper.Text, LIntValue)
    or TryStrToFloat(edtFilterHelper.Text, LDoubleValue)
    then
    begin
      for n1 := 0 to FFilterNumericFields.Count-1 do
      begin
        if LFilter <> '' then
          LFilter := LFilter + ' OR ';
        LFilter := LFilter + FFilterNumericFields.Strings[n1] + ' LIKE ' + QuotedStr('%' + edtFilterHelper.Text + '%');
      end;
    end;

    if (UpperCaseTr(edtFilterHelper.Text) = 'TRUE')
    or (LowerCaseTr(edtFilterHelper.Text) = 'true')
    or (UpperCaseTr(edtFilterHelper.Text) = 'FALSE')
    or (LowerCaseTr(edtFilterHelper.Text) = 'false')
    then
    begin
      for n1 := 0 to FFilterBoolFields.Count-1 do
      begin
        if LFilter <> '' then
          LFilter := LFilter + ' OR ';
        LFilter := LFilter + FFilterNumericFields.Strings[n1] + '=' + UpperCaseTr(edtFilterHelper.Text);
      end;
    end;

    if TryStrToDate(edtFilterHelper.Text, LDateTimeValue)
    or TryStrToTime(edtFilterHelper.Text, LDateTimeValue)
    or TryStrToDateTime(edtFilterHelper.Text, LDateTimeValue)
    then
    begin
      for n1 := 0 to FFilterNumericFields.Count-1 do
      begin
        if LFilter <> '' then
          LFilter := LFilter + ' OR ';
        LFilter := LFilter + FFilterNumericFields.Strings[n1] + '=' + edtFilterHelper.Text;
      end;
    end;

    if edtFilterHelper.Text <> '' then
    begin
      for n1 := 0 to FFilterStringFields.Count-1 do
      begin
        if LFilter <> '' then
          LFilter := LFilter + ' OR ';
        LFilter := LFilter + FFilterStringFields.Strings[n1] + ' LIKE ' + QuotedStr('%' + UpperCaseTr(edtFilterHelper.Text) + '%');
        LFilter := LFilter + ' OR ' + FFilterStringFields.Strings[n1] + ' LIKE ' + QuotedStr('%' + LowerCaseTr(edtFilterHelper.Text) + '%');
      end;
    end;

    grd.DataSource.DataSet.Filter := LFilter;
    grd.DataSource.DataSet.Filtered := True;
  end;
  WriteRecordCount(Table.DataSource.DataSet.RecordCount);
end;

procedure TfrmBaseDBGrid.edtFilterHelperKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DOWN) then
    grd.DataSource.DataSet.Next
  else if (Key = VK_UP) then
    grd.DataSource.DataSet.Prior
  else if (Key = VK_NEXT) then
    grd.DataSource.DataSet.Next
  else if (Key = VK_PRIOR) then
    grd.DataSource.DataSet.Prior
  else
    inherited;
  //helper için aşağı yukarıda key up eventte sadece grid hareket etsin.
  //aşağı yukarı yönler edit içinde selstart position değişimi yapmasın
//  edtFilterHelper.SelStart := Length(edtFilterHelper.Text);
end;

procedure TfrmBaseDBGrid.edtFilterHelperKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
  //helper için aşağı yukarıda key up eventte sadece grid hareket etsin.
  //aşağı yukarı yönler edit içinde selstart position değişimi yapmasın
//  edtFilterHelper.SelStart := Length(edtFilterHelper.Text);
end;

//procedure TfrmBaseDBGrid.EventAlerterAlert(ASender: TFDCustomEventAlerter; const AEventName: string; const AArgument: Variant);
//var
//  sMesaj: string;
//  n1: Integer;
//begin
//  ASender.Unregister;
//  if VarIsArray( AArgument ) then
//    for n1 := VarArrayLowBound(AArgument, 1) to VarArrayHighBound(AArgument, 1) do
//      if n1 = 0 then
//        sMesaj := sMesaj + 'Process ID (pID):' + VarToStr(AArgument[n1]) + ', '
//      else if n1 = 1 then
//        sMesaj := sMesaj + 'Notify Value:' + VarToStr(AArgument[n1]) + ', '
//      else
//        sMesaj := sMesaj + ' ' + VarToStr(AArgument[n1]) + ', ';
//  grd.DataSource.DataSet.Refresh;
//end;

procedure TfrmBaseDBGrid.FormResize(Sender: TObject);
begin
  inherited;
  //
end;

procedure TfrmBaseDBGrid.FormShow(Sender: TObject);
var
  n1: Integer;
begin
  //if form is helper then show header panel for the filter properties
  pnlHeader.Visible := FIsHelper;

  if FIsHelper then
  begin
    FFilterStringFields := TStringList.Create;
    FFilterNumericFields := TStringList.Create;
    FFilterDateFields := TStringList.Create;
    FFilterBoolFields := TStringList.Create;

    if Assigned(Owner) then
      if Owner is TEdit then
        edtFilterHelper.Text := TEdit(Owner).Text;
  end;


  //ilk açılışta veri tabanından kayıtları getirmek için RefreshDataFirst çağır
  //daha sonraki işlemlerde sadece query refresh ile update yapacağız
  //buda işlemlerin hazlanması için gerekli bir adım.
  //Her zaman db den select yapınca fazla kolon ve kayıt olduğu durumlarda aşırı yavaşlamna oluyor
  RefreshDataFirst;

  inherited;

  StatusBarDuzenle();

  Self.Caption := getFormCaptionByLang(Self.Name, Self.Caption);

  mniColumnTitleByLang.Caption := TranslateText(mniColumnTitleByLang.Caption, FrameworkLang.PopupAddLangGuiContent, LngPopup, LngSystem);
  mniLangDataContent.Caption := TranslateText(mniLangDataContent.Caption, FrameworkLang.PopupAddLangDataContent, LngPopup, LngSystem);
  mnicopy_record.Caption := TranslateText(mnicopy_record.Caption, FrameworkLang.PopupCopyRecord, LngPopup, LngSystem);
  mnifilter_exclude.Caption := TranslateText(mnifilter_exclude.Caption, FrameworkLang.PopupFilterExclude, LngPopup, LngSystem);
  mniexport_excel.Caption := TranslateText(mniexport_excel.Caption, FrameworkLang.PopupExportExcel, LngPopup, LngSystem);
  mniexport_excel_all.Caption := TranslateText(mniexport_excel_all.Caption, FrameworkLang.PopupExportExcelAll, LngPopup, LngSystem);
  mnifilter.Caption := TranslateText(mnifilter.Caption, FrameworkLang.PopupFilter, LngPopup, LngSystem);
  mnipreview.Caption := TranslateText(mnipreview.Caption, FrameworkLang.PopupPreview, LngPopup, LngSystem);
  mniprint.Caption := TranslateText(mniprint.Caption, FrameworkLang.PopupPrint, LngPopup, LngSystem);
  mnifilter_remove.Caption := TranslateText(mnifilter_remove.Caption, FrameworkLang.PopupFilterRemove, LngPopup, LngSystem);
  mnisort_remove.Caption := TranslateText(mnisort_remove.Caption, FrameworkLang.PopupRemoveSort, LngPopup, LngSystem);

  if Table.IsAuthorized(ptAddRecord, True, False) then
  begin
    btnAddNew.Visible := True;
    btnAddNew.Enabled := True;
    mnicopy_record.Visible := True;
    mnicopy_record.Enabled := True;
  end
  else
  begin
    btnAddNew.Enabled := False;
    mnicopy_record.Visible := False;
    mnicopy_record.Enabled := False;
  end;
  //her zaman kapalı olsun istenilen formlarda açılır.
  mnicopy_record.Visible := False;


  mniPrint.Visible := False;
  mniFormTitleByLang.Visible := False;
  mniColumnTitleByLang.Visible := False;
  mniUpdateColWidth.Visible := False;
  mniColumnSummary.Visible := False;
  mniLangDataContent.Visible := False;
  mniSeperator1.Visible := False;
  if GSysKullanici.IsSuperKullanici.Value then
  begin
    mniSeperator1.Visible := True;
    mniFormTitleByLang.Visible := True;
    mniColumnTitleByLang.Visible := True;
    mniUpdateColWidth.Visible := True;
//    mniColumnSummary.Visible := True;
    mniLangDataContent.Visible := True;
  end;

  ResizeForm;

  if FIsHelper then
  begin
    if edtFilterHelper.Visible then
      edtFilterHelper.SetFocus;
    grd.PopupMenu := nil;
    grd.TabStop := False;
    pnlButtons.Visible := False;
    FDataAktar := False;

    for n1 := 0 to grd.Columns.Count - 1 do
    begin
      if (grd.Columns[n1].Field.DataType = Data.DB.ftString)
      or (grd.Columns[n1].Field.DataType = Data.DB.ftWideString)
      or (grd.Columns[n1].Field.DataType = Data.DB.ftMemo)
      or (grd.Columns[n1].Field.DataType = Data.DB.ftWideMemo)
      then begin
        FFilterStringFields.Add(grd.Columns[n1].FieldName);
      end else
      if (grd.Columns[n1].Field.DataType = Data.DB.ftWord)
      or (grd.Columns[n1].Field.DataType = Data.DB.ftLongWord)
      or (grd.Columns[n1].Field.DataType = Data.DB.ftByte)
      or (grd.Columns[n1].Field.DataType = Data.DB.ftShortint)
      or (grd.Columns[n1].Field.DataType = Data.DB.ftSmallint)
      or (grd.Columns[n1].Field.DataType = Data.DB.ftInteger)
      or (grd.Columns[n1].Field.DataType = Data.DB.ftLargeint)
      or (grd.Columns[n1].Field.DataType = Data.DB.ftFloat)
      or (grd.Columns[n1].Field.DataType = Data.DB.ftCurrency)
      or (grd.Columns[n1].Field.DataType = Data.DB.ftBCD)
      or (grd.Columns[n1].Field.DataType = Data.DB.ftSingle)
      then begin
        if grd.Columns[n1].FieldName <> 'id' then
          FFilterNumericFields.Add(grd.Columns[n1].FieldName);
      end
      else if (grd.Columns[n1].Field.DataType = Data.DB.ftBoolean) then begin
        FFilterBoolFields.Add(grd.Columns[n1].FieldName);
      end else
      if (grd.Columns[n1].Field.DataType = Data.DB.ftDate)
      or (grd.Columns[n1].Field.DataType = Data.DB.ftTime)
      or (grd.Columns[n1].Field.DataType = Data.DB.ftDateTime)
      then begin
        FFilterDateFields.Add(grd.Columns[n1].FieldName);
      end;
    end;

    edtFilterHelper.OnChange := edtFilterHelperChange;
    edtFilterHelper.OnKeyUp := edtFilterHelperKeyUp;
    edtFilterHelper.OnKeyDown := edtFilterHelperKeyDown;

    btnAccept.Visible := True;
    btnAccept.Caption := TranslateText('TEMİZLE VE KAPAT', FrameworkLang.ButtonHelper, LngButton, LngSystem);
    btnAccept.Width := Max(100, Canvas.TextWidth(btnAccept.Caption) + 70);
  end;

  if not FIsHelper then
  begin
    if Assigned(Table) then
    begin
      //Table.Listen;
      //Sleep(50);
      //FRefresher := ThreadRefresh.Create(Self, False);
    end;
//    Table.Database.EventAlerter.OnAlert := dm.EventAlerterAlert;
//    Table.Database.EventAlerter.Names.AddObject(Table.TableName, Table.QueryOfDS);
//    Table.Database.EventAlerter.Active := True;
  end;

  PostMessage(Self.Handle, WM_AFTER_SHOW, 0, 0);
end;

procedure TfrmBaseDBGrid.frxrprtBasePreview(Sender: TObject);
begin
  inherited;
  TfrxPreview(frxrprtBase.Preview).ZoomMode := zmWholePage;
end;

function TfrmBaseDBGrid.GetFieldByFieldName(pFieldName: string; pGridColumns: TDBGridColumns): TField;
var
  nIndex: Integer;
begin
  Result := nil;
  if pFieldName <> '' then
  begin
    for nIndex := 0 to pGridColumns.Count-1 do
      if pGridColumns[nIndex].FieldName = pFieldName then
        Result := pGridColumns[nIndex].Field;
  end;
end;

function TfrmBaseDBGrid.getFilterEditData: string;
var
  LField: TField;
begin
  Result := '';
  if Assigned(Owner) then
  begin
    if Owner is TEdit then
    begin
      LField := grd.DataSource.DataSet.FindField(Table.Id.FieldName);
      if Assigned(LField) then
        TEdit(Owner).HelperValue := FormatedVariantVal(LField.DataType, LField.Value);
    end;
  end;
end;

function TfrmBaseDBGrid.GetLowHighEqual(pField: TField; pDefaultColor: TColor): Integer;
var
  n1: Integer;
begin
  Result := pDefaultColor;
  for n1 := 0 to Length(FColoredNumericColNames) do
  begin
    if pField.FieldName = TColColor(FColoredNumericColNames[n1]).FieldName then
    begin
      if pField.AsInteger < TColColor(FColoredNumericColNames[n1]).MinValue then
        Result := TColColor(FColoredNumericColNames[n1]).MinColor
      else if pField.AsInteger > TColColor(FColoredNumericColNames[n1]).MaxValue then
        Result := TColColor(FColoredNumericColNames[n1]).MaxColor;
      Break;
    end;
  end;
end;

function TfrmBaseDBGrid.GetPercentMaxVal(pField: TField): Double;
var
  n1: Integer;
begin
  Result := 1;
  for n1 := 0 to Length(FColoredPercentColNames) do
  begin
    if pField.FieldName = TColPercent(FColoredPercentColNames[n1]).FieldName then
    begin
      Result := TColPercent(FColoredPercentColNames[n1]).MaxValue;
      ColorBar := TColPercent(FColoredPercentColNames[n1]).ColorBar;
      ColorBarBack := TColPercent(FColoredPercentColNames[n1]).ColorBarBack;
      ColorBarText := TColPercent(FColoredPercentColNames[n1]).ColorBarText;
      Break;
    end;
  end;
end;

function TfrmBaseDBGrid.IsRenkliRakamVar(pFieldName: string): Boolean;
var
  n1: Integer;
begin
  Result := False;
  for n1 := 0 to Length(FColoredNumericColNames)-1 do
  begin
    if pFieldName = TColColor(FColoredNumericColNames[n1]).FieldName then
    begin
      Result := True;
      Break
    end;
  end;
end;

function TfrmBaseDBGrid.IsYuzdeCizimAlaniVar(pFieldName: string): Boolean;
var
  n1: Integer;
begin
  Result := False;
  for n1 := 0 to Length(FColoredPercentColNames)-1 do
  begin
    if pFieldName = TColPercent(FColoredPercentColNames[n1]).FieldName then
    begin
      Result := True;
      Break
    end;
  end;
end;

procedure TfrmBaseDBGrid.mnicopy_recordClick(Sender: TObject);
begin
  if Table.DataSource.DataSet.RecordCount > 0 then
  begin
    SetSelectedItem;
    ShowInputForm(mnicopy_record, ifmCopyNewRecord);
  end;
end;

procedure TfrmBaseDBGrid.mnicopy_to_clipboardClick(Sender: TObject);
begin
  if grd.Focused then
  begin
    if not grd.SelectedField.IsNull then
    begin
      Clipboard.Clear;
      Clipboard.AsText := grd.SelectedField.Value;
    end;
  end;
end;

procedure TfrmBaseDBGrid.mniColumnSummaryClick(Sender: TObject);
var
  LSummary: TSysGridKolon;
  LColumn: TColumn;
begin
  LColumn := grd.Columns[grd.SelectedField.Index];
  if Assigned(LColumn) then
  begin
    if (LColumn.Field.DataType = ftString)
    or (LColumn.Field.DataType = ftWideString)
    or (LColumn.Field.DataType = ftMemo)
    or (LColumn.Field.DataType = ftWideMemo)
    or (LColumn.Field.DataType = ftFixedChar)
    or (LColumn.Field.DataType = ftFixedWideChar)
    then
    begin
      {TODO -oFerhat -cGeneral : Dile göre düzenleme yap}
      ShowMessage('Bu işlemi sadece sayısal bilgi içeren sütunlarda yapabilirsiniz!!! ' + FERHAT_UYARI);
      Exit;
    end;

    LSummary := TSysGridKolon.Create(GDataBase);
    LSummary.SelectToList(' AND ' + LSummary.TableName + '.' + LSummary.TabloAdi.FieldName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(Table.TableName)) +
                          ' AND ' + LSummary.TableName + '.' + LSummary.KolonAdi.FieldName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(LColumn.FieldName)), False, False);
    if LSummary.List.Count = 0 then
    begin
      LSummary.TabloAdi.Value := ReplaceRealColOrTableNameTo(Table.TableName);
      LSummary.KolonAdi.Value := ReplaceRealColOrTableNameTo(LColumn.FieldName);
      LSummary.OzetTipi.Value := 1;
      if (LColumn.Field.DataType = ftSmallint)
      or (LColumn.Field.DataType = ftShortint)
      or (LColumn.Field.DataType = ftInteger)
      or (LColumn.Field.DataType = ftLargeint)
      or (LColumn.Field.DataType = ftWord)
      or (LColumn.Field.DataType = ftLongWord)
      or (LColumn.Field.DataType = ftLongWord)
      then
        LSummary.DataFormat.Value := '##' + FormatSettings.ThousandSeparator + '#';

      TfrmSysGridKolon.Create(Self, nil, LSummary, ifmCopyNewRecord, fomNormal, ivmSort).ShowModal;
    end
    else if LSummary.List.Count = 1 then
      TfrmSysGridKolon.Create(Self, nil, LSummary, ifmRewiev, fomNormal, ivmSort).ShowModal;
  end;
end;

procedure TfrmBaseDBGrid.mniColumnTitleByLangClick(Sender: TObject);
var
  vSysLangGuiContent: TSysLisanGuiIcerik;
  AColumn: TColumn;
begin
  AColumn := grd.Columns[grd.SelectedField.Index];
  if Assigned(AColumn) then
  begin
    vSysLangGuiContent := TSysLisanGuiIcerik.Create(GDataBase);

    vSysLangGuiContent.Lisan.Value := GDataBase.ConnSetting.Language;
    vSysLangGuiContent.Kod.Value := AColumn.FieldName;
    vSysLangGuiContent.IcerikTipi.Value := LngDGridFieldCaption;
    vSysLangGuiContent.TabloAdi.Value := Table.TableName;
    vSysLangGuiContent.Deger.Value := AColumn.Title.Caption;

    TfrmSysLisanGuiIcerik.Create(Self, nil, vSysLangGuiContent, ifmCopyNewRecord, fomNormal, ivmSort).ShowModal;
    SetTitleFromLangContent();
  end;
end;

procedure TfrmBaseDBGrid.mniLangDataContentClick(Sender: TObject);
var
  vSysLangDataContent: TSysLisanDataIcerik;
  AField: Data.DB.TField;
begin
  grd.SetFocus;

  AField := grd.SelectedField;

  if Assigned(AField) then
  begin
    vSysLangDataContent := TSysLisanDataIcerik.Create(GDataBase);

    vSysLangDataContent.Lisan.Value := GDataBase.ConnSetting.Language;
    vSysLangDataContent.TabloAdi.Value := Table.TableName;
    vSysLangDataContent.KolonAdi.Value := AField.FieldName;

    vSysLangDataContent.RowID.Value := FormatedVariantVal(
        grd.DataSource.DataSet.FindField(Table.Id.FieldName).DataType,
        grd.DataSource.DataSet.FindField(Table.Id.FieldName).Value);
    vSysLangDataContent.Deger.Value := FormatedVariantVal(AField.DataType, AField.Value);

    TfrmSysLangDataContent.Create(Application, Self, vSysLangDataContent, ifmCopyNewRecord, fomNormal, ivmSort).Show;
  end;
end;

procedure TfrmBaseDBGrid.mniexport_excel_allClick(Sender: TObject);
begin
  TransferToExcel(True);
  //TransferToExcelAll();
end;

procedure TfrmBaseDBGrid.mniexport_excelClick(Sender: TObject);
begin
  TransferToExcel();
end;

procedure TfrmBaseDBGrid.mniFormTitleByLangClick(Sender: TObject);
begin
  CreateLangGuiContentFormforFormCaption;
end;

procedure TfrmBaseDBGrid.mnipreviewClick(Sender: TObject);
begin
  if mniPreview.Visible then
  begin
    if (Table.DataSource.DataSet.RecordCount <> 0) and (grd.DataSource.DataSet.RecordCount > 0) then
    begin
      SetSelectedItem();
      ShowInputForm(mniPreview, ifmRewiev);
    end;
  end;
end;

procedure TfrmBaseDBGrid.mnisort_removeClick(Sender: TObject);
begin
  actsort_removeExecute(Sender);
end;

procedure TfrmBaseDBGrid.mniUpdateColWidthClick(Sender: TObject);
begin
  if UpdateColWidth(Table.TableName, grd) then
    CustomMsgDlg(TranslateText('Yeni Sütun genişlikleri kaydedildi.', FrameworkLang.MessageUpdateColumnWidth, LngMsgData, LngSystem),
        mtInformation, [mbOK], [TranslateText('Tamam', FrameworkLang.ButtonOK, LngButton, LngSystem)], mbOK, '');
end;

procedure TfrmBaseDBGrid.mniprintClick(Sender: TObject);
var
  vmd: TfrxComponent;
  vObj: TfrxMemoView;
  vFileName: string;
  vFormNo: string;
  n1, nx: Integer;
begin
  if mniPrint.Visible then
  begin
    vFileName := GUygulamaAnaDizin + 'Reports\ListDGrid.fr3';
  //  frxrprtBase.EngineOptions.DestroyForms := False;
  //  frxrprtBase.EngineOptions.SilentMode := True;
  //  frxrprtBase.EngineOptions.EnableThreadSafe := True;
  //  frxrprtBase.ShowProgress := False;
  //  frxrprtBase.EngineOptions.UseFileCache := False;
  //  frxrprtBase.ReportOptions.Compressed := True;
  //  frxrprtBase.EngineOptions.UseGlobalDataSetList := False;

    if frxrprtBase.LoadFromFile(vFileName) then
    begin
      frxdbdtstBase.DataSet := grd.DataSource.DataSet;
      frxrprtBase.DataSets.Add(frxdbdtstBase);
      frxrprtBase.EnabledDataSets.Add(frxdbdtstBase);

      vmd := frxrprtBase.FindObject('Masterdata1'); //point to Masterdata1 at Page1 of report file
      (vmd as Tfrxmasterdata).DataSet := frxdbdtstBase;
      (vmd as Tfrxmasterdata).DataSetName := 'Masterdata1';

      if frxrprtBase.FindObject('mmotitle') is TfrxMemoView then
      begin
        vObj := frxrprtBase.FindObject('mmotitle') as TfrxMemoView;
        vObj.Text := Self.Caption;
      end;

      nx := 0;
      for n1 := 0 to grd.Columns.Count-1 do
      begin
        if grd.Columns[n1].Visible then
        begin
          vObj := TfrxMemoView.Create(frxrprtBase.FindObject('Header1'));

          vObj.Name := 'mmo' + grd.Columns[n1].FieldName;
          vObj.Parent := frxrprtBase.FindObject('Header1');
          vObj.Font.Name := 'Trebuchet MS';
          vObj.Font.Style := [fsBold];
          vObj.Font.Size := 9;
          vObj.Height := fr01cm * 5;
          vObj.Width := grd.Columns[n1].Width;  //fr1cm * 1.5;
          vObj.Text := StringReplace(StringReplace(grd.Columns[n1].Title.Caption, '[', '(', [rfReplaceAll]), ']', ')', [rfReplaceAll]);
          vObj.Left := nx * fr1cm * 1.5 + (fr01cm * 5);
          vObj.Top := 0;
          vObj.HAlign := TfrxHAlign.haLeft;


          vObj := TfrxMemoView.Create(frxrprtBase.FindObject('Masterdata1'));
          vObj.Name := 'mmoVal' + grd.Columns[n1].FieldName;
          vObj.Parent := frxrprtBase.FindObject('Masterdata1');
          vObj.Font.Name := 'Trebuchet MS';
          vObj.Font.Style := [];
          vObj.Font.Size := 9;
          vObj.Height := fr01cm * 5;
          vObj.Width := grd.Columns[n1].Width;  //fr1cm * 1.5;
          vObj.Left := nx * fr1cm * 1.5 + (fr01cm * 5);
          vObj.Top := 0;
          if (grd.Columns[n1].Field.DataType = Data.DB.ftInteger)
          or (grd.Columns[n1].Field.DataType = Data.DB.ftSmallint)
          or (grd.Columns[n1].Field.DataType = Data.DB.ftShortint)
          or (grd.Columns[n1].Field.DataType = Data.DB.ftWord)
          or (grd.Columns[n1].Field.DataType = Data.DB.ftDate)
          or (grd.Columns[n1].Field.DataType = Data.DB.ftTime)
          or (grd.Columns[n1].Field.DataType = Data.DB.ftDateTime)
          or (grd.Columns[n1].Field.DataType = Data.DB.ftTimeStamp)
          then
            vObj.HAlign := TfrxHAlign.haLeft
          else
            vObj.HAlign := TfrxHAlign.haLeft;

          vObj.DataSet := frxdbdtstBase;
          vObj.DataField := grd.Columns[n1].FieldName;

          Inc(nx);
        end;
      end;

  //    if frxrprtBase.FindObject('Memo1') is TfrxMemoView then
  //    begin
  //      vObj := frxrprtBase.FindObject('Memo1') as TfrxMemoView;
  //      vObj.Text := grd.DataSource.DataSet.FieldByName('id').DisplayName;
  //    end;
  //
  //    if frxrprtBase.FindObject('Memo4') is TfrxMemoView then
  //    begin
  //      vObj := frxrprtBase.FindObject('Memo4') as TfrxMemoView;
  //      vObj.DataSet := frxdbdtstBase;
  //      vObj.DataField := 'id';
  //      vObj.HAlign := TfrxHAlign.haRight;
  //    end;

      if frxrprtBase.FindObject('mmoquality_form_no') is TfrxMemoView then
      begin
        vFormNo := GetKaliteFormNo(Table.TableName, QtyPrintList);
        vObj := frxrprtBase.FindObject('mmoquality_form_no') as TfrxMemoView;
        if vFormNo <> '' then
          vObj.Text := vFormNo
        else
          vObj.Text := '';
        vObj.Left := vObj.Left + 8;
        vObj.Top := vObj.Top + 8;
      end;
    end;

    frxrprtBase.ShowReport;
  end;
end;

procedure TfrmBaseDBGrid.MoveDown;
begin
  Table.DataSource.DataSet.Prior;
  SetSelectedItem();
end;

procedure TfrmBaseDBGrid.MoveUp;
begin
  Table.DataSource.DataSet.Next;
  SetSelectedItem();
end;

procedure TfrmBaseDBGrid.pmDBChange(Sender: TObject; Source: TMenuItem; Rebuild: Boolean);
begin
//
end;

procedure TfrmBaseDBGrid.pmDBPopup(Sender: TObject);
begin
  SetSelectedItem();
end;

procedure TfrmBaseDBGrid.RefreshData;
begin
//  if (ParentForm <> nil) then//and (ParentForm.Parent.Name = 'TfrmBaseDBGrid') then
//    Table.DataSource.DataSet.Refresh;

  if (Table <> nil) and (Table.Id.Value > 0) then
    grd.DataSource.DataSet.Locate(Table.Id.FieldName, Table.Id.Value,[]);

  if FFiltreGrid.Text <> '' then
  begin
    grd.DataSource.DataSet.Filter := FFiltreGrid.Text;
    grd.DataSource.DataSet.Filtered := True;
    mnifilter_remove.Visible := True;
    mnifilter_back.Visible := True;
  end
  else
  begin
    grd.DataSource.DataSet.Filtered := False;
    grd.DataSource.DataSet.Filter := '';
    mnifilter_remove.Visible := False;
    mnifilter_back.Visible := False;
  end;

  RefreshGrid;
end;

procedure TfrmBaseDBGrid.RefreshDataFirst();
var
  AField: TField;
  AFieldDB: TFieldDB;
  ACol: TColumn;
  AGridCols: TObjectList<TSysGridKolon>;
  n1, n2, n3, vHaneSayisi: Integer;

  LColPercent: TColPercent;
  LColColor: TColColor;

  LTableName: string;
  LColName: string;
  LKolonVar: Boolean;
  LNumberOfVisibleColumns: Integer;

  function ExistsGridColumn(AFieldName: string): Boolean;
  var
    nx: Integer;
  begin
    Result := False;
    for nx := 0 to grd.Columns.Count-1 do
    begin
      if AFieldName = grd.Columns.Items[nx].FieldName then
      begin
        Result := True;
        Break;
      end;
    end;
  end;

  procedure AddColumn(AFieldName, ATitle: string; AVisible: Boolean=False);
  begin
    with grd.Columns.Add do
    begin
      FieldName := AFieldName;
      Title.Caption := ATitle;
      //Title.Caption := GetTextFromLang(Title.Caption, ReplaceRealColOrTableNameTo(FieldName), LngGridFieldCaption, ReplaceRealColOrTableNameTo(Table.TableName));
      Title.Color := clBlack;
      Title.Font.Color := clBlack;
      Title.Font.Style := [fsBold];
      Title.Alignment := TAlignment.taCenter;
      Visible := AVisible;
    end;
  end;

  procedure SetDisplayFormat(AFieldDB: TFieldDB; AGridField: TField; AGridKolonProp: TSysGridKolon);
  begin
    if((AFieldDB.DataType = Data.DB.ftSmallint)
    or (AFieldDB.DataType = Data.DB.ftInteger)
    or (AFieldDB.DataType = Data.DB.ftLargeint)
    or (AFieldDB.DataType = Data.DB.ftWord)
    or (AFieldDB.DataType = Data.DB.ftLongWord))
    and (AFieldDB.FieldName <> 'id')
    then
    begin
      TIntegerField(AGridField).DisplayFormat := '0';
      if AGridKolonProp.DataFormat.Value <> '' then
        TIntegerField(AGridField).DisplayFormat := AGridKolonProp.DataFormat.Value;
    end
    else
    if (AFieldDB.DataType = Data.DB.ftFloat)
    or (AFieldDB.DataType = Data.DB.ftBCD)
    then
    begin
      TFloatField(AGridField).DisplayFormat := '#' + FormatSettings.DecimalSeparator + StringOfChar('#', vHaneSayisi) + '0' + FormatSettings.ThousandSeparator + StringOfChar('0', vHaneSayisi);
      if AGridKolonProp.DataFormat.Value <> '' then
        TFloatField(AGridField).DisplayFormat := AGridKolonProp.DataFormat.Value;
    end
    else if (AFieldDB.DataType = Data.DB.ftDate) then
    begin
      TDateField(AGridField).DisplayFormat := 'dd' + FormatSettings.DateSeparator + 'mm' + FormatSettings.DateSeparator + 'yyyy';
      if AGridKolonProp.DataFormat.Value <> '' then
        TDateField(AGridField).DisplayFormat := AGridKolonProp.DataFormat.Value;
    end
    else if (AFieldDB.DataType = Data.DB.ftTime) then
    begin
      TDateField(AGridField).DisplayFormat := 'hh' + FormatSettings.TimeSeparator + 'nn' + FormatSettings.DateSeparator + 'ss';
      if AGridKolonProp.DataFormat.Value <> '' then
        TDateField(AGridField).DisplayFormat := AGridKolonProp.DataFormat.Value;
    end
    else if (AFieldDB.DataType = Data.DB.ftDateTime) then
    begin
      TDateField(AGridField).DisplayFormat := 'dd' + FormatSettings.DateSeparator + 'mm' + FormatSettings.DateSeparator + 'yyyy' + ' ' +
                                              'hh' + FormatSettings.TimeSeparator + 'nn' + FormatSettings.DateSeparator + 'ss';
      if AGridKolonProp.DataFormat.Value <> '' then
        TDateField(AGridField).DisplayFormat := AGridKolonProp.DataFormat.Value;
    end;
  end;

begin
  Table.DataSource.DataSet.DisableControls;
  AGridCols := TObjectList<TSysGridKolon>.Create(False);
  try
    Table.DataSource.OnDataChange := DataSourceDataChange;
    FQryFiltreVarsayilan := ' ' + Trim(FQryFiltreVarsayilan);

    if Pos(' ORDER BY ', FQrySiralamaVarsayilan) = 0 then
      FQrySiralamaVarsayilan := Trim(FQrySiralamaVarsayilan);
    if FQrySiralamaVarsayilan <> '' then
    begin
      if Pos(' ORDER BY ', FQrySiralamaVarsayilan) = 0 then
        FQrySiralamaVarsayilan := ' ORDER BY ' + Trim(FQrySiralamaVarsayilan);
    end
    else
      FQrySiralamaVarsayilan := ' ORDER BY 1 ASC ';

    if Table.TableName = '' then
    begin
      spDS := GDataBase.NewStoredProcedure();
      grd.DataSource.DataSet := spDS;
      spDS.StoredProcName := 'sp_get_ch_hesap_karti';
      spDS.Prepare;
      spDS.ParamByName('pfilter').Text := FQryFiltreVarsayilan + FQryFiltreVarsayilanKullanici + FQrySiralamaVarsayilan;
      spDS.ParamByName('plang').Text := GDataBase.ConnSetting.Language;
      spDS.Open;
    end
    else
    begin
      //helper formu ise hak kontrolü yapma.
      Table.SelectToDatasource(FQryFiltreVarsayilan + FQryFiltreVarsayilanKullanici + FQrySiralamaVarsayilan, False, False, FIsHelper);
    end;


    //sayısal bilgilerde otomatik formatlama ve kolonların çıkma sırasını ayarla işlemini yap
    vHaneSayisi := 2;
    if FormOndalikMod = fomBuying then
      vHaneSayisi := FormatedVariantVal(GSysOndalikHane.AlimFiyat)
    else if FormOndalikMod = fomSale  then
      vHaneSayisi := FormatedVariantVal(GSysOndalikHane.SatisFiyat)
    else if FormOndalikMod = fomStock then
      vHaneSayisi := FormatedVariantVal(GSysOndalikHane.StokMiktar);


    for n2 := 0 to Table.QueryOfDS.FieldCount-1 do
    begin
      if not ExistsGridColumn(Table.QueryOfDS.Fields.Fields[n2].FieldName) then
      begin  AFieldDB := Table.GetFieldByFieldName(Table.QueryOfDS.Fields.Fields[n2].FieldName);
        if AFieldDB <> nil then
          AddColumn(Table.QueryOfDS.Fields.Fields[n2].FieldName, AFieldDB.Title);
      end;
    end;


    LTableName := ReplaceRealColOrTableNameTo(Table.TableName);
    for n1 := 0 to GGridColWidth.List.Count-1 do
      if TSysGridKolon(GGridColWidth.List[n1]).TabloAdi.AsString = LTableName then
        AGridCols.Add(TSysGridKolon(GGridColWidth.List[n1]));

    LNumberOfVisibleColumns := 0;

    if AGridCols.Count = 0 then
    begin
      for n1 := 0 to grd.Columns.Count-1 do
        grd.Columns.Items[n1].Visible := True;
    end
    //burada görünmesi istenilen kolonları show yapıyoruz ve genişliğini ayarlıyoruz
    else
    begin
      for n1 := 0 to AGridCols.Count-1 do
      begin
        for n2 := 0 to grd.Columns.Count-1 do
        begin
          AField := grd.Columns.Items[n2].Field;
          ACol := grd.Columns.Items[n2];

          if  (TSysGridKolon(AGridCols[n1]).TabloAdi.AsString = LTableName)
          and (AField.FieldName = ReplaceToRealColOrTableName(VarToStr(FormatedVariantVal(TSysGridKolon(AGridCols[n1]).KolonAdi))))
          then
          begin
            Inc(LNumberOfVisibleColumns);
            AFieldDB := nil;
            if Table <> nil then
              AFieldDB := Table.GetFieldByFieldName(AField.FieldName);
            //display formatlarını ayarla
            if AFieldDB <> nil then
              SetDisplayFormat(AFieldDB, AField, TSysGridKolon(AGridCols[n1]));

            if Assigned(ACol) then
            begin
              with TSysGridKolon(AGridCols[n1]) do
              try
                ACol.Index := VarToInt(FormatedVariantVal(TSysGridKolon(AGridCols[n1]).SiraNo));
                ACol.Width := VarToInt(FormatedVariantVal(TSysGridKolon(AGridCols[n1]).Genislik));
                ACol.Visible := FormatedVariantVal(TSysGridKolon(AGridCols[n1]).IsGorunsun);
              except
                on E: Exception do
                begin
                  ShowMessage(E.Message + AddLBs(2) + ACol.FieldName + ' bulunamadı!');
                end;
              end;
            end;
            Break;
          end;
        end;
      end;


      //todo yüzdeli olarak renklendirme işlemini yap
      SetLength(FColoredPercentColNames, Table.DataSource.DataSet.FieldCount);
      for n1 := 0 to Length(FColoredPercentColNames)-1 do
      begin
        LColPercent.FieldName := '';
        LColPercent.MaxValue := 0;
        LColPercent.ColorBar := 0;
        LColPercent.ColorBarBack := 0;
        LColPercent.ColorBarText := 0;
        FColoredPercentColNames[n1] := LColPercent;
      end;

      for n3 := 0 to Length(FColoredPercentColNames)-1 do
        for n1 := 0 to AGridCols.Count-1 do
          for n2 := 0 to grd.Columns.Count-1 do
          begin
            LColName := TSysGridKolon(AGridCols[n1]).KolonAdi.AsString;
            if  (TSysGridKolon(AGridCols[n1]).TabloAdi.AsString = LTableName)
            and (ReplaceToRealColOrTableName(LColName) = grd.Columns.Items[n2].FieldName)
            then
            begin
              LColPercent.FieldName := LColName;
              LColPercent.MaxValue := TSysGridKolon(AGridCols[n1]).MaksDegerYuzde.AsFloat;
              LColPercent.ColorBar := TSysGridKolon(AGridCols[n1]).RenkBar.AsInteger;
              LColPercent.ColorBarBack := TSysGridKolon(AGridCols[n1]).RenkBarArka.AsInteger;
              LColPercent.ColorBarText := TSysGridKolon(AGridCols[n1]).RenkBarYazi.AsInteger;
              FColoredPercentColNames[n3] := LColPercent;
            end;
          end;


      //todo sayısal renklendirme işlemini yap
      SetLength(FColoredNumericColNames, LNumberOfVisibleColumns);
      for n1 := 0 to Length(FColoredNumericColNames)-1 do
      begin
        LColColor.FieldName := '';
        LColColor.MinValue := 0;
        LColColor.MinColor := 0;
        LColColor.MaxValue := 0;
        LColColor.MaxColor := 0;
        LColColor.EqualColor := 0;
        FColoredNumericColNames[n1] := LColColor;
      end;

      //progress bar gibi renklendirme boyama işlemi yap
      for n3 := 0 to Length(FColoredNumericColNames)-1 do
      for n1 := 0 to AGridCols.Count-1 do
      begin
        if (TSysGridKolon(AGridCols[n1]).TabloAdi.AsString = LTableName) then
        begin
          LColName := TSysGridKolon(AGridCols[n1]).KolonAdi.AsString;
          LColColor.FieldName := ReplaceToRealColOrTableName(LColName);
          LColColor.MinValue := TSysGridKolon(AGridCols[n1]).MinDeger.AsInteger;
          LColColor.MinColor := TSysGridKolon(AGridCols[n1]).MinRenk.AsInteger;
          LColColor.MaxValue := TSysGridKolon(AGridCols[n1]).MaksDeger.AsInteger;
          LColColor.MaxColor := TSysGridKolon(AGridCols[n1]).MaksRenk.AsInteger;
          LColColor.EqualColor := clOlive;
          FColoredNumericColNames[n3] := LColColor;
        end;
      end;
    end;


  //summary alt toplamları getir form showda varsa bunları göster
//      AGridColSummary := TSysGridColWidth.Create(Table.Database);
//      try
//        AGridColSummary.SelectToList(
//            ' AND ' + AGridColSummary.TableName + '.' + AGridColSummary.TableAdi.FieldName + '=' +
//            QuotedStr(ReplaceRealColOrTableNameTo(Table.TableName)), False, False);
//
//        for n1 := 0 to AGridColSummary.List.Count-1 do
//          for n2 := 0 to grd.Columns.Count-1 do
//            if ReplaceToRealColOrTableName(TSysGridColWidth(AGridColSummary.List[n1]).KolonAdi.Value) = grdTVBase.Columns[n2].DataBinding.FieldName then
//            begin
//              grdTVBase.DataController.Summary.FooterSummaryItems.Add(
//                  grdTVBase.Columns[n2],
//                  spFooter,
//                  TcxSummaryKind(VarToStr(TSysGridColWidth(AGridColSummary.List[n1]).OzetTipi.Value).ToInteger),
//                  TSysGridColWidth(AGridColSummary.List[n1]).OzetFormat.Value);
//            end;
//      finally
//        AGridColSummary.Free;
//      end;


    if Table.Id.Value > 0 then
      grd.DataSource.DataSet.Locate(Table.Id.FieldName, Table.Id.Value,[]);

    SetTitleFromLangContent();

    RefreshGrid();
  finally
    AGridCols.Free;
    Table.DataSource.DataSet.EnableControls;
  end;
end;

procedure TfrmBaseDBGrid.RefreshGrid;
begin
  WriteRecordCount(grd.DataSource.DataSet.RecordCount);
end;

procedure TfrmBaseDBGrid.mnifilter_removeClick(Sender: TObject);
begin
  actfilter_removeExecute(Sender);
end;

function TfrmBaseDBGrid.ResizeDBGrid(Sender: TObject):Integer;
var
  nIndex, dGridWidth: Integer;
begin
  Result := 0;

  if Sender is TDBGrid then
  begin
    with TDBGrid(Sender)  do
    begin
      dGridWidth := 0;
      for nIndex := 0 to Columns.Count-1 do
        if Columns[nIndex].Visible then
          dGridWidth := dGridWidth + Columns[nIndex].Width + 1;

      if AlignWithMargins then
        dGridWidth := dGridWidth + Margins.Left + Margins.Right;

      //çıkan indicator için width bunun kontrolü eklenmeli. Şimdilik sabit bilgi olarak girildi
      if dgIndicator in Options then
        dGridWidth := dGridWidth + IndicatorWidth;

      //çıkan scroll için width bunun kontrolü eklenmeli. Şimdilik sabit bilgi olarak girildi
      dGridWidth := dGridWidth + 40;

      Width := dGridWidth;
    end;

    Result := dGridWidth;
  end;
end;

procedure TfrmBaseDBGrid.ResizeForm;
var
  nDBGridHeight, nClientWidth : Integer;
begin
  Self.Enabled := False;
  grd.Enabled := False;
  try
    nClientWidth := ResizeDBGrid(grd);
    if pnlContent.AlignWithMargins then
      nClientWidth := nClientWidth + pnlContent.Margins.Left + pnlContent.Margins.Right;

    if pnlLeft.Visible then
    begin
      nClientWidth := nClientWidth + pnlLeft.Width;
      if pnlLeft.AlignWithMargins then
        nClientWidth := nClientWidth + pnlLeft.Margins.Left + pnlLeft.Margins.Right;
    end;

    if splLeft.Visible then
    begin
      nClientWidth := nClientWidth + splLeft.Width;
      if splLeft.AlignWithMargins then
        nClientWidth := nClientWidth + splLeft.Margins.Left + splLeft.Margins.Right;
    end;

    if pnlMain.AlignWithMargins then
      nClientWidth := nClientWidth + pnlMain.Margins.Left + pnlMain.Margins.Right;

    //form kenarlıkları için windows temadan gelen
    nClientWidth := nClientWidth + 4;

    ClientWidth := System.Math.Min(nClientWidth, Screen.Width-100);
    Self.Left := (Screen.Width-ClientWidth) div 2;


    nDBGridHeight := 0;
    if pnlHeader.Visible then
    begin
      nDBGridHeight := nDBGridHeight + pnlHeader.Height;
      if pnlHeader.AlignWithMargins then
        nDBGridHeight := nDBGridHeight + pnlHeader.Margins.Top + pnlHeader.Margins.Bottom;
    end;

    if splHeader.Visible then
    begin
      nDBGridHeight := nDBGridHeight + splHeader.Height;
      if splHeader.AlignWithMargins then
        nDBGridHeight := nDBGridHeight + splHeader.Margins.Top + splHeader.Margins.Bottom;
    end;

    if pnlBottom.Visible then
    begin
      nDBGridHeight := nDBGridHeight + pnlBottom.Height;
      if pnlBottom.AlignWithMargins then
        nDBGridHeight := nDBGridHeight + pnlBottom.Margins.Top + pnlBottom.Margins.Bottom;
    end;

    if pnlButtons.Visible then
    begin
      nDBGridHeight := nDBGridHeight + pnlButtons.Height;
      if pnlButtons.AlignWithMargins then
        nDBGridHeight := nDBGridHeight + pnlButtons.Margins.Top + pnlButtons.Margins.Bottom;
    end;

    if stbBase.Visible then
    begin
      nDBGridHeight := nDBGridHeight + stbBase.Height;
      if stbBase.AlignWithMargins then
        nDBGridHeight := nDBGridHeight + stbBase.Margins.Top + stbBase.Margins.Bottom;
    end;

    ClientHeight := nDBGridHeight;

    //form kenarlıkları için windows temadan gelen
//    ClientHeight := nDBGridHeight + 4;

    //Toplam 20 adet kayıt görünmesi için 20+1 * 20 satır yüksekliği yapıyoruz (+1 başlık için)
    nDBGridHeight := nDBGridHeight + (21*20);

    ClientHeight := System.Math.Min(nDBGridHeight, Screen.Height-100);
  finally
    grd.Invalidate;
    grd.Enabled := True;
    Self.Invalidate;
    Self.Enabled := True;
  end;
end;

procedure TfrmBaseDBGrid.SelectCurrentRecord;
begin
  FDataAktar := True;
  if grd.DataSource.DataSet.RecordCount > 0 then
  begin
    SetSelectedItem;
    Table.SelectToList(' AND ' + Table.Id.QryName + '=' + IntToStr(Table.Id.Value), False, False);
    TableHelper := Table.Clone;
  end;
  btnCloseClick(btnClose);
end;

procedure TfrmBaseDBGrid.SetColVisible(pFieldName: string; pVisible: Boolean);
var
  n1: Integer;
begin
  for n1 := 0 to grd.Columns.Count-1 do
  begin
    if grd.Columns.Items[n1].FieldName = pFieldName then
    begin
      grd.Columns.Items[n1].Visible := pVisible;
      break;
    end;
  end;
end;

procedure TfrmBaseDBGrid.SetSelectedItem;
var
  AField: TField;
  n1, n2: Integer;
begin
  if grd.DataSource.DataSet.RecordCount > 0 then
  begin
    if not FIsHelper then
    begin
      AField := grd.DataSource.DataSet.FindField(Table.Id.FieldName);
      if not Assigned(AField) or (AField = nil) or AField.IsNull then
        Exit;

      Table.Id.Value := VarToStr(AField.Value).ToInteger;
    end;


    for n1 := 0 to Length(Table.Fields)-1 do
    begin
      for n2 := 0 to grd.Columns.Count-1 do
      begin
        if Table.Fields[n1].FieldName = grd.Columns.Items[n2].Field.FieldName then
        begin
          Table.Fields[n1].Value := grd.Columns.Items[n2].Field.Value;
          Table.Fields[n1].IsNullable := not grd.Columns.Items[n2].Field.Required;
          Break;
        end;
      end;
    end;
  end;
end;

procedure TfrmBaseDBGrid.SetTitleFromLangContent;
var
  n1, n2: Integer;
  vLangVal: TSysLisanGuiIcerik;
begin
  if Assigned(Table) then
  begin
    vLangVal := TSysLisanGuiIcerik.Create(Table.Database);
    try
      vLangVal.SelectToList(
          ' AND ' + vLangVal.TableName + '.' + vLangVal.TabloAdi.FieldName + '=' + QuotedStr(Table.TableName) +
          ' AND ' + vLangVal.TableName + '.' + vLangVal.Lisan.FieldName + '=' + QuotedStr(GDataBase.ConnSetting.Language) +
          ' AND ' + vLangVal.TableName + '.' + vLangVal.IcerikTipi.FieldName + '=' + QuotedStr(LngDGridFieldCaption), False, False);
      for n1 := 0 to vLangVal.List.Count-1 do
        for n2 := 0 to grd.Columns.Count - 1 do
          if grd.Columns.Items[n2].FieldName = TSysLisanGuiIcerik(vLangVal.List[n1]).Kod.Value then
            grd.Columns.Items[n2].Title.Caption := TSysLisanGuiIcerik(vLangVal.List[n1]).Deger.Value;

    finally
      vLangVal.Free;
    end;
  end;
end;

procedure TfrmBaseDBGrid.ShowInputForm(Sender: TObject; pFormType: TInputFormMode);
var
  LForm: TForm;
begin
  if (pFormType = ifmRewiev)
  or ((not GDatabase.Connection.InTransaction) and ((pFormType = ifmNewRecord) or (pFormType = ifmCopyNewRecord)))
  then
  begin
    if (pFormType = ifmRewiev) or (pFormType = ifmCopyNewRecord) then
      Table.LogicalSelect(' AND ' + Table.Id.QryName + '=' + IntToStr(Table.Id.Value), False, False, False);

    LForm := CreateInputForm(Sender, pFormType);
    if Table is TTableDetailed then
      TTableDetailed(Table).FreeDetayListContent;
    LForm.Show;
  end
  else
    raise Exception.Create(
      TranslateText('Başka bir pencere giriş veya güncelleme için açılmış, önce bu işlemi tamamlayın.',
                    FrameworkLang.WarningOpenWindow, LngMsgWarning, LngSystem));
end;

procedure TfrmBaseDBGrid.StatusBarDuzenle;
var
  vQualityFormNo: string;

  procedure addPanel(AWidth: Integer; AStyle: TStatusPanelStyle);
  begin
    with stbBase.Panels.Add do
    begin
      Width := AWidth;
      Style := AStyle;
    end;
  end;

begin
  //output formlar için status bar içeriği
  //kayıt sayısı | server ip adresi | dönem | firma adı | kalite form numaraları olacak şekilde kullanılıyor.
  //Toplam: 2 | 127.0.0.1 | Dönem 2018 | Firma Adı | KaliteForm No

  addPanel(80, psOwnerDraw);
  addPanel(80, psOwnerDraw);
  addPanel(80, psOwnerDraw);
  addPanel(80, psOwnerDraw);
  addPanel(80, psOwnerDraw);

  //Gösterilen Toplam Kayıt Sayısını status bara yaz. Paneli kayıt sayısı yazman anında ekleniyor
  if GDataBase.Connection.Connected then
    WriteRecordCount(grd.DataSource.DataSet.RecordCount);

  //Server Adresini status bara yaz
  if GDataBase.Connection.Connected then
    stbBase.Panels.Items[STATUS_DATE].Text := GDataBase.ConnSetting.SQLServer;

  //donem bilgsini status bara yaz
  stbBase.Panels.Items[STATUS_USERNAME].Text := TranslateText('Dönem', FrameworkLang.GeneralPeriod, LngGeneral, LngSystem) + ' ' +
                                                   VarToStr(GSysUygulamaAyari.Donem.Value);

  //firma ünvan
  if GDataBase.Connection.Connected then
    stbBase.Panels.Items[STATUS_KEY_F4].Text := GSysUygulamaAyari.Unvan.AsString;

  //Form Numarası status bara yaz
  if GDataBase.Connection.Connected then
  begin
    stbBase.Panels.Add;
    vQualityFormNo := GetKaliteFormNo(Table.TableName, QtyOutput);
    if vQualityFormNo <> '' then
      stbBase.Panels.Items[STATUS_KEY_F5].Text := vQualityFormNo
    else
      stbBase.Panels.Items[STATUS_KEY_F5].Text := '';
  end;
end;

procedure TfrmBaseDBGrid.stbBaseDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
var
  vIco: Integer;
begin
  stbBase.Canvas.Font.Name := DefaultFontName;
  stbBase.Canvas.Font.Style := [fsBold];

  stbBase.Canvas.TextRect(Rect,
    Rect.Left + dm.il16.Width + 4,
    Rect.Top + (stbBase.Height-Canvas.TextHeight(Panel.Text)) div 2 - 2,
    Panel.Text);

  vIco := -1;
  case Panel.Index of
    STATUS_SQL_SERVER: vIco := IMG_SUM;
    STATUS_DATE: vIco := IMG_SERVER;
    STATUS_USERNAME: vIco := IMG_CALENDAR;
    STATUS_KEY_F4: vIco := IMG_CUSTOMER;
    STATUS_KEY_F5:
    begin
      if Panel.Text <> '' then
        vIco := IMG_QUALITY
      else
        vIco := -1;
    end;
  end;

  if vIco > -1 then
  begin
    dm.il16.Draw(StatusBar.Canvas, Rect.Left, Rect.Top, vIco);
    Panel.Width := stbBase.Canvas.TextWidth(Panel.Text)+ dm.il16.Width + 8;
  end;
end;

procedure TfrmBaseDBGrid.Timer1Timer(Sender: TObject);
begin
  //
end;

procedure TfrmBaseDBGrid.TransferToExcel(AAllColumn: Boolean = False);
var
  ExcelApplication, Sheet: Variant;
  LRecPozisyon: Integer;
  LColCount, LRow, LRowCount, LWidth: Integer;
  ADataSet: TDataSet;
  LDosyaAdi, LRange: string;
  n1: Integer;
begin
  dlgSave.Filter := FILE_FILTER_XLSX;
  dlgSave.DefaultExt := FILE_EXT_XLSX;
  dlgSave.FileName := Self.Caption + ' ' + DateToStr(Table.Database.GetToday);
  dlgSave.InitialDir := '%USERPROFILE%\desktop';
  if not dlgSave.Execute then
    Exit;

  LDosyaAdi := dlgSave.FileName;

  Cursor := crHourGlass;
  try
    ExcelApplication := CreateOleObject('Excel.Application');
    ExcelApplication.Visible := False;
  except
    Showmessage('Excel dosya oluşturulamadı,' + AddLBs(2) +
                'Bilgisayarında Microsoft Excel kurulu olduğundan emin misin?');
    Exit;
  end;
  ADataSet := grd.DataSource.DataSet;

  ADataSet.DisableControls;
  LRowCount := ADataSet.RecordCount;
  LRecPozisyon := ADataSet.RecNo;
  try
    ADataSet.RecNo := 1;

    ExcelApplication.WorkBooks.Add(-4167);   //Add excel workbook
    ExcelApplication.WorkBooks[1].WorkSheets[1].Name := 'Sayfa1';
    Sheet := ExcelApplication.WorkBooks[1].WorkSheets['Sayfa1'];

    LColCount := 0;
    for n1 := 0 to grd.Columns.Count-1 do
      if grd.Columns.Items[n1].Visible or AAllColumn then
        Inc(LColCount);

    LRange := 'A1:' + Chr(64 + LColCount) + IntToStr(LRowCount+1);
    //Col names A..Z total 26 cols After 27 col start again AA, AB ..
    if LColCount > 26 then
      LRange := 'A1:' + Chr(64 + LColCount div 26) + Chr(64 + LColCount mod 26) + IntToStr(LRowCount+1);

    //Format cells in excel sheet
    Sheet.Range[LRange].Borders.LineStyle := 7; //line style
    Sheet.Range[LRange].Borders.color := clGray;

    LColCount := 0;
    for n1 := 0 to grd.Columns.Count-1 do
      if grd.Columns.Items[n1].Visible or AAllColumn then
      begin
        Inc(LColCount);
        Sheet.Cells[1, LColCount].Interior.Color := $004FA7FF; //grd.Columns.Items[n1].Title.Color;
        Sheet.Cells[1, LColCount].Font.Bold := fsBold in grd.Columns.Items[n1].Title.Font.Style;
        Sheet.Cells[1, LColCount] := grd.Columns.Items[n1].Title.Caption;

        LWidth := grd.Columns.Items[n1].Width;
        if LWidth = -1 then
          LWidth := 60;
        Sheet.Columns[LColCount].ColumnWidth := (((LWidth / 28) * 5.1425) - 0.71);

        if (grd.Columns.Items[n1].Field.DataType = ftBcd)
        or (grd.Columns.Items[n1].Field.DataType = ftFMTBcd)
        then
          Sheet.Columns[LColCount].NumberFormat := '_-* #.##0,00 _₺_-;-* #.##0,00 _₺_-;_-* "-"?? _₺_-;_-@_-'
      end;

    pb1.Max := ADataSet.RecordCount;
    pb1.Position := 0;
    pb1.Visible := True;

    //now copy from table to excel cells
    for LRow := 1 to ADataSet.RecordCount do
    begin
      LColCount := 0;
      for n1 := 0 to grd.Columns.Count-1 do
        if grd.Columns[n1].Visible or AAllColumn then
        begin
          Inc(LColCount);
          if (ADataSet.FieldByName(grd.Columns[n1].FieldName).DataType = ftString)
          or (ADataSet.FieldByName(grd.Columns[n1].FieldName).DataType = ftWideString)
          then
            Sheet.Cells[LRow+1, LColCount] := ADataSet.FieldByName(grd.Columns[n1].FieldName).AsString
          else
          if (ADataSet.FieldByName(grd.Columns[n1].FieldName).DataType = ftLargeint)
          or (ADataSet.FieldByName(grd.Columns[n1].FieldName).DataType = ftInteger)
          or (ADataSet.FieldByName(grd.Columns[n1].FieldName).DataType = ftSmallint)
          or (ADataSet.FieldByName(grd.Columns[n1].FieldName).DataType = ftShortint)
          or (ADataSet.FieldByName(grd.Columns[n1].FieldName).DataType = ftWord)
          then
            Sheet.Cells[LRow+1, LColCount] := ADataSet.FieldByName(grd.Columns[n1].FieldName).AsInteger
          else
          if (ADataSet.FieldByName(grd.Columns[n1].FieldName).DataType = ftDate)
          or (ADataSet.FieldByName(grd.Columns[n1].FieldName).DataType = ftDateTime)
          then
            Sheet.Cells[LRow+1, LColCount] := ADataSet.FieldByName(grd.Columns[n1].FieldName).AsDateTime
          else if (ADataSet.FieldByName(grd.Columns[n1].FieldName).DataType = ftBoolean) then
            Sheet.Cells[LRow+1, LColCount] := ADataSet.FieldByName(grd.Columns[n1].FieldName).AsBoolean
          else
          if (ADataSet.FieldByName(grd.Columns[n1].FieldName).DataType = ftBCD)
          or (ADataSet.FieldByName(grd.Columns[n1].FieldName).DataType = ftFMTBcd)
          then
            Sheet.Cells[LRow+1, LColCount] := ADataSet.FieldByName(grd.Columns[n1].FieldName).AsFloat
          else if (ADataSet.FieldByName(grd.Columns[n1].FieldName).DataType = ftFloat) then
            Sheet.Cells[LRow+1, LColCount] := ADataSet.FieldByName(grd.Columns[n1].FieldName).AsFloat
          else if (ADataSet.FieldByName(grd.Columns[n1].FieldName).DataType = ftCurrency) then
            Sheet.Cells[LRow+1, LColCount] := ADataSet.FieldByName(grd.Columns[n1].FieldName).AsCurrency
        end;
      pb1.Position := LRow;
      ADataSet.Next;
    end;

    DeleteFile(LDosyaAdi);
    Sheet.SaveAs(LDosyaAdi);

    ExcelApplication.Visible := True;
//    ExcelApplication.Quit; //Quit excel
    ExcelApplication := Unassigned;
    Sheet := Unassigned;
  finally
    pb1.Visible := False;
    pb1.Position := 0;
    Screen.Cursor := crDefault;
    ADataSet.RecNo := LRecPozisyon;
    ADataSet.EnableControls;
  end;
end;

procedure TfrmBaseDBGrid.TransferToExcelAll();
//var
//  vFileName: string;
var
//  nR: Integer;
  nC: Integer;
//  SaveDialogExcelFile:TSaveDialog;
  strTemp:string;
//  dTemp:double;

//  strFileName:string;
//  rs:TResourceStream;
//  nVisilbeColCount:integer;
//  nVisibleColNumber:array of integer;
//  qry: TFDQuery;
  ATable: TTable;
  AGridFilter: string;
//  OpenWithControl: Boolean;
  //dxSpreadSheet1: TdxSpreadSheet;
begin
//  OpenWithControl := isCtrlDown;

  dlgSave.Filter := FILE_FILTER_XLSX;
  dlgSave.DefaultExt := FILE_EXT_XLSX;
  dlgSave.FileName := Self.Caption + ' ' + DateToStr(Table.Database.GetToday);
  dlgSave.InitialDir := '%USERPROFILE%\desktop';
  if not dlgSave.Execute then
    Exit;


  AGridFilter := '';
  if grd.DataSource.DataSet.Filter <> '' then
    AGridFilter := ' AND ' + grd.DataSource.DataSet.Filter;
  if (Table.QueryOfDS.Filter <> '') then
    if (UpperCase(Trim(LeftStr(Table.QueryOfDS.Filter, 5))) = 'AND') then
      AGridFilter := Table.QueryOfDS.Filter + AGridFilter
    else
      AGridFilter := ' AND ' + Table.QueryOfDS.Filter + AGridFilter;

  ATable := Table.Clone;
  ATable.SelectToDatasource(AGridFilter, False, True, False);
  ATable.QueryOfDS.DisableControls;
  try
    for nC := 0 to ATable.QueryOfDS.FieldCount-1 do
    begin
//      if OpenWithControl then
//        ATable.QueryOfDS.Fields.Fields[nC].DisplayName + '['+ATable.QueryOfDS.Fields.Fields[nC].FieldName+']';
//
//      dxSpreadSheet1.ActiveSheetAsTable.Columns.Items[0].Cells
//      Font.Style := [fsBold];
//      AlignHorz := ssahCenter;
//      AlignVert := ssavCenter;
//      BackgroundColor := clLtGray;
    end;

//    nR := 1;
    ATable.QueryOfDS.First;
    while not ATable.QueryOfDS.Eof do
    begin
      for nC := 0 to ATable.QueryOfDS.FieldCount-1 do
      begin
        strTemp := '';
        if (ATable.QueryOfDS.Fields.Fields[nC].Value <> null) then
          strTemp := ATable.QueryOfDS.Fields.Fields[nC].Value;

        if (ATable.QueryOfDS.Fields.Fields[nC].DataType = ftDate)
        or (ATable.QueryOfDS.Fields.Fields[nC].DataType = ftTimeStamp)
        then
        begin
          if strTemp <> '' then
          begin
            StrToDateTime(strTemp);
//            FormatCode := 'DD.MM.YYYY';
          end;
        end
        else
        if ATable.QueryOfDS.Fields.Fields[nC].DataType = ftFloat then
        begin
          if strTemp <> '' then
          begin
//            dTemp := StrToFloat(strTemp);
//            AsFloat := dTemp;
//            FormatCode := '0.00';
          end;
        end
        else
        if ATable.QueryOfDS.Fields.Fields[nC].DataType = ftCurrency then
//          AsString := strTemp
        else
        if (ATable.QueryOfDS.Fields.Fields[nC].DataType = ftInteger)
        or (ATable.QueryOfDS.Fields.Fields[nC].DataType = ftSmallint)
        then
        begin
          if strTemp <> '' then
          begin
//            AsInteger := StrToInt(strTemp);
//            FormatCode := '0';
          end;
        end
        else
        if ATable.QueryOfDS.Fields.Fields[nC].DataType = ftString then
//          AsString := strTemp
        else
//          AsString := strTemp
      end;
      ATable.QueryOfDS.Next;
//      Inc(nR);
    end;

//    for nC := 0 to dxSpreadSheet1.ActiveSheetAsTable.Columns.Count-1 do
//      dxSpreadSheet1.ActiveSheetAsTable.Columns.Items[nC].ApplyBestFit;
//
//    dxSpreadSheet1.SaveToFile(dlgSave.FileName);
  finally
    FreeAndNil(ATable);
  end;
end;

procedure TfrmBaseDBGrid.WmAfterShow(var Msg: TMessage);
//var
//  n1: Integer;
begin
  if FIsHelper then
  begin
    edtFilterHelperChange(edtFilterHelper);
  end;
//  inherited;

//  for n1 := 0 to grd.Columns.Count-1 do
//  begin
//    if grd.Columns.Items[n1].Visible then
//    begin
//      grdTitleClick(grd.Columns.Items[n1]);
//      mniRemoveSort.Click;
//      WriteRecordCount(Table.DataSource.DataSet.RecordCount);
//      Break;
//    end;
//  end;
  //Caption := FStopwatch.ElapsedMilliseconds.ToString;
end;

procedure TfrmBaseDBGrid.WriteRecordCount(pCount: Integer);
begin
  if (GDataBase.Connection.Connected) and (stbBase.Panels.Count > 0) then
    stbBase.Panels.Items[STATUS_SQL_SERVER].Text := TranslateText('Total', FrameworkLang.GeneralRecordCount, LngGeneral, LngSystem) + ': ' + pCount.ToString;
end;

{ ThreadRefresh }

constructor ThreadRefresh.Create(AOwner: TForm; ACreateSuspended: Boolean);
begin
  inherited Create(ACreateSuspended);
  FreeOnTerminate := True;
  NameThreadForDebugging('ThreadRefreshData');
  FOwner := AOwner;
end;

procedure ThreadRefresh.Execute;
var
  oConn: TPgConnection;
  sName, sParam: String;
  iProcID, n1: Integer;
  LRefresh: Boolean;
begin
  while not Terminated do
  try
    LRefresh := False;
    Sleep(100);
    if GDataBase.FDPhyPG.DriverIntf.ConnectionCount > 0 then
    begin
      for n1 := 0 to GDataBase.FDPhyPG.DriverIntf.ConnectionCount-1 do
      begin
        if GDataBase.FDPhyPG.DriverIntf.Connections[n1].CliObj <> nil then
        begin
          oConn := GDataBase.FDPhyPG.DriverIntf.Connections[n1].CliObj;
          if oConn.CheckForInput() then
            while oConn.ReadNotifies(sName, iProcID, sParam) do
              if sName = TfrmBaseDBGrid(FOwner).Table.TableName then
                LRefresh := True;
          Break;
        end;
      end;
    end;

    if LRefresh then
      Synchronize(TfrmBaseDBGrid(FOwner).RefreshData);
  except
    Terminate;
  end;
end;

end.
