unit SetAccCompanyLegalForm.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SetAccCompanyLegalForm, FilterCriterion;

type
  TSetAccCompanyLegalFormRepository = class(TRepository<TSetAccCompanyLegalForm>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  end;

implementation

constructor TSetAccCompanyLegalFormRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSetAccCompanyLegalFormRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TSetAccCompanyLegalForm);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_' + LTableName + ' WHERE 1=1 ';
end;

end.
