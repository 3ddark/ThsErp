unit SlsOffer;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('sls_offer')]
  TSlsOffer = class(TEntity)
  private
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

    // View (vw_sls_offer) okunabilir alanları
    FAccountCode: string;
    FAccountName: string;
    FEmployeeName: string;
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

    [NotMapped]
    property AccountCode: string read FAccountCode write FAccountCode;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    [NotMapped]
    property EmployeeName: string read FEmployeeName write FEmployeeName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSlsOffer;
  end;

implementation

constructor TSlsOffer.Create;
begin
  inherited;
  FOfferDate := Date;
  FStatus := 1;
  FExchangeRate := 1;
end;

destructor TSlsOffer.Destroy;
begin
  inherited;
end;

function TSlsOffer.Clone: TSlsOffer;
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
  Result.AccountCode := Self.AccountCode;
  Result.AccountName := Self.AccountName;
  Result.EmployeeName := Self.EmployeeName;
end;

end.
