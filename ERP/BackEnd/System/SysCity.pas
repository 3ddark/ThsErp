unit SysCity;

interface

uses SysUtils, Classes, Types, BaseEntity, SysRegion, SysCountry;

type
  [TableName('sys_cities')]
  TSysCity = class(TEntity)
  private
    FCityName: TEntityField<string>;
    FCarPlateCode: TEntityField<Integer>;
    FCountryId: TEntityField<Int64>;
    FRegionId: TEntityField<Int64>;
    FCountry: TSysCountry;
    FRegion: TSysRegion;
  public
    property CityName: TEntityField<string> read FCityName write FCityName;
    property CarPlateCode: TEntityField<Integer> read FCarPlateCode write FCarPlateCode;
    property CountryId: TEntityField<Int64> read FCountryId write FCountryId;
    property RegionId: TEntityField<Int64> read FRegionId write FRegionId;
    property Country: TSysCountry read FCountry write FCountry;
    property Region: TSysRegion read FRegion write FRegion;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysCity.Create();
begin
  inherited;
  FCityName := TEntityField<string>.Create(Self, 'city_name');
  FCarPlateCode := TEntityField<Integer>.Create(Self, 'car_plate_code');
  FCountryId := TEntityField<Int64>.Create(Self, 'country_id');
  FRegionId := TEntityField<Int64>.Create(Self, 'region_id');

  FCountry := TSysCountry.Create;
  FRegion := TSysRegion.Create;
end;

destructor TSysCity.Destroy;
var
  n1: Integer;
begin
  for n1 := 0 to FCountry.Fields.Count-1 do
    FCountry.Fields.Items[n1].OwnerEntity := nil;

  for n1 := 0 to FRegion.Fields.Count-1 do
    FRegion.Fields.Items[n1].OwnerEntity := nil;

  inherited;
end;

end.
