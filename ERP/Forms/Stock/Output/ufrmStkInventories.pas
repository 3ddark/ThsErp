unit ufrmStkInventories;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, StkInventory.Service, StkInventory, ufrmStkInventory,
  LocalizationManager;

type
  TfrmStkInventories = class(TfrmGrid<TStkInventory, TStkInventoryService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmStkInventories.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkInventory.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkInventory.Create(Self, Service, TStkInventory.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkInventory.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmStkInventories.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',                          0, TLocalizationManager.Translate('stk_inventory.col_id', 'Id'));
  SetColumnProperty('code',                       80, TLocalizationManager.Translate('stk_inventory.col_code', 'Stock Code'));
  SetColumnProperty('name',                      200, TLocalizationManager.Translate('stk_inventory.col_name', 'Stock Name'));
  SetColumnProperty('group_id',                    0, TLocalizationManager.Translate('stk_inventory.col_group_id', 'Group Id'));
  SetColumnProperty('measurement_id',              0, TLocalizationManager.Translate('stk_inventory.col_measurement_id', 'UoM Id'));
  SetColumnProperty('product_type',               80, TLocalizationManager.Translate('stk_inventory.col_product_type', 'Product Type'));
  SetColumnProperty('buying_discount',            60, TLocalizationManager.Translate('stk_inventory.col_buying_discount', 'Buy Disc %'));
  SetColumnProperty('sales_discount',             60, TLocalizationManager.Translate('stk_inventory.col_sales_discount', 'Sale Disc %'));
  SetColumnProperty('buying_price',              100, TLocalizationManager.Translate('stk_inventory.col_buying_price', 'Buying Price'));
  SetColumnProperty('buying_currency',            50, TLocalizationManager.Translate('stk_inventory.col_buying_currency', 'Buy Curr'));
  SetColumnProperty('sales_price',               100, TLocalizationManager.Translate('stk_inventory.col_sales_price', 'Sales Price'));
  SetColumnProperty('sales_currency',             50, TLocalizationManager.Translate('stk_inventory.col_sales_currency', 'Sale Curr'));
  SetColumnProperty('export_price',              100, TLocalizationManager.Translate('stk_inventory.col_export_price', 'Export Price'));
  SetColumnProperty('export_currency',            50, TLocalizationManager.Translate('stk_inventory.col_export_currency', 'Exp Curr'));
  SetColumnProperty('width',                      60, TLocalizationManager.Translate('stk_inventory.col_width', 'Width'));
  SetColumnProperty('length',                     60, TLocalizationManager.Translate('stk_inventory.col_length', 'Length'));
  SetColumnProperty('height',                     60, TLocalizationManager.Translate('stk_inventory.col_height', 'Height'));
  SetColumnProperty('weight',                     60, TLocalizationManager.Translate('stk_inventory.col_weight', 'Weight'));
  SetColumnProperty('supply_duration',            60, TLocalizationManager.Translate('stk_inventory.col_supply_duration', 'Supply Days'));
  SetColumnProperty('special_code',               80, TLocalizationManager.Translate('stk_inventory.col_special_code', 'Special Code'));
  SetColumnProperty('brand',                      80, TLocalizationManager.Translate('stk_inventory.col_brand', 'Brand'));
end;

procedure TfrmStkInventories.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmStkInventories.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmStkInventories.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('stk_inventory.title_plural', 'Stock Cards');
end;

end.
