unit SysGridColumnTitle;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_grid_column_title')]
  TSysGridColumnTitle = class(TEntity)
  private
    FTableName: string;
    FColumnName: string;
    FLngCode: string;
    FColumnLabel: string;
  public
    [Column('table_name'), MaxLength(64), Required()]
    property TableName: string read FTableName write FTableName;

    [Column('column_name'), MaxLength(64), Required()]
    property ColumnName: string read FColumnName write FColumnName;

    [Column('lng_code'), MaxLength(2), Required()]
    property LngCode: string read FLngCode write FLngCode;

    [Column('column_label'), MaxLength(64)]
    property ColumnLabel: string read FColumnLabel write FColumnLabel;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysGridColumnTitle.Create();
begin
  inherited;
end;

destructor TSysGridColumnTitle.Destroy;
begin
  inherited;
end;

end.
