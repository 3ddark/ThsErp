unit StkTransaction;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('stk_transaction')]
  TStkTransaction = class(TEntity)
  private
    FTransactionDate: TDate;
    FTransactionType: SmallInt;
    FStkInventoryId: Int64;
    FFromStkWarehouseId: Int64;
    FToStkWarehouseId: Int64;
    FQuantity: Currency;
    FAmount: Currency;
    FAmountForeign: Currency;
    FCurrency: string;
    FIsOpening: Boolean;
    FDescription: string;
    FDispatchId: Int64;
    FProductionId: Int64;

    // View (vw_stk_transaction) okunabilir alanları
    FInventoryName: string;
    FFromWarehouseName: string;
    FToWarehouseName: string;
    FInventoryCode: string;
  public
    [Column('transaction_date')]
    property TransactionDate: TDate read FTransactionDate write FTransactionDate;

    [Column('transaction_type')]
    property TransactionType: SmallInt read FTransactionType write FTransactionType;

    [Column('stk_inventory_id')]
    property StkInventoryId: Int64 read FStkInventoryId write FStkInventoryId;

    [Column('from_stk_warehouse_id')]
    property FromStkWarehouseId: Int64 read FFromStkWarehouseId write FFromStkWarehouseId;

    [Column('to_stk_warehouse_id')]
    property ToStkWarehouseId: Int64 read FToStkWarehouseId write FToStkWarehouseId;

    [Column('quantity')]
    property Quantity: Currency read FQuantity write FQuantity;

    [Column('amount')]
    property Amount: Currency read FAmount write FAmount;

    [Column('amount_foreign')]
    property AmountForeign: Currency read FAmountForeign write FAmountForeign;

    [Column('currency')]
    [MaxLength(3)]
    property Currency: string read FCurrency write FCurrency;

    [Column('is_opening')]
    property IsOpening: Boolean read FIsOpening write FIsOpening;

    [Column('description')]
    [MaxLength(128)]
    property Description: string read FDescription write FDescription;

    [Column('dispatch_id')]
    property DispatchId: Int64 read FDispatchId write FDispatchId;

    [Column('production_id')]
    property ProductionId: Int64 read FProductionId write FProductionId;

    [NotMapped]
    property InventoryName: string read FInventoryName write FInventoryName;

    [NotMapped]
    property FromWarehouseName: string read FFromWarehouseName write FFromWarehouseName;

    [NotMapped]
    property ToWarehouseName: string read FToWarehouseName write FToWarehouseName;

    [NotMapped]
    property InventoryCode: string read FInventoryCode write FInventoryCode;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TStkTransaction;
  end;

implementation

constructor TStkTransaction.Create;
begin
  inherited;
  FTransactionDate := Date;
  FTransactionType := 1;  // STK_TRANSACTION_IN
end;

destructor TStkTransaction.Destroy;
begin
  inherited;
end;

function TStkTransaction.Clone: TStkTransaction;
begin
  Result := TStkTransaction.Create;
  Result.Id := Self.Id;
  Result.TransactionDate := Self.TransactionDate;
  Result.TransactionType := Self.TransactionType;
  Result.StkInventoryId := Self.StkInventoryId;
  Result.FromStkWarehouseId := Self.FromStkWarehouseId;
  Result.ToStkWarehouseId := Self.ToStkWarehouseId;
  Result.Quantity := Self.Quantity;
  Result.Amount := Self.Amount;
  Result.AmountForeign := Self.AmountForeign;
  Result.Currency := Self.Currency;
  Result.IsOpening := Self.IsOpening;
  Result.Description := Self.Description;
  Result.DispatchId := Self.DispatchId;
  Result.ProductionId := Self.ProductionId;
  Result.InventoryName := Self.InventoryName;
  Result.FromWarehouseName := Self.FromWarehouseName;
  Result.ToWarehouseName := Self.ToWarehouseName;
  Result.InventoryCode := Self.InventoryCode;
end;

end.
