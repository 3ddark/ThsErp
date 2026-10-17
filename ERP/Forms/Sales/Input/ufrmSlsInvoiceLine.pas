unit ufrmSlsInvoiceLine;

// Fatura kalemi satır formu (TfrmSlsInvoiceDetail'den modal): bellekteki satırı düzenler, DB'ye faturayla birlikte
// yazılır. Girilenler: sıra no, stok, miktar (ölçü birimi yanında), birim fiyat (para birimi yanında), iskonto (0-100),
// KDV (tanımlı oranlardan). Hesaplananlar (brüt / iskonto / net / KDV / toplam, bağlı irsaliye / sipariş) panelde;
// miktar / fiyat / iskonto / KDV değiştikçe anında yeniden hesaplanır.
// e-Belge / İhracat: GTİP (boşsa stok kartından / DİİB satırından), tevkifat kodu (tutar = KDV x oran), satıcı DİİB
// satırı (firmamızın belgesi) ve alıcı DİİB satırı (faturadaki müşterinin belgesi), kap cinsi / no / adedi / markası.
// Yalnız faturanın e-belge kapsamında anlamlı alanlar görünür (boşluksuz dizilir, bölüm boşsa gizlenir ve form kısalır):
// GTİP + kap bilgisi yalnız ihracat ya da GTİP isteyen istisnada (ihraç kayıtlı 702), DİİB satır kodları yalnız DİİB
// isteyen istisnada (GİB: IHRACKAYITLI + 702), tevkifat kağıt faturada / tevkifat tipinde (KDV %0 iken pasif). Gizlenen
// alanın değeri boşalır.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputLineDB, SharedFormTypes, LocalizationManager, Detail.Totals,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SlsInvoiceDetail.Service, SlsInvoiceDetail, SlsInvoice.Repository;

type
  TfrmSlsInvoiceLine = class(TfrmInputLineDB<TSlsInvoiceDetail, TSlsInvoiceDetailService>)
    pnlContent: TPanel;
    lblLineNo: TLabel;
    edtLineNo: TEdit;
    lblStkInventoryId: TLabel;
    edtStkInventoryId: TEdit;
    lblQuantity: TLabel;
    edtQuantity: TEdit;
    lblUomCode: TLabel;
    lblUnitPrice: TLabel;
    edtUnitPrice: TEdit;
    lblPriceCurrency: TLabel;
    lblDiscountRate: TLabel;
    edtDiscountRate: TEdit;
    lblVatRate: TLabel;
    cbbVatRate: TComboBox;
    lblDescription: TLabel;
    edtDescription: TEdit;
    pnlTotals: TPanel;
    lblEInvSection: TLabel;
    lblEinvGtipId: TLabel;
    edtEinvGtipId: TEdit;
    lblEinvWithholdingId: TLabel;
    edtEinvWithholdingId: TEdit;
    lblSellerEinvDiibLineId: TLabel;
    edtSellerEinvDiibLineId: TEdit;
    lblBuyerEinvDiibLineId: TLabel;
    edtBuyerEinvDiibLineId: TEdit;
    lblEinvPackagingTypeId: TLabel;
    edtEinvPackagingTypeId: TEdit;
    lblPackageNo: TLabel;
    edtPackageNo: TEdit;
    lblPackageQuantity: TLabel;
    edtPackageQuantity: TEdit;
    lblPackageBrand: TLabel;
    edtPackageBrand: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FTotals: TTotalsPanel;
    FVatRates: TArray<Currency>;
    FScope: TSlsEInvScope;
    procedure ApplyEInvScope;
    procedure ShowEInvField(ALabel: TLabel; AEdit: TEdit; AVisible, ARequired: Boolean);
    function StackRows(const ALabels: array of TLabel; const AEdits: array of TEdit; ATop: Integer): Integer;
    procedure VatChanged(Sender: TObject);
    procedure FillVatRates;
    procedure SelectVatRate(ARate: Currency);
    function SelectedVatRate: Currency;
    procedure FillInventoryDefaults;
    procedure InputChanged(Sender: TObject);
    procedure DiscountChanged(Sender: TObject);
    procedure ShowAmounts;
    procedure ShowEInvFields;
  protected
    procedure PrepareLine; override;
  public
    destructor Destroy; override;
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SlsLookup, SlsOfferDetail.Service, SlsInvoice, SlsInvoice.Service,
  StkInventory, StkInventory.Service, ufrmStkInventories,   // TfrmStkInventories helper output form
  EInvLookup,
  EInvGtip, EInvGtip.Service, ufrmEInvGtips,                               // TfrmEInvGtips helper output form
  EInvWithholding, EInvWithholding.Service, ufrmEInvWithholdings,          // TfrmEInvWithholdings helper output form
  EInvDiibLine, EInvDiibLine.Service, ufrmEInvDiibLines,                   // TfrmEInvDiibLines helper output form
  EInvPackagingType, EInvPackagingType.Service, ufrmEInvPackagingTypes;    // TfrmEInvPackagingTypes helper output form

