unit SetEvinTasimaUcreti.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SetEvinTasimaUcreti, FilterCriterion;

type
  TSetEvinTransportPriceRepository = class(TRepository<TSetEvinTransportPrice>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSetEvinTransportPriceRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSetEvinTransportPriceRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TSetEvinTransportPrice);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
