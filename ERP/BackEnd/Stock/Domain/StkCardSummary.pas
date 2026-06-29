unit StkCardSummary;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('stk_card_summaries')]
  TStkCardSummary = class(TEntity)
  private
    FStkCardID: Int64;
    FStockQuantity: Double;
    FAverageCost: Double;
    FPeriodBeginningPrice: Double;
    FPeriodBeginningQuantity: Double;
    FPeriodBeginningAmount: Double;
    FIncomingQuantity: Double;
    FIncomingAmount: Double;
    FOutgoingQuantity: Double;
    FOutgoingAmount: Double;
    FLastBuyPrice: Double;
    FLastBuyMoney: string;
    FLastBuyDate: TDate;
    FLastBuyQuantity: Double;
    FLastBuyExchangeRate: Double;
    FLastBuyExchangeMoney: string;
  public
    [Column('stk_card_id')]
    Property StkCardID: Int64 read FStkCardID write FStkCardID;

    [Column('stock_quantity', [], 18, 6)]
    Property StockQuantity: Double read FStockQuantity write FStockQuantity;

    [Column('average_cost', [], 18, 6)]
    Property AverageCost: Double read FAverageCost write FAverageCost;

    [Column('period_beginning_price', [], 18, 6)]
    Property PeriodBeginningPrice: Double read FPeriodBeginningPrice write FPeriodBeginningPrice;

    [Column('period_beginning_quantity', [], 18, 6)]
    Property PeriodBeginningQuantity: Double read FPeriodBeginningQuantity write FPeriodBeginningQuantity;

    [Column('period_beginning_amount', [], 18, 6)]
    Property PeriodBeginningAmount: Double read FPeriodBeginningAmount write FPeriodBeginningAmount;

    [Column('incoming_quantity', [], 18, 6)]
    Property IncomingQuantity: Double read FIncomingQuantity write FIncomingQuantity;

    [Column('incoming_amount', [], 18, 6)]
    Property IncomingAmount: Double read FIncomingAmount write FIncomingAmount;

    [Column('outgoing_quantity', [], 18, 6)]
    Property OutgoingQuantity: Double read FOutgoingQuantity write FOutgoingQuantity;

    [Column('outgoing_amount', [], 18, 6)]
    Property OutgoingAmount: Double read FOutgoingAmount write FOutgoingAmount;

    [Column('last_buy_price', [], 18, 6)]
    Property LastBuyPrice: Double read FLastBuyPrice write FLastBuyPrice;

    [Column('last_buy_money')]
    Property LastBuyMoney: string read FLastBuyMoney write FLastBuyMoney;

    [Column('last_buy_date')]
    Property LastBuyDate: TDate read FLastBuyDate write FLastBuyDate;

    [Column('last_buy_quantity', [], 18, 6)]
    Property LastBuyQuantity: Double read FLastBuyQuantity write FLastBuyQuantity;

    [Column('last_buy_exchange_rate', [], 18, 6)]
    Property LastBuyExchangeRate: Double read FLastBuyExchangeRate write FLastBuyExchangeRate;

    [Column('last_buy_exchange_money')]
    Property LastBuyExchangeMoney: string read FLastBuyExchangeMoney write FLastBuyExchangeMoney;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TStkCardSummary.Create;
begin
  inherited;
  FStockQuantity := 0;
  FAverageCost := 0;
  FPeriodBeginningPrice := 0;
  FPeriodBeginningQuantity := 0;
  FPeriodBeginningAmount := 0;
  FIncomingQuantity := 0;
  FIncomingAmount := 0;
  FOutgoingQuantity := 0;
  FOutgoingAmount := 0;
  FLastBuyQuantity := 0;
  FLastBuyExchangeRate := 0;
end;

destructor TStkCardSummary.Destroy;
begin
  inherited;
end;

end.
