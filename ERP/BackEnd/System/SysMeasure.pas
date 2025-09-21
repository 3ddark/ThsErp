unit SysMeasure;

interface

uses SysUtils, Classes, Types, BaseEntity;

type
  [TableName('sys_measures')]
  TSysMeasure = class(TEntity)
  private
    FDayName: TEntityField<string>;
  public
    property DayName: TEntityField<string> read FDayName write FDayName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysMeasure.Create();
begin
  inherited;
  FDayName := TEntityField<string>.Create(Self, 'day_name');
end;

destructor TSysMeasure.Destroy;
begin
  inherited;
end;

end.
