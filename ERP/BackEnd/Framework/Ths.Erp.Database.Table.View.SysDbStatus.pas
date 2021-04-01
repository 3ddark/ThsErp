unit Ths.Erp.Database.Table.View.SysDbStatus;

interface

{$I ThsERP.inc}

uses
    SysUtils
  , Classes
  , Dialogs
  , Forms
  , Windows
  , Controls
  , Types
  , DateUtils
  , FireDAC.Stan.Param
  , System.Variants
  , Data.DB
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  , Ths.Erp.Database.Table.View
  ;

type
  TSysDBStatus = class(TView)
  private
    FPID: TFieldDB;
    FDBName: TFieldDB;
    FAppName: TFieldDB;
    FUserName: TFieldDB;
    FClientAddress: TFieldDB;
    FQuery: TFieldDB;
    FLockedTables: TFieldDB;
  protected
  published
    constructor Create(OwnerDatabase:TDatabase);override;
  public
    procedure SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True); override;

    function Clone():TTable;override;

    Property PID: TFieldDB read FPID write FPID;
    Property DBName: TFieldDB read FDBName write FDBName;
    Property AppName: TFieldDB read FAppName write FAppName;
    Property UserName: TFieldDB read FUserName write FUserName;
    Property ClientAddress: TFieldDB read FClientAddress write FClientAddress;
    Property Query: TFieldDB read FQuery write FQuery;
    Property LockedTables: TFieldDB read FLockedTables write FLockedTables;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Database.Singleton
  ;

constructor TSysDBStatus.Create(OwnerDatabase:TDatabase);
begin
  TableName := 'sys_db_status';
  TableSourceCode := '1';
  inherited Create(OwnerDatabase);

  FPID := TFieldDB.Create('pid', ftInteger, 0, Self, 'PID');
  FDBName := TFieldDB.Create('db_name', ftString, '', Self, 'DB Name');
  FAppName := TFieldDB.Create('app_name', ftString, '', Self, 'Uygulama Ad�');
  FUserName := TFieldDB.Create('user_name', ftString, '', Self, 'Kullan�c� Ad�');
  FClientAddress := TFieldDB.Create('client_address', ftString, '', Self, 'Client IP Adres');
  FQuery := TFieldDB.Create('query', ftString, '', Self, 'Query');
  FLockedTables := TFieldDB.Create('locked_tables', ftString, '', Self, 'Locked Tables');
end;

procedure TSysDBStatus.SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
	  with QueryOfDS do
	  begin
		  Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FPID.FieldName,
        TableName + '.' + FDBName.FieldName,
        TableName + '.' + FAppName.FieldName+'::varchar(128)',
        TableName + '.' + FUserName.FieldName,
        TableName + '.' + FClientAddress.FieldName,
        TableName + '.' + FQuery.FieldName,
        TableName + '.' + FLockedTables.FieldName
      ], [
        'WHERE ' + FPID.FieldName + '<> pg_backend_pid() ', pFilter
      ], AAllColumn, AHelper);
		  Open;
		  Active := True;

      setFieldTitle(Self.Id, 'ID', QueryOfDS);
      setFieldTitle(FPID, 'Process ID', QueryOfDS);
      setFieldTitle(FDBName, 'DB Name', QueryOfDS);
      setFieldTitle(FAppName, 'App Name', QueryOfDS);
      setFieldTitle(FUserName, 'User Name', QueryOfDS);
      setFieldTitle(FClientAddress, 'Client Address', QueryOfDS);
      setFieldTitle(FQuery, 'Query', QueryOfDS);
      setFieldTitle(FLockedTables, 'Locked Tables', QueryOfDS);
	  end;
  end;
end;

procedure TSysDBStatus.SelectToList(pFilter: string; pLock: Boolean;
  pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
	  if (pLock) then
		  pFilter := pFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

	  with QueryOfList do
	  begin
		  Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FPID.FieldName,
        TableName + '.' + FDBName.FieldName,
        TableName + '.' + FAppName.FieldName,
        TableName + '.' + FUserName.FieldName,
        TableName + '.' + FClientAddress.FieldName,
        TableName + '.' + FQuery.FieldName,
        TableName + '.' + FLockedTables.FieldName
      ], [
        'WHERE ' + FPID.FieldName + '<> pg_backend_pid() ', pFilter
      ]);
		  Open;

		  FreeListContent();
		  List.Clear;
		  while NOT EOF do
		  begin
		    setFieldValue(Self.Id, QueryOfList);
        setFieldValue(FPID, QueryOfList);
        setFieldValue(FDBName, QueryOfList);
        setFieldValue(FAppName, QueryOfList);
        setFieldValue(FUserName, QueryOfList);
        setFieldValue(FClientAddress, QueryOfList);
        setFieldValue(FQuery, QueryOfList);
        setFieldValue(FLockedTables, QueryOfList);

		    List.Add(Self.Clone());

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
