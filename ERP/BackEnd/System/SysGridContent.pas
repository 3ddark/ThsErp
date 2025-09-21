unit SysGridContent;

interface

uses SysUtils, Classes, Types, BaseEntity;

type
  [TableName('sys_grid_contents')]
  TSysGridContents = class(TEntity)
  private
    FDayName: TEntityField<string>;
  public
    property DayName: TEntityField<string> read FDayName write FDayName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysGridContents.Create();
begin
  inherited;
  FDayName := TEntityField<string>.Create(Self, 'day_name');
end;

destructor TSysGridContents.Destroy;
begin
  inherited;
end;

end.
