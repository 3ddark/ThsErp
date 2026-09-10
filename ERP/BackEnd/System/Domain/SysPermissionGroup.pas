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

    FSysLanguage: TSysLanguage;
  public
    [Column('sys_permission_group_id', [cpPrimaryKey, cpNotNull])]
    property SysPermissionGroupId: Int64 read FSysPermissionGroupId write FSysPermissionGroupId;

    [Column('sys_language_id', [cpPrimaryKey, cpNotNull])]
    property SysLanguageId: Int64 read FSysLanguageId write FSysLanguageId;

    [Column('permission_group_name')]
    [MaxLength(128, TLangKeys.TValidation.MaxLength)]
    [Required(TLangKeys.TSysPermissionGroup.KeyRequired)]
    property PermissionGroupName: string read FPermissionGroupName write FPermissionGroupName;

    [BelongsTo('SysLanguageId', 'Id')]
    property SysLanguage: TSysLanguage read FSysLanguage write FSysLanguage;

    constructor Create; override;
    destructor Destroy; override;

    function Clone: TSysPermissionGroupTranslation;
  end;

  [Table('sys_permission_group')]
  TSysPermissionGroup = class(TEntity)
  private
    FPermissionGroupKey: string;

    FTranslations: TObjectList<TSysPermissionGroupTranslation>;
  public
    [Column('permission_group_key'), MaxLength(128), Required()]
    property PermissionGroupKey: string read FPermissionGroupKey write FPermissionGroupKey;

    [HasMany('SysPermissionGroupId', 'Id')]
    property Translations: TObjectList<TSysPermissionGroupTranslation> read FTranslations write FTranslations;

    constructor Create; override;
    destructor Destroy; override;

    function Clone: TSysPermissionGroup;
  end;

implementation

constructor TSysPermissionGroup.Create();
begin
  inherited;
  FTranslations := nil;
end;

destructor TSysPermissionGroup.Destroy;
begin
  FTranslations.Free;
  inherited;
end;

function TSysPermissionGroup.Clone: TSysPermissionGroup;
var
  item: TSysPermissionGroupTranslation;
begin
  Result := TSysPermissionGroup.Create;
  Result.PermissionGroupKey := Self.PermissionGroupKey;

  Result.Translations := TObjectList<TSysPermissionGroupTranslation>.Create(True);
  if Assigned(Self.Translations) then
    for item in Self.Translations do
      Result.Translations.Add(item.Clone);
end;

constructor TSysPermissionGroupTranslation.Create;
begin
  inherited;
  FSysLanguage := nil;
end;

destructor TSysPermissionGroupTranslation.Destroy;
begin
  FSysLanguage.Free;
  inherited;
end;

function TSysPermissionGroupTranslation.Clone: TSysPermissionGroupTranslation;
begin
  Result := TSysPermissionGroupTranslation.Create;
  Result.SysPermissionGroupId := Self.SysPermissionGroupId;
  Result.SysLanguageId := Self.SysLanguageId;
  Result.PermissionGroupName := Self.PermissionGroupName;

  if Assigned(Self.SysLanguage) then
    Result.SysLanguage := Self.SysLanguage.Clone;
end;

end.
