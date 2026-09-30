unit SysUserPermissionTemplate;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, LocalizationManager;

type
  [Table('sys_user_permission_template')]
  TSysUserPermissionTemplate = class(TEntity)
  private
    FSysUserId: Int64;
    FSysPermissionTemplateId: Int64;
    FUsername: string;
    FTemplateName: string;
  public
    [Column('sys_user_id')]
    [Required(TLangKeys.TValidation.Required, True)]
    property SysUserId: Int64 read FSysUserId write FSysUserId;

    [Column('sys_permission_template_id')]
    [Required(TLangKeys.TValidation.Required, True)]
    property SysPermissionTemplateId: Int64 read FSysPermissionTemplateId write FSysPermissionTemplateId;

    [NotMapped]
    property Username: string read FUsername write FUsername;

    [NotMapped]
    property TemplateName: string read FTemplateName write FTemplateName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSysUserPermissionTemplate;
  end;

implementation

constructor TSysUserPermissionTemplate.Create();
begin
  inherited;
end;

destructor TSysUserPermissionTemplate.Destroy;
begin
  inherited;
end;

function TSysUserPermissionTemplate.Clone: TSysUserPermissionTemplate;
begin
  Result := TSysUserPermissionTemplate.Create;
  Result.Id := Self.Id;
  Result.SysUserId := Self.SysUserId;
  Result.SysPermissionTemplateId := Self.SysPermissionTemplateId;
  Result.Username := Self.Username;
  Result.TemplateName := Self.TemplateName;
end;

end.
