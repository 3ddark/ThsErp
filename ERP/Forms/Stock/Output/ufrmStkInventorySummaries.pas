unit ufrmStkInventorySummaries;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  StkInventorySummary.Service, StkInventorySummary;

type
  TfrmStkInventorySummaries = class(TfrmGrid<TStkInventorySummary, TStkInventorySummaryService>)
  private
    FFixedInventoryId: Int64;
    FFixedInventoryName: string;
  public
    procedure SetFixedInventory(AInventoryId: Int64; const AInventoryName: string);

    // Salt okunur liste: kayıtlar stok hareketlerinden hesaplanır, giriş formu yok
    procedure ShowInputForm(Sender: TObject; AFormType: TInputFormMode); override;
    procedure ApplyPermissionState; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmStkInventorySummaries.SetFixedInventory(AInventoryId: Int64; const AInventoryName: string);
begin
  FFixedInventoryId := AInventoryId;
  FFixedInventoryName := AInventoryName;
  AddFixedFilter('stk_inventory_id', AInventoryId);
end;

function TfrmStkInventorySummaries.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
end;

procedure TfrmStkInventorySummaries.ShowInputForm(Sender: TObject; AFormType: TInputFormMode);
begin
  // giriş formu yok
end;

procedure TfrmStkInventorySummaries.ApplyPermissionState;
begin
  inherited;
  if Assigned(BtnAdd) then
    BtnAdd.Visible := False;
  if Assigned(mniDuplicate) then
    mniDuplicate.Visible := False;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmStkInventorySummaries.SetSelectedItem;

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
  Table.InventoryName := FieldText('inventory_name');
  Table.InventoryCode := FieldText('inventory_code');
end;

procedure TfrmStkInventorySummaries.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('stk_inventory_id', 0);
end;

procedure TfrmStkInventorySummaries.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmStkInventorySummaries.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.TitlePlural, 'Stock Summaries');
  if FFixedInventoryName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedInventoryName;
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColInventory, 'Stock Card'));
  SetColumnTitle('current_quantity', TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColCurrentQuantity, 'Current Quantity'));
  SetColumnTitle('average_cost', TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColAverageCost, 'Average Cost'));
  SetColumnTitle('opening_quantity', TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColOpeningQuantity, 'Opening Quantity'));
  SetColumnTitle('opening_price', TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColOpeningPrice, 'Opening Price'));
  SetColumnTitle('opening_amount', TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColOpeningAmount, 'Opening Amount'));
  SetColumnTitle('incoming_quantity', TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColIncomingQuantity, 'Incoming Quantity'));
  SetColumnTitle('incoming_amount', TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColIncomingAmount, 'Incoming Amount'));
  SetColumnTitle('outgoing_quantity', TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColOutgoingQuantity, 'Outgoing Quantity'));
  SetColumnTitle('outgoing_amount', TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColOutgoingAmount, 'Outgoing Amount'));
  SetColumnTitle('last_buy_date', TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColLastBuyDate, 'Last Purchase Date'));
  SetColumnTitle('last_buy_quantity', TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColLastBuyQuantity, 'Last Purchase Quantity'));
  SetColumnTitle('last_buy_price', TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColLastBuyPrice, 'Last Purchase Price'));
  SetColumnTitle('last_buy_currency', TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColLastBuyCurrency, 'Last Purchase Currency'));
  SetColumnTitle('last_buy_exchange_rate', TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColLastBuyExchangeRate, 'Last Purchase Exchange Rate'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColInventoryCode, 'Stock Code'));
end;

end.
