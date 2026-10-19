unit AccExchangeRate;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

const
  ACC_RATE_SOURCE_MANUAL = 'MANUAL';
  ACC_RATE_SOURCE_TCMB = 'TCMB';

type
  [Table('acc_exchange_rate')]
  TAccExchangeRate = class(TEntity)
  private
    FRateDate: TDate;
    FCurrency: string;
    FRate: Currency;
    FForexSelling: Currency;
    FBanknoteBuying: Currency;
    FBanknoteSelling: Currency;
    FSource: string;
  public
    [Column('rate_date'), Required()]
    property RateDate: TDate read FRateDate write FRateDate;

    [Column('currency')]
    [MaxLength(3), Required(TLangKeys.TValidation.Required, True)]
    property Currency: string read FCurrency write FCurrency;

    // döviz alış (TCMB ForexBuying): belgelerin varsayılan kuru
    [Column('rate')]
    property Rate: Currency read FRate write FRate;

    [Column('forex_selling')]
    property ForexSelling: Currency read FForexSelling write FForexSelling;

    [Column('banknote_buying')]
    property BanknoteBuying: Currency read FBanknoteBuying write FBanknoteBuying;

    [Column('banknote_selling')]
    property BanknoteSelling: Currency read FBanknoteSelling write FBanknoteSelling;

    // MANUAL / TCMB (TCMB satırları her çekişte güncellenir; elle değiştirilen satır MANUAL olur)
    [Column('source')]
    [MaxLength(8)]
    property Source: string read FSource write FSource;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccExchangeRate;
  end;

implementation

constructor TAccExchangeRate.Create;
begin
  inherited;
  FSource := ACC_RATE_SOURCE_MANUAL;
end;

destructor TAccExchangeRate.Destroy;
begin
  inherited;
end;

function TAccExchangeRate.Clone: TAccExchangeRate;
begin
  Result := TAccExchangeRate.Create;
  Result.Id := Self.Id;
  Result.RateDate := Self.RateDate;
  Result.Currency := Self.Currency;
  Result.Rate := Self.Rate;
  Result.ForexSelling := Self.ForexSelling;
  Result.BanknoteBuying := Self.BanknoteBuying;
  Result.BanknoteSelling := Self.BanknoteSelling;
  Result.Source := Self.Source;
end;

end.
