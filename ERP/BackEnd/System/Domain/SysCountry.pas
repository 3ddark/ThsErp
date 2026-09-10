unit SysCountry;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, System.Generics.Collections,
  SysLanguage;

type
  TSysCountry = class;

  [Table('sys_country_translation', 'public')]
  TSysCountryTranslation = class(TEntityBase, ICloneable<TSysCountryTranslation>)
  private
    FSysCountryId: Int64;
    FSysLanguageId: Int64;
    FCountryName: string;

    FSysLanguage: TSysLanguage;
  public
    [Column('sys_country_id', [cpPrimaryKey])]
    property SysCountryId: Int64 read FSysCountryId write FSysCountryId;

    [Column('sys_language_id', [cpPrimaryKey])]
    property SysLanguageId: Int64 read FSysLanguageId write FSysLanguageId;

    [Column('country_name')]
    property CountryName: string read FCountryName write FCountryName;

    [BelongsTo('SysLanguageId')]
    property SysLanguage: TSysLanguage read FSysLanguage write FSysLanguage;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSysCountryTranslation;
  end;

  [Table('sys_country')]
  TSysCountry = class(TEntity, ICloneable<TSysCountry>)
  private
    FCountryCode: string;
    FISOYear: Integer;
    FISOCCTLD: string;
    FIsEuMember: Boolean;

    FTranslations: TObjectList<TSysCountryTranslation>;

    FCountryName: string;
  public
    [Column('country_code'), MaxLength(2), Required()]
    property CountryCode: string read FCountryCode write FCountryCode;

    [Column('iso_year')]
    property ISOYear: Integer read FISOYear write FISOYear;

    [Column('iso_cctld'), MaxLength(3)]
    property ISOCCTLD: string read FISOCCTLD write FISOCCTLD;

    [Column('is_eu_member'), Required()]
    property IsEuMember: Boolean read FIsEuMember write FIsEuMember;

    [HasMany('SysCountryId', 'Id')]
    property Translations: TObjectList<TSysCountryTranslation> read FTranslations write FTranslations;

    [NotMapped()]
    property CountryName: string read FCountryName write FCountryName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSysCountry;
  end;

implementation

constructor TSysCountry.Create();
begin
  inherited;
  FTranslations := nil;
  FIsEuMember := False;
end;

destructor TSysCountry.Destroy;
begin
  FTranslations.Free;
  inherited;
end;

function TSysCountry.Clone: TSysCountry;
var
  LTrans: TSysCountryTranslation;
begin
  Result             := TSysCountry.Create;
  Result.Id          := Self.Id;
  Result.CountryCode := Self.CountryCode;
  Result.ISOYear     := Self.ISOYear;
  Result.ISOCCTLD    := Self.ISOCCTLD;
  Result.IsEuMember  := Self.IsEuMember;
  Result.CountryName := Self.CountryName;

  Result.Translations := TObjectList<TSysCountryTranslation>.Create(True);
  for LTrans in Self.Translations do
    Result.Translations.Add(LTrans.Clone);
end;

constructor TSysCountryTranslation.Create;
begin
  inherited;
  FSysLanguage := nil;
end;

destructor TSysCountryTranslation.Destroy;
begin
  FSysLanguage.Free;
  inherited;
end;

function TSysCountryTranslation.Clone: TSysCountryTranslation;
begin
  Result := TSysCountryTranslation.Create;
  Result.SysCountryId := Self.SysCountryId;
  Result.SysLanguageId := Self.SysLanguageId;
  Result.CountryName := Self.CountryName;

  if Assigned(Self.SysLanguage) then
    Result.SysLanguage := Self.SysLanguage.Clone;
end;

end.
