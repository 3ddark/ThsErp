unit FinPosTerminal;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('fin_pos_terminal')]
  TFinPosTerminal = class(TEntity)
  private
    FPosName: string;
    FAccBankId: Int64;
    FTerminalNo: string;
    FCommissionRate: Currency;
    FBlockedDays: SmallInt;
    FCurrency: string;
    FAccAccountCode: string;
    FIsActive: Boolean;
    FNotes: string;

    // View (vw_fin_pos_terminal) okunabilir alanları
    FBankName: string;
    FAccountName: string;
  public
    [Column('pos_name')]
    [MaxLength(64), Required(TLangKeys.TValidation.Required, True)]
    property PosName: string read FPosName write FPosName;

    [Column('acc_bank_id')]
    [Required()]
    property AccBankId: Int64 read FAccBankId write FAccBankId;

    [Column('terminal_no')]
    [MaxLength(32)]
    property TerminalNo: string read FTerminalNo write FTerminalNo;

    [Column('commission_rate')]
    property CommissionRate: Currency read FCommissionRate write FCommissionRate;

    [Column('blocked_days')]
    property BlockedDays: SmallInt read FBlockedDays write FBlockedDays;

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

    function Clone: TFinPosTerminal;
  end;

implementation

constructor TFinPosTerminal.Create;
begin
  inherited;
  FIsActive := True;
end;

destructor TFinPosTerminal.Destroy;
begin
  inherited;
end;

function TFinPosTerminal.Clone: TFinPosTerminal;
begin
  Result := TFinPosTerminal.Create;
  Result.Id := Self.Id;
  Result.PosName := Self.PosName;
  Result.AccBankId := Self.AccBankId;
  Result.TerminalNo := Self.TerminalNo;
  Result.CommissionRate := Self.CommissionRate;
  Result.BlockedDays := Self.BlockedDays;
  Result.Currency := Self.Currency;
  Result.AccAccountCode := Self.AccAccountCode;
  Result.IsActive := Self.IsActive;
  Result.Notes := Self.Notes;
  Result.BankName := Self.BankName;
  Result.AccountName := Self.AccountName;
end;

end.
