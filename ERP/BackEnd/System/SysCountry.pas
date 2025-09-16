unit SysCountry;

interface

uses
  SysUtils, Classes, Types, BaseEntity;

type
  [TableName('sys_countries')]
  TSysCountry = class(TEntity)
  private
    FCountryCode: TEntityField<string>;
    FCountryName: TEntityField<string>;
    FISOYear: TEntityField<Integer>;
    FISOCCTLD: TEntityField<string>;
    FIsEuMember: TEntityField<Boolean>;
  public
    property CountryCode: TEntityField<string> read FCountryCode write FCountryCode;
    property CountryName: TEntityField<string> read FCountryName write FCountryName;
    property ISOYear: TEntityField<Integer> read FISOYear write FISOYear;
    property ISOCCTLD: TEntityField<string> read FISOCCTLD write FISOCCTLD;
    property IsEuMember: TEntityField<Boolean> read FIsEuMember write FIsEuMember;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysCountry.Create();
begin
  inherited;
  FCountryCode := TEntityField<string>.Create(Self, 'country_code');
  FCountryName := TEntityField<string>.Create(Self, 'country_name');
  FISOYear := TEntityField<Integer>.Create(Self, 'iso_year');
  FISOCCTLD := TEntityField<string>.Create(Self, 'iso_cctld');
  FIsEuMember := TEntityField<Boolean>.Create(Self, 'is_eu_member');
end;

destructor TSysCountry.Destroy;
begin
  inherited;
end;

end.
