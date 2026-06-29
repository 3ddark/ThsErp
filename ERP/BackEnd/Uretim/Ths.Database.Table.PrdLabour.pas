unit Ths.Database.Table.PrdLabour;

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
  TLabourType = (Variable = 1, Fixed);

  TPrdLabour = class(TTable)
  private
    FExpenseCode: TFieldDB;
    FExpenseName: TFieldDB;
    FPrice: TFieldDB;
    FUnitId: TFieldDB;
    FUnitName: TFieldDB;
    FLabourType: TFieldDB;
    //not a database field
    FLabourTypeName: TFieldDB;
  published
    FUnit: TSysOlcuBirimi;

    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property ExpenseCode: TFieldDB read FExpenseCode write FExpenseCode;
    Property ExpenseName: TFieldDB read FExpenseName write FExpenseName;
    Property Price: TFieldDB read FPrice write FPrice;
    Property UnitId: TFieldDB read FUnitId write FUnitId;
    Property UnitName: TFieldDB read FUnitName write FUnitName;
    Property LabourType: TFieldDB read FLabourType write FLabourType;
    Property LabourTypeName: TFieldDB read FLabourTypeName write FLabourTypeName;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TPrdLabour.Create(ADatabase: TDatabase);
begin
  TableName := 'prd_labour';
  TableSourceCode := MODULE_RCT_RECETE_AYAR;
  inherited Create(ADatabase);

  FUnit := TSysOlcuBirimi.Create(ADatabase);

  FExpenseCode := TFieldDB.Create('gider_kodu', ftWideString, '', Self);
  FExpenseName := TFieldDB.Create('gider_adi', ftWideString, '', Self);
  FPrice := TFieldDB.Create('fiyat', ftBCD, 0, Self);
  FUnitId := TFieldDB.Create('birim_id', ftInteger, 0, Self);
  FUnitName := TFieldDB.Create(FUnit.Birim.FieldName, FUnit.Birim.DataType, FUnit.Birim.Value, Self);
  FLabourType := TFieldDB.Create('gider_tipi', ftSmallInt, 0, Self);
  FLabourTypeName := TFieldDB.Create('gider_tipi_adi', ftWideString, '', Self);
end;

destructor TPrdLabour.Destroy;
begin
  FreeAndNil(FUnit);
  inherited;
end;

function TPrdLabour.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FExpenseCode.QryName,
      FExpenseName.QryName,
      FPrice.QryName,
      FUnitId.QryName,
      addField(FUnit.TableName, FUnit.Birim.FieldName, FUnitName.FieldName),
      FLabourType.QryName,
      'CASE ' +
        'WHEN ' + FLabourType.QryName + '=' + Ord(TLabourType.Variable).ToString + ' THEN ' + QuotedStr('VARIABLE') +
        'WHEN ' + FLabourType.QryName + '=' + Ord(TLabourType.Fixed).ToString    + ' THEN ' + QuotedStr('FIXED') +
        'ELSE null ' +
      'END AS ' + FLabourTypeName.FieldName
    ], [
      addJoin(jtLeft, FUnit.TableName, FUnit.Id.FieldName, TableName, FUnitId.FieldName),
      ' WHERE 1=1 ', AFilter
    ]);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TPrdLabour.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FExpenseCode.QryName,
      FExpenseName.QryName,
      FPrice.QryName,
      FUnitId.QryName,
      addField(FUnit.TableName, FUnit.Birim.FieldName, FUnitName.FieldName),
      FLabourType.QryName,
      FLabourType.QryName,
      'CASE ' +
        'WHEN ' + FLabourType.QryName + '=' + Ord(TLabourType.Variable).ToString + ' THEN ' + QuotedStr('VARIABLE') +
        'WHEN ' + FLabourType.QryName + '=' + Ord(TLabourType.Fixed).ToString    + ' THEN ' + QuotedStr('FIXED') +
        'ELSE null ' +
      'END AS ' + FLabourTypeName.FieldName
    ], [
      addJoin(jtLeft, FUnit.TableName, FUnit.Id.FieldName, TableName, FUnitId.FieldName),
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

procedure TPrdLabour.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FExpenseCode.FieldName,
      FExpenseName.FieldName,
      FPrice.FieldName,
      FUnitId.FieldName,
      FLabourType.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TPrdLabour.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FExpenseCode.FieldName,
      FExpenseName.FieldName,
      FPrice.FieldName,
      FUnitId.FieldName,
      FLabourType.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TPrdLabour.Clone: TTable;
begin
  Result := TPrdLabour.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
