unit SysUom.Repository;

interface

uses
  SysUtils, Classes, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysUom;

type
  TSysUomRepository = class(TRepository<TSysUom>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSysUomRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
