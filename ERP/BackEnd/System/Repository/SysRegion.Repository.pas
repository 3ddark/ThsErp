unit SysRegion.Repository;

interface

uses
  SysUtils, Classes, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysRegion;

type
  TSysRegionRepository = class(TRepository<TSysRegion>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSysRegionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
