unit SysRegion;

interface

uses SysUtils, Classes, Types, BaseEntity;

type
  [TableName('sys_regions')]
  TSysRegion = class(TEntity)
  private
    FRegionName: TEntityField<string>;
  public
    property RegionName: TEntityField<string> read FRegionName write FRegionName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysRegion.Create();
begin
  inherited;
  FRegionName := TEntityField<string>.Create(Self, 'region_name');
end;

destructor TSysRegion.Destroy;
begin
  inherited;
end;

end.
