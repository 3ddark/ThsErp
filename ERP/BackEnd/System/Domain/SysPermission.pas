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
    FName: string;

    FSysLanguage: TSysLanguage;
  public
    [Column('sys_permission_id', [cpPrimaryKey])]
    property SysPermissionId: Int64 read FSysPermissionId write FSysPermissionId;

    [Column('sys_language_id', [cpPrimaryKey])]
    property SysLanguageId: Int64 read FSysLanguageId write FSysLanguageId;

    [Column('name')]
    property Name: string read FName write FName;

    [BelongsTo('SysLanguageId')]
    property SysLanguage: TSysLanguage read FSysLanguage write FSysLanguage;

    constructor Create; override;
    destructor Destroy; override;

    function Clone: TSysPermissionTranslation;
  end;

  [Table('sys_permission', 'public')]
  TSysPermission = class(TEntity)
  private
    FCode: Integer;
    FKey: string;
    FGroupId: Int64;

    FSysPermissionGroup: TSysPermissionGroup;
    FTranslations: TObjectList<TSysPermissionTranslation>;
  public
    [Column('code', [cpNotNull])]
    property Code: Integer read FCode write FCode;

    [Column('key', [cpNotNull])]
    property Key: string read FKey write FKey;

    [Column('group_id', [cpNotNull])]
    property GroupId: Int64 read FGroupId write FGroupId;

    [BelongsTo('GroupId', 'Id')]
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
  Result.Code := Self.Code;
  Result.Key := Self.Key;
  Result.GroupId := Self.GroupId;

  if Assigned(Self.SysPermissionGroup) then
    Result.SysPermissionGroup := Self.SysPermissionGroup.Clone;

  Result.Translations := TObjectList<TSysPermissionTranslation>.Create(True);
  if Assigned(Self.Translations) then
    for item in Self.Translations do
    begin
      Result.Translations.Add(item.Clone);
    end;
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
  Result.Name := Self.Name;

  if Assigned(Self.SysLanguage) then
    Result.SysLanguage := Self.SysLanguage.Clone;
end;

end.
