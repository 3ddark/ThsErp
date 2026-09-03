unit SysAddress;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, SysCity, LocalizationManager;

type
  [Table('sys_address')]
  TSysAddress = class(TEntity)
  private
    FSysCityId: Int64;
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

    FSysCity: TSysCity;
  public
    constructor Create(); override;
    destructor Destroy; override;

    [Column('sys_city_id')]
    [Required(TLangKeys.TValidation.Required, True)]
    property SysCityId: Int64 read FSysCityId write FSysCityId;

    [Column('district')]
    property District: string read FDistrict write FDistrict;

    [Column('neighborhood')]
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

    [BelongsTo('sys_city_id', 'id')]
    property SysCity: TSysCity read FSysCity write FSysCity;
  end;

implementation

constructor TSysAddress.Create();
begin
  inherited;
  FSysCity := TSysCity.Create;
end;

destructor TSysAddress.Destroy;
begin
  inherited;
  FSysCity.Free;
end;

end.
