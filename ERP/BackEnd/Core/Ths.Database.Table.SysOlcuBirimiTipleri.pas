unit Ths.Database.Table.SysOlcuBirimiTipleri;

interface

{$I Ths.inc}

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, Ths.Database,
  Ths.Database.Table, Ths.Constants;

type
  TOlcuBirimiTipi = (Zaman=1, Agirlik, Uzunluk, Miktar);

  TSysOlcuBirimiTipi = class(TTable)
  private
    FOlcuBirimiTipi: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
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

function TSysOlcuBirimiTipi.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FOlcuBirimiTipi.QryName
    ], [
      ' WHERE 1=1 ' + AFilter
    ], AAllColumn, AHelper);
    RESULT := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TSysOlcuBirimiTipi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
      FOlcuBirimiTipi.QryName
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

procedure TSysOlcuBirimiTipi.DoInsert(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FOlcuBirimiTipi.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSysOlcuBirimiTipi.DoUpdate(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FOlcuBirimiTipi.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TSysOlcuBirimiTipi.Clone: TTable;
begin
  Result := TSysOlcuBirimiTipi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
