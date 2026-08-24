unit StkCardSummary.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, StkCardSummary;

type
  TStkCardSummaryRepository = class(TRepository<TStkCardSummary>)
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TStkCardSummary); override;
  end;

implementation

constructor TStkCardSummaryRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TStkCardSummaryRepository.Delete(AModel: TStkCardSummary);
begin
  Delete(AModel.Id);
end;

end.
