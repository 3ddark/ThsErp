unit Ths.Database.Table.SetPrsEhliyetler;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
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
    procedure DoInsert(APermissionControl: Boolean=True); override;
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
  TableSourceCode := MODULE_PRS_AYAR;
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
  LQry: TFDQuery;
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
    while NOT EOF do
    begin
      PrepareTableClassFromQuery(LQry);

      List.Add(Clone);

      Next;
    end;
  finally
    LQry.Free;
  end;
end;

procedure TSetPrsEhliyet.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery;
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FEhliyet.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSetPrsEhliyet.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
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
