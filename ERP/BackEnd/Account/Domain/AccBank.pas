unit AccBank;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('acc_bank')]
  TAccBank = class(TEntity)
  private
    FSWiftCode: string;
    FBankName: string;
  public
    [Column('bank_name'), MaxLength(128), Required()]
    property BankName: string read FBankName write FBankName;

    [Column('swift_code'), MaxLength(16)]
    property SWiftCode: string read FSWiftCode write FSWiftCode;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccBank;
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

function TAccBank.Clone: TAccBank;
begin
  Result := TAccBank.Create;
  Result.Id := Self.Id;
  Result.SWiftCode := Self.SWiftCode;
  Result.BankName := Self.BankName;
end;

end.
