unit SysMeasureType;

interface

uses SysUtils, Classes, Types, BaseEntity;

type
  [TableName('sys_measure_types')]
  TSysMeasureType = class(TEntity)
  private
    FDayName: TEntityField<string>;
  public
    property DayName: TEntityField<string> read FDayName write FDayName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysMeasureType.Create();
begin
  inherited;
  FDayName := TEntityField<string>.Create(Self, 'day_name');
end;

destructor TSysMeasureType.Destroy;
begin
  inherited;
end;

end.
