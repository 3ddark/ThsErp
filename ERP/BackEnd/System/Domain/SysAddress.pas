unit SysAddress;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_addresses')]
  TSysAddress = class(TEntity)
  private
    FCityId: Int64;
    FDistrict: string;
    FNeighborhood: string;
    FQuarter: string;
    FRoad: string;
    FStreet: string;
    FBuildingName: string;
    FDoorNumber: string;
    FZipCode: string;
    FWeb: string;
    FEmail: string;
  public
    [Column('city_id')]
    [Required('sysaddress.cityid.required', True)]
    property CityId: Int64 read FCityId write FCityId;

    [Column('district')]
    property District: string read FDistrict write FDistrict;

    [Column('neigborhood')]
    property Neighborhood: string read FNeighborhood write FNeighborhood;

    [Column('quarter')]
    property Quarter: string read FQuarter write FQuarter;

    [Column('road')]
    property Road: string read FRoad write FRoad;

    [Column('street')]
    property Street: string read FStreet write FStreet;

    [Column('building_name')]
    property BuildingName: string read FBuildingName write FBuildingName;

    [Column('door_number')]
    property DoorNumber: string read FDoorNumber write FDoorNumber;

    [Column('zip_code')]
    property ZipCode: string read FZipCode write FZipCode;

    [Column('web')]
    property Web: string read FWeb write FWeb;

    [Column('email')]
    property Email: string read FEmail write FEmail;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysAddress.Create();
begin
  inherited;
  
end;

destructor TSysAddress.Destroy;
begin
  inherited;
end;

end.
