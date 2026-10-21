unit ufrmPurOrderDetail;

// Satın alma siparişi: başlık (pur_order) + kalemler (Table.Lines, pur_order_detail) tek ekranda. Kalemler bellekte
// sipariş servisiyle eklenir / değişir / çıkar (satır formu TfrmPurOrderLine); Onayla Service.BusinessSaveWithDetails
// ile başlık ve kalemleri tek transaction'da yazar. Başlık onaylı siparişte de değişebilir; kalemler yalnız taslakta.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.Generics.Collections,
  ufrmInputDetailedDB, Detail.Lines, Detail.Totals, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  PurOrder.Service, PurOrder, PurOrderDetail.Service, PurOrderDetail;

type
  TfrmPurOrderDetail = class(TfrmInputDetailedDB<TPurOrder, TPurOrderService>)
    pnlContent: TPanel;
    lblOrderNo: TLabel;
    edtOrderNo: TEdit;
    lblOrderDate: TLabel;
    edtOrderDate: TEdit;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblSupplierRefNo: TLabel;
    edtSupplierRefNo: TEdit;
    lblDeliveryDate: TLabel;
    edtDeliveryDate: TEdit;
    lblStkWarehouseId: TLabel;
    edtStkWarehouseId: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
    lblExchangeRate: TLabel;
    edtExchangeRate: TEdit;
    lblPaymentTermDays: TLabel;
    edtPaymentTermDays: TEdit;
    lblStatusText: TLabel;
    edtStatusText: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    pnlTotals: TPanel;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FTotals: TTotalsPanel;
    FPageLines: TTabSheet;
    FLines: TDetailSet<TPurOrderDetail>;
    procedure ShowTotals;
    // Table toplamları panelde (para birimiyle)
    procedure ShowTotalValues;
  protected
    procedure DetailsChanged; override;
    // kalemler yalnız taslak siparişte değişir (başlık onaylıda da düzenlenebilir)
    function DetailsEditable: Boolean; override;
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
  PurLookup, Grid.Types, ufrmPurOrderLine,
  AccAccount, AccAccount.Service, ufrmAccAccounts,        // TfrmAccAccounts helper output form
  StkWarehouse, StkWarehouse.Service, ufrmStkWarehouses,  // TfrmStkWarehouses helper output form
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;    // TfrmSysCurrencies helper output form

