unit SetEvinOdemeSekli.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SetEvinOdemeSekli, FilterCriterion;

type
  TSetEvinPaymentMethodRepository = class(TRepository<TSetEvinPaymentMethod>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSetEvinPaymentMethodRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSetEvinPaymentMethodRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TSetEvinPaymentMethod);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
