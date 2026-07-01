unit PrdBomByProduct.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, PrdBomByProduct, FilterCriterion;

type
  TPrdBomByProductRepository = class(TRepository<TPrdBomByProduct>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TPrdBomByProductRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TPrdBomByProductRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TPrdBomByProduct);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
