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
    FEinvProfileId: Int64;
    FEinvUuid: string;
    FEinvStatus: SmallInt;
    FDespatchTime: TTime;
    FCarrierAccAccountId: Int64;
    FEinvVehicleId: Int64;
    FTrailer1EinvVehicleId: Int64;
    FTrailer2EinvVehicleId: Int64;
    FDriver1EinvDriverId: Int64;
    FDriver2EinvDriverId: Int64;

    // View (vw_sls_dispatch) okunabilir alanları
    FTotalAmount: Currency;
    FAccountCode: string;
    FAccountName: string;
    FWarehouseName: string;
    FOrderNo: string;
    FProfileCode: string;
    FEinvNo: string;
    FCarrierCode: string;
    FCarrierName: string;
    FVehiclePlate: string;
    FTrailer1Plate: string;
    FTrailer2Plate: string;
    FDriver1Name: string;
    FDriver2Name: string;
    FAccountEDespatchActive: Boolean;
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

    // e-İrsaliye (UBL-TR DespatchAdvice) — einv_status: 1 taslak … 7 iptal (EInvLookup), einv_uuid = ETTN;
    // senaryo boş = kağıt irsaliye. Taşıma: taşıyıcı firma (cari) ya da araç plakası + şoför (GİB)
    [Column('einv_profile_id')]
    property EinvProfileId: Int64 read FEinvProfileId write FEinvProfileId;

    [Column('einv_uuid')]
    property EinvUuid: string read FEinvUuid write FEinvUuid;

    [Column('einv_status')]
    property EinvStatus: SmallInt read FEinvStatus write FEinvStatus;

    [Column('despatch_time')]
    property DespatchTime: TTime read FDespatchTime write FDespatchTime;

    [Column('carrier_acc_account_id')]
    property CarrierAccAccountId: Int64 read FCarrierAccAccountId write FCarrierAccAccountId;

    [Column('einv_vehicle_id')]
    property EinvVehicleId: Int64 read FEinvVehicleId write FEinvVehicleId;

    [Column('trailer1_einv_vehicle_id')]
    property Trailer1EinvVehicleId: Int64 read FTrailer1EinvVehicleId write FTrailer1EinvVehicleId;

    [Column('trailer2_einv_vehicle_id')]
    property Trailer2EinvVehicleId: Int64 read FTrailer2EinvVehicleId write FTrailer2EinvVehicleId;

    [Column('driver1_einv_driver_id')]
    property Driver1EinvDriverId: Int64 read FDriver1EinvDriverId write FDriver1EinvDriverId;

    [Column('driver2_einv_driver_id')]
    property Driver2EinvDriverId: Int64 read FDriver2EinvDriverId write FDriver2EinvDriverId;

    [NotMapped]
    property ProfileCode: string read FProfileCode write FProfileCode;

    [NotMapped]
    property EinvNo: string read FEinvNo write FEinvNo;

    [NotMapped]
    property CarrierCode: string read FCarrierCode write FCarrierCode;

    [NotMapped]
    property CarrierName: string read FCarrierName write FCarrierName;

    [NotMapped]
    property VehiclePlate: string read FVehiclePlate write FVehiclePlate;

    [NotMapped]
    property Trailer1Plate: string read FTrailer1Plate write FTrailer1Plate;

    [NotMapped]
    property Trailer2Plate: string read FTrailer2Plate write FTrailer2Plate;

    [NotMapped]
    property Driver1Name: string read FDriver1Name write FDriver1Name;

    [NotMapped]
    property Driver2Name: string read FDriver2Name write FDriver2Name;

    [NotMapped]
    property AccountEDespatchActive: Boolean read FAccountEDespatchActive write FAccountEDespatchActive;

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
  Result.EinvProfileId := Self.EinvProfileId;
  Result.EinvUuid := Self.EinvUuid;
  Result.EinvStatus := Self.EinvStatus;
  Result.DespatchTime := Self.DespatchTime;
  Result.CarrierAccAccountId := Self.CarrierAccAccountId;
  Result.EinvVehicleId := Self.EinvVehicleId;
  Result.Trailer1EinvVehicleId := Self.Trailer1EinvVehicleId;
  Result.Trailer2EinvVehicleId := Self.Trailer2EinvVehicleId;
  Result.Driver1EinvDriverId := Self.Driver1EinvDriverId;
  Result.Driver2EinvDriverId := Self.Driver2EinvDriverId;
  Result.ProfileCode := Self.ProfileCode;
  Result.EinvNo := Self.EinvNo;
  Result.CarrierCode := Self.CarrierCode;
  Result.CarrierName := Self.CarrierName;
  Result.VehiclePlate := Self.VehiclePlate;
  Result.Trailer1Plate := Self.Trailer1Plate;
  Result.Trailer2Plate := Self.Trailer2Plate;
  Result.Driver1Name := Self.Driver1Name;
  Result.Driver2Name := Self.Driver2Name;
  Result.AccountEDespatchActive := Self.AccountEDespatchActive;
  for LLine in Self.FLines do
  begin
    LCopy := LLine.Clone;
    LCopy.HeaderEntity := Result;
    Result.FLines.Add(LCopy);
  end;
end;

end.
