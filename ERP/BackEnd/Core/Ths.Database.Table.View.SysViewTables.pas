﻿unit Ths.Database.Table.View.SysViewTables;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.View;

type
  TSysViewTables = class(TView)
  private
    FTableName: TFieldDB;
    FTableType: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property TableName1: TFieldDB read FTableName write FTableName;
    Property TableType: TFieldDB read FTableType write FTableType;
  end;

implementation

uses
  Ths.Constants;

constructor TSysViewTables.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_view_tables';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FTableName  := TFieldDB.Create('table_name', ftString, '', Self);
  FTableType := TFieldDB.Create('table_type', ftString, '', Self);
end;

function TSysViewTables.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FTableName.QryName,
      FTableType.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TSysViewTables.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
      FTableName.QryName,
      FTableType.QryName
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

function TSysViewTables.Clone: TTable;
begin
  Result := TSysViewTables.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
