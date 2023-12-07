unit Ths.Database.Table.SysKullanicilar;

interface

{$I Ths.inc}

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  Ths.Database, Ths.Database.Table, Ths.Database.Table.PrsPersoneller;

type
  TKullaniciStruct = record
    KullaniciAdi: string;
    UserID: Integer;
  end;

  TUserList = TArray<TKullaniciStruct>;

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

    procedure CopyUserRightFromUser(AFromUserID: Integer);
    procedure CopyFromRights(FromUserID, ToUserID: Integer);
    function getActiveUsers(): TUserList;

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
  Ths.Database.Table.SysKaynaklar;

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

function TSysKullanici.getActiveUsers: TUserList;
var
  LKullanici: TSysKullanici;
  n1: Integer;
begin
  LKullanici := TSysKullanici.Create(Database);
  try
    LKullanici.SelectToList(' AND ' + LKullanici.FIsAktif.QryName + '=True', False, False);
    SetLength(Result, LKullanici.List.Count);
    for n1 := 0 to LKullanici.List.Count-1 do
    begin
      Result[n1].KullaniciAdi := TSysKullanici(LKullanici.List[n1]).FKullaniciAdi.Value;
      Result[n1].UserID := TSysKullanici(LKullanici.List[n1]).Id.Value;
    end;
  finally
    LKullanici.Free;
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
      Database.GetSQLSelectCmd(QryOfDS, TableName, [
        Id.QryName,
        FKullaniciAdi.QryName,
        'cast(' + FKullaniciSifre.QryName + ' as varchar(256)) ' + FKullaniciSifre.AsString,
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
      Database.GetSQLSelectCmd(LQry, TableName, [
        Id.QryName,
        FKullaniciAdi.QryName,
        'cast(' + FKullaniciSifre.QryName + ' as varchar(256)) ' + FKullaniciSifre.FieldName,
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
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FKullaniciAdi.FieldName,
      FKullaniciSifre.FieldName,
      FIsAktif.FieldName,
      FIsYonetici.FieldName,
      FIsSuperKullanici.FieldName,
      FIpAdres.FieldName,
      FMacAdres.FieldName,
      FPersonelID.FieldName
    ]);

    FKullaniciSifre.Value := getCryptedData(FKullaniciSifre.Value);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TSysKullanici.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FKullaniciAdi.FieldName,
      FIsAktif.FieldName,
      FIsYonetici.FieldName,
      FIsSuperKullanici.FieldName,
      FIpAdres.FieldName,
      FMacAdres.FieldName,
      FPersonelID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
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

procedure TSysKullanici.CopyUserRightFromUser(AFromUserID: Integer);
var
  LAccessRight: TSysErisimHakki;
  LResource: TSysKaynak;
  LQry: TFDQuery;
begin
  LAccessRight := TSysErisimHakki.Create(Database);
  LResource := TSysKaynak.Create(Database);
  LQry := DataBase.NewQuery();
  Database.Connection.StartTransaction;
  try
    try
      //geçerli kullanýcýya ait tüm eriþim haklarý siliniyor
      LQry.SQL.Text := 'DELETE FROM ' + LAccessRight.TableName + ' WHERE ' + LAccessRight.KullaniciID.QryName + '=' + Id.AsString;
      LQry.ExecSQL;

      //hakalarýn kopyalanacaðý kullanýcýdan tüm haklar mevcut kullanýcý için insert ediliyor.
      LQry.SQL.Text :=
        'INSERT INTO ' + LAccessRight.TableName + ' (' +
          LAccessRight.KaynakID.FieldName + ', ' +
          LAccessRight.IsOkuma.FieldName + ', ' +
          LAccessRight.IsEkleme.FieldName + ', ' +
          LAccessRight.IsGuncelleme.FieldName + ', ' +
          LAccessRight.IsSilme.FieldName + ', ' +
          LAccessRight.IsOzel.FieldName + ', ' +
          LAccessRight.KullaniciID.FieldName + ') ' +
        '(SELECT ' +
            't2.' + LAccessRight.KaynakID.FieldName + ', ' +
            't2.' + LAccessRight.IsOkuma.FieldName + ', ' +
            't2.' + LAccessRight.IsEkleme.FieldName + ', ' +
            't2.' + LAccessRight.IsGuncelleme.FieldName + ', ' +
            't2.' + LAccessRight.IsSilme.FieldName + ', ' +
            't2.' + LAccessRight.IsOzel.FieldName + ', ' +
            IntToStr(Self.Id.Value) + ' FROM ' + LAccessRight.TableName + ' as t2 )';
      LQry.ExecSQL;
      if Database.Connection.InTransaction then
        Database.Connection.Commit;
    finally
      LAccessRight.Free;
      LResource.Free;
      LQry.Free;
    end;
  except
    if Database.Connection.InTransaction then
      Database.Connection.Rollback;
  end;
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

end.
