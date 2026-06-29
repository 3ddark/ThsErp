unit SetChFirmaTipleri.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SetChFirmaTipleri;

type
  TSetChFirmaTipleriRepository = class(TRepository<TSetChFirmaTipleri>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSetChFirmaTipleriRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
