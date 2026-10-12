unit ufrmPurReceiptDetails;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PurReceiptDetail.Service, PurReceiptDetail, ufrmPurReceiptDetail;

type
  TfrmPurReceiptDetails = class(TfrmGrid<TPurReceiptDetail, TPurReceiptDetailService>)
  private
    FFixedMasterId: Int64;
    FFixedMasterName: string;

  public
    procedure SetFixedReceipt(AMasterId: Int64; const AMasterName: string);
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

procedure TfrmPurReceiptDetails.SetFixedReceipt(AMasterId: Int64; const AMasterName: string);
begin
  FFixedMasterId := AMasterId;
  FFixedMasterName := AMasterName;
  AddFixedFilter('pur_receipt_id', AMasterId);
end;

function TfrmPurReceiptDetails.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TPurReceiptDetail;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmPurReceiptDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TPurReceiptDetail.Create;
    if FFixedMasterId > 0 then
    begin
      LNew.PurReceiptId := FFixedMasterId;
      LNew.ReceiptNo := FFixedMasterName;
    end;
    Result := TfrmPurReceiptDetail.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
  begin
    LNew := Table.Clone;
    // Kopya: sipariş kalemi bağlantısı taşınmaz
    LNew.PurOrderDetailId := 0;
    LNew.OrderNo := '';
    Result := TfrmPurReceiptDetail.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPurReceiptDetails.SetSelectedItem;

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
  Table.ReceiptNo := FieldText('receipt_no');
  Table.Currency := FieldText('currency');
  Table.InventoryCode := FieldText('inventory_code');
  Table.InventoryName := FieldText('inventory_name');
  Table.UomCode := FieldText('uom_code');
  Table.OrderNo := FieldText('order_no');
end;

procedure TfrmPurReceiptDetails.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('pur_receipt_id', 0);
  SetColumnProperty('stk_inventory_id', 0);
  SetColumnProperty('pur_order_detail_id', 0);
  SetColumnProperty('acc_account_id', 0);

end;

procedure TfrmPurReceiptDetails.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPurReceiptDetails.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.TitlePlural, 'Receipt Lines');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColQuantity, 'Quantity'));
  SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColUnitPrice, 'Unit Cost'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColDescription, 'Description'));
  SetColumnTitle('receipt_no', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColReceiptNo, 'Receipt No'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColCurrency, 'Currency'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColInventoryCode, 'Stock Code'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColInventoryName, 'Stock Name'));
  SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColUomCode, 'Unit'));
  SetColumnTitle('order_no', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColOrderNo, 'Order No'));
  SetColumnTitle('amount', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColAmount, 'Amount'));
  SetColumnTitle('order_line_no', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColOrderLineNo, 'Line No'));
  SetColumnTitle('invoiced_quantity', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColInvoicedQuantity, 'Invoiced Quantity'));
  SetColumnTitle('remaining_invoice_quantity', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColRemainingInvoiceQuantity, 'To Be Invoiced'));
end;

end.
