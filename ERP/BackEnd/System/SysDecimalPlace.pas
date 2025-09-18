unit SysDecimalPlace;

interface

uses SysUtils, Classes, Types, BaseEntity;

type
  [TableName('sys_decimal_places')]
  TSysDecimalPlace = class(TEntity)
  private
    FQuantity: TEntityField<Word>;
    FPrice: TEntityField<Word>;
    FTotal: TEntityField<Word>;
    FStockQuantity: TEntityField<Word>;
    FExchangeRate: TEntityField<Word>;
  public
    property Quantity: TEntityField<Word> read FQuantity write FQuantity;
    property Price: TEntityField<Word> read FPrice write FPrice;
    property Total: TEntityField<Word> read FTotal write FTotal;
    property StockQuantity: TEntityField<Word> read FStockQuantity write FStockQuantity;
    property ExchangeRate: TEntityField<Word> read FExchangeRate write FExchangeRate;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysDecimalPlace.Create();
begin
  inherited;
  FQuantity := TEntityField<Word>.Create(Self, 'quantity');
  FPrice := TEntityField<Word>.Create(Self, 'price');
  FTotal := TEntityField<Word>.Create(Self, 'total');
  FStockQuantity := TEntityField<Word>.Create(Self, 'stock_quantity');
  FExchangeRate := TEntityField<Word>.Create(Self, 'exchange_rate');
end;

destructor TSysDecimalPlace.Destroy;
begin
  inherited;
end;

end.
