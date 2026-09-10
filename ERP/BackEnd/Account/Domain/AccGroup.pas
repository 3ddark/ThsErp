unit AccGroup;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('acc_group')]
  TAccGroup = class(TEntity)
  private
    FName: string;
  public
    [Column('name'), MaxLength(16), Required()]
    property Name: string read FName write FName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccGroup;
  end;

implementation

constructor TAccGroup.Create();
begin
  inherited;
end;

destructor TAccGroup.Destroy;
begin
  inherited;
end;

function TAccGroup.Clone: TAccGroup;
begin
  Result := TAccGroup.Create;
  Result.Name := Self.Name;
end;

end.
