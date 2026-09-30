unit StkWarehouse;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('stk_warehouse')]
  TStkWarehouse = class(TEntity)
  private
    FWarehouseName: string;
    FDefaultRawMaterial: Boolean;
    FDefaultProduction: Boolean;
    FDefaultSales: Boolean;
  public
    [Column('warehouse_name')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property WarehouseName: string read FWarehouseName write FWarehouseName;

    [Column('default_raw_material')]
    property DefaultRawMaterial: Boolean read FDefaultRawMaterial write FDefaultRawMaterial;

    [Column('default_production')]
    property DefaultProduction: Boolean read FDefaultProduction write FDefaultProduction;

    [Column('default_sales')]
    property DefaultSales: Boolean read FDefaultSales write FDefaultSales;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TStkWarehouse;
  end;

implementation

constructor TStkWarehouse.Create;
begin
  inherited;
end;

destructor TStkWarehouse.Destroy;
begin
  inherited;
end;

function TStkWarehouse.Clone: TStkWarehouse;
begin
  Result := TStkWarehouse.Create;
  Result.Id := Self.Id;
  Result.WarehouseName := Self.WarehouseName;
  Result.DefaultRawMaterial := Self.DefaultRawMaterial;
  Result.DefaultProduction := Self.DefaultProduction;
  Result.DefaultSales := Self.DefaultSales;
end;

end.
