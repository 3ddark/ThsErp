unit Ths.Erp.Database;

interface

{$I ThsERP.inc}

uses
  System.DateUtils,
  System.StrUtils,
  System.Classes,
  System.SysUtils,
  System.Variants,
  System.Rtti,
  Vcl.Forms,
  Vcl.Dialogs,
  Data.DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.UI.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Phys,
  FireDAC.Phys.Intf,
  FireDAC.Phys.PG,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client,
  Ths.Erp.Database.Connection.Settings;

{$M+}

type
  TPermissionType = (ptRead, ptAddRecord, ptUpdate, ptDelete, ptSpeacial);

type
  TDatabase = class
  private
    FSchemaName: string;
    FConManager: TFDManager;
    FConnection: TFDConnection;
    FFDPhyPG: TFDPhysPgDriverLink;
    FEventAlerter: TFDEventAlerter;
    FQueryOfDatabase: TFDQuery;

    FConnSetting: TConnSettings;
    FLangs: TLangs;
    FLoginText: TLoginText;

    FNewRecordId: Integer;

    FDateDB: TDate; //Used for today date controls. Data came from the SQL server during the login process
  protected
    property QueryOfDataBase: TFDQuery read FQueryOfDatabase;

    procedure ConnAfterCommit(Sender: TObject);
    procedure ConnAfterRollback(Sender: TObject);
    procedure ConnAfterStartTransaction(Sender: TObject);
    procedure ConnBeforeCommit(Sender: TObject);
    procedure ConnBeforeRollback(Sender: TObject);
    procedure ConnBeforeStartTransaction(Sender: TObject);
    procedure ConnDatabaseErrors(ASender, AInitiator: TObject; var AException: Exception);
  public
    property ConManager: TFDManager read FConManager write FConManager;
    property Connection: TFDConnection read FConnection write FConnection;
    property FDPhyPG: TFDPhysPgDriverLink read FFDPhyPG write FFDPhyPG;
    property EventAlerter: TFDEventAlerter read FEventAlerter write FEventAlerter;

    property NewRecordId: Integer read FNewRecordId write FNewRecordId;
    property ConnSetting: TConnSettings read FConnSetting write FConnSetting;
    property Langs: TLangs read FLangs write FLangs;
    property LoginText: TLoginText read FLoginText write FLoginText;
    property SchemaName: string read FSchemaName write FSchemaName;

    property DateDB: TDate read FDateDB write FDateDB;

    constructor Create;
    function GetNewRecordId():Integer;

    //get easy SELECT ... FROM ... sql code
    procedure GetSQLSelectCmd(AQry: TFDQuery; ATableName: string; AFieldNames: TArray<string>; AWhereJoin: TArray<string>; AAllColumn: Boolean=True; AHelper: Boolean=False);
    //get easy INSERT INTO .. (...) VALUES(...) RETURNIN ID
    function GetSQLInsertCmd(pTableName: string; pParamDelimiter: Char; pArrFieldNames: TArray<string>): string;
    //get easy UPDATE .. SET ..... WHERE id=...
    function GetSQLUpdateCmd(pTableName: string; pParamDelimiter: Char; pArrFieldNames: TArray<string>): string;
    //if don't want 0, '' value call this routine (string '' = null) (integer or double 0 = null)
    procedure SetQueryParamsDefaultValue(pQuery: TFDQuery; pInput: Boolean = True);

    function NewQuery(pConnection: TFDConnection = nil): TFDQuery;
    function NewStoredProcedure(pConnection: TFDConnection = nil): TFDStoredProc;
    function NewDataSource(pDataset: TDataSet): TDataSource;
    function NewConnection(): TFDConnection;

    function getVarsayilanParaBirimi(): string;
//    procedure EventAlerterAlert(ASender: TFDCustomEventAlerter; const AEventName: string; const AArgument: Variant); virtual;
  published
    destructor Destroy();Override;
    function GetToday():TDateTime;
    function GetNow(OnlyTime: Boolean = True):TDateTime;
    procedure runCustomSQL(pSQL: string);
    procedure ConfigureConnection();
  end;

