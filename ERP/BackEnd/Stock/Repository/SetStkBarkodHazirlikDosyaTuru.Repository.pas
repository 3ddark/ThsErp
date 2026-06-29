unit SetStkBarkodHazirlikDosyaTuru.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, SetStkBarkodHazirlikDosyaTuru;

type
  TSetStkBarkodHazirlikDosyaTuruRepository = class(TRepository<TSetStkBarkodHazirlikDosyaTuru>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSetStkBarkodHazirlikDosyaTuruRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
