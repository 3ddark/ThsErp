unit SysGridColumn;

interface

uses SysUtils, Classes, Types, BaseEntity;

type
  [TableName('sys_grid_columns')]
  TSysGridColumns = class(TEntity)
  private
    FDayName: TEntityField<string>;
  public
    property DayName: TEntityField<string> read FDayName write FDayName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysGridColumns.Create();
begin
  inherited;
  FDayName := TEntityField<string>.Create(Self, 'day_name');
end;

destructor TSysGridColumns.Destroy;
begin
  inherited;
end;

end.
