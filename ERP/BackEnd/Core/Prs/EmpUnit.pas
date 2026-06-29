unit Emp.Unit;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.EmpBolum;

type
  TEmpUnit = class(TTable)
  private
    SectionId: TFieldDB;
  SectionName: TFieldDB;
  UnitName: TFieldDB;

    FEmpBolum: TEmpSection;
  published
    destructor Destroy; override;
    constructor Create(ADatabase: TDatabase); override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property BolumID: TFieldDB read FBolumID write FBolumID;
    Property Bolum: TFieldDB read FBolum write FBolum;
    Property Birim: TFieldDB read FBirim write FBirim;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TEmpUnit.Create(ADatabase: TDatabase);
begin
  TableName := 'emp_unit';
  TableSourceCode := MODULE_PRS_AYAR;
  inherited Create(ADatabase);

  FEmpBolum := TEmpSection.Create(Database);

  FBolumID := TFieldDB.Create('bolum_id', ftInteger, 0, Self);
  FBolum := TFieldDB.Create(FEmpBolum.Bolum.FieldName, FEmpBolum.Bolum.DataType, FEmpBolum.Bolum.Value, Self);
  FBirim := TFieldDB.Create('birim', ftWideString, '', Self);
end;

destructor TEmpUnit.Destroy;
begin
  FreeAndNil(FEmpBolum);
  inherited;
end;

function TEmpUnit.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FBolumID.QryName,
      addField(FEmpBolum.TableName, FEmpBolum.Bolum.FieldName, FBolum.FieldName),
      FBirim.QryName
    ], [
      addJoin(jtLeft, FEmpBolum.TableName, FEmpBolum.Id.FieldName, TableName, FBolumID.FieldName),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TEmpUnit.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        FBolumID.QryName,
        addField(FEmpBolum.TableName, FEmpBolum.Bolum.FieldName, FBolum.FieldName),
        FBirim.QryName
      ], [
        addJoin(jtLeft, FEmpBolum.TableName, FEmpBolum.Id.FieldName, TableName, FBolumID.FieldName),
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

procedure TEmpUnit.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FBolumID.FieldName,
      FBirim.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TEmpUnit.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FBolumID.FieldName,
      FBirim.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TEmpUnit.Clone: TTable;
begin
  Result := TEmpUnit.Create(Database);
  CloneClassContent(Self, Result);
end;

end.

