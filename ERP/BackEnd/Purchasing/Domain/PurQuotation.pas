unit PurQuotation;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, PurQuotationDetail;

type
  // Alış teklifi: tedarikçinin talebe (ya da talepsiz) verdiği fiyat / koşullar. Talep -> teklif -> sipariş;
  // durum PurLookup PUR_QUO_*; onay bilgisi ve sipariş bağı servis tarafından yazılır (insert / update SQL dışı)
  [Table('pur_quotation')]
  TPurQuotation = class(TEntity)
  private
    // Kalemler (sahiplenir): servis yükler / yazar; durum TDetailEntity (Id işareti + Deleted)
    FLines: TObjectList<TPurQuotationDetail>;
    FQuotationNo: string;
    FQuotationDate: TDate;
    FPurRequestId: Int64;
    FAccAccountId: Int64;
    FSupplierRefNo: string;
    FValidUntil: TDate;
    FDeliveryDays: SmallInt;
    FDeliveryDate: TDate;
    FCurrency: string;
    FExchangeRate: Currency;
    FPaymentTermDays: SmallInt;
    FPaymentTerms: string;
    FStatus: SmallInt;
    FGrossAmount: Currency;
    FDiscountAmount: Currency;
    FNetAmount: Currency;
    FVatAmount: Currency;
    FTotalAmount: Currency;
    FPurOrderId: Int64;
    FApprovedSysUserId: Int64;
    FApprovedAt: TDateTime;
    FDescription: string;

    // View (vw_pur_quotation) okunabilir alanları
    FRequestNo: string;
    FAccountCode: string;
    FAccountName: string;
    FOrderNo: string;
    FApprovedBy: string;
  public
    [Column('quotation_no')]
    [MaxLength(16)]
    property QuotationNo: string read FQuotationNo write FQuotationNo;

    [Column('quotation_date')]
    [Required()]
    property QuotationDate: TDate read FQuotationDate write FQuotationDate;

    [Column('pur_request_id')]
    property PurRequestId: Int64 read FPurRequestId write FPurRequestId;

    [Column('acc_account_id')]
    [Required()]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('supplier_ref_no')]
    [MaxLength(32)]
    property SupplierRefNo: string read FSupplierRefNo write FSupplierRefNo;

    [Column('valid_until')]
    property ValidUntil: TDate read FValidUntil write FValidUntil;

    [Column('delivery_days')]
    property DeliveryDays: SmallInt read FDeliveryDays write FDeliveryDays;

    [Column('delivery_date')]
    property DeliveryDate: TDate read FDeliveryDate write FDeliveryDate;

    [Column('currency')]
    [MaxLength(3)]
    property Currency: string read FCurrency write FCurrency;

    [Column('exchange_rate')]
    property ExchangeRate: Currency read FExchangeRate write FExchangeRate;

    [Column('payment_term_days')]
    property PaymentTermDays: SmallInt read FPaymentTermDays write FPaymentTermDays;

    [Column('payment_terms')]
    [MaxLength(256)]
    property PaymentTerms: string read FPaymentTerms write FPaymentTerms;

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

    [Column('pur_order_id')]
    property PurOrderId: Int64 read FPurOrderId write FPurOrderId;

    [Column('approved_sys_user_id')]
    property ApprovedSysUserId: Int64 read FApprovedSysUserId write FApprovedSysUserId;

    [Column('approved_at')]
    property ApprovedAt: TDateTime read FApprovedAt write FApprovedAt;

    [Column('description')]
    [MaxLength(256)]
    property Description: string read FDescription write FDescription;

    [NotMapped]
    property RequestNo: string read FRequestNo write FRequestNo;

    [NotMapped]
    property AccountCode: string read FAccountCode write FAccountCode;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    [NotMapped]
    property OrderNo: string read FOrderNo write FOrderNo;

    [NotMapped]
    property ApprovedBy: string read FApprovedBy write FApprovedBy;

    // Kolon değil (nesne özelliği): BusinessFindById ile dolar, BusinessSaveWithDetails ile yazılır
    property Lines: TObjectList<TPurQuotationDetail> read FLines;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPurQuotation;
  end;

  // Kalemden başlığa tipli erişim: Line.Header (HeaderEntity zayıf referans, sahiplenmez)
  TPurQuotationDetailHelper = class helper for TPurQuotationDetail
  private
    function GetHeader: TPurQuotation;
    procedure SetHeader(const Value: TPurQuotation);
  public
    property Header: TPurQuotation read GetHeader write SetHeader;
  end;

implementation

{ TPurQuotationDetailHelper }

function TPurQuotationDetailHelper.GetHeader: TPurQuotation;
begin
  Result := TPurQuotation(HeaderEntity);
end;

procedure TPurQuotationDetailHelper.SetHeader(const Value: TPurQuotation);
begin
  HeaderEntity := Value;
end;

{ TPurQuotation }

constructor TPurQuotation.Create;
begin
  inherited;
  FLines := TObjectList<TPurQuotationDetail>.Create(True);
  FQuotationDate := Date;
  FStatus := 1;
  FExchangeRate := 1;
end;

destructor TPurQuotation.Destroy;
begin
  FLines.Free;
  inherited;
end;

// Kalemler dahil derin kopya; kopyanın kalemleri kopya başlığa bağlanır
function TPurQuotation.Clone: TPurQuotation;
var
  LLine, LCopy: TPurQuotationDetail;
begin
  Result := TPurQuotation.Create;
  Result.Id := Self.Id;
  Result.QuotationNo := Self.QuotationNo;
  Result.QuotationDate := Self.QuotationDate;
  Result.PurRequestId := Self.PurRequestId;
  Result.AccAccountId := Self.AccAccountId;
  Result.SupplierRefNo := Self.SupplierRefNo;
  Result.ValidUntil := Self.ValidUntil;
  Result.DeliveryDays := Self.DeliveryDays;
  Result.DeliveryDate := Self.DeliveryDate;
  Result.Currency := Self.Currency;
  Result.ExchangeRate := Self.ExchangeRate;
  Result.PaymentTermDays := Self.PaymentTermDays;
  Result.PaymentTerms := Self.PaymentTerms;
  Result.Status := Self.Status;
  Result.GrossAmount := Self.GrossAmount;
  Result.DiscountAmount := Self.DiscountAmount;
  Result.NetAmount := Self.NetAmount;
  Result.VatAmount := Self.VatAmount;
  Result.TotalAmount := Self.TotalAmount;
  Result.PurOrderId := Self.PurOrderId;
  Result.ApprovedSysUserId := Self.ApprovedSysUserId;
  Result.ApprovedAt := Self.ApprovedAt;
  Result.Description := Self.Description;
  Result.RequestNo := Self.RequestNo;
  Result.AccountCode := Self.AccountCode;
  Result.AccountName := Self.AccountName;
  Result.OrderNo := Self.OrderNo;
  Result.ApprovedBy := Self.ApprovedBy;
  for LLine in Self.FLines do
  begin
    LCopy := LLine.Clone;
    LCopy.HeaderEntity := Result;
    Result.FLines.Add(LCopy);
  end;
end;

end.
