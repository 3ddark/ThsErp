unit StkTransaction;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('stk_transaction')]
  TStkTransaction = class(TEntity)
  private
    FSku: string;
    FQuantity: Double;
    FAmount: Double;
    FAmountForeign: Double;
    FCurrency: string;
    FDirection: SmallInt;
    FTransactionDate: TDateTime;
    FFromWarehouseId: Int64;
    FToWarehouseId: Int64;
    FIsOpening: Boolean;
    FDescription: string;
    FDispatchId: Int64;
    FProductionId: Int64;
  public
    [Column('sku'), MaxLength(64), Required()]
    Property Sku: string read FSku write FSku;

    [Column('quantity')]
    Property Quantity: Double read FQuantity write FQuantity;

    [Column('amount')]
    Property Amount: Double read FAmount write FAmount;

    [Column('amount_foreign')]
    Property AmountForeign: Double read FAmountForeign write FAmountForeign;

    [Column('currency'), MaxLength(8)]
    Property Currency: string read FCurrency write FCurrency;

    [Column('direction')]
    Property Direction: SmallInt read FDirection write FDirection;

    [Column('transaction_date')]
    Property TransactionDate: TDateTime read FTransactionDate write FTransactionDate;

    [Column('from_warehouse')]
    Property FromWarehouseId: Int64 read FFromWarehouseId write FFromWarehouseId;

    [Column('to_warehouse')]
    Property ToWarehouseId: Int64 read FToWarehouseId write FToWarehouseId;

    [Column('is_opening')]
    Property IsOpening: Boolean read FIsOpening write FIsOpening;

    [Column('description'), MaxLength(256)]
    Property Description: string read FDescription write FDescription;

    [Column('dispatch_id')]
    Property DispatchId: Int64 read FDispatchId write FDispatchId;

    [Column('production_id')]
    Property ProductionId: Int64 read FProductionId write FProductionId;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TStkTransaction.Create;
begin
  inherited;
  FIsOpening := False;
end;

destructor TStkTransaction.Destroy;
begin
  inherited;
end;

end.
