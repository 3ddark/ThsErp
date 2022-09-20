unit Ths.Erp.Database.Table.View.SysViewTables;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.View;

type
  TSysViewTables = class(TView)
  private
    FTableName: TFieldDB;
    FTableType: TFieldDB;
  published
    constructor Create(OwnerDatabase:TDatabase);override;
  public
    procedure SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property TableName1: TFieldDB read FTableName write FTableName;
    Property TableType: TFieldDB read FTableType write FTableType;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSysViewTables.Create(OwnerDatabase:TDatabase);
begin
  TableName := 'sys_view_tables';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(OwnerDatabase);

  FTableName  := TFieldDB.Create('table_name', ftString, '', Self, 'Tablo Adý');
  FTableType := TFieldDB.Create('table_type', ftString, '', Self, 'Tablo Tipi');
end;

procedure TSysViewTables.SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
	  with QueryOfDS do
	  begin
		  Close;
		  Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Self.Id.QryName,
        FTableName.QryName,
        FTableType.QryName
      ], [
        ' WHERE 1=1 ', pFilter
      ], AAllColumn, AHelper);
		  Open;
	  end;
  end;
end;

procedure TSysViewTables.SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
	  if (pLock) then
		  pFilter := pFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

	  with QueryOfList do
	  begin
		  Close;
		  Database.GetSQLSelectCmd(QueryOfList, TableName, [
        Self.Id.QryName,
        FTableName.QryName,
        FTableType.QryName
      ], [
        ' WHERE 1=1 ', pFilter
      ]);
		  Open;

		  FreeListContent();
		  List.Clear;
		  while NOT EOF do
		  begin
		    PrepareTableClassFromQuery(QueryOfList);

		    List.Add(Self.Clone());

		    Next;
		  end;
		  EmptyDataSet;
		  Close;
	  end;
  end;
end;

function TSysViewTables.Clone(): TTable;
begin
  Result := TSysViewTables.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
