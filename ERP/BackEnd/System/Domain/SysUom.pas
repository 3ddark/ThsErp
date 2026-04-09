unit SysUom;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes, SysUomType;

type
  [Table('sys_uom')]
  TSysUom = class(TEntity)
  private
    FUnit: string;
    FUnitEInv: string;
    FDescription: string;
    FMultiplier: Integer;
    FMeasureTypeId: Int64;
    FMeasureType: TSysUomType;
    FDecimal: Boolean;
  public
    [Column('unit'), MaxLength(16), Required()]
    property _Unit: string read FUnit write FUnit;

    [Column('unit_einv'), MaxLength(3), Required()]
    property UnitEInv: string read FUnitEInv write FUnitEInv;

    [Column('description'), MaxLength(64)]
    property Description: string read FDescription write FDescription;

    [Column('decimal'), Required()]
    property Decimal: Boolean read FDecimal write FDecimal;

    [Column('measure_type_id')]
    property MeasureTypeId: Int64 read FMeasureTypeId write FMeasureTypeId;

    [BelongsTo('measure_type_id', 'id')]
    property MeasureType: TSysUomType read FMeasureType write FMeasureType;

    [Column('multiplier')]
    property Multiplier: Integer read FMultiplier write FMultiplier;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

{ TSysUom }

constructor TSysUom.Create;
begin
  inherited;
  FMeasureType := TSysUomType.Create;
end;

destructor TSysUom.Destroy;
begin
  if Assigned(FMeasureType) then
    FreeAndNil(FMeasureType);
  inherited;
end;

end.
