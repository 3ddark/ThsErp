unit FinChequeNoteTransaction;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('fin_cheque_note_transaction')]
  TFinChequeNoteTransaction = class(TEntity)
  private
    FFinChequeNoteId: Int64;
    FTransactionDate: TDate;
    FTransactionType: SmallInt;
    FAccAccountId: Int64;
    FAccBankId: Int64;
    FDescription: string;

    // View (vw_fin_cheque_note_transaction) okunabilir alanları
    FPortfolioNo: string;
    FSerialNo: string;
    FAccountCode: string;
    FAccountName: string;
    FBankName: string;
  public
    [Column('fin_cheque_note_id')]
    [Required()]
    property FinChequeNoteId: Int64 read FFinChequeNoteId write FFinChequeNoteId;

    [Column('transaction_date')]
    [Required()]
    property TransactionDate: TDate read FTransactionDate write FTransactionDate;

    [Column('transaction_type')]
    [Required()]
    property TransactionType: SmallInt read FTransactionType write FTransactionType;

    [Column('acc_account_id')]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('acc_bank_id')]
    property AccBankId: Int64 read FAccBankId write FAccBankId;

    [Column('description')]
    [MaxLength(256)]
    property Description: string read FDescription write FDescription;

    [NotMapped]
    property PortfolioNo: string read FPortfolioNo write FPortfolioNo;

    [NotMapped]
    property SerialNo: string read FSerialNo write FSerialNo;

    [NotMapped]
    property AccountCode: string read FAccountCode write FAccountCode;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    [NotMapped]
    property BankName: string read FBankName write FBankName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TFinChequeNoteTransaction;
  end;

implementation

constructor TFinChequeNoteTransaction.Create;
begin
  inherited;
  FTransactionDate := Date;
end;

destructor TFinChequeNoteTransaction.Destroy;
begin
  inherited;
end;

function TFinChequeNoteTransaction.Clone: TFinChequeNoteTransaction;
begin
  Result := TFinChequeNoteTransaction.Create;
  Result.Id := Self.Id;
  Result.FinChequeNoteId := Self.FinChequeNoteId;
  Result.TransactionDate := Self.TransactionDate;
  Result.TransactionType := Self.TransactionType;
  Result.AccAccountId := Self.AccAccountId;
  Result.AccBankId := Self.AccBankId;
  Result.Description := Self.Description;
  Result.PortfolioNo := Self.PortfolioNo;
  Result.SerialNo := Self.SerialNo;
  Result.AccountCode := Self.AccountCode;
  Result.AccountName := Self.AccountName;
  Result.BankName := Self.BankName;
end;

end.
