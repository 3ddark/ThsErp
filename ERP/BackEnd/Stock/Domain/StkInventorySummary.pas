unit StkInventorySummary;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('stk_inventory_summary')]
  TStkInventorySummary = class(TEntity)
  private
    FStkInventoryId: Int64;
    FCurrentQuantity: Currency;
    FAverageCost: Currency;
    FOpeningQuantity: Currency;
    FOpeningPrice: Currency;
    FOpeningAmount: Currency;
    FIncomingQuantity: Currency;
    FIncomingAmount: Currency;
    FOutgoingQuantity: Currency;
    FOutgoingAmount: Currency;
    FLastBuyDate: TDate;
    FLastBuyQuantity: Currency;
    FLastBuyPrice: Currency;
    FLastBuyCurrency: string;
    FLastBuyExchangeRate: Currency;

    // View (vw_stk_inventory_summary) okunabilir alanları
    FInventoryName: string;
    FInventoryCode: string;
  public
    [Column('stk_inventory_id')]
    property StkInventoryId: Int64 read FStkInventoryId write FStkInventoryId;

    [Column('current_quantity')]
    property CurrentQuantity: Currency read FCurrentQuantity write FCurrentQuantity;

    [Column('average_cost')]
    property AverageCost: Currency read FAverageCost write FAverageCost;

    [Column('opening_quantity')]
    property OpeningQuantity: Currency read FOpeningQuantity write FOpeningQuantity;

    [Column('opening_price')]
    property OpeningPrice: Currency read FOpeningPrice write FOpeningPrice;

    [Column('opening_amount')]
    property OpeningAmount: Currency read FOpeningAmount write FOpeningAmount;

    [Column('incoming_quantity')]
    property IncomingQuantity: Currency read FIncomingQuantity write FIncomingQuantity;

    [Column('incoming_amount')]
    property IncomingAmount: Currency read FIncomingAmount write FIncomingAmount;

    [Column('outgoing_quantity')]
    property OutgoingQuantity: Currency read FOutgoingQuantity write FOutgoingQuantity;

    [Column('outgoing_amount')]
    property OutgoingAmount: Currency read FOutgoingAmount write FOutgoingAmount;

    [Column('last_buy_date')]
    property LastBuyDate: TDate read FLastBuyDate write FLastBuyDate;

    [Column('last_buy_quantity')]
    property LastBuyQuantity: Currency read FLastBuyQuantity write FLastBuyQuantity;

    [Column('last_buy_price')]
    property LastBuyPrice: Currency read FLastBuyPrice write FLastBuyPrice;

    [Column('last_buy_currency')]
    [MaxLength(3)]
    property LastBuyCurrency: string read FLastBuyCurrency write FLastBuyCurrency;

    [Column('last_buy_exchange_rate')]
    property LastBuyExchangeRate: Currency read FLastBuyExchangeRate write FLastBuyExchangeRate;

    [NotMapped]
    property InventoryName: string read FInventoryName write FInventoryName;

    [NotMapped]
    property InventoryCode: string read FInventoryCode write FInventoryCode;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TStkInventorySummary;
  end;

implementation

constructor TStkInventorySummary.Create;
begin
  inherited;
end;

destructor TStkInventorySummary.Destroy;
begin
  inherited;
end;

function TStkInventorySummary.Clone: TStkInventorySummary;
begin
  Result := TStkInventorySummary.Create;
  Result.Id := Self.Id;
  Result.StkInventoryId := Self.StkInventoryId;
  Result.CurrentQuantity := Self.CurrentQuantity;
  Result.AverageCost := Self.AverageCost;
  Result.OpeningQuantity := Self.OpeningQuantity;
  Result.OpeningPrice := Self.OpeningPrice;
  Result.OpeningAmount := Self.OpeningAmount;
  Result.IncomingQuantity := Self.IncomingQuantity;
  Result.IncomingAmount := Self.IncomingAmount;
  Result.OutgoingQuantity := Self.OutgoingQuantity;
  Result.OutgoingAmount := Self.OutgoingAmount;
  Result.LastBuyDate := Self.LastBuyDate;
  Result.LastBuyQuantity := Self.LastBuyQuantity;
  Result.LastBuyPrice := Self.LastBuyPrice;
  Result.LastBuyCurrency := Self.LastBuyCurrency;
  Result.LastBuyExchangeRate := Self.LastBuyExchangeRate;
  Result.InventoryName := Self.InventoryName;
  Result.InventoryCode := Self.InventoryCode;
end;

end.
