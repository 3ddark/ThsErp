unit FinMoneyLedger;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('fin_money_ledger')]
  TFinMoneyLedger = class(TEntity)
  private
    FFinMoneyTransactionId: Int64;
    FFinMoneyAccountId: Int64;
    FTransactionDate: TDate;
    FTransactionType: SmallInt;
    FTransferMethod: SmallInt;
    FDirection: SmallInt;
    FAmountIn: Currency;
    FAmountOut: Currency;
    FBalance: Currency;
    FOtherFinMoneyAccountId: Int64;
    FAccAccountId: Int64;
    FDocumentNo: string;
    FCounterpartyName: string;
    FDescription: string;

    // View (vw_fin_money_ledger) okunabilir alanları
    FMoneyAccountName: string;
    FCurrency: string;
    FOtherMoneyAccountName: string;
    FAccountCode: string;
    FAccountName: string;
  public
    [Column('fin_money_transaction_id')]
    property FinMoneyTransactionId: Int64 read FFinMoneyTransactionId write FFinMoneyTransactionId;

    [Column('fin_money_account_id')]
    property FinMoneyAccountId: Int64 read FFinMoneyAccountId write FFinMoneyAccountId;

    [Column('transaction_date')]
    property TransactionDate: TDate read FTransactionDate write FTransactionDate;

    [Column('transaction_type')]
    property TransactionType: SmallInt read FTransactionType write FTransactionType;

    [Column('transfer_method')]
    property TransferMethod: SmallInt read FTransferMethod write FTransferMethod;

    [Column('direction')]
    property Direction: SmallInt read FDirection write FDirection;

    [Column('amount_in')]
    property AmountIn: Currency read FAmountIn write FAmountIn;

    [Column('amount_out')]
    property AmountOut: Currency read FAmountOut write FAmountOut;

    [Column('balance')]
    property Balance: Currency read FBalance write FBalance;

    [Column('other_fin_money_account_id')]
    property OtherFinMoneyAccountId: Int64 read FOtherFinMoneyAccountId write FOtherFinMoneyAccountId;

    [Column('acc_account_id')]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('document_no')]
    [MaxLength(32)]
    property DocumentNo: string read FDocumentNo write FDocumentNo;

    [Column('counterparty_name')]
    [MaxLength(128)]
    property CounterpartyName: string read FCounterpartyName write FCounterpartyName;

    [Column('description')]
    [MaxLength(256)]
    property Description: string read FDescription write FDescription;

    [NotMapped]
    property MoneyAccountName: string read FMoneyAccountName write FMoneyAccountName;

    [NotMapped]
    property Currency: string read FCurrency write FCurrency;

    [NotMapped]
    property OtherMoneyAccountName: string read FOtherMoneyAccountName write FOtherMoneyAccountName;

    [NotMapped]
    property AccountCode: string read FAccountCode write FAccountCode;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TFinMoneyLedger;
  end;

implementation

constructor TFinMoneyLedger.Create;
begin
  inherited;
end;

destructor TFinMoneyLedger.Destroy;
begin
  inherited;
end;

function TFinMoneyLedger.Clone: TFinMoneyLedger;
begin
  Result := TFinMoneyLedger.Create;
  Result.Id := Self.Id;
  Result.FinMoneyTransactionId := Self.FinMoneyTransactionId;
  Result.FinMoneyAccountId := Self.FinMoneyAccountId;
  Result.TransactionDate := Self.TransactionDate;
  Result.TransactionType := Self.TransactionType;
  Result.TransferMethod := Self.TransferMethod;
  Result.Direction := Self.Direction;
  Result.AmountIn := Self.AmountIn;
  Result.AmountOut := Self.AmountOut;
  Result.Balance := Self.Balance;
  Result.OtherFinMoneyAccountId := Self.OtherFinMoneyAccountId;
  Result.AccAccountId := Self.AccAccountId;
  Result.DocumentNo := Self.DocumentNo;
  Result.CounterpartyName := Self.CounterpartyName;
  Result.Description := Self.Description;
  Result.MoneyAccountName := Self.MoneyAccountName;
  Result.Currency := Self.Currency;
  Result.OtherMoneyAccountName := Self.OtherMoneyAccountName;
  Result.AccountCode := Self.AccountCode;
  Result.AccountName := Self.AccountName;
end;

end.
