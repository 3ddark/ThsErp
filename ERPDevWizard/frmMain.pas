unit frmMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.StrUtils,
  System.Classes,
  System.Math,
  System.Actions,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Grids,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.DBGrids,
  Vcl.ActnList,
  Data.DB,
  ZAbstractRODataset,
  ZAbstractDataset,
  ZDataset,
  ZAbstractConnection,
  ZConnection,
  Datasnap.DBClient;

const
  PROJECT_UNITNAME = 'Ths.Database.Table.';

  COL_ROW_NO = 0;
  COL_PROPERTY_NAME = 1;
  COL_FIELD_NAME = 2;
  COL_FIELD_TYPE = 3;
  COL_GRID_COL_CAPTION = 4;
  COL_INPUT_LABEL_CAPTION = 5;
  COL_GUI_CONTROL = 6;
  COL_CONTROL_TYPE = 7;

type
  TfrmMainClassGenerator = class(TForm)
    pnlTop: TPanel;
    pgcMemos: TPageControl;
    tsClass: TTabSheet;
    mmoClass: TMemo;
    tsOutput: TTabSheet;
    tsInput: TTabSheet;
    pnlClass: TPanel;
    btnAddClassToMemo: TButton;
    pnlOutputDFM: TPanel;
    mmoOutputDFM: TMemo;
    pnlOutputBottomDFM: TPanel;
    Splitter1: TSplitter;
    pnlOutputPAS: TPanel;
    mmoOutputPAS: TMemo;
    pnlOutputBottomPAS: TPanel;
    btnAddOutputPASToMemo: TButton;
    pnlInputDFM: TPanel;
    mmoInputDFM: TMemo;
    pnlInputBottomDFM: TPanel;
    Splitter2: TSplitter;
    pnlInputPAS: TPanel;
    mmoInputPAS: TMemo;
    pnlInputBottomPAS: TPanel;
    btnAddInputPASToMemo: TButton;
    Splitter3: TSplitter;
    pmBase: TPopupMenu;
    mniDeleteRow: TMenuItem;
    mniSaveToFile: TMenuItem;
    mniLoadFromFile: TMenuItem;
    pnlLeft: TPanel;
    Splitter4: TSplitter;
    dsTables: TDataSource;
    ActionList1: TActionList;
    actConnect: TAction;
    grdColumns: TDBGrid;
    lblhost_name: TLabel;
    lbldatabase_name: TLabel;
    lblport_name: TLabel;
    lbluser_name: TLabel;
    lblpassword: TLabel;
    lblschema_name: TLabel;
    edthost_name: TEdit;
    edtdatabase_name: TEdit;
    edtport_name: TEdit;
    edtuser_name: TEdit;
    edtpassword: TEdit;
    edtschema_name: TEdit;
    btnConnect: TButton;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lblInputFormCaption: TLabel;
    lblInputFormName: TLabel;
    lblOutputFormCaption: TLabel;
    lblOutputFormName: TLabel;
    lbltable_name: TLabel;
    btnSaveToFiles: TButton;
    edtClassType: TEdit;
    edtInputFormCaption: TEdit;
    edtInputFormName: TEdit;
    edtMainProjectDirectory: TEdit;
    edtOutputFormCaption: TEdit;
    edtOutputFormName: TEdit;
    edtSourceCode: TEdit;
    cbbtable_name: TComboBox;
    con1: TZConnection;
    dsColumns: TDataSource;
    cdsColumns: TClientDataSet;
    cdsColumnsfield_name: TStringField;
    cdsColumnsfield_type: TStringField;
    cdsColumnscolumn_caption: TStringField;
    cdsColumnsinput_caption: TStringField;
    cdsColumnsis_gui: TBooleanField;
    cdsColumnsinput_type: TStringField;
    cdsColumnsis_numeric: TBooleanField;
    procedure FormCreate(Sender: TObject);
    procedure btnAddClassToMemoClick(Sender: TObject);
    procedure btnSaveToFilesClick(Sender: TObject);
    procedure edtMainProjectDirectoryDblClick(Sender: TObject);
    procedure btnAddOutputPASToMemoClick(Sender: TObject);
    procedure btnAddInputPASToMemoClick(Sender: TObject);
    procedure mmoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure actConnectExecute(Sender: TObject);
    procedure cbbtable_nameChange(Sender: TObject);
    procedure GenerateClass;
    procedure GenerareOutput;
    procedure GenerateInput;
  private
    FQryColProp: TZQuery;
    FQryTableCol: TZQuery;
    FClass: TStringList;
    FOutputDfm: TStringList;
    FOutputPas: TStringList;
    FInputDfm: TStringList;
    FInputPas: TStringList;

    procedure FillTable;
    function GetDataTypeFromQry(Out IsNumeric: Boolean; AFieldName: string; AOnlyField: Boolean = False): string;
  end;

  function CapitalizeString(const s: string; const CapitalizeFirst: Boolean = True): string;

var
  frmMainClassGenerator: TfrmMainClassGenerator;

implementation

{$R *.dfm}

function CapitalizeString(const s: string; const CapitalizeFirst: Boolean = True): string;
const
  ALLOWEDCHARS = ['a'..'z', '_'];
var
  Index: Integer;
  bCapitalizeNext: Boolean;
begin
  bCapitalizeNext := CapitalizeFirst;
  Result := LowerCase(s);
  if Result <> EmptyStr then
    for Index := 1 to Length(Result) do
      if bCapitalizeNext then begin
        Result[Index] := UpCase(Result[Index]);
        bCapitalizeNext := False;
      end else
      if NOT CharInSet(Result[Index], ALLOWEDCHARS) then
        bCapitalizeNext := True;
end;

