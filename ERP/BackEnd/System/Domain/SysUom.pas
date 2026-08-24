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
    FUom: TSysUom;
    FLanguage: TSysLanguage;
  public
    destructor Destroy; override;

    [Column('sys_uom_id', [cpPrimaryKey, cpNotNull])]
    property SysUomId: Int64 read FSysUomId write FSysUomId;

    [Column('sys_language_id', [cpPrimaryKey, cpNotNull])]
    property SysLanguageId: Int64 read FSysLanguageId write FSysLanguageId;

    [Column('name')]
    [MaxLength(64)]
    property Name: string read FName write FName;

    [BelongsTo('SysUomId', 'Id')]
    property Uom: TSysUom read FUom write FUom;

    [BelongsTo('SysLanguageId', 'Id')]
    property Language: TSysLanguage read FLanguage write FLanguage;
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
    constructor Create; override;
    destructor Destroy; override;

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
  end;

implementation

destructor TSysUomTranslation.Destroy;
begin
  FLanguage.Free;
  inherited;
end;

constructor TSysUom.Create();
begin
  inherited;
  FDecimal := False;
  FMultiplier := 1;
  FSysUomGroup := TSysUomGroup.Create;
  FTranslations := TObjectList<TSysUomTranslation>.Create(True);
end;

destructor TSysUom.Destroy;
begin
  FSysUomGroup.Free;
  FTranslations.Free;
  inherited;
end;

end.
