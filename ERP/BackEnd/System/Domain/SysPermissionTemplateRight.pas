unit SysPermissionTemplateRight;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, LocalizationManager;

type
  [Table('sys_permission_template_right')]
  TSysPermissionTemplateRight = class(TEntity)
  private
    FSysPermissionTemplateId: Int64;
    FSysPermissionId: Int64;
    FIsRead: Boolean;
    FIsAdd: Boolean;
    FIsUpdate: Boolean;
    FIsDelete: Boolean;
    FIsSpecial: Boolean;
    FTemplateName: string;
    FPermissionName: string;
  public
    [Column('sys_permission_template_id')]
    [Required(TLangKeys.TValidation.Required, True)]
    property SysPermissionTemplateId: Int64 read FSysPermissionTemplateId write FSysPermissionTemplateId;

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

    [NotMapped]
    property TemplateName: string read FTemplateName write FTemplateName;

    [NotMapped]
    property PermissionName: string read FPermissionName write FPermissionName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSysPermissionTemplateRight;
  end;

implementation

constructor TSysPermissionTemplateRight.Create();
begin
  inherited;
end;

destructor TSysPermissionTemplateRight.Destroy;
begin
  inherited;
end;

function TSysPermissionTemplateRight.Clone: TSysPermissionTemplateRight;
begin
  Result := TSysPermissionTemplateRight.Create;
  Result.Id := Self.Id;
  Result.SysPermissionTemplateId := Self.SysPermissionTemplateId;
  Result.SysPermissionId := Self.SysPermissionId;
  Result.IsRead := Self.IsRead;
  Result.IsAdd := Self.IsAdd;
  Result.IsUpdate := Self.IsUpdate;
  Result.IsDelete := Self.IsDelete;
  Result.IsSpecial := Self.IsSpecial;
  Result.TemplateName := Self.TemplateName;
  Result.PermissionName := Self.PermissionName;
end;

end.
