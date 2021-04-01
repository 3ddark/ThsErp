unit Ths.Erp.Database.Table.SysGridColSummary;

interface

{$I ThsERP.inc}

uses
    System.SysUtils
  , Data.DB
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  ;

type
  TSysGridColSummary = class(TTable)
  private
    FTableName: TFieldDB;
    FColumnName: TFieldDB;
    FSumaryType: TFieldDB;
    FFormat: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property TableName1: TFieldDB read FTableName write FTableName;
    Property ColumnName: TFieldDB read FColumnName write FColumnName;
    property SumaryType: TFieldDB read FSumaryType write FSumaryType;
    property Format: TFieldDB read FFormat write FFormat;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TSysGridColSummary.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_grid_col_summary';
  TableSourceCode := '1';
  inherited Create(ADatabase);

  FTableName := TFieldDB.Create('table_name', ftString, '', Self);
  FColumnName := TFieldDB.Create('column_name', ftString, '', Self);
  FSumaryType := TFieldDB.Create('summary_type', ftString, '', Self);
  FFormat := TFieldDB.Create('format', ftString, '', Self);
end;

procedure TSysGridColSummary.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
	  with QueryOfDS do
	  begin
		  Close;
		  Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FTableName.FieldName,
        TableName + '.' + FColumnName.FieldName,
        TableName + '.' + FSumaryType.FieldName,
        TableName + '.' + FFormat.FieldName
      ], [
        'WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
		  Open;
		  Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FTableName, 'Tablo Adý', QueryOfDS);
      setFieldTitle(FColumnName, 'Kolon Adý', QueryOfDS);
      setFieldTitle(FSumaryType, 'Özet Tipi', QueryOfDS);
      setFieldTitle(FFormat, 'Format', QueryOfDS);
	  end;
  end;
end;

procedure TSysGridColSummary.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
	  if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

	  with QueryOfList do
	  begin
		  Close;
		  Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FTableName.FieldName,
        TableName + '.' + FColumnName.FieldName,
        TableName + '.' + FSumaryType.FieldName,
        TableName + '.' + FFormat.FieldName
      ], [
        'WHERE 1=1 ', AFilter
      ]);
		  Open;

		  FreeListContent();
		  List.Clear;
		  while NOT EOF do
		  begin
		    PrepareTableClassFromQuery(QueryOfList);

		    List.Add(Self.Clone);

		    Next;
		  end;
		  EmptyDataSet;
		  Close;
	  end;
  end;
end;

procedure TSysGridColSummary.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
	  with QueryOfInsert do
	  begin
		  Close;
		  SQL.Clear;
		  SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FTableName.FieldName,
        FColumnName.FieldName,
        FSumaryType.FieldName,
        FFormat.FieldName
      ]);

      PrepareInsertQueryParams;

		  Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull) then
        AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else
        AID := 0;

		  EmptyDataSet;
		  Close;
	  end;
    Self.notify;
  end;
end;

procedure TSysGridColSummary.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
	  with QueryOfUpdate do
	  begin
		  Close;
		  SQL.Clear;
		  SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FTableName.FieldName,
        FColumnName.FieldName,
        FSumaryType.FieldName,
        FFormat.FieldName
      ]);

      PrepareUpdateQueryParams;

		  ExecSQL;
		  Close;
	  end;
    Self.notify;
  end;
end;

function TSysGridColSummary.Clone():TTable;
begin
  Result := TSysGridColSummary.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
