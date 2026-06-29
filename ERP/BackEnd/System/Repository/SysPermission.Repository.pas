unit SysPermission.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysPermission;

type
  TSysPermissionRepository = class(TRepository<TSysPermission>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSysPermissionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
