unit AccVoucherDetail;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('acc_voucher_detail')]
  TAccVoucherDetail = class(TEntity)
  private
    FHeaderId: Int64;
  public
    [Column('header_id'), Required()]
    property HeaderId: Int64 read FHeaderId write FHeaderId;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TAccVoucherDetail.Create();
begin
  inherited;
end;

destructor TAccVoucherDetail.Destroy;
begin
  inherited;
end;

end.
