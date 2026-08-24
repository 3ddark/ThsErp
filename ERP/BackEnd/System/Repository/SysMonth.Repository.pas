unit SysMonth.Repository;

interface

uses SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
     FireDAC.Comp.Client, Entity, Repository, SysMonth, FilterCriterion;

type
  TSysMonthRepository = class(TRepository<TSysMonth>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
    procedure Delete(AModel: TSysMonth; ACascade: TCascadeOperations = []); override;
  end;

implementation

constructor TSysMonthRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysMonthRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TSysMonth);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

procedure TSysMonthRepository.Delete(AModel: TSysMonth; ACascade: TCascadeOperations);
begin
  Delete(AModel.Id, ACascade);
end;

end.
