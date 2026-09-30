unit AccSetTaxRate;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('acc_set_tax_rate')]
  TAccSetTaxRate = class(TEntity)
  private
    FTaxRate: Currency;
    FSalesAccount: string;
    FSalesReturnAccount: string;
    FPurchaseAccount: string;
    FPurchaseReturnAccount: string;
  public
    [Column('tax_rate')]
    property TaxRate: Currency read FTaxRate write FTaxRate;

    [Column('sales_account')]
    [MaxLength(16), Required(TLangKeys.TValidation.Required, True)]
    property SalesAccount: string read FSalesAccount write FSalesAccount;

    [Column('sales_return_account')]
    [MaxLength(16), Required(TLangKeys.TValidation.Required, True)]
    property SalesReturnAccount: string read FSalesReturnAccount write FSalesReturnAccount;

    [Column('purchase_account')]
    [MaxLength(16), Required(TLangKeys.TValidation.Required, True)]
    property PurchaseAccount: string read FPurchaseAccount write FPurchaseAccount;

    [Column('purchase_return_account')]
    [MaxLength(16), Required(TLangKeys.TValidation.Required, True)]
    property PurchaseReturnAccount: string read FPurchaseReturnAccount write FPurchaseReturnAccount;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccSetTaxRate;
  end;

implementation

constructor TAccSetTaxRate.Create;
begin
  inherited;
end;

destructor TAccSetTaxRate.Destroy;
begin
  inherited;
end;

function TAccSetTaxRate.Clone: TAccSetTaxRate;
begin
  Result := TAccSetTaxRate.Create;
  Result.Id := Self.Id;
  Result.TaxRate := Self.TaxRate;
  Result.SalesAccount := Self.SalesAccount;
  Result.SalesReturnAccount := Self.SalesReturnAccount;
  Result.PurchaseAccount := Self.PurchaseAccount;
  Result.PurchaseReturnAccount := Self.PurchaseReturnAccount;
end;

end.
