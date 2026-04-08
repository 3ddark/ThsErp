unit SysUomType.Repository;

interface

uses
  SysUtils, Classes, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysUomType;

type
  TSysUomTypeRepository = class(TRepository<TSysUomType>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSysUomTypeRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
