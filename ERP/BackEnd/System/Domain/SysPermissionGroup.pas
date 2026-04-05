unit SysPermissionGroup;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_permission_groups')]
  TSysPermissionGroup = class(TEntity)
  private
    FGroupName: string;
  public
    [Column('group_name')]
    property GroupName: string read FGroupName write FGroupName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysPermissionGroup.Create();
begin
  inherited;
end;

destructor TSysPermissionGroup.Destroy;
begin
  inherited;
end;

end.
