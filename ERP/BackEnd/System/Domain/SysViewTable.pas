unit SysViewTable;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_view_tables')]
  TSysViewTable = class(TEntity)
  private
    FTableName: string;
    FTableType: string;
  public
    [Column('table_name'), MaxLength(128)]
    property TableName: string read FTableName write FTableName;

    [Column('table_type'), MaxLength(64)]
    property TableType: string read FTableType write FTableType;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSysViewTable;
  end;

implementation

constructor TSysViewTable.Create();
begin
  inherited;
end;

destructor TSysViewTable.Destroy;
begin
  inherited;
end;

function TSysViewTable.Clone: TSysViewTable;
begin
  Result := TSysViewTable.Create;
  Result.Id := Self.Id;
  Result.TableName := Self.TableName;
  Result.TableType := Self.TableType;
end;

end.
