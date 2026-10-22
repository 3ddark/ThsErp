unit AccVoucherDetail;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  // Fiş kalemi: hareket gören hesaba borç ya da alacak (biri). Fişin Lines listesinde durum TDetailEntity'den;
  // başlığa tipli erişim AccVoucher birimindeki class helper ile (Line.Header.VoucherNo)
  [Table('acc_voucher_detail')]
  TAccVoucherDetail = class(TDetailEntity)
  private
    FAccVoucherId: Int64;
    FLineNo: SmallInt;
    FAccAccountId: Int64;
    FDescription: string;
    FDebit: Currency;
    FCredit: Currency;

    // View (vw_acc_voucher_detail) okunabilir alanları
    FVoucherNo: string;
    FAccountCode: string;
    FAccountName: string;
  public
    [Column('acc_voucher_id')]
    [Required()]
    property AccVoucherId: Int64 read FAccVoucherId write FAccVoucherId;

    [Column('line_no')]
    property LineNo: SmallInt read FLineNo write FLineNo;

    [Column('acc_account_id')]
    [Required()]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('description')]
    [MaxLength(256)]
    property Description: string read FDescription write FDescription;

    [Column('debit')]
    property Debit: Currency read FDebit write FDebit;

    [Column('credit')]
    property Credit: Currency read FCredit write FCredit;

    [NotMapped]
    property VoucherNo: string read FVoucherNo write FVoucherNo;

    [NotMapped]
    property AccountCode: string read FAccountCode write FAccountCode;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccVoucherDetail;
  end;

implementation

constructor TAccVoucherDetail.Create;
begin
  inherited;
end;

destructor TAccVoucherDetail.Destroy;
begin
  inherited;
end;

function TAccVoucherDetail.Clone: TAccVoucherDetail;
begin
  // başlık referansı kopyalanmaz (kopyayı sahiplenen başlık verir)
  Result := TAccVoucherDetail.Create;
  Result.Id := Self.Id;
  Result.Deleted := Self.Deleted;
  Result.AccVoucherId := Self.AccVoucherId;
  Result.LineNo := Self.LineNo;
  Result.AccAccountId := Self.AccAccountId;
  Result.Description := Self.Description;
  Result.Debit := Self.Debit;
  Result.Credit := Self.Credit;
  Result.VoucherNo := Self.VoucherNo;
  Result.AccountCode := Self.AccountCode;
  Result.AccountName := Self.AccountName;
end;

end.
