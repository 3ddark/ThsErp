unit EmpSection;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, SysLanguage;

type
  [Table('emp_section_translation', 'public')]
  TEmpSectionTranslation = class(TEntityBase)
  private
    FEmpSectionId: Int64;
    FSysLanguageId: Int64;
    FName: string;
    FSysLanguage: TSysLanguage;
  public
    [Column('emp_section_id', [cpPrimaryKey])]
    property EmpSectionId: Int64 read FEmpSectionId write FEmpSectionId;

    [Column('sys_language_id', [cpPrimaryKey])]
    property SysLanguageId: Int64 read FSysLanguageId write FSysLanguageId;

    [Column('name')]
    property Name: string read FName write FName;

    [BelongsTo('SysLanguageId')]
    property SysLanguage: TSysLanguage read FSysLanguage write FSysLanguage;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpSectionTranslation;
  end;

  [Table('emp_section')]
  TEmpSection = class(TEntity)
  private
    FSectionKey: string;
    FTranslations: TObjectList<TEmpSectionTranslation>;

    // View (vw_emp_section) okunabilir alanları
    FSectionName: string;
  public
    [Column('section_key')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property SectionKey: string read FSectionKey write FSectionKey;

    [HasMany('EmpSectionId', 'Id')]
    property Translations: TObjectList<TEmpSectionTranslation> read FTranslations write FTranslations;

    [NotMapped]
    property SectionName: string read FSectionName write FSectionName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpSection;
  end;

implementation

constructor TEmpSection.Create;
begin
  inherited;
  FTranslations := nil;
end;

destructor TEmpSection.Destroy;
begin
  FTranslations.Free;
  inherited;
end;

function TEmpSection.Clone: TEmpSection;
var
  LTrans: TEmpSectionTranslation;
begin
  Result := TEmpSection.Create;
  Result.Id := Self.Id;
  Result.SectionKey := Self.SectionKey;
  Result.SectionName := Self.SectionName;

  if Assigned(Self.Translations) then
  begin
    Result.Translations := TObjectList<TEmpSectionTranslation>.Create(True);
    for LTrans in Self.Translations do
      Result.Translations.Add(LTrans.Clone);
  end;
end;

constructor TEmpSectionTranslation.Create;
begin
  inherited;
  FSysLanguage := nil;
end;

destructor TEmpSectionTranslation.Destroy;
begin
  FSysLanguage.Free;
  inherited;
end;

function TEmpSectionTranslation.Clone: TEmpSectionTranslation;
begin
  Result := TEmpSectionTranslation.Create;
  Result.EmpSectionId := Self.EmpSectionId;
  Result.SysLanguageId := Self.SysLanguageId;
  Result.Name := Self.Name;
  if Assigned(Self.SysLanguage) then
    Result.SysLanguage := Self.SysLanguage.Clone;
end;

end.
