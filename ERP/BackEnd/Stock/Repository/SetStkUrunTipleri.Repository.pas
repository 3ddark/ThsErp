unit SetStkUrunTipleri.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, SetStkUrunTipleri;

type
  TSetStkUrunTipleriRepository = class(TRepository<TSetStkUrunTipleri>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSetStkUrunTipleriRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
