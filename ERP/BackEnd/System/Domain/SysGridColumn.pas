unit SysGridColumn;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_grid_column')]
  TSysGridColumn = class(TEntity)
  private
    FTableName: string;
    FColumnName: string;
    FColumnOrder: Integer;
    FColumnWidth: Integer;
    FDataFormat: string;
    FIsShow: Boolean;
    FIsShowHelper: Boolean;
    FMinValue: Double;
    FMinValueColor: Integer;
    FMaxValue: Double;
    FMaxValueColor: Integer;
    FMaxValuePercent: Double;
    FBarColor: Integer;
    FBarBgColor: Integer;
    FBarTextColor: Integer;
  public
    [Column('table_name'), MaxLength(128), Required()]
    property TableName: string read FTableName write FTableName;

    [Column('column_name'), MaxLength(128), Required()]
    property ColumnName: string read FColumnName write FColumnName;

    [Column('column_order')]
    property ColumnOrder: Integer read FColumnOrder write FColumnOrder;

    [Column('column_width')]
    property ColumnWidth: Integer read FColumnWidth write FColumnWidth;

    [Column('data_format'), MaxLength(16)]
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
    property MaxValuePercent: Double read FMaxValuePercent write FMaxValuePercent;

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

constructor TSysGridColumn.Create();
begin
  inherited;
  FColumnOrder := 1;
  FColumnWidth := 0;
  FIsShow := True;
  FIsShowHelper := False;
  FMinValue := 0;
  FMinValueColor := 0;
  FMaxValue := 0;
  FMaxValueColor := 0;
  FMaxValuePercent := 0;
  FBarColor := 0;
  FBarBgColor := 0;
  FBarTextColor := 0;
end;

destructor TSysGridColumn.Destroy;
begin
  inherited;
end;

end.
