unit SysGridSort;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_grid_sort')]
  TSysGridSort = class(TEntity)
  private
    FTableName: string;
    FSortContent: string;
  public
    constructor Create(); override;
    destructor Destroy; override;

    [Column('table_name'), MaxLength(32)]
    property TableName: string read FTableName write FTableName;

    [Column('sort_content')]
    property SortContent: string read FSortContent write FSortContent;
  end;

implementation

constructor TSysGridSort.Create();
begin
  inherited;
end;

destructor TSysGridSort.Destroy;
begin
  inherited;
end;

end.
