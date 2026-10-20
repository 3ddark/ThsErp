unit ufrmSlsOfferDetail;

// Satış teklifi: başlık (sls_offer) + kalemler (Table.Lines, sls_offer_detail) tek ekranda. Kalemler bellekte teklif
// servisiyle eklenir / değişir / çıkar (satır formu TfrmSlsOfferLine); Onayla Service.BusinessSaveWithDetails ile
// başlık ve kalemleri tek transaction'da yazar.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.Generics.Collections,
  ufrmInputDetailedDB, Detail.Lines, Detail.Totals, Detail.Address, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SlsOffer.Service, SlsOffer, SlsOfferDetail.Service, SlsOfferDetail;

type
  TfrmSlsOfferDetail = class(TfrmInputDetailedDB<TSlsOffer, TSlsOfferService>)
    pnlContent: TPanel;
    pgcHeader: TPageControl;
    tsGeneral: TTabSheet;
    tsBillingAddress: TTabSheet;
    tsShippingAddress: TTabSheet;
    lblOfferNo: TLabel;
    edtOfferNo: TEdit;
    lblOfferDate: TLabel;
    edtOfferDate: TEdit;
    lblValidUntil: TLabel;
    edtValidUntil: TEdit;
    lblDeliveryDate: TLabel;
    edtDeliveryDate: TEdit;
    lblAccAccountId: TLabel;
    edtAccountCode: TEdit;
    edtAccAccountId: TEdit;
    lblTaxOffice: TLabel;
    edtTaxOffice: TEdit;
    edtTaxNo: TEdit;
    lblCustomerRefNo: TLabel;
    edtCustomerRefNo: TEdit;
    lblEmpEmployeeId: TLabel;
    edtEmpEmployeeId: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
    lblExchangeRate: TLabel;
    edtExchangeRate: TEdit;
    lblEinvPaymentMeansId: TLabel;
    edtEinvPaymentMeansId: TEdit;
    lblPaymentTermDays: TLabel;
    edtPaymentTermDays: TEdit;
    lblEinvDeliveryTermId: TLabel;
    edtEinvDeliveryTermId: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    lblUsdRate: TLabel;
    edtUsdRate: TEdit;
    lblEurRate: TLabel;
    edtEurRate: TEdit;
    lblSaleType: TLabel;
    cbbSaleType: TComboBox;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    // kalem grid'inin altında, sağda
    FPnlLinesFooter: TPanel;
    FPnlTotals: TPanel;
    FTotals: TTotalsPanel;
    FPageLines: TTabSheet;
    FLines: TDetailSet<TSlsOfferDetail>;
    FBillingEditor: TDocumentAddressEditor;
    FShippingEditor: TDocumentAddressEditor;
    // ana para (muhasebe para birimi): kayıtlı teklifte teklifinki
    FBaseCurrency: string;
    FRateDateText: string;
    procedure ShowTotals;
    // Table toplamları panelde (para birimiyle)
    procedure ShowTotalValues;
    procedure ShowAddresses;
    procedure ShowAccount;
    procedure AddressFromAccount(Sender: TObject);
    procedure AddressClear(Sender: TObject);
    // Teklif tarihinin kurları (belge parası; AAll: USD / EUR da); kullanıcı sonra değiştirebilir
    procedure UpdateRates(AAll: Boolean);
    procedure OfferDateExit(Sender: TObject);
    procedure ApplyRateCaptions;
    procedure SaleTypeChange(Sender: TObject);
    // ihracatta "Teslim Şartı (Incoterms)", diğerlerinde "Gönderim Şekli"
    procedure ApplyDeliveryTermCaption;
  protected
    procedure DetailsChanged; override;
    function HeaderSummary: string; override;
  public
    destructor Destroy; override;
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SysDecimalPlace.Cache, SysCurrency.Cache,
  SlsLookup, Grid.Types, ufrmSlsOfferLine,
  AccAccount, AccAccount.Service, ufrmAccAccounts,        // TfrmAccAccounts helper output form
  EmpEmployee, EmpEmployee.Service, ufrmEmpEmployees,     // TfrmEmpEmployees helper output form
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies,    // TfrmSysCurrencies helper output form
  AccAccountAddress, AccAccountAddress.Service, ufrmAccAccountAddresses,  // TfrmAccAccountAddresses helper output form
  EInvPaymentMeans, EInvPaymentMeans.Service, ufrmEInvPaymentMeansList,   // TfrmEInvPaymentMeansList helper output form
  EInvDeliveryTerm, EInvDeliveryTerm.Service, ufrmEInvDeliveryTerms;      // TfrmEInvDeliveryTerms helper output form

