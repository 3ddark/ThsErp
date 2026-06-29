unit SetChFirmaTuru.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SetChFirmaTuru;

type
  TSetChFirmaTuruRepository = class(TRepository<TSetChFirmaTuru>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSetChFirmaTuruRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
