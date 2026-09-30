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
    FDenyRead: Boolean;
    FDenyAdd: Boolean;
    FDenyUpdate: Boolean;
    FDenyDelete: Boolean;
    FDenySpecial: Boolean;
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

    // Override (engelleme): şablondan gelse bile ilgili hak kaldırılır
    [Column('deny_read')]
    property DenyRead: Boolean read FDenyRead write FDenyRead;

    [Column('deny_add')]
    property DenyAdd: Boolean read FDenyAdd write FDenyAdd;

    [Column('deny_update')]
    property DenyUpdate: Boolean read FDenyUpdate write FDenyUpdate;

    [Column('deny_delete')]
    property DenyDelete: Boolean read FDenyDelete write FDenyDelete;

    [Column('deny_special')]
    property DenySpecial: Boolean read FDenySpecial write FDenySpecial;

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
  EmpEmployee;

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
  Result.Id := Self.Id;
  Result.SysPermissionId := Self.SysPermissionId;
  Result.IsRead := Self.IsRead;
  Result.IsAdd := Self.IsAdd;
  Result.IsUpdate := Self.IsUpdate;
  Result.IsDelete := Self.IsDelete;
  Result.IsSpecial := Self.IsSpecial;
  Result.DenyRead := Self.DenyRead;
  Result.DenyAdd := Self.DenyAdd;
  Result.DenyUpdate := Self.DenyUpdate;
  Result.DenyDelete := Self.DenyDelete;
  Result.DenySpecial := Self.DenySpecial;
  Result.SysUserId := Self.SysUserId;
  Result.Username := Self.FUsername;
  Result.PermissionName := Self.FPermissionName;

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
    Result := FSysPermission.PermissionKey
  else
    Result := '';
end;

end.
