unit SysGridFilter;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_grid_filter')]
  TSysGridFilter = class(TEntity)
  private
    FTableName: string;
    FFilterContent: string;
  public
    constructor Create(); override;
    destructor Destroy; override;

    [Column('table_name'), MaxLength(32)]
    property TableName: string read FTableName write FTableName;

    [Column('filter_content')]
    property FilterContent: string read FFilterContent write FFilterContent;
  end;

implementation

constructor TSysGridFilter.Create();
begin
  inherited;
end;

destructor TSysGridFilter.Destroy;
begin
  inherited;
end;

end.