const
  ROW_GROSS = 'gross';
  ROW_DISCOUNT = 'discount';
  ROW_NET = 'net';
  ROW_VAT = 'vat';
  ROW_TOTAL = 'total';
  ROW_DISPATCH = 'dispatch';
  ROW_ORDER = 'order';
  ROW_WITHHOLDING = 'withholding';
  ROW_DIIB = 'diib';

procedure TfrmSlsInvoiceLine.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır; fatura (sls_invoice_id) ana formdan gelir
  Table.LineNo := StrToIntDef(edtLineNo.Text, 0);
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  Table.UnitPrice := StrToCurrDef(edtUnitPrice.Text, 0);
  Table.DiscountRate := StrToCurrDef(edtDiscountRate.Text, 0);
  Table.VatRate := SelectedVatRate;
  Table.Description := edtDescription.Text;
  Table.PackageNo := edtPackageNo.Text;
  Table.PackageQuantity := StrToCurrDef(edtPackageQuantity.Text, 0);
  Table.PackageBrand := edtPackageBrand.Text;
  inherited;
end;

// Kabul: alan kontrolleri + tutarlar (servisin belge kaydıyla aynı kurallar), KDV tanımlı oranlardan
procedure TfrmSlsInvoiceLine.PrepareLine;
begin
  inherited;
  TSlsInvoiceDetailService.CheckLine(Table);
  // %0 KDV (istisna / ihracat) faturanın istisna koduyla belge kaydında denetlenir
  if Table.VatRate <> 0 then
    TSlsOfferDetailService.CheckVatRate(Table.VatRate, FVatRates);
end;

procedure TfrmSlsInvoiceLine.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtLineNo.thsInputDataType := itInteger;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
  edtUnitPrice.thsInputDataType := itFloat;
  edtDiscountRate.thsInputDataType := itFloat;
  edtDescription.thsInputDataType := itString;
  edtEinvGtipId.OnHelperProcess := HelperProcess;
  edtEinvWithholdingId.OnHelperProcess := HelperProcess;
  edtSellerEinvDiibLineId.OnHelperProcess := HelperProcess;
  edtBuyerEinvDiibLineId.OnHelperProcess := HelperProcess;
  edtEinvPackagingTypeId.OnHelperProcess := HelperProcess;
  edtPackageNo.thsInputDataType := itString;
  edtPackageNo.CharCase := TEditCharCase.ecUpperCase;
  edtPackageQuantity.thsInputDataType := itFloat;
  edtPackageBrand.thsInputDataType := itString;

  edtQuantity.OnChange := InputChanged;
  edtUnitPrice.OnChange := InputChanged;
  edtDiscountRate.OnChange := DiscountChanged;
  cbbVatRate.OnChange := VatChanged;

  FTotals := TTotalsPanel.Create(pnlTotals);
  FTotals.AddRow(ROW_GROSS);
  FTotals.AddRow(ROW_DISCOUNT);
  FTotals.AddRow(ROW_NET);
  FTotals.AddRow(ROW_VAT);
  FTotals.AddRow(ROW_TOTAL, True);
  FTotals.AddRow(ROW_DISPATCH);
  FTotals.AddRow(ROW_ORDER);
  FTotals.AddRow(ROW_WITHHOLDING);
  FTotals.AddRow(ROW_DIIB);
  pnlTotals.Height := FTotals.RequiredHeight;

  FillVatRates;