implementation

uses
  Ths.Erp.Constants,
  Ths.Erp.Globals,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SysParaBirimi,
  Ths.Erp.Database.Table.SysGridKolon;

procedure TDatabase.ConfigureConnection();
begin
  FConnection.AfterStartTransaction  := ConnAfterStartTransaction;
  FConnection.AfterCommit            := ConnAfterCommit;
  FConnection.AfterRollback          := ConnAfterRollback;
  FConnection.BeforeStartTransaction := ConnBeforeStartTransaction;
  FConnection.BeforeCommit           := ConnBeforeCommit;
  FConnection.BeforeRollback         := ConnBeforeRollback;
  FConnection.OnError                := ConnDatabaseErrors;

  if FConnection.Connected then
    FConnection.Close;

  FConnection.Name := 'Connection';

  FConnection.Params.Clear;

  FConnection.Params.Add('DriverID=PG');
  FConnection.Params.Add('CharacterSet=UTF8');
  FConnection.Params.Add('Server=' + FConnSetting.SQLServer);
  FConnection.Params.Add('Database=' + FConnSetting.DatabaseName);
  FConnection.Params.Add('User_Name=' + FConnSetting.DBUserName);
  FConnection.Params.Add('Password=' + FConnSetting.DBUserPassword);
  FConnection.Params.Add('Port=' + FConnSetting.DBPortNo.ToString);
  FConnection.Params.Add('ApplicationName=' + 'THS ERP Framework ' + FConnSetting.UserName);
  FConnection.Params.Add('Pooled=true');
  FConnection.LoginPrompt := False;

  FConManager.AddConnectionDef('Ths_Erp_Framework_Pooled', 'PG', FConnection.Params);
  FConnection.ConnectionDefName := 'Ths_Erp_Framework_Pooled';
//  FEventAlerter.OnAlert := EventAlerterAlert;
end;

procedure TDatabase.ConnAfterCommit(Sender: TObject);
begin

end;

procedure TDatabase.ConnAfterRollback(Sender: TObject);
begin

end;

procedure TDatabase.ConnAfterStartTransaction(Sender: TObject);
begin
//
end;

procedure TDatabase.ConnBeforeCommit(Sender: TObject);
begin
//
end;

procedure TDatabase.ConnBeforeRollback(Sender: TObject);
begin
//
end;

procedure TDatabase.ConnBeforeStartTransaction(Sender: TObject);
begin

end;

procedure TDatabase.ConnDatabaseErrors(ASender, AInitiator: TObject; var AException: Exception);
var
  oExc: EFDDBEngineException;

  vTableName, vColumnName, vData, vDataUnique, vTemp: string;
  vStart, vEnd: Integer;
begin
  if AException is EFDDBEngineException then
  begin
    oExc := EFDDBEngineException(AException);

    if FConnection.Connected then
      FConnection.Rollback;

    if oExc.Kind = ekOther then
    begin
      if Pos('could not obtain lock on row in relation', oExc.Message) > 0 then
      begin
        CustomMsgDlg(TranslateText('Kayýt þu anda baþka bir kullanýcý tarafýndan kullanýlýyor. Lütfen daha sonra tekrar deneyin.', FrameworkLang.ErrorDBRecordLocked, LngMsgError, LngSystem),
          mtError, [mbOK], [TranslateText('Tamam', FrameworkLang.ButtonOK, LngButton, LngSystem)], mbOK,
          TranslateText('Diðer', FrameworkLang.MessageTitleOther, LngMsgTitle, LngSystem));
      end
      else
      begin
        ShowException(oExc, oExc.ClassInfo);//.Message
