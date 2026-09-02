unit SysPermission;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, System.Generics.Collections,
  SysPermissionGroup, SysLanguage;

type
  TSysPermission = class;

  [Table('sys_permission_translation', 'public')]
  TSysPermissionTranslation = class(TEntityBase)
  private
    FPermissionId: Int64;
    FLanguageId: Int64;
    FName: string;

    FLanguage: TSysLanguage;
  public
    constructor Create; override;
    destructor Destroy; override;

    [Column('sys_permission_id', [cpPrimaryKey])]
    property PermissionId: Int64 read FPermissionId write FPermissionId;

    [Column('sys_language_id', [cpPrimaryKey])]
    property LanguageId: Int64 read FLanguageId write FLanguageId;

    [Column('name')]
    property Name: string read FName write FName;

    [BelongsTo('LanguageId')]
    property Language: TSysLanguage read FLanguage write FLanguage;
  end;

  [Table('sys_permission', 'public')]
  TSysPermission = class(TEntity)
  private
    FCode: Integer;
    FKey: string;
    FGroupId: Int64;
    FGroup: TSysPermissionGroup;
    FTranslations: TObjectList<TSysPermissionTranslation>;
  public
    constructor Create; override;
    destructor Destroy; override;

    [Column('code', [cpNotNull])]
    property Code: Integer read FCode write FCode;

    [Column('key', [cpNotNull])]
    property Key: string read FKey write FKey;

    [Column('group_id', [cpNotNull])]
    property GroupId: Int64 read FGroupId write FGroupId;

    [BelongsTo('GroupId', 'Id')]
    property Group: TSysPermissionGroup read FGroup write FGroup;

    [HasMany('PermissionId', 'Id')]
    property Translations: TObjectList<TSysPermissionTranslation> read FTranslations write FTranslations;
  end;

implementation

constructor TSysPermission.Create();
begin
  inherited;
  FGroup        := TSysPermissionGroup.Create;
  FTranslations := TObjectList<TSysPermissionTranslation>.Create(True);
end;

destructor TSysPermission.Destroy;
begin
  FGroup.Free;
  FTranslations.Free;
  inherited;
end;

constructor TSysPermissionTranslation.Create;
begin
  inherited;
  FLanguage := nil;
end;

destructor TSysPermissionTranslation.Destroy;
begin
  FLanguage.Free;
  inherited;
end;

end.
