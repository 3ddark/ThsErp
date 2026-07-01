unit SetAccOwnershipType.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SetAccOwnershipType, FilterCriterion;

type
  TSetAccOwnershipTypeRepository = class(TRepository<TSetAccOwnershipType>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSetAccOwnershipTypeRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSetAccOwnershipTypeRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TSetAccOwnershipType);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
