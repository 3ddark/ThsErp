unit SysPermission;

interface

uses SysUtils, Classes, Types, BaseEntity, SysPermissionGroup;

type
  [TableName('sys_permissions')]
  TSysPermission = class(TEntity)
  private
    FPermissionCode: TEntityField<Integer>;
    FPermissionName: TEntityField<string>;
    FPermissionGroupId: TEntityField<Int64>;
    FPermissionGroup: TSysPermissionGroup;
  public
    property PermissionCode: TEntityField<Integer> read FPermissionCode write FPermissionCode;
    property PermissionName: TEntityField<string> read FPermissionName write FPermissionName;
    property PermissionGroupId: TEntityField<Int64> read FPermissionGroupId write FPermissionGroupId;
    property PermissionGroup: TSysPermissionGroup read FPermissionGroup write FPermissionGroup;

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
  FPermissionGroup := TSysPermissionGroup.Create;
end;

destructor TSysPermission.Destroy;
var n1: Integer;
begin
  for n1 := 0 to FPermissionGroup.Fields.Count-1 do
    FPermissionGroup.Fields.Items[n1].OwnerEntity := nil;

  inherited;
end;

end.
