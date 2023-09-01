unit Ths.Database.Table.SysErisimHaklari;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SysKaynaklar,
  Ths.Database.Table.SysKullanicilar;

type
  TSysErisimHakki = class(TTable)
  private
    FKaynakID: TFieldDB;
    FKaynakAdi: TFieldDB;
    FKaynakKodu: TFieldDB;
    FIsOkuma: TFieldDB;
    FIsEkleme: TFieldDB;
    FIsGuncelleme: TFieldDB;
    FIsSilme: TFieldDB;
    FIsOzel: TFieldDB;
    FKullaniciID: TFieldDB;
    FKullanici: TFieldDB;
  published
    FSysKaynak: TSysKaynak;
    FSysKullanici: TSysKullanici;

    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;
    destructor Destroy; override;

    procedure GetAccessRightBySourceCode(ASourceCode: string);

    Property KaynakID: TFieldDB read FKaynakID write FKaynakID;
    Property KaynakAdi: TFieldDB read FKaynakAdi write FKaynakAdi;
    Property KaynakKodu: TFieldDB read FKaynakKodu write FKaynakKodu;
    Property IsOkuma: TFieldDB read FIsOkuma write FIsOkuma;
    Property IsEkleme: TFieldDB read FIsEkleme write FIsEkleme;
    Property IsGuncelleme: TFieldDB read FIsGuncelleme write FIsGuncelleme;
    Property IsSilme: TFieldDB read FIsSilme write FIsSilme;
    Property IsOzel: TFieldDB read FIsOzel write FIsOzel;
    Property KullaniciID: TFieldDB read FKullaniciID write FKullaniciID;
    Property Kullanici: TFieldDB read FKullanici write FKullanici;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSysErisimHakki.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_ersim_haklari';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FSysKaynak := TSysKaynak.Create(Database);
  FSysKullanici := TSysKullanici.Create(Database);

  FKaynakID := TFieldDB.Create('kaynak_id', ftInteger, 0, Self, 'Kaynak ID');
  FKaynakAdi := TFieldDB.Create(FSysKaynak.KaynakAdi.FieldName, FSysKaynak.KaynakAdi.DataType, '', Self, FSysKaynak.KaynakAdi.Title);
  FKaynakKodu := TFieldDB.Create(FSysKaynak.KaynakKodu.FieldName, FSysKaynak.KaynakKodu.DataType, '', Self, FSysKaynak.KaynakKodu.Title);
  FIsOkuma := TFieldDB.Create('is_okuma', ftBoolean, False, Self, 'Okuma?');
  FIsEkleme := TFieldDB.Create('is_ekleme', ftBoolean, False, Self, 'Ekleme?');
  FIsGuncelleme := TFieldDB.Create('is_guncelleme', ftBoolean, False, Self, 'Güncelleme?');
  FIsSilme := TFieldDB.Create('is_silme', ftBoolean, False, Self, 'Silme?');
  FIsOzel := TFieldDB.Create('is_ozel', ftBoolean, False, Self, 'Özel?');
  FKullaniciID := TFieldDB.Create('kullanici_id', ftInteger, 0, Self, 'Kullanýcý ID');
  FKullanici := TFieldDB.Create(FSysKullanici.KullaniciAdi.FieldName, FSysKullanici.KullaniciAdi.DataType, FSysKullanici.KullaniciAdi.Value, Self, FSysKullanici.KullaniciAdi.Title);
end;

destructor TSysErisimHakki.Destroy;
begin
  FreeAndNil(FSysKaynak);
  FreeAndNil(FSysKullanici);
  inherited;
end;

procedure TSysErisimHakki.GetAccessRightBySourceCode(ASourceCode: string);
begin
  Self.SelectToList(
    ' AND ' + FKaynakKodu.QryName + '=' + QuotedStr(ASourceCode) +
    ' AND ' + FKullaniciID.QryName + '=' + IntToStr(GSysKullanici.Id.Value) , False, False
  );
end;

procedure TSysErisimHakki.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
var
  LDump: string;
  LJoinTableName: string;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LDump := '';
  LJoinTableName := 'data_' + FKaynakAdi.FieldName;
  if  (AppLanguage <> GSysApplicationSetting.Lisan.AsString)
  and (GSysApplicationSetting.Lisan.AsString <> '')
  then
  begin
    LDump := 'LEFT JOIN ' + FSysKaynak.TableName + ' ON ' + FSysKaynak.TableName + '.id=' + FKaynakID.QryName;
    LJoinTableName := FSysKaynak.TableName;
  end;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Self.Id.QryName,
      FKaynakID.QryName,
      addLangField(FKaynakAdi.FieldName),
      'data_' + FKaynakAdi.FieldName + '.' + FKaynakKodu.FieldName,
      FIsOkuma.QryName,
      FIsEkleme.QryName,
      FIsGuncelleme.QryName,
      FIsSilme.QryName,
      FIsOzel.QryName,
      FKullaniciID.QryName,
      addLangField(FKullanici.FieldName)
    ], [
      addLeftJoin(FKaynakAdi.FieldName, FKaynakID.QryName, FSysKaynak.TableName),
      addLeftJoin(FKullanici.FieldName, FKullaniciID.QryName, FSysKullanici.TableName),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSysErisimHakki.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LDump: string;
  LJoinTableName: string;
  LQry: TZQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LDump := '';
  LJoinTableName := 'data_' + FKaynakAdi.FieldName;
  if  (AppLanguage <> GSysApplicationSetting.Lisan.AsString)
  and (GSysApplicationSetting.Lisan.AsString <> '')
  then
  begin
    LDump := 'LEFT JOIN ' + FSysKaynak.TableName + ' ON ' + FSysKaynak.TableName + '.id=' + FKaynakID.QryName;
    LJoinTableName := FSysKaynak.TableName;
  end;

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.GetSQLSelectCmd(LQry, TableName, [
      Self.Id.QryName,
      FKaynakID.QryName,
      addLangField(FKaynakAdi.FieldName),
      LJoinTableName + '.' + FKaynakKodu.FieldName,
      FIsOkuma.QryName,
      FIsEkleme.QryName,
      FIsGuncelleme.QryName,
      FIsSilme.QryName,
      FIsOzel.QryName,
      FKullaniciID.QryName,
      addLangField(FKullanici.FieldName)
    ], [
      LDump,
      addLeftJoin(FKaynakAdi.FieldName, TableName + '.' + FKaynakID.FieldName, FSysKaynak.TableName),
      addLeftJoin(FKullanici.FieldName, TableName + '.' + FKullaniciID.FieldName, FSysKullanici.TableName),
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
  finally
    Free;
  end;
end;

procedure TSysErisimHakki.DoInsert(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FKaynakID.FieldName,            
      FIsOkuma.FieldName,
      FIsEkleme.FieldName,
      FIsGuncelleme.FieldName,
      FIsSilme.FieldName,
      FIsOzel.FieldName,
      FKullaniciID.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TSysErisimHakki.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FKaynakID.FieldName,
      FIsOkuma.FieldName,
      FIsEkleme.FieldName,
      FIsGuncelleme.FieldName,
      FIsSilme.FieldName,
      FIsOzel.FieldName,
      FKullaniciID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSysErisimHakki.Clone():TTable;
begin
  Result := TSysErisimHakki.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
