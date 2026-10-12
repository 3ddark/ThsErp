unit FinCreditCard;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('fin_credit_card')]
  TFinCreditCard = class(TEntity)
  private
    FCardName: string;
    FAccBankId: Int64;
    FCardHolder: string;
    FCardLastDigits: string;
    FCardLimit: Currency;
    FStatementDay: SmallInt;
    FPaymentDay: SmallInt;
    FCurrency: string;
    FAccAccountCode: string;
    FIsActive: Boolean;
    FNotes: string;

    // View (vw_fin_credit_card) okunabilir alanları
    FBankName: string;
    FAccountName: string;
  public
    [Column('card_name')]
    [MaxLength(64), Required(TLangKeys.TValidation.Required, True)]
    property CardName: string read FCardName write FCardName;

    [Column('acc_bank_id')]
    [Required()]
    property AccBankId: Int64 read FAccBankId write FAccBankId;

    [Column('card_holder')]
    [MaxLength(128)]
    property CardHolder: string read FCardHolder write FCardHolder;

    [Column('card_last_digits')]
    [MaxLength(4)]
    property CardLastDigits: string read FCardLastDigits write FCardLastDigits;

    [Column('card_limit')]
    property CardLimit: Currency read FCardLimit write FCardLimit;

    [Column('statement_day')]
    property StatementDay: SmallInt read FStatementDay write FStatementDay;

    [Column('payment_day')]
    property PaymentDay: SmallInt read FPaymentDay write FPaymentDay;

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
    property AccountName: string read FAccountName write FAccountName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TFinCreditCard;
  end;

implementation

constructor TFinCreditCard.Create;
begin
  inherited;
  FIsActive := True;
end;

destructor TFinCreditCard.Destroy;
begin
  inherited;
end;

function TFinCreditCard.Clone: TFinCreditCard;
begin
  Result := TFinCreditCard.Create;
  Result.Id := Self.Id;
  Result.CardName := Self.CardName;
  Result.AccBankId := Self.AccBankId;
  Result.CardHolder := Self.CardHolder;
  Result.CardLastDigits := Self.CardLastDigits;
  Result.CardLimit := Self.CardLimit;
  Result.StatementDay := Self.StatementDay;
  Result.PaymentDay := Self.PaymentDay;
  Result.Currency := Self.Currency;
  Result.AccAccountCode := Self.AccAccountCode;
  Result.IsActive := Self.IsActive;
  Result.Notes := Self.Notes;
  Result.BankName := Self.BankName;
  Result.AccountName := Self.AccountName;
end;

end.
