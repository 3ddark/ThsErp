unit Ths.Erp.Database.Table.View.SysDbStatus;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.View;

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
    constructor Create(OwnerDatabase:TDatabase);override;
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
  Ths.Erp.Globals,
  Ths.Erp.Constants;

constructor TSysDBStatus.Create(OwnerDatabase:TDatabase);
begin
  TableName := 'sys_db_status';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(OwnerDatabase);

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
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
	  with QueryOfDS do
	  begin
		  Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Id.QryName,
        FPID.QryName,
        FDBName.QryName,
        FAppName.QryName+'::varchar(128)',
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
end;

procedure TSysDBStatus.SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
	  with QueryOfList do
	  begin
		  Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        Id.QryName,
        FPID.QryName,
        FDBName.QryName,
        FAppName.QryName+'::varchar(128)',
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
		  List.Clear;
		  while NOT EOF do
		  begin
        PrepareTableClassFromQuery(QueryOfList);

		    List.Add(Clone);

		    Next;
		  end;
		  EmptyDataSet;
		  Close;
	  end;
  end;
end;

function TSysDBStatus.Clone():TTable;
begin
  Result := TSysDBStatus.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
