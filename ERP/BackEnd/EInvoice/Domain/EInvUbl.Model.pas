unit EInvUbl.Model;

// UBL-TR 1.2.1 fatura / irsaliye üretimi için düz veri: TEInvDocumentRepository.LoadSalesInvoice / LoadSalesDispatch
// doldurur, TEInvUblBuilder XML'e çevirir. Mantık yok; tutarlar faturadaki (servisin hesapladığı) değerlerdir.

interface

uses
  System.SysUtils, System.Generics.Collections;

type
  TEInvUblAddress = record
    StreetName: string;          // mahalle / cadde / sokak
    BuildingName: string;
    BuildingNumber: string;      // kapı no
    CitySubdivisionName: string; // ilçe
    CityName: string;            // il
    PostalZone: string;
    CountryName: string;         // tr-TR ülke adı (Türkiye)
    CountryCode: string;         // ISO 3166 (TR)
  end;

  TEInvUblParty = record
    Found: Boolean;
    TaxNo: string;               // VKN (10 hane) / TCKN (11 hane) / yabancı vergi no (ihracat alıcısı)
    IsPerson: Boolean;           // gerçek kişi: Person (ad / soyad) yazılır
    Name: string;                // unvan / ad soyad
    FirstName: string;
    FamilyName: string;
    TaxOffice: string;
    Address: TEInvUblAddress;
    Phone: string;
    Fax: string;
    Email: string;
    Website: string;
  end;

  TEInvUblLine = class
  public
    LineNo: Integer;
    InventoryCode: string;
    InventoryName: string;
    Description: string;
    Quantity: Currency;
    UnitCode: string;            // sys_uom.unit_einv (GİB / UN/ECE Rec 20)
    UomCode: string;             // ölçü birimi (eksik e-belge kodu mesajı için)
    UnitPrice: Currency;
    GrossAmount: Currency;
    DiscountRate: Currency;
    DiscountAmount: Currency;
    NetAmount: Currency;
    VatRate: Currency;
    VatAmount: Currency;
    WithholdingCode: string;
    WithholdingRate: Currency;
    WithholdingAmount: Currency;
    GtipCode: string;
    PackagingTypeCode: string;
    PackageNo: string;
    PackageQuantity: Currency;
    PackageBrand: string;
    SellerDiibLineCode: string;
    SellerDiibNo: string;
    BuyerDiibLineCode: string;
    BuyerDiibNo: string;
  end;

  TEInvUblInvoice = class
  private
    FLines: TObjectList<TEInvUblLine>;
  public
    InvoiceId: Int64;
    InvoiceNo: string;           // iç fatura no (not olarak)
    EInvNo: string;              // GİB belge no (gönderimde verilir; önizlemede seri + yıl + 000000000)
    Uuid: string;
    ProfileCode: string;
    InvoiceTypeCode: string;
    IssueDate: TDate;
    DueDate: TDate;
    Currency: string;            // UBL / ISO kodu (TRY)
    ExchangeRate: Currency;
    Description: string;
    Supplier: TEInvUblParty;
    Customer: TEInvUblParty;
    IsExport: Boolean;           // IHRACAT: fatura alıcısı GTB, malı alan BuyerCustomerParty
    ExemptionCode: string;
    ExemptionName: string;
    PaymentMeansCode: string;
    DeliveryTermCode: string;
    TransportModeCode: string;
    GrossAmount: Currency;
    DiscountAmount: Currency;
    NetAmount: Currency;
    VatAmount: Currency;
    TotalAmount: Currency;
    WithholdingAmount: Currency;
    constructor Create;
    destructor Destroy; override;
    property Lines: TObjectList<TEInvUblLine> read FLines;
  end;

  TEInvUblDriver = record
    FirstName: string;
    FamilyName: string;
    NationalId: string;          // TCKN
  end;

  TEInvUblDespatchLine = class
  public
    LineNo: Integer;
    InventoryCode: string;
    InventoryName: string;
    Description: string;
    Quantity: Currency;
    UnitCode: string;            // sys_uom.unit_einv
    UomCode: string;
    OrderLineNo: Integer;        // sipariş kalem no (siparişsiz 0)
  end;

  // e-İrsaliye (DespatchAdvice): fiyat / tutar yazılmaz (kullanıcı kararı 2026-10-18)
  TEInvUblDespatch = class
  private
    FLines: TObjectList<TEInvUblDespatchLine>;
  public
    DispatchId: Int64;
    DispatchNo: string;          // iç irsaliye no (not olarak)
    EInvNo: string;              // GİB belge no (gönderimde verilir; önizlemede seri + yıl + 000000000)
    Uuid: string;
    ProfileCode: string;
    IssueDate: TDate;            // düzenleme = fiili sevk tarihi (irsaliye tarihi)
    DespatchTime: TTime;         // fiili sevk saati
    Description: string;
    OrderNo: string;
    OrderDate: TDate;
    Supplier: TEInvUblParty;     // sevk eden (uygulama ayarları)
    Customer: TEInvUblParty;     // teslim alan (cari; sevk adresi, yoksa fatura / birincil adres)
    HasCarrier: Boolean;
    Carrier: TEInvUblParty;      // taşıyıcı firma (cari)
    VehiclePlate: string;
    TrailerPlates: TArray<string>;
    Drivers: TArray<TEInvUblDriver>;
    constructor Create;
    destructor Destroy; override;
    property Lines: TObjectList<TEInvUblDespatchLine> read FLines;
  end;

implementation

constructor TEInvUblDespatch.Create;
begin
  inherited;
  FLines := TObjectList<TEInvUblDespatchLine>.Create(True);
end;

destructor TEInvUblDespatch.Destroy;
begin
  FLines.Free;
  inherited;
end;

constructor TEInvUblInvoice.Create;
begin
  inherited;
  FLines := TObjectList<TEInvUblLine>.Create(True);
end;

destructor TEInvUblInvoice.Destroy;
begin
  FLines.Free;
  inherited;
end;

end.
