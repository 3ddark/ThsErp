unit SysViewColumn;

interface

uses
  SysUtils, Classes, Types, BaseEntity, Data.DB;

type
  [TableName('sys_view_columns')]
  TSysViewColumn = class(TEntity)
  private
    FTableName: TEntityField<string>;
    FColumnName: TEntityField<string>;
    FIsNullable: TEntityField<Boolean>;
    FDataType: TEntityField<string>;
    FCharacterMaximumLength: TEntityField<Integer>;
    FOrdinalPosition: TEntityField<Integer>;
    FNumericPrecision: TEntityField<Integer>;
    FNumericScale: TEntityField<Integer>;
    FOrjTableName: TEntityField<string>;
    FOrjColumnName: TEntityField<string>;
  public
    property TableName_: TEntityField<string> read FTableName write FTableName;
    property ColumnName: TEntityField<string> read FColumnName write FColumnName;
    property IsNullable: TEntityField<Boolean> read FIsNullable write FIsNullable;
    property DataType: TEntityField<string> read FDataType write FDataType;
    property CharacterMaximumLength: TEntityField<Integer> read FCharacterMaximumLength write FCharacterMaximumLength;
    property OrdinalPosition: TEntityField<Integer> read FOrdinalPosition write FOrdinalPosition;
    property NumericPrecision: TEntityField<Integer> read FNumericPrecision write FNumericPrecision;
    property NumericScale: TEntityField<Integer> read FNumericScale write FNumericScale;
    property OrjTableName: TEntityField<string> read FOrjTableName write FOrjTableName;
    property OrjColumnName: TEntityField<string> read FOrjColumnName write FOrjColumnName;

    constructor Create(); override;
    destructor Destroy; override;

    function GetFieldType: TFieldType;
  end;

implementation

constructor TSysViewColumn.Create;
begin
  inherited;
  FTableName := TEntityField<string>.Create(Self, 'table_name');
  FColumnName := TEntityField<string>.Create(Self, 'column_name');
  FIsNullable := TEntityField<Boolean>.Create(Self, 'is_nullable');
  FDataType := TEntityField<string>.Create(Self, 'data_type');
  FCharacterMaximumLength := TEntityField<Integer>.Create(Self, 'character_maximum_length');
  FOrdinalPosition := TEntityField<Integer>.Create(Self, 'ordinal_position');
  FNumericPrecision := TEntityField<Integer>.Create(Self, 'numeric_precision');
  FNumericScale := TEntityField<Integer>.Create(Self, 'numeric_scale');
  FOrjTableName := TEntityField<string>.Create(Self, 'orj_table_name');
  FOrjColumnName := TEntityField<string>.Create(Self, 'orj_column_name');
end;

destructor TSysViewColumn.Destroy;
begin
  inherited;
end;

function TSysViewColumn.GetFieldType: TFieldType;
var
  AType: string;
begin
  AType := Self.FDataType.Value;

  if SameText(AType, 'character varying')
  or SameText(AType, 'character')
  or SameText(AType, 'text')
  or SameText(AType, 'citext')
  or SameText(AType, 'name')
  or SameText(AType, 'uuid')
  or SameText(AType, 'xml')
  or SameText(AType, 'json')
  or SameText(AType, 'jsonb')
  then
    Exit(ftString)
  else if SameText(AType, 'smallint') then
    Exit(ftSmallint)
  else if SameText(AType, 'integer') then
    Exit(ftInteger)
  else if SameText(AType, 'bigint') then
    Exit(ftLargeint)
  else
  if SameText(AType, 'real')
  or SameText(AType, 'double precision')
  then
    Exit(ftFloat)
  else
  if SameText(AType, 'numeric')
  or SameText(AType, 'decimal')
  then
    Exit(ftBCD)
  else if SameText(AType, 'date') then
    Exit(ftDate)
  else
  if SameText(AType, 'time')
  or SameText(AType, 'time with time zone')
  then
    Exit(ftTime)
  else
  if SameText(AType, 'timestamp')
  or SameText(AType, 'timestamp with time zone')
  then
    Exit(ftDateTime)
  else
    Exit(ftUnknown);
end;

end.