//        CustomMsgDlg(TranslateText('Diðer', FrameworkLang.ErrorDBOther, LngError, LngSystem) + sLineBreak + oExc.Message,
//          mtError, [mbOK], [TranslateText('Tamam', FrameworkLang.ButtonOK, LngButton, LngSystem)], mbOK,
//          TranslateText('Diðer', FrameworkLang.MessageTitleOther, LngMessageTitle, LngSystem));
      end;
    end
    else if oExc.Kind = ekNoDataFound then
    begin
      CustomMsgDlg(TranslateText('Eriþmeye çalýþtýðýnýz bilgi silinmiþ veya deðiþtirilmiþ.', FrameworkLang.ErrorDBNoDataFound, LngMsgError, LngSystem),
        mtError, [mbOK], [TranslateText('Tamam', FrameworkLang.ButtonOK, LngButton, LngSystem)], mbOK,
        TranslateText('Bilgi bulunamadý', FrameworkLang.MessageTitleNoDataFound, LngMsgTitle, LngSystem));
     end
    else if oExc.Kind = ekTooManyRows then
    begin
      CustomMsgDlg(TranslateText('Çok fazla kayýt geliyor!', FrameworkLang.ErrorDBTooManyRows, LngMsgError, LngSystem),
        mtError, [mbOK], [TranslateText('Tamam', FrameworkLang.ButtonOK, LngButton, LngSystem)], mbOK,
        TranslateText('Bilgi bulunamadý', FrameworkLang.MessageTitleNoDataFound, LngMsgTitle, LngSystem));
    end
    else if oExc.Kind = ekRecordLocked then
    begin
      CustomMsgDlg(TranslateText('Kayýt þu anda baþka bir kullanýcý tarafýndan kullanýlýyor. Lütfen daha sonra tekrar deneyin.', FrameworkLang.ErrorDBRecordLocked, LngMsgError, LngSystem),
        mtError, [mbOK], [TranslateText('Tamam', FrameworkLang.ButtonOK, LngButton, LngSystem)], mbOK,
        TranslateText('Diðer', FrameworkLang.MessageTitleOther, LngMsgTitle, LngSystem));
    end
    else if (oExc.Kind = ekUKViolated) then
    begin
      vStart := Pos(')=(', oExc.Message) + Length(')=(');
      vEnd := PosEx(')', oExc.Message, vStart+1);
      if vStart > 0 then
        vDataUnique := '"' + MidStr(oExc.Message, vStart, vEnd-vStart) + '"';

      vTemp := TranslateText('Girdiðiniz deðer var.' + AddLBs + 'Lütfen daha önce girilmemiþ bir deðer girin.' + AddLBs +
        vDataUnique + ' isimli bilgi zaten var.', FrameworkLang.ErrorDBUnique, LngMsgError, LngSystem);
      vTemp := ReplaceMessages(vTemp, ['#par1#'], [vDataUnique]);

      CustomMsgDlg(vTemp + AddLBs(2) + oExc.Message, mtError, [mbOK], [TranslateText('Tamam', FrameworkLang.ButtonOK, LngButton, LngSystem)], mbOK,
        TranslateText('Varolan Kayýt', FrameworkLang.MessageTitleDataAlreadyExists, LngMsgTitle, LngSystem));
    end
    else if oExc.Kind = ekFKViolated then
    begin
      if Pos('update or delete', oExc.Message) > 0 then
      begin
        vStart := Pos('" on table "', oExc.Message) + Length('" on table "');
        vEnd := PosEx('"', oExc.Message, vStart+1);
        if vStart > 0 then
          vTableName := '"' + ReplaceRealColOrTableNameTo(MidStr(oExc.Message, vStart, vEnd-vStart)) + '"';

        vTemp := TranslateText('Bu kayýt silinemez veya güncellenemez.' + AddLBs + vTableName + ' isimli tabloda kullanýlýyor', FrameworkLang.ErrorDBForeignKeyDeleteUpdate, LngMsgError, LngSystem);
        vTemp := ReplaceMessages(vTemp, ['#par1#'], [vTableName]);
        vTemp := vTemp + AddLBs(2) + oExc.Message;
        CustomMsgDlg(vTemp,
          mtError, [mbOK], [TranslateText('Tamam', FrameworkLang.ButtonOK, LngButton, LngSystem)], mbOK,
          TranslateText('Güncelleme/Silme Hatasý', FrameworkLang.MessageTitleUpdateDelete, LngMsgTitle, LngSystem));
      end
      else
      if Pos('is not present in table', oExc.Message) > 0 then
      begin
        vStart := Pos('is not present in table "', oExc.Message) + Length('is not present in table "');
        vEnd := PosEx('".', oExc.Message, vStart+1);
        if vStart > 0 then
          vTableName := '"' + ReplaceRealColOrTableNameTo(MidStr(oExc.Message, vStart, vEnd-vStart)) + '"';

        vStart := Pos('Key (', oExc.Message) + Length('Key (');
        vEnd := PosEx(')=(', oExc.Message, vStart+1);
        if vStart > 0 then
          vColumnName := '"' + ReplaceRealColOrTableNameTo(MidStr(oExc.Message, vStart, vEnd-vStart)) + '"';

        vStart := Pos(')=(', oExc.Message) + Length(')=(');
        vEnd := PosEx(') is not present in table "', oExc.Message, vStart+1);
        if vStart > 0 then
          vData := '"' + MidStr(oExc.Message, vStart, vEnd-vStart) + '"';

        vTemp := TranslateText('Kullanmak istediðiniz ' + vColumnName + '=' + vData + ' bilgisi ' + vTableName + ' tablosunda kayýtlý deðil', FrameworkLang.ErrorDBForeignKeyUnique, LngMsgError, LngSystem);
        vTemp := ReplaceMessages(vTemp, ['#par1#', '#par2#', '#par3#'], [vColumnName, vData, vTableName]);
        CustomMsgDlg(vTemp,
          mtError, [mbOK], [TranslateText('Tamam', FrameworkLang.ButtonOK, LngButton, LngSystem)], mbOK,
          TranslateText('Ekleme/Güncelleme Hatasý', FrameworkLang.MessageTitleInsertUpdate, LngMsgTitle, LngSystem));
      end;
    end
    else if oExc.Kind = ekObjNotExists then
    begin
      CustomMsgDlg(TranslateText('Kullanýlan Obje mevcut deðil', FrameworkLang.ErrorDBObjectNotExist, LngMsgError, LngSystem) + AddLBs + oExc.Message,
        mtError, [mbOK], [TranslateText('Tamam', FrameworkLang.ButtonOK, LngButton, LngSystem)], mbOK,
        TranslateText('Obje Mevcut Deðil', FrameworkLang.MessageTitleObjectNotFound, LngMsgTitle, LngSystem));
    end
    else if oExc.Kind = ekUserPwdInvalid then
    begin

    end
    else if oExc.Kind = ekUserPwdExpired then
    begin
    end
    else if oExc.Kind = ekUserPwdWillExpire then
    begin
    end
    else if oExc.Kind = ekCmdAborted then
    begin
      CustomMsgDlg(TranslateText('Komut iptal edildi', FrameworkLang.ErrorDBCmdAborted, LngMsgError, LngSystem),
        mtError, [mbOK], [TranslateText('Tamam', FrameworkLang.ButtonOK, LngButton, LngSystem)], mbOK, '');
    end
    else if oExc.Kind = ekServerGone then
    begin
      CustomMsgDlg(TranslateText('Sunucuya ulaþýlamýyor.', FrameworkLang.ErrorDBServerGone, LngMsgError, LngSystem),
        mtError, [mbOK], [TranslateText('Tamam', FrameworkLang.ButtonOK, LngButton, LngSystem)], mbOK, '');
    end
    else if oExc.Kind = ekServerOutput then
    begin
    end
    else if oExc.Kind = ekArrExecMalfunc then
    begin
    end
    else if oExc.Kind = ekInvalidParams then
    begin
      CustomMsgDlg(TranslateText('Hatalý parametre kullanýmý', FrameworkLang.ErrorDBInvalidParams, LngMsgError, LngSystem),
        mtError, [mbOK], [TranslateText('Tamam', FrameworkLang.ButtonOK, LngButton, LngSystem)], mbOK, '');
    end
  end;
