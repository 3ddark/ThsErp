unit PrdBomLabour;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('prd_bom_labour')]
  TPrdBomLabour = class(TEntity)
  private
    FHeaderId: Int64;
    FLaborCode: string;
    FQuantity: double;
  public
    [Column('header_id')]
    [Required]
    property HeaderId: Int64 read FHeaderId write FHeaderId;

    [Column('labor_code')]
    [Required]
    [MaxLength(16)]
    property LaborCode: string read FLaborCode write FLaborCode;

    [Column('quantity')]
    [Required]
    property Quantity: double read FQuantity write FQuantity;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TPrdBomLabour.Create();
begin
  inherited;
end;

destructor TPrdBomLabour.Destroy;
begin
  inherited;
end;

end.
