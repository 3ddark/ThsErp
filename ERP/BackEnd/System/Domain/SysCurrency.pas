unit SysCurrency;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_currency')]
  TSysCurrency = class(TEntity)
  private
    FCurrency: string;
    FSymbol: string;
    FDescription: string;
  public
    [Column('currency'), MaxLength(3), Required()]
    property Currency: string read FCurrency write FCurrency;

    [Column('symbol'), MaxLength(3), Required()]
    property Symbol: string read FSymbol write FSymbol;

    [Column('description')]
    property Description: string read FDescription write FDescription;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSysCurrency;
  end;

implementation

constructor TSysCurrency.Create();
begin
  inherited;
end;

destructor TSysCurrency.Destroy;
begin
  inherited;
end;

function TSysCurrency.Clone: TSysCurrency;
begin
  Result := TSysCurrency.Create;
  Result.Currency := Self.Currency;
  Result.Symbol := Self.Symbol;
  Result.Description := Self.Description;
end;

end.
