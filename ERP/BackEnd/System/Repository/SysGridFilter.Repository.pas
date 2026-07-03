unit SysGridFilter.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysGridFilter, FilterCriterion;

type
  TSysGridFilterRepository = class(TRepository<TSysGridFilter>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSysGridFilterRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysGridFilterRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_sys_grid_filters WHERE 1=1 ';
end;

end.
