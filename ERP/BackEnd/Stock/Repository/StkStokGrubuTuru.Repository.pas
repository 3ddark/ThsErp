unit StkStokGrubuTuru.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, StkStokGrubuTuru;

type
  TStkStokGrubuTuruRepository = class(TRepository<TStkStokGrubuTuru>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TStkStokGrubuTuruRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
