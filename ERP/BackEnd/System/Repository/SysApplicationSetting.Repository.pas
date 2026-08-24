unit SysApplicationSetting.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysApplicationSetting, FilterCriterion;

type
  TSysApplicationSettingRepository = class(TRepository<TSysApplicationSetting>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
    procedure Delete(AModel: TSysApplicationSetting); override;
  end;

implementation

constructor TSysApplicationSettingRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysApplicationSettingRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(TSysApplicationSetting);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_sys_application_setting WHERE 1=1 ';
end;

procedure TSysApplicationSettingRepository.Delete(AModel: TSysApplicationSetting);
begin
  Delete(AModel.Id);
end;

end.
