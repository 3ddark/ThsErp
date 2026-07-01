unit SetEvinFaturaTipi.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SetEvinFaturaTipi, FilterCriterion;

type
  TSetEvinInvoiceTypeRepository = class(TRepository<TSetEvinInvoiceType>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSetEvinInvoiceTypeRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSetEvinInvoiceTypeRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TSetEvinInvoiceType);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
