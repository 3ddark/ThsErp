unit SysCountry;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, System.Generics.Collections,
  SysLanguage;

type
  TSysCountry = class;

  [Table('sys_country_translation', 'public')]
  TSysCountryTranslation = class(TEntityBase)
  private
    FSysCountryId: Int64;
    FSysLanguageId: Int64;
    FCountryName: string;

    FSysCountry: TSysCountry;
    FSysLanguage: TSysLanguage;
  public
    constructor Create(); override;
    destructor Destroy; override;

    [Column('sys_country_id', [cpPrimaryKey])]
    property SysCountryId: Int64 read FSysCountryId write FSysCountryId;

    [Column('sys_language_id', [cpPrimaryKey])]
    property SysLanguageId: Int64 read FSysLanguageId write FSysLanguageId;

    [Column('country_name')]
    property CountryName: string read FCountryName write FCountryName;

    [BelongsTo('SysCountryId')]
    property SysCountry: TSysCountry read FSysCountry write FSysCountry;

    [BelongsTo('SysLanguageId')]
    property SysLanguage: TSysLanguage read FSysLanguage write FSysLanguage;
  end;

  [Table('sys_country')]
  TSysCountry = class(TEntity)
  private
    FCountryCode: string;
    FISOYear: Integer;
    FISOCCTLD: string;
    FIsEuMember: Boolean;

    FTranslations: TObjectList<TSysCountryTranslation>;
  public
    constructor Create(); override;
    destructor Destroy; override;

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
  end;

implementation

constructor TSysCountry.Create();
begin
  inherited;
  FTranslations := TObjectList<TSysCountryTranslation>.Create(True);
  FIsEuMember := False;
end;

destructor TSysCountry.Destroy;
begin
  FreeAndNil(FTranslations);
  inherited;
end;

constructor TSysCountryTranslation.Create;
begin
  inherited;
  FSysCountry := TSysCountry.Create;
  FSysLanguage := TSysLanguage.Create;
end;

destructor TSysCountryTranslation.Destroy;
begin
  FreeAndNil(FSysCountry);
  FreeAndNil(FSysLanguage);
  inherited;
end;

end.
