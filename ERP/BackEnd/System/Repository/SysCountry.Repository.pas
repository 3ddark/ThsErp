unit SysCountry.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysCountry, FilterCriterion;

type
  TSysCountryRepository = class(TRepository<TSysCountry>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
    procedure Delete(AModel: TSysCountry); override;
  end;

implementation

constructor TSysCountryRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysCountryRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_sys_countries WHERE 1=1 ';
end;

procedure TSysCountryRepository.Delete(AModel: TSysCountry);
begin
  Delete(AModel.Id);
end;

end.
