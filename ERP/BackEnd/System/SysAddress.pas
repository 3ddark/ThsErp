unit SysAddress;

interface

uses SysUtils, Classes, Types, BaseEntity;

type
  [TableName('sys_addresses')]
  TSysAddress = class(TEntity)
  private
    FCityId: TEntityField<Int64>;
    FDistrict: TEntityField<string>;
    FNeighborhood: TEntityField<string>;
    FQuarter: TEntityField<string>;
    FRoad: TEntityField<string>;
    FStreet: TEntityField<string>;
    FBuildingName: TEntityField<string>;
    FDoorNumber: TEntityField<string>;
    FZipCode: TEntityField<string>;
    FWeb: TEntityField<string>;
    FEmail: TEntityField<string>;
  public
    property CityId: TEntityField<Int64> read FCityId write FCityId;
    property District: TEntityField<string> read FDistrict write FDistrict;
    property Neighborhood: TEntityField<string> read FNeighborhood write FNeighborhood;
    property Quarter: TEntityField<string> read FQuarter write FQuarter;
    property Road: TEntityField<string> read FRoad write FRoad;
    property Street: TEntityField<string> read FStreet write FStreet;
    property BuildingName: TEntityField<string> read FBuildingName write FBuildingName;
    property DoorNumber: TEntityField<string> read FDoorNumber write FDoorNumber;
    property ZipCode: TEntityField<string> read FZipCode write FZipCode;
    property Web: TEntityField<string> read FWeb write FWeb;
    property Email: TEntityField<string> read FEmail write FEmail;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysAddress.Create();
begin
  inherited;
  FCityId := TEntityField<Int64>.Create(Self, 'city_id');
  FDistrict := TEntityField<string>.Create(Self, 'district');
  FNeighborhood := TEntityField<string>.Create(Self, 'neighborhood');
  FQuarter := TEntityField<string>.Create(Self, 'quarter');
  FRoad := TEntityField<string>.Create(Self, 'road');
  FStreet := TEntityField<string>.Create(Self, 'street');
  FBuildingName := TEntityField<string>.Create(Self, 'building_name');
  FDoorNumber := TEntityField<string>.Create(Self, 'door_number');
  FZipCode := TEntityField<string>.Create(Self, 'zip_code');
  FWeb := TEntityField<string>.Create(Self, 'web');
  FEmail := TEntityField<string>.Create(Self, 'email');
end;

destructor TSysAddress.Destroy;
begin
  inherited;
end;

end.
