unit StkInventory.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, StkInventory;

type
  TStkInventoryRepository = class(TRepository<TStkInventory>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TStkInventoryRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
