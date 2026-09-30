unit SysPermissionTemplate;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, LocalizationManager;

type
  [Table('sys_permission_template')]
  TSysPermissionTemplate = class(TEntity)
  private
    FTemplateKey: string;
    FTemplateName: string;
    FDescription: string;
    FActive: Boolean;
  public
    [Column('template_key')]
    [MaxLength(64), Required(TLangKeys.TValidation.Required, True)]
    property TemplateKey: string read FTemplateKey write FTemplateKey;

    [Column('template_name')]
    [MaxLength(128), Required(TLangKeys.TValidation.Required, True)]
    property TemplateName: string read FTemplateName write FTemplateName;

    [Column('description')]
    [MaxLength(512)]
    property Description: string read FDescription write FDescription;

    [Column('active')]
    property Active: Boolean read FActive write FActive;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSysPermissionTemplate;
  end;

implementation

constructor TSysPermissionTemplate.Create();
begin
  inherited;
  FActive := True;
end;

destructor TSysPermissionTemplate.Destroy;
begin
  inherited;
end;

function TSysPermissionTemplate.Clone: TSysPermissionTemplate;
begin
  Result := TSysPermissionTemplate.Create;
  Result.Id := Self.Id;
  Result.TemplateKey := Self.TemplateKey;
  Result.TemplateName := Self.TemplateName;
  Result.Description := Self.Description;
  Result.Active := Self.Active;
end;

end.
