unit StkInventory.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, StkInventory;

type
  TStkKartRepository = class(TRepository<TStkInventory>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TStkKartRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
