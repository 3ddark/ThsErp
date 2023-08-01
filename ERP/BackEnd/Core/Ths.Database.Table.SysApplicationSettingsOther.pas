unit Ths.Database.Table.SysApplicationSettingsOther;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table,
  Ths.Constants;

type
  TSysApplicationSettingsOther = class(TTable)
  private
    FPathUpdate: TFieldDB;
    FPathStockImage: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property PathUpdate: TFieldDB read FPathUpdate write FPathUpdate;
    Property PathStockImage: TFieldDB read FPathStockImage write FPathStockImage;
  end;

implementation

constructor TSysApplicationSettingsOther.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_application_settings_other';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FPathUpdate := TFieldDB.Create('path_update', ftString, '', Self, 'Update File Path');
  FPathStockImage := TFieldDB.Create('path_stock_image', ftString, '', Self, 'Stock Card Image Path');
end;

procedure TSysApplicationSettingsOther.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FPathUpdate.QryName,
      FPathStockImage.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSysApplicationSettingsOther.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FPathUpdate.QryName,
      FPathStockImage.QryName
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

procedure TSysApplicationSettingsOther.DoInsert(out AID: Integer; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FPathUpdate.FieldName,
      FPathStockImage.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
    then  AID := Fields.FieldByName(Id.FieldName).AsInteger
    else  AID := 0;
  finally
    Free;
  end;
end;

procedure TSysApplicationSettingsOther.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FPathUpdate.FieldName,
      FPathStockImage.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSysApplicationSettingsOther.Clone: TTable;
begin
  Result := TSysApplicationSettingsOther.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
