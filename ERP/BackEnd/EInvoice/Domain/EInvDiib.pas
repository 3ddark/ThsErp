unit EInvDiib;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, EInvLookup, EInvDiibLine;

type
  [Table('einv_diib')]
  TEInvDiib = class(TEntity)
  private
    // Kalemler (sahiplenir): servis yükler / yazar; durum TDetailEntity (Id işareti + Deleted)
    FLines: TObjectList<TEInvDiibLine>;
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

    // Kolon değil (nesne özelliği): BusinessFindById ile dolar, BusinessSaveWithDetails ile yazılır
    property Lines: TObjectList<TEInvDiibLine> read FLines;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEInvDiib;
  end;

  // Kalemden başlığa tipli erişim: Line.Header.DocumentNo (HeaderEntity zayıf referans, sahiplenmez)
  TEInvDiibLineHelper = class helper for TEInvDiibLine
  private
    function GetHeader: TEInvDiib;
    procedure SetHeader(const Value: TEInvDiib);
  public
    property Header: TEInvDiib read GetHeader write SetHeader;
  end;

implementation

{ TEInvDiibLineHelper }

function TEInvDiibLineHelper.GetHeader: TEInvDiib;
begin
  Result := TEInvDiib(HeaderEntity);
end;

procedure TEInvDiibLineHelper.SetHeader(const Value: TEInvDiib);
begin
  HeaderEntity := Value;
end;

{ TEInvDiib }

constructor TEInvDiib.Create;
begin
  inherited;
  FLines := TObjectList<TEInvDiibLine>.Create(True);
  FIsActive := True;
  FHolderType := EINV_DIIB_CUSTOMER;
end;

destructor TEInvDiib.Destroy;
begin
  FLines.Free;
  inherited;
end;

// Kalemler dahil derin kopya; kopyanın kalemleri kopya başlığa bağlanır
function TEInvDiib.Clone: TEInvDiib;
var
  LLine, LCopy: TEInvDiibLine;
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
  for LLine in Self.FLines do
  begin
    LCopy := LLine.Clone;
    LCopy.HeaderEntity := Result;
    Result.FLines.Add(LCopy);
  end;
end;

end.
