unit PrdBom;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, PrdBomRaw, PrdBomLabour, PrdBomByProduct, PrdBomPacketRaw, PrdBomPacketLabour;

type
  [Table('prd_bom')]
  TPrdBom = class(TEntity)
  private
    // Kalemler (sahiplenir): servis yükler / yazar; durum TDetailEntity (Id işareti + Deleted)
    FPacketLabours: TObjectList<TPrdBomPacketLabour>;
    // Kalemler (sahiplenir): servis yükler / yazar; durum TDetailEntity (Id işareti + Deleted)
    FPacketRaws: TObjectList<TPrdBomPacketRaw>;
    // Kalemler (sahiplenir): servis yükler / yazar; durum TDetailEntity (Id işareti + Deleted)
    FByProducts: TObjectList<TPrdBomByProduct>;
    // Kalemler (sahiplenir): servis yükler / yazar; durum TDetailEntity (Id işareti + Deleted)
    FLabours: TObjectList<TPrdBomLabour>;
    // Kalemler (sahiplenir): servis yükler / yazar; durum TDetailEntity (Id işareti + Deleted)
    FRaws: TObjectList<TPrdBomRaw>;
    FStkInventoryId: Int64;
    FBomName: string;
    FBaseQuantity: Currency;
    FIsDefault: Boolean;
    FIsActive: Boolean;
    FDescription: string;

    // View (vw_prd_bom) okunabilir alanları
    FInventoryCode: string;
    FInventoryName: string;
    FRawCount: string;
    FLabourCount: string;
  public
    [Column('stk_inventory_id'), Required()]
    property StkInventoryId: Int64 read FStkInventoryId write FStkInventoryId;

    [Column('bom_name')]
    [MaxLength(128), Required(TLangKeys.TValidation.Required, True)]
    property BomName: string read FBomName write FBomName;

    [Column('base_quantity')]
    property BaseQuantity: Currency read FBaseQuantity write FBaseQuantity;

    [Column('is_default')]
    property IsDefault: Boolean read FIsDefault write FIsDefault;

    [Column('is_active')]
    property IsActive: Boolean read FIsActive write FIsActive;

    [Column('description')]
    [MaxLength(256)]
    property Description: string read FDescription write FDescription;

    [NotMapped]
    property InventoryCode: string read FInventoryCode write FInventoryCode;

    [NotMapped]
    property InventoryName: string read FInventoryName write FInventoryName;

    [NotMapped]
    property RawCount: string read FRawCount write FRawCount;

    [NotMapped]
    property LabourCount: string read FLabourCount write FLabourCount;

    // Kolon değil (nesne özelliği): BusinessFindById ile dolar, BusinessSaveWithDetails ile yazılır
    property Raws: TObjectList<TPrdBomRaw> read FRaws;

    // Kolon değil (nesne özelliği): BusinessFindById ile dolar, BusinessSaveWithDetails ile yazılır
    property Labours: TObjectList<TPrdBomLabour> read FLabours;

    // Kolon değil (nesne özelliği): BusinessFindById ile dolar, BusinessSaveWithDetails ile yazılır
    property ByProducts: TObjectList<TPrdBomByProduct> read FByProducts;

    // Kolon değil (nesne özelliği): BusinessFindById ile dolar, BusinessSaveWithDetails ile yazılır
    property PacketRaws: TObjectList<TPrdBomPacketRaw> read FPacketRaws;

    // Kolon değil (nesne özelliği): BusinessFindById ile dolar, BusinessSaveWithDetails ile yazılır
    property PacketLabours: TObjectList<TPrdBomPacketLabour> read FPacketLabours;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPrdBom;
  end;

  // Kalemden başlığa tipli erişim: Line.Header.BomName (HeaderEntity zayıf referans, sahiplenmez)
  TPrdBomPacketLabourHelper = class helper for TPrdBomPacketLabour
  private
    function GetHeader: TPrdBom;
    procedure SetHeader(const Value: TPrdBom);
  public
    property Header: TPrdBom read GetHeader write SetHeader;
  end;

  // Kalemden başlığa tipli erişim: Line.Header.BomName (HeaderEntity zayıf referans, sahiplenmez)
  TPrdBomPacketRawHelper = class helper for TPrdBomPacketRaw
  private
    function GetHeader: TPrdBom;
    procedure SetHeader(const Value: TPrdBom);
  public
    property Header: TPrdBom read GetHeader write SetHeader;
  end;

  // Kalemden başlığa tipli erişim: Line.Header.BomName (HeaderEntity zayıf referans, sahiplenmez)
  TPrdBomByProductHelper = class helper for TPrdBomByProduct
  private
    function GetHeader: TPrdBom;
    procedure SetHeader(const Value: TPrdBom);
  public
    property Header: TPrdBom read GetHeader write SetHeader;
  end;

  // Kalemden başlığa tipli erişim: Line.Header.BomName (HeaderEntity zayıf referans, sahiplenmez)
  TPrdBomLabourHelper = class helper for TPrdBomLabour
  private
    function GetHeader: TPrdBom;
    procedure SetHeader(const Value: TPrdBom);
  public
    property Header: TPrdBom read GetHeader write SetHeader;
  end;

  // Kalemden başlığa tipli erişim: Line.Header.BomName (HeaderEntity zayıf referans, sahiplenmez)
  TPrdBomRawHelper = class helper for TPrdBomRaw
  private
    function GetHeader: TPrdBom;
    procedure SetHeader(const Value: TPrdBom);
  public
    property Header: TPrdBom read GetHeader write SetHeader;
  end;

