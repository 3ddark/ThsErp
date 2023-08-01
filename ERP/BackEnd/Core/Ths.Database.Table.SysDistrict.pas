unit Ths.Database.Table.SysDistrict;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SysCity,
  Ths.Database.Table.SysCountry;

type
  TSysDistrict = class(TTable)
  private
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

    Property District: TFieldDB read FDistrict write FDistrict;
    Property CityID: TFieldDB read FCityID write FCityID;
    Property City: TFieldDB read FCity write FCity;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSysDistrict.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_districts';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited Create(ADatabase);

  FSysCity := TSysCity.Create(ADatabase);

  FDistrict := TFieldDB.Create('district', ftWideString, '', Self, 'District');
  FCityID := TFieldDB.Create('city_id', ftInteger, 0, Self, 'City ID');
  FCity := TFieldDB.Create(FSysCity.City.FieldName, FSysCity.City.DataType, FSysCity.City.Value, Self, FSysCity.City.Title);
end;

destructor TSysDistrict.Destroy;
begin
  FSysCity.Free;
  inherited;
end;

procedure TSysDistrict.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FDistrict.QryName,
      FCityID.QryName,
      addField(FSysCity.TableName, FSysCity.City.FieldName, FCity.FieldName)
    ], [
      addJoin(jtLeft, FSysCity.TableName, FSysCity.Id.FieldName, TableName, FCityID.FieldName),
      ' WHERE 1=1 ' + AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSysDistrict.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
      FDistrict.QryName,
      FCityID.QryName,
      addField(FSysCity.TableName, FSysCity.City.FieldName, FCity.FieldName)
    ], [
      addJoin(jtLeft, FSysCity.TableName, FSysCity.Id.FieldName, TableName, FCityID.FieldName),
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

procedure TSysDistrict.DoInsert(out AID: Integer; APermissionControl: Boolean=True);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FDistrict.FieldName,
      FCityID.FieldName
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

procedure TSysDistrict.DoUpdate(APermissionControl: Boolean=True);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FDistrict.FieldName,
      FCityID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSysDistrict.Clone: TTable;
begin
  Result := TSysDistrict.Create(Database);
  CloneClassContent(Self, Result);
end;

end.



