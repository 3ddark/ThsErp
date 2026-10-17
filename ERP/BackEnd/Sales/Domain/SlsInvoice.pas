unit SlsInvoice;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, SlsInvoiceDetail;

type
  [Table('sls_invoice')]
  TSlsInvoice = class(TEntity)
  private
    // Kalemler (sahiplenir): servis yükler / yazar; durum TDetailEntity (Id işareti + Deleted)
    FLines: TObjectList<TSlsInvoiceDetail>;
    FInvoiceNo: string;
    FInvoiceDate: TDate;
    FAccAccountId: Int64;
    FDueDate: TDate;
    FStkWarehouseId: Int64;
    FCurrency: string;
    FExchangeRate: Currency;
    FGrossAmount: Currency;
    FDiscountAmount: Currency;
    FNetAmount: Currency;
    FVatAmount: Currency;
    FTotalAmount: Currency;
    FDescription: string;
    // e-Belge (UBL-TR)
    FEinvProfileId: Int64;
    FEinvInvoiceTypeId: Int64;
    FEinvUuid: string;
    FEinvStatus: SmallInt;
    FEinvTaxExemptionId: Int64;
    FEinvDeliveryTermId: Int64;
    FEinvTransportModeId: Int64;
    FEinvPaymentMeansId: Int64;
    FCustomsDeclarationNo: string;
    FGtbRefNo: string;
    FActualExportDate: TDate;
    FWithholdingAmount: Currency;

    // View (vw_sls_invoice) okunabilir alanları
    FAccountCode: string;
    FAccountName: string;
    FWarehouseName: string;
    FProfileCode: string;
    FInvoiceTypeCode: string;
    FTaxExemptionCode: string;
    FTaxExemptionName: string;
    FDeliveryTermCode: string;
    FTransportModeName: string;
    FPaymentMeansName: string;
    FPayableAmount: Currency;
    FAccountEInvoiceActive: Boolean;
  public
    [Column('invoice_no')]
    [MaxLength(16)]
    property InvoiceNo: string read FInvoiceNo write FInvoiceNo;

    [Column('invoice_date')]
    [Required()]
    property InvoiceDate: TDate read FInvoiceDate write FInvoiceDate;

    [Column('acc_account_id')]
    [Required()]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('due_date')]
    property DueDate: TDate read FDueDate write FDueDate;

    [Column('stk_warehouse_id')]
    property StkWarehouseId: Int64 read FStkWarehouseId write FStkWarehouseId;

    [Column('currency')]
    [MaxLength(3)]
    property Currency: string read FCurrency write FCurrency;

    [Column('exchange_rate')]
    property ExchangeRate: Currency read FExchangeRate write FExchangeRate;

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
    property WarehouseName: string read FWarehouseName write FWarehouseName;

    // e-Belge (UBL-TR) — einv_status: 1 taslak … 7 iptal (EInvLookup), einv_uuid = ETTN
    [Column('einv_profile_id')]
    property EinvProfileId: Int64 read FEinvProfileId write FEinvProfileId;

    [Column('einv_invoice_type_id')]
    property EinvInvoiceTypeId: Int64 read FEinvInvoiceTypeId write FEinvInvoiceTypeId;

    [Column('einv_uuid')]
    property EinvUuid: string read FEinvUuid write FEinvUuid;

    [Column('einv_status')]
    property EinvStatus: SmallInt read FEinvStatus write FEinvStatus;

    [Column('einv_tax_exemption_id')]
    property EinvTaxExemptionId: Int64 read FEinvTaxExemptionId write FEinvTaxExemptionId;

    [Column('einv_delivery_term_id')]
    property EinvDeliveryTermId: Int64 read FEinvDeliveryTermId write FEinvDeliveryTermId;

    [Column('einv_transport_mode_id')]
    property EinvTransportModeId: Int64 read FEinvTransportModeId write FEinvTransportModeId;

    [Column('einv_payment_means_id')]
    property EinvPaymentMeansId: Int64 read FEinvPaymentMeansId write FEinvPaymentMeansId;

    [Column('customs_declaration_no')]
    [MaxLength(32)]
    property CustomsDeclarationNo: string read FCustomsDeclarationNo write FCustomsDeclarationNo;

    [Column('gtb_ref_no')]
    [MaxLength(32)]
    property GtbRefNo: string read FGtbRefNo write FGtbRefNo;

    [Column('actual_export_date')]
    property ActualExportDate: TDate read FActualExportDate write FActualExportDate;

    [Column('withholding_amount')]
    property WithholdingAmount: Currency read FWithholdingAmount write FWithholdingAmount;

    [NotMapped]
    property ProfileCode: string read FProfileCode write FProfileCode;

    [NotMapped]
    property InvoiceTypeCode: string read FInvoiceTypeCode write FInvoiceTypeCode;

    [NotMapped]
    property TaxExemptionCode: string read FTaxExemptionCode write FTaxExemptionCode;

    [NotMapped]
    property TaxExemptionName: string read FTaxExemptionName write FTaxExemptionName;

    [NotMapped]
    property DeliveryTermCode: string read FDeliveryTermCode write FDeliveryTermCode;

    [NotMapped]
    property TransportModeName: string read FTransportModeName write FTransportModeName;

    [NotMapped]
    property PaymentMeansName: string read FPaymentMeansName write FPaymentMeansName;

    [NotMapped]
    property PayableAmount: Currency read FPayableAmount write FPayableAmount;

    [NotMapped]
    property AccountEInvoiceActive: Boolean read FAccountEInvoiceActive write FAccountEInvoiceActive;

    // Kolon değil (nesne özelliği): BusinessFindById ile dolar, BusinessSaveWithDetails ile yazılır
    property Lines: TObjectList<TSlsInvoiceDetail> read FLines;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSlsInvoice;
  end;

  // Kalemden başlığa tipli erişim: Line.Header.InvoiceNo (HeaderEntity zayıf referans, sahiplenmez)
  TSlsInvoiceDetailHelper = class helper for TSlsInvoiceDetail
  private
    function GetHeader: TSlsInvoice;
    procedure SetHeader(const Value: TSlsInvoice);
  public
    property Header: TSlsInvoice read GetHeader write SetHeader;
  end;