end;

destructor TfrmSlsInvoiceLine.Destroy;
begin
  FreeAndNil(FTotals);
  inherited;
end;

procedure TfrmSlsInvoiceLine.FormShow(Sender: TObject);
begin
  inherited;
  if edtStkInventoryId.CanFocus then
    edtStkInventoryId.SetFocus;
end;

procedure TfrmSlsInvoiceLine.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.TitleSingular, 'Invoice Line');
  lblLineNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColLineNo, 'Line No');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColStkInventoryId, 'Stock Card');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColQuantity, 'Quantity');
  lblUnitPrice.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColUnitPrice, 'Unit Price');
  lblDiscountRate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColDiscountRate, 'Discount (%)');
  lblVatRate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColVatRate, 'VAT (%)');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColDescription, 'Description');
  if Assigned(FTotals) then
  begin
    FTotals.SetCaption(ROW_GROSS, TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColGrossAmount, 'Gross Amount'));
    FTotals.SetCaption(ROW_DISCOUNT, TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColDiscountAmount, 'Discount Amount'));
    FTotals.SetCaption(ROW_NET, TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColNetAmount, 'Net Amount'));
    FTotals.SetCaption(ROW_VAT, TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColVatAmount, 'VAT Amount'));
    FTotals.SetCaption(ROW_TOTAL, TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColTotalAmount, 'Total'));
    FTotals.SetCaption(ROW_DISPATCH, TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColDispatchNo, 'Delivery Note No'));
    FTotals.SetCaption(ROW_ORDER, TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColOrderNo, 'Order No'));
    FTotals.SetCaption(ROW_WITHHOLDING, TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColWithholdingAmount, 'Withholding Amount'));
    FTotals.SetCaption(ROW_DIIB, TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColDiibProductDescription, 'DIIB Product Description'));
  end;
  lblEInvSection.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.TabEInvoice, 'e-Document / Export');
  lblEinvGtipId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColEinvGtipId, 'GTIP Code');
  lblEinvWithholdingId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColEinvWithholdingId, 'Withholding Code');
  lblSellerEinvDiibLineId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColSellerEinvDiibLineId, 'Seller DIIB Line Code');
  lblBuyerEinvDiibLineId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColBuyerEinvDiibLineId, 'Buyer DIIB Line Code');
  lblEinvPackagingTypeId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColEinvPackagingTypeId, 'Packaging Type');
  lblPackageNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColPackageNo, 'Package No');
  lblPackageQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColPackageQuantity, 'Package Quantity');
  lblPackageBrand.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.ColPackageBrand, 'Package Brand');
end;

procedure TfrmSlsInvoiceLine.FillVatRates;
var
  LRate: Currency;
begin
  FVatRates := Service.GetVatRates;
  cbbVatRate.Items.BeginUpdate;
  try
    cbbVatRate.Items.Clear;
    // %0: istisna kodlu (istisna / ihraç kayıtlı / ihracat) faturalar için
    cbbVatRate.Items.Add('0');
    for LRate in FVatRates do
      cbbVatRate.Items.Add(FormatFloat('0.##', LRate));
  finally
    cbbVatRate.Items.EndUpdate;
  end;
end;

procedure TfrmSlsInvoiceLine.SelectVatRate(ARate: Currency);
var
  LText: string;
begin
  LText := FormatFloat('0.##', ARate);
  // listede olmayan oran: kayıtlı satırda gösterilir (kayıtta reddedilir), yeni satırda (0) boş bırakılır
  if (cbbVatRate.Items.IndexOf(LText) < 0) and (ARate <> 0) then
    cbbVatRate.Items.Add(LText);
  // yeni satırda %0 seçili gelmez (oran stok kartından önerilir)
  if (ARate = 0) and (Table.Id = 0) then
    cbbVatRate.ItemIndex := -1
  else
    cbbVatRate.ItemIndex := cbbVatRate.Items.IndexOf(LText);
end;

