unit FinCreditCardTransaction;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('fin_credit_card_transaction')]
  TFinCreditCardTransaction = class(TEntity)
  private
    FFinCreditCardId: Int64;
    FTransactionDate: TDate;
    FTransactionType: SmallInt;
    FAccAccountId: Int64;
    FAmount: Currency;
    FInstallmentCount: SmallInt;
    FDescription: string;

    // View (vw_fin_credit_card_transaction) okunabilir alanları
    FCardName: string;
    FCurrency: string;
    FAccountCode: string;
    FAccountName: string;
  public
    [Column('fin_credit_card_id')]
    [Required()]
    property FinCreditCardId: Int64 read FFinCreditCardId write FFinCreditCardId;

    [Column('transaction_date')]
    [Required()]
    property TransactionDate: TDate read FTransactionDate write FTransactionDate;

    [Column('transaction_type')]
    [Required()]
    property TransactionType: SmallInt read FTransactionType write FTransactionType;

    [Column('acc_account_id')]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('amount')]
    property Amount: Currency read FAmount write FAmount;

    [Column('installment_count')]
    property InstallmentCount: SmallInt read FInstallmentCount write FInstallmentCount;

    [Column('description')]
    [MaxLength(256)]
    property Description: string read FDescription write FDescription;

    [NotMapped]
    property CardName: string read FCardName write FCardName;

    [NotMapped]
    property Currency: string read FCurrency write FCurrency;

    [NotMapped]
    property AccountCode: string read FAccountCode write FAccountCode;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TFinCreditCardTransaction;
  end;

implementation

constructor TFinCreditCardTransaction.Create;
begin
  inherited;
  FTransactionDate := Date;
  FInstallmentCount := 1;
end;

destructor TFinCreditCardTransaction.Destroy;
begin
  inherited;
end;

function TFinCreditCardTransaction.Clone: TFinCreditCardTransaction;
begin
  Result := TFinCreditCardTransaction.Create;
  Result.Id := Self.Id;
  Result.FinCreditCardId := Self.FinCreditCardId;
  Result.TransactionDate := Self.TransactionDate;
  Result.TransactionType := Self.TransactionType;
  Result.AccAccountId := Self.AccAccountId;
  Result.Amount := Self.Amount;
  Result.InstallmentCount := Self.InstallmentCount;
  Result.Description := Self.Description;
  Result.CardName := Self.CardName;
  Result.Currency := Self.Currency;
  Result.AccountCode := Self.AccountCode;
  Result.AccountName := Self.AccountName;
end;

end.
