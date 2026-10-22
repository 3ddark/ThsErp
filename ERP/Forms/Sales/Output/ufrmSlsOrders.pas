unit ufrmSlsOrders;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SlsOrder.Service, SlsOrder, ufrmSlsOrderDetail;

type
  TfrmSlsOrders = class(TfrmGrid<TSlsOrder, TSlsOrderService>)
  private
    FmniDispatches, FmniApprove, FmniToDraft, FmniCancel, FmniToDispatch, FmniToInvoice: TMenuItem;
    procedure mniDispatchesClick(Sender: TObject);
    procedure mniApproveClick(Sender: TObject);
    procedure mniToDraftClick(Sender: TObject);
    procedure mniCancelClick(Sender: TObject);
    procedure mniToDispatchClick(Sender: TObject);
    procedure mniToInvoiceClick(Sender: TObject);
    procedure SetStatus(AStatus: SmallInt);
    function SelectWarehouse: Int64;
    procedure StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure PreparePopupMenu; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure DefineFooterColumns; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SysDecimalPlace.Cache,
  SlsLookup,
  ufrmSlsDispatches, ufrmSlsDispatchDetail, SlsDispatch, SlsDispatch.Service,
  ufrmSlsInvoiceDetail, SlsInvoice, SlsInvoice.Service,
  StkWarehouse, StkWarehouse.Service, ufrmStkWarehouses;

procedure TfrmSlsOrders.StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TSlsLookup.Text(slkOrderStatus, Sender.AsInteger);
end;
procedure TfrmSlsOrders.mniDispatchesClick(Sender: TObject);
var
  LFrm: TfrmSlsDispatches;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmSlsDispatches.Create(Self, TSlsDispatchService.Create, TSlsDispatch.Create);
  LFrm.SetFixedOrder(Table.Id, Table.OrderNo);
  LFrm.Show;
end;

procedure TfrmSlsOrders.SetStatus(AStatus: SmallInt);
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  Service.ChangeStatus(Table.Id, AStatus, True);
  RefreshParentGrid(True);
end;

procedure TfrmSlsOrders.mniApproveClick(Sender: TObject);
begin
  SetStatus(SLS_ORD_APPROVED);
end;

procedure TfrmSlsOrders.mniToDraftClick(Sender: TObject);
begin
  SetStatus(SLS_ORD_DRAFT);
end;

procedure TfrmSlsOrders.mniCancelClick(Sender: TObject);
begin
  SetStatus(SLS_ORD_CANCELLED);
end;

// Çıkış ambarı: siparişin sevk ambarı, yoksa kullanıcı seçer (0 = vazgeçildi)
function TfrmSlsOrders.SelectWarehouse: Int64;
var
  LHelper: TfrmStkWarehouses;
begin
  Result := Table.StkWarehouseId;
  if Result > 0 then
    Exit;

  LHelper := TfrmStkWarehouses.Create(Self, TStkWarehouseService.Create, TStkWarehouse.Create);
  try
    LHelper.IsHelper := True;
    LHelper.ShowModal;
    if LHelper.DataTransfer and not LHelper.CleanAndClose then
      Result := LHelper.Table.Id;
  finally
    LHelper.Free;
  end;
end;

// Kalan miktarlarla sevk irsaliyesi oluşur (stok çıkışı) ve belge ekranında açılır
procedure TfrmSlsOrders.mniToDispatchClick(Sender: TObject);
var
  LDispatchSvc: TSlsDispatchService;
  LDispatch: TSlsDispatch;
  LWarehouseId, LDispatchId: Int64;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LWarehouseId := SelectWarehouse;
  if LWarehouseId <= 0 then
    Exit;

  LDispatchSvc := TSlsDispatchService.Create;
  try
    LDispatchId := LDispatchSvc.CreateFromOrder(Table.Id, LWarehouseId, True);
  finally
    LDispatchSvc.Free;
  end;
  // oluşan irsaliye belge ekranında (inceleme; Güncelle ile kalemler düzenlenir)
  LDispatchSvc := TSlsDispatchService.Create;
  LDispatch := LDispatchSvc.FindById(LDispatchId, False, True);
  TfrmSlsDispatchDetail.Create(Self, LDispatchSvc, LDispatch, ifmRewiev, nil, ivmNormal, True).Show;
  RefreshParentGrid(True);
