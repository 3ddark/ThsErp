unit StkInventorySummary;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('stk_inventory_summary')]
  TStkInventorySummary = class(TEntity)
  private
    FInventoryID: Int64;
    FCurrentQuantity: Currency;
    FAverageCost: Currency;
    FOpeningPrice: Currency;
    FOpeningQuantity: Currency;
    FOpeningAmount: Currency;
    FIncomingQuantity: Currency;
    FIncomingAmount: Currency;
    FOutgoingQuantity: Currency;
    FOutgoingAmount: Currency;
    FLastBuyPrice: Currency;
    FLastBuyMoney: string;
    FLastBuyDate: TDate;
    FLastBuyQuantity: Currency;
    FLastBuyExchangeRate: Currency;
  public
    [Column('inventory_id')]
    Property InventoryID: Int64 read FInventoryID write FInventoryID;

    [Column('current_quantity')]
    Property CurrentQuantity: Currency read FCurrentQuantity write FCurrentQuantity;

    [Column('average_cost')]
    Property AverageCost: Currency read FAverageCost write FAverageCost;

    [Column('opening_price')]
    Property OpeningPrice: Currency read FOpeningPrice write FOpeningPrice;

    [Column('opening_quantity')]
    Property OpeningQuantity: Currency read FOpeningQuantity write FOpeningQuantity;

    [Column('opening_amount')]
    Property OpeningAmount: Currency read FOpeningAmount write FOpeningAmount;

    [Column('incoming_quantity')]
    Property IncomingQuantity: Currency read FIncomingQuantity write FIncomingQuantity;

    [Column('incoming_amount')]
    Property IncomingAmount: Currency read FIncomingAmount write FIncomingAmount;

    [Column('outgoing_quantity')]
    Property OutgoingQuantity: Currency read FOutgoingQuantity write FOutgoingQuantity;

    [Column('outgoing_amount')]
    Property OutgoingAmount: Currency read FOutgoingAmount write FOutgoingAmount;

    [Column('last_buy_price')]
    Property LastBuyPrice: Currency read FLastBuyPrice write FLastBuyPrice;

    [Column('last_buy_money')]
    Property LastBuyMoney: string read FLastBuyMoney write FLastBuyMoney;

    [Column('last_buy_date')]
    Property LastBuyDate: TDate read FLastBuyDate write FLastBuyDate;

    [Column('last_buy_quantity')]
    Property LastBuyQuantity: Currency read FLastBuyQuantity write FLastBuyQuantity;

    [Column('last_buy_exchange_rate')]
    Property LastBuyExchangeRate: Currency read FLastBuyExchangeRate write FLastBuyExchangeRate;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TStkInventorySummary.Create;
begin
  inherited;
  FCurrentQuantity := 0;
  FAverageCost := 0;
  FOpeningPrice := 0;
  FOpeningQuantity := 0;
  FOpeningAmount := 0;
  FIncomingQuantity := 0;
  FIncomingAmount := 0;
  FOutgoingQuantity := 0;
  FOutgoingAmount := 0;
  FLastBuyPrice := 0;
  FLastBuyMoney := '';
  FLastBuyDate := Date;
  FLastBuyQuantity := 0;
  FLastBuyExchangeRate := 0;
end;

destructor TStkInventorySummary.Destroy;
begin
  inherited;
end;

end.
