unit AccAccountPlan.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, AccAccountPlan, FilterCriterion;

type
  TAccAccountPlanRepository = class(TRepository<TAccAccountPlan>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TAccAccountPlanRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TAccAccountPlanRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TAccAccountPlan);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + LTableName + ' WHERE 1=1 ';
end;

end.