function RateText(AValue: Currency): string;
begin
  if AValue > 0 then
    Result := CurrToStr(AValue)
  else
    Result := '';
end;

procedure TfrmSlsOfferDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.OfferNo := edtOfferNo.Text;
  Table.OfferDate := StrToDateDef(edtOfferDate.Text, 0);
  Table.ValidUntil := StrToDateDef(edtValidUntil.Text, 0);
  Table.DeliveryDate := StrToDateDef(edtDeliveryDate.Text, 0);
  Table.CustomerRefNo := edtCustomerRefNo.Text;
  Table.ExchangeRate := StrToCurrDef(edtExchangeRate.Text, 0);
  Table.PaymentTermDays := StrToIntDef(edtPaymentTermDays.Text, 0);
  Table.SaleType := cbbSaleType.ItemIndex + 1;
  Table.Description := edtDescription.Text;
  Table.UsdRate := StrToCurrDef(edtUsdRate.Text, 0);
  Table.EurRate := StrToCurrDef(edtEurRate.Text, 0);
  FBillingEditor.SaveTo(Table.BillingAddress);
  FShippingEditor.SaveTo(Table.ShippingAddress);
  inherited;
end;

procedure TfrmSlsOfferDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  TSlsLookup.FillItems(cbbSaleType.Items, slkSaleType);
  cbbSaleType.OnChange := SaleTypeChange;
  edtOfferNo.thsInputDataType := itString;
  edtOfferNo.CharCase := TEditCharCase.ecUpperCase;
  edtOfferDate.thsInputDataType := itDate;
  edtValidUntil.thsInputDataType := itDate;
  edtDeliveryDate.thsInputDataType := itDate;
  edtEinvPaymentMeansId.OnHelperProcess := HelperProcess;
  edtEinvDeliveryTermId.OnHelperProcess := HelperProcess;
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtCustomerRefNo.thsInputDataType := itString;
  edtEmpEmployeeId.OnHelperProcess := HelperProcess;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtExchangeRate.thsInputDataType := itFloat;
  edtPaymentTermDays.thsInputDataType := itInteger;
  edtDescription.thsInputDataType := itString;
  edtUsdRate.thsInputDataType := itFloat;
  edtEurRate.thsInputDataType := itFloat;
  // haneler sys_decimal_place'ten
  edtExchangeRate.thsDecimalDigitCount := TDecimalPlaces.ExchangeRate;
  edtUsdRate.thsDecimalDigitCount := TDecimalPlaces.ExchangeRate;
  edtEurRate.thsDecimalDigitCount := TDecimalPlaces.ExchangeRate;
  edtOfferDate.OnExit := OfferDateExit;
  pgcHeader.ActivePage := tsGeneral;
  FBaseCurrency := Service.GetBaseCurrency;

  // Kalemler = Table.Lines (servis satır no sırasıyla okur); ekle / çıkar / hesap teklif servisinde,
  // satır formu modal, kayıt teklifle birlikte
  FPageLines := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuLines, 'Lines'));
  FLines := AddDetail<TSlsOfferDetail>(FPageLines, 'vw_sls_offer_detail',
    function: TObjectList<TSlsOfferDetail>
    begin
      Result := Table.Lines;
    end,
    function: TSlsOfferDetail
    begin
      Result := Service.CreateLine(Table);
    end,
    procedure(ALine: TSlsOfferDetail)
    begin
      Service.AddLine(Table, ALine);
    end,
    procedure(ALine: TSlsOfferDetail)
    begin
      Service.RemoveLine(Table, ALine);
    end,
    function(ALine: TSlsOfferDetail; AMode: TInputFormMode): TForm
    begin
      Result := TfrmSlsOfferLine.Create(Self, TSlsOfferDetailService.Create, ALine, AMode, nil);
    end);

  FLines.Grid.BuildData;
  FLines.Grid.SetColumnProperty('id', 0);
  FLines.Grid.SetColumnProperty('sls_offer_id', 0);
  FLines.Grid.SetColumnProperty('stk_inventory_id', 0);
  FLines.Grid.SetColumnProperty('offer_no', 0);
  FLines.Grid.SetColumnProperty('currency', 0);
  FLines.Grid.SetColumnProperty('gross_amount', 0);
  FLines.Grid.SetColumnProperty('discount_amount', 0);
  FLines.Grid.SetColumnProperty('line_no', 50);
  FLines.Grid.SetColumnProperty('inventory_code', 90);
  FLines.Grid.SetColumnProperty('inventory_name', 200);
  FLines.Grid.SetColumnProperty('uom_code', 50);
  FLines.Grid.SetColumnProperty('description', 160);

  // Toplamlar kalem grid'inin altında, sağda (tema renkleri)
  FPnlLinesFooter := TPanel.Create(Self);
  FPnlLinesFooter.Parent := FPageLines;
  FPnlLinesFooter.Align := alBottom;
  FPnlLinesFooter.BevelOuter := bvNone;
  FPnlLinesFooter.Caption := '';
  FPnlTotals := TPanel.Create(Self);
  FPnlTotals.Parent := FPnlLinesFooter;
  FPnlTotals.Align := alRight;
  FPnlTotals.AlignWithMargins := True;
  FPnlTotals.Width := 340;
  FTotals := TTotalsPanel.Create(FPnlTotals);
  FTotals.AddRow('gross');
  FTotals.AddRow('discount');
  FTotals.AddRow('net');
  FTotals.AddRow('vat');
  FTotals.AddRow('total', True);
  FPnlLinesFooter.Height := FTotals.RequiredHeight + FPnlTotals.Margins.Top + FPnlTotals.Margins.Bottom;

  // Adresler (başlık sekmeleri): belgeye ait ayrıntılı kopya (cari adresinden alınır, burada düzenlenir; teklifle
  // birlikte yazılır)
  FBillingEditor := TDocumentAddressEditor.Create(Self, tsBillingAddress);
  FShippingEditor := TDocumentAddressEditor.Create(Self, tsShippingAddress);
  FBillingEditor.OnFromAccount := AddressFromAccount;
  FBillingEditor.OnClear := AddressClear;
  FShippingEditor.OnFromAccount := AddressFromAccount;
  FShippingEditor.OnClear := AddressClear;
