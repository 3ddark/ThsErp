unit AccAccountPlan;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('acc_account_plan')]
  TAccAccountPlan = class(TEntity)
  private
    FCode: string;
    FName: string;
    FLevel: SmallInt;
  public
    [Column('code'), MaxLength(16), Required()]
    property Code: string read FCode write FCode;

    [Column('name'), MaxLength(128), Required()]
    property Name: string read FName write FName;

    [Column('level'), Required()]
    property Level: SmallInt read FLevel write FLevel;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TAccAccountPlan.Create();
begin
  inherited;
end;

destructor TAccAccountPlan.Destroy;
begin
  inherited;
end;

end.
