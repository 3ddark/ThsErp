unit SetStkBarkodTezgah.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SetStkBarkodTezgah;

type
  TSetStkBarkodTezgahRepository = class(TRepository<TSetStkBarkodTezgah>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSetStkBarkodTezgahRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
