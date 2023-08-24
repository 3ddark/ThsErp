unit Ths.Database.Table.PrsEhliyetler;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SetPrsEhliyetler;

type
  TPrsEhliyet = class(TTable)
  private
    FEhliyetID: TFieldDB;
    FEhliyet: TFieldDB;
    FPersonelID: TFieldDB;
    FPersonel: TFieldDB;
  protected
    FSetPrsEhliyet: TSetPrsEhliyet;
  published
    destructor Destroy; override;
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
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
  Ths.Database.Table.PrsPersoneller;


constructor TPrsEhliyet.Create(ADatabase: TDatabase);
var
  LEmp: TPrsPersonel;
begin
  TableName := 'prs_ehliyetler';
  TableSourceCode := MODULE_PRS_AYAR;
  inherited Create(ADatabase);

  FSetPrsEhliyet := TSetPrsEhliyet.Create(Database);

  LEmp := TPrsPersonel.Create(Database);
  try
    FEhliyetID := TFieldDB.Create('ehliyet_id', ftInteger, 0, Self, 'Ehliyet ID');
    FEhliyet := TFieldDB.Create(FSetPrsEhliyet.Ehliyet.FieldName, FSetPrsEhliyet.Ehliyet.DataType, FSetPrsEhliyet.Ehliyet.Value, Self, FSetPrsEhliyet.Ehliyet.Title);
    FPersonelID := TFieldDB.Create('personel_id', ftInteger, 0, Self, 'Personel ID');
    FPersonel := TFieldDB.Create(LEmp.AdSoyad.FieldName, LEmp.AdSoyad.DataType, LEmp.AdSoyad.Value, Self, LEmp.AdSoyad.Title);
  finally
    LEmp.Free;
  end;
end;

destructor TPrsEhliyet.Destroy;
begin
  FreeAndNil(FSetPrsEhliyet);
  inherited;
end;

procedure TPrsEhliyet.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
var
  LEmp: TPrsPersonel;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LEmp := TPrsPersonel.Create(Database);
  try
    with QryOfDS do
    begin
      Close;
      SQL.Clear;
      Database.GetSQLSelectCmd(QryOfDS, TableName, [
        Id.QryName,
        FEhliyetID.QryName,
        addField(FSetPrsEhliyet.TableName, FSetPrsEhliyet.Ehliyet.FieldName, FEhliyet.FieldName),
        FPersonelID.QryName,
        addField(LEmp.TableName, LEmp.AdSoyad.FieldName, FPersonel.FieldName)
      ], [
        addJoin(jtLeft, FSetPrsEhliyet.TableName, FSetPrsEhliyet.Id.FieldName, TableName, FEhliyetID.FieldName),
        addJoin(jtLeft, LEmp.TableName, LEmp.Id.FieldName, TableName, FPersonelID.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
    end;
  finally
    LEmp.Free;
  end;
end;

procedure TPrsEhliyet.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LPersEmp: TPrsPersonel;
  LQry: TZQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  LPersEmp := TPrsPersonel.Create(Database);
  with LQry do
  try
    Database.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FEhliyetID.QryName,
      addField(FSetPrsEhliyet.TableName, FSetPrsEhliyet.Ehliyet.FieldName, FEhliyet.FieldName),
      FPersonelID.QryName,
      addField(LPersEmp.TableName, LPersEmp.AdSoyad.FieldName, FPersonel.FieldName)
    ], [
      addJoin(jtLeft, FSetPrsEhliyet.TableName, FSetPrsEhliyet.Id.FieldName, TableName, FEhliyetID.FieldName),
      addJoin(jtLeft, LPersEmp.TableName, LPersEmp.Id.FieldName, TableName, FPersonelID.FieldName),
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
    LPersEmp.Free;
  end;
end;

procedure TPrsEhliyet.DoInsert(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FEhliyetID.FieldName,
      FPersonelID.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TPrsEhliyet.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FEhliyetID.FieldName,
      FPersonelID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TPrsEhliyet.Clone: TTable;
begin
  Result := TPrsEhliyet.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
