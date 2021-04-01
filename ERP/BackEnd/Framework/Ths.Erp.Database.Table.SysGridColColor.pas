unit Ths.Erp.Database.Table.SysGridColColor;

interface

{$I ThsERP.inc}

uses
    System.SysUtils
  , Data.DB
  , FireDAC.Stan.Param
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  ;

type
  TSysGridColColor = class(TTable)
  private
    FTableName: TFieldDB;
    FColumnName: TFieldDB;
    FMinValue: TFieldDB;
    FMinColor: TFieldDB;
    FMaxValue: TFieldDB;
    FMaxColor: TFieldDB;
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
    property MinValue: TFieldDB read FMinValue write FMinValue;
    property MinColor: TFieldDB read FMinColor write FMinColor;
    property MaxValue: TFieldDB read FMaxValue write FMaxValue;
    property MaxColor: TFieldDB read FMaxColor write FMaxColor;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TSysGridColColor.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_grid_col_color';
  TableSourceCode := '1';
  inherited Create(ADatabase);

  FTableName  := TFieldDB.Create('table_name', ftString, '', Self);
  FColumnName := TFieldDB.Create('column_name', ftString, '', Self);
  FMinValue := TFieldDB.Create('min_value', ftFloat, 0, Self);
  FMinColor := TFieldDB.Create('min_color', ftInteger, 0, Self);
  FMaxValue := TFieldDB.Create('max_value', ftFloat, 0, Self);
  FMaxColor := TFieldDB.Create('max_color', ftInteger, 0, Self);
end;

procedure TSysGridColColor.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
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
        TableName + '.' + FMinValue.FieldName,
        TableName + '.' + FMinColor.FieldName,
        TableName + '.' + FMaxValue.FieldName,
        TableName + '.' + FMaxColor.FieldName
      ], [
        'WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
		  Open;
		  Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FTableName, 'Tablo Adý', QueryOfDS);
      setFieldTitle(FColumnName, 'Kolon Adý', QueryOfDS);
      setFieldTitle(FMinValue, 'Minimum Deðer', QueryOfDS);
      setFieldTitle(FMinColor, 'Minimum Rengi', QueryOfDS);
      setFieldTitle(FMaxValue, 'Maksimum Deðer', QueryOfDS);
      setFieldTitle(FMaxColor, 'Maksimum Rengi', QueryOfDS);
	  end;
  end;
end;

procedure TSysGridColColor.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FMinValue.FieldName,
        TableName + '.' + FMinColor.FieldName,
        TableName + '.' + FMaxValue.FieldName,
        TableName + '.' + FMaxColor.FieldName
      ], [
        'WHERE 1=1 ', AFilter
      ]);
		  Open;

		  FreeListContent();
		  List.Clear;
		  while NOT EOF do
		  begin
		    setFieldValue(Self.Id, QueryOfList);
		    setFieldValue(FTableName, QueryOfList);
        setFieldValue(FColumnName, QueryOfList);
        setFieldValue(FMinValue, QueryOfList);
        setFieldValue(FMinColor, QueryOfList);
        setFieldValue(FMaxValue, QueryOfList);
        setFieldValue(FMaxColor, QueryOfList);

		    List.Add(Self.Clone);

		    Next;
		  end;
		  EmptyDataSet;
		  Close;
	  end;
  end;
end;

procedure TSysGridColColor.Insert(out AID: Integer; APermissionControl: Boolean);
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
        FMinValue.FieldName,
        FMinColor.FieldName,
        FMaxValue.FieldName,
        FMaxColor.FieldName
      ]);

      PrepareInsertQueryParams;

      //bu kodlar sýfýr deðer alabilmesi durumu için yazýldý.
      QueryOfInsert.ParamByName(FMinValue.FieldName).Value := FMinValue.Value;
      QueryOfInsert.ParamByName(FMinColor.FieldName).Value := FMinColor.Value;
      QueryOfInsert.ParamByName(FMaxValue.FieldName).Value := FMaxValue.Value;
      QueryOfInsert.ParamByName(FMaxColor.FieldName).Value := FMaxColor.Value;

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

procedure TSysGridColColor.Update(APermissionControl: Boolean);
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
        FMinValue.FieldName,
        FMinColor.FieldName,
        FMaxValue.FieldName,
        FMaxColor.FieldName
      ]);

      PrepareUpdateQueryParams;

      //bu kodlar sýfýr deðer alabilmesi durumu için yazýldý.
      QueryOfUpdate.ParamByName(FMinValue.FieldName).Value := FMinValue.Value;
      QueryOfUpdate.ParamByName(FMinColor.FieldName).Value := FMinColor.Value;
      QueryOfUpdate.ParamByName(FMaxValue.FieldName).Value := FMaxValue.Value;
      QueryOfUpdate.ParamByName(FMaxColor.FieldName).Value := FMaxColor.Value;

		  ExecSQL;
		  Close;
	  end;
    Self.notify;
  end;
end;

function TSysGridColColor.Clone: TTable;
begin
  Result := TSysGridColColor.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
