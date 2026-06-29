unit SysUser.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysUser;

type
  TSysUserRepository = class(TRepository<TSysUser>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSysUserRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
