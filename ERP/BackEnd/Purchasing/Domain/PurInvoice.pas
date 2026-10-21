unit PurInvoice;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, PurInvoiceDetail;

type
  [Table('pur_invoice')]
  TPurInvoice = class(TEntity)
  private
    // Kalemler (sahiplenir): servis yükler / yazar; durum TDetailEntity (Id işareti + Deleted)
    FLines: TObjectList<TPurInvoiceDetail>;
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

    // Kolon değil (nesne özelliği): BusinessFindById ile dolar, BusinessSaveWithDetails ile yazılır
    property Lines: TObjectList<TPurInvoiceDetail> read FLines;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPurInvoice;
  end;

  // Kalemden başlığa tipli erişim: Line.Header.InvoiceNo (HeaderEntity zayıf referans, sahiplenmez)
  TPurInvoiceDetailHelper = class helper for TPurInvoiceDetail
  private
    function GetHeader: TPurInvoice;
    procedure SetHeader(const Value: TPurInvoice);
  public
    property Header: TPurInvoice read GetHeader write SetHeader;
  end;

implementation

{ TPurInvoiceDetailHelper }

function TPurInvoiceDetailHelper.GetHeader: TPurInvoice;
begin
  Result := TPurInvoice(HeaderEntity);
end;

procedure TPurInvoiceDetailHelper.SetHeader(const Value: TPurInvoice);
begin
  HeaderEntity := Value;
end;

{ TPurInvoice }

constructor TPurInvoice.Create;
begin
  inherited;
  FLines := TObjectList<TPurInvoiceDetail>.Create(True);
  FInvoiceDate := Date;
  FExchangeRate := 1;
end;

destructor TPurInvoice.Destroy;
begin
  FLines.Free;
  inherited;
end;

// Kalemler dahil derin kopya; kopyanın kalemleri kopya başlığa bağlanır
function TPurInvoice.Clone: TPurInvoice;
var
  LLine, LCopy: TPurInvoiceDetail;
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
  for LLine in Self.FLines do
  begin
    LCopy := LLine.Clone;
    LCopy.HeaderEntity := Result;
    Result.FLines.Add(LCopy);
  end;
end;

end.
