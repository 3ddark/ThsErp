unit SysAccessRight;

interface

uses SysUtils, Classes, Types, BaseEntity;

type
  [TableName('sys_regions')]
  TSysAccessRight = class(TEntity)
  private
    FPermissionId: TEntityField<Int64>;
    FIsRead: TEntityField<Boolean>;
    FIsAdd: TEntityField<Boolean>;
    FIsUpdate: TEntityField<Boolean>;
    FIsDelete: TEntityField<Boolean>;
    FIsSpecial: TEntityField<Boolean>;
    FUserId: TEntityField<Int64>;
  public
    property PermissionId: TEntityField<Int64> read FPermissionId write FPermissionId;
    property IsRead: TEntityField<Boolean> read FIsRead write FIsRead;
    property IsAdd: TEntityField<Boolean> read FIsAdd write FIsAdd;
    property IsUpdate: TEntityField<Boolean> read FIsUpdate write FIsUpdate;
    property IsDelete: TEntityField<Boolean> read FIsDelete write FIsDelete;
    property IsSpecial: TEntityField<Boolean> read FIsSpecial write FIsSpecial;
    property UserId: TEntityField<Int64> read FUserId write FUserId;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysAccessRight.Create();
begin
  inherited;
  FPermissionId := TEntityField<Int64>.Create(Self, 'permission_id');
  FIsRead := TEntityField<Boolean>.Create(Self, 'is_read');
  FIsAdd := TEntityField<Boolean>.Create(Self, 'is_add');
  FIsUpdate := TEntityField<Boolean>.Create(Self, 'is_update');
  FIsDelete := TEntityField<Boolean>.Create(Self, 'is_delete');
  FIsSpecial := TEntityField<Boolean>.Create(Self, 'is_special');
  FUserId := TEntityField<Int64>.Create(Self, 'user_id');
end;

destructor TSysAccessRight.Destroy;
begin
  inherited;
end;

end.
