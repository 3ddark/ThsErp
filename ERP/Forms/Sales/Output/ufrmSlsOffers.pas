unit ufrmSlsOffers;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SlsOffer.Service, SlsOffer, ufrmSlsOfferDetail;

type
  TfrmSlsOffers = class(TfrmGrid<TSlsOffer, TSlsOfferService>)
  private
    FmniSend, FmniToDraft, FmniReject, FmniClose, FmniToOrder: TMenuItem;
    procedure mniSendClick(Sender: TObject);
    procedure mniToDraftClick(Sender: TObject);
    procedure mniRejectClick(Sender: TObject);
    procedure mniCloseClick(Sender: TObject);
    procedure mniToOrderClick(Sender: TObject);
    procedure SetStatus(AStatus: SmallInt);
    procedure StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure SaleTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  private
    FLblSummary: TLabel;
  protected
    // Filtreye uyan tüm tekliflerin para birimi bazında net / KDV / genel toplamı (+ birden çok parada ana para toplamı)
    procedure FilteredDataLoaded; override;
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
  System.Math, FireDAC.Comp.Client, Logger, SysDecimalPlace.Cache, SysCurrency.Cache,
  SlsLookup,
  ufrmSlsOrderDetail, SlsOrder, SlsOrder.Service;

procedure TfrmSlsOffers.StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TSlsLookup.Text(slkOfferStatus, Sender.AsInteger);
end;
procedure TfrmSlsOffers.SaleTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TSlsLookup.Text(slkSaleType, Sender.AsInteger);
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
  LFrm: TfrmSlsOrderDetail;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LOrderSvc := TSlsOrderService.Create;
  try
    LOrderId := LOrderSvc.CreateFromOffer(Table.Id, True);
  finally
    LOrderSvc.Free;
  end;
  // oluşan taslak sipariş belge ekranında (inceleme; Güncelle ile kalemler düzenlenir)
  LOrderSvc := TSlsOrderService.Create;
  LOrder := LOrderSvc.FindById(LOrderId, False, True);
  LFrm := TfrmSlsOrderDetail.Create(Self, LOrderSvc, LOrder, ifmRewiev, nil, ivmNormal, True);
  LFrm.Show;
  RefreshParentGrid(True);
end;

procedure TfrmSlsOffers.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniSend := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuSend, 'Mark as Sent'), 'mniSend', mniSendClick);
  FmniToDraft := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuToDraft, 'Back to Draft'), 'mniToDraft', mniToDraftClick);
  FmniReject := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuReject, 'Rejected by Customer'), 'mniReject', mniRejectClick);
  FmniClose := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuClose, 'Close'), 'mniClose', mniCloseClick);
  AddPopupMenuSpliter();
  FmniToOrder := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuToOrder, 'Convert to Order'), 'mniToOrder', mniToOrderClick);
end;

