unit ufrmPurOrderDetail;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  PurOrderDetail.Service, PurOrderDetail;

type
  TfrmPurOrderDetail = class(TfrmInputSimpleDB<TPurOrderDetail, TPurOrderDetailService>)
    pnlContent: TPanel;
    lblPurOrderId: TLabel;
    edtPurOrderId: TEdit;
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
    lblDeliveryDate: TLabel;
    edtDeliveryDate: TEdit;
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
    lblReceivedQuantity: TLabel;
    edtReceivedQuantity: TEdit;
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
  PurOrder, PurOrder.Service, ufrmPurOrders,
  StkInventory, StkInventory.Service, ufrmStkInventories;

procedure TfrmPurOrderDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.LineNo := StrToIntDef(edtLineNo.Text, 0);
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  Table.UnitPrice := StrToCurrDef(edtUnitPrice.Text, 0);
  Table.DiscountRate := StrToCurrDef(edtDiscountRate.Text, 0);
  Table.VatRate := SelectedVatRate;
  Table.DeliveryDate := StrToDateDef(edtDeliveryDate.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmPurOrderDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPurOrderId.OnHelperProcess := HelperProcess;
  edtLineNo.thsInputDataType := itInteger;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
  edtUnitPrice.thsInputDataType := itFloat;
  edtDiscountRate.thsInputDataType := itFloat;
  FillVatRates;
  edtDeliveryDate.thsInputDataType := itDate;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmPurOrderDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtStkInventoryId.CanFocus then
    edtStkInventoryId.SetFocus;
end;

procedure TfrmPurOrderDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.TitleSingular, 'Order Line');
  lblPurOrderId.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColPurOrderId, 'Order');
  lblLineNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColLineNo, 'Line No');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColStkInventoryId, 'Stock Card');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColQuantity, 'Quantity');
  lblUnitPrice.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColUnitPrice, 'Unit Price');
  lblDiscountRate.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColDiscountRate, 'Discount (%)');
  lblVatRate.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColVatRate, 'VAT (%)');
  lblDeliveryDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColDeliveryDate, 'Delivery Date');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColDescription, 'Description');
  lblGrossAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColGrossAmount, 'Gross Amount');
  lblDiscountAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColDiscountAmount, 'Discount Amount');
  lblNetAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColNetAmount, 'Net Amount');
  lblVatAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColVatAmount, 'VAT Amount');
  lblTotalAmount.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColTotalAmount, 'Total');
  lblReceivedQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColReceivedQuantity, 'Received Quantity');
end;

procedure TfrmPurOrderDetail.FillVatRates;
var
  LRate: Currency;
begin
  cbbVatRate.Items.BeginUpdate;
  try
    cbbVatRate.Items.Clear;
    for LRate in Service.GetVatRates do
      cbbVatRate.Items.Add(FormatFloat('0.##', LRate));
  finally
    cbbVatRate.Items.EndUpdate;
  end;
end;

// Listede olmayan oran: kayıtlı satırda gösterilir (kayıtta reddedilir), yeni satırda (0) boş bırakılır
procedure TfrmPurOrderDetail.SelectVatRate(ARate: Currency);
var
  LText: string;
begin
  LText := FormatFloat('0.##', ARate);
  if (cbbVatRate.Items.IndexOf(LText) < 0) and (ARate <> 0) then
    cbbVatRate.Items.Add(LText);
  cbbVatRate.ItemIndex := cbbVatRate.Items.IndexOf(LText);
end;

function TfrmPurOrderDetail.SelectedVatRate: Currency;
begin
  if cbbVatRate.ItemIndex < 0 then
    Result := 0
  else
    Result := StrToCurrDef(cbbVatRate.Items[cbbVatRate.ItemIndex], 0);
end;

procedure TfrmPurOrderDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPurOrderId: TfrmPurOrders;
  LFrmStkInventoryId: TfrmStkInventories;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtPurOrderId.Name then
  begin
    LFrmPurOrderId := TfrmPurOrders.Create(LEdit, TPurOrderService.Create, TPurOrder.Create);
    try
      LFrmPurOrderId.IsHelper := True;
      LFrmPurOrderId.ShowModal;
      if LFrmPurOrderId.DataTransfer then
        if LFrmPurOrderId.CleanAndClose then
        begin
          Table.PurOrderId := 0;
          Table.OrderNo := '';
          Table.Currency := '';
          LEdit.Clear;
        end
        else
        begin
          Table.PurOrderId := LFrmPurOrderId.Table.Id;
          Table.OrderNo := LFrmPurOrderId.Table.OrderNo;
          Table.Currency := LFrmPurOrderId.Table.Currency;
          LEdit.Text := Table.OrderNo;
        end;
    finally
      LFrmPurOrderId.Free;
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
procedure TfrmPurOrderDetail.FillInventoryDefaults;
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

procedure TfrmPurOrderDetail.RefreshData;
begin
  inherited;
  edtPurOrderId.Text := Table.OrderNo;
  edtLineNo.Text := IntToStr(Table.LineNo);
  edtStkInventoryId.Text := Table.InventoryName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
  lblUomCode.Caption := Table.UomCode;
  edtUnitPrice.Text := CurrToStr(Table.UnitPrice);
  edtDiscountRate.Text := CurrToStr(Table.DiscountRate);
  SelectVatRate(Table.VatRate);
  if Table.DeliveryDate > 0 then
    edtDeliveryDate.Text := DateToStr(Table.DeliveryDate)
  else
    edtDeliveryDate.Text := '';
  edtDescription.Text := Table.Description;
  edtGrossAmount.Text := CurrToStr(Table.GrossAmount);
  edtDiscountAmount.Text := CurrToStr(Table.DiscountAmount);
  edtNetAmount.Text := CurrToStr(Table.NetAmount);
  edtVatAmount.Text := CurrToStr(Table.VatAmount);
  edtTotalAmount.Text := CurrToStr(Table.TotalAmount);
  edtReceivedQuantity.Text := CurrToStr(Table.ReceivedQuantity);
end;

end.
