unit AccBank;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('acc_bank')]
  TAccBank = class(TEntity)
  private
    FSWiftCode: string;
    FName: string;
  public
    [Column('name'), MaxLength(64), Required()]
    property Name: string read FName write FName;

    [Column('swift_code'), MaxLength(16)]
    property SWiftCode: string read FSWiftCode write FSWiftCode;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TAccBank.Create();
begin
  inherited;
end;

destructor TAccBank.Destroy;
begin
  inherited;
end;

end.
