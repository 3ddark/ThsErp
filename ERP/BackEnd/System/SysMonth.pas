unit SysMonth;

interface

uses SysUtils, Classes, Types, BaseEntity;

type
  [TableName('sys_months')]
  TSysMonth = class(TEntity)
  private
    FMonthName: TEntityField<string>;
  public
    property MonthName: TEntityField<string> read FMonthName write FMonthName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysMonth.Create();
begin
  inherited;
  FMonthName := TEntityField<string>.Create(Self, 'month_name');
end;

destructor TSysMonth.Destroy;
begin
  inherited;
end;

end.
