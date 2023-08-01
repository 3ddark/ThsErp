unit Ths.Database.Table.SetPrsEhliyetler;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table;

type
  TSetPrsEhliyet = class(TTable)
  private
    FEhliyet: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property Ehliyet: TFieldDB read FEhliyet write FEhliyet;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSetPrsEhliyet.Create(ADatabase: TDatabase);
begin
  TableName := 'set_prs_ehliyetler';
  TableSourceCode := '1000';
  inherited Create(ADatabase);

  FEhliyet := TFieldDB.Create('ehliyet', ftWideString, '', Self, 'Ehliyet');
end;

procedure TSetPrsEhliyet.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FEhliyet.QryName
    ], [
      ' WHERE 1=1 ' + AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSetPrsEhliyet.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FEhliyet.QryName
    ], [
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

procedure TSetPrsEhliyet.DoInsert(out AID: Integer; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery;
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FEhliyet.FieldName
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

procedure TSetPrsEhliyet.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery;
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FEhliyet.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSetPrsEhliyet.Clone: TTable;
begin
  Result := TSetPrsEhliyet.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
