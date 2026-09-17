unit SysApplicationSetting.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  System.Rtti, FireDAC.Stan.Param, FireDAC.Comp.Client, Entity, Repository,
  SysApplicationSetting, FilterCriterion;

type
  TSysApplicationSettingRepository = class(TRepository<TSysApplicationSetting>)
  protected
    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TSysApplicationSetting); override;
  end;

implementation

constructor TSysApplicationSettingRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysApplicationSettingRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TSysApplicationSetting) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

procedure TSysApplicationSettingRepository.Delete(AModel: TSysApplicationSetting);
begin
  Delete(AModel.Id);
end;

end.
