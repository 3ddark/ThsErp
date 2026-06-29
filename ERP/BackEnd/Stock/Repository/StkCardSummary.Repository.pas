unit StkCardSummary.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, StkCardSummary;

type
  TStkCardSummaryRepository = class(TRepository<TStkCardSummary>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TStkCardSummaryRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