end;

constructor TDatabase.Create();
begin
  if Self.FConnection <> nil then
    Abort
  else
  begin
    inherited;

    GUygulamaAnaDizin := ExtractFilePath(Application.ExeName);

    FConManager := TFDManager.Create(nil);

    FSchemaName := 'public';
    FConnection := TFDConnection.Create(nil);

    FDPhyPG := TFDPhysPgDriverLink.Create(FConnection);

    //bu kod kullanýldýðýnda. uygulama.exe nin olduðu konumda /lib klasörü ve içinde baðlantý dll dosyalarý olmak zorunda
    FDPhyPG.VendorHome := GUygulamaAnaDizin;

    FEventAlerter := TFDEventAlerter.Create(nil);
    FEventAlerter.Connection := FConnection;

    FQueryOfDatabase := NewQuery;

    ConnSetting := TConnSettings.Create;
    ConnSetting.ReadFromFile;

    FLangs := TLangs.Create;
    FLangs.ReadFromFile;

    FLoginText := TLoginText.Create;
    FLoginText.ReadFromFile(Self.FConnSetting.Language);
  end;
end;

destructor TDatabase.Destroy;
begin
  FreeAndNil(FLangs);
  FreeAndNil(FLoginText);
  FreeAndNil(FConnSetting);
  FreeAndNil(FQueryOfDatabase);
  FreeAndNil(FEventAlerter);
  FreeAndNil(FConnection);
  FreeAndNil(FConManager);
  inherited;
