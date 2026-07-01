unit SetAccAccountType;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('acc_set_account_type')]
  TSetAccAccountType = class(TEntity)
  private
    FName: string;
  public
    [Column('name'), MaxLength(16), Required()]
    property Name: string read FName write FName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetAccAccountType.Create();
begin
  inherited;
end;

destructor TSetAccAccountType.Destroy;
begin
  inherited;
end;

end.
