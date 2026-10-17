unit ufrmSlsInvoiceDetail;

// Satış faturası: başlık (sls_invoice) + kalemler (Table.Lines, sls_invoice_detail) tek ekranda. Kalemler bellekte fatura
// servisiyle eklenir / değişir / çıkar (satır formu TfrmSlsInvoiceLine); Onayla Service.BusinessSaveWithDetails ile
// başlık ve kalemleri (irsaliyesiz kalemlerin stok hareketleri dahil) tek transaction'da yazar.
// e-Belge / İhracat sekmesi: senaryo, fatura tipi, istisna kodu, ödeme şekli, ETTN + durum (salt okunur), teslim şartı,
// taşıma şekli, gümrük çıkış bilgileri (UBL-TR 1.2.1). Kurallar TSlsInvoiceService.CheckEInvoice'ta; yalnız faturanın
// e-belge kapsamında (GetEInvScope) anlamlı alanlar görünür, görünenler boşluksuz dizilir: kağıt faturada tip / ödeme
// şekli / ETTN / durum, ihracat dışında teslim / taşıma / gümrük çıkış bilgileri gizli ve boş; istisna kodu %0 KDV'li
// kalem ya da istisna isteyen tipte görünür.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.Generics.Collections,
  ufrmInputDetailedDB, Detail.Lines, Detail.Totals, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SlsInvoice.Service, SlsInvoice, SlsInvoice.Repository, SlsInvoiceDetail.Service, SlsInvoiceDetail;

type
  TfrmSlsInvoiceDetail = class(TfrmInputDetailedDB<TSlsInvoice, TSlsInvoiceService>)
    pnlContent: TPanel;
    pgcHeader: TPageControl;
    tsGeneral: TTabSheet;
    tsEInvoice: TTabSheet;
    lblEinvProfileId: TLabel;
    edtEinvProfileId: TEdit;
    lblEinvInvoiceTypeId: TLabel;
    edtEinvInvoiceTypeId: TEdit;
    lblEinvTaxExemptionId: TLabel;
    edtEinvTaxExemptionId: TEdit;
    lblEinvPaymentMeansId: TLabel;
    edtEinvPaymentMeansId: TEdit;
    lblEinvUuid: TLabel;
    edtEinvUuid: TEdit;
    lblEinvStatus: TLabel;
    edtEinvStatus: TEdit;
    lblEinvDeliveryTermId: TLabel;
    edtEinvDeliveryTermId: TEdit;
    lblEinvTransportModeId: TLabel;
    edtEinvTransportModeId: TEdit;
    lblCustomsDeclarationNo: TLabel;
    edtCustomsDeclarationNo: TEdit;
    lblGtbRefNo: TLabel;
    edtGtbRefNo: TEdit;
    lblActualExportDate: TLabel;
    edtActualExportDate: TEdit;
    lblInvoiceNo: TLabel;
    edtInvoiceNo: TEdit;
    lblInvoiceDate: TLabel;
    edtInvoiceDate: TEdit;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblDueDate: TLabel;
    edtDueDate: TEdit;
    lblStkWarehouseId: TLabel;
    edtStkWarehouseId: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
    lblExchangeRate: TLabel;
    edtExchangeRate: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    pnlTotals: TPanel;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FTotals: TTotalsPanel;
    FPageLines: TTabSheet;
    FLines: TDetailSet<TSlsInvoiceDetail>;
    FScope: TSlsEInvScope;
    procedure ShowTotals;
    procedure ShowTotalValues;
    procedure ShowEInvFields;
    procedure ApplyEInvScope;
    procedure ShowEInvField(ALabel: TLabel; AEdit: TEdit; AVisible, ARequired: Boolean);
    function StackRows(const ALabels: array of TLabel; const AEdits: array of TEdit; ATop: Integer): Integer;
  protected
    procedure DetailsChanged; override;
  public
    destructor Destroy; override;
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SlsLookup, Grid.Types, ufrmSlsInvoiceLine,
  AccAccount, AccAccount.Service, ufrmAccAccounts,
  StkWarehouse, StkWarehouse.Service, ufrmStkWarehouses,
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies,
  EInvLookup,
  EInvProfile, EInvProfile.Service, ufrmEInvProfiles,                       // TfrmEInvProfiles helper output form
  EInvInvoiceType, EInvInvoiceType.Service, ufrmEInvInvoiceTypes,           // TfrmEInvInvoiceTypes helper output form
  EInvTaxExemption, EInvTaxExemption.Service, ufrmEInvTaxExemptions,        // TfrmEInvTaxExemptions helper output form
  EInvPaymentMeans, EInvPaymentMeans.Service, ufrmEInvPaymentMeansList,     // TfrmEInvPaymentMeansList helper output form
  EInvDeliveryTerm, EInvDeliveryTerm.Service, ufrmEInvDeliveryTerms,        // TfrmEInvDeliveryTerms helper output form
  EInvTransportMode, EInvTransportMode.Service, ufrmEInvTransportModes;     // TfrmEInvTransportModes helper output form

procedure TfrmSlsInvoiceDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.InvoiceNo := edtInvoiceNo.Text;
  Table.InvoiceDate := StrToDateDef(edtInvoiceDate.Text, 0);
  Table.DueDate := StrToDateDef(edtDueDate.Text, 0);
  Table.ExchangeRate := StrToCurrDef(edtExchangeRate.Text, 0);
  Table.Description := edtDescription.Text;
  Table.CustomsDeclarationNo := edtCustomsDeclarationNo.Text;
  Table.GtbRefNo := edtGtbRefNo.Text;
  Table.ActualExportDate := StrToDateDef(edtActualExportDate.Text, 0);
  inherited;
end;

procedure TfrmSlsInvoiceDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  FTotals := TTotalsPanel.Create(pnlTotals);
  FTotals.AddRow('gross');
  FTotals.AddRow('discount');
  FTotals.AddRow('net');
  FTotals.AddRow('vat');
  FTotals.AddRow('total', True);
  FTotals.AddRow('withholding');
  FTotals.AddRow('payable', True);
  pnlTotals.Height := FTotals.RequiredHeight;
  pgcHeader.ActivePage := tsGeneral;

  edtInvoiceNo.thsInputDataType := itString;
  edtInvoiceNo.CharCase := TEditCharCase.ecUpperCase;
  edtInvoiceDate.thsInputDataType := itDate;
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtDueDate.thsInputDataType := itDate;
  edtStkWarehouseId.OnHelperProcess := HelperProcess;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtExchangeRate.thsInputDataType := itFloat;
  edtDescription.thsInputDataType := itString;
  edtEinvProfileId.OnHelperProcess := HelperProcess;
  edtEinvInvoiceTypeId.OnHelperProcess := HelperProcess;
  edtEinvTaxExemptionId.OnHelperProcess := HelperProcess;
  edtEinvPaymentMeansId.OnHelperProcess := HelperProcess;
  edtEinvDeliveryTermId.OnHelperProcess := HelperProcess;
  edtEinvTransportModeId.OnHelperProcess := HelperProcess;
  edtCustomsDeclarationNo.thsInputDataType := itString;
  edtCustomsDeclarationNo.CharCase := TEditCharCase.ecUpperCase;
  edtGtbRefNo.thsInputDataType := itString;
  edtGtbRefNo.CharCase := TEditCharCase.ecUpperCase;
  edtActualExportDate.thsInputDataType := itDate;

  // Kalemler = Table.Lines (servis satır no sırasıyla okur); ekle / çıkar / hesap fatura servisinde
  FPageLines := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MenuLines, 'Lines'));
  FLines := AddDetail<TSlsInvoiceDetail>(FPageLines, 'vw_sls_invoice_detail',
    function: TObjectList<TSlsInvoiceDetail>
    begin
      Result := Table.Lines;
    end,
    function: TSlsInvoiceDetail
    begin
      Result := Service.CreateLine(Table);
    end,
    procedure(ALine: TSlsInvoiceDetail)
    begin
      Service.AddLine(Table, ALine);
    end,
    procedure(ALine: TSlsInvoiceDetail)
    begin
      Service.RemoveLine(Table, ALine);
    end,
    function(ALine: TSlsInvoiceDetail; AMode: TInputFormMode): TForm
    begin
      Result := TfrmSlsInvoiceLine.Create(Self, TSlsInvoiceDetailService.Create, ALine, AMode, nil);
    end);

  FLines.Grid.AddFooterColumn('net_amount', atSum, '#,##0.00');
  FLines.Grid.AddFooterColumn('vat_amount', atSum, '#,##0.00');
  FLines.Grid.AddFooterColumn('total_amount', atSum, '#,##0.00');
  FLines.Grid.BuildData;
  FLines.Grid.SetColumnProperty('id', 0);
  FLines.Grid.SetColumnProperty('sls_invoice_id', 0);
  FLines.Grid.SetColumnProperty('stk_inventory_id', 0);
  FLines.Grid.SetColumnProperty('sls_dispatch_detail_id', 0);
  FLines.Grid.SetColumnProperty('sls_order_detail_id', 0);
  FLines.Grid.SetColumnProperty('invoice_no', 0);
  FLines.Grid.SetColumnProperty('currency', 0);
  FLines.Grid.SetColumnProperty('gross_amount', 0);
  FLines.Grid.SetColumnProperty('discount_amount', 0);
  FLines.Grid.SetColumnProperty('line_no', 50);
  FLines.Grid.SetColumnProperty('inventory_code', 90);
  FLines.Grid.SetColumnProperty('inventory_name', 200);
  FLines.Grid.SetColumnProperty('uom_code', 50);
  FLines.Grid.SetColumnProperty('description', 160);
  FLines.Grid.SetColumnProperty('acc_account_id', 0);
  FLines.Grid.SetColumnProperty('einv_gtip_id', 0);
  FLines.Grid.SetColumnProperty('einv_withholding_id', 0);
  FLines.Grid.SetColumnProperty('seller_einv_diib_line_id', 0);
  FLines.Grid.SetColumnProperty('buyer_einv_diib_line_id', 0);
  FLines.Grid.SetColumnProperty('einv_packaging_type_id', 0);