end;

//procedure TDatabase.EventAlerterAlert(ASender: TFDCustomEventAlerter;
//  const AEventName: string; const AArgument: Variant);
//var
//  sMesaj: string;
//  n1: Integer;
//begin
//  ASender.Unregister;
//
//  ShowMessage(AEventName);
//  if VarIsArray( AArgument ) then
//    for n1 := VarArrayLowBound(AArgument, 1) to VarArrayHighBound(AArgument, 1) do
//      if n1 = 0 then
//        sMesaj := sMesaj + 'Process ID (pID):' + VarToStr(AArgument[n1]) + ', '
//      else if n1 = 1 then
//        sMesaj := sMesaj + 'Notify Value:' + VarToStr(AArgument[n1]) + ', ';
//
//  ShowMessage(sMesaj);
//end;

function TDatabase.GetNewRecordId: Integer;
begin
  Dec(FNewRecordId, 1);
  Result := FNewRecordId;
end;

function TDatabase.GetNow(OnlyTime: Boolean = True): TDateTime;
begin
  Result := 0;
  with QueryOfDataBase do
  begin
    Close;
    SQL.Text := 'SELECT NOW()::timestamp without time zone;';
    Open;
    while not EOF do
    begin
      Result := Fields.Fields[0].AsDateTime;
      Next;
    end;
    EmptyDataSet;
    Close;
  end;

  if OnlyTime then
    Result := TimeOf(Result);
end;

function TDatabase.GetSQLInsertCmd(pTableName: string; pParamDelimiter: Char;
  pArrFieldNames: TArray<string>): string;
var
  nIndex: Integer;
  sFields, sParams: string;
  vSQL: TStringList;
begin
  vSQL := TStringList.Create;
  Result := '';
  try
    sFields := '';
    sParams := '';

    vSQL.Add('INSERT INTO ' + pTableName + '(');

    for nIndex := 0 to Length(pArrFieldNames)-1 do
    begin
      if pArrFieldNames[nIndex] <> '' then
      begin
        sFields := sFields + pArrFieldNames[nIndex] + ',';
        sParams := sParams + pParamDelimiter + pArrFieldNames[nIndex] + ',';
      end;

      if (nIndex = Length(pArrFieldNames)-1) and (sFields <> '') then
        sFields := LeftStr(sFields, Length(sFields)-1);

      if (nIndex = Length(pArrFieldNames)-1) and (sParams <> '') then
        sParams := LeftStr(sParams, Length(sParams)-1);
    end;

    vSQL.Add(sFields);
    vSQL.Add(') VALUES (');
    vSQL.Add(sParams);
    vSQL.Add(') RETURNING id');

    if (sFields = '') then
      raise Exception.Create('Database fields not found!');
  finally
    vSQL.LineBreak := '';
    Result := vSQL.Text;
    vSQL.Free;
  end;
