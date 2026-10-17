unit EInvDiib;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, EInvLookup;

type
  [Table('einv_diib')]
  TEInvDiib = class(TEntity)
  private
    FDocumentNo: string;
    FHolderType: SmallInt;
    FAccAccountId: Int64;
    FIssueDate: TDate;
    FValidUntil: TDate;
    FDescription: string;
    FIsActive: Boolean;

    // View (vw_einv_diib) okunabilir alanları
    FAccountCode: string;
    FAccountName: string;
  public
    [Column('document_no')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property DocumentNo: string read FDocumentNo write FDocumentNo;

    [Column('holder_type')]
    [Required()]
    property HolderType: SmallInt read FHolderType write FHolderType;

    [Column('acc_account_id')]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('issue_date')]
    property IssueDate: TDate read FIssueDate write FIssueDate;

    [Column('valid_until')]
    property ValidUntil: TDate read FValidUntil write FValidUntil;

    [Column('description')]
    [MaxLength(256)]
    property Description: string read FDescription write FDescription;

    [Column('is_active')]
    property IsActive: Boolean read FIsActive write FIsActive;

    [NotMapped]
    property AccountCode: string read FAccountCode write FAccountCode;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEInvDiib;
  end;

implementation

constructor TEInvDiib.Create;
begin
  inherited;
  FIsActive := True;
  FHolderType := EINV_DIIB_CUSTOMER;
end;

destructor TEInvDiib.Destroy;
begin
  inherited;
end;

function TEInvDiib.Clone: TEInvDiib;
begin
  Result := TEInvDiib.Create;
  Result.Id := Self.Id;
  Result.DocumentNo := Self.DocumentNo;
  Result.HolderType := Self.HolderType;
  Result.AccAccountId := Self.AccAccountId;
  Result.IssueDate := Self.IssueDate;
  Result.ValidUntil := Self.ValidUntil;
  Result.Description := Self.Description;
  Result.IsActive := Self.IsActive;
  Result.AccountCode := Self.AccountCode;
  Result.AccountName := Self.AccountName;
end;

end.
