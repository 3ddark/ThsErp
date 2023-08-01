unit Ths.Database.Table.SysOlcuBirimiTipleri;

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
  TOlcuBirimiTipi = (Zaman=1, Agirlik, Uzunluk, Miktar);

  TSysOlcuBirimiTipi = class(TTable)
  private
    FOlcuBirimiTipi: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property OlcuBirimiTipi: TFieldDB read FOlcuBirimiTipi write FOlcuBirimiTipi;
  end;

implementation

constructor TSysOlcuBirimiTipi.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_olcu_birimi_tipleri';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited Create(ADatabase);

  FOlcuBirimiTipi := TFieldDB.Create('olcu_birimi_tipi', ftWideString, '', Self, 'Ölçü Birimi Tipi');
end;

procedure TSysOlcuBirimiTipi.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FOlcuBirimiTipi.QryName
    ], [
      ' WHERE 1=1 ' + AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSysOlcuBirimiTipi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
      FOlcuBirimiTipi.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
    List.Clear;
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

procedure TSysOlcuBirimiTipi.DoInsert(out AID: Integer; APermissionControl: Boolean=True);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FOlcuBirimiTipi.FieldName
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

procedure TSysOlcuBirimiTipi.DoUpdate(APermissionControl: Boolean=True);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FOlcuBirimiTipi.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSysOlcuBirimiTipi.Clone: TTable;
begin
  Result := TSysOlcuBirimiTipi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
