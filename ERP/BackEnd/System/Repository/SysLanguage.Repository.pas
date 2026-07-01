unit SysLanguage.Repository;

interface

uses SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
     FireDAC.Comp.Client, Entity, Repository, SysLanguage, FilterCriterion;

type
  TSysLanguageRepository = class(TRepository<TSysLanguage>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSysLanguageRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysLanguageRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TSysLanguage);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
