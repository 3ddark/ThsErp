unit SetAccTaxRate.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SetAccTaxRate, FilterCriterion;

type
  TSetAccTaxRateRepository = class(TRepository<TSetAccTaxRate>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSetAccTaxRateRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSetAccTaxRateRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TSetAccTaxRate);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
