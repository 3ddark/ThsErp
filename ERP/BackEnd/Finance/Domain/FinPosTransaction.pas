unit FinPosTransaction;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('fin_pos_transaction')]
  TFinPosTransaction = class(TEntity)
  private
    FFinPosTerminalId: Int64;
    FTransactionDate: TDate;
    FTransactionType: SmallInt;
    FAccAccountId: Int64;
    FAmount: Currency;
    FInstallmentCount: SmallInt;
    FCommissionRate: Currency;
    FCommissionAmount: Currency;
    FNetAmount: Currency;
    FValueDate: TDate;
    FCardHolder: string;
    FCardLastDigits: string;
    FDescription: string;

    // View (vw_fin_pos_transaction) okunabilir alanları
    FPosName: string;
    FCurrency: string;
    FAccountCode: string;
    FAccountName: string;
  public
    [Column('fin_pos_terminal_id')]
    [Required()]
    property FinPosTerminalId: Int64 read FFinPosTerminalId write FFinPosTerminalId;

    [Column('transaction_date')]
    [Required()]
    property TransactionDate: TDate read FTransactionDate write FTransactionDate;

    [Column('transaction_type')]
    [Required()]
    property TransactionType: SmallInt read FTransactionType write FTransactionType;

    [Column('acc_account_id')]
    [Required()]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('amount')]
    property Amount: Currency read FAmount write FAmount;

    [Column('installment_count')]
    property InstallmentCount: SmallInt read FInstallmentCount write FInstallmentCount;

    [Column('commission_rate')]
    property CommissionRate: Currency read FCommissionRate write FCommissionRate;

    [Column('commission_amount')]
    property CommissionAmount: Currency read FCommissionAmount write FCommissionAmount;

    [Column('net_amount')]
    property NetAmount: Currency read FNetAmount write FNetAmount;

    [Column('value_date')]
    property ValueDate: TDate read FValueDate write FValueDate;

    [Column('card_holder')]
    [MaxLength(128)]
    property CardHolder: string read FCardHolder write FCardHolder;

    [Column('card_last_digits')]
    [MaxLength(4)]
    property CardLastDigits: string read FCardLastDigits write FCardLastDigits;

    [Column('description')]
    [MaxLength(256)]
    property Description: string read FDescription write FDescription;

    [NotMapped]
    property PosName: string read FPosName write FPosName;

    [NotMapped]
    property Currency: string read FCurrency write FCurrency;

    [NotMapped]
    property AccountCode: string read FAccountCode write FAccountCode;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TFinPosTransaction;
  end;

implementation

constructor TFinPosTransaction.Create;
begin
  inherited;
  FTransactionDate := Date;
  FTransactionType := 1;
  FInstallmentCount := 1;
end;

destructor TFinPosTransaction.Destroy;
begin
  inherited;
end;

function TFinPosTransaction.Clone: TFinPosTransaction;
begin
  Result := TFinPosTransaction.Create;
  Result.Id := Self.Id;
  Result.FinPosTerminalId := Self.FinPosTerminalId;
  Result.TransactionDate := Self.TransactionDate;
  Result.TransactionType := Self.TransactionType;
  Result.AccAccountId := Self.AccAccountId;
  Result.Amount := Self.Amount;
  Result.InstallmentCount := Self.InstallmentCount;
  Result.CommissionRate := Self.CommissionRate;
  Result.CommissionAmount := Self.CommissionAmount;
  Result.NetAmount := Self.NetAmount;
  Result.ValueDate := Self.ValueDate;
  Result.CardHolder := Self.CardHolder;
  Result.CardLastDigits := Self.CardLastDigits;
  Result.Description := Self.Description;
  Result.PosName := Self.PosName;
  Result.Currency := Self.Currency;
  Result.AccountCode := Self.AccountCode;
  Result.AccountName := Self.AccountName;
end;

end.
