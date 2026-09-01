unit SysPermissionGroup;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, System.Generics.Collections,
  SysLanguage, LocalizationManager;

type
  TSysPermissionGroup = class;

  [Table('sys_permission_group_translation', 'public')]
  TSysPermissionGroupTranslation = class(TEntityBase)
  private
    FSysPermissionGroupId: Int64;
    FSysLanguageId: Int64;
    FPermissionGroupName: string;

    FSysPermissionGroup: TSysPermissionGroup;
    FSysLanguage: TSysLanguage;
  public
    constructor Create; override;
    destructor Destroy; override;

    [Column('sys_permission_group_id', [cpPrimaryKey, cpNotNull])]
    property SysPermissionGroupId: Int64 read FSysPermissionGroupId write FSysPermissionGroupId;

    [Column('sys_language_id', [cpPrimaryKey, cpNotNull])]
    property SysLanguageId: Int64 read FSysLanguageId write FSysLanguageId;

    [Column('permission_group_name')]
    [MaxLength(128, TLangKeys.TValidation.MaxLength)]
    [Required(TLangKeys.TSysPermissionGroup.KeyRequired)]
    property PermissionGroupName: string read FPermissionGroupName write FPermissionGroupName;

    [BelongsTo('SysPermissionGroupId', 'Id')]
    property SysPermissionGroup: TSysPermissionGroup read FSysPermissionGroup write FSysPermissionGroup;

    [BelongsTo('SysLanguageId', 'Id')]
    property SysLanguage: TSysLanguage read FSysLanguage write FSysLanguage;
  end;

  [Table('sys_permission_group')]
  TSysPermissionGroup = class(TEntity)
  private
    FPermissionGroupKey: string;

    FTranslations: TObjectList<TSysPermissionGroupTranslation>;
  public
    constructor Create; override;
    destructor Destroy; override;

    [Column('permission_group_key'), MaxLength(128), Required()]
    property PermissionGroupKey: string read FPermissionGroupKey write FPermissionGroupKey;

    [HasMany('SysPermissionGroupId', 'Id')]
    property Translations: TObjectList<TSysPermissionGroupTranslation> read FTranslations write FTranslations;
  end;

implementation

constructor TSysPermissionGroupTranslation.Create;
begin
  inherited;
  FSysLanguage := TSysLanguage.Create;
end;

destructor TSysPermissionGroupTranslation.Destroy;
begin
  FreeAndNil(FSysLanguage);
  inherited;
end;

constructor TSysPermissionGroup.Create();
begin
  inherited;
  FTranslations := TObjectList<TSysPermissionGroupTranslation>.Create(True);
end;

destructor TSysPermissionGroup.Destroy;
begin
  FreeAndNil(FTranslations);
  inherited;
end;

end.
