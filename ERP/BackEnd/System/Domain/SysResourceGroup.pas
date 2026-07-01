unit SysResourceGroup;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_kaynak_gruplari')]
  TSysResourceGroup = class(TEntity)
  private
    FName: string;
  public
    [Column('ad'), MaxLength(64), Required()]
    property Name: string read FName write FName;
  end;

implementation

end.
