unit PurInvoice;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('pur_invoice')]
  TPurInvoice = class(TEntity)
  private
    FInvoiceNo: string;
    FInvoiceDate: TDate;
    FAccAccountId: Int64;
    FDueDate: TDate;
    FCurrency: string;
    FExchangeRate: Currency;
    FGrossAmount: Currency;
    FDiscountAmount: Currency;
    FNetAmount: Currency;
    FVatAmount: Currency;
    FTotalAmount: Currency;
    FDescription: string;

    // View (vw_pur_invoice) okunabilir alanları
    FAccountCode: string;
    FAccountName: string;
  public
    [Column('invoice_no')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property InvoiceNo: string read FInvoiceNo write FInvoiceNo;

    [Column('invoice_date')]
    [Required()]
    property InvoiceDate: TDate read FInvoiceDate write FInvoiceDate;

    [Column('acc_account_id')]
    [Required()]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('due_date')]
    property DueDate: TDate read FDueDate write FDueDate;

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

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPurInvoice;
  end;

implementation

constructor TPurInvoice.Create;
begin
  inherited;
  FInvoiceDate := Date;
  FExchangeRate := 1;
end;

destructor TPurInvoice.Destroy;
begin
  inherited;
end;

function TPurInvoice.Clone: TPurInvoice;
begin
  Result := TPurInvoice.Create;
  Result.Id := Self.Id;
  Result.InvoiceNo := Self.InvoiceNo;
  Result.InvoiceDate := Self.InvoiceDate;
  Result.AccAccountId := Self.AccAccountId;
  Result.DueDate := Self.DueDate;
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
end;

end.
