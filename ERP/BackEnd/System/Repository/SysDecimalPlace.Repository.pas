unit SysDecimalPlace.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysDecimalPlace, FilterCriterion;

type
  TSysDecimalPlaceRepository = class(TRepository<TSysDecimalPlace>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSysDecimalPlaceRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysDecimalPlaceRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_sys_decimal_places WHERE 1=1 ';
end;

end.
