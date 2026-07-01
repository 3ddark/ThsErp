unit SysResourceGroup.Repository;

interface

uses
  SysUtils, Classes, Types, DB, System.Generics.Collections,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  Entity, Repository, SysResourceGroup, FilterCriterion;

type
  TSysResourceGroupRepository = class(TRepository<TSysResourceGroup>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSysResourceGroupRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysResourceGroupRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TSysResourceGroup);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
