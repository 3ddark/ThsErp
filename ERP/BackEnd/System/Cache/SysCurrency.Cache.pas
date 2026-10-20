unit SysCurrency.Cache;

// Para birimi simgeleri (sys_currency.symbol: TRY -> ₺, USD -> $ ...) önbelleği: toplam / özet metinlerinde kod
// yerine simge. İlk kullanımda AppContext bağlantısıyla okunur; para birimi kaydedilince / silinince Invalidate.
// Simgesi olmayan (ya da bilinmeyen) kod olduğu gibi döner.

interface

uses
  System.SysUtils, System.Generics.Collections, Data.DB, FireDAC.Comp.Client;

type
  TCurrencySymbols = class
  strict private
    class var FSymbols: TDictionary<string, string>;
    class var FLoaded: Boolean;
    class procedure EnsureLoaded; static;
  public
    class constructor Create;
    class destructor Destroy;
    class procedure Load(AConnection: TFDConnection); static;
    class procedure Invalidate; static;
    // 'USD' -> '$'; boş / bilinmeyen kod aynen
    class function Symbol(const ACurrency: string): string; static;
    // '1.200,00 $' (simge yoksa '1.200,00 USD'; kod boşsa yalnız tutar)
    class function FormatAmount(AValue: Double; const ACurrency, AFormat: string): string; static;
  end;

implementation

uses
  AppContext, Logger;

class constructor TCurrencySymbols.Create;
begin
  FSymbols := TDictionary<string, string>.Create;
end;

class destructor TCurrencySymbols.Destroy;
begin
  FSymbols.Free;
end;

class procedure TCurrencySymbols.Load(AConnection: TFDConnection);
var
  Q: TFDQuery;
begin
  FSymbols.Clear;
  FLoaded := True;
  if not Assigned(AConnection) or not AConnection.Connected then
    Exit;
  Q := TFDQuery.Create(nil);
  try
    try
      Q.Connection := AConnection;
      Q.SQL.Text := 'SELECT currency, symbol FROM public.sys_currency';
      Q.Open;
      while not Q.Eof do
      begin
        if Trim(Q.FieldByName('symbol').AsString) <> '' then
          FSymbols.AddOrSetValue(UpperCase(Q.FieldByName('currency').AsString), Trim(Q.FieldByName('symbol').AsString));
        Q.Next;
      end;
    except
      on E: Exception do
        GLogger.ErrorFmt('TCurrencySymbols.Load error: %s', [E.Message]);
    end;
  finally
    Q.Free;
  end;
end;

class procedure TCurrencySymbols.Invalidate;
begin
  FLoaded := False;
end;

class procedure TCurrencySymbols.EnsureLoaded;
begin
  if FLoaded or not TAppContext.IsInitialized then
    Exit;
  Load(TAppContext.Instance.DBConnection);
end;

class function TCurrencySymbols.Symbol(const ACurrency: string): string;
begin
  Result := ACurrency;
  if Trim(ACurrency) = '' then
    Exit;
  EnsureLoaded;
  if not FSymbols.TryGetValue(UpperCase(Trim(ACurrency)), Result) then
    Result := ACurrency;
end;

class function TCurrencySymbols.FormatAmount(AValue: Double; const ACurrency, AFormat: string): string;
begin
  Result := FormatFloat(AFormat, AValue);
  if Trim(ACurrency) <> '' then
    Result := Result + ' ' + Symbol(ACurrency);
end;

end.