procedure TfrmPurOrderDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.OrderNo := edtOrderNo.Text;
  Table.OrderDate := StrToDateDef(edtOrderDate.Text, 0);
  Table.SupplierRefNo := edtSupplierRefNo.Text;
  Table.DeliveryDate := StrToDateDef(edtDeliveryDate.Text, 0);
  Table.ExchangeRate := StrToCurrDef(edtExchangeRate.Text, 0);
  Table.PaymentTermDays := StrToIntDef(edtPaymentTermDays.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmPurOrderDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  FTotals := TTotalsPanel.Create(pnlTotals);
  FTotals.AddRow('gross');
  FTotals.AddRow('discount');
  FTotals.AddRow('net');
  FTotals.AddRow('vat');
  FTotals.AddRow('total', True);
  pnlTotals.Height := FTotals.RequiredHeight;

  edtOrderNo.thsInputDataType := itString;
  edtOrderNo.CharCase := TEditCharCase.ecUpperCase;
  edtOrderDate.thsInputDataType := itDate;
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtSupplierRefNo.thsInputDataType := itString;
  edtDeliveryDate.thsInputDataType := itDate;
  edtStkWarehouseId.OnHelperProcess := HelperProcess;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtExchangeRate.thsInputDataType := itFloat;
  edtExchangeRate.thsDecimalDigitCount := TDecimalPlaces.ExchangeRate;
  edtPaymentTermDays.thsInputDataType := itInteger;
  edtDescription.thsInputDataType := itString;

  // Kalemler = Table.Lines (servis satır no sırasıyla okur); ekle / çıkar / hesap sipariş servisinde,
  // satır formu modal, kayıt siparişle birlikte
  FPageLines := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TPurOrder.MenuLines, 'Lines'));
  FLines := AddDetail<TPurOrderDetail>(FPageLines, 'vw_pur_order_detail',
    function: TObjectList<TPurOrderDetail>
    begin
      Result := Table.Lines;
    end,
    function: TPurOrderDetail
    begin
      Result := Service.CreateLine(Table);
    end,
    procedure(ALine: TPurOrderDetail)
    begin
      Service.AddLine(Table, ALine);
    end,
    procedure(ALine: TPurOrderDetail)
    begin
      Service.RemoveLine(Table, ALine);
    end,
    function(ALine: TPurOrderDetail; AMode: TInputFormMode): TForm
    begin
      Result := TfrmPurOrderLine.Create(Self, TPurOrderDetailService.Create, ALine, AMode, nil);
    end);

  FLines.Grid.AddFooterColumn('net_amount', atSum, TDecimalPlaces.TotalFormat);
  FLines.Grid.AddFooterColumn('vat_amount', atSum, TDecimalPlaces.TotalFormat);
  FLines.Grid.AddFooterColumn('total_amount', atSum, TDecimalPlaces.TotalFormat);
  FLines.Grid.BuildData;
  FLines.Grid.SetColumnProperty('id', 0);
  FLines.Grid.SetColumnProperty('pur_order_id', 0);
  FLines.Grid.SetColumnProperty('stk_inventory_id', 0);
  FLines.Grid.SetColumnProperty('pur_request_detail_id', 0);
  FLines.Grid.SetColumnProperty('order_no', 0);
  FLines.Grid.SetColumnProperty('currency', 0);
  FLines.Grid.SetColumnProperty('gross_amount', 0);
  FLines.Grid.SetColumnProperty('discount_amount', 0);
  FLines.Grid.SetColumnProperty('line_no', 50);
  FLines.Grid.SetColumnProperty('inventory_code', 90);
  FLines.Grid.SetColumnProperty('inventory_name', 200);
  FLines.Grid.SetColumnProperty('uom_code', 50);
  FLines.Grid.SetColumnProperty('description', 160);
end;

destructor TfrmPurOrderDetail.Destroy;
begin
  FreeAndNil(FTotals);
  inherited;
end;

procedure TfrmPurOrderDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtOrderDate.CanFocus then
    edtOrderDate.SetFocus;
end;

function TfrmPurOrderDetail.DetailsEditable: Boolean;
begin
  Result := inherited DetailsEditable and Assigned(Table) and (Table.Status = PUR_ORD_DRAFT);
end;

procedure TfrmPurOrderDetail.ShowTotalValues;
begin
  if not Assigned(FTotals) or not Assigned(Table) then
    Exit;
  FTotals.SetValue('gross', Table.GrossAmount, Table.Currency);
  FTotals.SetValue('discount', Table.DiscountAmount, Table.Currency);
  FTotals.SetValue('net', Table.NetAmount, Table.Currency);
  FTotals.SetValue('vat', Table.VatAmount, Table.Currency);
  FTotals.SetValue('total', Table.TotalAmount, Table.Currency);
end;

// Başlık toplamları: servis kalemlerden hesaplar (kayıtta yine aynı hesap)
procedure TfrmPurOrderDetail.ShowTotals;
begin
  if not Assigned(Table) then
    Exit;
  Service.Recalculate(Table);
  ShowTotalValues;
end;

procedure TfrmPurOrderDetail.DetailsChanged;
begin
  inherited;
  ShowTotals;
end;

