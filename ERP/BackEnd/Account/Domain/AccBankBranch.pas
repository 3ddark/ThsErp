unit AccBankBranch;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, AccBank, SysCity;

type
  [Table('acc_bank_branch')]
  TAccBankBranch = class(TEntity)
  private
    FAccBankId: Int64;
    FBranchCode: Integer;
    FBranchName: string;
    FSysCityId: Int64;

    FAccBank: TAccBank;
    FSysCity: TSysCity;
  public
    [Column('acc_bank_id'), Required()]
    property AccBankId: Int64 read FAccBankId write FAccBankId;

    [Column('branch_code'), Required()]
    property BranchCode: Integer read FBranchCode write FBranchCode;

    [Column('branch_name'), MaxLength(128), Required()]
    property BranchName: string read FBranchName write FBranchName;

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
  FAccBank.Free;

  inherited;
end;

function TAccBankBranch.Clone: TAccBankBranch;
begin
  Result := TAccBankBranch.Create;
  Result.Id := Self.Id;
  Result.AccBankId := Self.AccBankId;
  Result.BranchCode := Self.BranchCode;
  Result.BranchName := Self.BranchName;
  Result.SysCityId := Self.SysCityId;

  if Assigned(Self.AccBank) then
  begin
    if Assigned(Result.AccBank) then
      Result.AccBank.Free;
    Result.AccBank := Self.AccBank.Clone;
  end;

  if Assigned(Self.SysCity) then
  begin
    if Assigned(Result.SysCity) then
      Result.SysCity.Free;
    Result.SysCity:= Self.SysCity.Clone;
  end;
end;

end.
