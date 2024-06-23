unit Ths.Database.Table.SysUygulamaAyarlari;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Variants, Vcl.Graphics, Data.DB, REST.Json,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, Ths.Database, Ths.Database.Table,
  Ths.Database.Table.SysAdresler;

type
  TSysUygulamaDigerAyarlar = class
  private
    FPathStokKartiResim: string;
    FPathPersonelKartiResim: string;
    FPathUpdate: string;
  public
    property PathStokKartiResim: string read FPathStokKartiResim write FPathStokKartiResim;
    property PathPersonelKartiResim: string read FPathPersonelKartiResim write FPathPersonelKartiResim;
    property PathUpdate: string read FPathUpdate write FPathUpdate;
  end;

  TSysUygulamaAyari = class(TTable)
  private
    FUnvan: TFieldDB;
    FTelefon: TFieldDB;
    FFaks: TFieldDB;
    FVergiDairesi: TFieldDB;
    FVergiNo: TFieldDB;
    FDonem: TFieldDB;
    FMailSunucu: TFieldDB;
    FMailKullanici: TFieldDB;
    FMailSifre: TFieldDB;
    FMailSmtpPort: TFieldDB;
    FGridRenk1: TFieldDB;
    FGridRenk2: TFieldDB;
    FGridRenkAktif: TFieldDB;
    FCryptKey: TFieldDB;
    FSmsSunucu: TFieldDB;
    FSmsKullanici: TFieldDB;
    FSmsSifre: TFieldDB;
    FSmsBaslik: TFieldDB;
    FVersiyon: TFieldDB;
    FPara: TFieldDB;
    FAdresID: TFieldDB;
    FDigerAyarlar: TFieldDB;
    FMukellefAdi: TFieldDB;
    FMukellefSoyadi: TFieldDB;
    FMukellefTipi: TFieldDB;
    FLogo: TFieldDB;
  protected
    procedure BusinessSelect(AFilter: string; ALock: Boolean; APermissionControl: Boolean); override;
    procedure BusinessInsert(APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    Adres: TSysAdres;
    DigerAyarlarJSon: TSysUygulamaDigerAyarlar;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;
    procedure Delete(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    function GetAddress: string;

    Property Unvan: TFieldDB read FUnvan write FUnvan;
    Property Telefon: TFieldDB read FTelefon write FTelefon;
    Property Faks: TFieldDB read FFaks write FFaks;
    Property VergiDairesi: TFieldDB read FVergiDairesi write FVergiDairesi;
    Property VergiNo: TFieldDB read FVergiNo write FVergiNo;
    Property Donem: TFieldDB read FDonem write FDonem;
    Property MailSunucu: TFieldDB read FMailSunucu write FMailSunucu;
    Property MailKullanici: TFieldDB read FMailKullanici write FMailKullanici;
    Property MailSifre: TFieldDB read FMailSifre write FMailSifre;
    Property MailSmtpPort: TFieldDB read FMailSmtpPort write FMailSmtpPort;
    Property GridRenk1: TFieldDB read FGridRenk1 write FGridRenk1;
    Property GridRenk2: TFieldDB read FGridRenk2 write FGridRenk2;
    Property GridRenkAktif: TFieldDB read FGridRenkAktif write FGridRenkAktif;
    Property CryptKey: TFieldDB read FCryptKey write FCryptKey;
    property SmsSunucu: TFieldDB read FSmsSunucu write FSmsSunucu;
    property SmsKullanici: TFieldDB read FSmsKullanici write FSmsKullanici;
    property SmsSifre: TFieldDB read FSmsSifre write FSmsSifre;
    property SmsBaslik: TFieldDB read FSmsBaslik write FSmsBaslik;
    property Versiyon: TFieldDB read FVersiyon write FVersiyon;
    Property Para: TFieldDB read FPara write FPara;
    Property AdresID: TFieldDB read FAdresID write FAdresID;
    Property DigerAyarlar: TFieldDB read FDigerAyarlar write FDigerAyarlar;
    Property MukellefAdi: TFieldDB read FMukellefAdi write FMukellefAdi;
    Property MukellefSoyadi: TFieldDB read FMukellefSoyadi write FMukellefSoyadi;
    Property MukellefTipi: TFieldDB read FMukellefTipi write FMukellefTipi;
    Property Logo: TFieldDB read FLogo write FLogo;
  end;

implementation

uses Ths.Constants, Ths.Globals;

constructor TSysUygulamaAyari.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_uygulama_ayarlari';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  Adres := TSysAdres.Create(Database);

  FUnvan := TFieldDB.Create('unvan', ftString, '', Self, '');
  FTelefon := TFieldDB.Create('telefon', ftString, '', Self, '');
  FFaks := TFieldDB.Create('faks', ftString, '', Self, '');
  FVergiDairesi := TFieldDB.Create('vergi_dairesi', ftString, '', Self, '');
  FVergiNo := TFieldDB.Create('vergi_no', ftString, '', Self, '');
  FDonem := TFieldDB.Create('donem', ftInteger, 0, Self, '');
  FMailSunucu := TFieldDB.Create('mail_sunucu', ftString, '', Self, '');
  FMailKullanici := TFieldDB.Create('mail_kullanici', ftString, '', Self, '');
  FMailSifre := TFieldDB.Create('mail_sifre', ftString, '', Self, '');
  FMailSmtpPort := TFieldDB.Create('mail_smtp_port', ftInteger, 0, Self, '');
  FGridRenk1 := TFieldDB.Create('grid_renk_1', ftInteger, 0, Self, '');
  FGridRenk2 := TFieldDB.Create('grid_renk_2', ftInteger, 0, Self, '');
  FGridRenkAktif := TFieldDB.Create('grid_renk_aktif', ftInteger, 0, Self, '');
  FCryptKey := TFieldDB.Create('crypt_key', ftInteger, 0, Self, '');
  FSmsSunucu := TFieldDB.Create('sms_sunucu', ftString, '', Self, '');
  FSmsKullanici := TFieldDB.Create('sms_kullanici', ftString, '', Self, '');
  FSmsSifre := TFieldDB.Create('sms_sifre', ftString, '', Self, '');
  FSmsBaslik := TFieldDB.Create('sms_baslik', ftString, '', Self, '');
  FVersiyon := TFieldDB.Create('versiyon', ftString, '', Self, '');
  FPara := TFieldDB.Create('para', ftString, '', Self, '');
  FAdresID := TFieldDB.Create('adres_id', ftLargeint, 0, Self, '');
  FDigerAyarlar := TFieldDB.Create('diger_ayarlar', ftWideMemo, '', Self, '');
  DigerAyarlarJSon := TSysUygulamaDigerAyarlar.Create;
  FMukellefAdi := TFieldDB.Create('mukellef_adi', ftString, '', Self, '');
  FMukellefSoyadi := TFieldDB.Create('mukellef_soyadi', ftString, '', Self, '');
  FMukellefTipi := TFieldDB.Create('mukellef_tipi', ftString, '', Self, '');
  FLogo := TFieldDB.Create('logo', ftBytes, '', Self, '');
end;

procedure TSysUygulamaAyari.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  Database.SQLBuilder.GetSQLSelectCmd(QryOfDS, TableName, [
    Id.QryName,
    FUnvan.QryName,
    FTelefon.QryName,
    FFaks.QryName,
    FVergiDairesi.QryName,
    FVergiNo.QryName,
    FDonem.QryName,
    FMailSunucu.QryName,
    FMailKullanici.QryName,
    FMailSifre.QryName,
    FMailSmtpPort.QryName,
    FGridRenk1.QryName,
    FGridRenk2.QryName,
    FGridRenkAktif.QryName,
    FCryptKey.QryName,
    FSmsSunucu.QryName,
    FSmsKullanici.QryName,
    FSmsSifre.QryName,
    FSmsBaslik.QryName,
    FVersiyon.QryName,
    FPara.QryName,
    FAdresID.QryName,
    FDigerAyarlar.QryName,
    FMukellefTipi.QryName,
    FMukellefAdi.QryName,
    FMukellefSoyadi.QryName,
    FLogo.QryName
  ], [
    ' WHERE 1=1 ', AFilter
  ], AAllColumn, AHelper);

  QryOfDS.Open;
end;

procedure TSysUygulamaAyari.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FUnvan.QryName,
      FTelefon.QryName,
      FFaks.QryName,
      FVergiDairesi.QryName,
      FVergiNo.QryName,
      FDonem.QryName,
      FMailSunucu.QryName,
      FMailKullanici.QryName,
      FMailSifre.QryName,
      FMailSmtpPort.QryName,
      FGridRenk1.QryName,
      FGridRenk2.QryName,
      FGridRenkAktif.QryName,
      FCryptKey.QryName,
      FSmsSunucu.QryName,
      FSmsKullanici.QryName,
      FSmsSifre.QryName,
      FSmsBaslik.QryName,
      FVersiyon.QryName,
      FPara.QryName,
      FAdresID.QryName,
      FDigerAyarlar.QryName,
      FMukellefTipi.QryName,
      FMukellefAdi.QryName,
      FMukellefSoyadi.QryName,
      FLogo.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    LQry.Open;

    FreeListContent();
    while NOT LQry.Eof do
    begin
      PrepareTableClassFromQuery(LQry);

      List.Add(Clone);

      LQry.Next;
    end;
  finally
    LQry.Free;
  end;
end;

procedure TSysUygulamaAyari.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FUnvan.FieldName,
      FTelefon.FieldName,
      FFaks.FieldName,
      FVergiDairesi.FieldName,
      FVergiNo.FieldName,
      FDonem.FieldName,
      FMailSunucu.FieldName,
      FMailKullanici.FieldName,
      FMailSifre.FieldName,
      FMailSmtpPort.FieldName,
      FGridRenk1.FieldName,
      FGridRenk2.FieldName,
      FGridRenkAktif.FieldName,
      FCryptKey.FieldName,
      FSmsSunucu.FieldName,
      FSmsKullanici.FieldName,
      FSmsSifre.FieldName,
      FSmsBaslik.FieldName,
      FVersiyon.FieldName,
      FPara.FieldName,
      FAdresID.FieldName,
      FDigerAyarlar.FieldName,
      FMukellefTipi.FieldName,
      FMukellefAdi.FieldName,
      FMukellefSoyadi.FieldName,
      FLogo.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSysUygulamaAyari.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FUnvan.FieldName,
      FTelefon.FieldName,
      FFaks.FieldName,
      FVergiDairesi.FieldName,
      FVergiNo.FieldName,
      FDonem.FieldName,
      FMailSunucu.FieldName,
      FMailKullanici.FieldName,
      FMailSifre.FieldName,
      FMailSmtpPort.FieldName,
      FGridRenk1.FieldName,
      FGridRenk2.FieldName,
      FGridRenkAktif.FieldName,
      FCryptKey.FieldName,
      FSmsSunucu.FieldName,
      FSmsKullanici.FieldName,
      FSmsSifre.FieldName,
      FSmsBaslik.FieldName,
      FVersiyon.FieldName,
      FPara.FieldName,
      FAdresID.FieldName,
      FDigerAyarlar.FieldName,
      FMukellefTipi.FieldName,
      FMukellefAdi.FieldName,
      FMukellefSoyadi.FieldName,
      FLogo.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);
    ParameterCasting(LQry, QRY_PAR_CH, FDigerAyarlar.FieldName, 'jsonb');

    LQry.ExecSQL;

    Self.Adres.Update(False);
  finally
    LQry.Free;
  end;
end;

procedure TSysUygulamaAyari.Delete(APermissionControl: Boolean);
begin
  raise Exception.Create('Bu kay�t silinemez!' + AddLBs + self.ClassName);
end;

destructor TSysUygulamaAyari.Destroy;
begin
  Adres.Free;
  DigerAyarlarJSon.Free;
  inherited;
end;

function TSysUygulamaAyari.GetAddress: string;
begin
  Result := '';
  if Adres.Mahalle.Value <> '' then
    Result := Result + Adres.Mahalle.Value + ' MAH. ';

  if Adres.Cadde.Value <> '' then
    Result := Result + Adres.Cadde.Value + ' CD. ';

  if Adres.Sokak.Value <> '' then
    Result := Result + Adres.Sokak.Value + ' SK. ';

  if Adres.KapiNo.Value <> '' then
    Result := Result + ' NO: ' + Adres.KapiNo.Value;
end;

procedure TSysUygulamaAyari.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
var
  ASysUygulamaAyari: TSysUygulamaAyari;
  n1: Integer;
begin
  Self.SelectToList(AFilter, ALock, APermissionControl);
  for n1 := 0 to List.Count-1 do
  begin
    ASysUygulamaAyari := TSysUygulamaAyari(List[n1]);
    if ASysUygulamaAyari.AdresID.AsInt64 > 0 then
      ASysUygulamaAyari.Adres.SelectToList(' AND ' + ASysUygulamaAyari.Adres.Id.QryName + '=' + ASysUygulamaAyari.AdresID.AsString, ALock, False);

    ASysUygulamaAyari.DigerAyarlarJSon.Free;
    ASysUygulamaAyari.DigerAyarlarJSon := TJson.JsonToObject<TSysUygulamaDigerAyarlar>(ASysUygulamaAyari.DigerAyarlar.AsString);
  end;
end;

procedure TSysUygulamaAyari.BusinessInsert(APermissionControl: Boolean);
begin
  Self.Adres.Insert(False);
  Self.AdresID.Value := Self.Adres.Id.Value;
  Self.FDigerAyarlar.Value := TJson.ObjectToJsonString(Self.DigerAyarlarJSon);
  Self.Insert(APermissionControl);
end;

procedure TSysUygulamaAyari.BusinessUpdate(APermissionControl: Boolean);
begin
  if Self.Adres.Id.AsInt64 > 0 then
    Self.Adres.Update(False)
  else
    Self.Adres.Insert(False);
  Self.AdresID.Value := Self.Adres.Id.AsInt64;
  Self.FDigerAyarlar.Value := TJson.ObjectToJsonString(Self.DigerAyarlarJSon);
  Self.Update(APermissionControl);
end;

function TSysUygulamaAyari.Clone: TTable;
begin
  Result := TSysUygulamaAyari.Create(Database);
  CloneClassContent(Self, Result);
  CloneClassContent(Self.Adres, TSysUygulamaAyari(Result).Adres);
end;

end.