function TfrmSlsInvoiceLine.SelectedVatRate: Currency;
begin
  if cbbVatRate.ItemIndex < 0 then
    Result := 0
  else
    Result := StrToCurrDef(cbbVatRate.Items[cbbVatRate.ItemIndex], 0);
end;

// İskonto 0-100: üst sınır aşılırsa 100'e çekilir
procedure TfrmSlsInvoiceLine.DiscountChanged(Sender: TObject);
begin
  if StrToCurrDef(edtDiscountRate.Text, 0) > 100 then
  begin
    edtDiscountRate.Text := '100';
    edtDiscountRate.SelStart := Length(edtDiscountRate.Text);
    Exit;   // Text ataması OnChange'i yeniden tetikler
  end;
  ShowAmounts;
end;

procedure TfrmSlsInvoiceLine.InputChanged(Sender: TObject);
begin
  ShowAmounts;
end;

// KDV %0 olunca tevkifat kalkar
procedure TfrmSlsInvoiceLine.VatChanged(Sender: TObject);
begin
  ApplyEInvScope;
  ShowAmounts;
end;

procedure TfrmSlsInvoiceLine.ShowEInvField(ALabel: TLabel; AEdit: TEdit; AVisible, ARequired: Boolean);
begin
  ALabel.Visible := AVisible;
  AEdit.Visible := AVisible;
  AEdit.thsRequiredData := AVisible and ARequired;
end;

// Görünen satırlar boşluk bırakmadan alt alta (satır aralığı 23, etiket kutudan 4 px aşağıda); sonuç = sonraki satırın Top'u
function TfrmSlsInvoiceLine.StackRows(const ALabels: array of TLabel; const AEdits: array of TEdit; ATop: Integer): Integer;
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

// Faturanın e-belge kapsamı (senaryo / tip / istisna): uygulanamayan alanlar gizlenir ve boşalır (servis kayıtta aynısını
// yapar), zorunlular işaretlenir; e-Belge bölümü boşsa gizlenir, form yüksekliği görünen içeriğe göre (+12 boşluk, 36
// alt bar, 20 durum çubuğu). Başlığı olmayan (bağımsız açılan) satırda alanlar olduğu gibi kalır.
procedure TfrmSlsInvoiceLine.ApplyEInvScope;
var
  LWithholding, LSection: Boolean;
  LBottom, LNext: Integer;
begin
  if not Assigned(Table) or not Assigned(Table.HeaderEntity) then
    Exit;
  FScope := Service.EInvScope(Table.Header);
  TSlsInvoiceService.ClearNotApplicableLine(FScope, Table);
  // tevkifat alanı faturaya göre görünür, KDV %0 iken pasif (KDV değiştikçe form zıplamasın)
  LWithholding := FScope.WithholdingAllowed and (SelectedVatRate > 0);
  if not LWithholding and (Table.EinvWithholdingId > 0) then
  begin
    Table.EinvWithholdingId := 0;
    Table.WithholdingCode := '';
    Table.WithholdingRate := 0;
  end;
  if not FScope.CustomsLine then
  begin
    edtPackageNo.Text := '';
    edtPackageQuantity.Text := '';
    edtPackageBrand.Text := '';
  end;
  ShowEInvField(lblEinvGtipId, edtEinvGtipId, FScope.CustomsLine, FScope.GtipRequired);
  ShowEInvField(lblEinvWithholdingId, edtEinvWithholdingId, FScope.WithholdingAllowed, False);
  lblEinvWithholdingId.Enabled := LWithholding;
  edtEinvWithholdingId.Enabled := LWithholding;
  ShowEInvField(lblSellerEinvDiibLineId, edtSellerEinvDiibLineId, FScope.DiibAllowed, False);
  ShowEInvField(lblBuyerEinvDiibLineId, edtBuyerEinvDiibLineId, FScope.DiibAllowed, FScope.DiibAllowed);
  // kap sütunu (sağ) bütün olarak
  ShowEInvField(lblEinvPackagingTypeId, edtEinvPackagingTypeId, FScope.CustomsLine, FScope.PackageRequired);
  ShowEInvField(lblPackageNo, edtPackageNo, FScope.CustomsLine, False);
  ShowEInvField(lblPackageQuantity, edtPackageQuantity, FScope.CustomsLine, FScope.PackageRequired);
  ShowEInvField(lblPackageBrand, edtPackageBrand, FScope.CustomsLine, False);

  LSection := FScope.CustomsLine or FScope.WithholdingAllowed or FScope.DiibAllowed;
  lblEInvSection.Visible := LSection;
  LBottom := edtDescription.Top + edtDescription.Height;
  if pnlTotals.Top + pnlTotals.Height > LBottom then
    LBottom := pnlTotals.Top + pnlTotals.Height;
  if LSection then
  begin
    LNext := StackRows([lblEinvGtipId, lblEinvWithholdingId, lblSellerEinvDiibLineId, lblBuyerEinvDiibLineId],
      [edtEinvGtipId, edtEinvWithholdingId, edtSellerEinvDiibLineId, edtBuyerEinvDiibLineId], lblEInvSection.Top + 20);
    if LNext - 1 > LBottom then
      LBottom := LNext - 1;
    if FScope.CustomsLine and (edtPackageBrand.Top + edtPackageBrand.Height > LBottom) then
      LBottom := edtPackageBrand.Top + edtPackageBrand.Height;
  end;
  ClientHeight := LBottom + 12 + 36 + 20;
  ShowEInvFields;
