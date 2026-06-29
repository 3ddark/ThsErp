unit SysPermissionGroup.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysPermissionGroup;

type
  TSysPermissionGroupRepository = class(TRepository<TSysPermissionGroup>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSysPermissionGroupRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
