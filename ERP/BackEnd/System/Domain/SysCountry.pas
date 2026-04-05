unit SysCountry;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_countries')]
  TSysCountry = class(TEntity)
  private
    FCountryCode: string;
    FCountryName: string;
    FISOYear: Integer;
    FISOCCTLD: string;
    FIsEuMember: Boolean;
  public
    [Column('country_code'), MaxLength(2), Required()]
    property CountryCode: string read FCountryCode write FCountryCode;

    [Column('country_name'), MaxLength(128), Required()]
    property CountryName: string read FCountryName write FCountryName;

    [Column('iso_year')]
    property ISOYear: Integer read FISOYear write FISOYear;

    [Column('iso_cctld')]
    property ISOCCTLD: string read FISOCCTLD write FISOCCTLD;

    [Column('is_eu_member'), Required()]
    property IsEuMember: Boolean read FIsEuMember write FIsEuMember;
  end;

implementation

end.
