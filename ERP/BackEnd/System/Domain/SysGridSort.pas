unit SysGridFilter;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [TableName('sys_grid_sorts')]
  TSysGridFilters = class(TEntity)
  private
    FTableName: string;
    FSortContent: string;
  public
    [Column('table_name')]
    property TableName: string read FTableName write FTableName;

    [Column('sort_content')]
    property SortContent: string read FSortContent write FSortContent;

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