end;

destructor TfrmSlsInvoiceDetail.Destroy;
begin
  FreeAndNil(FTotals);
  inherited;
end;

procedure TfrmSlsInvoiceDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtInvoiceDate.CanFocus then
    edtInvoiceDate.SetFocus;
end;

procedure TfrmSlsInvoiceDetail.ShowTotalValues;
begin
  if not Assigned(FTotals) or not Assigned(Table) then
    Exit;
  FTotals.SetValue('gross', Table.GrossAmount, Table.Currency);
  FTotals.SetValue('discount', Table.DiscountAmount, Table.Currency);
  FTotals.SetValue('net', Table.NetAmount, Table.Currency);
  FTotals.SetValue('vat', Table.VatAmount, Table.Currency);
  FTotals.SetValue('total', Table.TotalAmount, Table.Currency);
  FTotals.SetValue('withholding', Table.WithholdingAmount, Table.Currency);
  FTotals.SetValue('payable', Table.TotalAmount - Table.WithholdingAmount, Table.Currency);
end;

procedure TfrmSlsInvoiceDetail.ShowEInvField(ALabel: TLabel; AEdit: TEdit; AVisible, ARequired: Boolean);
begin
  ALabel.Visible := AVisible;
  AEdit.Visible := AVisible;
  AEdit.thsRequiredData := AVisible and ARequired;
end;

// Görünen satırlar boşluk bırakmadan alt alta (satır aralığı 23, etiket kutudan 4 px aşağıda); sonuç = sonraki satırın Top'u
function TfrmSlsInvoiceDetail.StackRows(const ALabels: array of TLabel; const AEdits: array of TEdit; ATop: Integer): Integer;
var
  i: Integer;
begin
  Result := ATop;
  for i := 0 to High(AEdits) do
    if AEdits[i].Visible then
    begin
      AEdits[i].Top := Result;
      ALabels[i].Top := Result + 4;
      Inc(Result, 23);
    end;
end;

