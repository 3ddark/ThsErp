unit SlsDispatch;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, SlsDispatchDetail;

type
  [Table('sls_dispatch')]
  TSlsDispatch = class(TEntity)
  private
    // Kalemler (sahiplenir): servis yükler / yazar; durum TDetailEntity (Id işareti + Deleted)
    FLines: TObjectList<TSlsDispatchDetail>;
    FDispatchNo: string;
    FDispatchDate: TDate;
    FAccAccountId: Int64;
    FStkWarehouseId: Int64;
    FSlsOrderId: Int64;
    FCurrency: string;
    FDescription: string;
    FStatus: SmallInt;

    // View (vw_sls_dispatch) okunabilir alanları
    FTotalAmount: Currency;
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

    // 1 bekliyor (tamamı faturalanmamış), 2 kapandı (tüm kalemler faturalandı); servis tutar
    [Column('status')]
    property Status: SmallInt read FStatus write FStatus;

    // kalem tutarları toplamı (miktar x net fiyat); view'dan, bellekte servis hesaplar
    [NotMapped]
    property TotalAmount: Currency read FTotalAmount write FTotalAmount;

    [NotMapped]
    property AccountCode: string read FAccountCode write FAccountCode;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    [NotMapped]
    property WarehouseName: string read FWarehouseName write FWarehouseName;

    [NotMapped]
    property OrderNo: string read FOrderNo write FOrderNo;

    // Kolon değil (nesne özelliği): BusinessFindById ile dolar, BusinessSaveWithDetails ile yazılır
    property Lines: TObjectList<TSlsDispatchDetail> read FLines;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSlsDispatch;
  end;

  // Kalemden başlığa tipli erişim: Line.Header.DispatchNo (HeaderEntity zayıf referans, sahiplenmez)
  TSlsDispatchDetailHelper = class helper for TSlsDispatchDetail
  private
    function GetHeader: TSlsDispatch;
    procedure SetHeader(const Value: TSlsDispatch);
  public
    property Header: TSlsDispatch read GetHeader write SetHeader;
  end;

implementation

{ TSlsDispatchDetailHelper }

function TSlsDispatchDetailHelper.GetHeader: TSlsDispatch;
begin
  Result := TSlsDispatch(HeaderEntity);
end;

procedure TSlsDispatchDetailHelper.SetHeader(const Value: TSlsDispatch);
begin
  HeaderEntity := Value;
end;

{ TSlsDispatch }

constructor TSlsDispatch.Create;
begin
  inherited;
  FLines := TObjectList<TSlsDispatchDetail>.Create(True);
  FDispatchDate := Date;
  FStatus := 1;
end;

destructor TSlsDispatch.Destroy;
begin
  FLines.Free;
  inherited;
end;

// Kalemler dahil derin kopya; kopyanın kalemleri kopya başlığa bağlanır
function TSlsDispatch.Clone: TSlsDispatch;
var
  LLine, LCopy: TSlsDispatchDetail;
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
  Result.Status := Self.Status;
  Result.TotalAmount := Self.TotalAmount;
  for LLine in Self.FLines do
  begin
    LCopy := LLine.Clone;
    LCopy.HeaderEntity := Result;
    Result.FLines.Add(LCopy);
  end;
end;

end.
