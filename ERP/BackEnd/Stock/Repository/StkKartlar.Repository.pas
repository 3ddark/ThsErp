unit StkKartlar.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, StkKartlar;

type
  TStkKartRepository = class(TRepository<TStkKart>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TStkKartRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
