unit SysDecimalPlace;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_decimal_place')]
  TSysDecimalPlace = class(TEntity)
  private
    FQuantity: SmallInt;
    FPrice: SmallInt;
    FTotal: SmallInt;
    FStockQuantity: SmallInt;
    FExchangeRate: SmallInt;
  public
    [Column('quantity')]
    property Quantity: SmallInt read FQuantity write FQuantity;

    [Column('price')]
    property Price: SmallInt read FPrice write FPrice;

    [Column('total')]
    property Total: SmallInt read FTotal write FTotal;

    [Column('stock_quantity')]
    property StockQuantity: SmallInt read FStockQuantity write FStockQuantity;

    [Column('exchange_rate')]
    property ExchangeRate: SmallInt read FExchangeRate write FExchangeRate;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysDecimalPlace.Create();
begin
  inherited;
  FQuantity := 2;
  FPrice := 2;
  FTotal := 2;
  FStockQuantity := 4;
  FExchangeRate := 4;
end;

destructor TSysDecimalPlace.Destroy;
begin
  inherited;
end;

end.
