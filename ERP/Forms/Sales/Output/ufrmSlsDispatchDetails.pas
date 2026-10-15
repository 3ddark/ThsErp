unit ufrmSlsDispatchDetails;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SlsDispatchDetail.Service, SlsDispatchDetail, ufrmSlsDispatchDetail;

type
  TfrmSlsDispatchDetails = class(TfrmGrid<TSlsDispatchDetail, TSlsDispatchDetailService>)
  private
    FFixedMasterId: Int64;
    FFixedMasterName: string;

  public
    procedure SetFixedDispatch(AMasterId: Int64; const AMasterName: string);
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

procedure TfrmSlsDispatchDetails.SetFixedDispatch(AMasterId: Int64; const AMasterName: string);
begin
  FFixedMasterId := AMasterId;
  FFixedMasterName := AMasterName;
  AddFixedFilter('sls_dispatch_id', AMasterId);
end;

function TfrmSlsDispatchDetails.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TSlsDispatchDetail;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSlsDispatchDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TSlsDispatchDetail.Create;
    if FFixedMasterId > 0 then
    begin
      LNew.SlsDispatchId := FFixedMasterId;
      LNew.DispatchNo := FFixedMasterName;
    end;
    Result := TfrmSlsDispatchDetail.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
  begin
    LNew := Table.Clone;
    // Kopya: sipariş kalemi bağlantısı taşınmaz
    LNew.SlsOrderDetailId := 0;
    LNew.OrderNo := '';
    Result := TfrmSlsDispatchDetail.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmSlsDispatchDetails.SetSelectedItem;

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
  Table.DispatchNo := FieldText('dispatch_no');
  Table.Currency := FieldText('currency');
  Table.InventoryCode := FieldText('inventory_code');
  Table.InventoryName := FieldText('inventory_name');
  Table.UomCode := FieldText('uom_code');
  Table.OrderNo := FieldText('order_no');
end;

procedure TfrmSlsDispatchDetails.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('sls_dispatch_id', 0);
  SetColumnProperty('stk_inventory_id', 0);
  SetColumnProperty('sls_order_detail_id', 0);
  SetColumnProperty('acc_account_id', 0);

end;

procedure TfrmSlsDispatchDetails.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSlsDispatchDetails.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.TitlePlural, 'Delivery Note Lines');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColQuantity, 'Quantity'));
  SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColUnitPrice, 'Net Unit Price'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColDescription, 'Description'));
  SetColumnTitle('dispatch_no', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColDispatchNo, 'Delivery Note No'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColCurrency, 'Currency'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColInventoryCode, 'Stock Code'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColInventoryName, 'Stock Name'));
  SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColUomCode, 'Unit'));
  SetColumnTitle('order_no', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColOrderNo, 'Order No'));
  SetColumnTitle('amount', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColAmount, 'Amount'));
  SetColumnTitle('order_line_no', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColOrderLineNo, 'Line No'));
  SetColumnTitle('invoiced_quantity', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColInvoicedQuantity, 'Invoiced Quantity'));
  SetColumnTitle('remaining_invoice_quantity', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColRemainingInvoiceQuantity, 'To Be Invoiced'));
end;

end.