procedure TfrmPurOrderDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.TitleSingular, 'Purchase Order');
  lblOrderNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColOrderNo, 'Order No');
  lblOrderDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColOrderDate, 'Order Date');
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColAccAccountId, 'Supplier');
  lblSupplierRefNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColSupplierRefNo, 'Supplier Ref No');
  lblDeliveryDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColDeliveryDate, 'Delivery Date');
  lblStkWarehouseId.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColStkWarehouseId, 'Warehouse');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColCurrency, 'Currency');
  lblExchangeRate.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColExchangeRate, 'Exchange Rate');
  lblPaymentTermDays.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColPaymentTermDays, 'Payment Term (Days)');
  lblStatusText.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColStatus, 'Status');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.ColDescription, 'Description');
  if Assigned(FTotals) then
  begin
    FTotals.SetCaption('gross', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColGrossAmount, 'Gross Amount'));
    FTotals.SetCaption('discount', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColDiscountAmount, 'Discount Amount'));
    FTotals.SetCaption('net', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColNetAmount, 'Net Amount'));
    FTotals.SetCaption('vat', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColVatAmount, 'VAT Amount'));
    FTotals.SetCaption('total', TLocalizationManager.Translate(TLangKeys.TPurOrder.ColTotalAmount, 'Total'));
  end;

  if Assigned(FPageLines) then
    FPageLines.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.MenuLines, 'Lines');
  if Assigned(FLines) then
  begin
    FLines.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColLineNo, 'Line No'));
    FLines.Grid.SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColInventoryCode, 'Stock Code'));
    FLines.Grid.SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColInventoryName, 'Stock Name'));
    FLines.Grid.SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColUomCode, 'Unit'));
    FLines.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColQuantity, 'Quantity'));
    FLines.Grid.SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColUnitPrice, 'Unit Price'));
    FLines.Grid.SetColumnTitle('discount_rate', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColDiscountRate, 'Discount (%)'));
    FLines.Grid.SetColumnTitle('vat_rate', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColVatRate, 'VAT (%)'));
    FLines.Grid.SetColumnTitle('gross_amount', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColGrossAmount, 'Gross Amount'));
    FLines.Grid.SetColumnTitle('discount_amount', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColDiscountAmount, 'Discount Amount'));
    FLines.Grid.SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColNetAmount, 'Net Amount'));
    FLines.Grid.SetColumnTitle('vat_amount', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColVatAmount, 'VAT Amount'));
    FLines.Grid.SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColTotalAmount, 'Total'));
    FLines.Grid.SetColumnTitle('received_quantity', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColReceivedQuantity, 'Received Quantity'));
    FLines.Grid.SetColumnTitle('remaining_quantity', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColRemainingQuantity, 'Remaining'));
    FLines.Grid.SetColumnTitle('delivery_date', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColDeliveryDate, 'Delivery Date'));
    FLines.Grid.SetColumnTitle('request_no', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColRequestNo, 'Request No'));
    FLines.Grid.SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.ColDescription, 'Description'));
  end;
end;

procedure TfrmPurOrderDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccAccountId: TfrmAccAccounts;
  LFrmStkWarehouseId: TfrmStkWarehouses;
  LFrmCurrency: TfrmSysCurrencies;
  LLine: TPurOrderDetail;
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
        end;
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
  end;
end;

procedure TfrmPurOrderDetail.RefreshData;
begin
  inherited;
  edtOrderNo.Text := Table.OrderNo;
  if Table.OrderDate > 0 then
    edtOrderDate.Text := DateToStr(Table.OrderDate)
  else
    edtOrderDate.Text := '';
  edtAccAccountId.Text := Table.AccountName;
  edtSupplierRefNo.Text := Table.SupplierRefNo;
  if Table.DeliveryDate > 0 then
    edtDeliveryDate.Text := DateToStr(Table.DeliveryDate)
  else
    edtDeliveryDate.Text := '';
  edtStkWarehouseId.Text := Table.WarehouseName;
  edtCurrency.Text := Table.Currency;
  edtExchangeRate.Text := CurrToStr(Table.ExchangeRate);
  edtPaymentTermDays.Text := IntToStr(Table.PaymentTermDays);
  edtStatusText.Text := TPurLookup.Text(plkOrderStatus, Table.Status);
  edtDescription.Text := Table.Description;
  // bellekte kalem varsa toplamlar onlardan
  if Table.Lines.Count > 0 then
    ShowTotals
  else
    ShowTotalValues;
end;

end.
