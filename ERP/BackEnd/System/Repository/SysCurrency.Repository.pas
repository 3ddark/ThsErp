unit SysCurrency.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysCurrency;

type
  TSysCurrencyRepository = class(TRepository<TSysCurrency>)
  public
    constructor Create(AConnection: TFDConnection);
    destructor Destroy; override;
  end;

implementation

constructor TSysCurrencyRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

destructor TSysCurrencyRepository.Destroy;
begin
  //
  inherited;
end;

end.

