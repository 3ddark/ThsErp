unit Ths.Database.Table.SysAdresler;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SysUlkeler,
  Ths.Database.Table.SysSehirler;

type
  TSysAdres = class(TTable)
  private
    FUlke: TFieldDB;
    FSehirId: TFieldDB;
    FSehir: TFieldDB;
    FMahalle: TFieldDB;
    FCadde: TFieldDB;
    FSokak: TFieldDB;
    FBinaAdi: TFieldDB;
    FKapiNo: TFieldDB;
    FPostaKutusu: TFieldDB;
    FPostaKodu: TFieldDB;
    FWeb: TFieldDB;
    FEmail: TFieldDB;
  published
    FSysUlke: TSysUlke;
    FSysSehir: TSysSehir;

    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property Ulke: TFieldDB read FUlke write FUlke;
    Property SehirId: TFieldDB read FSehirId write FSehirId;
    Property Sehir: TFieldDB read FSehir write FSehir;
    Property Mahalle: TFieldDB read FMahalle write FMahalle;
    Property Cadde: TFieldDB read FCadde write FCadde;
    Property Sokak: TFieldDB read FSokak write FSokak;
    Property BinaAdi: TFieldDB read FBinaAdi write FBinaAdi;
    Property KapiNo: TFieldDB read FKapiNo write FKapiNo;
    Property PostaKutusu: TFieldDB read FPostaKutusu write FPostaKutusu;
    Property PostaKodu: TFieldDB read FPostaKodu write FPostaKodu;
    Property Web: TFieldDB read FWeb write FWeb;
    Property Email: TFieldDB read FEmail write FEmail;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSysAdres.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_adresler';
  TableSourceCode := '1000';
  inherited Create(ADatabase);

  FSysUlke := TSysUlke.Create(ADatabase);
  FSysSehir := TSysSehir.Create(ADatabase);

  FUlke := TFieldDB.Create(FSysSehir.Ulke.FieldName, FSysSehir.Ulke.DataType, FSysSehir.Ulke.Value, Self, 'Ülke Kodu');
  FSehirId := TFieldDB.Create('sehir_id', ftLargeint, 0, Self, 'Þehir ID');
  FSehir := TFieldDB.Create(FSysSehir.Sehir.FieldName, FSysSehir.Sehir.DataType, FSysSehir.Sehir.Value, Self, 'Þehir');
  FMahalle := TFieldDB.Create('mahalle', ftWideString, '', Self, 'Mahalle');
  FCadde := TFieldDB.Create('cadde', ftWideString, '', Self, 'Cadde');
  FSokak := TFieldDB.Create('sokak', ftWideString, '', Self, 'Sokak');
  FBinaAdi := TFieldDB.Create('bina_adi', ftWideString, '', Self, 'Bina Adý');
  FKapiNo := TFieldDB.Create('kapi_no', ftWideString, '', Self, 'Kapý No');
  FPostaKutusu := TFieldDB.Create('posta_kutusu', ftWideString, '', Self, 'Posta Kutusu');
  FPostaKodu := TFieldDB.Create('posta_kodu', ftWideString, '', Self, 'Posta Kodu');
  FWeb := TFieldDB.Create('web', ftWideString, '', Self, 'Web');
  FEmail := TFieldDB.Create('email', ftWideString, '', Self, 'Email');
end;

destructor TSysAdres.Destroy;
begin
  FSysUlke.Free;
  FSysSehir.Free;
  inherited;
end;

procedure TSysAdres.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      addLangField(FUlke.FieldName),
      FSehirId.QryName,
      addLangField(FSehir.FieldName),
      FMahalle.QryName,
      FCadde.QryName,
      FSokak.QryName,
      FBinaAdi.QryName,
      FKapiNo.QryName,
      FPostaKutusu.QryName,
      FPostaKodu.QryName,
      FWeb.QryName,
      FEmail.QryName
    ], [
      addJoin(jtLeft, FSysSehir.TableName, FSysSehir.Id.FieldName, TableName, FSehirId.FieldName),
      addLeftJoin(FUlke.FieldName, FSysSehir.UlkeID.QryName, FSysUlke.TableName),
      addLeftJoin(FSehir.FieldName, FSehirId.QryName, FSysSehir.TableName),
      ' WHERE 1=1 ' + AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSysAdres.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      addLangField(FUlke.FieldName),
      FSehirId.QryName,
      addLangField(FSehir.FieldName),
      FMahalle.QryName,
      FCadde.QryName,
      FSokak.QryName,
      FBinaAdi.QryName,
      FKapiNo.QryName,
      FPostaKutusu.QryName,
      FPostaKodu.QryName,
      FWeb.QryName,
      FEmail.QryName
    ], [
      addJoin(jtLeft, FSysSehir.TableName, FSysSehir.Id.FieldName, TableName, FSehirId.FieldName),
      addLeftJoin(FUlke.FieldName, FSysSehir.UlkeID.QryName, FSysUlke.TableName),
      addLeftJoin(FSehir.FieldName, FSehirId.QryName, FSysSehir.TableName),
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
    List.Clear;
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

procedure TSysAdres.DoInsert(out AID: Integer; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FSehirId.FieldName,
      FMahalle.FieldName,
      FCadde.FieldName,
      FSokak.FieldName,
      FBinaAdi.FieldName,
      FKapiNo.FieldName,
      FPostaKutusu.FieldName,
      FPostaKodu.FieldName,
      FWeb.FieldName,
      FEmail.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
    then AID := Fields.FieldByName(Id.FieldName).AsInteger
    else AID := 0;
  finally
    Free;
  end;
end;

procedure TSysAdres.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FSehirId.FieldName,
      FMahalle.FieldName,
      FCadde.FieldName,
      FSokak.FieldName,
      FBinaAdi.FieldName,
      FKapiNo.FieldName,
      FPostaKutusu.FieldName,
      FPostaKodu.FieldName,
      FWeb.FieldName,
      FEmail.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSysAdres.Clone: TTable;
begin
  Result := TSysAdres.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