end;

procedure TfrmSlsOfferDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtOfferDate.CanFocus then
    edtOfferDate.SetFocus;
end;

// Başlık toplamları: servis kalemlerden hesaplar (kayıtta yine aynı hesap)
destructor TfrmSlsOfferDetail.Destroy;
begin
  FreeAndNil(FShippingEditor);
  FreeAndNil(FBillingEditor);
  FreeAndNil(FTotals);
  inherited;
end;

procedure TfrmSlsOfferDetail.ShowAddresses;
begin
  if not Assigned(FBillingEditor) or not Assigned(Table) then
    Exit;
  FBillingEditor.LoadFrom(Table.BillingAddress);
  FShippingEditor.LoadFrom(Table.ShippingAddress);
end;

// Seçilen cari adresi bu adrese kopyalanır (diğer adresin ekrandaki değişiklikleri korunur)
procedure TfrmSlsOfferDetail.AddressFromAccount(Sender: TObject);
var
  LFrm: TfrmAccAccountAddresses;
  LShipping: Boolean;
begin
  if Table.AccAccountId <= 0 then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColAccAccountId, 'Customer') + ': ' +
      TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  LShipping := Sender = FShippingEditor;
  LFrm := TfrmAccAccountAddresses.Create(Self, TAccAccountAddressService.Create, TAccAccountAddress.Create);
  try
    LFrm.SetFixedAccount(Table.AccAccountId, Table.AccountName);
    LFrm.IsHelper := True;
    LFrm.ShowModal;
    if LFrm.DataTransfer and not LFrm.CleanAndClose then
    begin
      Service.ApplyAccountAddress(Table, LShipping, LFrm.Table.Id);
      if LShipping then
        FShippingEditor.LoadFrom(Table.ShippingAddress)
      else
        FBillingEditor.LoadFrom(Table.BillingAddress);
    end;
  finally
    LFrm.Free;
  end;
end;

