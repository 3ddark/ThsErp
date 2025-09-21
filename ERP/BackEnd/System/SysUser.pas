unit SysUser;

interface

uses SysUtils, Classes, Types, BaseEntity;

type
  [TableName('sys_users')]
  TSysUser = class(TEntity)
  private
    FDayName: TEntityField<string>;
  public
    property DayName: TEntityField<string> read FDayName write FDayName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysUser.Create();
begin
  inherited;
  FDayName := TEntityField<string>.Create(Self, 'day_name');
end;

destructor TSysUser.Destroy;
begin
  inherited;
end;

end.
