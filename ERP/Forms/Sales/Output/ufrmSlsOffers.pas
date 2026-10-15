unit ufrmSlsOffers;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SlsOffer.Service, SlsOffer, ufrmSlsOffer;

type
  TfrmSlsOffers = class(TfrmGrid<TSlsOffer, TSlsOfferService>)
  private
    FmniLines, FmniSend, FmniToDraft, FmniReject, FmniClose, FmniToOrder: TMenuItem;
    procedure mniLinesClick(Sender: TObject);
    procedure mniSendClick(Sender: TObject);
    procedure mniToDraftClick(Sender: TObject);
    procedure mniRejectClick(Sender: TObject);
    procedure mniCloseClick(Sender: TObject);
    procedure mniToOrderClick(Sender: TObject);
    procedure SetStatus(AStatus: SmallInt);
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
  SlsLookup,
  ufrmSlsOfferDetails, SlsOfferDetail, SlsOfferDetail.Service,
  ufrmSlsOrderDetails, SlsOrderDetail, SlsOrderDetail.Service, SlsOrder, SlsOrder.Service;

procedure TfrmSlsOffers.StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TSlsLookup.Text(slkOfferStatus, Sender.AsInteger);
end;
procedure TfrmSlsOffers.mniLinesClick(Sender: TObject);
var
  LFrm: TfrmSlsOfferDetails;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmSlsOfferDetails.Create(Self, TSlsOfferDetailService.Create, TSlsOfferDetail.Create);
  LFrm.SetFixedOffer(Table.Id, Table.OfferNo, Table.Currency);
  LFrm.Show;
end;

procedure TfrmSlsOffers.SetStatus(AStatus: SmallInt);
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  Service.ChangeStatus(Table.Id, AStatus, True);
  RefreshParentGrid(True);
end;

procedure TfrmSlsOffers.mniSendClick(Sender: TObject);
begin
  SetStatus(SLS_OFF_SENT);
end;

procedure TfrmSlsOffers.mniToDraftClick(Sender: TObject);
begin
  SetStatus(SLS_OFF_DRAFT);
end;

procedure TfrmSlsOffers.mniRejectClick(Sender: TObject);
begin
  SetStatus(SLS_OFF_REJECTED);
end;

procedure TfrmSlsOffers.mniCloseClick(Sender: TObject);
begin
  SetStatus(SLS_OFF_CLOSED);
end;

// Teklifin kalan miktarlarıyla (fiyat / iskonto / KDV tekliften) taslak sipariş açılır ve kalemleri gösterilir
procedure TfrmSlsOffers.mniToOrderClick(Sender: TObject);
var
  LOrderSvc: TSlsOrderService;
  LOrder: TSlsOrder;
  LOrderId: Int64;
  LFrm: TfrmSlsOrderDetails;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LOrderSvc := TSlsOrderService.Create;
  try
    LOrderId := LOrderSvc.CreateFromOffer(Table.Id, True);
    LOrder := LOrderSvc.FindById(LOrderId, False);
    try
      LFrm := TfrmSlsOrderDetails.Create(Self, TSlsOrderDetailService.Create, TSlsOrderDetail.Create);
      LFrm.SetFixedOrder(LOrder.Id, LOrder.OrderNo, LOrder.Currency);
      LFrm.Show;
    finally
      LOrder.Free;
    end;
  finally
    LOrderSvc.Free;
  end;
  RefreshParentGrid(True);
end;

procedure TfrmSlsOffers.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniLines := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuLines, 'Lines'), 'mniLines', mniLinesClick);
  AddPopupMenuSpliter();
  FmniSend := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuSend, 'Mark as Sent'), 'mniSend', mniSendClick);
  FmniToDraft := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuToDraft, 'Back to Draft'), 'mniToDraft', mniToDraftClick);
  FmniReject := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuReject, 'Rejected by Customer'), 'mniReject', mniRejectClick);
  FmniClose := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuClose, 'Close'), 'mniClose', mniCloseClick);
  AddPopupMenuSpliter();
  FmniToOrder := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuToOrder, 'Convert to Order'), 'mniToOrder', mniToOrderClick);
end;

