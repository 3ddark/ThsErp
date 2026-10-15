unit ufrmSlsInvoiceDetails;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SlsInvoiceDetail.Service, SlsInvoiceDetail, ufrmSlsInvoiceDetail;

type
  TfrmSlsInvoiceDetails = class(TfrmGrid<TSlsInvoiceDetail, TSlsInvoiceDetailService>)
  private
    FFixedMasterId: Int64;
    FFixedMasterName: string;
    FFixedCurrency: string;

  public
    procedure SetFixedInvoice(AMasterId: Int64; const AMasterName, ACurrency: string);
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

procedure TfrmSlsInvoiceDetails.SetFixedInvoice(AMasterId: Int64; const AMasterName, ACurrency: string);
begin
  FFixedMasterId := AMasterId;
  FFixedMasterName := AMasterName;
  FFixedCurrency := ACurrency;
  AddFixedFilter('sls_invoice_id', AMasterId);
end;

function TfrmSlsInvoiceDetails.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TSlsInvoiceDetail;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSlsInvoiceDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TSlsInvoiceDetail.Create;
    if FFixedMasterId > 0 then
    begin
      LNew.SlsInvoiceId := FFixedMasterId;
      LNew.InvoiceNo := FFixedMasterName;
      LNew.Currency := FFixedCurrency;
    end;
    Result := TfrmSlsInvoiceDetail.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
  begin
    LNew := Table.Clone;
    // Kopya: yeni sıra no, irsaliye / sipariş bağlantısı taşınmaz
    LNew.LineNo := 0;
    LNew.SlsDispatchDetailId := 0;
    LNew.SlsOrderDetailId := 0;
    LNew.DispatchNo := '';
    LNew.OrderNo := '';
    Result := TfrmSlsInvoiceDetail.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmSlsInvoiceDetails.SetSelectedItem;

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
  Table.InvoiceNo := FieldText('invoice_no');
  Table.Currency := FieldText('currency');
  Table.InventoryCode := FieldText('inventory_code');
  Table.InventoryName := FieldText('inventory_name');
  Table.UomCode := FieldText('uom_code');
  Table.DispatchNo := FieldText('dispatch_no');
  Table.OrderNo := FieldText('order_no');
end;

procedure TfrmSlsInvoiceDetails.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('sls_invoice_id', 0);
  SetColumnProperty('stk_inventory_id', 0);
  SetColumnProperty('sls_dispatch_detail_id', 0);
  SetColumnProperty('sls_order_detail_id', 0);
  SetColumnProperty('acc_account_id', 0);

end;

procedure TfrmSlsInvoiceDetails.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSlsInvoiceDetails.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.TitlePlural, 'Invoice Lines');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColLineNo, 'Line No'));
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColQuantity, 'Quantity'));
  SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColUnitPrice, 'Unit Price'));
  SetColumnTitle('discount_rate', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColDiscountRate, 'Discount (%)'));
  SetColumnTitle('vat_rate', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColVatRate, 'VAT (%)'));
  SetColumnTitle('gross_amount', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColGrossAmount, 'Gross Amount'));
  SetColumnTitle('discount_amount', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColDiscountAmount, 'Discount Amount'));
  SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColNetAmount, 'Net Amount'));
  SetColumnTitle('vat_amount', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColVatAmount, 'VAT Amount'));
  SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColTotalAmount, 'Total'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColDescription, 'Description'));
  SetColumnTitle('invoice_no', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColInvoiceNo, 'Invoice No'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColCurrency, 'Currency'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColInventoryCode, 'Stock Code'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColInventoryName, 'Stock Name'));
  SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColUomCode, 'Unit'));
  SetColumnTitle('dispatch_no', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColDispatchNo, 'Delivery Note No'));
  SetColumnTitle('order_no', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColOrderNo, 'Order No'));
end;

end.
