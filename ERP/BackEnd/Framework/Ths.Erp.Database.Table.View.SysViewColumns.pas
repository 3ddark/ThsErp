unit Ths.Erp.Database.Table.View.SysViewColumns;

interface

{$I ThsERP.inc}

uses
  SysUtils,
  Classes,
  Dialogs,
  Forms,
  Windows,
  Controls,
  Types,
  DateUtils,
  System.Variants,
  Data.DB,
  FireDAC.Stan.Param,
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
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;

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

  FTableName  := TFieldDB.Create('table_name', ftWideString, '', Self, 'Tablo Adý');
  FColumnName := TFieldDB.Create('column_name', ftWideString, '', Self, 'Kolon Adý');
  FIsNullable := TFieldDB.Create('is_nullable', ftBoolean, False, Self, 'Null Olabilir');
  FDataType := TFieldDB.Create('data_type', ftWideString, '', Self, 'Veri Tipi');
  FCharacterMaximumLength := TFieldDB.Create('character_maximum_length', ftInteger, 0, Self, 'Maks Uzunluk');
  FOrdinalPosition := TFieldDB.Create('ordinal_position', ftInteger, 0, Self, 'Kolon Sýrasý');
  FNumericPrecision := TFieldDB.Create('numeric_precision', ftInteger, 0, Self, 'Numeric Hassaslýk');
  FNumericScale := TFieldDB.Create('numeric_scale', ftInteger, 0, Self, 'Numeric Ölçek');
  FOrjTableName  := TFieldDB.Create('orj_table_name', ftWideString, '', Self, 'Orj Tablo Adý');
  FOrjColumnName := TFieldDB.Create('orj_column_name', ftWideString, '', Self, 'Orj Kolon Adý');
end;

procedure TSysViewColumns.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
	  with QueryOfDS do
	  begin
		  Close;
		  SQL.Clear;
		  Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Id.QryName,
        FTableName.QryName,
        FColumnName.QryName,
        FIsNullable.QryName,
        FDataType.QryName,
        FCharacterMaximumLength.QryName,
        FOrdinalPosition.QryName,
        FNumericPrecision.QryName,
        FNumericScale.QryName,
        FOrjTableName.QryName,
        FOrjColumnName.QryName
      ],[
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
		  Open;
	  end;
  end;
end;

procedure TSysViewColumns.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
        Id.QryName,
        FTableName.QryName,
        FColumnName.QryName,
        FIsNullable.QryName,
        FDataType.QryName,
        FCharacterMaximumLength.QryName,
        FOrdinalPosition.QryName,
        FNumericPrecision.QryName,
        FNumericScale.QryName,
        FOrjTableName.QryName,
        FOrjColumnName.QryName
      ], [
        ' WHERE 1=1 ', AFilter
      ]);
		  Open;

		  FreeListContent();
		  List.Clear;
		  while NOT EOF do
		  begin
        PrepareTableClassFromQuery(QueryOfList);

		    List.Add(Clone());

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
