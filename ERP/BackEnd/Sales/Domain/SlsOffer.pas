unit SlsOffer;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, SlsOfferDetail,
  SysAddress;

type
  [Table('sls_offer')]
  TSlsOffer = class(TEntity)
  private
    // Kalemler (sahiplenir): servis yükler / yazar; durum TDetailEntity (Id işareti + Deleted)
    FLines: TObjectList<TSlsOfferDetail>;

    FOfferNo: string;
    FOfferDate: TDate;
    FValidUntil: TDate;
    FAccAccountId: Int64;
    FCustomerRefNo: string;
    FEmpEmployeeId: Int64;
    FCurrency: string;
    FExchangeRate: Currency;
    FPaymentTermDays: SmallInt;
    FStatus: SmallInt;
    FGrossAmount: Currency;
    FDiscountAmount: Currency;
    FNetAmount: Currency;
    FVatAmount: Currency;
    FTotalAmount: Currency;
    FDescription: string;
    FBillingAddressId: Int64;
    FBillingSysAddressId: Int64;
    FShippingAddressId: Int64;
    FShippingSysAddressId: Int64;
    FBaseCurrency: string;
    FUsdRate: Currency;
    FEurRate: Currency;
    FDeliveryDate: TDate;
    FEinvPaymentMeansId: Int64;
    FEinvDeliveryTermId: Int64;
    FSaleType: SmallInt;
    // belgeye ait ayrıntılı adresler (sahiplenir; boş = adres yok)
    FBillingAddress: TSysAddress;
    FShippingAddress: TSysAddress;

    // View (vw_sls_offer) okunabilir alanları
    FAccountCode: string;
    FAccountName: string;
    FEmployeeName: string;
    FBillingAddressText: string;
    FShippingAddressText: string;
    FTotalAmountBase: Currency;
    FPaymentMeansName: string;
    FDeliveryTermName: string;
    FTaxOffice: string;
    FTaxNo: string;
    FAccountTitle: string;
    FTaxpayerType: SmallInt;
    FDeliveryTermIsIncoterms: Boolean;
  public
    [Column('offer_no')]
    [MaxLength(16)]
    property OfferNo: string read FOfferNo write FOfferNo;

    [Column('offer_date')]
    [Required()]
    property OfferDate: TDate read FOfferDate write FOfferDate;

    [Column('valid_until')]
    property ValidUntil: TDate read FValidUntil write FValidUntil;

    [Column('acc_account_id')]
    [Required()]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('customer_ref_no')]
    [MaxLength(32)]
    property CustomerRefNo: string read FCustomerRefNo write FCustomerRefNo;

    [Column('emp_employee_id')]
    property EmpEmployeeId: Int64 read FEmpEmployeeId write FEmpEmployeeId;

    [Column('currency')]
    [MaxLength(3)]
    property Currency: string read FCurrency write FCurrency;

    [Column('exchange_rate')]
    property ExchangeRate: Currency read FExchangeRate write FExchangeRate;

    [Column('payment_term_days')]
    property PaymentTermDays: SmallInt read FPaymentTermDays write FPaymentTermDays;

    [Column('status')]
    property Status: SmallInt read FStatus write FStatus;

    [Column('gross_amount')]
    property GrossAmount: Currency read FGrossAmount write FGrossAmount;

    [Column('discount_amount')]
    property DiscountAmount: Currency read FDiscountAmount write FDiscountAmount;

    [Column('net_amount')]
    property NetAmount: Currency read FNetAmount write FNetAmount;

    [Column('vat_amount')]
    property VatAmount: Currency read FVatAmount write FVatAmount;

    [Column('total_amount')]
    property TotalAmount: Currency read FTotalAmount write FTotalAmount;

    [Column('description')]
    [MaxLength(256)]
    property Description: string read FDescription write FDescription;

    // Belge adresi: kaynak cari adresi (acc_account_address) + belgeye ait ayrıntılı kopya (sys_address; cari adresi
    // sonradan değişse de belge değişmez, belgede düzenlenebilir). Teslimat boşsa fatura adresi geçerlidir.
    [Column('billing_address_id')]
    property BillingAddressId: Int64 read FBillingAddressId write FBillingAddressId;

    [Column('billing_sys_address_id')]
    property BillingSysAddressId: Int64 read FBillingSysAddressId write FBillingSysAddressId;

    [Column('shipping_address_id')]
    property ShippingAddressId: Int64 read FShippingAddressId write FShippingAddressId;

    [Column('shipping_sys_address_id')]
    property ShippingSysAddressId: Int64 read FShippingSysAddressId write FShippingSysAddressId;

    // Ana para (muhasebe para birimi, kayıtta servis yazar); ExchangeRate: 1 belge parası = ? ana para
    [Column('base_currency')]
    [MaxLength(3)]
    property BaseCurrency: string read FBaseCurrency write FBaseCurrency;

    // Rapor kurları (teklif tarihi): 1 USD / 1 EUR = ? ana para
    [Column('usd_rate')]
    property UsdRate: Currency read FUsdRate write FUsdRate;

    [Column('eur_rate')]
    property EurRate: Currency read FEurRate write FEurRate;

    // Teslim (termin) tarihi: siparişe aktarılır
    [Column('delivery_date')]
    property DeliveryDate: TDate read FDeliveryDate write FDeliveryDate;

    // Ödeme şekli (einv_payment_means) / gönderim şekli (einv_delivery_term: adrese / kargoya teslim, Incoterms)
    [Column('einv_payment_means_id')]
    property EinvPaymentMeansId: Int64 read FEinvPaymentMeansId write FEinvPaymentMeansId;

    [Column('einv_delivery_term_id')]
    property EinvDeliveryTermId: Int64 read FEinvDeliveryTermId write FEinvDeliveryTermId;

    // Satış tipi (SlsLookup SLS_SALE_*): satış / ihracat / ihraç kayıtlı / istisna / tevkifatlı
    [Column('sale_type')]
    property SaleType: SmallInt read FSaleType write FSaleType;

    [NotMapped]
    property AccountCode: string read FAccountCode write FAccountCode;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    [NotMapped]
    property EmployeeName: string read FEmployeeName write FEmployeeName;

    [NotMapped]
    property BillingAddressText: string read FBillingAddressText write FBillingAddressText;

    [NotMapped]
    property ShippingAddressText: string read FShippingAddressText write FShippingAddressText;

    [NotMapped]
    property TotalAmountBase: Currency read FTotalAmountBase write FTotalAmountBase;

    [NotMapped]
    property PaymentMeansName: string read FPaymentMeansName write FPaymentMeansName;

    [NotMapped]
    property DeliveryTermName: string read FDeliveryTermName write FDeliveryTermName;

    [NotMapped]
    property DeliveryTermIsIncoterms: Boolean read FDeliveryTermIsIncoterms write FDeliveryTermIsIncoterms;

    // Belgedeki cari kopyası (belge düzenlendiği andaki ünvan / vergi bilgisi; DB tetikleyicisi party_snapshot yazar:
    // yeni kayıtta, cari değişince ya da kopya boşken cari kartından)
    [NotMapped]
    property TaxOffice: string read FTaxOffice write FTaxOffice;

    [NotMapped]
    property TaxNo: string read FTaxNo write FTaxNo;

    [NotMapped]
    property AccountTitle: string read FAccountTitle write FAccountTitle;

    [NotMapped]
    property TaxpayerType: SmallInt read FTaxpayerType write FTaxpayerType;

    // Kolon değil (nesne özelliği): servis yükler (BusinessFindById) ve teklifle birlikte yazar
    property BillingAddress: TSysAddress read FBillingAddress;
    property ShippingAddress: TSysAddress read FShippingAddress;

    // Kolon değil (nesne özelliği): BusinessFindById ile dolar, BusinessSaveWithDetails ile yazılır
    property Lines: TObjectList<TSlsOfferDetail> read FLines;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSlsOffer;
  end;

  // Kalemden başlığa tipli erişim: Line.Header.OfferNo (HeaderEntity zayıf referans, sahiplenmez)
  TSlsOfferDetailHelper = class helper for TSlsOfferDetail
  private
    function GetHeader: TSlsOffer;
    procedure SetHeader(const Value: TSlsOffer);
  public
    property Header: TSlsOffer read GetHeader write SetHeader;
  end;

