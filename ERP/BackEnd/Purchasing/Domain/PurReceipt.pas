unit PurReceipt;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('pur_receipt')]
  TPurReceipt = class(TEntity)
  private
    FReceiptNo: string;
    FReceiptDate: TDate;
    FAccAccountId: Int64;
    FStkWarehouseId: Int64;
    FWaybillNo: string;
    FPurOrderId: Int64;
    FCurrency: string;
    FDescription: string;

    // View (vw_pur_receipt) okunabilir alanları
    FAccountCode: string;
    FAccountName: string;
    FWarehouseName: string;
    FOrderNo: string;
  public
    [Column('receipt_no')]
    [MaxLength(16)]
    property ReceiptNo: string read FReceiptNo write FReceiptNo;

    [Column('receipt_date')]
    [Required()]
    property ReceiptDate: TDate read FReceiptDate write FReceiptDate;

    [Column('acc_account_id')]
    [Required()]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('stk_warehouse_id')]
    [Required()]
    property StkWarehouseId: Int64 read FStkWarehouseId write FStkWarehouseId;

    [Column('waybill_no')]
    [MaxLength(32)]
    property WaybillNo: string read FWaybillNo write FWaybillNo;

    [Column('pur_order_id')]
    property PurOrderId: Int64 read FPurOrderId write FPurOrderId;

    [Column('currency')]
    [MaxLength(3)]
    property Currency: string read FCurrency write FCurrency;

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
    property OrderNo: string read FOrderNo write FOrderNo;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPurReceipt;
  end;

implementation

constructor TPurReceipt.Create;
begin
  inherited;
  FReceiptDate := Date;
end;

destructor TPurReceipt.Destroy;
begin
  inherited;
end;

function TPurReceipt.Clone: TPurReceipt;
begin
  Result := TPurReceipt.Create;
  Result.Id := Self.Id;
  Result.ReceiptNo := Self.ReceiptNo;
  Result.ReceiptDate := Self.ReceiptDate;
  Result.AccAccountId := Self.AccAccountId;
  Result.StkWarehouseId := Self.StkWarehouseId;
  Result.WaybillNo := Self.WaybillNo;
  Result.PurOrderId := Self.PurOrderId;
  Result.Currency := Self.Currency;
  Result.Description := Self.Description;
  Result.AccountCode := Self.AccountCode;
  Result.AccountName := Self.AccountName;
  Result.WarehouseName := Self.WarehouseName;
  Result.OrderNo := Self.OrderNo;
end;

end.
