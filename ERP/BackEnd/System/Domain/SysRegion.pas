unit SysRegion;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_region')]
  TSysRegion = class(TEntity)
  private
    FRegionName: string;
  public
    [Column('region_name'), MaxLength(64), Required()]
    property RegionName: string read FRegionName write FRegionName;

    constructor Create(); override;

    function Clone: TSysRegion;
  end;

implementation

constructor TSysRegion.Create();
begin
  inherited;
end;

function TSysRegion.Clone: TSysRegion;
begin
  Result := TSysRegion.Create;
  Result.Id := Self.Id;
  Result.RegionName := Self.RegionName;
end;

end.
