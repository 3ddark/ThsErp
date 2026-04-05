unit SysCity.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysCity;

type
  TSysCityRepository = class(TRepository<TSysCity>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSysCityRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
