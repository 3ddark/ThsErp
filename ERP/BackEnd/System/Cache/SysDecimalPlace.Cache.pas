unit SysDecimalPlace.Cache;

// sys_decimal_place (tek satır) ondalık hane ayarlarının önbelleği: miktar, fiyat, tutar, stok miktarı, kur.
// İlk kullanımda AppContext bağlantısıyla okunur; ayar kaydedilince Invalidate (bir sonraki kullanımda yeniden okunur).
// Satır / bağlantı yoksa varsayılanlar. Değerler saklanabilen haneye sınırlanır: entity alanları Currency (4 hane),
// tutar kolonları numeric(18,2).

interface

uses
  System.SysUtils, System.StrUtils, System.Math, Data.DB, FireDAC.Comp.Client;

type
  TDecimalPlaces = class
  public
    const
      MAX_DIGITS = 4;
      MAX_TOTAL_DIGITS = 2;
      DEFAULT_QUANTITY = 2;
      DEFAULT_PRICE = 2;
      DEFAULT_TOTAL = 2;
      DEFAULT_STOCK_QUANTITY = 4;
      DEFAULT_EXCHANGE_RATE = 4;
  strict private
    class var FLoaded: Boolean;
    class var FQuantity: Integer;
    class var FPrice: Integer;
    class var FTotal: Integer;
    class var FStockQuantity: Integer;
    class var FExchangeRate: Integer;
    class procedure SetDefaults; static;
    class procedure EnsureLoaded; static;
  public
    class constructor Create;
    class procedure Load(AConnection: TFDConnection); static;
    class procedure Invalidate; static;

    class function Quantity: Integer; static;
    class function Price: Integer; static;
    class function Total: Integer; static;
    class function StockQuantity: Integer; static;
    class function ExchangeRate: Integer; static;

    // '#,##0.00' (0 hane: '#,##0')
    class function DisplayFormat(ADigits: Integer): string; static;
    class function TotalFormat: string; static;
    // Yarım değer sıfırdan uzağa (Round bankacı yuvarlaması yapar); Currency üzerinde tam sayı aritmetiği
    class function RoundTo(AValue: Currency; ADigits: Integer): Currency; static;
    class function RoundTotal(AValue: Currency): Currency; static;
    class function RoundPrice(AValue: Currency): Currency; static;
    // Kolon adına göre hane (eşleşmezse -1): *quantity -> miktar (stk_ görünümlerinde stok miktarı), *price / *cost ->
    // fiyat, *amount* -> tutar, exchange_rate / usd_rate / eur_rate / rate -> kur. Yüzde oranları (discount_rate,
    // vat_rate ...) eşleşmez.
    class function DigitsForField(const AViewName, AFieldName: string): Integer; static;
  end;

implementation

uses
  AppContext, Logger;

class constructor TDecimalPlaces.Create;
begin
  SetDefaults;
end;

class procedure TDecimalPlaces.SetDefaults;
begin
  FQuantity := DEFAULT_QUANTITY;
  FPrice := DEFAULT_PRICE;
  FTotal := DEFAULT_TOTAL;
  FStockQuantity := DEFAULT_STOCK_QUANTITY;
  FExchangeRate := DEFAULT_EXCHANGE_RATE;
end;

class procedure TDecimalPlaces.Load(AConnection: TFDConnection);
var
  Q: TFDQuery;
