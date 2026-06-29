unit SetStkHareketTipi.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, SetStkHareketTipi;

type
  TSetStkHareketTipiRepository = class(TRepository<TSetStkHareketTipi>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSetStkHareketTipiRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
