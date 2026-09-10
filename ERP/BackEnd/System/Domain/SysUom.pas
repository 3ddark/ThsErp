unit SysUom;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, System.Generics.Collections,
  SysUomGroup, SysLanguage, LocalizationManager;

type
  TSysUom = class;

  [Table('sys_uom_translation', 'public')]
  TSysUomTranslation = class(TEntityBase)
  private
    FSysUomId: Int64;
    FSysLanguageId: Int64;
    FName: string;

    FSysLanguage: TSysLanguage;
  public
    [Column('sys_uom_id', [cpPrimaryKey, cpNotNull])]
    property SysUomId: Int64 read FSysUomId write FSysUomId;

    [Column('sys_language_id', [cpPrimaryKey, cpNotNull])]
    property SysLanguageId: Int64 read FSysLanguageId write FSysLanguageId;

    [Column('name')]
    [MaxLength(64)]
    property Name: string read FName write FName;

    [BelongsTo('SysLanguageId', 'Id')]
    property SysLanguage: TSysLanguage read FSysLanguage write FSysLanguage;

    constructor Create; override;
    destructor Destroy; override;

    function Clone: TSysUomTranslation;
  end;

  [Table('sys_uom')]
  TSysUom = class(TEntity)
  private
    FUnitCode: string;
    FUnitEInv: string;
    FDecimal: Boolean;
    FGroupId: Int64;
    FMultiplier: Integer;
    FSysUomGroup: TSysUomGroup;
    FTranslations: TObjectList<TSysUomTranslation>;
  public
    [Column('unit_code'), MaxLength(16), Required()]
    property UnitCode: string read FUnitCode write FUnitCode;

    [Column('unit_einv'), MaxLength(3), Required()]
    property UnitEInv: string read FUnitEInv write FUnitEInv;

    [Column('decimal'), Required()]
    property Decimal: Boolean read FDecimal write FDecimal;

    [Column('group_id')]
    property GroupId: Int64 read FGroupId write FGroupId;

    [BelongsTo('GroupId', 'Id')]
    property SysUomGroup: TSysUomGroup read FSysUomGroup write FSysUomGroup;

    [Column('multiplier')]
    property Multiplier: Integer read FMultiplier write FMultiplier;

    [HasMany('SysUomId', 'Id')]
    property Translations: TObjectList<TSysUomTranslation> read FTranslations write FTranslations;

    constructor Create; override;
    destructor Destroy; override;

    function Clone: TSysUom;
  end;

implementation

constructor TSysUom.Create();
begin
  inherited;
  FDecimal := False;
  FMultiplier := 1;
  FSysUomGroup := nil;
  FTranslations := nil;
end;

destructor TSysUom.Destroy;
begin
  FSysUomGroup.Free;
  FTranslations.Free;
  inherited;
end;

function TSysUom.Clone: TSysUom;
var
  item: TSysUomTranslation;
begin
  Result := TSysUom.Create;
  Result.UnitCode := Self.UnitCode;
  Result.UnitEInv := Self.UnitEInv;
  Result.Decimal := Self.Decimal;
  Result.GroupId := Self.GroupId;
  Result.Multiplier := Self.Multiplier;

  if Assigned(Self.SysUomGroup) then
    Result.SysUomGroup := Self.SysUomGroup;

  Result.Translations := TObjectList<TSysUomTranslation>.Create(True);
  if Assigned(Self.Translations) then
    for item in Self.Translations do
      Result.Translations.Add(item.Clone);
end;

constructor TSysUomTranslation.Create;
begin
  inherited;
  FSysLanguage := nil;
end;

destructor TSysUomTranslation.Destroy;
begin
  FSysLanguage.Free;
  inherited;
end;

function TSysUomTranslation.Clone: TSysUomTranslation;
begin
  Result := TSysUomTranslation.Create;
  Result.SysUomId := Self.SysUomId;
  Result.SysLanguageId := Self.SysLanguageId;
  Result.Name := Self.Name;

  if Assigned(Self.SysLanguage) then
    Result.SysLanguage := Self.SysLanguage.Clone;
end;

end.
