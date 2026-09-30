unit AccExchangeRate;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('acc_exchange_rate')]
  TAccExchangeRate = class(TEntity)
  private
    FRateDate: TDate;
    FCurrency: string;
    FRate: Currency;
  public
    [Column('rate_date')]
    property RateDate: TDate read FRateDate write FRateDate;

    [Column('currency')]
    [MaxLength(3), Required(TLangKeys.TValidation.Required, True)]
    property Currency: string read FCurrency write FCurrency;

    [Column('rate')]
    property Rate: Currency read FRate write FRate;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccExchangeRate;
  end;

implementation

constructor TAccExchangeRate.Create;
begin
  inherited;
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
end;

end.
