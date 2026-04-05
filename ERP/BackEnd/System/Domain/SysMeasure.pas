unit SysMeasure;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_measures')]
  TSysMeasure = class(TEntity)
  private
    FMeasureUnit: string;
    FMeasureUnitEInv: string;
    FDescription: string;
    FMultiplier: Integer;
    FIsDecimal: Boolean;
    FMeasureUnitTypeId: Int64;
  public
    [Column('measure_unit')]
    property MeasureUnit: string read FMeasureUnit write FMeasureUnit;

    [Column('measure_unit_einv')]
    property MeasureUnitEInv: string read FMeasureUnitEInv write FMeasureUnitEInv;

    [Column('description')]
    property Description: string read FDescription write FDescription;

    [Column('is_decimal')]
    property IsDecimal: Boolean read FIsDecimal write FIsDecimal;

    [Column('measure_unit_type_id')]
    property MeasureUnitTypeId: Int64 read FMeasureUnitTypeId write FMeasureUnitTypeId;

    [Column('multiplier')]
    property Multiplier: Integer read FMultiplier write FMultiplier;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysMeasure.Create();
begin
  inherited;
end;

destructor TSysMeasure.Destroy;
begin
  inherited;
end;

end.
