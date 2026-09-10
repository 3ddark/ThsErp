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
    FSysCurrency: TSysCurrency;
  public
    [Column('rate_date'), Required()]
    property RateDate: TDateTime read FRateDate write FRateDate;

    [Column('rate'), Required()]
    property Rate: Double read FRate write FRate;

    [Column('currency'), MaxLength(3)]
    property Currency: string read FCurrency write FCurrency;

    [BelongsTo('Currency')]
    property SysCurrency: TSysCurrency read FSysCurrency write FSysCurrency;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccExchangeRate;
  end;

implementation

constructor TAccExchangeRate.Create();
begin
  inherited;
  FSysCurrency := nil;//TSysCurrency.Create;
end;

destructor TAccExchangeRate.Destroy;
begin
  FSysCurrency.Free;

  inherited;
end;

function TAccExchangeRate.Clone: TAccExchangeRate;
begin
  Result := TAccExchangeRate.Create;
  Result.RateDate := Self.RateDate;
  Result.Rate := Self.Rate;
  Result.Currency := Self.Currency;

  if Assigned(Self.SysCurrency) then
    Result.SysCurrency := Self.SysCurrency.Clone;
end;

end.
