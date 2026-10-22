unit PurQuotationComparison;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  // Teklif karşılaştırma satırı (salt okunur, yalnız vw_pur_quotation_comparison): talep kalemi başına tedarikçi
  // teklifleri, ana para biriminde net birim fiyat ve fiyat sırası (1 = en uygun)
  [Table('pur_quotation_comparison')]
  TPurQuotationComparison = class(TEntity)
  private
    FPurRequestId: Int64;
    FRequestNo: string;
    FPurRequestDetailId: Int64;
    FRequestLineNo: SmallInt;
    FStkInventoryId: Int64;
    FInventoryCode: string;
    FInventoryName: string;
    FUomCode: string;
    FRequestQuantity: Currency;
    FPurQuotationId: Int64;
    FQuotationNo: string;
    FQuotationDate: TDate;
    FStatus: SmallInt;
    FAccAccountId: Int64;
    FAccountCode: string;
    FAccountName: string;
    FCurrency: string;
    FExchangeRate: Currency;
    FQuantity: Currency;
    FUnitPrice: Currency;
    FDiscountRate: Currency;
    FVatRate: Currency;
    FNetUnitPrice: Currency;
    FNetUnitPriceBase: Currency;
    FNetAmountBase: Currency;
    FDeliveryDays: SmallInt;
    FDeliveryDate: TDate;
    FPaymentTermDays: SmallInt;
    FPaymentTerms: string;
    FValidUntil: TDate;
    FPriceRank: Integer;
  public
    [Column('pur_request_id')]
    property PurRequestId: Int64 read FPurRequestId write FPurRequestId;

    [Column('request_no')]
    [MaxLength(16)]
    property RequestNo: string read FRequestNo write FRequestNo;

    [Column('pur_request_detail_id')]
    property PurRequestDetailId: Int64 read FPurRequestDetailId write FPurRequestDetailId;

    [Column('request_line_no')]
    property RequestLineNo: SmallInt read FRequestLineNo write FRequestLineNo;

    [Column('stk_inventory_id')]
    property StkInventoryId: Int64 read FStkInventoryId write FStkInventoryId;

    [Column('inventory_code')]
    [MaxLength(32)]
    property InventoryCode: string read FInventoryCode write FInventoryCode;

    [Column('inventory_name')]
    [MaxLength(128)]
    property InventoryName: string read FInventoryName write FInventoryName;

    [Column('uom_code')]
    [MaxLength(16)]
    property UomCode: string read FUomCode write FUomCode;

    [Column('request_quantity')]
    property RequestQuantity: Currency read FRequestQuantity write FRequestQuantity;

    [Column('pur_quotation_id')]
    property PurQuotationId: Int64 read FPurQuotationId write FPurQuotationId;

    [Column('quotation_no')]
    [MaxLength(16)]
    property QuotationNo: string read FQuotationNo write FQuotationNo;

    [Column('quotation_date')]
    property QuotationDate: TDate read FQuotationDate write FQuotationDate;

    [Column('status')]
    property Status: SmallInt read FStatus write FStatus;

    [Column('acc_account_id')]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('account_code')]
    [MaxLength(32)]
    property AccountCode: string read FAccountCode write FAccountCode;

    [Column('account_name')]
    [MaxLength(128)]
    property AccountName: string read FAccountName write FAccountName;

    [Column('currency')]
    [MaxLength(3)]
    property Currency: string read FCurrency write FCurrency;

    [Column('exchange_rate')]
    property ExchangeRate: Currency read FExchangeRate write FExchangeRate;

    [Column('quantity')]
    property Quantity: Currency read FQuantity write FQuantity;

    [Column('unit_price')]
    property UnitPrice: Currency read FUnitPrice write FUnitPrice;

    [Column('discount_rate')]
    property DiscountRate: Currency read FDiscountRate write FDiscountRate;

    [Column('vat_rate')]
    property VatRate: Currency read FVatRate write FVatRate;

    [Column('net_unit_price')]
    property NetUnitPrice: Currency read FNetUnitPrice write FNetUnitPrice;

    [Column('net_unit_price_base')]
    property NetUnitPriceBase: Currency read FNetUnitPriceBase write FNetUnitPriceBase;

    [Column('net_amount_base')]
    property NetAmountBase: Currency read FNetAmountBase write FNetAmountBase;

    [Column('delivery_days')]
    property DeliveryDays: SmallInt read FDeliveryDays write FDeliveryDays;

    [Column('delivery_date')]
    property DeliveryDate: TDate read FDeliveryDate write FDeliveryDate;

    [Column('payment_term_days')]
    property PaymentTermDays: SmallInt read FPaymentTermDays write FPaymentTermDays;

    [Column('payment_terms')]
    [MaxLength(256)]
    property PaymentTerms: string read FPaymentTerms write FPaymentTerms;

    [Column('valid_until')]
    property ValidUntil: TDate read FValidUntil write FValidUntil;

    [Column('price_rank')]
    property PriceRank: Integer read FPriceRank write FPriceRank;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPurQuotationComparison;
  end;

implementation

constructor TPurQuotationComparison.Create;
begin
  inherited;
end;

destructor TPurQuotationComparison.Destroy;
begin
  inherited;
end;

function TPurQuotationComparison.Clone: TPurQuotationComparison;
begin
  Result := TPurQuotationComparison.Create;
  Result.Id := Self.Id;
  Result.PurRequestId := Self.PurRequestId;
  Result.RequestNo := Self.RequestNo;
  Result.PurRequestDetailId := Self.PurRequestDetailId;
  Result.RequestLineNo := Self.RequestLineNo;
  Result.StkInventoryId := Self.StkInventoryId;
  Result.InventoryCode := Self.InventoryCode;
  Result.InventoryName := Self.InventoryName;
  Result.UomCode := Self.UomCode;
  Result.RequestQuantity := Self.RequestQuantity;
  Result.PurQuotationId := Self.PurQuotationId;
  Result.QuotationNo := Self.QuotationNo;
  Result.QuotationDate := Self.QuotationDate;
  Result.Status := Self.Status;
  Result.AccAccountId := Self.AccAccountId;
  Result.AccountCode := Self.AccountCode;
  Result.AccountName := Self.AccountName;
  Result.Currency := Self.Currency;
  Result.ExchangeRate := Self.ExchangeRate;
  Result.Quantity := Self.Quantity;
  Result.UnitPrice := Self.UnitPrice;
  Result.DiscountRate := Self.DiscountRate;
  Result.VatRate := Self.VatRate;
  Result.NetUnitPrice := Self.NetUnitPrice;
  Result.NetUnitPriceBase := Self.NetUnitPriceBase;
  Result.NetAmountBase := Self.NetAmountBase;
  Result.DeliveryDays := Self.DeliveryDays;
  Result.DeliveryDate := Self.DeliveryDate;
  Result.PaymentTermDays := Self.PaymentTermDays;
  Result.PaymentTerms := Self.PaymentTerms;
  Result.ValidUntil := Self.ValidUntil;
  Result.PriceRank := Self.PriceRank;
end;

end.
