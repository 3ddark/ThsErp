unit SysResource;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes, SysResourceGroup;

type
  [Table('sys_resources')]
  TSysResource = class(TEntity)
  private
    FResourceCode: string;
    FResourceName: string;
    FResourceGroupId: Int64;
    FResourceGroup: TSysResourceGroup;
  public
    [Column('resource_code')]
    property ResourceCode: string read FResourceCode write FResourceCode;

    [Column('resource_name')]
    property ResourceName: string read FResourceName write FResourceName;

    [Column('resource_group_id')]
    property ResourceGroupId: Int64 read FResourceGroupId write FResourceGroupId;

    [BelongsTo('resource_group_id', 'id')]
    property ResourceGroup: TSysResourceGroup read FResourceGroup write FResourceGroup;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysResource.Create();
begin
  inherited;
  FResourceGroup := TSysResourceGroup.Create;
end;

destructor TSysResource.Destroy;
begin
  if Assigned(FResourceGroup) then
    FreeAndNil(FResourceGroup);

  inherited;
end;

end.
