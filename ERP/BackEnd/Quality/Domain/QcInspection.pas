unit QcInspection;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  // Giriş kalite kontrol kaydı (mal kabul kalemi başına bir kayıt). Kontrol edilen miktar, stok ve sonuç servisten:
  // uygun = miktar - uygunsuz; uygunsuz miktar varsa karar (iade / hurda / yeniden işleme / şartlı kabul) zorunlu
  [Table('qc_inspection')]
  TQcInspection = class(TEntity)
  private
    FInspectionNo: string;
    FInspectionDate: TDate;
    FPurReceiptDetailId: Int64;
    FStkInventoryId: Int64;
    FQuantity: Currency;
    FAcceptedQuantity: Currency;
    FRejectedQuantity: Currency;
    FInspectionResult: SmallInt;
    FDisposition: SmallInt;
    FEmpEmployeeId: Int64;
    FDescription: string;

    // View (vw_qc_inspection) okunabilir alanları
    FPurReceiptId: Int64;
    FReceiptNo: string;
    FReceiptDate: TDate;
    FAccountName: string;
    FWarehouseName: string;
    FReceiptLineNo: Integer;
    FInventoryCode: string;
    FInventoryName: string;
    FUomCode: string;
    FEmployeeName: string;
    FStkTransactionId: Int64;
    FRejectStkWarehouseId: Int64;
  public
    [Column('inspection_no')]
    [MaxLength(16)]
    property InspectionNo: string read FInspectionNo write FInspectionNo;

    [Column('inspection_date')]
    [Required()]
    property InspectionDate: TDate read FInspectionDate write FInspectionDate;

    [Column('pur_receipt_detail_id')]
    [Required()]
    property PurReceiptDetailId: Int64 read FPurReceiptDetailId write FPurReceiptDetailId;

    [Column('stk_inventory_id')]
    property StkInventoryId: Int64 read FStkInventoryId write FStkInventoryId;

    [Column('quantity')]
    property Quantity: Currency read FQuantity write FQuantity;

    [Column('accepted_quantity')]
    property AcceptedQuantity: Currency read FAcceptedQuantity write FAcceptedQuantity;

    [Column('rejected_quantity')]
    property RejectedQuantity: Currency read FRejectedQuantity write FRejectedQuantity;

    [Column('result')]
    property InspectionResult: SmallInt read FInspectionResult write FInspectionResult;

    [Column('disposition')]
    property Disposition: SmallInt read FDisposition write FDisposition;

    [Column('emp_employee_id')]
    property EmpEmployeeId: Int64 read FEmpEmployeeId write FEmpEmployeeId;

    [Column('description')]
    [MaxLength(256)]
    property Description: string read FDescription write FDescription;

    [NotMapped]
    property PurReceiptId: Int64 read FPurReceiptId write FPurReceiptId;

    [NotMapped]
    property ReceiptNo: string read FReceiptNo write FReceiptNo;

    [NotMapped]
    property ReceiptDate: TDate read FReceiptDate write FReceiptDate;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    [NotMapped]
    property WarehouseName: string read FWarehouseName write FWarehouseName;

    [NotMapped]
    property ReceiptLineNo: Integer read FReceiptLineNo write FReceiptLineNo;

    [NotMapped]
    property InventoryCode: string read FInventoryCode write FInventoryCode;

    [NotMapped]
    property InventoryName: string read FInventoryName write FInventoryName;

    [NotMapped]
    property UomCode: string read FUomCode write FUomCode;

    [NotMapped]
    property EmployeeName: string read FEmployeeName write FEmployeeName;

    [NotMapped]
    property StkTransactionId: Int64 read FStkTransactionId write FStkTransactionId;

    [NotMapped]
    property RejectStkWarehouseId: Int64 read FRejectStkWarehouseId write FRejectStkWarehouseId;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TQcInspection;
  end;

implementation

constructor TQcInspection.Create;
begin
  inherited;
  FInspectionDate := Date;
end;

destructor TQcInspection.Destroy;
begin
  inherited;
end;

function TQcInspection.Clone: TQcInspection;
begin
  Result := TQcInspection.Create;
  Result.Id := Self.Id;
  Result.InspectionNo := Self.InspectionNo;
  Result.InspectionDate := Self.InspectionDate;
  Result.PurReceiptDetailId := Self.PurReceiptDetailId;
  Result.StkInventoryId := Self.StkInventoryId;
  Result.Quantity := Self.Quantity;
  Result.AcceptedQuantity := Self.AcceptedQuantity;
  Result.RejectedQuantity := Self.RejectedQuantity;
  Result.InspectionResult := Self.InspectionResult;
  Result.Disposition := Self.Disposition;
  Result.EmpEmployeeId := Self.EmpEmployeeId;
  Result.Description := Self.Description;
  Result.PurReceiptId := Self.PurReceiptId;
  Result.ReceiptNo := Self.ReceiptNo;
  Result.ReceiptDate := Self.ReceiptDate;
  Result.AccountName := Self.AccountName;
  Result.WarehouseName := Self.WarehouseName;
  Result.ReceiptLineNo := Self.ReceiptLineNo;
  Result.InventoryCode := Self.InventoryCode;
  Result.InventoryName := Self.InventoryName;
  Result.UomCode := Self.UomCode;
  Result.EmployeeName := Self.EmployeeName;
  Result.StkTransactionId := Self.StkTransactionId;
  Result.RejectStkWarehouseId := Self.RejectStkWarehouseId;
end;

end.
