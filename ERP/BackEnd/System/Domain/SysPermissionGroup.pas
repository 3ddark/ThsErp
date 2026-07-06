unit SysPermissionGroup;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_permission_group')]
  TSysPermissionGroup = class(TEntity)
  private
    FName: string;
  public
    [Column('name'), MaxLength(64), Required()]
    property Name: string read FName write FName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysPermissionGroup.Create();
begin
  inherited;
end;

destructor TSysPermissionGroup.Destroy;
begin
  inherited;
end;

end.