end;

// Kalan miktarlarla irsaliyeli satış faturası oluşur (stok faturadan düşer) ve belge ekranında açılır
procedure TfrmSlsOrders.mniToInvoiceClick(Sender: TObject);
var
  LInvoiceSvc: TSlsInvoiceService;
  LInvoice: TSlsInvoice;
  LWarehouseId, LInvoiceId: Int64;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LWarehouseId := SelectWarehouse;
  if LWarehouseId <= 0 then
    Exit;

  LInvoiceSvc := TSlsInvoiceService.Create;
  try
    LInvoiceId := LInvoiceSvc.CreateFromOrder(Table.Id, LWarehouseId, True);
  finally
    LInvoiceSvc.Free;
  end;
  // oluşan fatura belge ekranında (inceleme; Güncelle ile kalemler düzenlenir)
  LInvoiceSvc := TSlsInvoiceService.Create;
  LInvoice := LInvoiceSvc.FindById(LInvoiceId, False, True);
  TfrmSlsInvoiceDetail.Create(Self, LInvoiceSvc, LInvoice, ifmRewiev, nil, ivmNormal, True).Show;
  RefreshParentGrid(True);
end;

procedure TfrmSlsOrders.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniDispatches := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsOrder.MenuDispatches, 'Delivery Notes'), 'mniDispatches', mniDispatchesClick);
  AddPopupMenuSpliter();
  FmniApprove := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsOrder.MenuApprove, 'Approve'), 'mniApprove', mniApproveClick);
  FmniToDraft := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsOrder.MenuToDraft, 'Back to Draft'), 'mniToDraft', mniToDraftClick);
  FmniCancel := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsOrder.MenuCancel, 'Cancel Order'), 'mniCancel', mniCancelClick);
  AddPopupMenuSpliter();
  FmniToDispatch := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsOrder.MenuToDispatch, 'Create Delivery Note'), 'mniToDispatch', mniToDispatchClick);
  FmniToInvoice := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsOrder.MenuToInvoice, 'Create Invoice with Delivery'), 'mniToInvoice', mniToInvoiceClick);
end;

