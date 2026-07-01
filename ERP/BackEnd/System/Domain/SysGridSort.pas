unit SysGridFilter;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_grid_sort')]
  TSysGridSorts = class(TEntity)
  private
    FTableName: string;
    FSortContent: string;
  public
    [Column('table_name'), MaxLength(32)]
    property TableName: string read FTableName write FTableName;

    [Column('sort_content')]
    property SortContent: string read FSortContent write FSortContent;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysGridSorts.Create();
begin
  inherited;
end;

destructor TSysGridSorts.Destroy;
begin
  inherited;
end;

end.