begin
  SetDefaults;
  FLoaded := True;
  if not Assigned(AConnection) or not AConnection.Connected then
    Exit;
  Q := TFDQuery.Create(nil);
  try
    try
      Q.Connection := AConnection;
      Q.SQL.Text := 'SELECT quantity, price, total, stock_quantity, exchange_rate FROM public.sys_decimal_place ORDER BY id LIMIT 1';
      Q.Open;
      if not Q.IsEmpty then
      begin
        FQuantity := EnsureRange(Q.FieldByName('quantity').AsInteger, 0, MAX_DIGITS);
        FPrice := EnsureRange(Q.FieldByName('price').AsInteger, 0, MAX_DIGITS);
        FTotal := EnsureRange(Q.FieldByName('total').AsInteger, 0, MAX_TOTAL_DIGITS);
        FStockQuantity := EnsureRange(Q.FieldByName('stock_quantity').AsInteger, 0, MAX_DIGITS);
        FExchangeRate := EnsureRange(Q.FieldByName('exchange_rate').AsInteger, 0, MAX_DIGITS);
      end;
    except
      on E: Exception do
        GLogger.ErrorFmt('TDecimalPlaces.Load error: %s', [E.Message]);
    end;
  finally
    Q.Free;
  end;
end;

class procedure TDecimalPlaces.Invalidate;
begin
  FLoaded := False;
end;

class procedure TDecimalPlaces.EnsureLoaded;
begin
  if FLoaded or not TAppContext.IsInitialized then
    Exit;
  Load(TAppContext.Instance.DBConnection);
end;

class function TDecimalPlaces.Quantity: Integer;
begin
  EnsureLoaded;
  Result := FQuantity;
end;

class function TDecimalPlaces.Price: Integer;
begin
  EnsureLoaded;
  Result := FPrice;
end;

class function TDecimalPlaces.Total: Integer;
begin
  EnsureLoaded;
  Result := FTotal;
end;

class function TDecimalPlaces.StockQuantity: Integer;
begin
  EnsureLoaded;
  Result := FStockQuantity;
end;

class function TDecimalPlaces.ExchangeRate: Integer;
begin
  EnsureLoaded;
  Result := FExchangeRate;
end;

class function TDecimalPlaces.DisplayFormat(ADigits: Integer): string;
begin
  if ADigits > 0 then
    Result := '#,##0.' + StringOfChar('0', ADigits)
  else
    Result := '#,##0';
end;

class function TDecimalPlaces.TotalFormat: string;
begin
  Result := DisplayFormat(Total);
end;

class function TDecimalPlaces.RoundTo(AValue: Currency; ADigits: Integer): Currency;
var
  LScaled, LDivisor, LRemainder: Int64;
begin
  ADigits := EnsureRange(ADigits, 0, MAX_DIGITS);
  if ADigits = MAX_DIGITS then
    Exit(AValue);
  // Currency = Int64 x 10^-4
  LDivisor := Round(IntPower(10, MAX_DIGITS - ADigits));
  LScaled := PInt64(@AValue)^;
  LRemainder := LScaled mod LDivisor;
  LScaled := LScaled - LRemainder;
  if Abs(LRemainder) * 2 >= LDivisor then
    if LRemainder > 0 then
      Inc(LScaled, LDivisor)
    else
      Dec(LScaled, LDivisor);
  PInt64(@Result)^ := LScaled;
end;

class function TDecimalPlaces.RoundTotal(AValue: Currency): Currency;
begin
  Result := RoundTo(AValue, Total);
end;

class function TDecimalPlaces.RoundPrice(AValue: Currency): Currency;
begin
  Result := RoundTo(AValue, Price);
end;

class function TDecimalPlaces.DigitsForField(const AViewName, AFieldName: string): Integer;
var
  LName: string;
begin
  LName := LowerCase(AFieldName);
  if EndsText('quantity', LName) then
  begin
    if StartsText('vw_stk_', LowerCase(AViewName)) or StartsText('stk_', LowerCase(AViewName)) then
      Result := StockQuantity
    else
      Result := Quantity;
  end
  else if EndsText('price', LName) or EndsText('_cost', LName) then
    Result := Price
  else if ContainsText(LName, 'amount') then
    Result := Total
  else if (LName = 'rate') or (LName = 'exchange_rate') or (LName = 'usd_rate') or (LName = 'eur_rate') then
    Result := ExchangeRate
  else
    Result := -1;
end;

end.
