unit SysDay;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_days')]
  TSysDay = class(TEntity)
  private
    FDayName: string;
  public
    [Column('day_name')]
    property DayName: string read FDayName write FDayName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysDay.Create();
begin
  inherited;
end;

destructor TSysDay.Destroy;
begin
  inherited;
end;

end.
