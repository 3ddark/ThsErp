unit PrdBom;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('prd_bom')]
  TPrdBom = class(TEntity)
  private
    FProductSku: string;
    FProductName: string;
    FSampleQuantity: double;
    FDescription: string;
  public
    [Column('product_sku')]
    [Required]
    [MaxLength(32)]
    property ProductSku: string read FProductSku write FProductSku;

    [Column('product_name')]
    [Required]
    [MaxLength(128)]
    property ProductName: string read FProductName write FProductName;

    [Column('sample_quantity')]
    property SampleQuantity: double read FSampleQuantity write FSampleQuantity;

    [Column('description')]
    property Description: string read FDescription write FDescription;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TPrdBom.Create();
begin
  inherited;
  FSampleQuantity := 1;
end;

destructor TPrdBom.Destroy;
begin
  inherited;
end;

end.
