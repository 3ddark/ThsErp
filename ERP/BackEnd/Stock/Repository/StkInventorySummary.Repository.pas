unit StkInventorySummary.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, StkInventorySummary;

type
  TStkInventorySummaryRepository = class(TRepository<TStkInventorySummary>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TStkInventorySummaryRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