procedure TfrmSlsOfferDetail.AddressClear(Sender: TObject);
begin
  if Sender = FShippingEditor then
  begin
    Service.ApplyAccountAddress(Table, True, 0);
    FShippingEditor.LoadFrom(Table.ShippingAddress);
  end
  else
  begin
    Service.ApplyAccountAddress(Table, False, 0);
    FBillingEditor.LoadFrom(Table.BillingAddress);
  end;
end;

procedure TfrmSlsOfferDetail.UpdateRates(AAll: Boolean);
var
  LDate: TDate;
begin
  LDate := StrToDateDef(edtOfferDate.Text, Date);
  FRateDateText := edtOfferDate.Text;
  if (Table.Currency = '') or SameText(Table.Currency, FBaseCurrency) then
    edtExchangeRate.Text := '1'
  else
    edtExchangeRate.Text := RateText(Service.GetExchangeRate(Table.Currency, LDate));
  if AAll then
  begin
    edtUsdRate.Text := RateText(Service.GetExchangeRate('USD', LDate));
    edtEurRate.Text := RateText(Service.GetExchangeRate('EUR', LDate));
  end;
end;

// tarih değişince o günün kurları (hafta sonu / tatil: önceki iş günü)
procedure TfrmSlsOfferDetail.OfferDateExit(Sender: TObject);
begin
  if DetailsEditable and (edtOfferDate.Text <> FRateDateText) then
    UpdateRates(True);
end;

procedure TfrmSlsOfferDetail.ApplyRateCaptions;
var
  LSuffix: string;
begin
  LSuffix := '';
  if FBaseCurrency <> '' then
    LSuffix := ' (' + FBaseCurrency + ')';
  lblExchangeRate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColExchangeRate, 'Exchange Rate') + LSuffix;
  lblUsdRate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColUsdRate, 'USD Rate') + LSuffix;
  lblEurRate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColEurRate, 'EUR Rate') + LSuffix;
end;

procedure TfrmSlsOfferDetail.ShowTotalValues;
begin
  if not Assigned(FTotals) or not Assigned(Table) then
    Exit;
  FTotals.SetValue('gross', Table.GrossAmount, Table.Currency);
  FTotals.SetValue('discount', Table.DiscountAmount, Table.Currency);
  FTotals.SetValue('net', Table.NetAmount, Table.Currency);
  FTotals.SetValue('vat', Table.VatAmount, Table.Currency);
  FTotals.SetValue('total', Table.TotalAmount, Table.Currency);
  UpdateHeaderBar;
end;

procedure TfrmSlsOfferDetail.ShowTotals;
begin
  if not Assigned(Table) then
    Exit;
  Service.Recalculate(Table);
  ShowTotalValues;
end;

procedure TfrmSlsOfferDetail.DetailsChanged;
begin
  inherited;
  ShowTotals;
  // adresler kalemlerle aynı durumda düzenlenebilir (yeni / kopya / güncelleme)
  if Assigned(FBillingEditor) then
  begin
    FBillingEditor.SetEditable(DetailsEditable);
    FShippingEditor.SetEditable(DetailsEditable);
  end;
end;

