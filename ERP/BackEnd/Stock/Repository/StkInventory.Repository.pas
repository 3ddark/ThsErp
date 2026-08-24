unit StkInventory.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, StkInventory;

type
  TStkInventoryRepository = class(TRepository<TStkInventory>)
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TStkInventory); override;
  end;

implementation

constructor TStkInventoryRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TStkInventoryRepository.Delete(AModel: TStkInventory);
begin
  Delete(AModel.Id);
end;

end.
