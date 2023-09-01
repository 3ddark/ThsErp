unit Ths.Database.Table.SetPrsLisanSeviyeleri;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table;

type
  TSetPrsLisanSeviyesi = class(TTable)
  private
    FLisanSeviyesi: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property LisanSeviyesi: TFieldDB read FLisanSeviyesi write FLisanSeviyesi;
  end;

implementation

uses
  Ths.Constants;

constructor TSetPrsLisanSeviyesi.Create(ADatabase: TDatabase);
begin
  TableName := 'set_prs_lisan_seviyeleri';
  TableSourceCode := MODULE_PRS_AYAR;
  inherited Create(ADatabase);

  FLisanSeviyesi := TFieldDB.Create('lisan_seviyesi', ftWideString, '', Self, 'Lisan Seviyesi');
end;

procedure TSetPrsLisanSeviyesi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FLisanSeviyesi.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSetPrsLisanSeviyesi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FLisanSeviyesi.QryName
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

procedure TSetPrsLisanSeviyesi.DoInsert(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    Close;
    SQL.Clear;
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FLisanSeviyesi.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TSetPrsLisanSeviyesi.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Clear;
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FLisanSeviyesi.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSetPrsLisanSeviyesi.Clone: TTable;
begin
  Result := TSetPrsLisanSeviyesi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.