// Başlık + kalemler tek ekranda (TfrmSlsOfferDetail); Table = BusinessFindById ile kalemli belge, Clone derin kopya.
// Kopya modunda form Service.PrepareCopy ile yeni numara / taslak / yeni kalemler hazırlar
function TfrmSlsOffers.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) or (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSlsOfferDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSlsOfferDetail.Create(Self, Service, TSlsOffer.Create, AFormMode, Self.RefreshParentGrid);
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
  SetColumnProperty('billing_address_id', 0);
  SetColumnProperty('billing_sys_address_id', 0);
  SetColumnProperty('shipping_address_id', 0);
  SetColumnProperty('shipping_sys_address_id', 0);
  SetColumnProperty('einv_payment_means_id', 0);
  SetColumnProperty('einv_delivery_term_id', 0);
  SetColumnProperty('delivery_term_is_incoterms', 0);
  LField := Grd.DataSource.DataSet.FindField('status');
  if Assigned(LField) then
    LField.OnGetText := StatusGetText;
  LField := Grd.DataSource.DataSet.FindField('sale_type');
  if Assigned(LField) then
    LField.OnGetText := SaleTypeGetText;
end;

// Grid alt toplamı yerine (farklı para birimleri toplanmasın): filtreye uyan tüm kayıtlar, para birimi bazında
procedure TfrmSlsOffers.FilteredDataLoaded;
var
  Q: TFDQuery;
  LLines: TStringList;
  LFormat, LBase, LCurrency: string;
  LBaseTotal: Double;
begin
  inherited;
  if not Assigned(FLblSummary) then
  begin
    FLblSummary := TLabel.Create(Self);
    FLblSummary.Parent := PanelButtons;
    FLblSummary.Left := 4;
    FLblSummary.Top := BtnAdd.Top + BtnAdd.Height + 6;
    FLblSummary.Font.Style := [fsBold];
  end;
  FLblSummary.Caption := '';
  LFormat := TDecimalPlaces.TotalFormat;
  LLines := TStringList.Create;
  try
    try
      Q := OpenFilteredQuery('currency, sum(net_amount) AS net, sum(vat_amount) AS vat, sum(total_amount) AS total, ' +
        'sum(total_amount_base) AS total_base, max(base_currency) AS base_currency', 'currency', 'currency');
    except
      on E: Exception do
      begin
        // özet kolonları liste sorgusunda yoksa (kolon seçimi) özet gösterilmez
        GLogger.ErrorFmt('TfrmSlsOffers summary: %s', [E.Message]);
        Q := nil;
      end;
    end;
    if not Assigned(Q) then
      Exit;
    try
      LBaseTotal := 0;
      LBase := '';
      while not Q.Eof do
      begin
        LCurrency := Q.FieldByName('currency').AsString;
        LLines.Add(Format('%s: %s     %s: %s     %s: %s', [
          TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColNetAmount, 'Net Amount'),
          TCurrencySymbols.FormatAmount(Q.FieldByName('net').AsFloat, LCurrency, LFormat),
          TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColVatAmount, 'VAT Amount'),
          TCurrencySymbols.FormatAmount(Q.FieldByName('vat').AsFloat, LCurrency, LFormat),
          TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColTotalAmount, 'Total'),
          TCurrencySymbols.FormatAmount(Q.FieldByName('total').AsFloat, LCurrency, LFormat)]));
        LBaseTotal := LBaseTotal + Q.FieldByName('total_base').AsFloat;
        LBase := Q.FieldByName('base_currency').AsString;
        Q.Next;
      end;
      if LLines.Count > 1 then
        LLines.Add(Format('%s: %s', [TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColTotalAmountBase, 'Total (Base Currency)'),
          TCurrencySymbols.FormatAmount(LBaseTotal, LBase, LFormat)]));
    finally
      Q.Free;
    end;
    FLblSummary.Caption := TrimRight(LLines.Text);
    // satır sayısı kadar yer (Kayıt Ekle + özet)
    PanelButtons.Height := Max(70, FLblSummary.Top + FLblSummary.Height + 6);
  finally
    LLines.Free;
  end;
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
  SetColumnTitle('billing_address', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColBillingAddress, 'Billing Address'));
  SetColumnTitle('shipping_address', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColShippingAddress, 'Shipping Address'));
  SetColumnTitle('base_currency', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColBaseCurrency, 'Base Currency'));
  SetColumnTitle('usd_rate', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColUsdRate, 'USD Rate'));
  SetColumnTitle('eur_rate', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColEurRate, 'EUR Rate'));
  SetColumnTitle('total_amount_base', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColTotalAmountBase, 'Total (Base Currency)'));
  SetColumnTitle('delivery_date', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColDeliveryDate, 'Delivery Date'));
  SetColumnTitle('payment_means_name', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColEinvPaymentMeansId, 'Payment Method'));
  SetColumnTitle('delivery_term_code', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColEinvDeliveryTermId, 'Shipping Method'));
  SetColumnTitle('delivery_term_name', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColEinvDeliveryTermId, 'Shipping Method'));
  SetColumnTitle('tax_office', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColTaxOffice, 'Tax Office'));
  SetColumnTitle('tax_no', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColTaxNo, 'Tax No'));
  SetColumnTitle('sale_type', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColSaleType, 'Sale Type'));
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
