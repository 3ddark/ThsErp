unit ufrmSlsOrderDetail;

// Satış siparişi: başlık (sls_order) + kalemler (Table.Lines, sls_order_detail) tek ekranda. Kalemler bellekte sipariş
// servisiyle eklenir / değişir / çıkar (satır formu TfrmSlsOrderLine); Onayla Service.BusinessSaveWithDetails ile
// başlık ve kalemleri tek transaction'da yazar. Başlık onaylı siparişte de değişebilir; kalemler yalnız taslakta.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.Generics.Collections,
  ufrmInputDetailedDB, Detail.Lines, Detail.Totals, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SlsOrder.Service, SlsOrder, SlsOrderDetail.Service, SlsOrderDetail;

type
  TfrmSlsOrderDetail = class(TfrmInputDetailedDB<TSlsOrder, TSlsOrderService>)
    pnlContent: TPanel;
    lblOrderNo: TLabel;
    edtOrderNo: TEdit;
    lblOrderDate: TLabel;
    edtOrderDate: TEdit;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblCustomerRefNo: TLabel;
    edtCustomerRefNo: TEdit;
    lblDeliveryDate: TLabel;
    edtDeliveryDate: TEdit;
    lblStkWarehouseId: TLabel;
    edtStkWarehouseId: TEdit;
    lblEmpEmployeeId: TLabel;
    edtEmpEmployeeId: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
    lblExchangeRate: TLabel;
    edtExchangeRate: TEdit;
    lblPaymentTermDays: TLabel;
    edtPaymentTermDays: TEdit;
    lblStatusText: TLabel;
    edtStatusText: TEdit;
    pnlTotals: TPanel;
    lblDescription: TLabel;
    edtDescription: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FTotals: TTotalsPanel;
    FPageLines: TTabSheet;
    FLines: TDetailSet<TSlsOrderDetail>;
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
  SlsLookup, Grid.Types, ufrmSlsOrderLine,
  AccAccount, AccAccount.Service, ufrmAccAccounts,        // TfrmAccAccounts helper output form
  StkWarehouse, StkWarehouse.Service, ufrmStkWarehouses,  // TfrmStkWarehouses helper output form
  EmpEmployee, EmpEmployee.Service, ufrmEmpEmployees,     // TfrmEmpEmployees helper output form
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;    // TfrmSysCurrencies helper output form

procedure TfrmSlsOrderDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.OrderNo := edtOrderNo.Text;
  Table.OrderDate := StrToDateDef(edtOrderDate.Text, 0);
  Table.CustomerRefNo := edtCustomerRefNo.Text;
  Table.DeliveryDate := StrToDateDef(edtDeliveryDate.Text, 0);
  Table.ExchangeRate := StrToCurrDef(edtExchangeRate.Text, 0);
  Table.PaymentTermDays := StrToIntDef(edtPaymentTermDays.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmSlsOrderDetail.FormCreate(Sender: TObject);
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
  edtCustomerRefNo.thsInputDataType := itString;
  edtDeliveryDate.thsInputDataType := itDate;
  edtStkWarehouseId.OnHelperProcess := HelperProcess;
  edtEmpEmployeeId.OnHelperProcess := HelperProcess;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtExchangeRate.thsInputDataType := itFloat;
  edtPaymentTermDays.thsInputDataType := itInteger;
  edtDescription.thsInputDataType := itString;

  // Kalemler = Table.Lines (servis satır no sırasıyla okur); ekle / çıkar / hesap sipariş servisinde,
  // satır formu modal, kayıt siparişle birlikte
  FPageLines := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TSlsOrder.MenuLines, 'Lines'));
  FLines := AddDetail<TSlsOrderDetail>(FPageLines, 'vw_sls_order_detail',
    function: TObjectList<TSlsOrderDetail>
    begin
      Result := Table.Lines;
    end,
    function: TSlsOrderDetail
    begin
      Result := Service.CreateLine(Table);
    end,
    procedure(ALine: TSlsOrderDetail)
    begin
      Service.AddLine(Table, ALine);
    end,
    procedure(ALine: TSlsOrderDetail)
    begin
      Service.RemoveLine(Table, ALine);
    end,
    function(ALine: TSlsOrderDetail; AMode: TInputFormMode): TForm
    begin
      Result := TfrmSlsOrderLine.Create(Self, TSlsOrderDetailService.Create, ALine, AMode, nil);
    end);

  FLines.Grid.AddFooterColumn('net_amount', atSum, '#,##0.00');
  FLines.Grid.AddFooterColumn('vat_amount', atSum, '#,##0.00');
  FLines.Grid.AddFooterColumn('total_amount', atSum, '#,##0.00');
  FLines.Grid.BuildData;
  FLines.Grid.SetColumnProperty('id', 0);
  FLines.Grid.SetColumnProperty('sls_order_id', 0);
  FLines.Grid.SetColumnProperty('stk_inventory_id', 0);
  FLines.Grid.SetColumnProperty('sls_offer_detail_id', 0);
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

destructor TfrmSlsOrderDetail.Destroy;
begin
  FreeAndNil(FTotals);
  inherited;
end;

procedure TfrmSlsOrderDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtOrderDate.CanFocus then
    edtOrderDate.SetFocus;
end;