procedure TfrmSlsOfferDetail.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.TitleSingular, 'Sales Offer');
  lblOfferNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColOfferNo, 'Offer No');
  lblOfferDate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColOfferDate, 'Offer Date');
  lblValidUntil.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColValidUntil, 'Valid Until');
  lblDeliveryDate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColDeliveryDate, 'Delivery Date');
  lblTaxOffice.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColTaxOfficeNo, 'Tax Office / No');
  lblEinvPaymentMeansId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColEinvPaymentMeansId, 'Payment Method');
  ApplyDeliveryTermCaption;
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColAccAccountId, 'Customer');
  lblCustomerRefNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColCustomerRefNo, 'Customer Ref. No');
  lblEmpEmployeeId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColEmpEmployeeId, 'Sales Representative');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColCurrency, 'Currency');
  lblPaymentTermDays.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColPaymentTermDays, 'Payment Term (Days)');
  lblSaleType.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColSaleType, 'Sale Type');
  LIndex := cbbSaleType.ItemIndex;
  TSlsLookup.FillItems(cbbSaleType.Items, slkSaleType);
  cbbSaleType.ItemIndex := LIndex;
  if Assigned(FTotals) then
  begin
    FTotals.SetCaption('gross', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColGrossAmount, 'Gross Amount'));
    FTotals.SetCaption('discount', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColDiscountAmount, 'Discount Amount'));
    FTotals.SetCaption('net', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColNetAmount, 'Net Amount'));
    FTotals.SetCaption('vat', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColVatAmount, 'VAT Amount'));
    FTotals.SetCaption('total', TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColTotalAmount, 'Total'));
  end;
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColDescription, 'Description');
  ApplyRateCaptions;
  tsGeneral.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.TabGeneral, 'General');
  tsBillingAddress.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColBillingAddress, 'Billing Address');
  tsShippingAddress.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColShippingAddress, 'Shipping Address');
  if Assigned(FBillingEditor) then
  begin
    FBillingEditor.ApplyLocalization(TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColBillingAddress, 'Billing Address'));
    FShippingEditor.ApplyLocalization(TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColShippingAddress, 'Shipping Address'));
  end;

  if Assigned(FPageLines) then
    FPageLines.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.MenuLines, 'Lines');
  if Assigned(FLines) then
  begin
    FLines.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColLineNo, 'Line No'));
    FLines.Grid.SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColInventoryCode, 'Stock Code'));
    FLines.Grid.SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColInventoryName, 'Stock Name'));
    FLines.Grid.SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColUomCode, 'Unit'));
    FLines.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColQuantity, 'Quantity'));
    FLines.Grid.SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColUnitPrice, 'Unit Price'));
    FLines.Grid.SetColumnTitle('discount_rate', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColDiscountRate, 'Discount (%)'));
    FLines.Grid.SetColumnTitle('vat_rate', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColVatRate, 'VAT (%)'));
    FLines.Grid.SetColumnTitle('gross_amount', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColGrossAmount, 'Gross Amount'));
    FLines.Grid.SetColumnTitle('discount_amount', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColDiscountAmount, 'Discount Amount'));
    FLines.Grid.SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColNetAmount, 'Net Amount'));
    FLines.Grid.SetColumnTitle('vat_amount', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColVatAmount, 'VAT Amount'));
    FLines.Grid.SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColTotalAmount, 'Total'));
    FLines.Grid.SetColumnTitle('ordered_quantity', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColOrderedQuantity, 'Ordered Quantity'));
    FLines.Grid.SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColDescription, 'Description'));
  end;
end;

