unit FinChequeNote;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('fin_cheque_note')]
  TFinChequeNote = class(TEntity)
  private
    FDocKind: SmallInt;
    FDirection: SmallInt;
    FPortfolioNo: string;
    FSerialNo: string;
    FIssueDate: TDate;
    FDueDate: TDate;
    FAmount: Currency;
    FCurrency: string;
    FAccAccountId: Int64;
    FDrawerName: string;
    FDrawerTaxNo: string;
    FIssuePlace: string;
    FAccBankId: Int64;
    FAccBankBranchId: Int64;
    FBankAccountNo: string;
    FGuarantorName: string;
    FStatus: SmallInt;
    FNotes: string;

    // View (vw_fin_cheque_note) okunabilir alanları
    FAccountCode: string;
    FAccountName: string;
    FBankName: string;
    FBranchName: string;
    FCurrentHolder: string;
  public
    [Column('doc_kind')]
    [Required()]
    property DocKind: SmallInt read FDocKind write FDocKind;

    [Column('direction')]
    [Required()]
    property Direction: SmallInt read FDirection write FDirection;

    [Column('portfolio_no')]
    [MaxLength(16)]
    property PortfolioNo: string read FPortfolioNo write FPortfolioNo;

    [Column('serial_no')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property SerialNo: string read FSerialNo write FSerialNo;

    [Column('issue_date')]
    [Required()]
    property IssueDate: TDate read FIssueDate write FIssueDate;

    [Column('due_date')]
    [Required()]
    property DueDate: TDate read FDueDate write FDueDate;

    [Column('amount')]
    property Amount: Currency read FAmount write FAmount;

    [Column('currency')]
    [MaxLength(3)]
    property Currency: string read FCurrency write FCurrency;

    [Column('acc_account_id')]
    [Required()]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('drawer_name')]
    [MaxLength(128)]
    property DrawerName: string read FDrawerName write FDrawerName;

    [Column('drawer_tax_no')]
    [MaxLength(16)]
    property DrawerTaxNo: string read FDrawerTaxNo write FDrawerTaxNo;

    [Column('issue_place')]
    [MaxLength(64)]
    property IssuePlace: string read FIssuePlace write FIssuePlace;

    [Column('acc_bank_id')]
    property AccBankId: Int64 read FAccBankId write FAccBankId;

    [Column('acc_bank_branch_id')]
    property AccBankBranchId: Int64 read FAccBankBranchId write FAccBankBranchId;

    [Column('bank_account_no')]
    [MaxLength(32)]
    property BankAccountNo: string read FBankAccountNo write FBankAccountNo;

    [Column('guarantor_name')]
    [MaxLength(128)]
    property GuarantorName: string read FGuarantorName write FGuarantorName;

    [Column('status')]
    property Status: SmallInt read FStatus write FStatus;

    [Column('notes')]
    [MaxLength(512)]
    property Notes: string read FNotes write FNotes;

    [NotMapped]
    property AccountCode: string read FAccountCode write FAccountCode;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    [NotMapped]
    property BankName: string read FBankName write FBankName;

    [NotMapped]
    property BranchName: string read FBranchName write FBranchName;

    [NotMapped]
    property CurrentHolder: string read FCurrentHolder write FCurrentHolder;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TFinChequeNote;
  end;

implementation

constructor TFinChequeNote.Create;
begin
  inherited;
  FIssueDate := Date;
  FStatus := 1;
end;

destructor TFinChequeNote.Destroy;
begin
  inherited;
end;

function TFinChequeNote.Clone: TFinChequeNote;
begin
  Result := TFinChequeNote.Create;
  Result.Id := Self.Id;
  Result.DocKind := Self.DocKind;
  Result.Direction := Self.Direction;
  Result.PortfolioNo := Self.PortfolioNo;
  Result.SerialNo := Self.SerialNo;
  Result.IssueDate := Self.IssueDate;
  Result.DueDate := Self.DueDate;
  Result.Amount := Self.Amount;
  Result.Currency := Self.Currency;
  Result.AccAccountId := Self.AccAccountId;
  Result.DrawerName := Self.DrawerName;
  Result.DrawerTaxNo := Self.DrawerTaxNo;
  Result.IssuePlace := Self.IssuePlace;
  Result.AccBankId := Self.AccBankId;
  Result.AccBankBranchId := Self.AccBankBranchId;
  Result.BankAccountNo := Self.BankAccountNo;
  Result.GuarantorName := Self.GuarantorName;
  Result.Status := Self.Status;
  Result.Notes := Self.Notes;
  Result.AccountCode := Self.AccountCode;
  Result.AccountName := Self.AccountName;
  Result.BankName := Self.BankName;
  Result.BranchName := Self.BranchName;
  Result.CurrentHolder := Self.CurrentHolder;
end;

end.
