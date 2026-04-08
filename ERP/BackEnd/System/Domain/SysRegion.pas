unit SysRegion;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_regions')]
  TSysRegion = class(TEntity)
  private
    FRegionName: string;
  public
    [Column('region_name'), MaxLength(64), Required()]
    property RegionName: string read FRegionName write FRegionName;
  end;

implementation

end.