implementation

{ TSlsOfferDetailHelper }

function TSlsOfferDetailHelper.GetHeader: TSlsOffer;
begin
  Result := TSlsOffer(HeaderEntity);
end;

procedure TSlsOfferDetailHelper.SetHeader(const Value: TSlsOffer);
begin
  HeaderEntity := Value;
end;

{ TSlsOffer }

constructor TSlsOffer.Create;
begin
  inherited;
  FLines := TObjectList<TSlsOfferDetail>.Create(True);
  FBillingAddress := TSysAddress.Create;
  FShippingAddress := TSysAddress.Create;
  FOfferDate := Date;
  FStatus := 1;
  FSaleType := 1;
  // 0 = kur girilmedi: servis teklif tarihinin kurunu yazar
  FExchangeRate := 0;
end;

destructor TSlsOffer.Destroy;
begin
  FShippingAddress.Free;
  FBillingAddress.Free;
  FLines.Free;
  inherited;
end;

// Kalemler dahil derin kopya; kopyanın kalemleri kopya başlığa bağlanır
function TSlsOffer.Clone: TSlsOffer;
var
  LLine, LCopy: TSlsOfferDetail;
begin
  Result := TSlsOffer.Create;
  Result.Id := Self.Id;
  Result.OfferNo := Self.OfferNo;
  Result.OfferDate := Self.OfferDate;
  Result.ValidUntil := Self.ValidUntil;
  Result.AccAccountId := Self.AccAccountId;
  Result.CustomerRefNo := Self.CustomerRefNo;
  Result.EmpEmployeeId := Self.EmpEmployeeId;
  Result.Currency := Self.Currency;
  Result.ExchangeRate := Self.ExchangeRate;
  Result.PaymentTermDays := Self.PaymentTermDays;
  Result.Status := Self.Status;
  Result.GrossAmount := Self.GrossAmount;
  Result.DiscountAmount := Self.DiscountAmount;
  Result.NetAmount := Self.NetAmount;
  Result.VatAmount := Self.VatAmount;
  Result.TotalAmount := Self.TotalAmount;
  Result.Description := Self.Description;
  Result.BillingAddressId := Self.BillingAddressId;
  Result.BillingSysAddressId := Self.BillingSysAddressId;
  Result.ShippingAddressId := Self.ShippingAddressId;
  Result.ShippingSysAddressId := Self.ShippingSysAddressId;
  Result.BaseCurrency := Self.BaseCurrency;
  Result.UsdRate := Self.UsdRate;
  Result.EurRate := Self.EurRate;
  Result.DeliveryDate := Self.DeliveryDate;
  Result.EinvPaymentMeansId := Self.EinvPaymentMeansId;
  Result.EinvDeliveryTermId := Self.EinvDeliveryTermId;
  Result.SaleType := Self.SaleType;
  Result.DeliveryTermIsIncoterms := Self.DeliveryTermIsIncoterms;
  Result.PaymentMeansName := Self.PaymentMeansName;
  Result.DeliveryTermName := Self.DeliveryTermName;
  Result.TaxOffice := Self.TaxOffice;
  Result.TaxNo := Self.TaxNo;
  Result.AccountTitle := Self.AccountTitle;
  Result.TaxpayerType := Self.TaxpayerType;
  Result.BillingAddressText := Self.BillingAddressText;
  Result.ShippingAddressText := Self.ShippingAddressText;
  Result.TotalAmountBase := Self.TotalAmountBase;
  Result.FBillingAddress.Free;
  Result.FBillingAddress := Self.FBillingAddress.Clone;
  Result.FShippingAddress.Free;
  Result.FShippingAddress := Self.FShippingAddress.Clone;
  Result.AccountCode := Self.AccountCode;
  Result.AccountName := Self.AccountName;
  Result.EmployeeName := Self.EmployeeName;
  for LLine in Self.FLines do
  begin
    LCopy := LLine.Clone;
    LCopy.HeaderEntity := Result;
    Result.FLines.Add(LCopy);
  end;
end;

end.
