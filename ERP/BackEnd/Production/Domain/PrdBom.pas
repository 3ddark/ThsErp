unit PrdBom;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('prd_bom')]
  TPrdBom = class(TEntity)
  private
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
    [Column('stk_inventory_id')]
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

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPrdBom;
  end;

implementation

constructor TPrdBom.Create;
begin
  inherited;
  FBaseQuantity := 1;
  FIsActive := True;
end;

destructor TPrdBom.Destroy;
begin
  inherited;
end;

function TPrdBom.Clone: TPrdBom;
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
end;

end.
