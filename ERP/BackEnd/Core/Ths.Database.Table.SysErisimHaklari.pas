unit Ths.Database.Table.SysErisimHaklari;

interface

{$I Ths.inc}

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, Ths.Database,
  Ths.Database.Table, Ths.Database.Table.SysKaynaklar,
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
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
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

uses Ths.Globals, Ths.Constants;

constructor TSysErisimHakki.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_ersim_haklari';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FSysKaynak := TSysKaynak.Create(Database);
  FSysKullanici := TSysKullanici.Create(Database);

  FKaynakID := TFieldDB.Create('kaynak_id', ftInteger, 0, Self);
  FKaynakAdi := TFieldDB.Create(FSysKaynak.KaynakAdi.FieldName, FSysKaynak.KaynakAdi.DataType, FSysKaynak.KaynakAdi.Value, Self);
  FKaynakKodu := TFieldDB.Create(FSysKaynak.KaynakKodu.FieldName, FSysKaynak.KaynakKodu.DataType, FSysKaynak.KaynakKodu.Value, Self);
  FIsOkuma := TFieldDB.Create('is_okuma', ftBoolean, False, Self);
  FIsEkleme := TFieldDB.Create('is_ekleme', ftBoolean, False, Self);
  FIsGuncelleme := TFieldDB.Create('is_guncelleme', ftBoolean, False, Self);
  FIsSilme := TFieldDB.Create('is_silme', ftBoolean, False, Self);
  FIsOzel := TFieldDB.Create('is_ozel', ftBoolean, False, Self);
  FKullaniciID := TFieldDB.Create('kullanici_id', ftInteger, 0, Self);
  FKullanici := TFieldDB.Create(FSysKullanici.KullaniciAdi.FieldName, FSysKullanici.KullaniciAdi.DataType, FSysKullanici.KullaniciAdi.Value, Self);
end;

destructor TSysErisimHakki.Destroy;
begin
  FreeAndNil(FSysKaynak);
  FreeAndNil(FSysKullanici);
  inherited;
end;

procedure TSysErisimHakki.GetAccessRightBySourceCode(ASourceCode: string);
begin
  Self.SelectToList(' AND ' + FKaynakKodu.QryName + '=' + QuotedStr(ASourceCode) +
                    ' AND ' + FKullaniciID.QryName + '=' + IntToStr(GSysKullanici.Id.Value) , False, False);
end;

function TSysErisimHakki.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
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
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TSysErisimHakki.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LJoinTableName: string;
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LJoinTableName := 'data_' + FKaynakAdi.FieldName;

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
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
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FKaynakID.FieldName,            
      FIsOkuma.FieldName,
      FIsEkleme.FieldName,
      FIsGuncelleme.FieldName,
      FIsSilme.FieldName,
      FIsOzel.FieldName,
      FKullaniciID.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSysErisimHakki.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FKaynakID.FieldName,
      FIsOkuma.FieldName,
      FIsEkleme.FieldName,
      FIsGuncelleme.FieldName,
      FIsSilme.FieldName,
      FIsOzel.FieldName,
      FKullaniciID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TSysErisimHakki.Clone():TTable;
begin
  Result := TSysErisimHakki.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
