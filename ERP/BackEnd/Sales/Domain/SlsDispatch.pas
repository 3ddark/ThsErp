unit SlsDispatch;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('sls_dispatch')]
  TSlsDispatch = class(TEntity)
  private
    FDispatchNo: string;
    FDispatchDate: TDate;
    FAccAccountId: Int64;
    FStkWarehouseId: Int64;
    FSlsOrderId: Int64;
    FCurrency: string;
    FDescription: string;

    // View (vw_sls_dispatch) okunabilir alanları
    FAccountCode: string;
    FAccountName: string;
    FWarehouseName: string;
    FOrderNo: string;
  public
    [Column('dispatch_no')]
    [MaxLength(16)]
    property DispatchNo: string read FDispatchNo write FDispatchNo;

    [Column('dispatch_date')]
    [Required()]
    property DispatchDate: TDate read FDispatchDate write FDispatchDate;

    [Column('acc_account_id')]
    [Required()]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [Column('stk_warehouse_id')]
    [Required()]
    property StkWarehouseId: Int64 read FStkWarehouseId write FStkWarehouseId;

    [Column('sls_order_id')]
    property SlsOrderId: Int64 read FSlsOrderId write FSlsOrderId;

    [Column('currency')]
    [MaxLength(3)]
    property Currency: string read FCurrency write FCurrency;

    [Column('description')]
    [MaxLength(256)]
    property Description: string read FDescription write FDescription;

    [NotMapped]
    property AccountCode: string read FAccountCode write FAccountCode;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    [NotMapped]
    property WarehouseName: string read FWarehouseName write FWarehouseName;

    [NotMapped]
    property OrderNo: string read FOrderNo write FOrderNo;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSlsDispatch;
  end;

implementation

constructor TSlsDispatch.Create;
begin
  inherited;
  FDispatchDate := Date;
end;

destructor TSlsDispatch.Destroy;
begin
  inherited;
end;

function TSlsDispatch.Clone: TSlsDispatch;
begin
  Result := TSlsDispatch.Create;
  Result.Id := Self.Id;
  Result.DispatchNo := Self.DispatchNo;
  Result.DispatchDate := Self.DispatchDate;
  Result.AccAccountId := Self.AccAccountId;
  Result.StkWarehouseId := Self.StkWarehouseId;
  Result.SlsOrderId := Self.SlsOrderId;
  Result.Currency := Self.Currency;
  Result.Description := Self.Description;
  Result.AccountCode := Self.AccountCode;
  Result.AccountName := Self.AccountName;
  Result.WarehouseName := Self.WarehouseName;
  Result.OrderNo := Self.OrderNo;
end;

end.
