unit SysGridSort.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysGridSort, FilterCriterion;

type
  TSysGridSortRepository = class(TRepository<TSysGridSort>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSysGridSortRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysGridSortRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_sys_grid_sorts WHERE 1=1 ';
end;

end.
