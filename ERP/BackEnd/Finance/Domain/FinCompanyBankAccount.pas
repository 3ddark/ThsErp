unit FinCompanyBankAccount;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('fin_company_bank_account')]
  TFinCompanyBankAccount = class(TEntity)
  private
    FAccBankId: Int64;
    FBranchCode: string;
    FBranchName: string;
    FSysCityId: Int64;
    FAccountNo: string;
    FIban: string;
    FCurrency: string;
    FAccountHolder: string;
    FShowOnCheque: Boolean;
    FShowOnNote: Boolean;
    FShowOnPrint: Boolean;
    FSortOrder: SmallInt;
    FIsActive: Boolean;
    FDescription: string;

    // View (vw_fin_company_bank_account) okunabilir alanları
    FBankName: string;
    FCityName: string;
    FPrintText: string;
  public
    [Column('acc_bank_id')]
    [Required()]
    property AccBankId: Int64 read FAccBankId write FAccBankId;

    [Column('branch_code')]
    [MaxLength(16)]
    property BranchCode: string read FBranchCode write FBranchCode;

    [Column('branch_name')]
    [MaxLength(64)]
    property BranchName: string read FBranchName write FBranchName;

    [Column('sys_city_id')]
    property SysCityId: Int64 read FSysCityId write FSysCityId;

    [Column('account_no')]
    [MaxLength(32)]
    property AccountNo: string read FAccountNo write FAccountNo;

    [Column('iban')]
    [MaxLength(34), Required(TLangKeys.TValidation.Required, True)]
    property Iban: string read FIban write FIban;

    [Column('currency')]
    [MaxLength(3)]
    property Currency: string read FCurrency write FCurrency;

    [Column('account_holder')]
    [MaxLength(128)]
    property AccountHolder: string read FAccountHolder write FAccountHolder;

    [Column('show_on_cheque')]
    property ShowOnCheque: Boolean read FShowOnCheque write FShowOnCheque;

    [Column('show_on_note')]
    property ShowOnNote: Boolean read FShowOnNote write FShowOnNote;

    [Column('show_on_print')]
    property ShowOnPrint: Boolean read FShowOnPrint write FShowOnPrint;

    [Column('sort_order')]
    property SortOrder: SmallInt read FSortOrder write FSortOrder;

    [Column('is_active')]
    property IsActive: Boolean read FIsActive write FIsActive;

    [Column('description')]
    [MaxLength(256)]
    property Description: string read FDescription write FDescription;

    [NotMapped]
    property BankName: string read FBankName write FBankName;

    [NotMapped]
    property CityName: string read FCityName write FCityName;

    [NotMapped]
    property PrintText: string read FPrintText write FPrintText;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TFinCompanyBankAccount;
  end;

implementation

constructor TFinCompanyBankAccount.Create;
begin
  inherited;
  FShowOnPrint := True;
  FIsActive := True;
end;

destructor TFinCompanyBankAccount.Destroy;
begin
  inherited;
end;

function TFinCompanyBankAccount.Clone: TFinCompanyBankAccount;
begin
  Result := TFinCompanyBankAccount.Create;
  Result.Id := Self.Id;
  Result.AccBankId := Self.AccBankId;
  Result.BranchCode := Self.BranchCode;
  Result.BranchName := Self.BranchName;
  Result.SysCityId := Self.SysCityId;
  Result.AccountNo := Self.AccountNo;
  Result.Iban := Self.Iban;
  Result.Currency := Self.Currency;
  Result.AccountHolder := Self.AccountHolder;
  Result.ShowOnCheque := Self.ShowOnCheque;
  Result.ShowOnNote := Self.ShowOnNote;
  Result.ShowOnPrint := Self.ShowOnPrint;
  Result.SortOrder := Self.SortOrder;
  Result.IsActive := Self.IsActive;
  Result.Description := Self.Description;
  Result.BankName := Self.BankName;
  Result.CityName := Self.CityName;
  Result.PrintText := Self.PrintText;
end;

end.
