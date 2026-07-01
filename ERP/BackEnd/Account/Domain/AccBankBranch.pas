unit AccBankBranch;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes, AccBank;

type
  [Table('acc_bank_branch')]
  TAccBankBranch = class(TEntity)
  private
    FBankId: Int64;
    FCode: Integer;
    FName: string;
    FCityId: Int64;
    FBank: TAccBank;
  public
    [Column('bank_id'), Required()]
    property BankId: Int64 read FBankId write FBankId;

    [Column('code'), Required()]
    property Code: Integer read FCode write FCode;

    [Column('name'), MaxLength(64), Required()]
    property Name: string read FName write FName;

    [Column('city_id'), Required()]
    property CityId: Int64 read FCityId write FCityId;

    [BelongsTo('bank_id', 'id')]
    property Bank: TAccBank read FBank write FBank;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TAccBankBranch.Create();
begin
  inherited;
  FBank := TAccBank.Create;
end;

destructor TAccBankBranch.Destroy;
begin
  if Assigned(FBank) then FreeAndNil(FBank);

  inherited;
end;

end.
