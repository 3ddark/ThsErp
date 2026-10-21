unit ufrmPurOrderLine;

// Sipariş kalemi satır formu (TfrmPurOrderDetail'den modal): bellekteki satırı düzenler, DB'ye siparişle birlikte yazılır.
// Girilenler: sıra no, stok, miktar (ölçü birimi yanında), birim fiyat (para birimi yanında), iskonto (0-100), KDV
// (tanımlı oranlardan seçilir), teslim tarihi. Hesaplananlar (brüt / iskonto / net / KDV / toplam, teslim alınan,
// bağlı talep) panelde gösterilir; miktar / fiyat / iskonto / KDV değiştikçe anında yeniden hesaplanır.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputLineDB, SharedFormTypes, LocalizationManager, Detail.Totals,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  PurOrderDetail.Service, PurOrderDetail;

type
  TfrmPurOrderLine = class(TfrmInputLineDB<TPurOrderDetail, TPurOrderDetailService>)
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
    lblDeliveryDate: TLabel;
    edtDeliveryDate: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    pnlTotals: TPanel;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FTotals: TTotalsPanel;
    FVatRates: TArray<Currency>;
    procedure FillVatRates;
    procedure SelectVatRate(ARate: Currency);
    function SelectedVatRate: Currency;
    procedure FillInventoryDefaults;
    procedure InputChanged(Sender: TObject);
    procedure DiscountChanged(Sender: TObject);
    // Girilen değerlerle tutarlar (Table'a yazmadan) hesaplanır ve panelde gösterilir
    procedure ShowAmounts;
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
  SysDecimalPlace.Cache,
  PurLookup, AccSetTaxRate.Service,
  StkInventory, StkInventory.Service, ufrmStkInventories;   // TfrmStkInventories helper output form

const
  ROW_GROSS = 'gross';
  ROW_DISCOUNT = 'discount';
  ROW_NET = 'net';
  ROW_VAT = 'vat';
  ROW_TOTAL = 'total';
  ROW_RECEIVED = 'received';
  ROW_REQUEST = 'request';

procedure TfrmPurOrderLine.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır; sipariş (pur_order_id) ana formdan gelir, formda gösterilmez
  Table.LineNo := StrToIntDef(edtLineNo.Text, 0);
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  Table.UnitPrice := StrToCurrDef(edtUnitPrice.Text, 0);
  Table.DiscountRate := StrToCurrDef(edtDiscountRate.Text, 0);
  Table.VatRate := SelectedVatRate;
  Table.DeliveryDate := StrToDateDef(edtDeliveryDate.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

// Kabul: alan kontrolleri + tutarlar (servisin belge kaydıyla aynı kurallar), KDV tanımlı oranlardan
procedure TfrmPurOrderLine.PrepareLine;
begin
  inherited;
  TPurOrderDetailService.CheckLine(Table);
  TAccSetTaxRateService.CheckDefinedRate(Table.VatRate, FVatRates);
end;

procedure TfrmPurOrderLine.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtLineNo.thsInputDataType := itInteger;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
  edtQuantity.thsDecimalDigitCount := TDecimalPlaces.Quantity;
  edtUnitPrice.thsInputDataType := itFloat;
  edtUnitPrice.thsDecimalDigitCount := TDecimalPlaces.Price;
  edtDiscountRate.thsInputDataType := itFloat;
  edtDeliveryDate.thsInputDataType := itDate;
  edtDescription.thsInputDataType := itString;

  edtQuantity.OnChange := InputChanged;
  edtUnitPrice.OnChange := InputChanged;
  edtDiscountRate.OnChange := DiscountChanged;
  cbbVatRate.OnChange := InputChanged;

  FTotals := TTotalsPanel.Create(pnlTotals);
  FTotals.AddRow(ROW_GROSS);
  FTotals.AddRow(ROW_DISCOUNT);
  FTotals.AddRow(ROW_NET);
  FTotals.AddRow(ROW_VAT);
  FTotals.AddRow(ROW_TOTAL, True);
  FTotals.AddRow(ROW_RECEIVED);
  FTotals.AddRow(ROW_REQUEST);
  pnlTotals.Height := FTotals.RequiredHeight;

  FillVatRates;
end;

destructor TfrmPurOrderLine.Destroy;
begin
  FreeAndNil(FTotals);
  inherited;
end;

procedure TfrmPurOrderLine.FormShow(Sender: TObject);
begin
  inherited;
  if edtStkInventoryId.CanFocus then
    edtStkInventoryId.SetFocus;
end;

procedure TfrmPurOrderLine.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.TitleSingular, 'Order Line');
  lblLineNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColLineNo, 'Line No');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColStkInventoryId, 'Stock Card');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColQuantity, 'Quantity');
  lblUnitPrice.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColUnitPrice, 'Unit Price');
  lblDiscountRate.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColDiscountRate, 'Discount (%)');
  lblVatRate.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColVatRate, 'VAT (%)');
  lblDeliveryDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColDeliveryDate, 'Delivery Date');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColDescription, 'Description');
  if Assigned(FTotals) then
  begin
    FTotals.SetCaption(ROW_GROSS, TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColGrossAmount, 'Gross Amount'));
    FTotals.SetCaption(ROW_DISCOUNT, TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColDiscountAmount, 'Discount Amount'));
    FTotals.SetCaption(ROW_NET, TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColNetAmount, 'Net Amount'));
    FTotals.SetCaption(ROW_VAT, TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColVatAmount, 'VAT Amount'));
    FTotals.SetCaption(ROW_TOTAL, TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColTotalAmount, 'Total'));
    FTotals.SetCaption(ROW_RECEIVED, TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColReceivedQuantity, 'Received Quantity'));
    FTotals.SetCaption(ROW_REQUEST, TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColRequestNo, 'Request No'));
  end;
