unit SetAccTaxRate;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('acc_set_tax_rate')]
  TSetAccTaxRate = class(TEntity)
  private
    FTaxRate: Double;
    FSalesAccountCode: string;
    FSalesReturnAccountCode: string;
    FPurchaseAccountCode: string;
    FPurchaseReturnAccountCode: string;
  public
    [Column('tax_rate'), Required()]
    property TaxRate: Double read FTaxRate write FTaxRate;

    [Column('sales_account'), MaxLength(16), Required()]
    property SalesAccountCode: string read FSalesAccountCode write FSalesAccountCode;

    [Column('sales_return_account'), MaxLength(16), Required()]
    property SalesReturnAccountCode: string read FSalesReturnAccountCode write FSalesReturnAccountCode;

    [Column('purchase_account'), MaxLength(16), Required()]
    property PurchaseAccountCode: string read FPurchaseAccountCode write FPurchaseAccountCode;

    [Column('purchase_return_account'), MaxLength(16), Required()]
    property PurchaseReturnAccountCode: string read FPurchaseReturnAccountCode write FPurchaseReturnAccountCode;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetAccTaxRate.Create();
begin
  inherited;
end;

destructor TSetAccTaxRate.Destroy;
begin
  inherited;
end;

end.