end;

procedure TDatabase.GetSQLSelectCmd(AQry: TFDQuery; ATableName: string; AFieldNames: TArray<string>; AWhereJoin: TArray<string>; AAllColumn: Boolean=True; AHelper: Boolean=False);
var
  nx, LPos: Integer;
  AGridColWidth : TSysGridKolon;

  procedure _AddAllColumns();
  var
    n1: Integer;
  begin
    for n1 := 0 to Length(AFieldNames)-1 do
      AQry.SQL.Add(AFieldNames[n1] + ', '); //Select için FieldName ekleniyor
  end;

  type TColHelper = (Helper, Defined);

  procedure _AddAllColumnsHelper(AColHelper: TColHelper);
  var
    n1, n2: Integer;
    LFieldName: string;
  begin
    for n2 := 0 to AGridColWidth.List.Count-1 do
    begin
      if (n2 = 0) then
        AQry.SQL.Add(ATableName + '.' + AGridColWidth.Id.FieldName + ', ');

      if ((TSysGridKolon(AGridColWidth.List[n2]).IsGorunsunHelperForm.Value) and (AColHelper = Helper)) //IsShowForHelper iþaretli kolonlar gelsin
      //or ((TSysGridColWidth(AGridColWidth.List[n2]).IsAlwaysShow.Value) and (AColHelper = Defined))
      or (AColHelper = Defined)
      then
      begin
        for n1 := 0 to Length(AFieldNames)-1 do
        begin
          if Pos(' ', AFieldNames[n1]) > 0 then
            LPos := LastPos(' ', AFieldNames[n1])
          else
            LPos := Pos('.', AFieldNames[n1]);
          LFieldName := AFieldNames[n1].Substring(LPos);
          LFieldName := ReplaceRealColOrTableNameTo(LFieldName);
          if (TSysGridKolon(AGridColWidth.List[n2]).KolonAdi.Value = LFieldName) then
            AQry.SQL.Add(AFieldNames[n1] + ', ') //Select için FieldName ekleniyor
        end;
      end;
    end;
  end;

begin
  if Length(AFieldNames) = 0 then
    raise Exception.Create('Database fields are not defined!' + AddLBs + 'This process cannot be done');

  if AQry <> nil then
  begin
    AQry.SQL.Clear;
    AQry.SQL.Add('SELECT ');
    //helper tanýmlý ve helper için görünmesi gereken alan seçilmiþse helper gibi ekle aksi durumuda normal olarak tüm fieldlar gelsin
    if AHelper then
    begin
      //helper için select yapýlacaksa sadece helperde görünmesini istediðimiz kolonlar getirildi.
      //Bu þekilde gereksiz kolonlar gelmez ve hýz açýsýnda çok kayýt ve çok kolon olan sorgularda performans artmýþ olur.
      //Gereksiz kolonlar db den getirilmez
      if Length(AFieldNames) = 0 then
        raise Exception.Create('Database fields are not defined!' + AddLBs + 'This process cannot be done');

      AGridColWidth := TSysGridKolon.Create(GDataBase);
      try
        AGridColWidth.SelectToList(
          ' AND ' + AGridColWidth.TableName + '.' + AGridColWidth.TabloAdi.FieldName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(ATableName)) +
          ' ORDER BY ' + AGridColWidth.TableName + '.' + AGridColWidth.SiraNo.FieldName + ' ASC ', False, False);

        if AGridColWidth.List.Count = 0 then
          _AddAllColumns  //tüm kolonlar istenmemiþ olsa bile grid kolon geniþliði tanýmlanmamýþsa select içinde tanýmlanan tüm kolonlarý ekle
        else
          _AddAllColumnsHelper(Helper);
      finally
        FreeAndNil(AGridColWidth);
      end;
    end
    else
    begin
      if AAllColumn then
        _AddAllColumns //tüm kolonlar istenmiþse select içinde tanýmlanan tüm kolonlarý ekle
      else
      begin
        AGridColWidth := TSysGridKolon.Create(GDataBase);
        try
          AGridColWidth.SelectToList(
            ' AND ' + AGridColWidth.TableName + '.' + AGridColWidth.TabloAdi.FieldName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(ATableName)) +
            ' ORDER BY ' + AGridColWidth.TableName + '.' + AGridColWidth.SiraNo.FieldName + ' ASC ', False, False);

          if AGridColWidth.List.Count = 0 then
            _AddAllColumns  //tüm kolonlar istenmemiþ olsa bile grid kolon geniþliði tanýmlanmamýþsa select içinde tanýmlanan tüm kolonlarý ekle
          else
            _AddAllColumnsHelper(Defined);  //tüm kolonlar istenmiyorsa sadece IsAlwaysShow tanýmlý kolonlar gelsin
        finally
          FreeAndNil(AGridColWidth);
        end;
      end;
    end;

    if AQry.SQL.Count > 1 then
      AQry.SQL.Strings[AQry.SQL.Count-1] := AQry.SQL.Strings[AQry.SQL.Count-1].Replace(', ', ' ');

    AQry.SQL.Add('FROM ' + ATableName + ' ');
    for nx := 0 to Length(AWhereJoin)-1 do
      AQry.SQL.Add(AWhereJoin[nx]);
  end;
