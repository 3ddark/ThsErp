unit ufrmPurQuotations;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PurQuotation.Service, PurQuotation, ufrmPurQuotationDetail;

type
  // Alış teklifleri: durum hızlı filtreleri; popup ile onaya gönder / taslağa al / onayla / reddet (özel yetki),
  // siparişe dönüştür, talebin teklif karşılaştırması. Talep listesinden SetFixedRequest ile talebin teklifleri açılır.
  TfrmPurQuotations = class(TfrmGrid<TPurQuotation, TPurQuotationService>)
  private
    FFixedRequestId: Int64;
    FFixedRequestName: string;
    FmniSubmit, FmniToDraft, FmniApprove, FmniReject, FmniToOrder, FmniCompare: TMenuItem;
    procedure mniSubmitClick(Sender: TObject);
    procedure mniToDraftClick(Sender: TObject);
    procedure mniApproveClick(Sender: TObject);
    procedure mniRejectClick(Sender: TObject);
    procedure mniToOrderClick(Sender: TObject);
    procedure mniCompareClick(Sender: TObject);
    procedure SetStatus(AStatus: SmallInt);
    procedure StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure SetFixedRequest(ARequestId: Int64; const ARequestName: string);
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
  ufrmPurOrderDetail, PurOrder, PurOrder.Service,
  ufrmPurQuotationComparisons, PurQuotationComparison, PurQuotationComparison.Service;

procedure TfrmPurQuotations.StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TPurLookup.Text(plkQuotationStatus, Sender.AsInteger);
end;

procedure TfrmPurQuotations.SetFixedRequest(ARequestId: Int64; const ARequestName: string);
begin
  FFixedRequestId := ARequestId;
  FFixedRequestName := ARequestName;
  AddFixedFilter('pur_request_id', ARequestId);
end;

procedure TfrmPurQuotations.SetStatus(AStatus: SmallInt);
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  Service.ChangeStatus(Table.Id, AStatus, True);
  RefreshParentGrid(True);
end;

procedure TfrmPurQuotations.mniSubmitClick(Sender: TObject);
begin
  SetStatus(PUR_QUO_PENDING);
end;

procedure TfrmPurQuotations.mniToDraftClick(Sender: TObject);
begin
  SetStatus(PUR_QUO_DRAFT);
end;

procedure TfrmPurQuotations.mniApproveClick(Sender: TObject);
begin
  SetStatus(PUR_QUO_APPROVED);
end;

procedure TfrmPurQuotations.mniRejectClick(Sender: TObject);
begin
  SetStatus(PUR_QUO_REJECTED);
end;

// Onaylı tekliften taslak sipariş açılır ve belge ekranında gösterilir
procedure TfrmPurQuotations.mniToOrderClick(Sender: TObject);
var
  LOrderSvc: TPurOrderService;
  LOrder: TPurOrder;
  LOrderId: Int64;
  LFrm: TfrmPurOrderDetail;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LOrderId := Service.CreateOrder(Table.Id, True);
  // oluşan taslak sipariş belge ekranında (inceleme; Güncelle ile düzenlenir)
  LOrderSvc := TPurOrderService.Create;
  LOrder := LOrderSvc.FindById(LOrderId, False, True);
  LFrm := TfrmPurOrderDetail.Create(Self, LOrderSvc, LOrder, ifmRewiev, nil, ivmNormal, True);
  LFrm.Show;
  RefreshParentGrid(True);
end;

// Seçili teklifin talebine ait karşılaştırma
procedure TfrmPurQuotations.mniCompareClick(Sender: TObject);
var
  LFrm: TfrmPurQuotationComparisons;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  if Table.PurRequestId <= 0 then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TPurQuotation.NoRequest,
      'This quotation is not linked to a purchase request.'));
  LFrm := TfrmPurQuotationComparisons.Create(Self, TPurQuotationComparisonService.Create, TPurQuotationComparison.Create);
  LFrm.SetFixedRequest(Table.PurRequestId, Table.RequestNo);
  LFrm.Show;
end;

procedure TfrmPurQuotations.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniSubmit := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurQuotation.MenuSubmit, 'Select && Send for Approval'), 'mniSubmit', mniSubmitClick);
  FmniToDraft := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurQuotation.MenuToDraft, 'Back to Draft'), 'mniToDraft', mniToDraftClick);
  AddPopupMenuSpliter();
  FmniApprove := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurQuotation.MenuApprove, 'Approve'), 'mniApprove', mniApproveClick);
  FmniReject := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurQuotation.MenuReject, 'Reject'), 'mniReject', mniRejectClick);
  AddPopupMenuSpliter();
  FmniToOrder := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurQuotation.MenuToOrder, 'Convert to Order'), 'mniToOrder', mniToOrderClick);
  FmniCompare := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurQuotation.MenuCompare, 'Compare Quotations'), 'mniCompare', mniCompareClick);
  // onay kararları özel yetki ister (servis yine kontrol eder)
  FmniApprove.Enabled := Service.CanApprove;
  FmniReject.Enabled := FmniApprove.Enabled;
end;

