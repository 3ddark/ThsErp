unit Ths.Erp.Database.Table.SysMultiFirm;

interface

{$I ThsERP.inc}

uses
    System.SysUtils
  , Data.DB
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  ;

type
  TSysMultiFirm = class(TTable)
  private
    FFirmNo: TFieldDB;
    FFirmName: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property FirmNo: TFieldDB read FFirmNo write FFirmNo;
    property FirmName: TFieldDB read FFirmName write FFirmName;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TSysMultiFirm.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_multi_firm';
  TableSourceCode := '1';
  inherited Create(ADatabase);

  FFirmNo := TFieldDB.Create('firm_no', ftInteger, 0, Self);
  FFirmName := TFieldDB.Create('firm_name', ftString, '', Self);
end;

procedure TSysMultiFirm.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
	  with QueryOfDS do
	  begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FFirmNo.FieldName,
        TableName + '.' + FFirmName.FieldName
      ], [
        'WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FFirmNo, 'Firma Numarasý', QueryOfDS);
      setFieldTitle(FFirmName, 'Firma Adý', QueryOfDS);
    end;
  end;
end;

procedure TSysMultiFirm.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
	  if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

	  with QueryOfList do
	  begin
      Close;
      SQL.Clear;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FFirmNo.FieldName,
        TableName + '.' + FFirmName.FieldName
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

procedure TSysMultiFirm.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
	  with QueryOfInsert do
	  begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FFirmNo.FieldName,
        FFirmName.FieldName
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

procedure TSysMultiFirm.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
	  with QueryOfUpdate do
	  begin
		  Close;
		  SQL.Clear;
		  SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
		    FFirmNo.FieldName,
        FFirmName.FieldName
      ]);

      PrepareUpdateQueryParams;

		  ExecSQL;
		  Close;
	  end;
    Self.notify;
  end;
end;

function TSysMultiFirm.Clone: TTable;
begin
  Result := TSysMultiFirm.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
