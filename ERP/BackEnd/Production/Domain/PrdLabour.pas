unit PrdLabour;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('prd_labour')]
  TPrdLabour = class(TEntity)
  private
    FCostCode: string;
    FCostName: string;
    FUnitPrice: double;
    FUomCode: string;
    FCostType: Smallint;
  public
    [Column('cost_code')]
    [Required]
    [MaxLength(16)]
    property CostCode: string read FCostCode write FCostCode;

    [Column('cost_name')]
    [MaxLength(128)]
    property CostName: string read FCostName write FCostName;

    [Column('unit_price')]
    [Required]
    property UnitPrice: double read FUnitPrice write FUnitPrice;

    [Column('uom_code')]
    [Required]
    [MaxLength(8)]
    property UomCode: string read FUomCode write FUomCode;

    [Column('cost_type')]
    [Required]
    property CostType: Smallint read FCostType write FCostType;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TPrdLabour.Create();
begin
  inherited;
end;

destructor TPrdLabour.Destroy;
begin
  inherited;
end;

end.