procedure TfrmSlsOfferDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccAccountId: TfrmAccAccounts;
  LFrmEmpEmployeeId: TfrmEmpEmployees;
  LFrmCurrency: TfrmSysCurrencies;
  LNewCurrency: string;
  LFrmPayment: TfrmEInvPaymentMeansList;
  LFrmDelivery: TfrmEInvDeliveryTerms;
  LOldAccountId: Int64;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtAccAccountId.Name then
  begin
    LOldAccountId := Table.AccAccountId;
    LFrmAccAccountId := TfrmAccAccounts.Create(LEdit, TAccAccountService.Create, TAccAccount.Create);
    try
      LFrmAccAccountId.IsHelper := True;
      LFrmAccAccountId.ShowModal;
      if LFrmAccAccountId.DataTransfer then
        if LFrmAccAccountId.CleanAndClose then
        begin
          Table.AccAccountId := 0;
          Table.AccountCode := '';
          Table.AccountName := '';
          Table.TaxOffice := '';
          Table.TaxNo := '';
        end
        else
        begin
          Table.AccAccountId := LFrmAccAccountId.Table.Id;
          Table.AccountCode := LFrmAccAccountId.Table.Code;
          Table.AccountName := LFrmAccAccountId.Table.Name;
          Table.TaxOffice := LFrmAccAccountId.Table.TaxOffice;
          Table.TaxNo := LFrmAccAccountId.Table.TaxNo;
        end;
      ShowAccount;
      // adresler müşteriye ait: müşteri değişince önerilen adresler
      if Table.AccAccountId <> LOldAccountId then
      begin
        Service.ApplyDefaultAddresses(Table);
        ShowAddresses;
      end;
    finally
      LFrmAccAccountId.Free;
    end;
  end
  else if LEdit.Name = edtEmpEmployeeId.Name then
  begin
    LFrmEmpEmployeeId := TfrmEmpEmployees.Create(LEdit, TEmpEmployeeService.Create, TEmpEmployee.Create);
    try
      LFrmEmpEmployeeId.IsHelper := True;
      LFrmEmpEmployeeId.ShowModal;
      if LFrmEmpEmployeeId.DataTransfer then
        if LFrmEmpEmployeeId.CleanAndClose then
        begin
          Table.EmpEmployeeId := 0;
          Table.EmployeeName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.EmpEmployeeId := LFrmEmpEmployeeId.Table.Id;
          Table.EmployeeName := LFrmEmpEmployeeId.Table.FullName;
          LEdit.Text := Table.EmployeeName;
        end;
    finally
      LFrmEmpEmployeeId.Free;
    end;
  end
  else if LEdit.Name = edtCurrency.Name then
  begin
    LFrmCurrency := TfrmSysCurrencies.Create(LEdit, TSysCurrencyService.Create, TSysCurrency.Create);
    try
      LFrmCurrency.IsHelper := True;
      LFrmCurrency.ShowModal;
      if LFrmCurrency.DataTransfer then
      begin
        // temizle = ana para
        if LFrmCurrency.CleanAndClose then
          LNewCurrency := FBaseCurrency
        else
          LNewCurrency := LFrmCurrency.Table.Currency;
        if not SameText(LNewCurrency, Table.Currency) then
        begin
          // kalem fiyatları ekrandaki kurdan teklif tarihinin yeni kuruna çevrilir (servis); kur yoksa değişmez
          Table.OfferDate := StrToDateDef(edtOfferDate.Text, Date);
          Service.ChangeCurrency(Table, LNewCurrency, StrToCurrDef(edtExchangeRate.Text, Table.ExchangeRate));
          LEdit.Text := Table.Currency;
          edtExchangeRate.Text := RateText(Table.ExchangeRate);
          RefreshDetails;
        end;
      end;
    finally
      LFrmCurrency.Free;
    end;
  end
  else if LEdit.Name = edtEinvPaymentMeansId.Name then
  begin
    LFrmPayment := TfrmEInvPaymentMeansList.Create(LEdit, TEInvPaymentMeansService.Create, TEInvPaymentMeans.Create);
    try
      LFrmPayment.IsHelper := True;
      LFrmPayment.SetActiveOnly;
      LFrmPayment.ShowModal;
      if LFrmPayment.DataTransfer then
        if LFrmPayment.CleanAndClose then
        begin
          Table.EinvPaymentMeansId := 0;
          Table.PaymentMeansName := '';
        end
        else
        begin
          Table.EinvPaymentMeansId := LFrmPayment.Table.Id;
          Table.PaymentMeansName := LFrmPayment.Table.Name;
        end;
      LEdit.Text := Table.PaymentMeansName;
    finally
      LFrmPayment.Free;
    end;
  end
  else if LEdit.Name = edtEinvDeliveryTermId.Name then
  begin
    LFrmDelivery := TfrmEInvDeliveryTerms.Create(LEdit, TEInvDeliveryTermService.Create, TEInvDeliveryTerm.Create);
    try
      LFrmDelivery.IsHelper := True;
      LFrmDelivery.SetActiveOnly;
      LFrmDelivery.SetIncotermsOnly(Table.SaleType = SLS_SALE_EXPORT);
      LFrmDelivery.ShowModal;
      if LFrmDelivery.DataTransfer then
        if LFrmDelivery.CleanAndClose then
        begin
          Table.EinvDeliveryTermId := 0;
          Table.DeliveryTermName := '';
          Table.DeliveryTermIsIncoterms := False;
        end
        else
        begin
          Table.EinvDeliveryTermId := LFrmDelivery.Table.Id;
          Table.DeliveryTermName := LFrmDelivery.Table.Name;
          Table.DeliveryTermIsIncoterms := LFrmDelivery.Table.IsIncoterms;
        end;
      LEdit.Text := Table.DeliveryTermName;
    finally
      LFrmDelivery.Free;
    end;
  end;
end;

// Satış tipi değişince uymayan teslim şartı temizlenir (ihracat: Incoterms, diğerleri: yurt içi teslim şekli)
procedure TfrmSlsOfferDetail.SaleTypeChange(Sender: TObject);
begin
  Table.SaleType := cbbSaleType.ItemIndex + 1;
  if (Table.EinvDeliveryTermId > 0) and (Table.DeliveryTermIsIncoterms <> (Table.SaleType = SLS_SALE_EXPORT)) then
  begin
    Table.EinvDeliveryTermId := 0;
    Table.DeliveryTermName := '';
    Table.DeliveryTermIsIncoterms := False;
    edtEinvDeliveryTermId.Text := '';
  end;
  ApplyDeliveryTermCaption;
