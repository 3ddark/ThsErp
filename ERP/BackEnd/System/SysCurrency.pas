unit SysCurrency;

interface

uses SysUtils, Classes, Types, BaseEntity;

type
  [TableName('sys_currencies')]
  TSysCurrency = class(TEntity)
  private
    FCurrency: TEntityField<string>;
    FSymbol: TEntityField<string>;
    FDescription: TEntityField<string>;
  public
    property Currency: TEntityField<string> read FCurrency write FCurrency;
    property FSymbo: TEntityField<string> read FSymbol write FSymbol;
    property Description: TEntityField<string> read FDescription write FDescription;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysCurrency.Create();
begin
  inherited;
  FCurrency := TEntityField<string>.Create(Self, 'currency');
  FSymbol := TEntityField<string>.Create(Self, 'symbol');
  FDescription := TEntityField<string>.Create(Self, 'description');
end;

destructor TSysCurrency.Destroy;
begin
  inherited;
end;

end.
