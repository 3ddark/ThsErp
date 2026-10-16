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

    // View (vw_sls_invoice) okunabilir alanları
    FAccountCode: string;
    FAccountName: string;
    FWarehouseName: string;
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
  for LLine in Self.FLines do
  begin
    LCopy := LLine.Clone;
    LCopy.HeaderEntity := Result;
    Result.FLines.Add(LCopy);
  end;
end;

end.
