unit Ths.Database.Table.SysNeighborhood;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SysLocality,
  Ths.Database.Table.SysDistrict,
  Ths.Database.Table.SysCity;

type
  TSysNeighborhood = class(TTable)
  private
    FNeighborhood: TFieldDB;
    FPostalCode: TFieldDB;
    FLocalityID: TFieldDB;
    FLocality: TFieldDB;
    FDistrictID: TFieldDB;
    FDistrict: TFieldDB;
    FCityID: TFieldDB;
    FCity: TFieldDB;

    FSysLocality: TSysLocality;
    FSysDistrict: TSysDistrict;
    FSysCity: TSysCity;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property Neighborhood: TFieldDB read FNeighborhood write FNeighborhood;
    Property PostalCode: TFieldDB read FPostalCode write FPostalCode;
    Property LocalityID: TFieldDB read FLocalityID write FLocalityID;
    Property Locality: TFieldDB read FLocality write FLocality;
    Property DistrictID: TFieldDB read FDistrictID write FDistrictID;
    Property District: TFieldDB read FDistrict write FDistrict;
    Property CityID: TFieldDB read FCityID write FCityID;
    Property City: TFieldDB read FCity write FCity;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSysNeighborhood.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_neighborhoods';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited Create(ADatabase);

  FSysLocality := TSysLocality.Create(ADatabase);
  FSysDistrict := TSysDistrict.Create(ADatabase);
  FSysCity := TSysCity.Create(ADatabase);

  FNeighborhood := TFieldDB.Create('neighborhood', ftWideString, '', Self, 'Neighborhood');
  FPostalCode := TFieldDB.Create('postal_code', ftWideString, '', Self, 'Postal Code');
  FLocalityID := TFieldDB.Create('locality_id', ftInteger, 0, Self, 'Locality ID');
  FLocality := TFieldDB.Create(FSysLocality.Locality.FieldName, FSysLocality.Locality.DataType, '', Self, FSysLocality.Locality.Title);
  FDistrictID := TFieldDB.Create(FSysLocality.DistrictID.FieldName, FSysLocality.DistrictID.DataType, 0, Self, FSysLocality.DistrictID.Title);
  FDistrict := TFieldDB.Create(FSysDistrict.District.FieldName, FSysDistrict.District.DataType, '', Self, FSysDistrict.District.Title);
  FCityID := TFieldDB.Create(FSysDistrict.CityID.FieldName, FSysDistrict.CityID.DataType, '', Self, FSysDistrict.CityID.Title);
  FCity := TFieldDB.Create(FSysCity.City.FieldName, FSysCity.City.DataType, '', Self, FSysCity.City.Title);
end;

destructor TSysNeighborhood.Destroy;
begin
  FSysLocality.Free;
  FSysDistrict.Free;
  FSysCity.Free;
  inherited;
end;

procedure TSysNeighborhood.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FNeighborhood.QryName,
      FPostalCode.QryName,
      FLocalityID.QryName,
      addField(FSysLocality.TableName, FSysLocality.Locality.FieldName, FLocality.FieldName),
      addField(FSysDistrict.TableName, FSysDistrict.Id.FieldName, FDistrictID.FieldName),
      addField(FSysDistrict.TableName, FSysDistrict.District.FieldName, FDistrict.FieldName),
      addField(FSysCity.TableName, FSysCity.Id.FieldName, FCityID.FieldName),
      addField(FSysCity.TableName, FSysCity.City.FieldName, FCity.FieldName)
    ], [
      addJoin(jtLeft, FSysLocality.TableName, FSysLocality.Id.FieldName, TableName, FLocalityID.FieldName),
      addJoin(jtLeft, FSysDistrict.TableName, FSysDistrict.Id.FieldName, FSysLocality.TableName, FSysLocality.DistrictID.FieldName),
      addJoin(jtLeft, FSysCity.TableName, FSysCity.Id.FieldName, FSysDistrict.TableName, FSysDistrict.CityID.FieldName),
      ' WHERE 1=1 ' + AFilter
    ], AAllColumn, AHelper);
    Open;
    Active := True;
  end;
end;

procedure TSysNeighborhood.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
      FNeighborhood.QryName,
      FPostalCode.QryName,
      FLocalityID.QryName,
      addField(FSysLocality.TableName, FSysLocality.Locality.FieldName, FLocality.FieldName)
    ], [
      addJoin(jtLeft, FSysLocality.TableName, FSysLocality.Id.FieldName, TableName, FLocalityID.FieldName),
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

procedure TSysNeighborhood.DoInsert(out AID: Integer; APermissionControl: Boolean=True);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FNeighborhood.FieldName,
      FPostalCode.FieldName,
      FLocalityID.FieldName
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

procedure TSysNeighborhood.DoUpdate(APermissionControl: Boolean=True);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FNeighborhood.FieldName,
      FPostalCode.FieldName,
      FLocalityID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSysNeighborhood.Clone: TTable;
begin
  Result := TSysNeighborhood.Create(Database);
  CloneClassContent(Self, Result);
end;

end.




