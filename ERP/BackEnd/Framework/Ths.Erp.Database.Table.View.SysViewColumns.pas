unit Ths.Erp.Database.Table.View.SysViewColumns;

interface

{$I ThsERP.inc}

uses
  SysUtils, Classes, Dialogs, Forms, Windows, Controls, Types, DateUtils,
  FireDAC.Stan.Param, System.Variants, Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.View;

type
  TSysViewColumns = class(TView)
  private
    FTableName: TFieldDB;
    FColumnName: TFieldDB;
    FIsNullable: TFieldDB;
    FDataType: TFieldDB;
    FCharacterMaximumLength: TFieldDB;
    FOrdinalPosition: TFieldDB;
    FNumericPrecision: TFieldDB;
    FNumericScale: TFieldDB;
    FOrjTableName: TFieldDB;
    FOrjColumnName: TFieldDB;
  protected
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True); override;

    procedure Clear; override;
    function Clone: TTable; override;

    Property TableName1: TFieldDB read FTableName write FTableName;
    Property ColumnName: TFieldDB read FColumnName write FColumnName;
    property IsNullable: TFieldDB read FIsNullable write FIsNullable;
    property DataType: TFieldDB read FDataType write FDataType;
    property CharacterMaximumLength: TFieldDB read FCharacterMaximumLength write FCharacterMaximumLength;
    property OrdinalPosition: TFieldDB read FOrdinalPosition write FOrdinalPosition;
    property NumericPrecision: TFieldDB read FNumericPrecision write FNumericPrecision;
    property NumericScale: TFieldDB read FNumericScale write FNumericScale;
    property OrjTableName: TFieldDB read FOrjTableName write FOrjTableName;
    property OrjColumnName: TFieldDB read FOrjColumnName write FOrjColumnName;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSysViewColumns.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_view_columns';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FTableName  := TFieldDB.Create('table_name', ftString, '', Self, 'Tablo Adý');
  FColumnName := TFieldDB.Create('column_name', ftString, '', Self, 'Kolon Adý');
  FIsNullable := TFieldDB.Create('is_nullable', ftBoolean, False, Self, 'Null Olabilir');
  FDataType := TFieldDB.Create('data_type', ftString, '', Self, 'Veri Tipi');
  FCharacterMaximumLength := TFieldDB.Create('character_maximum_length', ftInteger, 0, Self, 'Maks Uzunluk');
  FOrdinalPosition := TFieldDB.Create('ordinal_position', ftInteger, 0, Self, 'Kolon Sýrasý');
  FNumericPrecision := TFieldDB.Create('numeric_precision', ftInteger, 0, Self, 'Numeric Hassaslýk');
  FNumericScale := TFieldDB.Create('numeric_scale', ftInteger, 0, Self, 'Numeric Ölçek');
  FOrjTableName  := TFieldDB.Create('orj_table_name', ftString, '', Self, 'Orj Tablo Adý');
  FOrjColumnName := TFieldDB.Create('orj_column_name', ftString, '', Self, 'Orj Kolon Adý');
end;

procedure TSysViewColumns.SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
	  with QueryOfDS do
	  begin
		  Close;
		  SQL.Clear;
		  Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FTableName.FieldName,
        TableName + '.' + FColumnName.FieldName,
        TableName + '.' + FIsNullable.FieldName,
        TableName + '.' + FDataType.FieldName,
        TableName + '.' + FCharacterMaximumLength.FieldName,
        TableName + '.' + FOrdinalPosition.FieldName,
        TableName + '.' + FNumericPrecision.FieldName,
        TableName + '.' + FNumericScale.FieldName,
        TableName + '.' + FOrjTableName.FieldName,
        TableName + '.' + FOrjColumnName.FieldName
      ],[
        ' WHERE 1=1 ', pFilter
      ], AAllColumn, AHelper);
		  Open;
		  Active := True;

      setFieldTitle(Self.Id, 'ID', QueryOfDS);
      setFieldTitle(FTableName, 'Table Name', QueryOfDS);
      setFieldTitle(FColumnName, 'Column Name', QueryOfDS);
      setFieldTitle(FIsNullable, 'Nullable?', QueryOfDS);
      setFieldTitle(FDataType, 'Data Type', QueryOfDS);
      setFieldTitle(FCharacterMaximumLength, 'Character Max Length', QueryOfDS);
      setFieldTitle(FOrdinalPosition, 'Ordinal Position', QueryOfDS);
      setFieldTitle(FNumericPrecision, 'Numeric Precision', QueryOfDS);
      setFieldTitle(FNumericScale, 'Numeric Scale', QueryOfDS);
      setFieldTitle(FOrjTableName, 'Orj Table Name', QueryOfDS);
      setFieldTitle(FOrjColumnName, 'Orj Column Name', QueryOfDS);
	  end;
  end;
end;

procedure TSysViewColumns.SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
	  if (pLock) then
		  pFilter := pFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

	  with QueryOfList do
	  begin
		  Close;
		  SQL.Clear;
		  Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FTableName.FieldName,
        TableName + '.' + FColumnName.FieldName,
        TableName + '.' + FIsNullable.FieldName,
        TableName + '.' + FDataType.FieldName,
        TableName + '.' + FCharacterMaximumLength.FieldName,
        TableName + '.' + FOrdinalPosition.FieldName,
        TableName + '.' + FNumericPrecision.FieldName,
        TableName + '.' + FNumericScale.FieldName,
        TableName + '.' + FOrjTableName.FieldName,
        TableName + '.' + FOrjColumnName.FieldName
      ], [
        ' WHERE 1=1 ', pFilter
      ]);
		  Open;

		  FreeListContent();
		  List.Clear;
		  while NOT EOF do
		  begin
//        PrepareTableClassFromQuery(QueryOfList);
		    setFieldValue(Self.Id, QueryOfList);
        setFieldValue(FTableName, QueryOfList);
        setFieldValue(FColumnName, QueryOfList);
        setFieldValue(FIsNullable, QueryOfList);
        setFieldValue(FDataType, QueryOfList);
        setFieldValue(FCharacterMaximumLength, QueryOfList);
        setFieldValue(FOrdinalPosition, QueryOfList);
        setFieldValue(FNumericPrecision, QueryOfList);
        setFieldValue(FNumericScale, QueryOfList);
		    setFieldValue(FOrjTableName, QueryOfList);
        setFieldValue(FOrjColumnName, QueryOfList);

		    List.Add(Self.Clone());

		    Next;
		  end;
		  EmptyDataSet;
		  Close;
	  end;
  end;
end;

procedure TSysViewColumns.Clear();
begin
  inherited;
  FIsNullable.Value := False;
end;

function TSysViewColumns.Clone: TTable;
begin
  Result := TSysViewColumns.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
