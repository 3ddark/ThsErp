unit Ths.Database.Table.UrtIscilikler;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SysOlcuBirimleri;

type
  TUrtIscilikTipi = (Degisken=1, Sabit);

  TUrtIscilik = class(TTable)
  private
    FGiderKodu: TFieldDB;
    FGiderAdi: TFieldDB;
    FFiyat: TFieldDB;
    FBirimID: TFieldDB;
    FBirim: TFieldDB;
    FGiderTipi: TFieldDB;
    //veri taban� alan� de�il
    FGiderTipiAdi: TFieldDB;
  published
    FSysUnit: TSysOlcuBirimi;

    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property GiderKodu: TFieldDB read FGiderKodu write FGiderKodu;
    Property GiderAdi: TFieldDB read FGiderAdi write FGiderAdi;
    Property Fiyat: TFieldDB read FFiyat write FFiyat;
    Property BirimID: TFieldDB read FBirimID write FBirimID;
    Property Birim: TFieldDB read FBirim write FBirim;
    Property GiderTipi: TFieldDB read FGiderTipi write FGiderTipi;
    Property GiderTipiAdi: TFieldDB read FGiderTipiAdi write FGiderTipiAdi;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TUrtIscilik.Create(ADatabase: TDatabase);
begin
  TableName := 'urt_iscilikler';
  TableSourceCode := MODULE_RCT_RECETE_AYAR;
  inherited Create(ADatabase);

  FSysUnit := TSysOlcuBirimi.Create(ADatabase);

  FGiderKodu := TFieldDB.Create('gider_kodu', ftWideString, '', Self, 'Gider Kodu');
  FGiderAdi := TFieldDB.Create('gider_adi', ftWideString, '', Self, 'Gider Ad�');
  FFiyat := TFieldDB.Create('fiyat', ftBCD, 0, Self, 'Fiyat');
  FBirimID := TFieldDB.Create('birim_id', ftInteger, 0, Self, 'Birim ID');
  FBirim := TFieldDB.Create(FSysUnit.Birim.FieldName, FSysUnit.Birim.DataType, FSysUnit.Birim.Value, Self, 'Birim');
  FGiderTipi := TFieldDB.Create('gider_tipi', ftSmallInt, 0, Self, 'Gider Tipi');
  FGiderTipiAdi := TFieldDB.Create('gider_tipi_adi', ftWideString, '', Self, 'Gider Tipi Ad�');
end;

destructor TUrtIscilik.Destroy;
begin
  FreeAndNil(FSysUnit);
  inherited;
end;

procedure TUrtIscilik.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.SQLBuilder.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FGiderKodu.QryName,
      FGiderAdi.QryName,
      FFiyat.QryName,
      FBirimID.QryName,
      addField(FSysUnit.TableName, FSysUnit.Birim.FieldName, FBirim.FieldName),
      FGiderTipi.QryName,
      FGiderTipiAdi.QryName
    ], [
      addJoin(jtLeft, FSysUnit.TableName, FSysUnit.Id.FieldName, TableName, FBirimID.FieldName),
      ' WHERE 1=1 ', AFilter
    ]);
    Open;
  end;
end;

procedure TUrtIscilik.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FGiderKodu.QryName,
      FGiderAdi.QryName,
      FFiyat.QryName,
      FBirimID.QryName,
      addField(FSysUnit.TableName, FSysUnit.Birim.FieldName, FBirim.FieldName),
      FGiderTipi.QryName,
      FGiderTipiAdi.QryName
    ], [
      addJoin(jtLeft, FSysUnit.TableName, FSysUnit.Id.FieldName, TableName, FBirimID.FieldName),
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

procedure TUrtIscilik.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FGiderKodu.FieldName,
      FGiderAdi.FieldName,
      FFiyat.FieldName,
      FBirimID.FieldName,
      FGiderTipi.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TUrtIscilik.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FGiderKodu.FieldName,
      FGiderAdi.FieldName,
      FFiyat.FieldName,
      FBirimID.FieldName,
      FGiderTipi.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TUrtIscilik.Clone: TTable;
begin
  Result := TUrtIscilik.Create(Database);
  CloneClassContent(Self, Result);
end;

end.




