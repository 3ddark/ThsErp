unit PrdBomPacketRaw.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, PrdBomPacketRaw, FilterCriterion;

type
  TPrdBomPacketRawRepository = class(TRepository<TPrdBomPacketRaw>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TPrdBomPacketRawRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TPrdBomPacketRawRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TPrdBomPacketRaw);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
