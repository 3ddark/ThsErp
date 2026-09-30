unit ufrmStkInventories;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  StkInventory.Service, StkInventory, ufrmStkInventory;

type
  TfrmStkInventories = class(TfrmGrid<TStkInventory, TStkInventoryService>)
  private
    FmniKindInfo: TMenuItem;
    FmniTransactions: TMenuItem;
    procedure mniKindInfoClick(Sender: TObject);
    procedure mniTransactionsClick(Sender: TObject);
  public
    procedure PreparePopupMenu; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  ufrmStkCardKindInfos, StkCardKindInfo, StkCardKindInfo.Service,               // TfrmStkCardKindInfos
  ufrmStkTransactions, StkTransaction, StkTransaction.Service;                  // TfrmStkTransactions

function TfrmStkInventories.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkInventory.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkInventory.Create(Self, Service, TStkInventory.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkInventory.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmStkInventories.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniKindInfo := AddMenu(TLocalizationManager.Translate(TLangKeys.TStkInventory.MenuKindInfo, 'Kind Information'), 'mniKindInfo', mniKindInfoClick);
  FmniTransactions := AddMenu(TLocalizationManager.Translate(TLangKeys.TStkInventory.MenuTransactions, 'Stock Transactions'), 'mniTransactions', mniTransactionsClick);
end;

procedure TfrmStkInventories.mniKindInfoClick(Sender: TObject);
var
  LFrm: TfrmStkCardKindInfos;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmStkCardKindInfos.Create(Self, TStkCardKindInfoService.Create, TStkCardKindInfo.Create);
  LFrm.SetFixedInventory(Table.Id, Table.Code + ' ' + Table.Name);
  LFrm.Show;
end;

procedure TfrmStkInventories.mniTransactionsClick(Sender: TObject);
var
  LFrm: TfrmStkTransactions;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmStkTransactions.Create(Self, TStkTransactionService.Create, TStkTransaction.Create);
  LFrm.SetFixedInventory(Table.Id, Table.Code + ' ' + Table.Name);
  LFrm.Show;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmStkInventories.SetSelectedItem;

  function FieldText(const AFieldName: string): string;
  var
    LField: TField;
  begin
    LField := Grd.DataSource.DataSet.FindField(AFieldName);
    if Assigned(LField) then
      Result := LField.AsString
    else
      Result := '';
  end;

begin
  inherited;
  Table.GroupName := FieldText('group_name');
  Table.ProductTypeName := FieldText('product_type_name');
  Table.UomName := FieldText('uom_name');
  Table.CountryName := FieldText('country_name');
  Table.CurrentQuantity := FieldText('current_quantity');
  Table.AverageCost := FieldText('average_cost');
end;

procedure TfrmStkInventories.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('stk_group_id', 0);
  SetColumnProperty('stk_product_type_id', 0);
  SetColumnProperty('sys_uom_id', 0);
  SetColumnProperty('sys_country_id', 0);
  SetColumnProperty('locale', 0);
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
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.TitlePlural, 'Stock Cards');
  if Assigned(FmniKindInfo) then
    FmniKindInfo.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.MenuKindInfo, 'Kind Information');
  if Assigned(FmniTransactions) then
    FmniTransactions.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.MenuTransactions, 'Stock Transactions');
  SetColumnTitle('code', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColCode, 'Stock Code'));
  SetColumnTitle('name', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColName, 'Stock Name'));
  SetColumnTitle('group_name', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColGroup, 'Group'));
  SetColumnTitle('product_type_name', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColProductType, 'Product Type'));
  SetColumnTitle('uom_name', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColUom, 'Unit'));
  SetColumnTitle('sellable', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColSellable, 'Sellable'));
  SetColumnTitle('buying_price', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColBuyingPrice, 'Buying Price'));
  SetColumnTitle('buying_currency', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColBuyingCurrency, 'Buying Currency'));
  SetColumnTitle('buying_discount', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColBuyingDiscount, 'Buying Discount (%)'));
  SetColumnTitle('sales_price', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColSalesPrice, 'Sales Price'));
  SetColumnTitle('sales_currency', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColSalesCurrency, 'Sales Currency'));
  SetColumnTitle('sales_discount', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColSalesDiscount, 'Sales Discount (%)'));
  SetColumnTitle('export_price', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColExportPrice, 'Export Price'));
  SetColumnTitle('export_currency', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColExportCurrency, 'Export Currency'));
  SetColumnTitle('special_code', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColSpecialCode, 'Special Code'));
  SetColumnTitle('brand', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColBrand, 'Brand'));
  SetColumnTitle('width', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColWidth, 'Width'));
  SetColumnTitle('length', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColLength, 'Length'));
  SetColumnTitle('height', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColHeight, 'Height'));
  SetColumnTitle('weight', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColWeight, 'Weight'));
  SetColumnTitle('supply_duration', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColSupplyDuration, 'Supply Duration (Days)'));
  SetColumnTitle('min_stock_amount', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColMinStockAmount, 'Minimum Stock'));
  SetColumnTitle('country_name', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColCountry, 'Origin Country'));
  SetColumnTitle('hs_no', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColHsNo, 'HS Code'));
  SetColumnTitle('diib_product_description', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColDiibProductDescription, 'DIIB Description'));
  SetColumnTitle('product_overview', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColProductOverview, 'Product Overview'));
  SetColumnTitle('current_quantity', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColCurrentQuantity, 'Current Quantity'));
  SetColumnTitle('average_cost', TLocalizationManager.Translate(TLangKeys.TStkInventory.ColAverageCost, 'Average Cost'));
end;

end.
