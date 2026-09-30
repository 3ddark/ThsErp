unit AccBankBranch;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('acc_bank_branch')]
  TAccBankBranch = class(TEntity)
  private
    FAccBankId: Int64;
    FBranchCode: Integer;
    FBranchName: string;
    FSysCityId: Int64;

    // View (vw_acc_bank_branch) okunabilir alanları
    FBankName: string;
    FCityName: string;
  public
    [Column('acc_bank_id')]
    property AccBankId: Int64 read FAccBankId write FAccBankId;

    [Column('branch_code')]
    property BranchCode: Integer read FBranchCode write FBranchCode;

    [Column('branch_name')]
    [MaxLength(128), Required(TLangKeys.TValidation.Required, True)]
    property BranchName: string read FBranchName write FBranchName;

    [Column('sys_city_id')]
    property SysCityId: Int64 read FSysCityId write FSysCityId;

    [NotMapped]
    property BankName: string read FBankName write FBankName;

    [NotMapped]
    property CityName: string read FCityName write FCityName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccBankBranch;
  end;

implementation

constructor TAccBankBranch.Create;
begin
  inherited;
end;

destructor TAccBankBranch.Destroy;
begin
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
  Result.BankName := Self.BankName;
  Result.CityName := Self.CityName;
end;

end.