end;

procedure TfrmSlsInvoiceLine.ShowAmounts;
var
  LGross, LDiscount, LNet, LVat, LTotal: Currency;
begin
  if not Assigned(FTotals) or not Assigned(Table) then
    Exit;
  LGross := 0; LDiscount := 0; LNet := 0; LVat := 0; LTotal := 0;
  TSlsLookup.CalculateLine(StrToCurrDef(edtQuantity.Text, 0), StrToCurrDef(edtUnitPrice.Text, 0),
    StrToCurrDef(edtDiscountRate.Text, 0), SelectedVatRate, LGross, LDiscount, LNet, LVat, LTotal);
  FTotals.SetValue(ROW_GROSS, LGross, Table.Currency);
  FTotals.SetValue(ROW_DISCOUNT, LDiscount, Table.Currency);
  FTotals.SetValue(ROW_NET, LNet, Table.Currency);
  FTotals.SetValue(ROW_VAT, LVat, Table.Currency);
  FTotals.SetValue(ROW_TOTAL, LTotal, Table.Currency);
  FTotals.SetText(ROW_DISPATCH, Table.DispatchNo);
  FTotals.SetText(ROW_ORDER, Table.OrderNo);
  if Table.EinvWithholdingId > 0 then
    FTotals.SetValue(ROW_WITHHOLDING, TSlsLookup.RoundAmount(LVat * Table.WithholdingRate / 100), Table.Currency)
  else
    FTotals.SetValue(ROW_WITHHOLDING, 0, Table.Currency);
  FTotals.SetText(ROW_DIIB, Table.DiibProductDescription);
end;

procedure TfrmSlsInvoiceLine.ShowEInvFields;
begin
  edtEinvGtipId.Text := TEInvLookup.FormatGtip(Table.GtipCode);
  if Table.EinvWithholdingId > 0 then
    edtEinvWithholdingId.Text := Table.WithholdingCode + ' (%' + FormatFloat('0.##', Table.WithholdingRate) + ')'
  else
    edtEinvWithholdingId.Text := '';
  edtSellerEinvDiibLineId.Text := Table.SellerDiibLineCode;
  edtBuyerEinvDiibLineId.Text := Table.BuyerDiibLineCode;
  edtEinvPackagingTypeId.Text := Table.PackagingTypeCode;
end;

procedure TfrmSlsInvoiceLine.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmStkInventoryId: TfrmStkInventories;
  LFrmGtip: TfrmEInvGtips;
  LFrmWithholding: TfrmEInvWithholdings;
  LFrmDiib: TfrmEInvDiibLines;
  LFrmPackaging: TfrmEInvPackagingTypes;
  LSeller: Boolean;
