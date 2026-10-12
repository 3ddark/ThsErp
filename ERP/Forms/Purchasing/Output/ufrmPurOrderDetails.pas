unit ufrmPurOrderDetails;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PurOrderDetail.Service, PurOrderDetail, ufrmPurOrderDetail;

type
  TfrmPurOrderDetails = class(TfrmGrid<TPurOrderDetail, TPurOrderDetailService>)
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
  PurLookup;

procedure TfrmPurOrderDetails.OrderStatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TPurLookup.Text(plkOrderStatus, Sender.AsInteger);
end;
procedure TfrmPurOrderDetails.SetFixedOrder(AMasterId: Int64; const AMasterName, ACurrency: string);
begin
  FFixedMasterId := AMasterId;
  FFixedMasterName := AMasterName;
  FFixedCurrency := ACurrency;
  AddFixedFilter('pur_order_id', AMasterId);
end;

function TfrmPurOrderDetails.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TPurOrderDetail;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmPurOrderDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TPurOrderDetail.Create;
    if FFixedMasterId > 0 then
    begin
      LNew.PurOrderId := FFixedMasterId;
      LNew.OrderNo := FFixedMasterName;
      LNew.Currency := FFixedCurrency;
    end;
    Result := TfrmPurOrderDetail.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
  begin
    LNew := Table.Clone;
    // Kopya: yeni sıra no, talep bağlantısı taşınmaz
    LNew.LineNo := 0;
    LNew.PurRequestDetailId := 0;
    LNew.RequestNo := '';
    Result := TfrmPurOrderDetail.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPurOrderDetails.SetSelectedItem;

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
  Table.RequestNo := FieldText('request_no');
end;

procedure TfrmPurOrderDetails.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('pur_order_id', 0);
  SetColumnProperty('stk_inventory_id', 0);
  SetColumnProperty('pur_request_detail_id', 0);
  SetColumnProperty('acc_account_id', 0);
  LField := Grd.DataSource.DataSet.FindField('order_status');
  if Assigned(LField) then
    LField.OnGetText := OrderStatusGetText;
end;

procedure TfrmPurOrderDetails.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPurOrderDetails.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.TitlePlural, 'Order Lines');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColLineNo, 'Line No'));
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColQuantity, 'Quantity'));
  SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColUnitPrice, 'Unit Price'));
  SetColumnTitle('discount_rate', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColDiscountRate, 'Discount (%)'));
  SetColumnTitle('vat_rate', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColVatRate, 'VAT (%)'));
  SetColumnTitle('gross_amount', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColGrossAmount, 'Gross Amount'));
  SetColumnTitle('discount_amount', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColDiscountAmount, 'Discount Amount'));
  SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColNetAmount, 'Net Amount'));
  SetColumnTitle('vat_amount', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColVatAmount, 'VAT Amount'));
  SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColTotalAmount, 'Total'));
  SetColumnTitle('received_quantity', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColReceivedQuantity, 'Received Quantity'));
  SetColumnTitle('delivery_date', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColDeliveryDate, 'Delivery Date'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColDescription, 'Description'));
  SetColumnTitle('order_no', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColOrderNo, 'Order No'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColCurrency, 'Currency'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColInventoryCode, 'Stock Code'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColInventoryName, 'Stock Name'));
  SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColUomCode, 'Unit'));
  SetColumnTitle('request_no', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColRequestNo, 'Request No'));
  SetColumnTitle('remaining_quantity', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColRemainingQuantity, 'Remaining Quantity'));
  SetColumnTitle('order_status', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColOrderStatus, 'Status'));
end;

end.
