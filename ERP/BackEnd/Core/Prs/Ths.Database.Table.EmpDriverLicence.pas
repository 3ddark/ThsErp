unit Ths.Database.Table.EmpDriverLicence;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.EmpEhliyet;

type
  TEmpDriverLicence = class(TTable)
  private
    FEhliyetID: TFieldDB;
    FEhliyet: TFieldDB;
    FPersonelID: TFieldDB;
    FPersonel: TFieldDB;
  protected
    FEmpEhliyet: TEmpEhliyet;
  published
    destructor Destroy; override;
    constructor Create(ADatabase: TDatabase); override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property EhliyetID: TFieldDB read FEhliyetID write FEhliyetID;
    Property Ehliyet: TFieldDB read FEhliyet write FEhliyet;
    Property PersonelID: TFieldDB read FPersonelID write FPersonelID;
    Property Personel: TFieldDB read FPersonel write FPersonel;
  end;

implementation

uses
  Ths.Constants,
  Ths.Database.Table.EmpPersonnel;


constructor TEmpDriverLicence.Create(ADatabase: TDatabase);
var
  LEmp: TEmpPersonnel;
begin
  TableName := 'emp_person_driver_license';
  TableSourceCode := MODULE_PRS_AYAR;
  inherited Create(ADatabase);

  FEmpEhliyet := TEmpEhliyet.Create(Database);

  LEmp := TEmpPersonnel.Create(Database);
  try
    FEhliyetID := TFieldDB.Create('ehliyet_id', ftInteger, 0, Self);
    FEhliyet := TFieldDB.Create(FEmpEhliyet.Ehliyet.FieldName, FEmpEhliyet.Ehliyet.DataType, FEmpEhliyet.Ehliyet.Value, Self);
    FPersonelID := TFieldDB.Create('personel_id', ftInteger, 0, Self);
    FPersonel := TFieldDB.Create(LEmp.AdSoyad.FieldName, LEmp.AdSoyad.DataType, LEmp.AdSoyad.Value, Self);
  finally
    LEmp.Free;
  end;
end;

destructor TEmpDriverLicence.Destroy;
begin
  FreeAndNil(FEmpEhliyet);
  inherited;
end;

function TEmpDriverLicence.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
  LEmp: TEmpPersonnel;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LEmp := TEmpPersonnel.Create(Database);
  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FEhliyetID.QryName,
      addField(FEmpEhliyet.TableName, FEmpEhliyet.Ehliyet.FieldName, FEhliyet.FieldName),
      FPersonelID.QryName,
      addField(LEmp.TableName, LEmp.AdSoyad.FieldName, FPersonel.FieldName)
    ], [
      addJoin(jtLeft, FEmpEhliyet.TableName, FEmpEhliyet.Id.FieldName, TableName, FEhliyetID.FieldName),
      addJoin(jtLeft, LEmp.TableName, LEmp.Id.FieldName, TableName, FPersonelID.FieldName),
      ' WHERE 1=1 ' + AFilter
    ], AAllColumn, AHelper);
    Result := LQry.SQL.Text;
  finally
    LEmp.Free;
    LQry.Free;
  end;
end;

procedure TEmpDriverLicence.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LPersEmp: TEmpPersonnel;
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  LPersEmp := TEmpPersonnel.Create(Database);
  with LQry do
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FEhliyetID.QryName,
      addField(FEmpEhliyet.TableName, FEmpEhliyet.Ehliyet.FieldName, FEhliyet.FieldName),
      FPersonelID.QryName,
      addField(LPersEmp.TableName, LPersEmp.AdSoyad.FieldName, FPersonel.FieldName)
    ], [
      addJoin(jtLeft, FEmpEhliyet.TableName, FEmpEhliyet.Id.FieldName, TableName, FEhliyetID.FieldName),
      addJoin(jtLeft, LPersEmp.TableName, LPersEmp.Id.FieldName, TableName, FPersonelID.FieldName),
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
    LPersEmp.Free;
    LQry.Free;
  end;
end;

procedure TEmpDriverLicence.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FEhliyetID.FieldName,
      FPersonelID.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TEmpDriverLicence.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FEhliyetID.FieldName,
      FPersonelID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TEmpDriverLicence.Clone: TTable;
begin
  Result := TEmpDriverLicence.Create(Database);
  CloneClassContent(Self, Result);
end;

end.


