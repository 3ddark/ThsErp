unit Ths.Database.Table.View.SysDbStatus;

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
    procedure SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
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

  FPID := TFieldDB.Create('pid', ftInteger, 0, Self, 'PID');
  FDBName := TFieldDB.Create('db_name', ftWideString, '', Self, 'DB Name');
  FAppName := TFieldDB.Create('app_name', ftWideString, '', Self, 'App Name');
  FUserName := TFieldDB.Create('user_name', ftWideString, '', Self, 'User Name');
  FClientAddress := TFieldDB.Create('client_address', ftWideString, '', Self, 'Client IP Adres');
  FState := TFieldDB.Create('state', ftWideString, '', Self, 'State');
  FQuery := TFieldDB.Create('query', ftWideString, '', Self, 'Query');
  FLockedTables := TFieldDB.Create('locked_tables', ftWideString, '', Self, 'Locked Tables');
end;

procedure TSysDBStatus.SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if not IsAuthorized(ptRead, pPermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
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
    ], AAllColumn, AHelper);
    Open;
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
    Database.GetSQLSelectCmd(LQry, TableName, [
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
