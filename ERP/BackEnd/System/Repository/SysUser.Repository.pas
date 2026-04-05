unit SysUser.Repository;

interface

uses
  SysUtils, Classes, Types, DB, System.Generics.Collections,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  Entity, Repository, FilterCriterion, SysUser, SharedFormTypes;

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
