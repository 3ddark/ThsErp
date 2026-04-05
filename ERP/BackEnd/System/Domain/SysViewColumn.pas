unit SysViewColumn;

interface

uses
  SysUtils, Classes, Types, Data.DB, Entity, EntityAttributes;

type
  [Table('sys_view_columns')]
  TSysViewColumn = class(TEntity)
  private
    FTableName: string;
    FColumnName: string;
    FIsNullable: Boolean;
    FDataType: string;
    FCharacterMaximumLength: Integer;
    FOrdinalPosition: Integer;
    FNumericPrecision: Integer;
    FNumericScale: Integer;
    FOrjTableName: string;
    FOrjColumnName: string;
  public
    [Column('table_name')]
    property TableName_: string read FTableName write FTableName;

    [Column('column_name')]
    property ColumnName: string read FColumnName write FColumnName;

    [Column('is_nullable')]
    property IsNullable: Boolean read FIsNullable write FIsNullable;

    [Column('data_type')]
    property DataType: string read FDataType write FDataType;

    [Column('character_maximum_length')]
    property CharacterMaximumLength: Integer read FCharacterMaximumLength write FCharacterMaximumLength;

    [Column('ordinal_position')]
    property OrdinalPosition: Integer read FOrdinalPosition write FOrdinalPosition;

    [Column('numeric_precision')]
    property NumericPrecision: Integer read FNumericPrecision write FNumericPrecision;

    [Column('numeric_scale')]
    property NumericScale: Integer read FNumericScale write FNumericScale;

    [Column('orj_table_name')]
    property OrjTableName: string read FOrjTableName write FOrjTableName;

    [Column('orj_column_name')]
    property OrjColumnName: string read FOrjColumnName write FOrjColumnName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysViewColumn.Create;
begin
  inherited;
end;

destructor TSysViewColumn.Destroy;
begin
  inherited;
end;

end.