// Belge ekranı (başlık + kalemler); kopyada belge formu Service.PrepareCopy ile yeni no / taslak / yeni kalemler verir
function TfrmPurQuotations.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LQuotation: TPurQuotation;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) or (AFormMode = ifmCopyNewRecord) then
    Result := TfrmPurQuotationDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LQuotation := TPurQuotation.Create;
    // talebin teklifleri açıkken yeni teklif o talebe bağlanır
    LQuotation.PurRequestId := FFixedRequestId;
    LQuotation.RequestNo := FFixedRequestName;
    Result := TfrmPurQuotationDetail.Create(Self, Service, LQuotation, AFormMode, Self.RefreshParentGrid);
  end;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPurQuotations.SetSelectedItem;

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
  Table.RequestNo := FieldText('request_no');
  Table.AccountCode := FieldText('account_code');
  Table.AccountName := FieldText('account_name');
  Table.OrderNo := FieldText('order_no');
  Table.ApprovedBy := FieldText('approved_by');
end;

procedure TfrmPurQuotations.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('pur_request_id', 0);
  SetColumnProperty('acc_account_id', 0);
  SetColumnProperty('pur_order_id', 0);
  SetColumnProperty('approved_sys_user_id', 0);
  LField := Grd.DataSource.DataSet.FindField('status');
  if Assigned(LField) then
    LField.OnGetText := StatusGetText;
end;

procedure TfrmPurQuotations.FormShow(Sender: TObject);
begin
  // Hızlı filtre: durum grupları
  if QuickFilterCount = 0 then
  begin
    AddQuickFilter('', '', []);
    AddQuickFilter('', 'status = :qc0', [PUR_QUO_DRAFT]);
    AddQuickFilter('', 'status = :qc0', [PUR_QUO_PENDING]);
    AddQuickFilter('', 'status IN (:qc0, :qc1)', [PUR_QUO_APPROVED, PUR_QUO_ORDERED]);
    AddQuickFilter('', 'status IN (:qc0, :qc1)', [PUR_QUO_REJECTED, PUR_QUO_NOT_SELECTED]);
  end;
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPurQuotations.ApplyLocalization;
begin
  inherited;
  SetQuickFilterCaption(0, TLocalizationManager.Translate(TLangKeys.TGeneral.QuickAll, 'All'));
  SetQuickFilterCaption(1, TLocalizationManager.Translate(TLangKeys.TPurOption.QuoDraft, 'Draft'));
  SetQuickFilterCaption(2, TLocalizationManager.Translate(TLangKeys.TPurOption.QuoPending, 'Pending Approval'));
  SetQuickFilterCaption(3, TLocalizationManager.Translate(TLangKeys.TPurOption.QuoApproved, 'Approved'));
  SetQuickFilterCaption(4, TLocalizationManager.Translate(TLangKeys.TPurQuotation.QuickClosed, 'Rejected / Not Selected'));
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.TitlePlural, 'Purchase Quotations');
  if FFixedRequestName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedRequestName;
  SetColumnTitle('quotation_no', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColQuotationNo, 'Quotation No'));
  SetColumnTitle('quotation_date', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColQuotationDate, 'Quotation Date'));
  SetColumnTitle('request_no', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColRequestNo, 'Request No'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColAccountCode, 'Supplier Code'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColAccountName, 'Supplier'));
  SetColumnTitle('supplier_ref_no', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColSupplierRefNo, 'Supplier Ref. No'));
  SetColumnTitle('valid_until', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColValidUntil, 'Valid Until'));
  SetColumnTitle('delivery_days', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColDeliveryDays, 'Delivery Time (Days)'));
  SetColumnTitle('delivery_date', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColDeliveryDate, 'Delivery Date'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColCurrency, 'Currency'));
  SetColumnTitle('exchange_rate', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColExchangeRate, 'Exchange Rate'));
  SetColumnTitle('payment_term_days', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColPaymentTermDays, 'Payment Term (Days)'));
  SetColumnTitle('payment_terms', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColPaymentTerms, 'Payment Terms'));
  SetColumnTitle('status', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColStatus, 'Status'));
  SetColumnTitle('gross_amount', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColGrossAmount, 'Gross Amount'));
  SetColumnTitle('discount_amount', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColDiscountAmount, 'Discount Amount'));
  SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColNetAmount, 'Net Amount'));
  SetColumnTitle('vat_amount', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColVatAmount, 'VAT Amount'));
  SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColTotalAmount, 'Total'));
  SetColumnTitle('net_amount_base', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColNetAmountBase, 'Net Amount (Base Currency)'));
  SetColumnTitle('total_amount_base', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColTotalAmountBase, 'Total (Base Currency)'));
  SetColumnTitle('order_no', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColOrderNo, 'Order No'));
  SetColumnTitle('approved_by', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColApprovedBy, 'Approved By'));
  SetColumnTitle('approved_at', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColApprovedAt, 'Approved At'));
  SetColumnTitle('line_count', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColLineCount, 'Lines'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColDescription, 'Description'));
  if Assigned(FmniSubmit) then
    FmniSubmit.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.MenuSubmit, 'Select && Send for Approval');
  if Assigned(FmniToDraft) then
    FmniToDraft.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.MenuToDraft, 'Back to Draft');
  if Assigned(FmniApprove) then
    FmniApprove.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.MenuApprove, 'Approve');
  if Assigned(FmniReject) then
    FmniReject.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.MenuReject, 'Reject');
  if Assigned(FmniToOrder) then
    FmniToOrder.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.MenuToOrder, 'Convert to Order');
  if Assigned(FmniCompare) then
    FmniCompare.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.MenuCompare, 'Compare Quotations');
end;

end.
