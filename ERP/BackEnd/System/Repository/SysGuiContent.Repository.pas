unit SysGuiContent.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysGuiContent, FilterCriterion;

type
  TSysGuiContentRepository = class(TRepository<TSysGridContents>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSysGuiContentRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysGuiContentRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TSysGridContents);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + LTableName + ' WHERE 1=1 ';
end;

end.
