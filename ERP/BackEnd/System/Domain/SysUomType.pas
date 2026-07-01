unit SysUomType;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_uom_type')]
  TSysUomType = class(TEntity)
  private
    FMeasureType: string;
  public
    [Column('measure_type'), MaxLength(16), Required()]
    property MeasureType: string read FMeasureType write FMeasureType;

    constructor Create(); override;
  end;

implementation

constructor TSysUomType.Create();
begin
  inherited;
end;

end.
