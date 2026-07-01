unit AlsTeklifDetay.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, AlsTeklifDetay, FilterCriterion;

type
  TAlsTeklifDetayRepository = class(TRepository<TAlsTeklifDetay>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TAlsTeklifDetayRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TAlsTeklifDetayRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TAlsTeklifDetay);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
