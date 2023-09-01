unit Ths.Database.Table.SysGunler;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table;

type
  TSysGun = class(TTable)
  private
    FGunAdi: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property GunAdi: TFieldDB read FGunAdi write FGunAdi;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSysGun.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_gunler';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FGunAdi := TFieldDB.Create('gun_adi', ftWideString, '', Self, 'Gün Adý');
end;

destructor TSysGun.Destroy;
begin
  inherited;
end;

procedure TSysGun.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FGunAdi.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSysGun.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FGunAdi.QryName
    ], [
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

procedure TSysGun.DoInsert(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FGunAdi.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TSysGun.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FGunAdi.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSysGun.Clone: TTable;
begin
  Result := TSysGun.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