implementation

{ TSlsInvoiceDetailHelper }

function TSlsInvoiceDetailHelper.GetHeader: TSlsInvoice;
begin
  Result := TSlsInvoice(HeaderEntity);
end;

procedure TSlsInvoiceDetailHelper.SetHeader(const Value: TSlsInvoice);
begin
  HeaderEntity := Value;
end;

{ TSlsInvoice }

constructor TSlsInvoice.Create;
begin
  inherited;
  FLines := TObjectList<TSlsInvoiceDetail>.Create(True);
  FInvoiceDate := Date;
  FExchangeRate := 1;
end;

destructor TSlsInvoice.Destroy;
begin
  FLines.Free;
  inherited;
end;

// Kalemler dahil derin kopya; kopyanın kalemleri kopya başlığa bağlanır
function TSlsInvoice.Clone: TSlsInvoice;
var
  LLine, LCopy: TSlsInvoiceDetail;
begin
  Result := TSlsInvoice.Create;
  Result.Id := Self.Id;
  Result.InvoiceNo := Self.InvoiceNo;
  Result.InvoiceDate := Self.InvoiceDate;
  Result.AccAccountId := Self.AccAccountId;
  Result.DueDate := Self.DueDate;
  Result.StkWarehouseId := Self.StkWarehouseId;
  Result.Currency := Self.Currency;
  Result.ExchangeRate := Self.ExchangeRate;
  Result.GrossAmount := Self.GrossAmount;
  Result.DiscountAmount := Self.DiscountAmount;
  Result.NetAmount := Self.NetAmount;
  Result.VatAmount := Self.VatAmount;
  Result.TotalAmount := Self.TotalAmount;
  Result.Description := Self.Description;
  Result.AccountCode := Self.AccountCode;
  Result.AccountName := Self.AccountName;
  Result.WarehouseName := Self.WarehouseName;
  Result.EinvProfileId := Self.EinvProfileId;
  Result.EinvInvoiceTypeId := Self.EinvInvoiceTypeId;
  Result.EinvUuid := Self.EinvUuid;
  Result.EinvStatus := Self.EinvStatus;
  Result.EinvTaxExemptionId := Self.EinvTaxExemptionId;
  Result.EinvDeliveryTermId := Self.EinvDeliveryTermId;
  Result.EinvTransportModeId := Self.EinvTransportModeId;
  Result.EinvPaymentMeansId := Self.EinvPaymentMeansId;
  Result.CustomsDeclarationNo := Self.CustomsDeclarationNo;
  Result.GtbRefNo := Self.GtbRefNo;
  Result.ActualExportDate := Self.ActualExportDate;
  Result.WithholdingAmount := Self.WithholdingAmount;
  Result.ProfileCode := Self.ProfileCode;
  Result.InvoiceTypeCode := Self.InvoiceTypeCode;
  Result.TaxExemptionCode := Self.TaxExemptionCode;
  Result.TaxExemptionName := Self.TaxExemptionName;
  Result.DeliveryTermCode := Self.DeliveryTermCode;
  Result.TransportModeName := Self.TransportModeName;
  Result.PaymentMeansName := Self.PaymentMeansName;
  Result.PayableAmount := Self.PayableAmount;
  Result.AccountEInvoiceActive := Self.AccountEInvoiceActive;
  for LLine in Self.FLines do
  begin
    LCopy := LLine.Clone;
    LCopy.HeaderEntity := Result;
    Result.FLines.Add(LCopy);
  end;
end;

end.
