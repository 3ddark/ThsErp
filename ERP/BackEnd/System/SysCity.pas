unit SysCity;

interface

uses SysUtils, Classes, Types, BaseEntity;

type
  [TableName('sys_cities')]
  TSysCity = class(TEntity)
  private
    FCityName: TEntityField<string>;
    FCarPlateCode: TEntityField<Integer>;
    FCountryId: TEntityField<Int64>;
    FRegionId: TEntityField<Int64>;
  public
    property CityName: TEntityField<string> read FCityName write FCityName;
    property CarPlateCode: TEntityField<Integer> read FCarPlateCode write FCarPlateCode;
    property CountryId: TEntityField<Int64> read FCountryId write FCountryId;
    property RegionId: TEntityField<Int64> read FRegionId write FRegionId;

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
end;

destructor TSysCity.Destroy;
begin
  inherited;
end;

end.
