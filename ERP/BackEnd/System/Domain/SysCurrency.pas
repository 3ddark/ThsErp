unit SysCurrency;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_currencies')]
  TSysCurrency = class(TEntity)
  private
    FCurrency: string;
    FSymbol: string;
    FDescription: string;
  public
    [Column('currency')]
    property Currency: string read FCurrency write FCurrency;

    [Column('symbol')]
    property Symbol: string read FSymbol write FSymbol;

    [Column('description')]
    property Description: string read FDescription write FDescription;

    constructor Create(); override;
    destructor Destroy; override;
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

end.
