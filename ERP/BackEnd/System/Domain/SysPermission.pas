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
    FSysPermissionId: Int64;
    FSysLanguageId: Int64;
    FPermissionName: string;

    FSysLanguage: TSysLanguage;
  public
    [Column('sys_permission_id', [cpPrimaryKey])]
    property SysPermissionId: Int64 read FSysPermissionId write FSysPermissionId;

    [Column('sys_language_id', [cpPrimaryKey])]
    property SysLanguageId: Int64 read FSysLanguageId write FSysLanguageId;

    [Column('permission_name')]
    property PermissionName: string read FPermissionName write FPermissionName;

    [BelongsTo('SysLanguageId')]
    property SysLanguage: TSysLanguage read FSysLanguage write FSysLanguage;

    constructor Create; override;
    destructor Destroy; override;

    function Clone: TSysPermissionTranslation;
  end;

  [Table('sys_permission', 'public')]
  TSysPermission = class(TEntity)
  private
    FPermissionCode: Integer;
    FPermissionKey: string;
    FSysPermissionGroupId: Int64;

    FSysPermissionGroup: TSysPermissionGroup;
    FTranslations: TObjectList<TSysPermissionTranslation>;
  public
    [Column('permission_code', [cpNotNull])]
    property PermissionCode: Integer read FPermissionCode write FPermissionCode;

    [Column('permission_key', [cpNotNull])]
    property PermissionKey: string read FPermissionKey write FPermissionKey;

    [Column('sys_permission_group_id', [cpNotNull])]
    property SysPermissionGroupId: Int64 read FSysPermissionGroupId write FSysPermissionGroupId;

    [BelongsTo('SysPermissionGroupId', 'Id')]
    property SysPermissionGroup: TSysPermissionGroup read FSysPermissionGroup write FSysPermissionGroup;

    [HasMany('SysPermissionId', 'Id')]
    property Translations: TObjectList<TSysPermissionTranslation> read FTranslations write FTranslations;

    constructor Create; override;
    destructor Destroy; override;

    function Clone: TSysPermission;
  end;

implementation

constructor TSysPermission.Create();
begin
  inherited;
  FSysPermissionGroup := nil;
  FTranslations := nil;
end;

destructor TSysPermission.Destroy;
begin
  FSysPermissionGroup.Free;
  FTranslations.Free;
  inherited;
end;

function TSysPermission.Clone: TSysPermission;
var
  item: TSysPermissionTranslation;
begin
  Result := TSysPermission.Create;
  Result.Id := Self.Id;
  Result.PermissionCode := Self.PermissionCode;
  Result.PermissionKey := Self.PermissionKey;
  Result.SysPermissionGroupId := Self.SysPermissionGroupId;

  if Assigned(Self.SysPermissionGroup) then
    Result.SysPermissionGroup := Self.SysPermissionGroup.Clone;

  Result.Translations := TObjectList<TSysPermissionTranslation>.Create(True);
  if Assigned(Self.Translations) then
    for item in Self.Translations do
      Result.Translations.Add(item.Clone);
end;

constructor TSysPermissionTranslation.Create;
begin
  inherited;
  FSysLanguage := nil;
end;

destructor TSysPermissionTranslation.Destroy;
begin
  FSysLanguage.Free;
  inherited;
end;

function TSysPermissionTranslation.Clone: TSysPermissionTranslation;
begin
  Result := TSysPermissionTranslation.Create;
  Result.SysPermissionId := Self.SysPermissionId;
  Result.SysLanguageId := Self.SysLanguageId;
  Result.PermissionName := Self.PermissionName;

  if Assigned(Self.SysLanguage) then
    Result.SysLanguage := Self.SysLanguage.Clone;
end;

end.
