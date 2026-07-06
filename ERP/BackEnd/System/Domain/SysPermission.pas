unit SysPermission;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes, SysPermissionGroup;

type
  [Table('sys_permission')]
  TSysPermission = class(TEntity)
  private
    FCode: Integer;
    FName: string;
    FGroupId: Int64;
    FPermissionGroup: TSysPermissionGroup;
  public
    [Column('code'), Required()]
    property Code: Integer read FCode write FCode;

    [Column('name'), MaxLength(64), Required()]
    property Name: string read FName write FName;

    [Column('group_id')]
    property GroupId: Int64 read FGroupId write FGroupId;

    [BelongsTo('GroupId')]
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
