unit AccSetCompanyLegalForm;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, SysLanguage;

type
  [Table('acc_set_company_legal_form_translation', 'public')]
  TAccSetCompanyLegalFormTranslation = class(TEntityBase)
  private
    FAccSetCompanyLegalFormId: Int64;
    FSysLanguageId: Int64;
    FName: string;
    FSysLanguage: TSysLanguage;
  public
    [Column('acc_set_company_legal_form_id', [cpPrimaryKey])]
    property AccSetCompanyLegalFormId: Int64 read FAccSetCompanyLegalFormId write FAccSetCompanyLegalFormId;

    [Column('sys_language_id', [cpPrimaryKey])]
    property SysLanguageId: Int64 read FSysLanguageId write FSysLanguageId;

    [Column('name')]
    property Name: string read FName write FName;

    [BelongsTo('SysLanguageId')]
    property SysLanguage: TSysLanguage read FSysLanguage write FSysLanguage;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccSetCompanyLegalFormTranslation;
  end;

  [Table('acc_set_company_legal_form')]
  TAccSetCompanyLegalForm = class(TEntity)
  private
    FLegalFormKey: string;
    FAccSetOwnershipTypeId: Int64;
    FTranslations: TObjectList<TAccSetCompanyLegalFormTranslation>;

    // View (vw_acc_set_company_legal_form) okunabilir alanları
    FLegalFormName: string;
    FOwnershipTypeName: string;
  public
    [Column('legal_form_key')]
    [MaxLength(48), Required(TLangKeys.TValidation.Required, True)]
    property LegalFormKey: string read FLegalFormKey write FLegalFormKey;

    [Column('acc_set_ownership_type_id')]
    property AccSetOwnershipTypeId: Int64 read FAccSetOwnershipTypeId write FAccSetOwnershipTypeId;

    [HasMany('AccSetCompanyLegalFormId', 'Id')]
    property Translations: TObjectList<TAccSetCompanyLegalFormTranslation> read FTranslations write FTranslations;

    [NotMapped]
    property LegalFormName: string read FLegalFormName write FLegalFormName;

    [NotMapped]
    property OwnershipTypeName: string read FOwnershipTypeName write FOwnershipTypeName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccSetCompanyLegalForm;
  end;

implementation

constructor TAccSetCompanyLegalForm.Create;
begin
  inherited;
  FTranslations := nil;
end;

destructor TAccSetCompanyLegalForm.Destroy;
begin
  FTranslations.Free;
  inherited;
end;

function TAccSetCompanyLegalForm.Clone: TAccSetCompanyLegalForm;
var
  LTrans: TAccSetCompanyLegalFormTranslation;
begin
  Result := TAccSetCompanyLegalForm.Create;
  Result.Id := Self.Id;
  Result.LegalFormKey := Self.LegalFormKey;
  Result.AccSetOwnershipTypeId := Self.AccSetOwnershipTypeId;
  Result.LegalFormName := Self.LegalFormName;
  Result.OwnershipTypeName := Self.OwnershipTypeName;

  if Assigned(Self.Translations) then
  begin
    Result.Translations := TObjectList<TAccSetCompanyLegalFormTranslation>.Create(True);
    for LTrans in Self.Translations do
      Result.Translations.Add(LTrans.Clone);
  end;
end;

constructor TAccSetCompanyLegalFormTranslation.Create;
begin
  inherited;
  FSysLanguage := nil;
end;

destructor TAccSetCompanyLegalFormTranslation.Destroy;
begin
  FSysLanguage.Free;
  inherited;
end;

function TAccSetCompanyLegalFormTranslation.Clone: TAccSetCompanyLegalFormTranslation;
begin
  Result := TAccSetCompanyLegalFormTranslation.Create;
  Result.AccSetCompanyLegalFormId := Self.AccSetCompanyLegalFormId;
  Result.SysLanguageId := Self.SysLanguageId;
  Result.Name := Self.Name;
  if Assigned(Self.SysLanguage) then
    Result.SysLanguage := Self.SysLanguage.Clone;
end;

end.
