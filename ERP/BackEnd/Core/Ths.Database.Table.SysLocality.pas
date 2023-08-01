unit Ths.Database.Table.SysLocality;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SysCity;

type
  TSysLocality = class(TTable)
  private
    FLocality: TFieldDB;
    FDistrictID: TFieldDB;
    FDistrict: TFieldDB;
    FCityID: TFieldDB;
    FCity: TFieldDB;

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

constructor TSysLocality.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_localities';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited Create(ADatabase);

  FSysCity := TSysCity.Create(ADatabase);

  FLocality := TFieldDB.Create('locality', ftWideString, '', Self, 'Locality');
  FDistrictID := TFieldDB.Create('district_id', ftInteger, 0, Self, 'District ID');
  FDistrict := TFieldDB.Create(FSysDistrict.District.FieldName, FSysDistrict.District.DataType, '', Self, FSysDistrict.District.Title);
  FCityID := TFieldDB.Create(FSysDistrict.CityID.FieldName, FSysDistrict.CityID.DataType, '', Self, FSysDistrict.CityID.Title);
  FCity := TFieldDB.Create(FSysCity.City.FieldName, FSysCity.City.DataType, '', Self, FSysCity.City.Title);
end;

destructor TSysLocality.Destroy;
begin
  FSysDistrict.Free;
  FSysCity.Free;
  inherited;
end;

procedure TSysLocality.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FLocality.QryName,
      FDistrictID.QryName,
      addField(FSysDistrict.TableName, FSysDistrict.District.FieldName, FDistrict.FieldName)
    ], [
      addJoin(jtLeft, FSysDistrict.TableName, FSysDistrict.Id.FieldName, TableName, FDistrictID.FieldName),
      ' WHERE 1=1 ' + AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSysLocality.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
      FLocality.QryName,
      addField(FSysDistrict.TableName, FSysDistrict.District.FieldName, FDistrict.FieldName)
    ], [
      addJoin(jtLeft, FSysDistrict.TableName, FSysDistrict.Id.FieldName, TableName, FDistrictID.FieldName),
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

procedure TSysLocality.DoInsert(out AID: Integer; APermissionControl: Boolean=True);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FLocality.FieldName,
      FDistrictID.FieldName
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

procedure TSysLocality.DoUpdate(APermissionControl: Boolean=True);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FLocality.FieldName,
      FDistrictID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSysLocality.Clone: TTable;
begin
  Result := TSysLocality.Create(Database);
  CloneClassContent(Self, Result);
end;

end.




