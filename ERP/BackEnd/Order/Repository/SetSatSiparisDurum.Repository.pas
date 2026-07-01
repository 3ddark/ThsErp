unit SetSatSiparisDurum.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SetSatSiparisDurum, FilterCriterion;

type
  TSetSatSiparisDurumRepository = class(TRepository<TSetSatSiparisDurum>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSetSatSiparisDurumRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSetSatSiparisDurumRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TSetSatSiparisDurum);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
