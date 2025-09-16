unit SysPermissionGroup.Repository;

interface

uses
  SysUtils, Classes, Types, DB, System.Generics.Collections,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  BaseEntity, BaseRepository, SysPermissionGroup;

type
  TSysPermissionGroupRepository = class(TBaseRepository<TSysPermissionGroup>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSysPermissionGroupRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
