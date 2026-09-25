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
    [Column('city_name')]
    property CityName: string read FCityName write FCityName;

    [Column('car_plate_code')]
    property CarPlateCode: Integer read FCarPlateCode write FCarPlateCode;

    [Column('sys_country_id')]
    property SysCountryId: Int64 read FSysCountryId write FSysCountryId;

    [Column('sys_region_id')]
    property SysRegionId: Int64 read FSysRegionId write FSysRegionId;

    [BelongsTo('SysCountryId')]
    property SysCountry: TSysCountry read FSysCountry write FSysCountry;

    [BelongsTo('SysRegionId')]
    property SysRegion: TSysRegion read FSysRegion write FSysRegion;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSysCity;
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

function TSysCity.Clone: TSysCity;
begin
  Result := TSysCity.Create;
  Result.Id := Self.Id;
  Result.CityName := Self.CityName;
  Result.CarPlateCode := Self.CarPlateCode;
  Result.SysCountryId := Self.SysCountryId;
  Result.SysRegionId := Self.SysRegionId;

  if Assigned(Self.SysCountry) then
  begin
    if Assigned(Result.SysCountry) then
      Result.SysCountry.Free;
    Result.SysCountry := Self.SysCountry.Clone;
  end;

  if Assigned(Self.SysRegion) then
  begin
    if Assigned(Result.SysRegion) then
      Result.SysRegion.Free;
    Result.SysRegion := Self.SysRegion.Clone;
  end;
end;

end.
