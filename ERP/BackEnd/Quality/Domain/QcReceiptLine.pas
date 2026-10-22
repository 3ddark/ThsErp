unit QcReceiptLine;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  // Kalite kontrol gereken mal kabul kalemi (salt okunur, yalnız vw_qc_receipt_line; modül kapalıyken boş).
  // Id = mal kabul kalemi id; QcStatus 1 bekliyor / 2 yeniden kontrol / 3 kontrol edildi
  [Table('qc_receipt_line')]
  TQcReceiptLine = class(TEntity)
  private
    FPurReceiptId: Int64;
    FReceiptNo: string;
    FReceiptDate: TDate;
    FAccAccountId: Int64;
    FAccountName: string;
    FStkWarehouseId: Int64;
    FWarehouseName: string;
    FLineNo: SmallInt;
    FStkInventoryId: Int64;
    FInventoryCode: string;
    FInventoryName: string;
    FUomCode: string;
    FQuantity: Currency;
    FInspectionCriteria: string;
    FQcInspectionId: Int64;
    FInspectionNo: string;
    FInspectionDate: TDate;
    FInspectedQuantity: Currency;
    FAcceptedQuantity: Currency;
    FRejectedQuantity: Currency;
    FInspectionResult: SmallInt;
    FQcStatus: SmallInt;
  public
    [Column('pur_receipt_id')]
    property PurReceiptId: Int64 read FPurReceiptId write FPurReceiptId;

    [Column('receipt_no')]
    [MaxLength(16)]
    property ReceiptNo: string read FReceiptNo write FReceiptNo;

    [Column('receipt_date')]
    property ReceiptDate: TDate read FReceiptDate write FReceiptDate;

    [Column('acc_account_id')]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('account_name')]
    [MaxLength(128)]
    property AccountName: string read FAccountName write FAccountName;

    [Column('stk_warehouse_id')]
    property StkWarehouseId: Int64 read FStkWarehouseId write FStkWarehouseId;

    [Column('warehouse_name')]
    [MaxLength(64)]
    property WarehouseName: string read FWarehouseName write FWarehouseName;

    [Column('line_no')]
    property LineNo: SmallInt read FLineNo write FLineNo;

    [Column('stk_inventory_id')]
    property StkInventoryId: Int64 read FStkInventoryId write FStkInventoryId;

    [Column('inventory_code')]
    [MaxLength(32)]
    property InventoryCode: string read FInventoryCode write FInventoryCode;

    [Column('inventory_name')]
    [MaxLength(128)]
    property InventoryName: string read FInventoryName write FInventoryName;

    [Column('uom_code')]
    [MaxLength(16)]
    property UomCode: string read FUomCode write FUomCode;

    [Column('quantity')]
    property Quantity: Currency read FQuantity write FQuantity;

    [Column('inspection_criteria')]
    [MaxLength(256)]
    property InspectionCriteria: string read FInspectionCriteria write FInspectionCriteria;

    [Column('qc_inspection_id')]
    property QcInspectionId: Int64 read FQcInspectionId write FQcInspectionId;

    [Column('inspection_no')]
    [MaxLength(16)]
    property InspectionNo: string read FInspectionNo write FInspectionNo;

    [Column('inspection_date')]
    property InspectionDate: TDate read FInspectionDate write FInspectionDate;

    [Column('inspected_quantity')]
    property InspectedQuantity: Currency read FInspectedQuantity write FInspectedQuantity;

    [Column('accepted_quantity')]
    property AcceptedQuantity: Currency read FAcceptedQuantity write FAcceptedQuantity;

    [Column('rejected_quantity')]
    property RejectedQuantity: Currency read FRejectedQuantity write FRejectedQuantity;

    [Column('result')]
    property InspectionResult: SmallInt read FInspectionResult write FInspectionResult;

    [Column('qc_status')]
    property QcStatus: SmallInt read FQcStatus write FQcStatus;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TQcReceiptLine;
  end;

implementation

constructor TQcReceiptLine.Create;
begin
  inherited;
end;

destructor TQcReceiptLine.Destroy;
begin
  inherited;
end;

function TQcReceiptLine.Clone: TQcReceiptLine;
begin
  Result := TQcReceiptLine.Create;
  Result.Id := Self.Id;
  Result.PurReceiptId := Self.PurReceiptId;
  Result.ReceiptNo := Self.ReceiptNo;
  Result.ReceiptDate := Self.ReceiptDate;
  Result.AccAccountId := Self.AccAccountId;
  Result.AccountName := Self.AccountName;
  Result.StkWarehouseId := Self.StkWarehouseId;
  Result.WarehouseName := Self.WarehouseName;
  Result.LineNo := Self.LineNo;
  Result.StkInventoryId := Self.StkInventoryId;
  Result.InventoryCode := Self.InventoryCode;
  Result.InventoryName := Self.InventoryName;
  Result.UomCode := Self.UomCode;
  Result.Quantity := Self.Quantity;
  Result.InspectionCriteria := Self.InspectionCriteria;
  Result.QcInspectionId := Self.QcInspectionId;
  Result.InspectionNo := Self.InspectionNo;
  Result.InspectionDate := Self.InspectionDate;
  Result.InspectedQuantity := Self.InspectedQuantity;
  Result.AcceptedQuantity := Self.AcceptedQuantity;
  Result.RejectedQuantity := Self.RejectedQuantity;
  Result.InspectionResult := Self.InspectionResult;
  Result.QcStatus := Self.QcStatus;
end;

end.
