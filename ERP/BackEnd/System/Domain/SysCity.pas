unit SysCity;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, SysRegion, SysCountry;

type
  [Table('sys_cities')]
  TSysCity = class(TEntity)
  private
    FCityName: string;
    FCarPlateCode: Integer;
    FCountryId: Int64;
    FRegionId: Int64;
    FCountry: TSysCountry;
    FRegion: TSysRegion;
  public
    [Column('city_name')]
    property CityName: string read FCityName write FCityName;

    [Column('car_plate_code')]
    property CarPlateCode: Integer read FCarPlateCode write FCarPlateCode;

    [Column('country_id')]
    property CountryId: Int64 read FCountryId write FCountryId;

    [Column('region_id')]
    property RegionId: Int64 read FRegionId write FRegionId;

    [BelongsTo('country_id', 'id')]
    property Country: TSysCountry read FCountry write FCountry;

    [BelongsTo('region_id', 'id')]
    property Region: TSysRegion read FRegion write FRegion;

    constructor Create(); override;
    destructor Destroy; override;
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
  if Assigned(FCountry) then
    FreeAndNil(FCountry);
  if Assigned(FRegion) then
    FreeAndNil(FRegion);

  inherited;
end;

end.