// Senaryo / tip / istisna / kalemler değişince: bu faturada uygulanamayan alanlar gizlenir ve boşalır (servis kayıtta
// aynısını yapar), zorunlu olanlar işaretlenir. Başka tipe ait istisna kodu tip değişince kaldırılır.
procedure TfrmSlsInvoiceDetail.ApplyEInvScope;
begin
  FScope := Service.EInvScope(Table);
  if FScope.ExemptionTypeMismatch then
  begin
    Table.EinvTaxExemptionId := 0;
    Table.TaxExemptionCode := '';
    Table.TaxExemptionName := '';
    FScope := Service.EInvScope(Table);
  end;
  TSlsInvoiceService.ClearNotApplicableHeader(FScope, Table);
  if not FScope.IsExport then
  begin
    edtCustomsDeclarationNo.Text := '';
    edtGtbRefNo.Text := '';
    edtActualExportDate.Text := '';
  end;
  ShowEInvField(lblEinvInvoiceTypeId, edtEinvInvoiceTypeId, FScope.IsEDoc, FScope.IsEDoc);
  // %0 KDV'li kalem istisna kodu ister
  ShowEInvField(lblEinvTaxExemptionId, edtEinvTaxExemptionId, FScope.ExemptionAvailable,
    FScope.ExemptionRequired or FScope.HasZeroVatLine);
  ShowEInvField(lblEinvPaymentMeansId, edtEinvPaymentMeansId, FScope.IsEDoc, False);
  ShowEInvField(lblEinvUuid, edtEinvUuid, FScope.IsEDoc, False);
  ShowEInvField(lblEinvStatus, edtEinvStatus, FScope.IsEDoc, False);
  StackRows([lblEinvProfileId, lblEinvInvoiceTypeId, lblEinvTaxExemptionId, lblEinvPaymentMeansId, lblEinvUuid, lblEinvStatus],
    [edtEinvProfileId, edtEinvInvoiceTypeId, edtEinvTaxExemptionId, edtEinvPaymentMeansId, edtEinvUuid, edtEinvStatus], edtEinvProfileId.Top);
  // ihracat sütunu (sağ) bütün olarak
  ShowEInvField(lblEinvDeliveryTermId, edtEinvDeliveryTermId, FScope.IsExport, FScope.IsExport);
  ShowEInvField(lblEinvTransportModeId, edtEinvTransportModeId, FScope.IsExport, FScope.IsExport);
  ShowEInvField(lblCustomsDeclarationNo, edtCustomsDeclarationNo, FScope.IsExport, False);
  ShowEInvField(lblGtbRefNo, edtGtbRefNo, FScope.IsExport, False);
  ShowEInvField(lblActualExportDate, edtActualExportDate, FScope.IsExport, False);
end;

procedure TfrmSlsInvoiceDetail.ShowEInvFields;
begin
  if not Assigned(Table) then
    Exit;
  ApplyEInvScope;
  edtEinvProfileId.Text := Table.ProfileCode;
  edtEinvInvoiceTypeId.Text := Table.InvoiceTypeCode;
  if Table.EinvTaxExemptionId > 0 then
    edtEinvTaxExemptionId.Text := Table.TaxExemptionCode + ' - ' + Table.TaxExemptionName
  else
    edtEinvTaxExemptionId.Text := '';
  edtEinvPaymentMeansId.Text := Table.PaymentMeansName;
  edtEinvDeliveryTermId.Text := Table.DeliveryTermCode;
  edtEinvTransportModeId.Text := Table.TransportModeName;
  edtEinvUuid.Text := Table.EinvUuid;
  edtEinvStatus.Text := TEInvLookup.Text(elkEInvStatus, Table.EinvStatus);
end;

procedure TfrmSlsInvoiceDetail.ShowTotals;
begin
  if not Assigned(Table) then
    Exit;
  Service.Recalculate(Table);
  ShowTotalValues;
end;

procedure TfrmSlsInvoiceDetail.DetailsChanged;
begin
  inherited;
  ShowTotals;
  // %0 KDV'li kalem eklendi / kalktı: istisna alanı
  ShowEInvFields;
end;

procedure TfrmSlsInvoiceDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.TitleSingular, 'Sales Invoice');
  lblInvoiceNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColInvoiceNo, 'Invoice No');
  lblInvoiceDate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColInvoiceDate, 'Invoice Date');
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColAccAccountId, 'Customer');
  lblDueDate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColDueDate, 'Due Date');
  lblStkWarehouseId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColStkWarehouseId, 'Warehouse');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColCurrency, 'Currency');
  lblExchangeRate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColExchangeRate, 'Exchange Rate');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColDescription, 'Description');
  if Assigned(FTotals) then
  begin
    FTotals.SetCaption('gross', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColGrossAmount, 'Gross Amount'));
    FTotals.SetCaption('discount', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColDiscountAmount, 'Discount Amount'));
    FTotals.SetCaption('net', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColNetAmount, 'Net Amount'));
    FTotals.SetCaption('vat', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColVatAmount, 'VAT Amount'));
    FTotals.SetCaption('total', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColTotalAmount, 'Total'));
    FTotals.SetCaption('withholding', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColWithholdingAmount, 'Withholding Amount'));
    FTotals.SetCaption('payable', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColPayableAmount, 'Payable Amount'));
  end;
  tsGeneral.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.TabGeneral, 'General');
  tsEInvoice.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.TabEInvoice, 'e-Document / Export');
  lblEinvProfileId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColEinvProfileId, 'e-Document Profile');
  lblEinvInvoiceTypeId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColEinvInvoiceTypeId, 'Invoice Type');
  lblEinvTaxExemptionId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColEinvTaxExemptionId, 'Tax Exemption Code');
  lblEinvPaymentMeansId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColEinvPaymentMeansId, 'Payment Means');
  lblEinvUuid.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColEinvUuid, 'UUID (ETTN)');
  lblEinvStatus.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColEinvStatus, 'e-Document Status');
  lblEinvDeliveryTermId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColEinvDeliveryTermId, 'Delivery Term');
  lblEinvTransportModeId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColEinvTransportModeId, 'Transport Mode');
  lblCustomsDeclarationNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColCustomsDeclarationNo, 'Customs Exit Declaration No');
  lblGtbRefNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColGtbRefNo, 'Customs Reference No');
  lblActualExportDate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColActualExportDate, 'Actual Export Date');
  if Assigned(edtEinvStatus) and Assigned(Table) then
    edtEinvStatus.Text := TEInvLookup.Text(elkEInvStatus, Table.EinvStatus);

  if Assigned(FPageLines) then
    FPageLines.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MenuLines, 'Lines');
  if Assigned(FLines) then
  begin
    FLines.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColLineNo, 'Line No'));
    FLines.Grid.SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColInventoryCode, 'Stock Code'));
    FLines.Grid.SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColInventoryName, 'Stock Name'));
    FLines.Grid.SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColUomCode, 'Unit'));
    FLines.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColQuantity, 'Quantity'));
    FLines.Grid.SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColUnitPrice, 'Unit Price'));
    FLines.Grid.SetColumnTitle('discount_rate', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColDiscountRate, 'Discount (%)'));
    FLines.Grid.SetColumnTitle('vat_rate', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColVatRate, 'VAT (%)'));
    FLines.Grid.SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColNetAmount, 'Net Amount'));
    FLines.Grid.SetColumnTitle('vat_amount', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColVatAmount, 'VAT Amount'));
    FLines.Grid.SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColTotalAmount, 'Total'));
    FLines.Grid.SetColumnTitle('dispatch_no', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColDispatchNo, 'Delivery Note No'));
    FLines.Grid.SetColumnTitle('order_no', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColOrderNo, 'Order No'));
    FLines.Grid.SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColDescription, 'Description'));
    FLines.Grid.SetColumnTitle('gtip_code', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColGtipCode, 'GTIP Code'));
    FLines.Grid.SetColumnTitle('withholding_code', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColWithholdingCode, 'Withholding Code'));
    FLines.Grid.SetColumnTitle('withholding_rate', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColWithholdingRate, 'Withholding Rate (%)'));
    FLines.Grid.SetColumnTitle('withholding_amount', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColWithholdingAmount, 'Withholding Amount'));
    FLines.Grid.SetColumnTitle('seller_diib_line_code', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColSellerDiibLineCode, 'Seller DIIB Line Code'));
    FLines.Grid.SetColumnTitle('buyer_diib_line_code', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColBuyerDiibLineCode, 'Buyer DIIB Line Code'));
    FLines.Grid.SetColumnTitle('diib_product_description', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColDiibProductDescription, 'DIIB Product Description'));
    FLines.Grid.SetColumnTitle('packaging_type_code', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColPackagingTypeCode, 'Packaging Type'));
    FLines.Grid.SetColumnTitle('package_no', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColPackageNo, 'Package No'));
    FLines.Grid.SetColumnTitle('package_quantity', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColPackageQuantity, 'Package Quantity'));
    FLines.Grid.SetColumnTitle('package_brand', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColPackageBrand, 'Package Brand'));
    FLines.Grid.SetColumnTitle('uom_einv_code', TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColUomEinvCode, 'e-Document Unit'));
  end;
end;

procedure TfrmSlsInvoiceDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccAccountId: TfrmAccAccounts;
  LFrmStkWarehouseId: TfrmStkWarehouses;
  LFrmCurrency: TfrmSysCurrencies;
  LLine: TSlsInvoiceDetail;
  LFrmProfile: TfrmEInvProfiles;
  LFrmType: TfrmEInvInvoiceTypes;
  LFrmExemption: TfrmEInvTaxExemptions;
  LFrmPayment: TfrmEInvPaymentMeansList;
  LFrmDelivery: TfrmEInvDeliveryTerms;
  LFrmTransport: TfrmEInvTransportModes;
begin
  if not (Sender is TEdit) then
    Exit;
  LEdit := (Sender as TEdit);
  if LEdit.Name = edtAccAccountId.Name then
  begin
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
          LEdit.Clear;
        end
        else
        begin
          Table.AccAccountId := LFrmAccAccountId.Table.Id;
          Table.AccountCode := LFrmAccAccountId.Table.Code;
          Table.AccountName := LFrmAccAccountId.Table.Name;
          LEdit.Text := Table.AccountName;
          // e-belge senaryosu boşsa cariye göre önerilir (e-Fatura mükellefi / e-Arşiv)
          Service.SuggestEInv(Table, LFrmAccAccountId.Table.EInvoiceActive);
          ShowEInvFields;
        end;
      // kalemlerin müşterisi (alıcı DİİB satırı seçimi) belgeyle aynı
      for LLine in Table.Lines do
        LLine.AccAccountId := Table.AccAccountId;
    finally
      LFrmAccAccountId.Free;
    end;
  end
  else if LEdit.Name = edtStkWarehouseId.Name then
  begin
    LFrmStkWarehouseId := TfrmStkWarehouses.Create(LEdit, TStkWarehouseService.Create, TStkWarehouse.Create);
    try
      LFrmStkWarehouseId.IsHelper := True;
      LFrmStkWarehouseId.ShowModal;
      if LFrmStkWarehouseId.DataTransfer then
        if LFrmStkWarehouseId.CleanAndClose then
        begin
          Table.StkWarehouseId := 0;
          Table.WarehouseName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.StkWarehouseId := LFrmStkWarehouseId.Table.Id;
          Table.WarehouseName := LFrmStkWarehouseId.Table.WarehouseName;
          LEdit.Text := Table.WarehouseName;
        end;
    finally
      LFrmStkWarehouseId.Free;
    end;
  end
  else if LEdit.Name = edtCurrency.Name then
  begin
    LFrmCurrency := TfrmSysCurrencies.Create(LEdit, TSysCurrencyService.Create, TSysCurrency.Create);
    try
      LFrmCurrency.IsHelper := True;
      LFrmCurrency.ShowModal;
      if LFrmCurrency.DataTransfer then
        if LFrmCurrency.CleanAndClose then
        begin
          Table.Currency := '';
          LEdit.Clear;
        end
        else
        begin
          Table.Currency := LFrmCurrency.Table.Currency;
          LEdit.Text := Table.Currency;
        end;
      // kalemlerin para birimi (fiyat önerisi) ve toplamların gösterimi belgeyle aynı
      for LLine in Table.Lines do
        LLine.Currency := Table.Currency;
      ShowTotalValues;
    finally
      LFrmCurrency.Free;
    end;
  end
  else if LEdit.Name = edtEinvProfileId.Name then
  begin
    LFrmProfile := TfrmEInvProfiles.Create(LEdit, TEInvProfileService.Create, TEInvProfile.Create);
    try
      LFrmProfile.IsHelper := True;
      LFrmProfile.SetActiveOnly(True);
      LFrmProfile.ShowModal;
      if LFrmProfile.DataTransfer then
        if LFrmProfile.CleanAndClose then
        begin
          Table.EinvProfileId := 0;
          Table.ProfileCode := '';
          Table.EinvInvoiceTypeId := 0;
          Table.InvoiceTypeCode := '';
        end
        else
        begin
          Table.EinvProfileId := LFrmProfile.Table.Id;
          Table.ProfileCode := LFrmProfile.Table.Code;
          Service.SuggestInvoiceType(Table);
        end;
      ShowEInvFields;
    finally
      LFrmProfile.Free;
    end;
  end
  else if LEdit.Name = edtEinvInvoiceTypeId.Name then
  begin
    LFrmType := TfrmEInvInvoiceTypes.Create(LEdit, TEInvInvoiceTypeService.Create, TEInvInvoiceType.Create);
    try
      LFrmType.IsHelper := True;
      LFrmType.SetActiveOnly;
      LFrmType.ShowModal;
      if LFrmType.DataTransfer then
        if LFrmType.CleanAndClose then
        begin
          Table.EinvInvoiceTypeId := 0;
          Table.InvoiceTypeCode := '';
        end
        else
        begin
          Table.EinvInvoiceTypeId := LFrmType.Table.Id;
          Table.InvoiceTypeCode := LFrmType.Table.Code;
        end;
      ShowEInvFields;
    finally
      LFrmType.Free;
    end;
  end
  else if LEdit.Name = edtEinvTaxExemptionId.Name then
  begin
    LFrmExemption := TfrmEInvTaxExemptions.Create(LEdit, TEInvTaxExemptionService.Create, TEInvTaxExemption.Create);
    try
      LFrmExemption.IsHelper := True;
      // %0 KDV'li kalem yoksa ve tip istisna istemiyorsa yalnız KDV'li kalemle kullanılan kodlar
      LFrmExemption.SetActiveOnly(Table.EinvInvoiceTypeId, not FScope.HasZeroVatLine and not FScope.ExemptionRequired);
      LFrmExemption.ShowModal;
      if LFrmExemption.DataTransfer then
        if LFrmExemption.CleanAndClose then
        begin
          Table.EinvTaxExemptionId := 0;
          Table.TaxExemptionCode := '';
          Table.TaxExemptionName := '';
        end
        else
        begin
          Table.EinvTaxExemptionId := LFrmExemption.Table.Id;
          Table.TaxExemptionCode := LFrmExemption.Table.Code;
          Table.TaxExemptionName := LFrmExemption.Table.Name;
        end;
      ShowEInvFields;
    finally
      LFrmExemption.Free;
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
      ShowEInvFields;
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
      LFrmDelivery.ShowModal;
      if LFrmDelivery.DataTransfer then
        if LFrmDelivery.CleanAndClose then
        begin
          Table.EinvDeliveryTermId := 0;
          Table.DeliveryTermCode := '';
        end
        else
        begin
          Table.EinvDeliveryTermId := LFrmDelivery.Table.Id;
          Table.DeliveryTermCode := LFrmDelivery.Table.Code;
        end;
      ShowEInvFields;
    finally
      LFrmDelivery.Free;
    end;
  end
  else if LEdit.Name = edtEinvTransportModeId.Name then
  begin
    LFrmTransport := TfrmEInvTransportModes.Create(LEdit, TEInvTransportModeService.Create, TEInvTransportMode.Create);
    try
      LFrmTransport.IsHelper := True;
      LFrmTransport.SetActiveOnly;
      LFrmTransport.ShowModal;
      if LFrmTransport.DataTransfer then
        if LFrmTransport.CleanAndClose then
        begin
          Table.EinvTransportModeId := 0;
          Table.TransportModeName := '';
        end
        else
        begin
          Table.EinvTransportModeId := LFrmTransport.Table.Id;
          Table.TransportModeName := LFrmTransport.Table.Name;
        end;
      ShowEInvFields;
    finally
      LFrmTransport.Free;
    end;
  end;
end;

procedure TfrmSlsInvoiceDetail.RefreshData;
begin
  inherited;
  edtInvoiceNo.Text := Table.InvoiceNo;
  if Table.InvoiceDate > 0 then
    edtInvoiceDate.Text := DateToStr(Table.InvoiceDate)
  else
    edtInvoiceDate.Text := '';
  edtAccAccountId.Text := Table.AccountName;
  if Table.DueDate > 0 then
    edtDueDate.Text := DateToStr(Table.DueDate)
  else
    edtDueDate.Text := '';
  edtStkWarehouseId.Text := Table.WarehouseName;
  edtCurrency.Text := Table.Currency;
  edtExchangeRate.Text := CurrToStr(Table.ExchangeRate);
  edtDescription.Text := Table.Description;
  edtCustomsDeclarationNo.Text := Table.CustomsDeclarationNo;
  edtGtbRefNo.Text := Table.GtbRefNo;
  if Table.ActualExportDate > 0 then
    edtActualExportDate.Text := DateToStr(Table.ActualExportDate)
  else
    edtActualExportDate.Text := '';
  ShowEInvFields;
  if Table.Lines.Count > 0 then
    ShowTotals
  else
    ShowTotalValues;
end;

end.
