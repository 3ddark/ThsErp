unit SysPermissionGroup.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SysPermissionGroup.Repository, SysPermissionGroup;

type
  TSysPermissionGroupService = class(TCrudService<TSysPermissionGroup>)
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

constructor TSysPermissionGroupService.Create;
begin
  inherited;
end;

destructor TSysPermissionGroupService.Destroy;
begin
  inherited;
end;

end.

