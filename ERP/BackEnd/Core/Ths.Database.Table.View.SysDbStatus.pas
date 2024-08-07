﻿unit Ths.Database.Table.View.SysDbStatus;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.View;

type
  TSysDBStatus = class(TView)
  private
    FPID: TFieldDB;
    FDBName: TFieldDB;
    FAppName: TFieldDB;
    FUserName: TFieldDB;
    FClientAddress: TFieldDB;
    FState: TFieldDB;
    FQuery: TFieldDB;
    FLockedTables: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    function SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property PID: TFieldDB read FPID write FPID;
    Property DBName: TFieldDB read FDBName write FDBName;
    Property AppName: TFieldDB read FAppName write FAppName;
    Property UserName: TFieldDB read FUserName write FUserName;
    Property ClientAddress: TFieldDB read FClientAddress write FClientAddress;
    Property State: TFieldDB read FState write FState;
    Property Query: TFieldDB read FQuery write FQuery;
    Property LockedTables: TFieldDB read FLockedTables write FLockedTables;
  end;

implementation

uses
  Ths.Constants;

constructor TSysDBStatus.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_db_status';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FPID := TFieldDB.Create('pid', ftInteger, 0, Self);
  FDBName := TFieldDB.Create('db_name', ftWideString, '', Self);
  FAppName := TFieldDB.Create('app_name', ftWideString, '', Self);
  FUserName := TFieldDB.Create('user_name', ftWideString, '', Self);
  FClientAddress := TFieldDB.Create('client_address', ftWideString, '', Self);
  FState := TFieldDB.Create('state', ftWideString, '', Self);
  FQuery := TFieldDB.Create('query', ftWideString, '', Self);
  FLockedTables := TFieldDB.Create('locked_tables', ftWideString, '', Self);
end;

function TSysDBStatus.SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, pPermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FPID.QryName,
      FDBName.QryName,
      'cast(' + FAppName.QryName + ' as varchar(128)) ' + FAppName.FieldName,
      FUserName.QryName,
      FClientAddress.QryName,
      FState.QryName,
      FQuery.QryName,
      FLockedTables.QryName
    ], [
      'WHERE ' + FPID.FieldName + '<> pg_backend_pid() ', pFilter
    ], AAllColumn, AHelper);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TSysDBStatus.SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, pPermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  with LQry do
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FPID.QryName,
      FDBName.QryName,
      'cast(' + FAppName.QryName + ' as varchar(128) ' + FAppName.QryName,
      FUserName.QryName,
      FClientAddress.QryName,
      FState.QryName,
      FQuery.QryName,
      FLockedTables.QryName
    ], [
      'WHERE ' + FPID.FieldName + '<> pg_backend_pid() ', pFilter
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

function TSysDBStatus.Clone():TTable;
begin
  Result := TSysDBStatus.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
