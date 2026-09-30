unit EmpPersonType;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, SysLanguage;

type
  [Table('emp_person_type_translation', 'public')]
  TEmpPersonTypeTranslation = class(TEntityBase)
  private
    FEmpPersonTypeId: Int64;
    FSysLanguageId: Int64;
    FName: string;
    FSysLanguage: TSysLanguage;
  public
    [Column('emp_person_type_id', [cpPrimaryKey])]
    property EmpPersonTypeId: Int64 read FEmpPersonTypeId write FEmpPersonTypeId;

    [Column('sys_language_id', [cpPrimaryKey])]
    property SysLanguageId: Int64 read FSysLanguageId write FSysLanguageId;

    [Column('name')]
    property Name: string read FName write FName;

    [BelongsTo('SysLanguageId')]
    property SysLanguage: TSysLanguage read FSysLanguage write FSysLanguage;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpPersonTypeTranslation;
  end;

  [Table('emp_person_type')]
  TEmpPersonType = class(TEntity)
  private
    FPersonTypeKey: string;
    FTranslations: TObjectList<TEmpPersonTypeTranslation>;

    // View (vw_emp_person_type) okunabilir alanları
    FPersonType: string;
  public
    [Column('person_type_key')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property PersonTypeKey: string read FPersonTypeKey write FPersonTypeKey;

    [HasMany('EmpPersonTypeId', 'Id')]
    property Translations: TObjectList<TEmpPersonTypeTranslation> read FTranslations write FTranslations;

    [NotMapped]
    property PersonType: string read FPersonType write FPersonType;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpPersonType;
  end;

implementation

constructor TEmpPersonType.Create;
begin
  inherited;
  FTranslations := nil;
end;

destructor TEmpPersonType.Destroy;
begin
  FTranslations.Free;
  inherited;
end;

function TEmpPersonType.Clone: TEmpPersonType;
var
  LTrans: TEmpPersonTypeTranslation;
begin
  Result := TEmpPersonType.Create;
  Result.Id := Self.Id;
  Result.PersonTypeKey := Self.PersonTypeKey;
  Result.PersonType := Self.PersonType;

  if Assigned(Self.Translations) then
  begin
    Result.Translations := TObjectList<TEmpPersonTypeTranslation>.Create(True);
    for LTrans in Self.Translations do
      Result.Translations.Add(LTrans.Clone);
  end;
end;

constructor TEmpPersonTypeTranslation.Create;
begin
  inherited;
  FSysLanguage := nil;
end;

destructor TEmpPersonTypeTranslation.Destroy;
begin
  FSysLanguage.Free;
  inherited;
end;

function TEmpPersonTypeTranslation.Clone: TEmpPersonTypeTranslation;
begin
  Result := TEmpPersonTypeTranslation.Create;
  Result.EmpPersonTypeId := Self.EmpPersonTypeId;
  Result.SysLanguageId := Self.SysLanguageId;
  Result.Name := Self.Name;
  if Assigned(Self.SysLanguage) then
    Result.SysLanguage := Self.SysLanguage.Clone;
end;

end.