end;

function TDatabase.GetSQLUpdateCmd(pTableName: string; pParamDelimiter: Char; pArrFieldNames: TArray<string>): string;
var
  nIndex: Integer;
  sFields: string;
  vSQL: TStringList;
begin
  vSQL := TStringList.Create;
  Result := '';
  try
    sFields := '';

    vSQL.Add('UPDATE ' + pTableName + ' SET ');

    for nIndex := 0 to Length(pArrFieldNames)-1 do
    begin
      if pArrFieldNames[nIndex] <> '' then
        sFields := sFields + pArrFieldNames[nIndex] + '=' + pParamDelimiter +
            RightStr(pArrFieldNames[nIndex], Length(pArrFieldNames[nIndex])- Pos('.', pArrFieldNames[nIndex])) + ', ';

      if (nIndex = Length(pArrFieldNames)-1) and (sFields <> '') then
        sFields := LeftStr(sFields, Length(sFields)-2);
    end;

    if sFields = '' then
      raise Exception.Create('Database fields not found!');

    vSQL.Add(sFields);

    vSQL.Add(' WHERE id=' + pParamDelimiter + 'id;');
  finally
    vSQL.LineBreak := '';
    Result := vSQL.Text;
    vSQL.Free;
  end;
end;

function TDatabase.GetToday(): TDateTime;
begin
  Result := 0;
  with QueryOfDataBase do
  begin
    Close;
    SQL.Text := 'SELECT CURRENT_DATE;';
    Open;
    while NOT EOF do
    begin
      Result := Fields.Fields[0].AsDateTime;
      Next;
    end;
    EmptyDataSet;
    Close;
  end;
end;

function TDatabase.getVarsayilanParaBirimi: string;
var
  vQuery: TFDQuery;
  vPara: TSysParaBirimi;
begin
  Result := '';
  vQuery := NewQuery;
  vPara := TSysParaBirimi.Create(GDataBase);
  try
    with vQuery do
    begin
      Close;
      SQL.Text :=
        'SELECT ' + vPara.ParaBirimi.FieldName + ' ' +
        'FROM ' + vPara.TableName + ' ' +
        'WHERE ' + vPara.IsVarsayilan.FieldName + '=true;';
      Open;
      while NOT EOF do
      begin
        Result := Fields.Fields[0].AsString;
        Next;
      end;
      EmptyDataSet;
      Close;
    end;
  finally
    vQuery.Destroy;
    vPara.Free;
  end;
