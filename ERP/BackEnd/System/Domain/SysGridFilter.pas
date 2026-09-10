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
    [Column('table_name'), MaxLength(32)]
    property TableName: string read FTableName write FTableName;

    [Column('filter_content')]
    property FilterContent: string read FFilterContent write FFilterContent;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSysGridFilter;
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

function TSysGridFilter.Clone: TSysGridFilter;
begin
  Result := TSysGridFilter.Create;
  Result.TableName := Self.TableName;
  Result.FilterContent := Self.FilterContent;
end;

end.
