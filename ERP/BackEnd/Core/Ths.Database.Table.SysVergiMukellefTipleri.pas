unit Ths.Database.Table.SysVergiMukellefTipleri;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Constants,
  Ths.Database,
  Ths.Database.Table;

type
  TVergiMukellefTipi = (VKN=1, TCKN=2);
  TSysVergiMukellefTipi = class(TTable)
  private
    FMukellefTipi: TFieldDB;
    FIsVarsayilan: TFieldDB;
  protected
    procedure BusinessInsert(APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property MukellefTipi: TFieldDB read FMukellefTipi write FMukellefTipi;
    Property IsVarsayilan: TFieldDB read FIsVarsayilan write FIsVarsayilan;
  end;

implementation

uses
  Ths.Globals;

constructor TSysVergiMukellefTipi.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_vergi_mukellef_tipleri';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FMukellefTipi := TFieldDB.Create('mukellef_tipi', ftString, '', Self, 'Mükellef Tipi');
  FIsVarsayilan := TFieldDB.Create('is_varsayilan', ftBoolean, False, Self, 'Varsayýlan?');
end;

procedure TSysVergiMukellefTipi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FMukellefTipi.QryName,
      FIsVarsayilan.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSysVergiMukellefTipi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      TableName + '.' + Self.Id.FieldName,
      TableName + '.' + FMukellefTipi.FieldName,
      TableName + '.' + FIsVarsayilan.FieldName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
    while NOT EOF do
    begin
      PrepareTableClassFromQuery(LQry);

      List.Add(Self.Clone);

      Next;
    end;
  finally
    Free;
  end;
end;

procedure TSysVergiMukellefTipi.DoInsert(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FMukellefTipi.FieldName,
      FIsVarsayilan.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TSysVergiMukellefTipi.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FMukellefTipi.FieldName, FIsVarsayilan.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

procedure TSysVergiMukellefTipi.BusinessInsert(APermissionControl: Boolean);
var
  LMukellef: TSysVergiMukellefTipi;
  n1: Integer;
begin
  if Self.IsVarsayilan.Value then
  begin
    LMukellef := TSysVergiMukellefTipi.Create(Database);
    try
      LMukellef.SelectToList('', False, False);
      for n1 := 0 to LMukellef.List.Count-1 do
      begin
        TSysVergiMukellefTipi(LMukellef.List[n1]).IsVarsayilan.Value := False;
        TSysVergiMukellefTipi(LMukellef.List[n1]).Update(False);
      end;
    finally
      FreeAndNil(LMukellef);
    end;
  end;
  Self.Insert(APermissionControl);
end;

procedure TSysVergiMukellefTipi.BusinessUpdate(APermissionControl: Boolean);
var
  LMukellef: TSysVergiMukellefTipi;
  n1: Integer;
begin
  if Self.IsVarsayilan.Value then
  begin
    LMukellef := TSysVergiMukellefTipi.Create(Database);
    try
      LMukellef.SelectToList('', False, False);
      for n1 := 0 to LMukellef.List.Count-1 do
      begin
        TSysVergiMukellefTipi(LMukellef.List[n1]).IsVarsayilan.Value := False;
        TSysVergiMukellefTipi(LMukellef.List[n1]).Update(False);
      end;
    finally
      FreeAndNil(LMukellef);
    end;
  end;
  Self.Update(APermissionControl);
end;

function TSysVergiMukellefTipi.Clone: TTable;
begin
  Result := TSysVergiMukellefTipi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
