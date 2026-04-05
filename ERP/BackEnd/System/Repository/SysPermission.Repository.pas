unit SysPermission.Repository;

interface

uses
  SysUtils, Classes, Types, DB, System.Generics.Collections,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  Entity, Repository, SysPermission;

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
