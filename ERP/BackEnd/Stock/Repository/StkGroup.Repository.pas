unit StkGroup.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, StkGroup;

type
  TStkGroupRepository = class(TRepository<TStkGroup>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TStkGroupRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
