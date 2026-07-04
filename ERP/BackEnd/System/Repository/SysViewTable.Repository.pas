unit SysViewTable.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysViewTable, FilterCriterion;

type
  TSysViewTableRepository = class(TRepository<TSysViewTable>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSysViewTableRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysViewTableRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  LTableName: string;
begin
  LTableName := GetTableName(TSysViewTable);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + LTableName + ' WHERE 1=1 ';
end;

end.
