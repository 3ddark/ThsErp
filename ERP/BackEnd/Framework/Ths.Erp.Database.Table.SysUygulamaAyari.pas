unit Ths.Erp.Database.Table.SysUygulamaAyari;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  System.Variants,
  Vcl.Graphics,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SysMukellefTipi,
  Ths.Erp.Database.Table.SysUlke,
  Ths.Erp.Database.Table.SysSehir,
  Ths.Erp.Database.Table.SysLisan;

type
  TSysUygulamaAyari = class(TTable)
  private
    FLogo: TFieldDB;
    FUnvan: TFieldDB;
    FTel1: TFieldDB;
    FTel2: TFieldDB;
    FTel3: TFieldDB;
    FTel4: TFieldDB;
    FTel5: TFieldDB;
    FFaks1: TFieldDB;
    FFaks2: TFieldDB;
    FMersisNo: TFieldDB;
    FTicaretSicilNo: TFieldDB;
    FWebSite: TFieldDB;
    FEMail: TFieldDB;
    FVergiDairesi: TFieldDB;
    FVergiNo: TFieldDB;
    FFormRengi: TFieldDB;
    FDonem: TFieldDB;
    FMukellefTipiID: TFieldDB;
    FMukellefTipi: TFieldDB;
    FUlkeID: TFieldDB;
    FUlke: TFieldDB;
    FSehirID: TFieldDB;
    FSehir: TFieldDB;
    FIlce: TFieldDB;
    FMahalle: TFieldDB;
    FCadde: TFieldDB;
    FSokak: TFieldDB;
    FPostaKodu: TFieldDB;
    FBinaAdi: TFieldDB;
    FKapiNo: TFieldDB;
    FUygulamaLisan: TFieldDB;
    FMailHostName: TFieldDB;
    FMailHostUser: TFieldDB;
    FMailHostPass: TFieldDB;
    FMailHostSmtpPort: TFieldDB;
    FGridColor1: TFieldDB;
    FGridColor2: TFieldDB;
    FGridColorActive: TFieldDB;
    FCryptKey: TFieldDB;
    FIsKaliteFormNoKullan: TFieldDB;
    FSmsTitle: TFieldDB;
    FSmsServiceProvider: TFieldDB;
    FSmsPassword: TFieldDB;
    FSmsUser: TFieldDB;
    FUygulamaSurum: TFieldDB;

    FSysMukellef: TSysMukellefTipi;
    FSysUlke: TSysUlke;
    FSysSehir: TSysSehir;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;
    procedure Delete(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    function GetAddress(): string;

    Property Logo: TFieldDB read FLogo write FLogo;
    Property Unvan: TFieldDB read FUnvan write FUnvan;
    Property Tel1: TFieldDB read FTel1 write FTel1;
    Property Tel2: TFieldDB read FTel2 write FTel2;
    Property Tel3: TFieldDB read FTel3 write FTel3;
    Property Tel4: TFieldDB read FTel4 write FTel4;
    Property Tel5: TFieldDB read FTel5 write FTel5;
    Property Faks1: TFieldDB read FFaks1 write FFaks1;
    Property Faks2: TFieldDB read FFaks2 write FFaks2;
    Property MersisNo: TFieldDB read FMersisNo write FMersisNo;
    Property TicaretSicilNo: TFieldDB read FTicaretSicilNo write FTicaretSicilNo;
    Property WebSite: TFieldDB read FWebSite write FWebSite;
    Property EMail: TFieldDB read FEMail write FEMail;
    Property VergiDairesi: TFieldDB read FVergiDairesi write FVergiDairesi;
    Property VergiNo: TFieldDB read FVergiNo write FVergiNo;
    Property FormRengi: TFieldDB read FFormRengi write FFormRengi;
    Property Donem: TFieldDB read FDonem write FDonem;
    Property MukellefTipiID: TFieldDB read FMukellefTipiID write FMukellefTipiID;
    Property MukellefTipi: TFieldDB read FMukellefTipi write FMukellefTipi; //veri tabaný alaný deðil not a database field
    Property UlkeID: TFieldDB read FUlkeID write FUlkeID;
    Property Ulke: TFieldDB read FUlke write FUlke;  //veri tabaný alaný deðil not a database field
    Property SehirID: TFieldDB read FSehirID write FSehirID;
    Property Sehir: TFieldDB read FSehir write FSehir; //veri tabaný alaný deðil not a database field
    Property Ilce: TFieldDB read FIlce write FIlce;
    Property Mahalle: TFieldDB read FMahalle write FMahalle;
    Property Cadde: TFieldDB read FCadde write FCadde;
    Property Sokak: TFieldDB read FSokak write FSokak;
    Property PostaKodu: TFieldDB read FPostaKodu write FPostaKodu;
    Property BinaAdi: TFieldDB read FBinaAdi write FBinaAdi;
    Property KapiNo: TFieldDB read FKapiNo write FKapiNo;
    Property UygulamaLisan: TFieldDB read FUygulamaLisan write FUygulamaLisan;
    Property MailHostName: TFieldDB read FMailHostName write FMailHostName;
    Property MailHostUser: TFieldDB read FMailHostUser write FMailHostUser;
    Property MailHostPass: TFieldDB read FMailHostPass write FMailHostPass;
    Property MailHostSmtpPort: TFieldDB read FMailHostSmtpPort write FMailHostSmtpPort;
    Property GridColor1: TFieldDB read FGridColor1 write FGridColor1;
    Property GridColor2: TFieldDB read FGridColor2 write FGridColor2;
    Property GridColorActive: TFieldDB read FGridColorActive write FGridColorActive;
    Property CryptKey: TFieldDB read FCryptKey write FCryptKey;
    Property IsKaliteFormNoKullan: TFieldDB read FIsKaliteFormNoKullan write FIsKaliteFormNoKullan;
    property SmsServiceProvider: TFieldDB read FSmsServiceProvider write FSmsServiceProvider;
    property SmsUser: TFieldDB read FSmsUser write FSmsUser;
    property SmsPassword: TFieldDB read FSmsPassword write FSmsPassword;
    property SmsTitle: TFieldDB read FSmsTitle write FSmsTitle;
    property UygulamaSurum: TFieldDB read FUygulamaSurum write FUygulamaSurum;
  end;

implementation

uses
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Globals;

constructor TSysUygulamaAyari.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_uygulama_ayari';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FSysMukellef := TSysMukellefTipi.Create(Database);
  FSysUlke := TSysUlke.Create(Database);
  FSysSehir := TSysSehir.Create(Database);

  FLogo := TFieldDB.Create('logo', ftBytes, 0, Self, 'Logo');
  FUnvan := TFieldDB.Create('unvan', ftString, '', Self, '');
  FTel1 := TFieldDB.Create('tel1', ftString, '', Self, '');
  FTel2 := TFieldDB.Create('tel2', ftString, '', Self, '');
  FTel3 := TFieldDB.Create('tel3', ftString, '', Self, '');
  FTel4 := TFieldDB.Create('tel4', ftString, '', Self, '');
  FTel5 := TFieldDB.Create('tel5', ftString, '', Self, '');
  FFaks1 := TFieldDB.Create('faks1', ftString, '', Self, '');
  FFaks2 := TFieldDB.Create('faks2', ftString, '', Self, '');
  FMersisNo := TFieldDB.Create('mersis_no', ftString, '', Self, '');
  FTicaretSicilNo := TFieldDB.Create('ticaret_sicil_no', ftString, '', Self, '');
  FWebSite := TFieldDB.Create('web_site', ftString, '', Self, '');
  FEMail := TFieldDB.Create('email', ftString, '', Self, '');
  FVergiDairesi := TFieldDB.Create('vergi_dairesi', ftString, '', Self, '');
  FVergiNo := TFieldDB.Create('vergi_no', ftString, '', Self, '');
  FFormRengi := TFieldDB.Create('form_rengi', ftInteger, 0, Self, '');
  FDonem := TFieldDB.Create('donem', ftInteger, 0, Self, '');
  FMukellefTipiID := TFieldDB.Create('mukellef_tipi_id', ftInteger, 0, Self, '');
  FMukellefTipi := TFieldDB.Create(FSysMukellef.MukellefTipi.FieldName, FSysMukellef.MukellefTipi.DataType, '', Self, '');
  FUlkeID := TFieldDB.Create('ulke_id', ftInteger, 0, Self, '');
  FUlke := TFieldDB.Create(FSysUlke.UlkeAdi.FieldName, FSysUlke.UlkeAdi.DataType, '', Self, '');
  FSehirID := TFieldDB.Create('sehir_id', ftInteger, 0, Self, '');
  FSehir := TFieldDB.Create(FSysSehir.SehirAdi.FieldName, FSysSehir.SehirAdi.DataType, '', Self, '');
  FIlce := TFieldDB.Create('ilce', ftString, '', Self, '');
  FMahalle := TFieldDB.Create('mahalle', ftString, '', Self, '');
  FCadde := TFieldDB.Create('cadde', ftString, '', Self, '');
  FSokak := TFieldDB.Create('sokak', ftString, '', Self, '');
  FPostaKodu := TFieldDB.Create('posta_kodu', ftString, '', Self, '');
  FBinaAdi := TFieldDB.Create('bina_adi', ftString, '', Self, '');
  FKapiNo := TFieldDB.Create('kapi_no', ftString, '', Self, '');
  FUygulamaLisan := TFieldDB.Create('uygulama_lisan', ftString, '', Self, '');
  FMailHostName := TFieldDB.Create('mail_host_name', ftString, '', Self, '');
  FMailHostUser := TFieldDB.Create('mail_host_user', ftString, '', Self, '');
  FMailHostPass := TFieldDB.Create('mail_host_pass', ftString, '', Self, '');
  FMailHostSmtpPort := TFieldDB.Create('mail_host_smtp_port', ftInteger, 0, Self, '');
  FGridColor1 := TFieldDB.Create('grid_color_1', ftInteger, 0, Self, '');
  FGridColor2 := TFieldDB.Create('grid_color_2', ftInteger, 0, Self, '');
  FGridColorActive := TFieldDB.Create('grid_color_active', ftInteger, 0, Self, '');
  FCryptKey := TFieldDB.Create('crypt_key', ftInteger, 0, Self, '');
  FIsKaliteFormNoKullan := TFieldDB.Create('is_kalite_form_no_kullan', ftBoolean, False, Self, '');
  FSmsServiceProvider := TFieldDB.Create('sms_service_provider', ftString, '', Self, '');
  FSmsUser := TFieldDB.Create('sms_user', ftString, '', Self, '');
  FSmsPassword := TFieldDB.Create('sms_password', ftString, '', Self, '');
  FSmsTitle := TFieldDB.Create('sms_title', ftString, '', Self, '');
  FUygulamaSurum := TFieldDB.Create('uygulama_surum', ftString, '', Self, '');
end;

procedure TSysUygulamaAyari.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FLogo.FieldName,
        TableName + '.' + FUnvan.FieldName,
        TableName + '.' + FTel1.FieldName,
        TableName + '.' + FTel2.FieldName,
        TableName + '.' + FTel3.FieldName,
        TableName + '.' + FTel4.FieldName,
        TableName + '.' + FTel5.FieldName,
        TableName + '.' + FFaks1.FieldName,
        TableName + '.' + FFaks2.FieldName,
        TableName + '.' + FMersisNo.FieldName,
        TableName + '.' + FTicaretSicilNo.FieldName,
        TableName + '.' + FWebSite.FieldName,
        TableName + '.' + FEMail.FieldName,
        TableName + '.' + FVergiDairesi.FieldName,
        TableName + '.' + FVergiNo.FieldName,
        TableName + '.' + FFormRengi.FieldName,
        TableName + '.' + FDonem.FieldName,
        TableName + '.' + FMukellefTipiID.FieldName,
        addLangField(FMukellefTipi.FieldName),
        TableName + '.' + FUlkeID.FieldName,
        addLangField(FUlke.FieldName),
        TableName + '.' + FSehirID.FieldName,
        addLangField(FSehir.FieldName),
        TableName + '.' + FIlce.FieldName,
        TableName + '.' + FMahalle.FieldName,
        TableName + '.' + FCadde.FieldName,
        TableName + '.' + FSokak.FieldName,
        TableName + '.' + FPostaKodu.FieldName,
        TableName + '.' + FBinaAdi.FieldName,
        TableName + '.' + FKapiNo.FieldName,
        TableName + '.' + FUygulamaLisan.FieldName,
        TableName + '.' + FMailHostName.FieldName,
        TableName + '.' + FMailHostUser.FieldName,
        TableName + '.' + FMailHostPass.FieldName,
        TableName + '.' + FMailHostSmtpPort.FieldName,
        TableName + '.' + FGridColor1.FieldName,
        TableName + '.' + FGridColor2.FieldName,
        TableName + '.' + FGridColorActive.FieldName,
        TableName + '.' + FCryptKey.FieldName,
        TableName + '.' + FIsKaliteFormNoKullan.FieldName,
        TableName + '.' + FSmsServiceProvider.FieldName,
        TableName + '.' + FSmsUser.FieldName,
        TableName + '.' + FSmsPassword.FieldName,
        TableName + '.' + FSmsTitle.FieldName,
        TableName + '.' + FUygulamaSurum.FieldName
      ], [
        addLeftJoin(FMukellefTipi.FieldName, TableName + '.' + FMukellefTipiID.FieldName, FSysMukellef.TableName),
        addLeftJoin(FUlke.FieldName, TableName + '.' + FUlkeID.FieldName, FSysUlke.TableName),
        addLeftJoin(FSehir.FieldName, TableName + '.' + FSehirID.FieldName, FSysSehir.TableName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
    end;
  end;
end;

procedure TSysUygulamaAyari.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FLogo.FieldName,
        TableName + '.' + FUnvan.FieldName,
        TableName + '.' + FTel1.FieldName,
        TableName + '.' + FTel2.FieldName,
        TableName + '.' + FTel3.FieldName,
        TableName + '.' + FTel4.FieldName,
        TableName + '.' + FTel5.FieldName,
        TableName + '.' + FFaks1.FieldName,
        TableName + '.' + FFaks2.FieldName,
        TableName + '.' + FMersisNo.FieldName,
        TableName + '.' + FTicaretSicilNo.FieldName,
        TableName + '.' + FWebSite.FieldName,
        TableName + '.' + FEMail.FieldName,
        TableName + '.' + FVergiDairesi.FieldName,
        TableName + '.' + FVergiNo.FieldName,
        TableName + '.' + FFormRengi.FieldName,
        TableName + '.' + FDonem.FieldName,
        TableName + '.' + FMukellefTipiID.FieldName,
        addLangField(FMukellefTipi.FieldName),
        TableName + '.' + FUlkeID.FieldName,
        addLangField(FUlke.FieldName),
        TableName + '.' + FSehirID.FieldName,
        addLangField(FSehir.FieldName),
        TableName + '.' + FIlce.FieldName,
        TableName + '.' + FMahalle.FieldName,
        TableName + '.' + FCadde.FieldName,
        TableName + '.' + FSokak.FieldName,
        TableName + '.' + FPostaKodu.FieldName,
        TableName + '.' + FBinaAdi.FieldName,
        TableName + '.' + FKapiNo.FieldName,
        TableName + '.' + FUygulamaLisan.FieldName,
        TableName + '.' + FMailHostName.FieldName,
        TableName + '.' + FMailHostUser.FieldName,
        TableName + '.' + FMailHostPass.FieldName,
        TableName + '.' + FMailHostSmtpPort.FieldName,
        TableName + '.' + FGridColor1.FieldName,
        TableName + '.' + FGridColor2.FieldName,
        TableName + '.' + FGridColorActive.FieldName,
        TableName + '.' + FCryptKey.FieldName,
        TableName + '.' + FIsKaliteFormNoKullan.FieldName,
        TableName + '.' + FSmsServiceProvider.FieldName,
        TableName + '.' + FSmsUser.FieldName,
        TableName + '.' + FSmsPassword.FieldName,
        TableName + '.' + FSmsTitle.FieldName,
        TableName + '.' + FUygulamaSurum.FieldName
      ], [
        addLeftJoin(FMukellefTipi.FieldName, TableName + '.' + FMukellefTipiID.FieldName, FSysMukellef.TableName),
        addLeftJoin(FUlke.FieldName, TableName + '.' + FUlkeID.FieldName, FSysUlke.TableName),
        addLeftJoin(FSehir.FieldName, TableName + '.' + FSehirID.FieldName, FSysSehir.TableName),
        ' WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(QueryOfList);

        List.Add(Self.Clone);

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TSysUygulamaAyari.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FLogo.FieldName,
        FUnvan.FieldName,
        FTel1.FieldName,
        FTel2.FieldName,
        FTel3.FieldName,
        FTel4.FieldName,
        FTel5.FieldName,
        FFaks1.FieldName,
        FFaks2.FieldName,
        FMersisNo.FieldName,
        FTicaretSicilNo.FieldName,
        FWebSite.FieldName,
        FEMail.FieldName,
        FVergiDairesi.FieldName,
        FVergiNo.FieldName,
        FFormRengi.FieldName,
        FDonem.FieldName,
        FMukellefTipiID.FieldName,
        FUlkeID.FieldName,
        FSehirID.FieldName,
        FIlce.FieldName,
        FMahalle.FieldName,
        FCadde.FieldName,
        FSokak.FieldName,
        FPostaKodu.FieldName,
        FBinaAdi.FieldName,
        FKapiNo.FieldName,
        FUygulamaLisan.FieldName,
        FMailHostName.FieldName,
        FMailHostUser.FieldName,
        FMailHostPass.FieldName,
        FMailHostSmtpPort.FieldName,
        FGridColor1.FieldName,
        FGridColor2.FieldName,
        FGridColorActive.FieldName,
        FCryptKey.FieldName,
        FIsKaliteFormNoKullan.FieldName,
        FSmsServiceProvider.FieldName,
        FSmsUser.FieldName,
        FSmsPassword.FieldName,
        FSmsTitle.FieldName,
        FUygulamaSurum.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TSysUygulamaAyari.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FLogo.FieldName,
        FUnvan.FieldName,
        FTel1.FieldName,
        FTel2.FieldName,
        FTel3.FieldName,
        FTel4.FieldName,
        FTel5.FieldName,
        FFaks1.FieldName,
        FFaks2.FieldName,
        FMersisNo.FieldName,
        FTicaretSicilNo.FieldName,
        FWebSite.FieldName,
        FEMail.FieldName,
        FVergiDairesi.FieldName,
        FVergiNo.FieldName,
        FFormRengi.FieldName,
        FDonem.FieldName,
        FMukellefTipiID.FieldName,
        FUlkeID.FieldName,
        FSehirID.FieldName,
        FIlce.FieldName,
        FMahalle.FieldName,
        FCadde.FieldName,
        FSokak.FieldName,
        FPostaKodu.FieldName,
        FBinaAdi.FieldName,
        FKapiNo.FieldName,
        FUygulamaLisan.FieldName,
        FMailHostName.FieldName,
        FMailHostUser.FieldName,
        FMailHostPass.FieldName,
        FMailHostSmtpPort.FieldName,
        FGridColor1.FieldName,
        FGridColor2.FieldName,
        FGridColorActive.FieldName,
        FCryptKey.FieldName,
        FIsKaliteFormNoKullan.FieldName,
        FSmsServiceProvider.FieldName,
        FSmsUser.FieldName,
        FSmsPassword.FieldName,
        FSmsTitle.FieldName,
        FUygulamaSurum.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TSysUygulamaAyari.Delete(APermissionControl: Boolean);
begin
  raise Exception.Create(
    TranslateText('Bu bilgiler için silme iþlemi yapýlamaz!', FrameworkLang.MessageUnsupportedProcess, LngMsgData, LngSystem) + AddLBs + self.ClassName);
end;

destructor TSysUygulamaAyari.Destroy;
begin
  FSysMukellef.Free;
  FSysUlke.Free;
  FSysSehir.Free;
  inherited;
end;

function TSysUygulamaAyari.GetAddress: string;
begin
  Result := '';
  if FMahalle.Value <> '' then
    Result := Result + FMahalle.Value + ' MAH. ';

  if FCadde.Value <> '' then
    Result := Result + FCadde.Value + ' CD. ';

  if FSokak.Value <> '' then
    Result := Result + FSokak.Value + ' SK. ';

  if FKapiNo.Value <> '' then
    Result := Result + ' NO: ' + FKapiNo.Value;
end;

function TSysUygulamaAyari.Clone: TTable;
begin
  Result := TSysUygulamaAyari.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
