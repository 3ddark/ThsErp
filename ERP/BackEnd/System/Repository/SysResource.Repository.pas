unit SysResource.Repository;

interface

uses
  SysUtils, Classes, Types, DB, System.Generics.Collections,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  Entity, Repository, SysResource, FilterCriterion;

type
  TSysResourceRepository = class(TRepository<TSysResource>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSysResourceRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysResourceRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TSysResource);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
