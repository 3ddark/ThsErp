unit SysPermission;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes, SysPermissionGroup;

type
  [Table('sys_permissions')]
  TSysPermission = class(TEntity)
  private
    FPermissionCode: Integer;
    FPermissionName: string;
    FPermissionGroupId: Int64;
    FPermissionGroup: TSysPermissionGroup;
  public
    [Column('permission_code')]
    property PermissionCode: Integer read FPermissionCode write FPermissionCode;

    [Column('permission_name')]
    property PermissionName: string read FPermissionName write FPermissionName;

    [Column('permission_group_id')]
    property PermissionGroupId: Int64 read FPermissionGroupId write FPermissionGroupId;

    [BelongsTo('PermissionGroupId')]
    property PermissionGroup: TSysPermissionGroup read FPermissionGroup write FPermissionGroup;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysPermission.Create();
begin
  inherited;
end;

destructor TSysPermission.Destroy;
begin
  if Assigned(FPermissionGroup) then
    FreeAndNil(FPermissionGroup);

  inherited;
end;

end.
