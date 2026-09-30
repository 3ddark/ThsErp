unit EmpUnit;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, SysLanguage;

type
  [Table('emp_unit_translation', 'public')]
  TEmpUnitTranslation = class(TEntityBase)
  private
    FEmpUnitId: Int64;
    FSysLanguageId: Int64;
    FName: string;
    FSysLanguage: TSysLanguage;
  public
    [Column('emp_unit_id', [cpPrimaryKey])]
    property EmpUnitId: Int64 read FEmpUnitId write FEmpUnitId;

    [Column('sys_language_id', [cpPrimaryKey])]
    property SysLanguageId: Int64 read FSysLanguageId write FSysLanguageId;

    [Column('name')]
    property Name: string read FName write FName;

    [BelongsTo('SysLanguageId')]
    property SysLanguage: TSysLanguage read FSysLanguage write FSysLanguage;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpUnitTranslation;
  end;

  [Table('emp_unit')]
  TEmpUnit = class(TEntity)
  private
    FUnitKey: string;
    FEmpSectionId: Int64;
    FTranslations: TObjectList<TEmpUnitTranslation>;

    // View (vw_emp_unit) okunabilir alanları
    FEmpUnitName: string;
    FSectionName: string;
  public
    [Column('unit_key')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property UnitKey: string read FUnitKey write FUnitKey;

    [Column('emp_section_id')]
    property EmpSectionId: Int64 read FEmpSectionId write FEmpSectionId;

    [HasMany('EmpUnitId', 'Id')]
    property Translations: TObjectList<TEmpUnitTranslation> read FTranslations write FTranslations;

    [NotMapped]
    property EmpUnitName: string read FEmpUnitName write FEmpUnitName;

    [NotMapped]
    property SectionName: string read FSectionName write FSectionName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpUnit;
  end;

implementation

constructor TEmpUnit.Create;
begin
  inherited;
  FTranslations := nil;
end;

destructor TEmpUnit.Destroy;
begin
  FTranslations.Free;
  inherited;
end;

function TEmpUnit.Clone: TEmpUnit;
var
  LTrans: TEmpUnitTranslation;
begin
  Result := TEmpUnit.Create;
  Result.Id := Self.Id;
  Result.UnitKey := Self.UnitKey;
  Result.EmpSectionId := Self.EmpSectionId;
  Result.EmpUnitName := Self.EmpUnitName;
  Result.SectionName := Self.SectionName;

  if Assigned(Self.Translations) then
  begin
    Result.Translations := TObjectList<TEmpUnitTranslation>.Create(True);
    for LTrans in Self.Translations do
      Result.Translations.Add(LTrans.Clone);
  end;
end;

constructor TEmpUnitTranslation.Create;
begin
  inherited;
  FSysLanguage := nil;
end;

destructor TEmpUnitTranslation.Destroy;
begin
  FSysLanguage.Free;
  inherited;
end;

function TEmpUnitTranslation.Clone: TEmpUnitTranslation;
begin
  Result := TEmpUnitTranslation.Create;
  Result.EmpUnitId := Self.EmpUnitId;
  Result.SysLanguageId := Self.SysLanguageId;
  Result.Name := Self.Name;
  if Assigned(Self.SysLanguage) then
    Result.SysLanguage := Self.SysLanguage.Clone;
end;

end.
