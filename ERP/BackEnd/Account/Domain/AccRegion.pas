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

    function Clone: TAccRegion;
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

function TAccRegion.Clone: TAccRegion;
begin
  Result := TAccRegion.Create;
  Result.Name := Self.Name;
end;

end.
