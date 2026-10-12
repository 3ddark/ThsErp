unit ufrmPurOrders;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PurOrder.Service, PurOrder, ufrmPurOrder;

type
  TfrmPurOrders = class(TfrmGrid<TPurOrder, TPurOrderService>)
  private
    FmniLines, FmniReceipts, FmniApprove, FmniToDraft, FmniCancel, FmniToReceipt: TMenuItem;
    procedure mniLinesClick(Sender: TObject);
    procedure mniReceiptsClick(Sender: TObject);
    procedure mniApproveClick(Sender: TObject);
    procedure mniToDraftClick(Sender: TObject);
    procedure mniCancelClick(Sender: TObject);
    procedure mniToReceiptClick(Sender: TObject);
    procedure SetStatus(AStatus: SmallInt);
    procedure StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
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
  PurLookup,
  ufrmPurOrderDetails, PurOrderDetail, PurOrderDetail.Service,
  ufrmPurReceipts, ufrmPurReceiptDetails, PurReceipt, PurReceipt.Service, PurReceiptDetail, PurReceiptDetail.Service,
  StkWarehouse, StkWarehouse.Service, ufrmStkWarehouses;

procedure TfrmPurOrders.StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TPurLookup.Text(plkOrderStatus, Sender.AsInteger);
end;
procedure TfrmPurOrders.mniLinesClick(Sender: TObject);
var
  LFrm: TfrmPurOrderDetails;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmPurOrderDetails.Create(Self, TPurOrderDetailService.Create, TPurOrderDetail.Create);
  LFrm.SetFixedOrder(Table.Id, Table.OrderNo, Table.Currency);
  LFrm.Show;
end;

procedure TfrmPurOrders.mniReceiptsClick(Sender: TObject);
var
  LFrm: TfrmPurReceipts;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmPurReceipts.Create(Self, TPurReceiptService.Create, TPurReceipt.Create);
  LFrm.SetFixedOrder(Table.Id, Table.OrderNo);
  LFrm.Show;
end;

procedure TfrmPurOrders.SetStatus(AStatus: SmallInt);
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  Service.ChangeStatus(Table.Id, AStatus, True);
  RefreshParentGrid(True);
end;

procedure TfrmPurOrders.mniApproveClick(Sender: TObject);
begin
  SetStatus(PUR_ORD_APPROVED);
end;

procedure TfrmPurOrders.mniToDraftClick(Sender: TObject);
begin
  SetStatus(PUR_ORD_DRAFT);
end;

procedure TfrmPurOrders.mniCancelClick(Sender: TObject);
begin
  SetStatus(PUR_ORD_CANCELLED);
end;

// Kalan miktarlarla mal kabul açılır (ambar: siparişin teslim ambarı, yoksa seçilir) ve kalemleri gösterilir
procedure TfrmPurOrders.mniToReceiptClick(Sender: TObject);
var
  LHelper: TfrmStkWarehouses;
  LReceiptSvc: TPurReceiptService;
  LReceipt: TPurReceipt;
  LWarehouseId, LReceiptId: Int64;
  LFrm: TfrmPurReceiptDetails;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LWarehouseId := Table.StkWarehouseId;
  if LWarehouseId <= 0 then
  begin
    LHelper := TfrmStkWarehouses.Create(Self, TStkWarehouseService.Create, TStkWarehouse.Create);
    try
      LHelper.IsHelper := True;
      LHelper.ShowModal;
      if LHelper.DataTransfer and not LHelper.CleanAndClose then
        LWarehouseId := LHelper.Table.Id;
    finally
      LHelper.Free;
    end;
    if LWarehouseId <= 0 then
      Exit;
  end;

  LReceiptSvc := TPurReceiptService.Create;
  try
    LReceiptId := LReceiptSvc.CreateFromOrder(Table.Id, LWarehouseId, True);
    LReceipt := LReceiptSvc.FindById(LReceiptId, False);
    try
      LFrm := TfrmPurReceiptDetails.Create(Self, TPurReceiptDetailService.Create, TPurReceiptDetail.Create);
      LFrm.SetFixedReceipt(LReceipt.Id, LReceipt.ReceiptNo);
      LFrm.Show;
    finally
      LReceipt.Free;
    end;
  finally
    LReceiptSvc.Free;
  end;
  RefreshParentGrid(True);
