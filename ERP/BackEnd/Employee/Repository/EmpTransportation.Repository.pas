unit EmpTransportation.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, EmpTransportation;

type
  TEmpTransportationRepository = class(TRepository<TEmpTransportation>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TEmpTransportationRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