begin
  if not (Sender is TEdit) then
    Exit;
  LEdit := (Sender as TEdit);
  if LEdit.Name = edtStkInventoryId.Name then
  begin
    LFrmStkInventoryId := TfrmStkInventories.Create(LEdit, TStkInventoryService.Create, TStkInventory.Create);
    try
      LFrmStkInventoryId.IsHelper := True;
      LFrmStkInventoryId.ShowModal;
      if LFrmStkInventoryId.DataTransfer then
        if LFrmStkInventoryId.CleanAndClose then
        begin
          Table.StkInventoryId := 0;
          Table.InventoryCode := '';
          Table.InventoryName := '';
          Table.UomCode := '';
          LEdit.Clear;
        end
        else
        begin
          Table.StkInventoryId := LFrmStkInventoryId.Table.Id;
          Table.InventoryCode := LFrmStkInventoryId.Table.Code;
          Table.InventoryName := LFrmStkInventoryId.Table.Name;
          Table.UomCode := Service.GetUomCode(Table.StkInventoryId);
          LEdit.Text := Table.InventoryName;
        end;
      lblUomCode.Caption := Table.UomCode;
      if LFrmStkInventoryId.DataTransfer and not LFrmStkInventoryId.CleanAndClose then
      begin
        FillInventoryDefaults;
        // stok kartının KDV'si %0 olabilir (tevkifat alanı); GTİP yalnız ihracat / GTİP isteyen istisnada
        ApplyEInvScope;
        if FScope.CustomsLine and (Table.EinvGtipId <= 0) and (LFrmStkInventoryId.Table.EinvGtipId > 0) then
        begin
          Table.EinvGtipId := LFrmStkInventoryId.Table.EinvGtipId;
          Table.GtipCode := LFrmStkInventoryId.Table.GtipCode;
          ShowEInvFields;
        end;
      end;
      ShowAmounts;
    finally
      LFrmStkInventoryId.Free;
    end;
  end
  else if LEdit.Name = edtEinvGtipId.Name then
  begin
    LFrmGtip := TfrmEInvGtips.Create(LEdit, TEInvGtipService.Create, TEInvGtip.Create);
    try
      LFrmGtip.IsHelper := True;
      LFrmGtip.SetActiveOnly;
      LFrmGtip.ShowModal;
      if LFrmGtip.DataTransfer then
        if LFrmGtip.CleanAndClose then
        begin
          Table.EinvGtipId := 0;
          Table.GtipCode := '';
        end
        else
        begin
          Table.EinvGtipId := LFrmGtip.Table.Id;
          Table.GtipCode := LFrmGtip.Table.Code;
        end;
      ShowEInvFields;
    finally
      LFrmGtip.Free;
    end;
  end
  else if LEdit.Name = edtEinvWithholdingId.Name then
  begin
    LFrmWithholding := TfrmEInvWithholdings.Create(LEdit, TEInvWithholdingService.Create, TEInvWithholding.Create);
    try
      LFrmWithholding.IsHelper := True;
      LFrmWithholding.SetActiveOnly;
      LFrmWithholding.ShowModal;
      if LFrmWithholding.DataTransfer then
        if LFrmWithholding.CleanAndClose then
        begin
          Table.EinvWithholdingId := 0;
          Table.WithholdingCode := '';
          Table.WithholdingRate := 0;
        end
        else
        begin
          Table.EinvWithholdingId := LFrmWithholding.Table.Id;
          Table.WithholdingCode := LFrmWithholding.Table.Code;
          Table.WithholdingRate := LFrmWithholding.Table.Rate;
        end;
      ShowEInvFields;
      ShowAmounts;
    finally
      LFrmWithholding.Free;
    end;
  end
  else if (LEdit.Name = edtSellerEinvDiibLineId.Name) or (LEdit.Name = edtBuyerEinvDiibLineId.Name) then
  begin
    // satıcı: firmamızın DİİB'i; alıcı: faturadaki müşterinin DİİB'i (yalnız aktif belge / satırlar)
    LSeller := LEdit.Name = edtSellerEinvDiibLineId.Name;
    LFrmDiib := TfrmEInvDiibLines.Create(LEdit, TEInvDiibLineService.Create, TEInvDiibLine.Create);
    try
      LFrmDiib.IsHelper := True;
      if LSeller then
        LFrmDiib.SetFixedHolder(EINV_DIIB_OWN, 0)
      else
        LFrmDiib.SetFixedHolder(EINV_DIIB_CUSTOMER, Table.AccAccountId);
      LFrmDiib.ShowModal;
      if LFrmDiib.DataTransfer then
        if LFrmDiib.CleanAndClose then
        begin
          if LSeller then
          begin
            Table.SellerEinvDiibLineId := 0;
            Table.SellerDiibLineCode := '';
          end
          else
          begin
            Table.BuyerEinvDiibLineId := 0;
            Table.BuyerDiibLineCode := '';
          end;
        end
        else
        begin
          if LSeller then
          begin
            Table.SellerEinvDiibLineId := LFrmDiib.Table.Id;
            Table.SellerDiibLineCode := LFrmDiib.Table.LineCode;
          end
          else
          begin
            Table.BuyerEinvDiibLineId := LFrmDiib.Table.Id;
            Table.BuyerDiibLineCode := LFrmDiib.Table.LineCode;
          end;
          // DİİB ürün tanımı (alıcı satırı öncelikli) ve boş GTİP DİİB satırından
          if (not LSeller) or (Table.BuyerEinvDiibLineId <= 0) then
            Table.DiibProductDescription := LFrmDiib.Table.ProductDescription;
          if Table.EinvGtipId <= 0 then
          begin
            Table.EinvGtipId := LFrmDiib.Table.EinvGtipId;
            Table.GtipCode := LFrmDiib.Table.GtipCode;
          end;
        end;
      ShowEInvFields;
      ShowAmounts;
    finally
      LFrmDiib.Free;
    end;
  end
  else if LEdit.Name = edtEinvPackagingTypeId.Name then
  begin
    LFrmPackaging := TfrmEInvPackagingTypes.Create(LEdit, TEInvPackagingTypeService.Create, TEInvPackagingType.Create);
    try
      LFrmPackaging.IsHelper := True;
      LFrmPackaging.SetActiveOnly;
      LFrmPackaging.ShowModal;
      if LFrmPackaging.DataTransfer then
        if LFrmPackaging.CleanAndClose then
        begin
          Table.EinvPackagingTypeId := 0;
          Table.PackagingTypeCode := '';
        end
        else
        begin
          Table.EinvPackagingTypeId := LFrmPackaging.Table.Id;
          Table.PackagingTypeCode := LFrmPackaging.Table.Code;
        end;
      ShowEInvFields;
    finally
      LFrmPackaging.Free;
    end;
  end;
