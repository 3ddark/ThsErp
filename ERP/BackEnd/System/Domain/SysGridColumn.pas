unit SysGridColumn;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_grid_columns')]
  TSysGridColumns = class(TEntity)
  private
    FTableName: string;
    FMinValue: Double;
    FColumnWidth: Integer;
    FMaxValueColor: Integer;
    FIsShowHelper: Boolean;
    FColumnOrder: Integer;
    FBarBgColor: Integer;
    FMaxValuePercent: Integer;
    FBarTextColor: Integer;
    FMinValueColor: Integer;
    FDataFormat: string;
    FIsShow: Boolean;
    FBarColor: Integer;
    FMaxValue: Double;
    FColumnName: string;
  public
    [Column('table_name')]
    property TableName: string read FTableName write FTableName;

    [Column('column_name')]
    property ColumnName: string read FColumnName write FColumnName;

    [Column('column_order')]
    property ColumnOrder: Integer read FColumnOrder write FColumnOrder;

    [Column('column_width')]
    property ColumnWidth: Integer read FColumnWidth write FColumnWidth;

    [Column('data_format')]
    property DataFormat: string read FDataFormat write FDataFormat;

    [Column('is_show')]
    property IsShow: Boolean read FIsShow write FIsShow;

    [Column('is_show_helper')]
    property IsShowHelper: Boolean read FIsShowHelper write FIsShowHelper;

    [Column('min_value')]
    property MinValue: Double read FMinValue write FMinValue;

    [Column('min_value_color')]
    property MinValueColor: Integer read FMinValueColor write FMinValueColor;

    [Column('max_value')]
    property MaxValue: Double read FMaxValue write FMaxValue;

    [Column('max_value_color')]
    property MaxValueColor: Integer read FMaxValueColor write FMaxValueColor;

    [Column('max_value_percent')]
    property MaxValuePercent: Integer read FMaxValuePercent write FMaxValuePercent;

    [Column('bar_color')]
    property BarColor: Integer read FBarColor write FBarColor;

    [Column('bar_bg_color')]
    property BarBgColor: Integer read FBarBgColor write FBarBgColor;

    [Column('bar_text_color')]
    property BarTextColor: Integer read FBarTextColor write FBarTextColor;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysGridColumns.Create();
begin
  inherited;
end;

destructor TSysGridColumns.Destroy;
begin
  inherited;
end;

end.
