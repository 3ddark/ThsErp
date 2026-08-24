unit PrdPacketLabourDetail.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, PrdPacketLabourDetail, FilterCriterion;

type
  TPrdPacketLabourDetailRepository = class(TRepository<TPrdPacketLabourDetail>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
    procedure Delete(AModel: TPrdPacketLabourDetail; ACascade: TCascadeOperations = []); override;
  end;

implementation

constructor TPrdPacketLabourDetailRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TPrdPacketLabourDetailRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TPrdPacketLabourDetail);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + LTableName + ' WHERE 1=1 ';
end;

procedure TPrdPacketLabourDetailRepository.Delete(AModel: TPrdPacketLabourDetail; ACascade: TCascadeOperations);
begin
  Delete(AModel.Id, ACascade);
end;

end.
