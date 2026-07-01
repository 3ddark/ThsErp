unit PrdBomPacketLabour.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, PrdBomPacketLabour, FilterCriterion;

type
  TPrdBomPacketLabourRepository = class(TRepository<TPrdBomPacketLabour>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TPrdBomPacketLabourRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TPrdBomPacketLabourRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TPrdBomPacketLabour);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
