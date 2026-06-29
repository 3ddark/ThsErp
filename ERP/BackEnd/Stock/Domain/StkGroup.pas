unit StkGroup;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('stk_groups')]
  TStkGroup = class(TEntity)
  private
    FGroupName: string;
    FWatRate: Double;
    FRawMaterialStockAccount: string;
    FRawMaterialUsageAccount: string;
    FSemiProductAccount: string;
  public
    [Column('group_name')]
    Property GroupName: string read FGroupName write FGroupName;

    [Column('vat_rate')]
    Property VatRate: Double read FWatRate write FWatRate;

    [Column('raw_material_stock_account')]
    Property RawMaterialStockAccount: string read FRawMaterialStockAccount write FRawMaterialStockAccount;

    [Column('raw_material_usage_account')]
    Property RawMaterialUsageAccount: string read FRawMaterialUsageAccount write FRawMaterialUsageAccount;

    [Column('semi_product_account')]
    Property SemiProductAccount: string read FSemiProductAccount write FSemiProductAccount;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TStkGroup.Create;
begin
  inherited;
end;

destructor TStkGroup.Destroy;
begin
  inherited;
end;

end.
