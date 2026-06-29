unit SetStkBarkodSeriNoTuru.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, SetStkBarkodSeriNoTuru;

type
  TSetStkBarkodSeriNoTuruRepository = class(TRepository<TSetStkBarkodSeriNoTuru>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSetStkBarkodSeriNoTuruRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
