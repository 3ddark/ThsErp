unit AccVoucherDetail.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, AccVoucherDetail, FilterCriterion;

type
  TAccVoucherDetailRepository = class(TRepository<TAccVoucherDetail>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TAccVoucherDetailRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TAccVoucherDetailRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TAccVoucherDetail);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
