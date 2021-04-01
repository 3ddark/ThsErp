unit Ths.Erp.Database.Table.SysKaynakGrup;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TSysKaynakGrup = class(TTable)
  private
    FKaynakGrup: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property KaynakGrup: TFieldDB read FKaynakGrup write FKaynakGrup;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSysKaynakGrup.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_kaynak_grup';
  TableSourceCode := '1';
  inherited Create(ADatabase);

  FKaynakGrup := TFieldDB.Create('kaynak_grup', ftString, '', Self, 'Kaynak Grup');
end;

procedure TSysKaynakGrup.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
	  with QueryOfDS do
	  begin
		  Close;
		  Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        addLangField(FKaynakGrup.FieldName, '', True)
      ], [
        addLeftJoin(FKaynakGrup.FieldName, FKaynakGrup.FieldName, TableName, True),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
		  Open;
		  Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FKaynakGrup, 'Kaynak Grup', QueryOfDS);
	  end;
  end;
end;

procedure TSysKaynakGrup.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        addLangField(FKaynakGrup.FieldName, '', True)
      ], [
        addLeftJoin(FKaynakGrup.FieldName, FKaynakGrup.FieldName, TableName, True),
        ' WHERE 1=1 ', AFilter
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

procedure TSysKaynakGrup.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
	  with QueryOfInsert do
	  begin
		  Close;
		  SQL.Clear;
		  SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FKaynakGrup.FieldName
      ]);

      PrepareInsertQueryParams;

		  Open;

      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else  AID := 0;

		  EmptyDataSet;
		  Close;
	  end;

    Self.notify;
  end;
end;

procedure TSysKaynakGrup.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
	  with QueryOfUpdate do
	  begin
		  Close;
		  SQL.Clear;
		  SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FKaynakGrup.FieldName
      ]);

      PrepareUpdateQueryParams;

		  ExecSQL;
		  Close;
	  end;

    Self.notify;
  end;
end;

function TSysKaynakGrup.Clone():TTable;
begin
  Result := TSysKaynakGrup.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
