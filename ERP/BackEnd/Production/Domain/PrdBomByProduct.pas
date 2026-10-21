unit PrdBomByProduct;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('prd_bom_by_product')]
  TPrdBomByProduct = class(TDetailEntity)
  private
    FPrdBomId: Int64;
    FLineNo: SmallInt;
    FStkInventoryId: Int64;
    FQuantity: Currency;

    // View (vw_prd_bom_by_product) okunabilir alanları
    FBomName: string;
    FInventoryCode: string;
    FInventoryName: string;
  public
    [Column('prd_bom_id'), Required()]
    property PrdBomId: Int64 read FPrdBomId write FPrdBomId;

    [Column('line_no')]
    property LineNo: SmallInt read FLineNo write FLineNo;

    [Column('stk_inventory_id'), Required()]
    property StkInventoryId: Int64 read FStkInventoryId write FStkInventoryId;

    [Column('quantity')]
    property Quantity: Currency read FQuantity write FQuantity;

    [NotMapped]
    property BomName: string read FBomName write FBomName;

    [NotMapped]
    property InventoryCode: string read FInventoryCode write FInventoryCode;

    [NotMapped]
    property InventoryName: string read FInventoryName write FInventoryName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPrdBomByProduct;
  end;

implementation

constructor TPrdBomByProduct.Create;
begin
  inherited;
end;

destructor TPrdBomByProduct.Destroy;
begin
  inherited;
end;

function TPrdBomByProduct.Clone: TPrdBomByProduct;
begin
  // başlık referansı kopyalanmaz (kopyayı sahiplenen başlık verir)
  Result := TPrdBomByProduct.Create;
  Result.Id := Self.Id;
  Result.Deleted := Self.Deleted;
  Result.PrdBomId := Self.PrdBomId;
  Result.LineNo := Self.LineNo;
  Result.StkInventoryId := Self.StkInventoryId;
  Result.Quantity := Self.Quantity;
  Result.BomName := Self.BomName;
  Result.InventoryCode := Self.InventoryCode;
  Result.InventoryName := Self.InventoryName;
end;

end.
