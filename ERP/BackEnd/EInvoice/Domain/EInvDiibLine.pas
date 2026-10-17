unit EInvDiibLine;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, EInvLookup;

type
  [Table('einv_diib_line')]
  TEInvDiibLine = class(TEntity)
  private
    FEinvDiibId: Int64;
    FLineCode: string;
    FLineKind: SmallInt;
    FEinvGtipId: Int64;
    FProductDescription: string;
    FStkInventoryId: Int64;
    FQuantity: Currency;
    FSysUomId: Int64;
    FIsActive: Boolean;

    // View (vw_einv_diib_line) okunabilir alanları
    FDocumentNo: string;
    FHolderType: SmallInt;
    FAccAccountId: Int64;
    FAccountName: string;
    FGtipCode: string;
    FGtipName: string;
    FInventoryCode: string;
    FInventoryName: string;
    FUnitCode: string;
    FUomEinvCode: string;
    FDiibIsActive: Boolean;
  public
    [Column('einv_diib_id')]
    [Required()]
    property EinvDiibId: Int64 read FEinvDiibId write FEinvDiibId;

    [Column('line_code')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property LineCode: string read FLineCode write FLineCode;

    [Column('line_kind')]
    [Required()]
    property LineKind: SmallInt read FLineKind write FLineKind;

    [Column('einv_gtip_id')]
    [Required()]
    property EinvGtipId: Int64 read FEinvGtipId write FEinvGtipId;

    [Column('product_description')]
    [MaxLength(512), Required(TLangKeys.TValidation.Required, True)]
    property ProductDescription: string read FProductDescription write FProductDescription;

    [Column('stk_inventory_id')]
    property StkInventoryId: Int64 read FStkInventoryId write FStkInventoryId;

    [Column('quantity')]
    property Quantity: Currency read FQuantity write FQuantity;

    [Column('sys_uom_id')]
    property SysUomId: Int64 read FSysUomId write FSysUomId;

    [Column('is_active')]
    property IsActive: Boolean read FIsActive write FIsActive;

    [NotMapped]
    property DocumentNo: string read FDocumentNo write FDocumentNo;

    [NotMapped]
    property HolderType: SmallInt read FHolderType write FHolderType;

    [NotMapped]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

    [NotMapped]
    property AccountName: string read FAccountName write FAccountName;

    [NotMapped]
    property GtipCode: string read FGtipCode write FGtipCode;

    [NotMapped]
    property GtipName: string read FGtipName write FGtipName;

    [NotMapped]
    property InventoryCode: string read FInventoryCode write FInventoryCode;

    [NotMapped]
    property InventoryName: string read FInventoryName write FInventoryName;

    [NotMapped]
    property UnitCode: string read FUnitCode write FUnitCode;

    [NotMapped]
    property UomEinvCode: string read FUomEinvCode write FUomEinvCode;

    [NotMapped]
    property DiibIsActive: Boolean read FDiibIsActive write FDiibIsActive;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEInvDiibLine;
  end;

implementation

constructor TEInvDiibLine.Create;
begin
  inherited;
  FIsActive := True;
  FLineKind := EINV_DIIB_LINE_EXPORT;
end;

destructor TEInvDiibLine.Destroy;
begin
  inherited;
end;

function TEInvDiibLine.Clone: TEInvDiibLine;
begin
  Result := TEInvDiibLine.Create;
  Result.Id := Self.Id;
  Result.EinvDiibId := Self.EinvDiibId;
  Result.LineCode := Self.LineCode;
  Result.LineKind := Self.LineKind;
  Result.EinvGtipId := Self.EinvGtipId;
  Result.ProductDescription := Self.ProductDescription;
  Result.StkInventoryId := Self.StkInventoryId;
  Result.Quantity := Self.Quantity;
  Result.SysUomId := Self.SysUomId;
  Result.IsActive := Self.IsActive;
  Result.DocumentNo := Self.DocumentNo;
  Result.HolderType := Self.HolderType;
  Result.AccAccountId := Self.AccAccountId;
  Result.AccountName := Self.AccountName;
  Result.GtipCode := Self.GtipCode;
  Result.GtipName := Self.GtipName;
  Result.InventoryCode := Self.InventoryCode;
  Result.InventoryName := Self.InventoryName;
  Result.UnitCode := Self.UnitCode;
  Result.UomEinvCode := Self.UomEinvCode;
  Result.DiibIsActive := Self.DiibIsActive;
end;

end.
