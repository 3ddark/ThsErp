unit ufrmSlsOrderDetails;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SlsOrderDetail.Service, SlsOrderDetail, ufrmSlsOrderDetail;

type
  TfrmSlsOrderDetails = class(TfrmGrid<TSlsOrderDetail, TSlsOrderDetailService>)
  private
    FFixedMasterId: Int64;
    FFixedMasterName: string;
    FFixedCurrency: string;
    procedure OrderStatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure SetFixedOrder(AMasterId: Int64; const AMasterName, ACurrency: string);
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SlsLookup;

procedure TfrmSlsOrderDetails.OrderStatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TSlsLookup.Text(slkOrderStatus, Sender.AsInteger);
end;
procedure TfrmSlsOrderDetails.SetFixedOrder(AMasterId: Int64; const AMasterName, ACurrency: string);
begin
  FFixedMasterId := AMasterId;
  FFixedMasterName := AMasterName;
  FFixedCurrency := ACurrency;
  AddFixedFilter('sls_order_id', AMasterId);
end;

function TfrmSlsOrderDetails.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TSlsOrderDetail;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSlsOrderDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TSlsOrderDetail.Create;
    if FFixedMasterId > 0 then
    begin
      LNew.SlsOrderId := FFixedMasterId;
      LNew.OrderNo := FFixedMasterName;
      LNew.Currency := FFixedCurrency;
    end;
    Result := TfrmSlsOrderDetail.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
  begin
    LNew := Table.Clone;
    // Kopya: yeni sıra no, teklif bağlantısı taşınmaz
    LNew.LineNo := 0;
    LNew.SlsOfferDetailId := 0;
    LNew.OfferNo := '';
    Result := TfrmSlsOrderDetail.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmSlsOrderDetails.SetSelectedItem;

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
  Table.OrderNo := FieldText('order_no');
  Table.Currency := FieldText('currency');
  Table.InventoryCode := FieldText('inventory_code');
  Table.InventoryName := FieldText('inventory_name');
  Table.UomCode := FieldText('uom_code');
  Table.OfferNo := FieldText('offer_no');
end;

procedure TfrmSlsOrderDetails.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('sls_order_id', 0);
  SetColumnProperty('stk_inventory_id', 0);
  SetColumnProperty('sls_offer_detail_id', 0);
  SetColumnProperty('acc_account_id', 0);
  LField := Grd.DataSource.DataSet.FindField('order_status');
  if Assigned(LField) then
    LField.OnGetText := OrderStatusGetText;
end;

procedure TfrmSlsOrderDetails.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSlsOrderDetails.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.TitlePlural, 'Order Lines');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColLineNo, 'Line No'));
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColQuantity, 'Quantity'));
  SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColUnitPrice, 'Unit Price'));
  SetColumnTitle('discount_rate', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColDiscountRate, 'Discount (%)'));
  SetColumnTitle('vat_rate', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColVatRate, 'VAT (%)'));
  SetColumnTitle('gross_amount', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColGrossAmount, 'Gross Amount'));
  SetColumnTitle('discount_amount', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColDiscountAmount, 'Discount Amount'));
  SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColNetAmount, 'Net Amount'));
  SetColumnTitle('vat_amount', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColVatAmount, 'VAT Amount'));
  SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColTotalAmount, 'Total'));
  SetColumnTitle('delivered_quantity', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColDeliveredQuantity, 'Delivered Quantity'));
  SetColumnTitle('delivery_date', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColDeliveryDate, 'Delivery Date'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColDescription, 'Description'));
  SetColumnTitle('order_no', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColOrderNo, 'Order No'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColCurrency, 'Currency'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColInventoryCode, 'Stock Code'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColInventoryName, 'Stock Name'));
  SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColUomCode, 'Unit'));
  SetColumnTitle('offer_no', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColOfferNo, 'Offer No'));
  SetColumnTitle('remaining_quantity', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColRemainingQuantity, 'Remaining Quantity'));
  SetColumnTitle('order_status', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColOrderStatus, 'Status'));
end;

end.
