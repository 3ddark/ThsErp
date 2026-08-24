unit StkInventorySummary.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, StkInventorySummary;

type
  TStkInventorySummaryRepository = class(TRepository<TStkInventorySummary>)
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TStkInventorySummary); override;
  end;

implementation

constructor TStkInventorySummaryRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TStkInventorySummaryRepository.Delete(AModel: TStkInventorySummary);
begin
  Delete(AModel.Id);
end;

end.
