unit SysPermissionGroup;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, System.Generics.Collections,
  SysLanguage, LocalizationManager;

type
  TSysPermissionGroup = class;

  // Composite PK tablosu: (sys_permission_group_id, sys_language_id)
  // TEntity'den Id kalıtılır ama bu tablo için kullanılmaz.
  // Repository composite key tabloları için Add/Update yaparken
  // cpAutoIncrement olmayan PK kolonları INSERT'e dahil eder — bu doğru davranış.
  [Table('sys_permission_group_translation', 'public')]
  TSysPermissionGroupTranslation = class(TEntityBase)
  private
    FPermissionGroupId: Int64;
    FLanguageId: Int64;
    FName: string;
    FPermissionGroup: TSysPermissionGroup;
    FLanguage: TSysLanguage;
  public
    destructor Destroy; override;

    [Column('sys_permission_group_id', [cpPrimaryKey, cpNotNull])]
    property PermissionGroupId: Int64 read FPermissionGroupId write FPermissionGroupId;

    [Column('sys_language_id', [cpPrimaryKey, cpNotNull])]
    property LanguageId: Int64 read FLanguageId write FLanguageId;

    [Column('name')]
    [MaxLength(64, TLangKeys.TValidation.MaxLength)]
    [Required(TLangKeys.TPermissionGroup.KeyRequired)]
    property Name: string read FName write FName;

    [BelongsTo('PermissionGroupId', 'Id')]
    property PermissionGroup: TSysPermissionGroup read FPermissionGroup write FPermissionGroup;

    [BelongsTo('LanguageId', 'Id')]
    property Language: TSysLanguage read FLanguage write FLanguage;
  end;

  [Table('sys_permission_group')]
  TSysPermissionGroup = class(TEntity)
  private
    FKey: string;

    FTranslations: TObjectList<TSysPermissionGroupTranslation>;
  public
    constructor Create; override;
    destructor Destroy; override;

    [Column('key'), MaxLength(64), Required()]
    property Key: string read FKey write FKey;

    [HasMany('PermissionGroupId', 'Id')]
    property Translations: TObjectList<TSysPermissionGroupTranslation> read FTranslations write FTranslations;
  end;

implementation

destructor TSysPermissionGroupTranslation.Destroy;
begin
  FreeAndNil(FLanguage);
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
