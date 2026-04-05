unit SysMonth;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_months')]
  TSysMonth = class(TEntity)
  private
    FMonthName: string;
  public
    property MonthName: string read FMonthName write FMonthName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysMonth.Create();
begin
  inherited;
end;

destructor TSysMonth.Destroy;
begin
  inherited;
end;

end.
