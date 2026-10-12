unit AccAccountTransaction;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('acc_account_transaction')]
  TAccAccountTransaction = class(TEntity)
  private
    FAccAccountId: Int64;
    FTransactionDate: TDate;
    FSourceType: SmallInt;
    FSourceId: Int64;
    FDocumentId: Int64;
    FDocumentNo: string;
    FDescription: string;
    FCurrency: string;
    FDebit: Currency;
    FCredit: Currency;
    FBalance: Currency;

    // View (vw_acc_account_transaction) okunabilir alanları
    FAccountCode: string;
    FAccountName: string;
  public
    [Column('acc_account_id')]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('transaction_date')]
    property TransactionDate: TDate read FTransactionDate write FTransactionDate;

    [Column('source_type')]
    property SourceType: SmallInt read FSourceType write FSourceType;

    [Column('source_id')]
    property SourceId: Int64 read FSourceId write FSourceId;

    [Column('document_id')]
    property DocumentId: Int64 read FDocumentId write FDocumentId;

    [Column('document_no')]
    [MaxLength(64)]
    property DocumentNo: string read FDocumentNo write FDocumentNo;

    [Column('description')]
    [MaxLength(256)]
    property Description: string read FDescription write FDescription;

    [Column('currency')]
    [MaxLength(3)]
    property Currency: string read FCurrency write FCurrency;

    [Column('debit')]
    property Debit: Currency read FDebit write FDebit;

    [Column('credit')]
    property Credit: Currency read FCredit write FCredit;

    [Column('balance')]
    property Balance: Currency read FBalance write FBalance;

    [NotMapped]
    property AccountCode: string read FAccountCode write FAccountCode;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccAccountTransaction;
  end;

implementation

constructor TAccAccountTransaction.Create;
begin
  inherited;
end;

destructor TAccAccountTransaction.Destroy;
begin
  inherited;
end;

function TAccAccountTransaction.Clone: TAccAccountTransaction;
begin
  Result := TAccAccountTransaction.Create;
  Result.Id := Self.Id;
  Result.AccAccountId := Self.AccAccountId;
  Result.TransactionDate := Self.TransactionDate;
  Result.SourceType := Self.SourceType;
  Result.SourceId := Self.SourceId;
  Result.DocumentId := Self.DocumentId;
  Result.DocumentNo := Self.DocumentNo;
  Result.Description := Self.Description;
  Result.Currency := Self.Currency;
  Result.Debit := Self.Debit;
  Result.Credit := Self.Credit;
  Result.Balance := Self.Balance;
  Result.AccountCode := Self.AccountCode;
  Result.AccountName := Self.AccountName;
end;

end.