end;

// Stok kartının satış fiyatı (belge para biriminde ise), satış iskontosu ve geçerli KDV oranı önerilir
procedure TfrmSlsInvoiceLine.FillInventoryDefaults;
var
  LPrice, LDiscount, LVat: Currency;
  LCurrency: string;
begin
  if not Service.GetInventoryDefaults(Table.StkInventoryId, LPrice, LCurrency, LDiscount, LVat) then
    Exit;
  if (Table.Currency = '') or (LCurrency = Table.Currency) then
    edtUnitPrice.Text := CurrToStr(LPrice);
  edtDiscountRate.Text := CurrToStr(LDiscount);
  SelectVatRate(LVat);
end;

procedure TfrmSlsInvoiceLine.RefreshData;
begin
  inherited;
  edtLineNo.Text := IntToStr(Table.LineNo);
  edtStkInventoryId.Text := Table.InventoryName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
  edtUnitPrice.Text := CurrToStr(Table.UnitPrice);
  edtDiscountRate.Text := CurrToStr(Table.DiscountRate);
  SelectVatRate(Table.VatRate);
  edtDescription.Text := Table.Description;
  lblUomCode.Caption := Table.UomCode;
  lblPriceCurrency.Caption := Table.Currency;
  edtPackageNo.Text := Table.PackageNo;
  if Table.PackageQuantity > 0 then
    edtPackageQuantity.Text := CurrToStr(Table.PackageQuantity)
  else
    edtPackageQuantity.Text := '';
  edtPackageBrand.Text := Table.PackageBrand;
  ShowEInvFields;
  ApplyEInvScope;
  ShowAmounts;
end;

end.
