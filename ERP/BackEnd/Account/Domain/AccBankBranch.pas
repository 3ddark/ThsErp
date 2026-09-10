unit AccBankBranch;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, AccBank, SysCity;

type
  [Table('acc_bank_branch')]
  TAccBankBranch = class(TEntity)
  private
    FAccBankId: Int64;
    FCode: Integer;
    FName: string;
    FSysCityId: Int64;

    FAccBank: TAccBank;
    FSysCity: TSysCity;
  public
    [Column('acc_bank_id'), Required()]
    property AccBankId: Int64 read FAccBankId write FAccBankId;

    [Column('code'), Required()]
    property Code: Integer read FCode write FCode;

    [Column('name'), MaxLength(64), Required()]
    property Name: string read FName write FName;

    [Column('sys_city_id'), Required()]
    property SysCityId: Int64 read FSysCityId write FSysCityId;

    [BelongsTo('AccBankId')]
    property AccBank: TAccBank read FAccBank write FAccBank;

    [BelongsTo('SysCityId')]
    property SysCity: TSysCity read FSysCity write FSysCity;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccBankBranch;
  end;

implementation

constructor TAccBankBranch.Create();
begin
  inherited;
  FAccBank := TAccBank.Create;
end;

destructor TAccBankBranch.Destroy;
begin
  if Assigned(FAccBank) then FreeAndNil(FAccBank);

  inherited;
end;

function TAccBankBranch.Clone: TAccBankBranch;
begin
  Result := TAccBankBranch.Create;
  Result.AccBankId := Self.AccBankId;
  Result.Code := Self.Code;
  Result.Name := Self.Name;
  Result.SysCityId := Self.SysCityId;

  if Assigned(Self.AccBank) then
    Result.AccBank := Self.AccBank.Clone;

  if Assigned(Self.SysCity) then
    Result.SysCity:= Self.SysCity.Clone;
end;

end.