function TfrmSlsOffers.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TSlsOffer;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSlsOffer.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSlsOffer.Create(Self, Service, TSlsOffer.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
  begin
    LNew := Table.Clone;
    // Kopya: yeni numara, taslak, tutarlar kalemlerden yeniden hesaplanır
    LNew.OfferNo := '';
    LNew.Status := SLS_OFF_DRAFT;
    Result := TfrmSlsOffer.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmSlsOffers.SetSelectedItem;

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
  Table.EmployeeName := FieldText('employee_name');
end;

procedure TfrmSlsOffers.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_account_id', 0);
  SetColumnProperty('emp_employee_id', 0);
  LField := Grd.DataSource.DataSet.FindField('status');
  if Assigned(LField) then
    LField.OnGetText := StatusGetText;
end;

// Alt toplamlar sayfanın değil filtreye uyan tüm kayıtların (sayfalı modda SQL ile)
procedure TfrmSlsOffers.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('net_amount', atSum, '#,##0.00');
  AddFooterColumn('vat_amount', atSum, '#,##0.00');
  AddFooterColumn('total_amount', atSum, '#,##0.00');
end;

procedure TfrmSlsOffers.FormShow(Sender: TObject);
begin
  // Hızlı filtre: durum grupları; kayıt sayısı ve alt toplamlar seçili gruba (+ arama / popup filtre) göre
  if QuickFilterCount = 0 then
  begin
    AddQuickFilter('', '', []);
    AddQuickFilter('', 'status = :qc0', [SLS_OFF_DRAFT]);
    AddQuickFilter('', 'status = :qc0', [SLS_OFF_SENT]);
    AddQuickFilter('', 'status = :qc0', [SLS_OFF_ORDERED]);
    AddQuickFilter('', 'status IN (:qc0, :qc1)', [SLS_OFF_REJECTED, SLS_OFF_CLOSED]);
  end;
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSlsOffers.ApplyLocalization;
begin
  inherited;
  SetQuickFilterCaption(0, TLocalizationManager.Translate(TLangKeys.TGeneral.QuickAll, 'All'));
  SetQuickFilterCaption(1, TLocalizationManager.Translate(TLangKeys.TSlsOffer.QuickDraft, 'Draft'));
  SetQuickFilterCaption(2, TLocalizationManager.Translate(TLangKeys.TSlsOffer.QuickSent, 'Sent'));
  SetQuickFilterCaption(3, TLocalizationManager.Translate(TLangKeys.TSlsOffer.QuickOrdered, 'Ordered'));
  SetQuickFilterCaption(4, TLocalizationManager.Translate(TLangKeys.TSlsOffer.QuickClosed, 'Rejected / Closed'));
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.TitlePlural, 'Sales Offers');
  SetColumnTitle('offer_no', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColOfferNo, 'Offer No'));
  SetColumnTitle('offer_date', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColOfferDate, 'Offer Date'));
  SetColumnTitle('valid_until', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColValidUntil, 'Valid Until'));
  SetColumnTitle('customer_ref_no', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColCustomerRefNo, 'Customer Ref. No'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColCurrency, 'Currency'));
  SetColumnTitle('exchange_rate', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColExchangeRate, 'Exchange Rate'));
  SetColumnTitle('payment_term_days', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColPaymentTermDays, 'Payment Term (Days)'));
  SetColumnTitle('status', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColStatus, 'Status'));
  SetColumnTitle('gross_amount', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColGrossAmount, 'Gross Amount'));
  SetColumnTitle('discount_amount', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColDiscountAmount, 'Discount Amount'));
  SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColNetAmount, 'Net Amount'));
  SetColumnTitle('vat_amount', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColVatAmount, 'VAT Amount'));
  SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColTotalAmount, 'Total'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColDescription, 'Description'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColAccountCode, 'Customer Code'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColAccountName, 'Customer'));
  SetColumnTitle('employee_name', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColEmployeeName, 'Sales Representative'));
  SetColumnTitle('line_count', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColLineCount, 'Lines'));
  if Assigned(FmniLines) then
    FmniLines.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuLines, 'Lines');
  if Assigned(FmniSend) then
    FmniSend.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuSend, 'Mark as Sent');
  if Assigned(FmniToDraft) then
    FmniToDraft.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuToDraft, 'Back to Draft');
  if Assigned(FmniReject) then
    FmniReject.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuReject, 'Rejected by Customer');
  if Assigned(FmniClose) then
    FmniClose.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuClose, 'Close');
  if Assigned(FmniToOrder) then
    FmniToOrder.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuToOrder, 'Convert to Order');
end;

end.