// Başlık + kalemler tek ekranda (TfrmSlsOrderDetail); Table = BusinessFindById ile kalemli belge, Clone derin kopya.
// Kopya modunda form Service.PrepareCopy ile yeni numara / taslak / yeni kalemler hazırlar
function TfrmSlsOrders.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) or (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSlsOrderDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSlsOrderDetail.Create(Self, Service, TSlsOrder.Create, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmSlsOrders.SetSelectedItem;

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
  Table.EmployeeName := FieldText('employee_name');
end;

procedure TfrmSlsOrders.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_account_id', 0);
  SetColumnProperty('stk_warehouse_id', 0);
  SetColumnProperty('emp_employee_id', 0);
  // belgedeki cari kopyası (sys_grid_column satırı yoksa tüm view kolonları gelir) listede gösterilmez
  SetColumnProperty('account_title', 0);
  SetColumnProperty('taxpayer_type', 0);
  SetColumnProperty('taxpayer_name', 0);
  SetColumnProperty('taxpayer_name2', 0);
  SetColumnProperty('taxpayer_surname', 0);
  SetColumnProperty('tax_office', 0);
  SetColumnProperty('tax_no', 0);
  LField := Grd.DataSource.DataSet.FindField('status');
  if Assigned(LField) then
    LField.OnGetText := StatusGetText;
end;

// Alt toplamlar sayfanın değil filtreye uyan tüm kayıtların (sayfalı modda SQL ile)
procedure TfrmSlsOrders.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('net_amount', atSum, TDecimalPlaces.TotalFormat);
  AddFooterColumn('vat_amount', atSum, TDecimalPlaces.TotalFormat);
  AddFooterColumn('total_amount', atSum, TDecimalPlaces.TotalFormat);
end;

procedure TfrmSlsOrders.FormShow(Sender: TObject);
begin
  // Hızlı filtre: durum grupları; kayıt sayısı ve alt toplamlar seçili gruba (+ arama / popup filtre) göre
  if QuickFilterCount = 0 then
  begin
    AddQuickFilter('', '', []);
    AddQuickFilter('', 'status = :qc0', [SLS_ORD_DRAFT]);
    AddQuickFilter('', 'status IN (:qc0, :qc1)', [SLS_ORD_APPROVED, SLS_ORD_PARTIAL]);
    AddQuickFilter('', 'status = :qc0', [SLS_ORD_DELIVERED]);
  end;
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSlsOrders.ApplyLocalization;
begin
  inherited;
  SetQuickFilterCaption(0, TLocalizationManager.Translate(TLangKeys.TGeneral.QuickAll, 'All'));
  SetQuickFilterCaption(1, TLocalizationManager.Translate(TLangKeys.TSlsOrder.QuickUnapproved, 'Unapproved'));
  SetQuickFilterCaption(2, TLocalizationManager.Translate(TLangKeys.TSlsOrder.QuickPending, 'Pending'));
  SetQuickFilterCaption(3, TLocalizationManager.Translate(TLangKeys.TSlsOrder.QuickDelivered, 'Delivered'));
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.TitlePlural, 'Sales Orders');
  SetColumnTitle('order_no', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColOrderNo, 'Order No'));
  SetColumnTitle('order_date', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColOrderDate, 'Order Date'));
  SetColumnTitle('customer_ref_no', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColCustomerRefNo, 'Customer Order No'));
  SetColumnTitle('delivery_date', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColDeliveryDate, 'Delivery Date'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColCurrency, 'Currency'));
  SetColumnTitle('exchange_rate', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColExchangeRate, 'Exchange Rate'));
  SetColumnTitle('payment_term_days', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColPaymentTermDays, 'Payment Term (Days)'));
  SetColumnTitle('status', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColStatus, 'Status'));
  SetColumnTitle('gross_amount', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColGrossAmount, 'Gross Amount'));
  SetColumnTitle('discount_amount', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColDiscountAmount, 'Discount Amount'));
  SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColNetAmount, 'Net Amount'));
  SetColumnTitle('vat_amount', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColVatAmount, 'VAT Amount'));
  SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColTotalAmount, 'Total'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColDescription, 'Description'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColAccountCode, 'Customer Code'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColAccountName, 'Customer'));
  SetColumnTitle('warehouse_name', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColWarehouseName, 'Shipping Warehouse'));
  SetColumnTitle('employee_name', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColEmployeeName, 'Sales Representative'));
  SetColumnTitle('line_count', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColLineCount, 'Lines'));
  if Assigned(FmniDispatches) then
    FmniDispatches.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.MenuDispatches, 'Delivery Notes');
  if Assigned(FmniApprove) then
    FmniApprove.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.MenuApprove, 'Approve');
  if Assigned(FmniToDraft) then
    FmniToDraft.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.MenuToDraft, 'Back to Draft');
  if Assigned(FmniCancel) then
    FmniCancel.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.MenuCancel, 'Cancel Order');
  if Assigned(FmniToDispatch) then
    FmniToDispatch.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.MenuToDispatch, 'Create Delivery Note');
  if Assigned(FmniToInvoice) then
    FmniToInvoice.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.MenuToInvoice, 'Create Invoice with Delivery');
end;

end.
