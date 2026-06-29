unit StkWarehouse.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, StkWarehouse;

type
  TStkWarehouseRepository = class(TRepository<TStkWarehouse>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TStkWarehouseRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
