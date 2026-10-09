unit PrdBomRaw;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('prd_bom_raw')]
  TPrdBomRaw = class(TEntity)
  private
    FPrdBomId: Int64;
    FStkInventoryId: Int64;
    FSubPrdBomId: Int64;
    FQuantity: Currency;
    FScrapRate: Currency;

    // View (vw_prd_bom_raw) okunabilir alanları
    FBomName: string;
    FInventoryCode: string;
    FInventoryName: string;
    FSubBomName: string;
    FGrossQuantity: string;
  public
    [Column('prd_bom_id')]
    property PrdBomId: Int64 read FPrdBomId write FPrdBomId;

    [Column('stk_inventory_id')]
    property StkInventoryId: Int64 read FStkInventoryId write FStkInventoryId;

    [Column('sub_prd_bom_id')]
    property SubPrdBomId: Int64 read FSubPrdBomId write FSubPrdBomId;

    [Column('quantity')]
    property Quantity: Currency read FQuantity write FQuantity;

    [Column('scrap_rate')]
    property ScrapRate: Currency read FScrapRate write FScrapRate;

    [NotMapped]
    property BomName: string read FBomName write FBomName;

    [NotMapped]
    property InventoryCode: string read FInventoryCode write FInventoryCode;

    [NotMapped]
    property InventoryName: string read FInventoryName write FInventoryName;

    [NotMapped]
    property SubBomName: string read FSubBomName write FSubBomName;

    [NotMapped]
    property GrossQuantity: string read FGrossQuantity write FGrossQuantity;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPrdBomRaw;
  end;

implementation

constructor TPrdBomRaw.Create;
begin
  inherited;
end;

destructor TPrdBomRaw.Destroy;
begin
  inherited;
end;

function TPrdBomRaw.Clone: TPrdBomRaw;
begin
  Result := TPrdBomRaw.Create;
  Result.Id := Self.Id;
  Result.PrdBomId := Self.PrdBomId;
  Result.StkInventoryId := Self.StkInventoryId;
  Result.SubPrdBomId := Self.SubPrdBomId;
  Result.Quantity := Self.Quantity;
  Result.ScrapRate := Self.ScrapRate;
  Result.BomName := Self.BomName;
  Result.InventoryCode := Self.InventoryCode;
  Result.InventoryName := Self.InventoryName;
  Result.SubBomName := Self.SubBomName;
  Result.GrossQuantity := Self.GrossQuantity;
end;

end.
