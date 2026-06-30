unit SysCity.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysCity, FilterCriterion;

type
  TSysCityRepository = class(TRepository<TSysCity>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSysCityRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysCityRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TSysCity);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
