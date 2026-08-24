unit SysRegion.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysRegion;

type
  TSysRegionRepository = class(TRepository<TSysRegion>)
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TSysRegion); override;
  end;

implementation

constructor TSysRegionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TSysRegionRepository.Delete(AModel: TSysRegion);
begin
  Delete(AModel.Id);
end;

end.
