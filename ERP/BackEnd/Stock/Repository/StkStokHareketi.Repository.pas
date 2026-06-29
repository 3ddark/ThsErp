unit StkStokHareketi.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, StkStokHareketi;

type
  TStkStokHareketiRepository = class(TRepository<TStkStokHareketi>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TStkStokHareketiRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
