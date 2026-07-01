unit StkWarehouse;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

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
    Property WarehouseName: string read FWarehouseName write FWarehouseName;

    [Column('default_raw_material')]
    Property DefaultRawMaterial: Boolean read FDefaultRawMaterial write FDefaultRawMaterial;

    [Column('default_production')]
    Property DefaultProduction: Boolean read FDefaultProduction write FDefaultProduction;

    [Column('default_sales')]
    Property DefaultSales: Boolean read FDefaultSales write FDefaultSales;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TStkWarehouse.Create;
begin
  inherited;
  FDefaultRawMaterial := False;
  FDefaultProduction := False;
  FDefaultSales := False;
end;

destructor TStkWarehouse.Destroy;
begin
  inherited;
end;

end.
