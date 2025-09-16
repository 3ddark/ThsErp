unit SysPermission;

interface

uses SysUtils, Classes, Types, BaseEntity;

type
  [TableName('sys_permissions')]
  TSysPermission = class(TEntity)
  private
    FPermissionCode: TEntityField<Integer>;
    FPermissionName: TEntityField<string>;
    FPermissionGroupId: TEntityField<Int64>;
  public
    property PermissionCode: TEntityField<Integer> read FPermissionCode write FPermissionCode;
    property PermissionName: TEntityField<string> read FPermissionName write FPermissionName;
    property PermissionGroupId: TEntityField<Int64> read FPermissionGroupId write FPermissionGroupId;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysPermission.Create();
begin
  inherited;
  FPermissionCode := TEntityField<Integer>.Create(Self, 'permission_code');
  FPermissionName := TEntityField<string>.Create(Self, 'permission_name');
  FPermissionGroupId := TEntityField<Int64>.Create(Self, 'permission_group_id');
end;

destructor TSysPermission.Destroy;
begin
  inherited;
end;

end.
