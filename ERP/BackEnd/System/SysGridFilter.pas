unit SysGridFilter;

interface

uses SysUtils, Classes, Types, BaseEntity;

type
  [TableName('sys_grid_filters')]
  TSysGridFilters = class(TEntity)
  private
    FDayName: TEntityField<string>;
  public
    property DayName: TEntityField<string> read FDayName write FDayName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysGridFilters.Create();
begin
  inherited;
  FDayName := TEntityField<string>.Create(Self, 'day_name');
end;

destructor TSysGridFilters.Destroy;
begin
  inherited;
end;

end.