end;

function TDatabase.NewConnection: TFDConnection;
begin
  Result := TFDConnection.Create(nil);
end;

function TDatabase.NewQuery(pConnection: TFDConnection = nil): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.ResourceOptions.DirectExecute := True;
  Result.FetchOptions.Mode := fmAll;
  Result.FormatOptions.StrsEmpty2Null := True;

  if pConnection = nil then
    Result.Connection := Self.FConnection
  else
    Result.Connection := pConnection;
end;

function TDatabase.NewStoredProcedure(pConnection: TFDConnection = nil): TFDStoredProc;
begin
  Result := TFDStoredProc.Create(nil);
  Result.ResourceOptions.DirectExecute := True;
  Result.FetchOptions.Mode := fmAll;
  Result.FormatOptions.StrsEmpty2Null := True;

  if pConnection = nil then
    Result.Connection := Self.FConnection
  else
    Result.Connection := pConnection;
end;

function TDatabase.NewDataSource(pDataset: TDataSet): TDataSource;
begin
  Result := TDataSource.Create(nil);
  Result.DataSet := pDataset;
  Result.Enabled := True;
  Result.AutoEdit := True;
end;

procedure TDatabase.runCustomSQL(pSQL: string);
begin
  if pSQL <> '' then
  begin
    with QueryOfDataBase do
    begin
      Close;
      SQL.Text := pSQL;
      ExecSQL;

      SQL.Clear;
      Close;
    end;
  end;
end;

procedure TDatabase.SetQueryParamsDefaultValue(pQuery: TFDQuery; pInput: Boolean = True);
var
  nIndex: Integer;
begin
  for nIndex := 0 to pQuery.ParamCount-1 do
  begin
    pQuery.Params.Items[nIndex].ParamType := ptInput;

    if (pQuery.Params.Items[nIndex].DataType = ftString)
    or (pQuery.Params.Items[nIndex].DataType = ftMemo)
    or (pQuery.Params.Items[nIndex].DataType = ftWideString)
    or (pQuery.Params.Items[nIndex].DataType = ftWideMemo)
    or (pQuery.Params.Items[nIndex].DataType = ftFixedChar)
    or (pQuery.Params.Items[nIndex].DataType = ftFixedWideChar)
    then
    begin
      if pQuery.Params.Items[nIndex].Value = '' then
        pQuery.Params.Items[nIndex].Value := Null;
    end
    else
    if (pQuery.Params.Items[nIndex].DataType = ftSmallint)
    or (pQuery.Params.Items[nIndex].DataType = ftInteger)
    or (pQuery.Params.Items[nIndex].DataType = ftWord)
    or (pQuery.Params.Items[nIndex].DataType = ftFloat)
    or (pQuery.Params.Items[nIndex].DataType = ftCurrency)
    or (pQuery.Params.Items[nIndex].DataType = ftBCD)
    or (pQuery.Params.Items[nIndex].DataType = ftBytes)
    or (pQuery.Params.Items[nIndex].DataType = ftLargeint)
    or (pQuery.Params.Items[nIndex].DataType = ftLongWord)
    or (pQuery.Params.Items[nIndex].DataType = ftShortint)
    or (pQuery.Params.Items[nIndex].DataType = ftByte)
    then
    begin
      if pQuery.Params.Items[nIndex].Value = 0 then
        pQuery.Params.Items[nIndex].Value := Null;
    end
    else
    if (pQuery.Params.Items[nIndex].DataType = ftDate)
    or (pQuery.Params.Items[nIndex].DataType = ftTime)
    or (pQuery.Params.Items[nIndex].DataType = ftDateTime)
    or (pQuery.Params.Items[nIndex].DataType = ftTimeStamp)
    then
    begin
      if pQuery.Params.Items[nIndex].Value = 0 then
        pQuery.Params.Items[nIndex].Value := Null;
    end;
  end;

  pQuery.SQL.Text := StringReplace(pQuery.SQL.Text, AddLBs, '', [rfReplaceAll]);
end;

end.
