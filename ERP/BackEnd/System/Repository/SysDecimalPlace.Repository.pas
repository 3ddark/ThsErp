unit SysDecimalPlace.Repository;interfaceuses SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,     FireDAC.Comp.Client, Entity, Repository, SysDecimalPlace, FilterCriterion;type  TSysDecimalPlaceRepository = class(TRepository<TSysDecimalPlace>)
  public    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;  end;implementationconstructor TSysDecimalPlaceRepository.Create(AConnection: TFDConnection);
begin  inherited Create(AConnection);
end;function TSysDecimalPlaceRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;var LTableName: string;
begin  LTableName := GetTableName(TSysDecimalPlace);
  Result := TFDQuery.Create(nil);  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';end;end.
