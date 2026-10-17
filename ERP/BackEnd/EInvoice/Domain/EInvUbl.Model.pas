unit EInvUbl.Model;

// UBL-TR 1.2.1 fatura üretimi için düz veri: TEInvDocumentRepository.LoadSalesInvoice doldurur, TEInvUblBuilder XML'e
// çevirir. Mantık yok; tutarlar faturadaki (servisin hesapladığı) değerlerdir.

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

implementation

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