function TfrmMainClassGenerator.GetDataTypeFromQry(Out IsNumeric: Boolean; AFieldName: string; AOnlyField: Boolean = False): string;
const
  DEF_STR = ', ''''';
  DEF_NUM = ', 0';
  DEF_BOOL = ', True';
var
  n1: Integer;
begin
  IsNumeric := False;
  FQryTableCol.First;
  for n1 := 0 to FQryTableCol.Fields.Count-1 do
  begin
    if FQryTableCol.Fields.Fields[n1].FieldName = AFieldName then
    begin
      case FQryTableCol.Fields.Fields[n1].DataType of
        ftUnknown:
          begin
            Result := 'ftUnknown';
          end;
        ftString:
          begin
            Result := 'ftString' + IfThen(AOnlyField, '', DEF_STR);
          end;
        ftSmallint:
          begin
            Result := 'ftSmallint' + IfThen(AOnlyField, '', DEF_NUM);
            IsNumeric := True;
          end;
        ftInteger:
          begin
            Result := 'ftInteger' + IfThen(AOnlyField, '', DEF_NUM);
            IsNumeric := True;
          end;
        ftWord:
          begin
            Result := 'ftWord' + IfThen(AOnlyField, '', DEF_NUM);
            IsNumeric := True;
          end;
        ftBoolean:
          begin
            Result := 'ftBoolean' + IfThen(AOnlyField, '', DEF_BOOL);
          end;
        ftFloat:
          begin
            Result := 'ftFloat' + IfThen(AOnlyField, '', DEF_NUM);
            IsNumeric := True;
          end;
        ftCurrency:
          begin
            Result := 'ftCurrency' + IfThen(AOnlyField, '', DEF_NUM);
            IsNumeric := True;
          end;
        ftBCD:
          begin
            Result := 'ftBCD' + IfThen(AOnlyField, '', DEF_NUM);
            IsNumeric := True;
          end;
        ftDate:
          begin
            Result := 'ftDate' + IfThen(AOnlyField, '', DEF_NUM);
            IsNumeric := True;
          end;
        ftTime:
          begin
            Result := 'ftTime' + IfThen(AOnlyField, '', DEF_NUM);
            IsNumeric := True;
          end;
        ftDateTime:
          begin
            Result := 'ftDateTime' + IfThen(AOnlyField, '', DEF_NUM);
            IsNumeric := True;
          end;
        ftBytes:
          begin
            Result := 'ftBytes' + IfThen(AOnlyField, '', DEF_NUM);
          end;
        ftVarBytes:
          begin
            Result := 'ftVarBytes' + IfThen(AOnlyField, '', DEF_NUM);
          end;
        ftAutoInc:
          begin
            Result := 'ftAutoInc' + IfThen(AOnlyField, '', DEF_NUM);
          end;
        ftBlob:
          begin
            Result := 'ftBlob' + IfThen(AOnlyField, '', DEF_NUM);
          end;
        ftMemo:
          begin
            Result := 'ftMemo' + IfThen(AOnlyField, '', DEF_STR);
          end;
        ftGraphic:
          begin
            Result := 'ftGraphic' + IfThen(AOnlyField, '', DEF_NUM);
          end;
        ftFmtMemo:
          begin
            Result := 'ftFmtMemo' + IfThen(AOnlyField, '', DEF_STR);
          end;
        ftParadoxOle:
          begin
            Result := 'ftParadoxOle';
          end;
        ftDBaseOle:
          begin
            Result := 'ftDBaseOle';
          end;
        ftTypedBinary:
          begin
            Result := 'ftTypedBinary';
          end;
        ftCursor:
          begin
            Result := 'ftCursor';
          end;
        ftFixedChar:
          begin
            Result := 'ftFixedChar' + IfThen(AOnlyField, '', DEF_STR);
            IsNumeric := True;
          end;
        ftWideString:
          begin
            Result := 'ftWideString' + IfThen(AOnlyField, '', DEF_STR);
          end;
        ftLargeint:
          begin
            Result := 'ftLargeint' + IfThen(AOnlyField, '', DEF_NUM);
            IsNumeric := True;
          end;
        ftADT:
          begin
            Result := 'ftADT';
          end;
        ftArray:
          begin
            Result := 'ftArray';
          end;
        ftReference:
          begin
            Result := 'ftReference';
          end;
        ftDataSet:
          begin
            Result := 'ftDataSet';
          end;
        ftOraBlob:
          begin
            Result := 'ftOraBlob';
          end;
        ftOraClob:
          begin
            Result := 'ftOraClob';
          end;
        ftVariant:
          begin
            Result := 'ftVariant';
          end;
        ftInterface:
          begin
            Result := 'ftInterface';
          end;
        ftIDispatch:
          begin
            Result := 'ftIDispatch';
          end;
        ftGuid:
          begin
            Result := 'ftGuid';
          end;
        ftTimeStamp:
          begin
            Result := 'ftTimeStamp' + IfThen(AOnlyField, '', DEF_NUM);
            IsNumeric := True;
          end;
        ftFMTBcd:
          begin
            Result := 'ftFMTBcd' + IfThen(AOnlyField, '', DEF_NUM);
            IsNumeric := True;
          end;
        ftFixedWideChar:
          begin
            Result := 'ftFixedWideChar' + IfThen(AOnlyField, '', DEF_STR);
          end;
        ftWideMemo:
          begin
            Result := 'ftWideMemo' + IfThen(AOnlyField, '', DEF_STR);
          end;
        ftOraTimeStamp:
          begin
            Result := 'ftOraTimeStamp' + IfThen(AOnlyField, '', DEF_NUM);
            IsNumeric := True;
          end;
        ftOraInterval:
          begin
            Result := 'ftOraInterval' + IfThen(AOnlyField, '', DEF_NUM);
          end;
        ftLongWord:
          begin
            Result := 'ftLongWord' + IfThen(AOnlyField, '', DEF_NUM);
            IsNumeric := True;
          end;
        ftShortint:
          begin
            Result := 'ftShortint' + IfThen(AOnlyField, '', DEF_NUM);
            IsNumeric := True;
          end;
        ftByte:
          begin
            Result := 'ftByte' + IfThen(AOnlyField, '', DEF_NUM);
            IsNumeric := True;
          end;
        ftExtended:
          begin
            Result := 'ftExtended' + IfThen(AOnlyField, '', DEF_NUM);
            IsNumeric := True;
          end;
        ftConnection:
          begin
            Result := 'ftConnection';
          end;
        ftParams:
          begin
            Result := 'ftParams';
          end;
        ftStream:
          begin
            Result := 'ftStream';
          end;
        ftTimeStampOffset:
          begin
            Result := 'ftTimeStampOffset';
          end;
        ftObject:
          begin
            Result := 'ftObject';
          end;
        ftSingle:
          begin
            Result := 'ftSingle' + IfThen(AOnlyField, '', DEF_NUM);
            IsNumeric := True;
          end;
      end;
      Break;
    end;
  end;
end;

procedure TfrmMainClassGenerator.btnAddInputPASToMemoClick(Sender: TObject);
begin
  GenerateInput;
end;

procedure TfrmMainClassGenerator.btnAddOutputPASToMemoClick(Sender: TObject);
begin
  GenerareOutput;
end;

procedure TfrmMainClassGenerator.actConnectExecute(Sender: TObject);
begin
  if not con1.Connected then
  begin
    con1.Protocol := 'postgresql-9';
    con1.ClientCodepage := 'UTF8';
    con1.HostName := edthost_name.Text;
    con1.Port := StrToIntDef(edtport_name.Text, 5432);
    con1.Database := edtdatabase_name.Text;
    con1.User := edtuser_name.Text;
    con1.Password := edtpassword.Text;
    con1.LoginPrompt := False;

    con1.LibraryLocation := ExtractFilePath(Application.ExeName) + PathDelim + 'lib' + PathDelim + 'libpq.dll';
    try
      con1.Connect;
      actConnect.Caption := 'DisConnect';
      cbbtable_name.Enabled := True;
      FillTable;
    except
      ShowMessage('Veri tabaný ile baðlantý kurulmadý! Lütfen ayarlarýnýzý kontrol edin.');
    end;
  end
  else
  begin
    con1.Disconnect;
    actConnect.Caption := 'Connect';
    cbbtable_name.Enabled := False;
    cbbtable_name.Clear;
  end;
end;

procedure TfrmMainClassGenerator.GenerareOutput;
var
  LTipOut: string;
  LTipIn: string;
begin
  mmoOutputDFM.Clear;
  mmoOutputDFM.Lines.BeginUpdate;
  FOutputDfm.Text := '';
  LTipOut := 'T' + Copy(edtOutputFormName.Text, 2, Length(edtOutputFormName.Text)-1);
  LTipIn := 'T' + Copy(edtInputFormName.Text, 2, Length(edtInputFormName.Text)-1);
  try
    FOutputDfm.Add('inherited ' + MidStr(LTipOut, 2, Length(LTipOut)-1) + ': ' + LTipOut);
    FOutputDfm.Add('  Caption = ' + QuotedStr(edtOutputFormCaption.Text));
    FOutputDfm.Add('end');
  finally
    mmoOutputDFM.Lines.Text := FOutputDfm.Text;
    mmoOutputDFM.Lines.EndUpdate;
    mmoOutputPAS.Lines.EndUpdate;
  end;


  mmoOutputPAS.Lines.Clear;
  mmoOutputPAS.Lines.BeginUpdate;
  FOutputPas.Text := '';
  try
    FOutputPas.Add('unit ' + edtOutputFormName.Text + ';');
    FOutputPas.Add('');
    FOutputPas.Add('interface');
    FOutputPas.Add('');
    FOutputPas.Add('{$I Ths.inc}');
    FOutputPas.Add('');
    FOutputPas.Add('uses');
    FOutputPas.Add('  Winapi.Windows,');
    FOutputPas.Add('  Winapi.Messages,');
    FOutputPas.Add('  System.SysUtils,');
    FOutputPas.Add('  System.Variants,');
    FOutputPas.Add('  System.Types,');
    FOutputPas.Add('  System.Classes,');
    FOutputPas.Add('  System.Math,');
    FOutputPas.Add('  System.StrUtils,');
    FOutputPas.Add('  System.UITypes,');
    FOutputPas.Add('  System.Rtti,');
    FOutputPas.Add('  System.Diagnostics,');
    FOutputPas.Add('  System.TimeSpan,');
    FOutputPas.Add('  System.TypInfo,');
    FOutputPas.Add('  System.Actions,');
    FOutputPas.Add('  Vcl.ImgList,');
    FOutputPas.Add('  Vcl.Menus,');
    FOutputPas.Add('  Vcl.Graphics,');
    FOutputPas.Add('  Vcl.Controls,');
    FOutputPas.Add('  Vcl.Forms,');
    FOutputPas.Add('  Vcl.Dialogs,');
    FOutputPas.Add('  Vcl.ExtCtrls,');
    FOutputPas.Add('  Vcl.ComCtrls,');
    FOutputPas.Add('  Vcl.Grids,');
    FOutputPas.Add('  Vcl.DBGrids,');
    FOutputPas.Add('  Vcl.AppEvnts,');
    FOutputPas.Add('  Vcl.StdCtrls,');
    FOutputPas.Add('  Vcl.Samples.Spin,');
    FOutputPas.Add('  Vcl.Clipbrd,');
    FOutputPas.Add('  Vcl.ActnList,');
    FOutputPas.Add('  Data.DB,');
    FOutputPas.Add('  ZAbstractRODataset,');
    FOutputPas.Add('  ZAbstractDataset,');
    FOutputPas.Add('  ZDataset,');
    FOutputPas.Add('  ZAbstractConnection,');
    FOutputPas.Add('  ZConnection,');
    FOutputPas.Add('  Ths.Erp.Helper.BaseTypes,');
    FOutputPas.Add('  Ths.Erp.Helper.Edit,');
    FOutputPas.Add('  Ths.Erp.Helper.Memo,');
    FOutputPas.Add('  Ths.Erp.Helper.ComboBox,');
    FOutputPas.Add('  udm,');
    FOutputPas.Add('  ufrmBase,');
    FOutputPas.Add('  ufrmBaseDBGrid;');
    FOutputPas.Add('');
    FOutputPas.Add('type');
    FOutputPas.Add('  ' + LTipOut + ' = class(TfrmBaseDBGrid)');
    FOutputPas.Add('  protected');
    FOutputPas.Add('    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;');
    FOutputPas.Add('  end;');
    FOutputPas.Add('');
    FOutputPas.Add('implementation');
    FOutputPas.Add('');
    FOutputPas.Add('uses');
    FOutputPas.Add('  Ths.Constants,');
    FOutputPas.Add('  ' + edtInputFormName.Text + ',');
    FOutputPas.Add('  ' + PROJECT_UNITNAME + edtClassType.Text + ';');
    FOutputPas.Add('');
    FOutputPas.Add('{$R *.dfm}');
    FOutputPas.Add('');
    FOutputPas.Add('function ' + LTipOut + '.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;');
    FOutputPas.Add('begin');
    FOutputPas.Add('  Result := nil;');
    FOutputPas.Add('  if (pFormMode = ifmRewiev) then');
    FOutputPas.Add('    Result := ' + LTipIn + '.Create(Application, Self, Table.Clone(), pFormMode)');
    FOutputPas.Add('  else if (pFormMode = ifmNewRecord) then');
    FOutputPas.Add('    Result := ' + LTipIn + '.Create(Application, Self, T' + edtClassType.Text + '.Create(Table.Database), pFormMode)');
    FOutputPas.Add('  else if (pFormMode = ifmCopyNewRecord) then');
    FOutputPas.Add('    Result := ' + LTipIn + '.Create(Application, Self, Table.Clone(), pFormMode);');
    FOutputPas.Add('end;');
    FOutputPas.Add('');
    FOutputPas.Add('end.');
  finally
    mmoOutputPAS.Lines.Text := FOutputPas.Text;
    mmoOutputPAS.Lines.EndUpdate;
  end;
end;

procedure TfrmMainClassGenerator.GenerateClass;
var
  Ls: string;
  LDataTypeVal: string;
  LNumeric: Boolean;
begin
  FClass.BeginUpdate;
  try
    FClass.Text := '';

    FClass.Add('unit ' + PROJECT_UNITNAME + edtClassType.Text + ';');
    FClass.Add('');
    FClass.Add('interface');
    FClass.Add('');
    FClass.Add('{$I Ths.inc}');
    FClass.Add('');
    FClass.Add('uses');
    FClass.Add('  System.SysUtils,');
    FClass.Add('  Data.DB,');
    FClass.Add('  Ths.Database,');
    FClass.Add('  Ths.Database.Table;');
    FClass.Add('');
    FClass.Add('type');
    FClass.Add('  T' + edtClassType.Text + ' = class(TTable)');
    FClass.Add('  private');

    grdColumns.DataSource.DataSet.First;
    while not cdsColumns.Eof do
    begin
      if cdsColumns.FieldByName('field_name').AsString <> 'id' then
      begin
        if not cdsColumns.Fields[0].IsNull then
        begin
          Ls := CapitalizeString(cdsColumns.FieldByName('field_name').AsString.Replace('_', ' ') ).Replace(' ', '');
          FClass.Add('    F' + Ls + ': TFieldDB;');
        end;
      end;
      cdsColumns.Next;
    end;

    FClass.Add('  published');
    FClass.Add('    constructor Create(ADatabase: TDatabase); override;');
    FClass.Add('  public');
    FClass.Add('    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;');
    FClass.Add('    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;');
    FClass.Add('    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;');
    FClass.Add('    procedure DoUpdate(APermissionControl: Boolean=True); override;');
    FClass.Add('');
    FClass.Add('    function Clone: TTable; override;');
    FClass.Add('');

    cdsColumns.First;
    while not cdsColumns.Eof do
    begin
      if cdsColumns.FieldByName('field_name').AsString <> 'id' then
      begin
        if not cdsColumns.Fields[0].IsNull then
        begin
          Ls := CapitalizeString(cdsColumns.FieldByName('field_name').AsString.Replace('_', ' ') ).Replace(' ', '');
          FClass.Add('    Property ' + Ls + ': TFieldDB read F' + Ls + ' write F' + Ls + ';');
        end;
      end;
      cdsColumns.Next;
    end;

    FClass.Add('  end;');
    FClass.Add('');
    FClass.Add('implementation');
    FClass.Add('');
    FClass.Add('uses');
    FClass.Add('  Ths.Globals,');
    FClass.Add('  Ths.Constants;');
    FClass.Add('');
    FClass.Add('constructor T' + edtClassType.Text + '.Create(ADatabase: TDatabase);');
    FClass.Add('begin');
    FClass.Add('  TableName := ' + QuotedStr(cbbtable_name.Text) + ';');
    FClass.Add('  TableSourceCode := ' + QuotedStr(edtSourceCode.Text) + ';');
    FClass.Add('  inherited Create(ADatabase);');
    FClass.Add('');
    cdsColumns.First;
    while not cdsColumns.Eof do
    begin
      if cdsColumns.FieldByName('field_name').AsString <> 'id' then
      begin
        if not cdsColumns.Fields[0].IsNull then
        begin
          Ls := CapitalizeString(cdsColumns.FieldByName('field_name').AsString.Replace('_', ' ') ).Replace(' ', '');
          LDataTypeVal := GetDataTypeFromQry(LNumeric, cdsColumns.FieldByName('field_name').AsString);
          FClass.Add('  F' + Ls + ' := TFieldDB.Create(' +
              QuotedStr(cdsColumns.FieldByName('field_name').AsString) + ', ' +
              LDataTypeVal + ', ' +
              'Self, ' +
              QuotedStr(cdsColumns.FieldByName('column_caption').AsString) + ');');
        end;
      end;
      cdsColumns.Next;
    end;
    FClass.Add('end;');
    FClass.Add('');
    FClass.Add('procedure T' + edtClassType.Text + '.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);');
    FClass.Add('begin');
    FClass.Add('  if not IsAuthorized(ptRead, APermissionControl) then');
    FClass.Add('    Exit;');
    FClass.Add('');
    FClass.Add('  with QueryOfDS do');
    FClass.Add('  begin');
    FClass.Add('    Close;');
    FClass.Add('    Database.GetSQLSelectCmd(QueryOfDS, TableName, [');
    FClass.Add('      Id.QryName,');
    cdsColumns.First;
    while not cdsColumns.Eof do
    begin
      if cdsColumns.FieldByName('field_name').AsString <> 'id' then
      begin
        if not cdsColumns.Fields[0].IsNull then
        begin
          Ls := CapitalizeString(cdsColumns.FieldByName('field_name').AsString.Replace('_', ' ') ).Replace(' ', '');
          FClass.Add('      F' + Ls + '.QryName,');
        end;
      end;
      cdsColumns.Next;
    end;
    FClass.Strings[FClass.Count-1] := LeftStr(FClass.Strings[FClass.Count-1], Length(FClass.Strings[FClass.Count-1])-1);
    FClass.Add('    ], [');
    FClass.Add('      '' WHERE 1=1 '' + AFilter');
    FClass.Add('    ], AAllColumn, AHelper);');
    FClass.Add('    Open;');
    FClass.Add('  end;');
    FClass.Add('end;');
    FClass.Add('');

    FClass.Add('procedure T' + edtClassType.Text + '.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);');
    FClass.Add('var');
    FClass.Add('  LQry: TZQuery;');
    FClass.Add('begin');
    FClass.Add('  if not IsAuthorized(ptRead, APermissionControl) then');
    FClass.Add('    Exit;');
    FClass.Add('');
    FClass.Add('  AFilter := GetLockSQL(AFilter, ALock);');
    FClass.Add('');
    FClass.Add('  LQry := Database.NewQuery();');
    FClass.Add('  with LQry do');
    FClass.Add('  try');
    FClass.Add('    Database.GetSQLSelectCmd(QueryOfList, TableName, [');
    FClass.Add('      Id.QryName,');
    cdsColumns.First;
    while not cdsColumns.Eof do
    begin
      if not cdsColumns.Fields[0].IsNull then
      begin
        if cdsColumns.FieldByName('field_name').AsString <> 'id' then
        begin
          Ls := CapitalizeString(cdsColumns.FieldByName('field_name').AsString.Replace('_', ' ') ).Replace(' ', '');
          FClass.Add('      F' + Ls + '.QryName,');
        end;
      end;
      cdsColumns.Next;
    end;
    FClass.Strings[FClass.Count-1] := LeftStr(FClass.Strings[FClass.Count-1], Length(FClass.Strings[FClass.Count-1])-1);
    FClass.Add('    ], [');
    FClass.Add('      '' WHERE 1=1 '', AFilter');
    FClass.Add('    ]);');
    FClass.Add('    Open;');
    FClass.Add('');
    FClass.Add('    FreeListContent();');
    FClass.Add('    List.Clear;');
    FClass.Add('    while NOT EOF do');
    FClass.Add('      begin');
    FClass.Add('        PrepareTableClassFromQuery(QueryOfList);');
    FClass.Add('');
    FClass.Add('        List.Add(Clone);');
    FClass.Add('');
    FClass.Add('        Next;');
    FClass.Add('      end;');
    FClass.Add('    end;');
    FClass.Add('  finally');
    FClass.Add('    Free;');
    FClass.Add('  end;');
    FClass.Add('end;');
    FClass.Add('');

    FClass.Add('procedure T' + edtClassType.Text + '.DoInsert(out AID: Integer; APermissionControl: Boolean);');
    FClass.Add('var');
    FClass.Add('  LQry: TZQuery;');
    FClass.Add('begin');
    FClass.Add('  LQry := Database.NewQuery;');
    FClass.Add('  with LQry do');
    FClass.Add('  try');
    FClass.Add('    SQL.Text := GetSQLInsertCmd(TableName, QRY_PAR_CH, [');
    FQryColProp.First;
    while not FQryColProp.Eof do
    begin
      if not FQryColProp.Fields[0].IsNull then
      begin
        if FQryColProp.Fields[0].AsString <> 'id' then
        begin
          Ls := CapitalizeString(FQryColProp.Fields[0].AsString.Replace('_', ' ') ).Replace(' ', '');
          FClass.Add('      F' + Ls + '.FieldName,');
        end;
      end;
      FQryColProp.Next;
    end;
    FClass.Strings[FClass.Count-1] := LeftStr(FClass.Strings[FClass.Count-1], Length(FClass.Strings[FClass.Count-1])-1);
    FClass.Add('    ]);');
    FClass.Add('');
    FClass.Add('    PrepareInsertQueryParams;');
    FClass.Add('');
    FClass.Add('    Open;');
    FClass.Add('    if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)');
    FClass.Add('    then AID := Fields.FieldByName(Id.FieldName).AsInteger');
    FClass.Add('    else AID := 0;');
    FClass.Add('  finally');
    FClass.Add('    Free;');
    FClass.Add('  end;');
    FClass.Add('end;');
    FClass.Add('');

    FClass.Add('procedure T' + edtClassType.Text + '.DoUpdate(APermissionControl: Boolean);');
    FClass.Add('var');
    FClass.Add('  LQry: TZQuery;');
    FClass.Add('begin');
    FClass.Add('  LQry := Database.NewQuery;');
    FClass.Add('  with LQry do');
    FClass.Add('  try');
    FClass.Add('    SQL.Text := GetSQLUpdateCmd(TableName, QRY_PAR_CH, [');
    FQryColProp.First;
    while not FQryColProp.Eof do
    begin
      if not FQryColProp.Fields[0].IsNull then
      begin
        if FQryColProp.Fields[0].AsString <> 'id' then
        begin
          Ls := CapitalizeString(FQryColProp.Fields[0].AsString.Replace('_', ' ') ).Replace(' ', '');
          FClass.Add('      F' + Ls + '.FieldName,');
        end;
      end;
      FQryColProp.Next;
    end;
    FClass.Strings[FClass.Count-1] := LeftStr(FClass.Strings[FClass.Count-1], Length(FClass.Strings[FClass.Count-1])-1);
    FClass.Add('    ]);');
    FClass.Add('');
    FClass.Add('    PrepareUpdateQueryParams;');
    FClass.Add('');
    FClass.Add('    ExecSQL;');
    FClass.Add('  finally');
    FClass.Add('    Free;');
    FClass.Add('  end;');
    FClass.Add('end;');
    FClass.Add('');

    FClass.Add('function T' + edtClassType.Text + '.Clone: TTable;');
    FClass.Add('begin');
    FClass.Add('  Result := T' + edtClassType.Text + '.Create(Database);');
    FClass.Add('  CloneClassContent(Self, Result);');
    FClass.Add('end;');
    FClass.Add('');
    FClass.Add('end.');
  finally
    FClass.EndUpdate;

    mmoClass.Clear;
    mmoClass.Lines.Text := FClass.Text;
  end;
end;

procedure TfrmMainClassGenerator.GenerateInput;
var
  LMaxCaptionLen, LGuiCount, LOrder: Integer;
  LStr, LFld: string;
  LTipIn: string;
begin
  LGuiCount := 0;
  LMaxCaptionLen := 0;
  LTipIn := 'T' + Copy(edtInputFormName.Text, 2, Length(edtInputFormName.Text)-1);

  cdsColumns.DisableControls;
  try
    cdsColumns.First;
    while not cdsColumns.Eof do
    begin
      if cdsColumns.FieldByName('is_gui').AsBoolean then
      begin
        LMaxCaptionLen := Max(LMaxCaptionLen, Canvas.TextWidth(cdsColumns.FieldByName('column_caption').AsString));
        Inc(LGuiCount);
      end;
      cdsColumns.Next;
    end;
  finally
    cdsColumns.EnableControls;
  end;

  mmoInputDFM.Lines.Clear;
  mmoInputDFM.Lines.BeginUpdate;
  FInputDfm.Clear;
  cdsColumns.DisableControls;
  try
    FInputDfm.Add('inherited ' + MidStr(LTipIn, 2, Length(LTipIn)-1) + ': ' + LTipIn);
    FInputDfm.Add('  PixelsPerInch = 96');
    FInputDfm.Add('  TextHeight = 13');
    FInputDfm.Add('  Caption = ' + QuotedStr(edtInputFormCaption.Text));
    FInputDfm.Add('  ActiveControl = btnClose');
    FInputDfm.Add('  ClientHeight = ' + IntToStr(70 + LGuiCount * 25) );
    FInputDfm.Add('  ClientWidth = ' + IntToStr( 32 + LMaxCaptionLen + 16 + 4 + 200 + 16 ));
    FInputDfm.Add('  inherited pnlMain: TPanel');
    FInputDfm.Add('    inherited pgcMain: TPageControl');
    FInputDfm.Add('      inherited tsMain: TTabSheet');


    LOrder := 0;
    cdsColumns.First;
    while not cdsColumns.Eof do
    begin
      if cdsColumns.FieldByName('is_gui').AsBoolean then
      begin
        FInputDfm.Add('        object lbl' + cdsColumns.FieldByName('field_name').AsString + ': TLabel');
        FInputDfm.Add('          Left = ' + IntToStr(32 + LMaxCaptionLen-Canvas.TextWidth(cdsColumns.FieldByName('column_caption').AsString)) );
        FInputDfm.Add('          Top = ' + (6+(LOrder*22)).ToString);
        FInputDfm.Add('          Width = ' + IntToStr(Canvas.TextWidth(cdsColumns.FieldByName('input_caption').AsString) + 16) );
        FInputDfm.Add('          Height = 13');
        FInputDfm.Add('          Alignment = taRightJustify');
        FInputDfm.Add('          Caption = ' + QuotedStr(cdsColumns.FieldByName('input_caption').AsString));
        FInputDfm.Add('          Font.Style = [fsBold]');
        FInputDfm.Add('        end');

        Inc(LOrder);
      end;
      cdsColumns.Next;
    end;

    LOrder := 0;
    cdsColumns.First;
    while not cdsColumns.Eof do
    begin
      if cdsColumns.FieldByName('is_gui').AsBoolean then
      begin
        if (cdsColumns.FieldByName('input_type').AsString = 'Edit') then
        begin
          FInputDfm.Add('        object edt' + cdsColumns.FieldByName('field_name').AsString + ': TEdit');
          FInputDfm.Add('          Height = 21');
        end
        else if (cdsColumns.FieldByName('input_type').AsString = 'Memo') then
        begin
          FInputDfm.Add('        object mmo' + cdsColumns.FieldByName('field_name').AsString + ': TMemo');
          FInputDfm.Add('          Height = 21');
        end
        else if (cdsColumns.FieldByName('input_type').AsString = 'ComboBox') then
        begin
          FInputDfm.Add('        object cbb' + cdsColumns.FieldByName('field_name').AsString + ': TComboBox');
          FInputDfm.Add('          Height = 21');
        end
        else if (cdsColumns.FieldByName('input_type').AsString = 'CheckBox') then
        begin
          FInputDfm.Add('        object chk' + cdsColumns.FieldByName('field_name').AsString + ': TCheckBox');
          FInputDfm.Add('          Height = 17');
        end;

        FInputDfm.Add('          Left = ' + IntToStr(32 + LMaxCaptionLen + 16 + 4));
        FInputDfm.Add('          Width = 200');
        FInputDfm.Add('          TabOrder = ' + LOrder.ToString);

        if (cdsColumns.FieldByName('input_type').AsString = 'CheckBox') then
          FInputDfm.Add('          Top = ' + (3+(LOrder*23)).ToString)
        else
          FInputDfm.Add('          Top = ' + (3+(LOrder*22)).ToString);
        FInputDfm.Add('        end');

        Inc(LOrder);
      end;
      cdsColumns.Next;
    end;
    FInputDfm.Add('      end');
    FInputDfm.Add('    end');
    FInputDfm.Add('  end');
    FInputDfm.Add('end');
  finally
    mmoInputDFM.Lines.Text := FInputDfm.Text;
    mmoInputDFM.Lines.EndUpdate;
    cdsColumns.EnableControls;
  end;





  mmoInputPAS.Lines.Clear;
  mmoInputPAS.Lines.BeginUpdate;
  FInputPas.Clear;
  cdsColumns.DisableControls;
  try
    FInputPas.Add('unit ' + edtInputFormName.Text + ';');
    FInputPas.Add('');
    FInputPas.Add('interface');
    FInputPas.Add('');
    FInputPas.Add('uses');
    FInputPas.Add('  Winapi.Windows,');
    FInputPas.Add('  Winapi.Messages,');
    FInputPas.Add('  System.SysUtils,');
    FInputPas.Add('  System.Variants,');
    FInputPas.Add('  System.Classes,');
    FInputPas.Add('  System.StrUtils,');
    FInputPas.Add('  System.Math,');
    FInputPas.Add('  Vcl.Graphics,');
    FInputPas.Add('  Vcl.Controls,');
    FInputPas.Add('  Vcl.Forms,');
    FInputPas.Add('  Vcl.Dialogs,');
    FInputPas.Add('  Vcl.StdCtrls,');
    FInputPas.Add('  Vcl.ExtCtrls,');
    FInputPas.Add('  Vcl.ComCtrls,');
    FInputPas.Add('  Vcl.AppEvnts,');
    FInputPas.Add('  Vcl.Menus,');
    FInputPas.Add('  Vcl.Samples.Spin,');
    FInputPas.Add('  Ths.Erp.Helper.BaseTypes,');
    FInputPas.Add('  Ths.Erp.Helper.Edit,');
    FInputPas.Add('  Ths.Erp.Helper.Memo,');
    FInputPas.Add('  Ths.Erp.Helper.ComboBox,');
    FInputPas.Add('  ufrmBase,');
    FInputPas.Add('  ufrmBaseInputDB;');
    FInputPas.Add('');
    FInputPas.Add('type');
    FInputPas.Add('  ' + LTipIn + ' = class(TfrmBaseInputDB)');

    cdsColumns.First;
    while not cdsColumns.Eof do
    begin
      if cdsColumns.FieldByName('is_gui').AsBoolean then
      begin
        FInputPas.Add('    lbl' + cdsColumns.FieldByName('field_name').AsString + ': TLabel;');
        if (cdsColumns.FieldByName('input_type').AsString = 'Edit') then
          FInputPas.Add('    edt' + cdsColumns.FieldByName('field_name').AsString + ': TEdit;')
        else if (cdsColumns.FieldByName('input_type').AsString = 'Memo') then
          FInputPas.Add('    mmo' + cdsColumns.FieldByName('field_name').AsString + ': TMemo;')
        else if (cdsColumns.FieldByName('input_type').AsString = 'ComboBox') then
          FInputPas.Add('    cbb' + cdsColumns.FieldByName('field_name').AsString + ': TComboBox;')
        else if (cdsColumns.FieldByName('input_type').AsString = 'CheckBox') then
          FInputPas.Add('    chk' + cdsColumns.FieldByName('field_name').AsString + ': TCheckBox;');
      end;
      cdsColumns.Next;
    end;

    FInputPas.Add('  published');
    FInputPas.Add('    procedure RefreshData; override;');
    FInputPas.Add('    procedure btnAcceptClick(Sender: TObject); override;');
    FInputPas.Add('  end;');
    FInputPas.Add('');
    FInputPas.Add('implementation');
    FInputPas.Add('');
    FInputPas.Add('uses');
    FInputPas.Add('  Ths.Erp.Globals,');
    FInputPas.Add('  ' + edtOutputFormName.Text + ',');
    FInputPas.Add('  ' + PROJECT_UNITNAME + edtClassType.Text + ';');
    FInputPas.Add('');
    FInputPas.Add('{$R *.dfm}');
    FInputPas.Add('');
    FInputPas.Add('procedure ' + LTipIn + '.RefreshData;');
    FInputPas.Add('begin');

    cdsColumns.First;
    while not cdsColumns.Eof do
    begin
      if cdsColumns.FieldByName('is_gui').AsBoolean then
      begin
        LStr := CapitalizeString(cdsColumns.FieldByName('field_name').AsString.Replace('_', ' ') ).Replace(' ', '');
        LFld := cdsColumns.FieldByName('field_name').AsString;
        if (cdsColumns.FieldByName('input_type').AsString = 'Edit') then
          FInputPas.Add('  edt' + LFld + '.Text := VarToStr(FormatedVariantVal(T' + edtClassType.Text + '(Table).' + LStr + '));')
        else if (cdsColumns.FieldByName('input_type').AsString = 'Memo') then
          FInputPas.Add('  mmo' + LFld + 'Lines.Text := VarToStr(FormatedVariantVal(T' + edtClassType.Text + '(Table).' + LStr + '));')
        else if (cdsColumns.FieldByName('input_type').AsString = 'ComboBox') then
          FInputPas.Add('  cbb' + LFld + 'ItemIndex := cbb' + LFld + '.Items.IndexOf(VarToStr(FormatedVariantVal(T' + edtClassType.Text + '(Table).' + LStr + ')));')
        else if (cdsColumns.FieldByName('input_type').AsString = 'CheckBox') then
          FInputPas.Add('  chk' + LFld + '.Checked := FormatedVariantVal(T' + edtClassType.Text + '(Table).' + LStr + '));');
      end;
      cdsColumns.Next;
    end;

    FInputPas.Add('end;');
    FInputPas.Add('');
    FInputPas.Add('procedure ' + LTipIn + '.btnAcceptClick(Sender: TObject);');
    FInputPas.Add('begin');
    FInputPas.Add('  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then');
    FInputPas.Add('  begin');
    FInputPas.Add('    if (ValidateInput) then');
    FInputPas.Add('    begin');

    cdsColumns.First;
    while not cdsColumns.Eof do
    begin
      if cdsColumns.FieldByName('is_gui').AsBoolean then
      begin
        LStr := CapitalizeString(cdsColumns.FieldByName('field_name').AsString.Replace('_', ' ') ).Replace(' ', '');
        LFld := cdsColumns.FieldByName('field_name').AsString;
        if (cdsColumns.FieldByName('input_type').AsString = 'Edit') then
        begin
          if  (cdsColumns.FieldByName('is_numeric').AsBoolean)
          then  FInputPas.Add('      T' + edtClassType.Text + '(Table).' + LStr + '.Value := StrToIntDef(edt' + LFld + '.Text, 0);')
          else  FInputPas.Add('      T' + edtClassType.Text + '(Table).' + LStr + '.Value := edt' + LFld + '.Text;');
        end
        else if (cdsColumns.FieldByName('input_type').AsString = 'Memo') then
        begin
          FInputPas.Add('      T' + edtClassType.Text + '(Table).' + LStr + '.Value := mmo' + LFld + '.Text;');
        end
        else if (cdsColumns.FieldByName('input_type').AsString = 'ComboBox') then
        begin
          FInputPas.Add('      T' + edtClassType.Text + '(Table).' + LStr + '.Value := cbb' + LFld + '.Text;');
        end
        else if (cdsColumns.FieldByName('input_type').AsString = 'CheckBox') then
        begin
          FInputPas.Add('      T' + edtClassType.Text + '(Table).' + LStr + '.Value := chk' + LFld + '.Checked;');
        end
      end;
      cdsColumns.Next
    end;

    FInputPas.Add('      inherited;');
    FInputPas.Add('    end;');
    FInputPas.Add('  end');
    FInputPas.Add('  else');
    FInputPas.Add('    inherited;');
    FInputPas.Add('end;');
    FInputPas.Add('');
    FInputPas.Add('end.');
  finally
    mmoInputPAS.Lines.Text := FInputPas.Text;
    mmoInputPAS.Lines.EndUpdate;
    cdsColumns.EnableControls;
  end;
end;

procedure TfrmMainClassGenerator.btnAddClassToMemoClick(Sender: TObject);
begin
  GenerateClass;
end;

procedure TfrmMainClassGenerator.btnSaveToFilesClick(Sender: TObject);
var
  vPath, vFileNameClass, vFileNameOutput, vFileNameInput: string;
  vFileDPR: TStringList;
  n1: Integer;
begin
  if MessageBox(Handle, PWideChar('Are you sure you want to Save Content to File?'), PWideChar('Confirmation'), MB_YESNO) <> mrYes then
    Exit;

  if edtMainProjectDirectory.Text <> '' then
  begin
    btnAddClassToMemo.Click;
    btnAddOutputPASToMemo.Click;
    btnAddInputPASToMemo.Click;

    vPath := ExtractFilePath(edtMainProjectDirectory.Text);
    vFileNameClass := vPath + 'BackEnd\' + PROJECT_UNITNAME + edtClassType.Text + '.pas';
    vFileNameOutput := vPath + 'Forms\OutputForms\DbGrid\' + edtOutputFormName.Text + '.pas';
    vFileNameInput := vPath + 'Forms\InputForms\' + edtInputFormName.Text + '.pas';

    mmoClass.Lines.SaveToFile(vFileNameClass);
    mmoOutputDFM.Lines.SaveToFile(vPath + 'Forms\OutputForms\DbGrid\' + edtOutputFormName.Text + '.dfm', TEncoding.UTF8);
    mmoOutputPAS.Lines.SaveToFile(vFileNameOutput);
    mmoInputDFM.Lines.SaveToFile(vPath + 'Forms\InputForms\' + edtInputFormName.Text + '.dfm', TEncoding.UTF8);
    mmoInputPAS.Lines.SaveToFile(vFileNameInput);

    vFileDPR := TStringList.Create;
    try
      vFileDPR.LoadFromFile(edtMainProjectDirectory.Text);
      //projede kullanýlan dosyalardan sonraki son satýr numarasýný bul
      n1 := vFileDPR.IndexOf('{$R *.res}');

      //son elemanýn noktalý virgül bilgisini virgüle çevir.
      vFileDPR.Strings[n1-2] := LeftStr(vFileDPR.Strings[n1-2], Length(vFileDPR.Strings[n1-2])-1) + ',';

      //eklenen sýnýf, output ve input formlarýný projeye dahil et
      vFileDPR.Insert(n1-1, '  ' + edtInputFormName.Text + ' in ''Forms\InputForms\' + edtInputFormName.Text + '.pas'' {' + MidStr(edtInputFormName.Text, 2, Length(edtInputFormName.Text)) + '};');
      vFileDPR.Insert(n1-1, '  ' + edtOutputFormName.Text + ' in ''Forms\OutputForms\DbGrid\' + edtOutputFormName.Text + '.pas'' {' + MidStr(edtOutputFormName.Text, 2, Length(edtOutputFormName.Text)) + '},');
      vFileDPR.Insert(n1-1, '  ' + PROJECT_UNITNAME + edtClassType.Text + ' in ''BackEnd\' + PROJECT_UNITNAME + edtClassType.Text + '.pas'',');

      vFileDPR.SaveToFile(edtMainProjectDirectory.Text);
    finally
      vFileDPR.Free;
    end;
  end
  else
    raise Exception.Create('Main Project File *.dpr is missing');
end;

procedure TfrmMainClassGenerator.cbbtable_nameChange(Sender: TObject);
var
  LStr: string;
  Ls: string;
  LNumeric: Boolean;
begin
  LStr := cbbtable_name.Text;
  edtClassType.Text := CapitalizeString(LStr.Replace('_', ' ') ).Replace(' ', '');
  edtSourceCode.Text := '1000';
  edtOutputFormName.Text := 'ufrm' + edtClassType.Text + 's';
  edtOutputFormCaption.Text := edtClassType.Text + 's';
  edtInputFormName.Text := 'ufrm' + edtClassType.Text;
  edtInputFormCaption.Text := edtClassType.Text;

  if cdsColumns.Active then
    cdsColumns.EmptyDataSet
  else
    cdsColumns.CreateDataSet;


  FQryColProp.SQL.Text := 'SELECT column_name, data_type FROM INFORMATION_SCHEMA.COLUMNS WHERE 1=1' +
  ' AND table_catalog=' + QuotedStr(edtdatabase_name.Text) +
  ' AND table_schema=' + QuotedStr(edtschema_name.Text) +
  ' AND table_name=' + QuotedStr(cbbtable_name.Text)+' ORDER BY ordinal_position;';
  FQryColProp.Open();
  FQryColProp.First;
  while not FQryColProp.Eof do
  begin
    if not FQryColProp.Fields[0].IsNull then
    begin
      Ls := CapitalizeString(FQryColProp.Fields[0].AsString.Replace('_', ' ') ).Replace(' ', '');
      FClass.Add('    F' + Ls + ': TFieldDB;');
    end;
    FQryColProp.Next;
  end;

  FQryTableCol.Close;
  if cbbtable_name.Text <> '' then
  begin
    FQryTableCol.SQL.Text := 'SELECT * FROM ' + cbbtable_name.Text + ' LIMIT 1';
    FQryTableCol.Open;
  end;

  cdsColumns.DisableControls;
  try
    FQryColProp.First;
    cdsColumns.Open;
    while not FQryColProp.Eof do
    begin
      if not FQryColProp.Fields[0].IsNull then
      begin
        cdsColumns.Append;
        cdsColumns.FieldByName('field_name').AsString := FQryColProp.Fields[0].AsString;
        cdsColumns.FieldByName('field_type').AsString := GetDataTypeFromQry(LNumeric, FQryColProp.Fields[0].AsString, True);
        cdsColumns.FieldByName('column_caption').AsString := CapitalizeString(FQryColProp.Fields[0].AsString.Replace('_', ' ') ).Replace(' ', '');
        cdsColumns.FieldByName('input_caption').AsString := cdsColumns.FieldByName('column_caption').AsString;
        if cdsColumns.FieldByName('field_name').AsString = 'id'
        then  cdsColumns.FieldByName('is_gui').AsBoolean := False
        else  cdsColumns.FieldByName('is_gui').AsBoolean := True;
        if cdsColumns.FieldByName('field_type').AsString = 'ftBoolean'
        then  cdsColumns.FieldByName('input_type').AsString := 'CheckBox'
        else  cdsColumns.FieldByName('input_type').AsString := 'Edit';
        cdsColumns.FieldByName('is_numeric').AsBoolean := LNumeric;
        cdsColumns.Post;
      end;
      FQryColProp.Next;
    end;
  finally
    cdsColumns.EnableControls;
  end;

  GenerateClass;

  GenerareOutput;

  GenerateInput;
end;

procedure TfrmMainClassGenerator.edtMainProjectDirectoryDblClick(Sender: TObject);
var
  vOD: TOpenDialog;
begin
  vOD := TOpenDialog.Create(Self);
  try
    vOD.InitialDir := ExtractFilePath(Application.ExeName);
    vOD.Filter := 'Delphi Project File|*.dpr';
    if vOD.Execute(Handle) then
    begin
      edtMainProjectDirectory.Text := vOD.FileName;
    end;
  finally
    vOD.Free;
  end;
end;

procedure TfrmMainClassGenerator.FillTable;
var
  LQry: TZQuery;
begin
  cbbtable_name.Clear;
  LQry := TZQuery.Create(con1);
  try
    LQry.Connection := con1;
    LQry.SQL.Text := 'SELECT table_name FROM information_schema.tables WHERE table_schema=' + QuotedStr(edtschema_name.Text) + ' ORDER BY table_name';
    LQry.Open();
    LQry.First;
    while not LQry.Eof do
    begin
      if not LQry.Fields[0].IsNull then
        cbbtable_name.Items.Add(LQry.Fields[0].AsString);
      LQry.Next;
    end;
  finally
    LQry.Free;
  end;
end;

procedure TfrmMainClassGenerator.FormCreate(Sender: TObject);
begin
  edtMainProjectDirectory.ReadOnly := True;

  mmoClass.Clear;
  mmoOutputDFM.Clear;
  mmoOutputPAS.Clear;
  mmoInputDFM.Clear;
  mmoInputPAS.Clear;

  cbbtable_name.Enabled := False;

  FClass := TStringList.Create;
  FOutputDfm := TStringList.Create;
  FOutputPas := TStringList.Create;
  FInputDfm := TStringList.Create;
  FInputPas := TStringList.Create;

  FQryColProp := TZQuery.Create(con1);
  FQryColProp.Connection := con1;

  FQryTableCol := TZQuery.Create(con1);
  FQryTableCol.Connection := con1;
end;

procedure TfrmMainClassGenerator.mmoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Sender is TMemo then
  begin
    if (Key = Word('A')) and (ssCtrl in Shift) then
      TMemo(Sender).SelectAll
    else if (Key = Word('C')) and (ssCtrl in Shift) then
      TMemo(Sender).CopyToClipboard;
  end;
end;

end.

