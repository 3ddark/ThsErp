unit SysAccessRight;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes, SysPermission, SysUser;

type
  [Table('sys_access_rights')]
  TSysAccessRight = class(TEntity)
  private
    FPermissionId: Int64;
    FIsRead: Boolean;
    FIsAdd: Boolean;
    FIsUpdate: Boolean;
    FIsDelete: Boolean;
    FIsSpecial: Boolean;
    FUserId: Int64;
    FPermission: TSysPermission;
    FUser: TSysUser;
  public
    [Column('permission_id')]
    [Required('sysaccessright.permissionid.required', True)]
    property PermissionId: Int64 read FPermissionId write FPermissionId;

    [Column('is_read')]
    property IsRead: Boolean read FIsRead write FIsRead;

    [Column('is_add')]
    [Required('', True)]
    property IsAdd: Boolean read FIsAdd write FIsAdd;

    [Column('is_update')]
    property IsUpdate: Boolean read FIsUpdate write FIsUpdate;

    [Column('is_delete')]
    property IsDelete: Boolean read FIsDelete write FIsDelete;

    [Column('is_special')]
    property IsSpecial: Boolean read FIsSpecial write FIsSpecial;

    [Column('user_id')]
    [Required('sysaccessright.userid.required', True)]
    property UserId: Int64 read FUserId write FUserId;

    [BelongsTo('PermissionId')]
    property Permission: TSysPermission read FPermission write FPermission;

    [BelongsTo('UserId')]
    property User: TSysUser read FUser write FUser;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysAccessRight.Create();
begin
  inherited;
  FPermission := TSysPermission.Create;
  FUser := TSysUser.Create;
end;

destructor TSysAccessRight.Destroy;
begin
  if Assigned(FPermission) then
    FreeAndNil(FPermission);
  if Assigned(FUser) then
    FreeAndNil(FUser);
  inherited;
end;

end.
