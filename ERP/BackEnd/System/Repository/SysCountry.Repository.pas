unit SysCountry.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysCountry;

type
  TSysCountryRepository = class(TRepository<TSysCountry>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSysCountryRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
