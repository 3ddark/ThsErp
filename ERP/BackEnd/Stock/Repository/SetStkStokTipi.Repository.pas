unit SetStkStokTipi.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, SetStkStokTipi;

type
  TSetStkStokTipiRepository = class(TRepository<TSetStkStokTipi>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSetStkStokTipiRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
