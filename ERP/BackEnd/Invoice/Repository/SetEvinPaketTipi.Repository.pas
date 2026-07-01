unit SetEvinPaketTipi.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SetEvinPaketTipi, FilterCriterion;

type
  TSetEvinPacketTypeRepository = class(TRepository<TSetEvinPacketType>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSetEvinPacketTypeRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSetEvinPacketTypeRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TSetEvinPacketType);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
