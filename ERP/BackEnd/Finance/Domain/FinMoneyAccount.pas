unit FinMoneyAccount;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('fin_money_account')]
  TFinMoneyAccount = class(TEntity)
  private
    FAccountKind: SmallInt;
    FCode: string;
    FName: string;
    FAccBankId: Int64;
    FAccBankBranchId: Int64;
    FAccountNo: string;
    FIban: string;
    FCurrency: string;
    FAccAccountCode: string;
    FIsActive: Boolean;
    FNotes: string;

    // View (vw_fin_money_account) okunabilir alanları
    FBankName: string;
    FBranchName: string;
    FAccountName: string;
  public
    [Column('account_kind')]
    [Required()]
    property AccountKind: SmallInt read FAccountKind write FAccountKind;

    [Column('code')]
    [MaxLength(16), Required(TLangKeys.TValidation.Required, True)]
    property Code: string read FCode write FCode;

    [Column('name')]
    [MaxLength(64), Required(TLangKeys.TValidation.Required, True)]
    property Name: string read FName write FName;

    [Column('acc_bank_id')]
    property AccBankId: Int64 read FAccBankId write FAccBankId;

    [Column('acc_bank_branch_id')]
    property AccBankBranchId: Int64 read FAccBankBranchId write FAccBankBranchId;

    [Column('account_no')]
    [MaxLength(32)]
    property AccountNo: string read FAccountNo write FAccountNo;

    [Column('iban')]
    [MaxLength(34)]
    property Iban: string read FIban write FIban;

    [Column('currency')]
    [MaxLength(3)]
    property Currency: string read FCurrency write FCurrency;

    [Column('acc_account_code')]
    [MaxLength(16)]
    property AccAccountCode: string read FAccAccountCode write FAccAccountCode;

    [Column('is_active')]
    property IsActive: Boolean read FIsActive write FIsActive;

    [Column('notes')]
    [MaxLength(512)]
    property Notes: string read FNotes write FNotes;

    [NotMapped]
    property BankName: string read FBankName write FBankName;

    [NotMapped]
    property BranchName: string read FBranchName write FBranchName;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TFinMoneyAccount;
  end;

implementation

constructor TFinMoneyAccount.Create;
begin
  inherited;
  FIsActive := True;
end;

destructor TFinMoneyAccount.Destroy;
begin
  inherited;
end;

function TFinMoneyAccount.Clone: TFinMoneyAccount;
begin
  Result := TFinMoneyAccount.Create;
  Result.Id := Self.Id;
  Result.AccountKind := Self.AccountKind;
  Result.Code := Self.Code;
  Result.Name := Self.Name;
  Result.AccBankId := Self.AccBankId;
  Result.AccBankBranchId := Self.AccBankBranchId;
  Result.AccountNo := Self.AccountNo;
  Result.Iban := Self.Iban;
  Result.Currency := Self.Currency;
  Result.AccAccountCode := Self.AccAccountCode;
  Result.IsActive := Self.IsActive;
  Result.Notes := Self.Notes;
  Result.BankName := Self.BankName;
  Result.BranchName := Self.BranchName;
  Result.AccountName := Self.AccountName;
end;

end.
