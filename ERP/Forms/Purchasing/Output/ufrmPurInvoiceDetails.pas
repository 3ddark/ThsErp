unit ufrmPurInvoiceDetails;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PurInvoiceDetail.Service, PurInvoiceDetail, ufrmPurInvoiceDetail;

type
  TfrmPurInvoiceDetails = class(TfrmGrid<TPurInvoiceDetail, TPurInvoiceDetailService>)
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
  PurLookup;

procedure TfrmPurInvoiceDetails.SetFixedInvoice(AMasterId: Int64; const AMasterName, ACurrency: string);
begin
  FFixedMasterId := AMasterId;
  FFixedMasterName := AMasterName;
  FFixedCurrency := ACurrency;
  AddFixedFilter('pur_invoice_id', AMasterId);
end;

function TfrmPurInvoiceDetails.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TPurInvoiceDetail;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmPurInvoiceDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TPurInvoiceDetail.Create;
    if FFixedMasterId > 0 then
    begin
      LNew.PurInvoiceId := FFixedMasterId;
      LNew.InvoiceNo := FFixedMasterName;
      LNew.Currency := FFixedCurrency;
    end;
    Result := TfrmPurInvoiceDetail.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
  begin
    LNew := Table.Clone;
    // Kopya: yeni sıra no, mal kabul bağlantısı taşınmaz
    LNew.LineNo := 0;
    LNew.PurReceiptDetailId := 0;
    LNew.ReceiptNo := '';
    Result := TfrmPurInvoiceDetail.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPurInvoiceDetails.SetSelectedItem;

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
  Table.ReceiptNo := FieldText('receipt_no');
end;

procedure TfrmPurInvoiceDetails.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('pur_invoice_id', 0);
  SetColumnProperty('stk_inventory_id', 0);
  SetColumnProperty('pur_receipt_detail_id', 0);
  SetColumnProperty('acc_account_id', 0);

end;

procedure TfrmPurInvoiceDetails.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPurInvoiceDetails.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.TitlePlural, 'Invoice Lines');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColLineNo, 'Line No'));
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColQuantity, 'Quantity'));
  SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColUnitPrice, 'Unit Price'));
  SetColumnTitle('discount_rate', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColDiscountRate, 'Discount (%)'));
  SetColumnTitle('vat_rate', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColVatRate, 'VAT (%)'));
  SetColumnTitle('gross_amount', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColGrossAmount, 'Gross Amount'));
  SetColumnTitle('discount_amount', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColDiscountAmount, 'Discount Amount'));
  SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColNetAmount, 'Net Amount'));
  SetColumnTitle('vat_amount', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColVatAmount, 'VAT Amount'));
  SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColTotalAmount, 'Total'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColDescription, 'Description'));
  SetColumnTitle('invoice_no', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColInvoiceNo, 'Invoice No'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColCurrency, 'Currency'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColInventoryCode, 'Stock Code'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColInventoryName, 'Stock Name'));
  SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColUomCode, 'Unit'));
  SetColumnTitle('receipt_no', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColReceiptNo, 'Receipt No'));
end;

end.
