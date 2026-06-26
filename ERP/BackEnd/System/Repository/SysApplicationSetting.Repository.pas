unit SysApplicationSetting.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysApplicationSetting;

type
  TSysApplicationSettingRepository = class(TRepository<TSysApplicationSetting>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSysApplicationSettingRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
