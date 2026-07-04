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

    [Column('table_type'), MaxLength(32)]
    property TableType: string read FTableType write FTableType;

    constructor Create(); override;
  end;

implementation

constructor TSysViewTable.Create();
begin
  inherited;
end;

end.
