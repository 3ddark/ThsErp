unit SysUomType;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_uom_types')]
  TSysUomType = class(TEntity)
  private
    FMeasureType: string;
  public
    [Column('measure_type'), MaxLength(16), Required()]
    property MeasureType: string read FMeasureType write FMeasureType;
  end;

implementation

end.
