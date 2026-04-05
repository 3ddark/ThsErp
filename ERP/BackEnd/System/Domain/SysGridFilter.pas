unit SysGridFilter;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_grid_filters')]
  TSysGridFilters = class(TEntity)
  private
    FTableName: string;
    FFilterContent: string;
  public
    [Column('table_name')]
    property TableName: string read FTableName write FTableName;

    [Column('filter_content')]
    property FilterContent: string read FFilterContent write FFilterContent;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysGridFilters.Create();
begin
  inherited;
end;

destructor TSysGridFilters.Destroy;
begin
  inherited;
end;

end.
