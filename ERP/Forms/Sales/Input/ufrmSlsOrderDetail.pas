unit ufrmSlsOrderDetail;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SlsOrderDetail.Service, SlsOrderDetail;

type
  TfrmSlsOrderDetail = class(TfrmInputSimpleDB<TSlsOrderDetail, TSlsOrderDetailService>)
    pnlContent: TPanel;
    lblSlsOrderId: TLabel;
    edtSlsOrderId: TEdit;
    lblLineNo: TLabel;
    edtLineNo: TEdit;
    lblStkInventoryId: TLabel;
    edtStkInventoryId: TEdit;
    lblQuantity: TLabel;
    edtQuantity: TEdit;
    lblUnitPrice: TLabel;
    edtUnitPrice: TEdit;
    lblDiscountRate: TLabel;
    edtDiscountRate: TEdit;
    lblVatRate: TLabel;
    edtVatRate: TEdit;
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
    lblDeliveredQuantity: TLabel;
    edtDeliveredQuantity: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure FillInventoryDefaults;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SlsLookup,
  SlsOrder, SlsOrder.Service, ufrmSlsOrders,
  StkInventory, StkInventory.Service, ufrmStkInventories;

procedure TfrmSlsOrderDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.LineNo := StrToIntDef(edtLineNo.Text, 0);
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  Table.UnitPrice := StrToCurrDef(edtUnitPrice.Text, 0);
  Table.DiscountRate := StrToCurrDef(edtDiscountRate.Text, 0);
  Table.VatRate := StrToCurrDef(edtVatRate.Text, 0);
  Table.DeliveryDate := StrToDateDef(edtDeliveryDate.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmSlsOrderDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtSlsOrderId.OnHelperProcess := HelperProcess;
  edtLineNo.thsInputDataType := itInteger;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
  edtUnitPrice.thsInputDataType := itFloat;
  edtDiscountRate.thsInputDataType := itFloat;
  edtVatRate.thsInputDataType := itFloat;
  edtDeliveryDate.thsInputDataType := itDate;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmSlsOrderDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtStkInventoryId.CanFocus then
    edtStkInventoryId.SetFocus;
end;

procedure TfrmSlsOrderDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.TitleSingular, 'Order Line');
  lblSlsOrderId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColSlsOrderId, 'Order');
  lblLineNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColLineNo, 'Line No');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColStkInventoryId, 'Stock Card');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColQuantity, 'Quantity');
  lblUnitPrice.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColUnitPrice, 'Unit Price');
  lblDiscountRate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColDiscountRate, 'Discount (%)');
  lblVatRate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColVatRate, 'VAT (%)');
  lblDeliveryDate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColDeliveryDate, 'Delivery Date');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColDescription, 'Description');
  lblGrossAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColGrossAmount, 'Gross Amount');
  lblDiscountAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColDiscountAmount, 'Discount Amount');
  lblNetAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColNetAmount, 'Net Amount');
  lblVatAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColVatAmount, 'VAT Amount');
  lblTotalAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColTotalAmount, 'Total');
  lblDeliveredQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColDeliveredQuantity, 'Delivered Quantity');
end;

procedure TfrmSlsOrderDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmSlsOrderId: TfrmSlsOrders;
  LFrmStkInventoryId: TfrmStkInventories;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtSlsOrderId.Name then
  begin
    LFrmSlsOrderId := TfrmSlsOrders.Create(LEdit, TSlsOrderService.Create, TSlsOrder.Create);
    try
      LFrmSlsOrderId.IsHelper := True;
      LFrmSlsOrderId.ShowModal;
      if LFrmSlsOrderId.DataTransfer then
        if LFrmSlsOrderId.CleanAndClose then
        begin
          Table.SlsOrderId := 0;
          Table.OrderNo := '';
          Table.Currency := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SlsOrderId := LFrmSlsOrderId.Table.Id;
          Table.OrderNo := LFrmSlsOrderId.Table.OrderNo;
          Table.Currency := LFrmSlsOrderId.Table.Currency;
          LEdit.Text := Table.OrderNo;
        end;
    finally
      LFrmSlsOrderId.Free;
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
          LEdit.Clear;
        end
        else
        begin
          Table.StkInventoryId := LFrmStkInventoryId.Table.Id;
          Table.InventoryCode := LFrmStkInventoryId.Table.Code;
          Table.InventoryName := LFrmStkInventoryId.Table.Name;
          LEdit.Text := Table.InventoryName;
        end;
      if LFrmStkInventoryId.DataTransfer and not LFrmStkInventoryId.CleanAndClose then
        FillInventoryDefaults;
    finally
      LFrmStkInventoryId.Free;
    end;
  end;
end;

// Stok kartının satış fiyatı (belge para biriminde ise), satış iskontosu ve geçerli KDV oranı önerilir
procedure TfrmSlsOrderDetail.FillInventoryDefaults;
var
  LPrice, LDiscount, LVat: Currency;
  LCurrency: string;
begin
  if not Service.GetInventoryDefaults(Table.StkInventoryId, LPrice, LCurrency, LDiscount, LVat) then
    Exit;
  if (Table.Currency = '') or (LCurrency = Table.Currency) then
    edtUnitPrice.Text := CurrToStr(LPrice);
  edtDiscountRate.Text := CurrToStr(LDiscount);
  edtVatRate.Text := CurrToStr(LVat);
end;

procedure TfrmSlsOrderDetail.RefreshData;
begin
  inherited;
  edtSlsOrderId.Text := Table.OrderNo;
  edtLineNo.Text := IntToStr(Table.LineNo);
  edtStkInventoryId.Text := Table.InventoryName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
  edtUnitPrice.Text := CurrToStr(Table.UnitPrice);
  edtDiscountRate.Text := CurrToStr(Table.DiscountRate);
  edtVatRate.Text := CurrToStr(Table.VatRate);
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
  edtDeliveredQuantity.Text := CurrToStr(Table.DeliveredQuantity);
end;

end.