implementation

{ TPrdBomPacketLabourHelper }

function TPrdBomPacketLabourHelper.GetHeader: TPrdBom;
begin
  Result := TPrdBom(HeaderEntity);
end;

procedure TPrdBomPacketLabourHelper.SetHeader(const Value: TPrdBom);
begin
  HeaderEntity := Value;
end;

{ TPrdBom }

{ TPrdBomPacketRawHelper }

function TPrdBomPacketRawHelper.GetHeader: TPrdBom;
begin
  Result := TPrdBom(HeaderEntity);
end;

procedure TPrdBomPacketRawHelper.SetHeader(const Value: TPrdBom);
begin
  HeaderEntity := Value;
end;

{ TPrdBom }

{ TPrdBomByProductHelper }

function TPrdBomByProductHelper.GetHeader: TPrdBom;
begin
  Result := TPrdBom(HeaderEntity);
end;

procedure TPrdBomByProductHelper.SetHeader(const Value: TPrdBom);
begin
  HeaderEntity := Value;
end;

{ TPrdBom }

{ TPrdBomLabourHelper }

function TPrdBomLabourHelper.GetHeader: TPrdBom;
begin
  Result := TPrdBom(HeaderEntity);
end;

procedure TPrdBomLabourHelper.SetHeader(const Value: TPrdBom);
begin
  HeaderEntity := Value;
end;

{ TPrdBom }

{ TPrdBomRawHelper }

function TPrdBomRawHelper.GetHeader: TPrdBom;
begin
  Result := TPrdBom(HeaderEntity);
end;

procedure TPrdBomRawHelper.SetHeader(const Value: TPrdBom);
begin
  HeaderEntity := Value;
end;

{ TPrdBom }

constructor TPrdBom.Create;
begin
  inherited;
  FPacketLabours := TObjectList<TPrdBomPacketLabour>.Create(True);
  FPacketRaws := TObjectList<TPrdBomPacketRaw>.Create(True);
  FByProducts := TObjectList<TPrdBomByProduct>.Create(True);
  FLabours := TObjectList<TPrdBomLabour>.Create(True);
  FRaws := TObjectList<TPrdBomRaw>.Create(True);
  FBaseQuantity := 1;
  FIsActive := True;
end;

destructor TPrdBom.Destroy;
begin
  FPacketLabours.Free;
  FPacketRaws.Free;
  FByProducts.Free;
  FLabours.Free;
  FRaws.Free;
  inherited;
end;

// Kalemler dahil derin kopya; kopyanın kalemleri kopya başlığa bağlanır
function TPrdBom.Clone: TPrdBom;
var
  LRawLine, LRawCopy: TPrdBomRaw;
  LLabourLine, LLabourCopy: TPrdBomLabour;
  LByProductLine, LByProductCopy: TPrdBomByProduct;
  LPacketRawLine, LPacketRawCopy: TPrdBomPacketRaw;
  LPacketLabourLine, LPacketLabourCopy: TPrdBomPacketLabour;
begin
  Result := TPrdBom.Create;
  Result.Id := Self.Id;
  Result.StkInventoryId := Self.StkInventoryId;
  Result.BomName := Self.BomName;
  Result.BaseQuantity := Self.BaseQuantity;
  Result.IsDefault := Self.IsDefault;
  Result.IsActive := Self.IsActive;
  Result.Description := Self.Description;
  Result.InventoryCode := Self.InventoryCode;
  Result.InventoryName := Self.InventoryName;
  Result.RawCount := Self.RawCount;
  Result.LabourCount := Self.LabourCount;
  for LRawLine in Self.FRaws do
  begin
    LRawCopy := LRawLine.Clone;
    LRawCopy.HeaderEntity := Result;
    Result.FRaws.Add(LRawCopy);
  end;
  for LLabourLine in Self.FLabours do
  begin
    LLabourCopy := LLabourLine.Clone;
    LLabourCopy.HeaderEntity := Result;
    Result.FLabours.Add(LLabourCopy);
  end;
  for LByProductLine in Self.FByProducts do
  begin
    LByProductCopy := LByProductLine.Clone;
    LByProductCopy.HeaderEntity := Result;
    Result.FByProducts.Add(LByProductCopy);
  end;
  for LPacketRawLine in Self.FPacketRaws do
  begin
    LPacketRawCopy := LPacketRawLine.Clone;
    LPacketRawCopy.HeaderEntity := Result;
    Result.FPacketRaws.Add(LPacketRawCopy);
  end;
  for LPacketLabourLine in Self.FPacketLabours do
  begin
    LPacketLabourCopy := LPacketLabourLine.Clone;
    LPacketLabourCopy.HeaderEntity := Result;
    Result.FPacketLabours.Add(LPacketLabourCopy);
  end;
end;

end.
