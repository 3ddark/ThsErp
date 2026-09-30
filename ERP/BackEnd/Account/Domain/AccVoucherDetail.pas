unit AccVoucherDetail;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('acc_voucher_detail')]
  TAccVoucherDetail = class(TEntity)
  private
    FAccVoucherId: Int64;

    // View (vw_acc_voucher_detail) okunabilir alanları
    FJournalNo: string;
  public
    [Column('acc_voucher_id')]
    property AccVoucherId: Int64 read FAccVoucherId write FAccVoucherId;

    [NotMapped]
    property JournalNo: string read FJournalNo write FJournalNo;

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
  Result := TAccVoucherDetail.Create;
  Result.Id := Self.Id;
  Result.AccVoucherId := Self.AccVoucherId;
  Result.JournalNo := Self.JournalNo;
end;

end.
