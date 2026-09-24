unit SysUomGroup;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, System.Generics.Collections,
  SysLanguage, LocalizationManager;

type
  TSysUomGroup = class;

  [Table('sys_uom_group_translation', 'public')]
  TSysUomGroupTranslation = class(TEntityBase)
  private
    FSysUomGroupId: Int64;
    FSysLanguageId: Int64;
    FUomGroupName: string;

    FSysLanguage: TSysLanguage;
  public
    [Column('sys_uom_group_id', [cpPrimaryKey, cpNotNull])]
    property SysUomGroupId: Int64 read FSysUomGroupId write FSysUomGroupId;

    [Column('sys_language_id', [cpPrimaryKey, cpNotNull])]
    property SysLanguageId: Int64 read FSysLanguageId write FSysLanguageId;

    [Column('uom_group_name')]
    [MaxLength(16)]
    property UomGroupName: string read FUomGroupName write FUomGroupName;

    [BelongsTo('SysLanguageId', 'Id')]
    property SysLanguage: TSysLanguage read FSysLanguage write FSysLanguage;

    constructor Create; override;
    destructor Destroy; override;

    function Clone: TSysUomGroupTranslation;
  end;

  [Table('sys_uom_group')]
  TSysUomGroup = class(TEntity)
  private
    FUomGroupKey: string;
    FTranslations: TObjectList<TSysUomGroupTranslation>;
  public
    [Column('uom_group_key'), MaxLength(16), Required()]
    property UomGroupKey: string read FUomGroupKey write FUomGroupKey;

    [HasMany('SysUomGroupId', 'Id')]
    property Translations: TObjectList<TSysUomGroupTranslation> read FTranslations write FTranslations;

    constructor Create; override;
    destructor Destroy; override;

    function Clone: TSysUomGroup;
  end;

implementation

constructor TSysUomGroup.Create();
begin
  inherited;
  FTranslations := nil;
end;

destructor TSysUomGroup.Destroy;
begin
  FTranslations.Free;
  inherited;
end;

function TSysUomGroup.Clone: TSysUomGroup;
var
  item: TSysUomGroupTranslation;
begin
  Result := TSysUomGroup.Create;
  Result.Id := Self.Id;
  Result.UomGroupKey := Self.UomGroupKey;

  Result.Translations := TObjectList<TSysUomGroupTranslation>.Create(True);
  if Assigned(Self.Translations) then
    for item in Self.Translations do
      Result.Translations.Add(item.Clone);
end;

constructor TSysUomGroupTranslation.Create;
begin
  inherited;
  FSysLanguage := nil;
end;

destructor TSysUomGroupTranslation.Destroy;
begin
  FSysLanguage.Free;
  inherited;
end;

function TSysUomGroupTranslation.Clone: TSysUomGroupTranslation;
begin
  Result := TSysUomGroupTranslation.Create;
  Result.SysUomGroupId := Self.SysUomGroupId;
  Result.SysLanguageId := Self.SysLanguageId;
  Result.UomGroupName := Self.UomGroupName;
end;

end.
