unit SysDay.Repository;

interface

uses SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
     FireDAC.Comp.Client, Entity, Repository, SysDay, FilterCriterion;

type
  TSysDayRepository = class(TRepository<TSysDay>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSysDayRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysDayRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TSysDay);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
