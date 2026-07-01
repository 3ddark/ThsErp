unit GridColumnTitle.Repository;

interface

uses SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
     FireDAC.Comp.Client, Entity, Repository, GridColumnTitle, FilterCriterion;

type
  TGridColumnTitleRepository = class(TRepository<TGridColumnTitle>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TGridColumnTitleRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TGridColumnTitleRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TGridColumnTitle);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
