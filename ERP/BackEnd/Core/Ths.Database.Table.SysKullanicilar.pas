unit Ths.Database.Table.SysKullanicilar;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Hash, Data.DB, FireDAC.Comp.Client,
  FireDAC.Comp.DataSet, Ths.Database, Ths.Database.Table;

type
  TLoginStatus = (UserNotFound=-1, InactiveUser=-2, InvalidAppVersion=-3, InvalidPassword=-4);

  TSysKullanici = class(TTable)
  private
    FKullaniciAdi: TFieldDB;
    FKullaniciSifre: TFieldDB;
    FIsAktif: TFieldDB;
    FIsYonetici: TFieldDB;
    FIsSuperKullanici: TFieldDB;
    FIpAdres: TFieldDB;
    FMacAdres: TFieldDB;
    FPersonelID: TFieldDB;
    FAdSoyad: TFieldDB;
  protected
    procedure BusinessInsert(APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    procedure CopyFromRights(FromUserID, ToUserID: Integer);

    class function Login(AUserName, APassword: string): Int64;
    function ChangePassword(ANewPassword: string): Boolean;

    property KullaniciAdi: TFieldDB read FKullaniciAdi write FKullaniciAdi;
    property KullaniciSifre: TFieldDB read FKullaniciSifre write FKullaniciSifre;
    property IsAktif: TFieldDB read FIsAktif write FIsAktif;
    property IsYonetici: TFieldDB read FIsYonetici write FIsYonetici;
    property IsSuperKullanici: TFieldDB read FIsSuperKullanici write FIsSuperKullanici;
    property IpAdres: TFieldDB read FIpAdres write FIpAdres;
    property MacAdres: TFieldDB read FMacAdres write FMacAdres;
    property PersonelID: TFieldDB read FPersonelID write FPersonelID;
    property AdSoyad: TFieldDB read FAdSoyad write FAdSoyad;
  end;

implementation

uses
  Ths.Globals, Ths.Constants, Ths.Database.Table.SysErisimHaklari,
  Ths.Database.Table.SysKaynaklar, Ths.Database.Table.PrsPersoneller,
  Ths.Database.Table.SysUygulamaAyarlari;

constructor TSysKullanici.Create(ADatabase: TDatabase);
var
  LEmployee: TPrsPersonel;
begin
  TableName := 'sys_kullanicilar';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  LEmployee := TPrsPersonel.Create(Database);
  try
    FKullaniciAdi := TFieldDB.Create('kullanici_adi', ftString, '', Self, 'Kullanýcý Adý');
    FKullaniciSifre := TFieldDB.Create('kullanici_sifre', ftString, '', Self, 'Kullanýcý Þifre');
    FIsAktif := TFieldDB.Create('is_aktif', ftBoolean, False, Self, 'Aktif?');
    FIsYonetici := TFieldDB.Create('is_yonetici', ftBoolean, False, Self, 'Yönetici?');
    FIsSuperKullanici := TFieldDB.Create('is_super_kullanici', ftBoolean, False, Self, 'Süper Kullanýcý?');
    FIpAdres := TFieldDB.Create('ip_adres', ftString, '', Self, 'Ip Adres');
    FMacAdres := TFieldDB.Create('mac_adres', ftString, '', Self, 'Mac Adres');
    FPersonelID := TFieldDB.Create('personel_id', ftInteger, 0, Self, 'Personel ID');
    FAdSoyad := TFieldDB.Create(LEmployee.AdSoyad.FieldName, LEmployee.AdSoyad.DataType, LEmployee.AdSoyad.Value, Self, LEmployee.AdSoyad.Title);
  finally
    FreeAndNil(LEmployee);
  end;
end;

procedure TSysKullanici.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
var
  LEmployee: TPrsPersonel;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LEmployee := TPrsPersonel.Create(Database);
  try
    with QryOfDS do
    begin
      Close;
      Database.SQLBuilder.GetSQLSelectCmd(QryOfDS, TableName, [
        Id.QryName,
        FKullaniciAdi.QryName,
        FKullaniciSifre.QryName,
        FIsAktif.QryName,
        FIsYonetici.QryName,
        FIsSuperKullanici.QryName,
        FIpAdres.QryName,
        FMacAdres.QryName,
        FPersonelID.QryName,
        addField(LEmployee.TableName, LEmployee.AdSoyad.FieldName, FAdSoyad.FieldName)
      ], [
        addJoin(jtLeft, LEmployee.TableName, LEmployee.Id.FieldName, TableName, FPersonelID.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
    end;
  finally
    LEmployee.Free;
  end;
end;

procedure TSysKullanici.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TFDQuery;
  LEmployee: TPrsPersonel;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  LEmployee := TPrsPersonel.Create(Database);
  try
    with LQry do
    begin
      Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
        Id.QryName,
        FKullaniciAdi.QryName,
        FKullaniciSifre.QryName,
        FIsAktif.QryName,
        FIsYonetici.QryName,
        FIsSuperKullanici.QryName,
        FIpAdres.QryName,
        FMacAdres.QryName,
        FPersonelID.QryName,
        addField(LEmployee.TableName, LEmployee.AdSoyad.FieldName, FAdSoyad.FieldName)
      ], [
        addJoin(jtLeft, LEmployee.TableName, LEmployee.Id.FieldName, TableName, FPersonelID.FieldName),
        ' WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(LQry);

        List.Add(Clone);

        Next;
      end;
    end;
  finally
    LQry.Free;
    LEmployee.Free;
  end;
end;

procedure TSysKullanici.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FKullaniciAdi.FieldName,
      FKullaniciSifre.FieldName,
      FIsAktif.FieldName,
      FIsYonetici.FieldName,
      FIsSuperKullanici.FieldName,
      FIpAdres.FieldName,
      FMacAdres.FieldName,
      FPersonelID.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSysKullanici.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FKullaniciAdi.FieldName,
      FIsAktif.FieldName,
      FIsYonetici.FieldName,
      FIsSuperKullanici.FieldName,
      FIpAdres.FieldName,
      FMacAdres.FieldName,
      FPersonelID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

procedure TSysKullanici.BusinessInsert(APermissionControl: Boolean);
var
  LAccessRight: TSysErisimHakki;
  LResource: TSysKaynak;
  LQry: TFDQuery;
begin
  Insert(APermissionControl);
  LAccessRight := TSysErisimHakki.Create(Database);
  LResource := TSysKaynak.Create(Database);
  LQry := DataBase.NewQuery();
  try
    LQry.SQL.Text :=
      'INSERT INTO ' + LAccessRight.TableName + ' (' +
        LAccessRight.KaynakID.FieldName + ', ' +
        LAccessRight.IsOkuma.FieldName + ', ' +
        LAccessRight.IsEkleme.FieldName + ', ' +
        LAccessRight.IsGuncelleme.FieldName + ', ' +
        LAccessRight.IsSilme.FieldName + ', ' +
        LAccessRight.IsOzel.FieldName + ', ' +
        LAccessRight.KullaniciID.FieldName + ') ' +
      '(SELECT ' + LResource.Id.QryName + ', false, false, false, false, false, ' + IntToStr(Self.Id.Value) + ' FROM ' + LResource.TableName + ')';
    LQry.ExecSQL;
  finally
    LAccessRight.Free;
    LResource.Free;
    LQry.Free;
  end;
end;

function TSysKullanici.Clone: TTable;
begin
  Result := TSysKullanici.Create(Database);
  CloneClassContent(Self, Result);
end;

procedure TSysKullanici.CopyFromRights(FromUserID, ToUserID: Integer);
var
  LQry: TFDQuery;
  LAccessRight: TSysErisimHakki;
begin
  LQry := GDataBase.NewQuery();
  LAccessRight := TSysErisimHakki.Create(GDataBase);
  try
    LQry.SQL.Clear;
    LQry.SQL.Text :=
      'UPDATE ' + LAccessRight.TableName + ' ri SET ' +
		    LAccessRight.IsOkuma.FieldName      + '=(SELECT ' + LAccessRight.IsOkuma.FieldName      + ' FROM ' + LAccessRight.TableName + ' r WHERE r.' + LAccessRight.KullaniciID.FieldName + '=' + IntToStr(FromUserID) + ' AND r.' + LAccessRight.KaynakID.FieldName + '=ri.' + LAccessRight.KaynakID.FieldName + '), ' +
		    LAccessRight.IsEkleme.FieldName     + '=(SELECT ' + LAccessRight.IsEkleme.FieldName     + ' FROM ' + LAccessRight.TableName + ' r WHERE r.' + LAccessRight.KullaniciID.FieldName + '=' + IntToStr(FromUserID) + ' AND r.' + LAccessRight.KaynakID.FieldName + '=ri.' + LAccessRight.KaynakID.FieldName + '), ' +
		    LAccessRight.IsGuncelleme.FieldName + '=(SELECT ' + LAccessRight.IsGuncelleme.FieldName + ' FROM ' + LAccessRight.TableName + ' r WHERE r.' + LAccessRight.KullaniciID.FieldName + '=' + IntToStr(FromUserID) + ' AND r.' + LAccessRight.KaynakID.FieldName + '=ri.' + LAccessRight.KaynakID.FieldName + '), ' +
		    LAccessRight.IsSilme.FieldName      + '=(SELECT ' + LAccessRight.IsSilme.FieldName      + ' FROM ' + LAccessRight.TableName + ' r WHERE r.' + LAccessRight.KullaniciID.FieldName + '=' + IntToStr(FromUserID) + ' AND r.' + LAccessRight.KaynakID.FieldName + '=ri.' + LAccessRight.KaynakID.FieldName + '), ' +
		    LAccessRight.IsOzel.FieldName       + '=(SELECT ' + LAccessRight.IsOzel.FieldName       + ' FROM ' + LAccessRight.TableName + ' r WHERE r.' + LAccessRight.KullaniciID.FieldName + '=' + IntToStr(FromUserID) + ' AND r.' + LAccessRight.KaynakID.FieldName + '=ri.' + LAccessRight.KaynakID.FieldName + ') ' +
      'WHERE ' + LAccessRight.KullaniciID.FieldName + '=' + IntToStr(ToUserID) +
       ' and ' + LAccessRight.KaynakID.FieldName + ' in (SELECT ' + LAccessRight.KaynakID.FieldName + ' FROM ' + LAccessRight.TableName + ' rf WHERE ' + LAccessRight.KullaniciID.FieldName + '=' + IntToStr(FromUserID) + ')';
    LQry.ExecSQL;
  finally
    LQry.Free;
    LAccessRight.Free;
  end;
end;

class function TSysKullanici.Login(AUserName, APassword: string): Int64;
var
  LUygulamaAyari: TSysUygulamaAyari;
  LUser: TSysKullanici;
  LHashPassword: string;
begin
  LUygulamaAyari := TSysUygulamaAyari.Create(GDataBase);
  LUser := TSysKullanici.Create(GDataBase);
  try
    LUygulamaAyari.SelectToList('', False, False);
    LUser.SelectToList(' AND ' + LUser.KullaniciAdi.QryName + '=' + QuotedStr(AUserName), False, False);

    Result := Ord(TLoginStatus.UserNotFound);
    if LUser.List.Count = 1 then
    begin
      if TSysKullanici(LUser.List[0]).IsAktif.AsBoolean then
      begin
        if LUygulamaAyari.Versiyon.AsString <> APP_VERSION then
        begin
          Result := Ord(TLoginStatus.InvalidAppVersion);
          Exit;
        end;

        LHashPassword := THashSHA2.GetHMAC(APassword, APP_KEY);
        if TSysKullanici(LUser.List[0]).KullaniciSifre.AsString <> LHashPassword then
        begin
          Result := Ord(TLoginStatus.InvalidPassword);
          Exit;
        end;

        Result := LUser.Id.AsInt64;
      end
      else
      begin
        Result := Ord(TLoginStatus.InactiveUser);
        Exit;
      end;
    end;
  finally
    LUygulamaAyari.Free;
    LUser.Free;
  end;
end;

function TSysKullanici.ChangePassword(ANewPassword: string): Boolean;
var
  LQry: TFDQuery;
  LHashPassword: string;
begin
  Result := True;
  try
    LHashPassword := THashSHA2.GetHMAC(ANewPassword, APP_KEY);

    LQry := DataBase.NewQuery();
    try
      LQry.SQL.Clear;
      LQry.SQL.Text :=
        'UPDATE ' + Self.TableName + ' SET ' + Self.FKullaniciSifre.FieldName + '=' + QuotedStr(LHashPassword) +
        ' WHERE ' + Self.Id.FieldName + '=' + IntToStr(Self.Id.AsInt64);
      LQry.ExecSQL;
    finally
      LQry.Free;
    end;

    if Self.Id.AsInt64 = GSysKullanici.Id.AsInt64 then
      GSysKullanici.SelectToList(' AND ' + GSysKullanici.Id.QryName + '=' + Self.Id.AsString, False, False);
  except
    Result := False;
  end;
end;

end.
