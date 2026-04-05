unit SysMeasure;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes, SysMeasureType;

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
    FMeasureUnitType: TSysMeasureType;
  public
    [Column('measure_unit'), MaxLength(16), Required()]
    property MeasureUnit: string read FMeasureUnit write FMeasureUnit;

    [Column('measure_unit_einv'), MaxLength(3), Required()]
    property MeasureUnitEInv: string read FMeasureUnitEInv write FMeasureUnitEInv;

    [Column('description'), MaxLength(64)]
    property Description: string read FDescription write FDescription;

    [Column('is_decimal'), Required()]
    property IsDecimal: Boolean read FIsDecimal write FIsDecimal;

    [Column('measure_unit_type_id')]
    property MeasureUnitTypeId: Int64 read FMeasureUnitTypeId write FMeasureUnitTypeId;

    [BelongsTo('measure_unit_type_id', 'id')]
    property MeasureUnitType: TSysMeasureType read FMeasureUnitType write FMeasureUnitType;

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
