unit AccSetAccountType;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, SysLanguage;

type
  [Table('acc_set_account_type_translation', 'public')]
  TAccSetAccountTypeTranslation = class(TEntityBase)
  private
    FAccSetAccountTypeId: Int64;
    FSysLanguageId: Int64;
    FName: string;
    FSysLanguage: TSysLanguage;
  public
    [Column('acc_set_account_type_id', [cpPrimaryKey])]
    property AccSetAccountTypeId: Int64 read FAccSetAccountTypeId write FAccSetAccountTypeId;

    [Column('sys_language_id', [cpPrimaryKey])]
    property SysLanguageId: Int64 read FSysLanguageId write FSysLanguageId;

    [Column('name')]
    property Name: string read FName write FName;

    [BelongsTo('SysLanguageId')]
    property SysLanguage: TSysLanguage read FSysLanguage write FSysLanguage;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccSetAccountTypeTranslation;
  end;

  [Table('acc_set_account_type')]
  TAccSetAccountType = class(TEntity)
  private
    FAccountTypeKey: string;
    FTranslations: TObjectList<TAccSetAccountTypeTranslation>;

    // View (vw_acc_set_account_type) okunabilir alanları
    FAccountTypeName: string;
  public
    [Column('account_type_key')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property AccountTypeKey: string read FAccountTypeKey write FAccountTypeKey;

    [HasMany('AccSetAccountTypeId', 'Id')]
    property Translations: TObjectList<TAccSetAccountTypeTranslation> read FTranslations write FTranslations;

    [NotMapped]
    property AccountTypeName: string read FAccountTypeName write FAccountTypeName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccSetAccountType;
  end;

implementation

constructor TAccSetAccountType.Create;
begin
  inherited;
  FTranslations := nil;
end;

destructor TAccSetAccountType.Destroy;
begin
  FTranslations.Free;
  inherited;
end;

function TAccSetAccountType.Clone: TAccSetAccountType;
var
  LTrans: TAccSetAccountTypeTranslation;
begin
  Result := TAccSetAccountType.Create;
  Result.Id := Self.Id;
  Result.AccountTypeKey := Self.AccountTypeKey;
  Result.AccountTypeName := Self.AccountTypeName;

  if Assigned(Self.Translations) then
  begin
    Result.Translations := TObjectList<TAccSetAccountTypeTranslation>.Create(True);
    for LTrans in Self.Translations do
      Result.Translations.Add(LTrans.Clone);
  end;
end;

constructor TAccSetAccountTypeTranslation.Create;
begin
  inherited;
  FSysLanguage := nil;
end;

destructor TAccSetAccountTypeTranslation.Destroy;
begin
  FSysLanguage.Free;
  inherited;
end;

function TAccSetAccountTypeTranslation.Clone: TAccSetAccountTypeTranslation;
begin
  Result := TAccSetAccountTypeTranslation.Create;
  Result.AccSetAccountTypeId := Self.AccSetAccountTypeId;
  Result.SysLanguageId := Self.SysLanguageId;
  Result.Name := Self.Name;
  if Assigned(Self.SysLanguage) then
    Result.SysLanguage := Self.SysLanguage.Clone;
end;

end.
