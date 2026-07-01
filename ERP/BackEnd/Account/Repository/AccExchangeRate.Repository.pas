unit AccExchangeRate.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, AccExchangeRate, FilterCriterion;

type
  TAccExchangeRateRepository = class(TRepository<TAccExchangeRate>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TAccExchangeRateRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TAccExchangeRateRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TAccExchangeRate);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
