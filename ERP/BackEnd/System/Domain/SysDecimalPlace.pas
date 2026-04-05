unit SysDecimalPlace;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_decimal_places')]
  TSysDecimalPlace = class(TEntity)
  private
    FQuantity: Word;
    FPrice: Word;
    FTotal: Word;
    FStockQuantity: Word;
    FExchangeRate: Word;
  public
    [Column('quantity')]
    property Quantity: Word read FQuantity write FQuantity;

    [Column('price')]
    property Price: Word read FPrice write FPrice;

    [Column('total')]
    property Total: Word read FTotal write FTotal;

    [Column('stock_quantity')]
    property StockQuantity: Word read FStockQuantity write FStockQuantity;

    [Column('exchange_rate')]
    property ExchangeRate: Word read FExchangeRate write FExchangeRate;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysDecimalPlace.Create();
begin
  inherited;
end;

destructor TSysDecimalPlace.Destroy;
begin
  inherited;
end;

end.