function TfrmSlsOrderDetail.DetailsEditable: Boolean;
begin
  Result := inherited DetailsEditable and Assigned(Table) and (Table.Status = SLS_ORD_DRAFT);
end;

procedure TfrmSlsOrderDetail.ShowTotalValues;
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
procedure TfrmSlsOrderDetail.ShowTotals;
begin
  if not Assigned(Table) then
    Exit;
  Service.Recalculate(Table);
  ShowTotalValues;
end;

procedure TfrmSlsOrderDetail.DetailsChanged;
begin
  inherited;
  ShowTotals;
end;

procedure TfrmSlsOrderDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.TitleSingular, 'Sales Order');
  lblOrderNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColOrderNo, 'Order No');
  lblOrderDate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColOrderDate, 'Order Date');
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColAccAccountId, 'Customer');
  lblCustomerRefNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColCustomerRefNo, 'Customer Order No');
  lblDeliveryDate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColDeliveryDate, 'Delivery Date');
  lblStkWarehouseId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColStkWarehouseId, 'Shipping Warehouse');
  lblEmpEmployeeId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColEmpEmployeeId, 'Sales Representative');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColCurrency, 'Currency');
  lblExchangeRate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColExchangeRate, 'Exchange Rate');
  lblPaymentTermDays.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColPaymentTermDays, 'Payment Term (Days)');
  lblStatusText.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColStatus, 'Status');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColDescription, 'Description');
  if Assigned(FTotals) then
  begin
    FTotals.SetCaption('gross', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColGrossAmount, 'Gross Amount'));
    FTotals.SetCaption('discount', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColDiscountAmount, 'Discount Amount'));
    FTotals.SetCaption('net', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColNetAmount, 'Net Amount'));
    FTotals.SetCaption('vat', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColVatAmount, 'VAT Amount'));
    FTotals.SetCaption('total', TLocalizationManager.Translate(TLangKeys.TSlsOrder.ColTotalAmount, 'Total'));
  end;

  if Assigned(FPageLines) then
    FPageLines.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.MenuLines, 'Lines');
  if Assigned(FLines) then
  begin
    FLines.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColLineNo, 'Line No'));
    FLines.Grid.SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColInventoryCode, 'Stock Code'));
    FLines.Grid.SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColInventoryName, 'Stock Name'));
    FLines.Grid.SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColUomCode, 'Unit'));
    FLines.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColQuantity, 'Quantity'));
    FLines.Grid.SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColUnitPrice, 'Unit Price'));
    FLines.Grid.SetColumnTitle('discount_rate', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColDiscountRate, 'Discount (%)'));
    FLines.Grid.SetColumnTitle('vat_rate', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColVatRate, 'VAT (%)'));
    FLines.Grid.SetColumnTitle('gross_amount', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColGrossAmount, 'Gross Amount'));
    FLines.Grid.SetColumnTitle('discount_amount', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColDiscountAmount, 'Discount Amount'));
    FLines.Grid.SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColNetAmount, 'Net Amount'));
    FLines.Grid.SetColumnTitle('vat_amount', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColVatAmount, 'VAT Amount'));
    FLines.Grid.SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColTotalAmount, 'Total'));
    FLines.Grid.SetColumnTitle('delivered_quantity', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColDeliveredQuantity, 'Delivered Quantity'));
    FLines.Grid.SetColumnTitle('delivery_date', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColDeliveryDate, 'Delivery Date'));
    FLines.Grid.SetColumnTitle('offer_no', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColOfferNo, 'Offer No'));
    FLines.Grid.SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.ColDescription, 'Description'));
  end;
end;

procedure TfrmSlsOrderDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccAccountId: TfrmAccAccounts;
  LFrmStkWarehouseId: TfrmStkWarehouses;
  LFrmEmpEmployeeId: TfrmEmpEmployees;
  LFrmCurrency: TfrmSysCurrencies;
  LLine: TSlsOrderDetail;
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

procedure TfrmSlsOrderDetail.RefreshData;
begin
  inherited;
  edtOrderNo.Text := Table.OrderNo;
  if Table.OrderDate > 0 then
    edtOrderDate.Text := DateToStr(Table.OrderDate)
  else
    edtOrderDate.Text := '';
  edtAccAccountId.Text := Table.AccountName;
  edtCustomerRefNo.Text := Table.CustomerRefNo;
  if Table.DeliveryDate > 0 then
    edtDeliveryDate.Text := DateToStr(Table.DeliveryDate)
  else
    edtDeliveryDate.Text := '';
  edtStkWarehouseId.Text := Table.WarehouseName;
  edtEmpEmployeeId.Text := Table.EmployeeName;
  edtCurrency.Text := Table.Currency;
  edtExchangeRate.Text := CurrToStr(Table.ExchangeRate);
  edtPaymentTermDays.Text := IntToStr(Table.PaymentTermDays);
  edtStatusText.Text := TSlsLookup.Text(slkOrderStatus, Table.Status);
  edtDescription.Text := Table.Description;
  // bellekte kalem varsa toplamlar onlardan
  if Table.Lines.Count > 0 then
    ShowTotals
  else
    ShowTotalValues;
end;

end.
