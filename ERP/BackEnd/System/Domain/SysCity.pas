unit SysCity;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, SysRegion, SysCountry;

type
  [Table('sys_city')]
  TSysCity = class(TEntity)
  private
    FCityName: string;
    FCarPlateCode: Integer;
    FSysCountryId: Int64;
    FSysRegionId: Int64;

    FSysCountry: TSysCountry;
    FSysRegion: TSysRegion;
  public
    constructor Create(); override;
    destructor Destroy; override;

    [Column('city_name')]
    property CityName: string read FCityName write FCityName;

    [Column('car_plate_code')]
    property CarPlateCode: Integer read FCarPlateCode write FCarPlateCode;

    [Column('sys_country_id')]
    property SysCountryId: Int64 read FSysCountryId write FSysCountryId;

    [Column('sys_region_id')]
    property SysRegionId: Int64 read FSysRegionId write FSysRegionId;

    [BelongsTo('sys_country_id', 'id')]
    property SysCountry: TSysCountry read FSysCountry write FSysCountry;

    [BelongsTo('sys_region_id', 'id')]
    property SysRegion: TSysRegion read FSysRegion write FSysRegion;
  end;

implementation

constructor TSysCity.Create();
begin
  inherited;
  FSysCountry := TSysCountry.Create;
  FSysRegion := TSysRegion.Create;
end;

destructor TSysCity.Destroy;
begin
  FSysCountry.Free;
  FSysRegion.Free;

  inherited;
end;

end.
