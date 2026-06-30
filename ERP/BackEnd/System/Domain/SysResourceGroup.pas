unit SysResourceGroup;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_resource_groups')]
  TSysResourceGroup = class(TEntity)
  private
    FGroupName: string;
  public
    [Column('group_name'), MaxLength(64), Required()]
    property GroupName: string read FGroupName write FGroupName;
  end;

implementation

end.
