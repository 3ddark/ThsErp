unit SysPermissionGroup;

interface

uses SysUtils, Classes, Types, BaseEntity;

type
  [TableName('sys_permission_groups')]
  TSysPermissionGroup = class(TEntity)
  private
    FGroupName: TEntityField<string>;
  public
    property GroupName: TEntityField<string> read FGroupName write FGroupName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysPermissionGroup.Create();
begin
  inherited;
  FGroupName := TEntityField<string>.Create(Self, 'group_name');
end;

destructor TSysPermissionGroup.Destroy;
begin
  inherited;
end;

end.
