unit ufrmPurInvoiceDetail;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  PurInvoiceDetail.Service, PurInvoiceDetail;

type
  TfrmPurInvoiceDetail = class(TfrmInputSimpleDB<TPurInvoiceDetail, TPurInvoiceDetailService>)
    pnlContent: TPanel;
    lblPurInvoiceId: TLabel;
    edtPurInvoiceId: TEdit;
    lblLineNo: TLabel;
    edtLineNo: TEdit;
    lblStkInventoryId: TLabel;
    edtStkInventoryId: TEdit;
    lblQuantity: TLabel;
    edtQuantity: TEdit;
    lblUomCode: TLabel;
    lblUnitPrice: TLabel;
    edtUnitPrice: TEdit;
    lblDiscountRate: TLabel;
    edtDiscountRate: TEdit;
    lblVatRate: TLabel;
    cbbVatRate: TComboBox;
    lblDescription: TLabel;
    edtDescription: TEdit;
    lblGrossAmount: TLabel;
    edtGrossAmount: TEdit;
    lblDiscountAmount: TLabel;
    edtDiscountAmount: TEdit;
    lblNetAmount: TLabel;
    edtNetAmount: TEdit;
    lblVatAmount: TLabel;
    edtVatAmount: TEdit;
    lblTotalAmount: TLabel;
    edtTotalAmount: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure FillInventoryDefaults;
  private
    // KDV yalnız muhasebe ayarlarındaki tanımlı oranlardan (acc_set_tax_rate) seçilir
    procedure FillVatRates;
    procedure SelectVatRate(ARate: Currency);
    function SelectedVatRate: Currency;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  PurLookup,
  PurInvoice, PurInvoice.Service, ufrmPurInvoices,
  StkInventory, StkInventory.Service, ufrmStkInventories;

procedure TfrmPurInvoiceDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.LineNo := StrToIntDef(edtLineNo.Text, 0);
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  Table.UnitPrice := StrToCurrDef(edtUnitPrice.Text, 0);
  Table.DiscountRate := StrToCurrDef(edtDiscountRate.Text, 0);
  Table.VatRate := SelectedVatRate;
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmPurInvoiceDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPurInvoiceId.OnHelperProcess := HelperProcess;
  edtLineNo.thsInputDataType := itInteger;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
  edtUnitPrice.thsInputDataType := itFloat;
  edtDiscountRate.thsInputDataType := itFloat;
  FillVatRates;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmPurInvoiceDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtStkInventoryId.CanFocus then
    edtStkInventoryId.SetFocus;
end;

procedure TfrmPurInvoiceDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.TitleSingular, 'Invoice Line');
  lblPurInvoiceId.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColPurInvoiceId, 'Invoice');
  lblLineNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColLineNo, 'Line No');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColStkInventoryId, 'Stock Card');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColQuantity, 'Quantity');
  lblUnitPrice.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColUnitPrice, 'Unit Price');
  lblDiscountRate.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColDiscountRate, 'Discount (%)');
  lblVatRate.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColVatRate, 'VAT (%)');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColDescription, 'Description');
  lblGrossAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColGrossAmount, 'Gross Amount');
  lblDiscountAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColDiscountAmount, 'Discount Amount');
  lblNetAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColNetAmount, 'Net Amount');
  lblVatAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColVatAmount, 'VAT Amount');
  lblTotalAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColTotalAmount, 'Total');
end;

procedure TfrmPurInvoiceDetail.FillVatRates;
var
  LRate: Currency;
begin
  cbbVatRate.Items.BeginUpdate;
  try
    cbbVatRate.Items.Clear;
    cbbVatRate.Items.Add('0');   // KDV'siz alış (istisna)
    for LRate in Service.GetVatRates do
      cbbVatRate.Items.Add(FormatFloat('0.##', LRate));
  finally
    cbbVatRate.Items.EndUpdate;
  end;
end;

// Listede olmayan oran: kayıtlı satırda gösterilir (kayıtta reddedilir), yeni satırda (0) boş bırakılır
procedure TfrmPurInvoiceDetail.SelectVatRate(ARate: Currency);
var
  LText: string;
begin
  LText := FormatFloat('0.##', ARate);
  if (cbbVatRate.Items.IndexOf(LText) < 0) and (ARate <> 0) then
    cbbVatRate.Items.Add(LText);
  cbbVatRate.ItemIndex := cbbVatRate.Items.IndexOf(LText);
end;

function TfrmPurInvoiceDetail.SelectedVatRate: Currency;
begin
  if cbbVatRate.ItemIndex < 0 then
    Result := 0
  else
    Result := StrToCurrDef(cbbVatRate.Items[cbbVatRate.ItemIndex], 0);
end;

procedure TfrmPurInvoiceDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPurInvoiceId: TfrmPurInvoices;
  LFrmStkInventoryId: TfrmStkInventories;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtPurInvoiceId.Name then
  begin
    LFrmPurInvoiceId := TfrmPurInvoices.Create(LEdit, TPurInvoiceService.Create, TPurInvoice.Create);
    try
      LFrmPurInvoiceId.IsHelper := True;
      LFrmPurInvoiceId.ShowModal;
      if LFrmPurInvoiceId.DataTransfer then
        if LFrmPurInvoiceId.CleanAndClose then
        begin
          Table.PurInvoiceId := 0;
          Table.InvoiceNo := '';
          Table.Currency := '';
          LEdit.Clear;
        end
        else
        begin
          Table.PurInvoiceId := LFrmPurInvoiceId.Table.Id;
          Table.InvoiceNo := LFrmPurInvoiceId.Table.InvoiceNo;
          Table.Currency := LFrmPurInvoiceId.Table.Currency;
          LEdit.Text := Table.InvoiceNo;
        end;
    finally
      LFrmPurInvoiceId.Free;
    end;
  end
  else if LEdit.Name = edtStkInventoryId.Name then
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
    finally
      LFrmStkInventoryId.Free;
    end;
  end;
end;

// Stok kartının alış fiyatı (belge para biriminde ise), alış iskontosu ve geçerli KDV oranı önerilir
procedure TfrmPurInvoiceDetail.FillInventoryDefaults;
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

procedure TfrmPurInvoiceDetail.RefreshData;
begin
  inherited;
  edtPurInvoiceId.Text := Table.InvoiceNo;
  edtLineNo.Text := IntToStr(Table.LineNo);
  edtStkInventoryId.Text := Table.InventoryName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
  lblUomCode.Caption := Table.UomCode;
  edtUnitPrice.Text := CurrToStr(Table.UnitPrice);
  edtDiscountRate.Text := CurrToStr(Table.DiscountRate);
  SelectVatRate(Table.VatRate);
  edtDescription.Text := Table.Description;
  edtGrossAmount.Text := CurrToStr(Table.GrossAmount);
  edtDiscountAmount.Text := CurrToStr(Table.DiscountAmount);
  edtNetAmount.Text := CurrToStr(Table.NetAmount);
  edtVatAmount.Text := CurrToStr(Table.VatAmount);
  edtTotalAmount.Text := CurrToStr(Table.TotalAmount);
end;

end.
