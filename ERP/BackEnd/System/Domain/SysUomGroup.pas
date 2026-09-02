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
    FName: string;

    FSysLanguage: TSysLanguage;
  public
    constructor Create; override;
    destructor Destroy; override;

    [Column('sys_uom_group_id', [cpPrimaryKey, cpNotNull])]
    property SysUomGroupId: Int64 read FSysUomGroupId write FSysUomGroupId;

    [Column('sys_language_id', [cpPrimaryKey, cpNotNull])]
    property SysLanguageId: Int64 read FSysLanguageId write FSysLanguageId;

    [Column('name')]
    [MaxLength(64)]
    property Name: string read FName write FName;

    [BelongsTo('SysLanguageId', 'Id')]
    property SysLanguage: TSysLanguage read FSysLanguage write FSysLanguage;
  end;

  [Table('sys_uom_group')]
  TSysUomGroup = class(TEntity)
  private
    FKey: string;
    FTranslations: TObjectList<TSysUomGroupTranslation>;
  public
    constructor Create; override;
    destructor Destroy; override;

    [Column('key'), MaxLength(64), Required()]
    property Key: string read FKey write FKey;

    [HasMany('SysUomGroupId', 'Id')]
    property Translations: TObjectList<TSysUomGroupTranslation> read FTranslations write FTranslations;
  end;

implementation

constructor TSysUomGroup.Create();
begin
  inherited;
  FTranslations := TObjectList<TSysUomGroupTranslation>.Create(True);
end;

destructor TSysUomGroup.Destroy;
begin
  FTranslations.Free;
  inherited;
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

end.
