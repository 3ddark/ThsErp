unit SetStkBarkodUrunTuru.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SetStkBarkodUrunTuru;

type
  TSetStkBarkodUrunTuruRepository = class(TRepository<TSetStkBarkodUrunTuru>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSetStkBarkodUrunTuruRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
