unit ufrmPurQuotationComparisons;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.Grids, Vcl.DBGrids, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PurQuotationComparison.Service, PurQuotationComparison;

type
  // Teklif karşılaştırma (salt okunur): talep kalemi başına tedarikçi teklifleri, ana para biriminde net birim fiyat ve
  // fiyat sırası; en uygun fiyat (sıra 1) yeşil / kalın. Popup: teklifi aç, bu teklifi seç ve onaya gönder.
  TfrmPurQuotationComparisons = class(TfrmGrid<TPurQuotationComparison, TPurQuotationComparisonService>)
  private
    FFixedRequestName: string;
    FmniOpenQuotation, FmniSubmit: TMenuItem;
    procedure mniOpenQuotationClick(Sender: TObject);
    procedure mniSubmitClick(Sender: TObject);
    procedure StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure grdDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState); override;
    procedure SetFixedRequest(ARequestId: Int64; const ARequestName: string);
    procedure PreparePopupMenu; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  PurLookup, Grid.Types,
  PurQuotation, PurQuotation.Service, ufrmPurQuotationDetail;

procedure TfrmPurQuotationComparisons.StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TPurLookup.Text(plkQuotationStatus, Sender.AsInteger);
end;

procedure TfrmPurQuotationComparisons.SetFixedRequest(ARequestId: Int64; const ARequestName: string);
begin
  FFixedRequestName := ARequestName;
  AddFixedFilter('pur_request_id', ARequestId);
end;

// en uygun fiyat (talep kalemi içinde sıra 1) yeşil / kalın
procedure TfrmPurQuotationComparisons.grdDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer;
  Column: TColumn; State: TGridDrawState);
var
  LField: TField;
begin
  LField := Grd.DataSource.DataSet.FindField('price_rank');
  if Assigned(LField) and not LField.IsNull and (LField.AsInteger = 1) then
  begin
    THackDBGrid(Sender).Canvas.Font.Color := clGreen;
    THackDBGrid(Sender).Canvas.Font.Style := [fsBold];
  end;
  inherited;
end;

procedure TfrmPurQuotationComparisons.mniOpenQuotationClick(Sender: TObject);
var
  LSvc: TPurQuotationService;
  LQuotation: TPurQuotation;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LSvc := TPurQuotationService.Create;
  try
    LQuotation := LSvc.BusinessFindById(Table.PurQuotationId, False, False, True);
  except
    LSvc.Free;
    raise;
  end;
  if not Assigned(LQuotation) then
  begin
    LSvc.Free;
    Exit;
  end;
  TfrmPurQuotationDetail.Create(Self, LSvc, LQuotation, ifmRewiev, nil, ivmNormal, True).Show;
end;

// Seçilen teklif onaya gönderilir (talep başına tek seçili teklif; servis kontrol eder)
procedure TfrmPurQuotationComparisons.mniSubmitClick(Sender: TObject);
var
  LSvc: TPurQuotationService;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LSvc := TPurQuotationService.Create;
  try
    LSvc.ChangeStatus(Table.PurQuotationId, PUR_QUO_PENDING, True);
  finally
    LSvc.Free;
  end;
  RefreshParentGrid(True);
end;

procedure TfrmPurQuotationComparisons.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniOpenQuotation := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurQuotationComparison.MenuOpenQuotation, 'Open Quotation'),
    'mniOpenQuotation', mniOpenQuotationClick);
  FmniSubmit := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurQuotation.MenuSubmit, 'Select && Send for Approval'),
    'mniSubmit', mniSubmitClick);
end;

function TfrmPurQuotationComparisons.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  // Salt okunur liste: giriş formu yok (teklif popup ile açılır)
  Result := nil;
end;

procedure TfrmPurQuotationComparisons.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('pur_request_id', 0);
  SetColumnProperty('pur_request_detail_id', 0);
  SetColumnProperty('stk_inventory_id', 0);
  SetColumnProperty('pur_quotation_id', 0);
  SetColumnProperty('acc_account_id', 0);
  LField := Grd.DataSource.DataSet.FindField('status');
  if Assigned(LField) then
    LField.OnGetText := StatusGetText;
end;

procedure TfrmPurQuotationComparisons.FormShow(Sender: TObject);
begin
  inherited;
  if Assigned(BtnAdd) then
    BtnAdd.Visible := False;
  if Assigned(mniDuplicate) then
    mniDuplicate.Visible := False;
  ApplyLocalization;
end;

procedure TfrmPurQuotationComparisons.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotationComparison.TitlePlural, 'Quotation Comparison');
  if FFixedRequestName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedRequestName;
  SetColumnTitle('request_no', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColRequestNo, 'Request No'));
  SetColumnTitle('request_line_no', TLocalizationManager.Translate(TLangKeys.TPurQuotationComparison.ColRequestLineNo, 'Request Line'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColInventoryCode, 'Stock Code'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColInventoryName, 'Stock Name'));
  SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColUomCode, 'Unit'));
  SetColumnTitle('request_quantity', TLocalizationManager.Translate(TLangKeys.TPurQuotationComparison.ColRequestQuantity, 'Requested Qty'));
  SetColumnTitle('quotation_no', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColQuotationNo, 'Quotation No'));
  SetColumnTitle('quotation_date', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColQuotationDate, 'Quotation Date'));
  SetColumnTitle('status', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColStatus, 'Status'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColAccountCode, 'Supplier Code'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColAccountName, 'Supplier'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColCurrency, 'Currency'));
  SetColumnTitle('exchange_rate', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColExchangeRate, 'Exchange Rate'));
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColQuantity, 'Quantity'));
  SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColUnitPrice, 'Unit Price'));
  SetColumnTitle('discount_rate', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColDiscountRate, 'Discount (%)'));
  SetColumnTitle('vat_rate', TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.ColVatRate, 'VAT (%)'));
  SetColumnTitle('net_unit_price', TLocalizationManager.Translate(TLangKeys.TPurQuotationComparison.ColNetUnitPrice, 'Net Unit Price'));
  SetColumnTitle('net_unit_price_base', TLocalizationManager.Translate(TLangKeys.TPurQuotationComparison.ColNetUnitPriceBase, 'Net Unit Price (Base Currency)'));
  SetColumnTitle('net_amount_base', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColNetAmountBase, 'Net Amount (Base Currency)'));
  SetColumnTitle('delivery_days', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColDeliveryDays, 'Delivery Time (Days)'));
  SetColumnTitle('delivery_date', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColDeliveryDate, 'Delivery Date'));
  SetColumnTitle('payment_term_days', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColPaymentTermDays, 'Payment Term (Days)'));
  SetColumnTitle('payment_terms', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColPaymentTerms, 'Payment Terms'));
  SetColumnTitle('valid_until', TLocalizationManager.Translate(TLangKeys.TPurQuotation.ColValidUntil, 'Valid Until'));
  SetColumnTitle('price_rank', TLocalizationManager.Translate(TLangKeys.TPurQuotationComparison.ColPriceRank, 'Price Rank'));
  if Assigned(FmniOpenQuotation) then
    FmniOpenQuotation.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotationComparison.MenuOpenQuotation, 'Open Quotation');
  if Assigned(FmniSubmit) then
    FmniSubmit.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.MenuSubmit, 'Select && Send for Approval');
end;

end.
