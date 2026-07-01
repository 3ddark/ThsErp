unit PrdPacketRawDetail.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, PrdPacketRawDetail, FilterCriterion;

type
  TPrdPacketRawDetailRepository = class(TRepository<TPrdPacketRawDetail>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TPrdPacketRawDetailRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TPrdPacketRawDetailRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TPrdPacketRawDetail);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + LTableName + ' WHERE 1=1 ';
end;

end.
