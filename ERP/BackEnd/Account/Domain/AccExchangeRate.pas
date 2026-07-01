unit AccExchangeRate;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes, SysCurrency;

type
  [Table('acc_exchange_rate')]
  TAccExchangeRate = class(TEntity)
  private
    FRateDate: TDateTime;
    FRate: Double;
    FCurrency: string;
    FCurrencyEntity: TSysCurrency;
  public
    [Column('rate_date'), Required()]
    property RateDate: TDateTime read FRateDate write FRateDate;

    [Column('rate'), Required()]
    property Rate: Double read FRate write FRate;

    [Column('currency'), MaxLength(3)]
    property Currency: string read FCurrency write FCurrency;

    [BelongsTo('currency', 'currency')]
    property CurrencyEntity: TSysCurrency read FCurrencyEntity write FCurrencyEntity;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TAccExchangeRate.Create();
begin
  inherited;
  FCurrencyEntity := TSysCurrency.Create;
end;

destructor TAccExchangeRate.Destroy;
begin
  if Assigned(FCurrencyEntity) then FreeAndNil(FCurrencyEntity);

  inherited;
end;

end.
