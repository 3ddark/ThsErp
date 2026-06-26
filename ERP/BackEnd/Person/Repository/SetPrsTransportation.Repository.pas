unit SetPrsTransportation.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, SetPrsTransportation;

type
  TSetPrsTransportationRepository = class(TRepository<TSetPrsTransportation>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSetPrsTransportationRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
