unit SetAccOwnershipType;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('acc_set_ownership_type')]
  TSetAccOwnershipType = class(TEntity)
  private
    FName: string;
  public
    [Column('name'), MaxLength(32), Required()]
    property Name: string read FName write FName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetAccOwnershipType.Create();
begin
  inherited;
end;

destructor TSetAccOwnershipType.Destroy;
begin
  inherited;
end;

end.