end;

procedure TfrmSlsOfferDetail.ApplyDeliveryTermCaption;
begin
  if cbbSaleType.ItemIndex + 1 = SLS_SALE_EXPORT then
    lblEinvDeliveryTermId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColDeliveryTermIncoterms, 'Delivery Term (Incoterms)')
  else
    lblEinvDeliveryTermId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColEinvDeliveryTermId, 'Shipping Method');
end;

// Başlık daraltılmışken: teklif no, tarih, müşteri, genel toplam
function TfrmSlsOfferDetail.HeaderSummary: string;
begin
  Result := '';
  if not Assigned(Table) then
    Exit;
  Result := Trim(edtOfferNo.Text);
  if edtOfferDate.Text <> '' then
    Result := Result + '   ' + edtOfferDate.Text;
  if Table.AccountName <> '' then
    Result := Result + '   ' + Table.AccountName;
  Result := Result + '   ' + TLocalizationManager.Translate(TLangKeys.TSlsOffer.ColTotalAmount, 'Total') + ': ' +
    TCurrencySymbols.FormatAmount(Table.TotalAmount, Table.Currency, TDecimalPlaces.TotalFormat);
end;

// Müşteri: kod, ad ve cari kartındaki vergi dairesi / no (salt okunur)
procedure TfrmSlsOfferDetail.ShowAccount;
begin
  edtAccountCode.Text := Table.AccountCode;
  edtAccAccountId.Text := Table.AccountName;
  edtTaxOffice.Text := Table.TaxOffice;
  edtTaxNo.Text := Table.TaxNo;
end;

procedure TfrmSlsOfferDetail.RefreshData;
begin
  inherited;
  edtOfferNo.Text := Table.OfferNo;
  if Table.OfferDate > 0 then
    edtOfferDate.Text := DateToStr(Table.OfferDate)
  else
    edtOfferDate.Text := '';
  if Table.ValidUntil > 0 then
    edtValidUntil.Text := DateToStr(Table.ValidUntil)
  else
    edtValidUntil.Text := '';
  if Table.DeliveryDate > 0 then
    edtDeliveryDate.Text := DateToStr(Table.DeliveryDate)
  else
    edtDeliveryDate.Text := '';
  ShowAccount;
  edtCustomerRefNo.Text := Table.CustomerRefNo;
  edtEinvPaymentMeansId.Text := Table.PaymentMeansName;
  edtEinvDeliveryTermId.Text := Table.DeliveryTermName;
  edtEmpEmployeeId.Text := Table.EmployeeName;
  edtCurrency.Text := Table.Currency;
  edtExchangeRate.Text := CurrToStr(Table.ExchangeRate);
  edtPaymentTermDays.Text := IntToStr(Table.PaymentTermDays);
  if TSlsLookup.IsValid(slkSaleType, Table.SaleType) then
    cbbSaleType.ItemIndex := Table.SaleType - 1
  else
    cbbSaleType.ItemIndex := SLS_SALE_DOMESTIC - 1;
  ApplyDeliveryTermCaption;
  ShowTotalValues;
  edtDescription.Text := Table.Description;
  if Table.BaseCurrency <> '' then
    FBaseCurrency := Table.BaseCurrency;
  ApplyRateCaptions;
  edtExchangeRate.Text := RateText(Table.ExchangeRate);
  edtUsdRate.Text := RateText(Table.UsdRate);
  edtEurRate.Text := RateText(Table.EurRate);
  FRateDateText := edtOfferDate.Text;
  // yeni teklif: ana para ve teklif tarihinin kurları
  if (Table.Id <= 0) and (FormMode = ifmNewRecord) then
  begin
    if Table.Currency = '' then
    begin
      Table.Currency := FBaseCurrency;
      edtCurrency.Text := Table.Currency;
    end;
    UpdateRates(True);
  end;
  ShowAddresses;
  // bellekte kalem varsa toplamlar onlardan
  if Table.Lines.Count > 0 then
    ShowTotals
  else
    ShowTotalValues;
end;

end.
