unit SatSiparisDetay.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SatSiparisDetay, FilterCriterion;

type
  TSatSiparisDetayRepository = class(TRepository<TSatSiparisDetay>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSatSiparisDetayRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSatSiparisDetayRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TSatSiparisDetay);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