end;

// Tanımlı KDV oranları (acc_set_tax_rate)
procedure TfrmPurOrderLine.FillVatRates;
var
  LRate: Currency;
begin
  FVatRates := Service.GetVatRates;
  cbbVatRate.Items.BeginUpdate;
  try
    cbbVatRate.Items.Clear;
    for LRate in FVatRates do
      cbbVatRate.Items.Add(FormatFloat('0.##', LRate));
  finally
    cbbVatRate.Items.EndUpdate;
  end;
end;

procedure TfrmPurOrderLine.SelectVatRate(ARate: Currency);
var
  LText: string;
begin
  LText := FormatFloat('0.##', ARate);
  // listede olmayan oran: kayıtlı satırda gösterilir (kayıtta reddedilir), yeni satırda (0) boş bırakılır
  if (cbbVatRate.Items.IndexOf(LText) < 0) and (ARate <> 0) then
    cbbVatRate.Items.Add(LText);
  cbbVatRate.ItemIndex := cbbVatRate.Items.IndexOf(LText);
end;

function TfrmPurOrderLine.SelectedVatRate: Currency;
begin
  if cbbVatRate.ItemIndex < 0 then
    Result := 0
  else
    Result := StrToCurrDef(cbbVatRate.Items[cbbVatRate.ItemIndex], 0);
end;

// İskonto 0-100: üst sınır aşılırsa 100'e çekilir
procedure TfrmPurOrderLine.DiscountChanged(Sender: TObject);
begin
  if StrToCurrDef(edtDiscountRate.Text, 0) > 100 then
  begin
    edtDiscountRate.Text := '100';
    edtDiscountRate.SelStart := Length(edtDiscountRate.Text);
    Exit;   // Text ataması OnChange'i yeniden tetikler
  end;
  ShowAmounts;
end;

procedure TfrmPurOrderLine.InputChanged(Sender: TObject);
begin
  ShowAmounts;
end;

procedure TfrmPurOrderLine.ShowAmounts;
var
  LGross, LDiscount, LNet, LVat, LTotal: Currency;
begin
  if not Assigned(FTotals) or not Assigned(Table) then
    Exit;
  LGross := 0; LDiscount := 0; LNet := 0; LVat := 0; LTotal := 0;
  TPurLookup.CalculateLine(StrToCurrDef(edtQuantity.Text, 0), StrToCurrDef(edtUnitPrice.Text, 0),
    StrToCurrDef(edtDiscountRate.Text, 0), SelectedVatRate, LGross, LDiscount, LNet, LVat, LTotal);
  FTotals.SetValue(ROW_GROSS, LGross, Table.Currency);
  FTotals.SetValue(ROW_DISCOUNT, LDiscount, Table.Currency);
  FTotals.SetValue(ROW_NET, LNet, Table.Currency);
  FTotals.SetValue(ROW_VAT, LVat, Table.Currency);
  FTotals.SetValue(ROW_TOTAL, LTotal, Table.Currency);
  FTotals.SetValue(ROW_RECEIVED, Table.ReceivedQuantity, Table.UomCode, -1);
  FTotals.SetText(ROW_REQUEST, Table.RequestNo);
end;

procedure TfrmPurOrderLine.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmStkInventoryId: TfrmStkInventories;
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
        FillInventoryDefaults;
      ShowAmounts;
    finally
      LFrmStkInventoryId.Free;
    end;
  end;
end;

// Stok kartının alış fiyatı (belge para biriminde ise), alış iskontosu ve geçerli KDV oranı önerilir
procedure TfrmPurOrderLine.FillInventoryDefaults;
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

procedure TfrmPurOrderLine.RefreshData;
begin
  inherited;
  edtLineNo.Text := IntToStr(Table.LineNo);
  edtStkInventoryId.Text := Table.InventoryName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
  edtUnitPrice.Text := CurrToStr(Table.UnitPrice);
  edtDiscountRate.Text := CurrToStr(Table.DiscountRate);
  SelectVatRate(Table.VatRate);
  if Table.DeliveryDate > 0 then
    edtDeliveryDate.Text := DateToStr(Table.DeliveryDate)
  else
    edtDeliveryDate.Text := '';
  edtDescription.Text := Table.Description;
  lblUomCode.Caption := Table.UomCode;
  lblPriceCurrency.Caption := Table.Currency;
  ShowAmounts;
end;

end.
