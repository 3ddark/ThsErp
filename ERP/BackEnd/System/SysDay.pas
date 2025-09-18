unit SysDay;

interface

uses SysUtils, Classes, Types, BaseEntity;

type
  [TableName('sys_days')]
  TSysDay = class(TEntity)
  private
    FDayName: TEntityField<string>;
  public
    property DayName: TEntityField<string> read FDayName write FDayName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysDay.Create();
begin
  inherited;
  FDayName := TEntityField<string>.Create(Self, 'day_name');
end;

destructor TSysDay.Destroy;
begin
  inherited;
end;

end.
