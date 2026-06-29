unit StkKartCinsBilgileri.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, StkKartCinsBilgileri;

type
  TStkKartCinsBilgileriRepository = class(TRepository<TStkKartCinsBilgileri>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TStkKartCinsBilgileriRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
