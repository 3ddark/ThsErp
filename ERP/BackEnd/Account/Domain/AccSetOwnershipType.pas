unit AccSetOwnershipType;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, SysLanguage;

type
  [Table('acc_set_ownership_type_translation', 'public')]
  TAccSetOwnershipTypeTranslation = class(TEntityBase)
  private
    FAccSetOwnershipTypeId: Int64;
    FSysLanguageId: Int64;
    FName: string;
    FSysLanguage: TSysLanguage;
  public
    [Column('acc_set_ownership_type_id', [cpPrimaryKey])]
    property AccSetOwnershipTypeId: Int64 read FAccSetOwnershipTypeId write FAccSetOwnershipTypeId;

    [Column('sys_language_id', [cpPrimaryKey])]
    property SysLanguageId: Int64 read FSysLanguageId write FSysLanguageId;

    [Column('name')]
    property Name: string read FName write FName;

    [BelongsTo('SysLanguageId')]
    property SysLanguage: TSysLanguage read FSysLanguage write FSysLanguage;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccSetOwnershipTypeTranslation;
  end;

  [Table('acc_set_ownership_type')]
  TAccSetOwnershipType = class(TEntity)
  private
    FOwnershipTypeKey: string;
    FTranslations: TObjectList<TAccSetOwnershipTypeTranslation>;

    // View (vw_acc_set_ownership_type) okunabilir alanları
    FOwnershipTypeName: string;
  public
    [Column('ownership_type_key')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property OwnershipTypeKey: string read FOwnershipTypeKey write FOwnershipTypeKey;

    [HasMany('AccSetOwnershipTypeId', 'Id')]
    property Translations: TObjectList<TAccSetOwnershipTypeTranslation> read FTranslations write FTranslations;

    [NotMapped]
    property OwnershipTypeName: string read FOwnershipTypeName write FOwnershipTypeName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccSetOwnershipType;
  end;

implementation

constructor TAccSetOwnershipType.Create;
begin
  inherited;
  FTranslations := nil;
end;

destructor TAccSetOwnershipType.Destroy;
begin
  FTranslations.Free;
  inherited;
end;

function TAccSetOwnershipType.Clone: TAccSetOwnershipType;
var
  LTrans: TAccSetOwnershipTypeTranslation;
begin
  Result := TAccSetOwnershipType.Create;
  Result.Id := Self.Id;
  Result.OwnershipTypeKey := Self.OwnershipTypeKey;
  Result.OwnershipTypeName := Self.OwnershipTypeName;

  if Assigned(Self.Translations) then
  begin
    Result.Translations := TObjectList<TAccSetOwnershipTypeTranslation>.Create(True);
    for LTrans in Self.Translations do
      Result.Translations.Add(LTrans.Clone);
  end;
end;

constructor TAccSetOwnershipTypeTranslation.Create;
begin
  inherited;
  FSysLanguage := nil;
end;

destructor TAccSetOwnershipTypeTranslation.Destroy;
begin
  FSysLanguage.Free;
  inherited;
end;

function TAccSetOwnershipTypeTranslation.Clone: TAccSetOwnershipTypeTranslation;
begin
  Result := TAccSetOwnershipTypeTranslation.Create;
  Result.AccSetOwnershipTypeId := Self.AccSetOwnershipTypeId;
  Result.SysLanguageId := Self.SysLanguageId;
  Result.Name := Self.Name;
  if Assigned(Self.SysLanguage) then
    Result.SysLanguage := Self.SysLanguage.Clone;
end;

end.
