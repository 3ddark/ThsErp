unit Ths.Database.Table.SysUygulamaAyarlari;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  System.Variants,
  Vcl.Graphics,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SysAdresler,
  Ths.Database.Table.SysLisanlar;

type
  TSysUygulamaAyari = class(TTable)
  private
    FLogo: TFieldDB;
    FUnvan: TFieldDB;
    FTelefon: TFieldDB;
    FFaks: TFieldDB;
    FVergiDairesi: TFieldDB;
    FVergiNo: TFieldDB;
    FDonem: TFieldDB;
    FLisan: TFieldDB;
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
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    Adres: TSysAdres;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;
    procedure Delete(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    function GetAddress: string;

    Property Logo: TFieldDB read FLogo write FLogo;
    Property Unvan: TFieldDB read FUnvan write FUnvan;
    Property Telefon: TFieldDB read FTelefon write FTelefon;
    Property Faks: TFieldDB read FFaks write FFaks;
    Property VergiDairesi: TFieldDB read FVergiDairesi write FVergiDairesi;
    Property VergiNo: TFieldDB read FVergiNo write FVergiNo;
    Property Donem: TFieldDB read FDonem write FDonem;
    Property Lisan: TFieldDB read FLisan write FLisan;
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
  end;

implementation

uses
  Ths.Constants,
  Ths.Globals;

constructor TSysUygulamaAyari.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_uygulama_ayarlari';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  Adres := TSysAdres.Create(Database);

  FLogo := TFieldDB.Create('logo', ftBytes, 0, Self, '');
  FUnvan := TFieldDB.Create('unvan', ftString, '', Self, '');
  FTelefon := TFieldDB.Create('telefon', ftString, '', Self, '');
  FFaks := TFieldDB.Create('faks', ftString, '', Self, '');
  FVergiDairesi := TFieldDB.Create('vergi_dairesi', ftString, '', Self, '');
  FVergiNo := TFieldDB.Create('vergi_no', ftString, '', Self, '');
  FDonem := TFieldDB.Create('donem', ftInteger, 0, Self, '');
  FLisan := TFieldDB.Create('lisan', ftString, '', Self, '');
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
  FDigerAyarlar := TFieldDB.Create('diger_ayarlar', ftMemo, '', Self, '');
end;

procedure TSysUygulamaAyari.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FLogo.QryName,
      FUnvan.QryName,
      FTelefon.QryName,
      FFaks.QryName,
      FVergiDairesi.QryName,
      FVergiNo.QryName,
      FDonem.QryName,
      FLisan.QryName,
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
      FDigerAyarlar.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSysUygulamaAyari.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FLogo.QryName,
      FUnvan.QryName,
      FTelefon.QryName,
      FFaks.QryName,
      FVergiDairesi.QryName,
      FVergiNo.QryName,
      FDonem.QryName,
      FLisan.QryName,
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
      FDigerAyarlar.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
    List.Clear;
    while NOT EOF do
    begin
      PrepareTableClassFromQuery(LQry);

      Adres.SelectToList(' AND ' + Adres.Id.QryName + '=' + AdresID.AsString, False, False);

      List.Add(Clone);

      Next;
    end;
  finally
    Free;
  end;
end;

procedure TSysUygulamaAyari.DoInsert(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FLogo.FieldName,
      FUnvan.FieldName,
      FTelefon.FieldName,
      FFaks.FieldName,
      FVergiDairesi.FieldName,
      FVergiNo.FieldName,
      FDonem.FieldName,
      FLisan.FieldName,
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
      FDigerAyarlar.FieldName
    ]);

    Self.Adres.Insert(False);
    Self.AdresID.Value := Self.Adres.Id.Value;

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TSysUygulamaAyari.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FLogo.FieldName,
      FUnvan.FieldName,
      FTelefon.FieldName,
      FFaks.FieldName,
      FVergiDairesi.FieldName,
      FVergiNo.FieldName,
      FDonem.FieldName,
      FLisan.FieldName,
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
      FDigerAyarlar.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;

    Self.Adres.Update(False);
  finally
    Free;
  end;
end;

procedure TSysUygulamaAyari.Delete(APermissionControl: Boolean);
begin
  raise Exception.Create('Bu kayýt silinemez!' + AddLBs + self.ClassName);
end;

destructor TSysUygulamaAyari.Destroy;
begin
  Adres.Free;
  inherited;
end;

function TSysUygulamaAyari.GetAddress: string;
begin
  Result := '';
  if Adres.Mahalle.Value <> '' then
    Result := Result + Adres.Mahalle.Value + ' NBH. ';

  if Adres.Cadde.Value <> '' then
    Result := Result + Adres.Cadde.Value + ' RD. ';

  if Adres.Sokak.Value <> '' then
    Result := Result + Adres.Sokak.Value + ' ST. ';

  if Adres.KapiNo.Value <> '' then
    Result := Result + ' NO: ' + Adres.KapiNo.Value;
end;

function TSysUygulamaAyari.Clone: TTable;
begin
  Result := TSysUygulamaAyari.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
