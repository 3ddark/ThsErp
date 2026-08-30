unit SysCity;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, SysRegion, SysCountry;

type
  [Table('sys_city')]
  TSysCity = class(TEntity)
  private
    FCityName: string;
    FPlateCode: Integer;
    FCountryId: Int64;
    FRegionId: Int64;
    FCountry: TSysCountry;
    FRegion: TSysRegion;
  public
    constructor Create(); override;
    destructor Destroy; override;

    [Column('city_name')]
    property CityName: string read FCityName write FCityName;

    [Column('plate_code')]
    property PlateCode: Integer read FPlateCode write FPlateCode;

    [Column('country_id')]
    property CountryId: Int64 read FCountryId write FCountryId;

    [Column('region_id')]
    property RegionId: Int64 read FRegionId write FRegionId;

    [BelongsTo('country_id', 'id')]
    property Country: TSysCountry read FCountry write FCountry;

    [BelongsTo('region_id', 'id')]
    property Region: TSysRegion read FRegion write FRegion;
  end;

implementation

constructor TSysCity.Create();
begin
  inherited;
  FCountry := TSysCountry.Create;
  FRegion := TSysRegion.Create;
end;

destructor TSysCity.Destroy;
begin
  FreeAndNil(FCountry);
  FreeAndNil(FRegion);

  inherited;
end;

end.
