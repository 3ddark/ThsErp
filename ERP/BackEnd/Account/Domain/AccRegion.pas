unit AccRegion;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('acc_region')]
  TAccRegion = class(TEntity)
  private
    FName: string;
  public
    [Column('name'), MaxLength(32), Required()]
    property Name: string read FName write FName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TAccRegion.Create();
begin
  inherited;
end;

destructor TAccRegion.Destroy;
begin
  inherited;
end;

end.
