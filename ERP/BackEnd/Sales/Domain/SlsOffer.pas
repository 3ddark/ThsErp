unit SlsOffer;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, SlsOfferDetail;

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
  FOfferDate := Date;
  FStatus := 1;
  FExchangeRate := 1;
end;

destructor TSlsOffer.Destroy;
begin
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
