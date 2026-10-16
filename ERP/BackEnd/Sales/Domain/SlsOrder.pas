unit SlsOrder;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, SlsOrderDetail;

type
  [Table('sls_order')]
  TSlsOrder = class(TEntity)
  private
    // Kalemler (sahiplenir): servis yükler / yazar; durum TDetailEntity (Id işareti + Deleted)
    FLines: TObjectList<TSlsOrderDetail>;
    FOrderNo: string;
    FOrderDate: TDate;
    FAccAccountId: Int64;
    FCustomerRefNo: string;
    FDeliveryDate: TDate;
    FStkWarehouseId: Int64;
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

    // View (vw_sls_order) okunabilir alanları
    FAccountCode: string;
    FAccountName: string;
    FWarehouseName: string;
    FEmployeeName: string;
  public
    [Column('order_no')]
    [MaxLength(16)]
    property OrderNo: string read FOrderNo write FOrderNo;

    [Column('order_date')]
    [Required()]
    property OrderDate: TDate read FOrderDate write FOrderDate;

    [Column('acc_account_id')]
    [Required()]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('customer_ref_no')]
    [MaxLength(32)]
    property CustomerRefNo: string read FCustomerRefNo write FCustomerRefNo;

    [Column('delivery_date')]
    property DeliveryDate: TDate read FDeliveryDate write FDeliveryDate;

    [Column('stk_warehouse_id')]
    property StkWarehouseId: Int64 read FStkWarehouseId write FStkWarehouseId;

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
    property WarehouseName: string read FWarehouseName write FWarehouseName;

    [NotMapped]
    property EmployeeName: string read FEmployeeName write FEmployeeName;

    // Kolon değil (nesne özelliği): BusinessFindById ile dolar, BusinessSaveWithDetails ile yazılır
    property Lines: TObjectList<TSlsOrderDetail> read FLines;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSlsOrder;
  end;

  // Kalemden başlığa tipli erişim: Line.Header.OrderNo (HeaderEntity zayıf referans, sahiplenmez)
  TSlsOrderDetailHelper = class helper for TSlsOrderDetail
  private
    function GetHeader: TSlsOrder;
    procedure SetHeader(const Value: TSlsOrder);
  public
    property Header: TSlsOrder read GetHeader write SetHeader;
  end;

implementation

{ TSlsOrderDetailHelper }

function TSlsOrderDetailHelper.GetHeader: TSlsOrder;
begin
  Result := TSlsOrder(HeaderEntity);
end;

procedure TSlsOrderDetailHelper.SetHeader(const Value: TSlsOrder);
begin
  HeaderEntity := Value;
end;

{ TSlsOrder }

constructor TSlsOrder.Create;
begin
  inherited;
  FLines := TObjectList<TSlsOrderDetail>.Create(True);
  FOrderDate := Date;
  FStatus := 1;
  FExchangeRate := 1;
end;

destructor TSlsOrder.Destroy;
begin
  FLines.Free;
  inherited;
end;

// Kalemler dahil derin kopya; kopyanın kalemleri kopya başlığa bağlanır
function TSlsOrder.Clone: TSlsOrder;
var
  LLine, LCopy: TSlsOrderDetail;
begin
  Result := TSlsOrder.Create;
  Result.Id := Self.Id;
  Result.OrderNo := Self.OrderNo;
  Result.OrderDate := Self.OrderDate;
  Result.AccAccountId := Self.AccAccountId;
  Result.CustomerRefNo := Self.CustomerRefNo;
  Result.DeliveryDate := Self.DeliveryDate;
  Result.StkWarehouseId := Self.StkWarehouseId;
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
  Result.WarehouseName := Self.WarehouseName;
  Result.EmployeeName := Self.EmployeeName;
  for LLine in Self.FLines do
  begin
    LCopy := LLine.Clone;
    LCopy.HeaderEntity := Result;
    Result.FLines.Add(LCopy);
  end;
end;

end.
