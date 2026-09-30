unit StkGroup;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('stk_group')]
  TStkGroup = class(TEntity)
  private
    FName: string;
    FVatRate: Currency;
    FRawMaterialStockAccount: string;
    FRawMaterialUsageAccount: string;
    FSemiProductAccount: string;
  public
    [Column('name')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property Name: string read FName write FName;

    [Column('vat_rate')]
    property VatRate: Currency read FVatRate write FVatRate;

    [Column('raw_material_stock_account')]
    [MaxLength(16)]
    property RawMaterialStockAccount: string read FRawMaterialStockAccount write FRawMaterialStockAccount;

    [Column('raw_material_usage_account')]
    [MaxLength(16)]
    property RawMaterialUsageAccount: string read FRawMaterialUsageAccount write FRawMaterialUsageAccount;

    [Column('semi_product_account')]
    [MaxLength(16)]
    property SemiProductAccount: string read FSemiProductAccount write FSemiProductAccount;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TStkGroup;
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

function TStkGroup.Clone: TStkGroup;
begin
  Result := TStkGroup.Create;
  Result.Id := Self.Id;
  Result.Name := Self.Name;
  Result.VatRate := Self.VatRate;
  Result.RawMaterialStockAccount := Self.RawMaterialStockAccount;
  Result.RawMaterialUsageAccount := Self.RawMaterialUsageAccount;
  Result.SemiProductAccount := Self.SemiProductAccount;
end;

end.
