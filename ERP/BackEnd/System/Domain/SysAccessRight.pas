unit SysAccessRight;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, SysPermission, SysUser,
  LocalizationManager;

type
  [Table('sys_access_right')]
  TSysAccessRight = class(TEntity)
  private
    FSysPermissionId: Int64;
    FIsRead: Boolean;
    FIsAdd: Boolean;
    FIsUpdate: Boolean;
    FIsDelete: Boolean;
    FIsSpecial: Boolean;
    FSysUserId: Int64;
    FSysPermission: TSysPermission;
    FSysUser: TSysUser;
    FUsername: string;
    FPermissionName: string;
    function GetUsername: string;
    function GetPermissionName: string;
  public
    [Column('sys_permission_id')]
    [Required(TLangKeys.TValidation.Required, True)]
    property SysPermissionId: Int64 read FSysPermissionId write FSysPermissionId;

    [Column('is_read')]
    property IsRead: Boolean read FIsRead write FIsRead;

    [Column('is_add')]
    property IsAdd: Boolean read FIsAdd write FIsAdd;

    [Column('is_update')]
    property IsUpdate: Boolean read FIsUpdate write FIsUpdate;

    [Column('is_delete')]
    property IsDelete: Boolean read FIsDelete write FIsDelete;

    [Column('is_special')]
    property IsSpecial: Boolean read FIsSpecial write FIsSpecial;

    [Column('sys_user_id')]
    [Required(TLangKeys.TValidation.Required, True)]
    property SysUserId: Int64 read FSysUserId write FSysUserId;

    [BelongsTo('SysPermissionId')]
    property SysPermission: TSysPermission read FSysPermission write FSysPermission;

    [BelongsTo('SysUserId')]
    property SysUser: TSysUser read FSysUser write FSysUser;

    [NotMapped]
    property Username: string read GetUsername write FUsername;

    [NotMapped]
    property PermissionName: string read GetPermissionName write FPermissionName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSysAccessRight;
  end;

implementation

uses
  EmpPerson;

constructor TSysAccessRight.Create();
begin
  inherited;
  FSysPermission := nil;
  FSysUser := nil;
end;

destructor TSysAccessRight.Destroy;
begin
  FSysPermission.Free;
  FSysUser.Free;
  inherited;
end;

function TSysAccessRight.Clone: TSysAccessRight;
begin
  Result := TSysAccessRight.Create;
  Result.SysPermissionId := Self.SysPermissionId;
  Result.IsRead := Self.IsRead;
  Result.IsAdd := Self.IsAdd;
  Result.IsUpdate := Self.IsUpdate;
  Result.IsDelete := Self.IsDelete;
  Result.IsSpecial := Self.IsSpecial;
  Result.SysUserId := Self.SysUserId;

  if Assigned(Self.SysPermission) then
    Result.SysPermission := Self.SysPermission.Clone;

  if Assigned(Self.SysUser) then
    Result.SysUser := Self.SysUser.Clone;
end;

function TSysAccessRight.GetUsername: string;
begin
  if FUsername <> '' then
    Result := FUsername
  else if Assigned(FSysUser) then
    Result := FSysUser.Username
  else
    Result := '';
end;

function TSysAccessRight.GetPermissionName: string;
begin
  if FPermissionName <> '' then
    Result := FPermissionName
  else if Assigned(FSysPermission) then
    Result := FSysPermission.Key
  else
    Result := '';
end;

end.