end;

procedure TfrmPurOrders.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniLines := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurOrder.MenuLines, 'Lines'), 'mniLines', mniLinesClick);
  FmniReceipts := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurOrder.MenuReceipts, 'Goods Receipts'), 'mniReceipts', mniReceiptsClick);
  AddPopupMenuSpliter();
  FmniApprove := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurOrder.MenuApprove, 'Approve'), 'mniApprove', mniApproveClick);
  FmniToDraft := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurOrder.MenuToDraft, 'Back to Draft'), 'mniToDraft', mniToDraftClick);
  FmniCancel := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurOrder.MenuCancel, 'Cancel Order'), 'mniCancel', mniCancelClick);
  AddPopupMenuSpliter();
  FmniToReceipt := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurOrder.MenuToReceipt, 'Create Goods Receipt'), 'mniToReceipt', mniToReceiptClick);
end;

function TfrmPurOrders.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TPurOrder;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmPurOrder.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmPurOrder.Create(Self, Service, TPurOrder.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
  begin
    LNew := Table.Clone;
    // Kopya: yeni numara, taslak, tutarlar kalemlerden yeniden hesaplanır
    LNew.OrderNo := '';
    LNew.Status := PUR_ORD_DRAFT;
    Result := TfrmPurOrder.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPurOrders.SetSelectedItem;

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
  Table.AccountCode := FieldText('account_code');
  Table.AccountName := FieldText('account_name');
  Table.WarehouseName := FieldText('warehouse_name');
end;

procedure TfrmPurOrders.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_account_id', 0);
  SetColumnProperty('stk_warehouse_id', 0);
  LField := Grd.DataSource.DataSet.FindField('status');
  if Assigned(LField) then
    LField.OnGetText := StatusGetText;
end;

procedure TfrmPurOrders.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPurOrders.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.TitlePlural, 'Purchase Orders');
  SetColumnTitle('order_no', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColOrderNo, 'Order No'));
  SetColumnTitle('order_date', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColOrderDate, 'Order Date'));
  SetColumnTitle('supplier_ref_no', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColSupplierRefNo, 'Supplier Ref. No'));
  SetColumnTitle('delivery_date', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColDeliveryDate, 'Delivery Date'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColCurrency, 'Currency'));
  SetColumnTitle('exchange_rate', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColExchangeRate, 'Exchange Rate'));
  SetColumnTitle('payment_term_days', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColPaymentTermDays, 'Payment Term (Days)'));
  SetColumnTitle('status', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColStatus, 'Status'));
  SetColumnTitle('gross_amount', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColGrossAmount, 'Gross Amount'));
  SetColumnTitle('discount_amount', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColDiscountAmount, 'Discount Amount'));
  SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColNetAmount, 'Net Amount'));
  SetColumnTitle('vat_amount', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColVatAmount, 'VAT Amount'));
  SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColTotalAmount, 'Total'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColDescription, 'Description'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColAccountCode, 'Supplier Code'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColAccountName, 'Supplier'));
  SetColumnTitle('warehouse_name', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColWarehouseName, 'Delivery Warehouse'));
  SetColumnTitle('line_count', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColLineCount, 'Lines'));
  if Assigned(FmniLines) then
    FmniLines.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.MenuLines, 'Lines');
  if Assigned(FmniReceipts) then
    FmniReceipts.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.MenuReceipts, 'Goods Receipts');
  if Assigned(FmniApprove) then
    FmniApprove.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.MenuApprove, 'Approve');
  if Assigned(FmniToDraft) then
    FmniToDraft.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.MenuToDraft, 'Back to Draft');
  if Assigned(FmniCancel) then
    FmniCancel.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.MenuCancel, 'Cancel Order');
  if Assigned(FmniToReceipt) then
    FmniToReceipt.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.MenuToReceipt, 'Create Goods Receipt');
end;

end.
