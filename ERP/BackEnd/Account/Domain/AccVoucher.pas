unit AccVoucher;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, AccVoucherDetail;

type
  // Muhasebe fişi (mahsup / tahsil / tediye / açılış / kapanış). Toplamlar ve yevmiye no servis tarafından tutulur.
  [Table('acc_voucher')]
  TAccVoucher = class(TEntity)
  private
    // Kalemler (sahiplenir): servis yükler / yazar; durum TDetailEntity (Id işareti + Deleted)
    FLines: TObjectList<TAccVoucherDetail>;
    FVoucherNo: string;
    FVoucherDate: TDate;
    FVoucherType: SmallInt;
    FJournalNo: Integer;
    FDescription: string;
    FTotalDebit: Currency;
    FTotalCredit: Currency;
  public
    [Column('voucher_no')]
    [MaxLength(16)]
    property VoucherNo: string read FVoucherNo write FVoucherNo;

    [Column('voucher_date')]
    [Required()]
    property VoucherDate: TDate read FVoucherDate write FVoucherDate;

    [Column('voucher_type')]
    [Required()]
    property VoucherType: SmallInt read FVoucherType write FVoucherType;

    [Column('journal_no')]
    property JournalNo: Integer read FJournalNo write FJournalNo;

    [Column('description')]
    [MaxLength(256)]
    property Description: string read FDescription write FDescription;

    [Column('total_debit')]
    property TotalDebit: Currency read FTotalDebit write FTotalDebit;

    [Column('total_credit')]
    property TotalCredit: Currency read FTotalCredit write FTotalCredit;

    // Kolon değil (nesne özelliği): BusinessFindById ile dolar, BusinessSaveWithDetails ile yazılır
    property Lines: TObjectList<TAccVoucherDetail> read FLines;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccVoucher;
  end;

  // Kalemden başlığa tipli erişim: Line.Header.VoucherNo (HeaderEntity zayıf referans, sahiplenmez)
  TAccVoucherDetailHelper = class helper for TAccVoucherDetail
  private
    function GetHeader: TAccVoucher;
    procedure SetHeader(const Value: TAccVoucher);
  public
    property Header: TAccVoucher read GetHeader write SetHeader;
  end;

implementation

{ TAccVoucherDetailHelper }

function TAccVoucherDetailHelper.GetHeader: TAccVoucher;
begin
  Result := TAccVoucher(HeaderEntity);
end;

procedure TAccVoucherDetailHelper.SetHeader(const Value: TAccVoucher);
begin
  HeaderEntity := Value;
end;

{ TAccVoucher }

constructor TAccVoucher.Create;
begin
  inherited;
  FLines := TObjectList<TAccVoucherDetail>.Create(True);
  FVoucherDate := Date;
  FVoucherType := 1;
end;

destructor TAccVoucher.Destroy;
begin
  FLines.Free;
  inherited;
end;

// Kalemler dahil derin kopya; kopyanın kalemleri kopya başlığa bağlanır
function TAccVoucher.Clone: TAccVoucher;
var
  LLine, LCopy: TAccVoucherDetail;
begin
  Result := TAccVoucher.Create;
  Result.Id := Self.Id;
  Result.VoucherNo := Self.VoucherNo;
  Result.VoucherDate := Self.VoucherDate;
  Result.VoucherType := Self.VoucherType;
  Result.JournalNo := Self.JournalNo;
  Result.Description := Self.Description;
  Result.TotalDebit := Self.TotalDebit;
  Result.TotalCredit := Self.TotalCredit;
  for LLine in Self.FLines do
  begin
    LCopy := LLine.Clone;
    LCopy.HeaderEntity := Result;
    Result.FLines.Add(LCopy);
  end;
end;

end.
