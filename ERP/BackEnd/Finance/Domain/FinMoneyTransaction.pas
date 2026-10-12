unit FinMoneyTransaction;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('fin_money_transaction')]
  TFinMoneyTransaction = class(TEntity)
  private
    FFinMoneyAccountId: Int64;
    FTransactionDate: TDate;
    FTransactionType: SmallInt;
    FTransferMethod: SmallInt;
    FAccAccountId: Int64;
    FTargetFinMoneyAccountId: Int64;
    FAmount: Currency;
    FDocumentNo: string;
    FCounterpartyName: string;
    FCounterpartyIban: string;
    FDescription: string;

    // View (vw_fin_money_transaction) okunabilir alanları
    FMoneyAccountName: string;
    FCurrency: string;
    FAccountCode: string;
    FAccountName: string;
    FTargetMoneyAccountName: string;
  public
    [Column('fin_money_account_id')]
    [Required()]
    property FinMoneyAccountId: Int64 read FFinMoneyAccountId write FFinMoneyAccountId;

    [Column('transaction_date')]
    [Required()]
    property TransactionDate: TDate read FTransactionDate write FTransactionDate;

    [Column('transaction_type')]
    [Required()]
    property TransactionType: SmallInt read FTransactionType write FTransactionType;

    [Column('transfer_method')]
    property TransferMethod: SmallInt read FTransferMethod write FTransferMethod;

    [Column('acc_account_id')]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('target_fin_money_account_id')]
    property TargetFinMoneyAccountId: Int64 read FTargetFinMoneyAccountId write FTargetFinMoneyAccountId;

    [Column('amount')]
    property Amount: Currency read FAmount write FAmount;

    [Column('document_no')]
    [MaxLength(32)]
    property DocumentNo: string read FDocumentNo write FDocumentNo;

    [Column('counterparty_name')]
    [MaxLength(128)]
    property CounterpartyName: string read FCounterpartyName write FCounterpartyName;

    [Column('counterparty_iban')]
    [MaxLength(34)]
    property CounterpartyIban: string read FCounterpartyIban write FCounterpartyIban;

    [Column('description')]
    [MaxLength(256)]
    property Description: string read FDescription write FDescription;

    [NotMapped]
    property MoneyAccountName: string read FMoneyAccountName write FMoneyAccountName;

    [NotMapped]
    property Currency: string read FCurrency write FCurrency;

    [NotMapped]
    property AccountCode: string read FAccountCode write FAccountCode;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    [NotMapped]
    property TargetMoneyAccountName: string read FTargetMoneyAccountName write FTargetMoneyAccountName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TFinMoneyTransaction;
  end;

implementation

constructor TFinMoneyTransaction.Create;
begin
  inherited;
  FTransactionDate := Date;
  FTransactionType := 1;
end;

destructor TFinMoneyTransaction.Destroy;
begin
  inherited;
end;

function TFinMoneyTransaction.Clone: TFinMoneyTransaction;
begin
  Result := TFinMoneyTransaction.Create;
  Result.Id := Self.Id;
  Result.FinMoneyAccountId := Self.FinMoneyAccountId;
  Result.TransactionDate := Self.TransactionDate;
  Result.TransactionType := Self.TransactionType;
  Result.TransferMethod := Self.TransferMethod;
  Result.AccAccountId := Self.AccAccountId;
  Result.TargetFinMoneyAccountId := Self.TargetFinMoneyAccountId;
  Result.Amount := Self.Amount;
  Result.DocumentNo := Self.DocumentNo;
  Result.CounterpartyName := Self.CounterpartyName;
  Result.CounterpartyIban := Self.CounterpartyIban;
  Result.Description := Self.Description;
  Result.MoneyAccountName := Self.MoneyAccountName;
  Result.Currency := Self.Currency;
  Result.AccountCode := Self.AccountCode;
  Result.AccountName := Self.AccountName;
  Result.TargetMoneyAccountName := Self.TargetMoneyAccountName;
end;

end.
