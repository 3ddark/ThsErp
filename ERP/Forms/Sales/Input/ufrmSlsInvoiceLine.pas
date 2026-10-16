unit ufrmSlsInvoiceLine;

// Fatura kalemi satır formu (TfrmSlsInvoiceDetail'den modal): bellekteki satırı düzenler, DB'ye faturayla birlikte
// yazılır. Girilenler: sıra no, stok, miktar (ölçü birimi yanında), birim fiyat (para birimi yanında), iskonto (0-100),
// KDV (tanımlı oranlardan). Hesaplananlar (brüt / iskonto / net / KDV / toplam, bağlı irsaliye / sipariş) panelde;
// miktar / fiyat / iskonto / KDV değiştikçe anında yeniden hesaplanır.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputLineDB, SharedFormTypes, LocalizationManager, Detail.Totals,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SlsInvoiceDetail.Service, SlsInvoiceDetail;

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
  SlsLookup, SlsOfferDetail.Service,
  StkInventory, StkInventory.Service, ufrmStkInventories;   // TfrmStkInventories helper output form

const
  ROW_GROSS = 'gross';
  ROW_DISCOUNT = 'discount';
  ROW_NET = 'net';
  ROW_VAT = 'vat';
  ROW_TOTAL = 'total';
  ROW_DISPATCH = 'dispatch';
  ROW_ORDER = 'order';

procedure TfrmSlsInvoiceLine.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır; fatura (sls_invoice_id) ana formdan gelir
  Table.LineNo := StrToIntDef(edtLineNo.Text, 0);
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  Table.UnitPrice := StrToCurrDef(edtUnitPrice.Text, 0);
  Table.DiscountRate := StrToCurrDef(edtDiscountRate.Text, 0);
  Table.VatRate := SelectedVatRate;
  Table.Description := edtDescription.Text;
  inherited;
end;

// Kabul: alan kontrolleri + tutarlar (servisin belge kaydıyla aynı kurallar), KDV tanımlı oranlardan
procedure TfrmSlsInvoiceLine.PrepareLine;
begin
  inherited;
  TSlsInvoiceDetailService.CheckLine(Table);
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
  FTotals.AddRow(ROW_DISPATCH);
  FTotals.AddRow(ROW_ORDER);
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
  end;
end;

procedure TfrmSlsInvoiceLine.FillVatRates;
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

procedure TfrmSlsInvoiceLine.SelectVatRate(ARate: Currency);
var
  LText: string;
begin
  LText := FormatFloat('0.##', ARate);
  // listede olmayan oran: kayıtlı satırda gösterilir (kayıtta reddedilir), yeni satırda (0) boş bırakılır
  if (cbbVatRate.Items.IndexOf(LText) < 0) and (ARate <> 0) then
    cbbVatRate.Items.Add(LText);
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
end;

procedure TfrmSlsInvoiceLine.HelperProcess(Sender: TObject);
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
  ShowAmounts;
end;

end.
