unit PrdBomByProduct;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('prd_bom_by_product')]
  TPrdBomByProduct = class(TEntity)
  private
    FHeaderId: Int64;
    FProductSku: string;
    FQuantity: double;
    FPrice: double;
  public
    [Column('header_id')]
    [Required]
    property HeaderId: Int64 read FHeaderId write FHeaderId;

    [Column('product_sku')]
    [Required]
    [MaxLength(32)]
    property ProductSku: string read FProductSku write FProductSku;

    [Column('quantity')]
    [Required]
    property Quantity: double read FQuantity write FQuantity;

    [Column('price')]
    property Price: double read FPrice write FPrice;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TPrdBomByProduct.Create();
begin
  inherited;
end;

destructor TPrdBomByProduct.Destroy;
begin
  inherited;
end;

end.
