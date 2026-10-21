unit ufrmPurReceiptDetail;

// Mal kabul: başlık (pur_receipt) + kalemler (Table.Lines, pur_receipt_detail) tek ekranda. Kalemler bellekte mal kabul
// servisiyle eklenir / değişir / çıkar (satır formu TfrmPurReceiptLine); Onayla Service.BusinessSaveWithDetails ile
// başlık, kalemler ve stok giriş hareketlerini tek transaction'da yazar. Faturalanan kalem silinemez / azaltılamaz.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.Generics.Collections,
  ufrmInputDetailedDB, Detail.Lines, Detail.Totals, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  PurReceipt.Service, PurReceipt, PurReceiptDetail.Service, PurReceiptDetail;

type
  TfrmPurReceiptDetail = class(TfrmInputDetailedDB<TPurReceipt, TPurReceiptService>)
    pnlContent: TPanel;
    lblReceiptNo: TLabel;
    edtReceiptNo: TEdit;
    lblReceiptDate: TLabel;
    edtReceiptDate: TEdit;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblStkWarehouseId: TLabel;
    edtStkWarehouseId: TEdit;
    lblWaybillNo: TLabel;
    edtWaybillNo: TEdit;
    lblPurOrderId: TLabel;
    edtPurOrderId: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    pnlTotals: TPanel;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FTotals: TTotalsPanel;
    FPageLines: TTabSheet;
    FLines: TDetailSet<TPurReceiptDetail>;
    procedure ShowTotals;
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
  SysDecimalPlace.Cache,
  Grid.Types, ufrmPurReceiptLine,
  AccAccount, AccAccount.Service, ufrmAccAccounts,        // TfrmAccAccounts helper output form
  StkWarehouse, StkWarehouse.Service, ufrmStkWarehouses,  // TfrmStkWarehouses helper output form
  PurOrder, PurOrder.Service, ufrmPurOrders,              // TfrmPurOrders helper output form
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;    // TfrmSysCurrencies helper output form

const
  ROW_TOTAL = 'total';

procedure TfrmPurReceiptDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.ReceiptNo := edtReceiptNo.Text;
  Table.ReceiptDate := StrToDateDef(edtReceiptDate.Text, 0);
  Table.WaybillNo := edtWaybillNo.Text;
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmPurReceiptDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  FTotals := TTotalsPanel.Create(pnlTotals);
  FTotals.AddRow(ROW_TOTAL, True);
  pnlTotals.Height := FTotals.RequiredHeight;

  edtReceiptNo.thsInputDataType := itString;
  edtReceiptNo.CharCase := TEditCharCase.ecUpperCase;
  edtReceiptDate.thsInputDataType := itDate;
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtStkWarehouseId.OnHelperProcess := HelperProcess;
  edtWaybillNo.thsInputDataType := itString;
  edtWaybillNo.CharCase := TEditCharCase.ecUpperCase;
  edtPurOrderId.OnHelperProcess := HelperProcess;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtDescription.thsInputDataType := itString;

  // Kalemler = Table.Lines (servis satır no sırasıyla okur); ekle / çıkar mal kabul servisinde,
  // satır formu modal, kayıt mal kabulle birlikte (stok hareketleri dahil)
  FPageLines := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TPurReceipt.MenuLines, 'Lines'));
  FLines := AddDetail<TPurReceiptDetail>(FPageLines, 'vw_pur_receipt_detail',
    function: TObjectList<TPurReceiptDetail>
    begin
      Result := Table.Lines;
    end,
    function: TPurReceiptDetail
    begin
      Result := Service.CreateLine(Table);
    end,
    procedure(ALine: TPurReceiptDetail)
    begin
      Service.AddLine(Table, ALine);
    end,
    procedure(ALine: TPurReceiptDetail)
    begin
      Service.RemoveLine(Table, ALine);
    end,
    function(ALine: TPurReceiptDetail; AMode: TInputFormMode): TForm
    begin
      Result := TfrmPurReceiptLine.Create(Self, TPurReceiptDetailService.Create, ALine, AMode, nil);
    end);

  FLines.Grid.AddFooterColumn('amount', atSum, TDecimalPlaces.TotalFormat);
  FLines.Grid.BuildData;
  FLines.Grid.SetColumnProperty('id', 0);
  FLines.Grid.SetColumnProperty('pur_receipt_id', 0);
  FLines.Grid.SetColumnProperty('stk_inventory_id', 0);
  FLines.Grid.SetColumnProperty('pur_order_detail_id', 0);
  FLines.Grid.SetColumnProperty('receipt_no', 0);
  FLines.Grid.SetColumnProperty('currency', 0);
  FLines.Grid.SetColumnProperty('line_no', 50);
  FLines.Grid.SetColumnProperty('inventory_code', 90);
  FLines.Grid.SetColumnProperty('inventory_name', 200);
  FLines.Grid.SetColumnProperty('uom_code', 50);
  FLines.Grid.SetColumnProperty('description', 160);
end;

destructor TfrmPurReceiptDetail.Destroy;
begin
  FreeAndNil(FTotals);
  inherited;
end;

procedure TfrmPurReceiptDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtReceiptDate.CanFocus then
    edtReceiptDate.SetFocus;
end;

// Toplam: aktif kalemlerin tutarları (servis hesaplar)
procedure TfrmPurReceiptDetail.ShowTotals;
begin
  if not Assigned(FTotals) or not Assigned(Table) then
    Exit;
  Service.Recalculate(Table);
  FTotals.SetValue(ROW_TOTAL, Service.TotalAmount(Table), Table.Currency);
end;

procedure TfrmPurReceiptDetail.DetailsChanged;
begin
  inherited;
  ShowTotals;
end;

procedure TfrmPurReceiptDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.TitleSingular, 'Goods Receipt');
  lblReceiptNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColReceiptNo, 'Receipt No');
  lblReceiptDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColReceiptDate, 'Receipt Date');
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColAccAccountId, 'Supplier');
  lblStkWarehouseId.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColStkWarehouseId, 'Warehouse');
  lblWaybillNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColWaybillNo, 'Waybill No');
  lblPurOrderId.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColPurOrderId, 'Order');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColCurrency, 'Currency');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColDescription, 'Description');
  if Assigned(FTotals) then
    FTotals.SetCaption(ROW_TOTAL, TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColTotalAmount, 'Total'));

  if Assigned(FPageLines) then
    FPageLines.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.MenuLines, 'Lines');
  if Assigned(FLines) then
  begin
    FLines.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColLineNo, 'Line No'));
    FLines.Grid.SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColInventoryCode, 'Stock Code'));
    FLines.Grid.SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColInventoryName, 'Stock Name'));
    FLines.Grid.SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColUomCode, 'Unit'));
    FLines.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColQuantity, 'Quantity'));
    FLines.Grid.SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColUnitPrice, 'Unit Cost'));
    FLines.Grid.SetColumnTitle('amount', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColAmount, 'Amount'));
    FLines.Grid.SetColumnTitle('order_no', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColOrderNo, 'Order No'));
    FLines.Grid.SetColumnTitle('order_line_no', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColOrderLineNo, 'Order Line'));
    FLines.Grid.SetColumnTitle('invoiced_quantity', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColInvoicedQuantity, 'Invoiced Quantity'));
    FLines.Grid.SetColumnTitle('remaining_invoice_quantity', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColRemainingInvoiceQuantity, 'Not Invoiced'));
    FLines.Grid.SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColDescription, 'Description'));
  end;
end;

procedure TfrmPurReceiptDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccAccountId: TfrmAccAccounts;
  LFrmStkWarehouseId: TfrmStkWarehouses;
  LFrmPurOrderId: TfrmPurOrders;
  LFrmCurrency: TfrmSysCurrencies;
  LLine: TPurReceiptDetail;
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
  else if LEdit.Name = edtPurOrderId.Name then
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
          LEdit.Clear;
        end
        else
        begin
          Table.PurOrderId := LFrmPurOrderId.Table.Id;
          Table.OrderNo := LFrmPurOrderId.Table.OrderNo;
          LEdit.Text := Table.OrderNo;
        end;
      // Sipariş seçilince tedarikçi / ambar / para birimi siparişten gelir
      if LFrmPurOrderId.DataTransfer and not LFrmPurOrderId.CleanAndClose then
      begin
        Table.AccAccountId := LFrmPurOrderId.Table.AccAccountId;
        Table.AccountName := LFrmPurOrderId.Table.AccountName;
        edtAccAccountId.Text := Table.AccountName;
        Table.Currency := LFrmPurOrderId.Table.Currency;
        edtCurrency.Text := Table.Currency;
        for LLine in Table.Lines do
          LLine.Currency := Table.Currency;
        if LFrmPurOrderId.Table.StkWarehouseId > 0 then
        begin
          Table.StkWarehouseId := LFrmPurOrderId.Table.StkWarehouseId;
          Table.WarehouseName := LFrmPurOrderId.Table.WarehouseName;
          edtStkWarehouseId.Text := Table.WarehouseName;
        end;
        ShowTotals;
      end;
    finally
      LFrmPurOrderId.Free;
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
      // kalemlerin para birimi (gösterim) belgeyle aynı
      for LLine in Table.Lines do
        LLine.Currency := Table.Currency;
      ShowTotals;
    finally
      LFrmCurrency.Free;
    end;
  end;
end;

procedure TfrmPurReceiptDetail.RefreshData;
begin
  inherited;
  edtReceiptNo.Text := Table.ReceiptNo;
  if Table.ReceiptDate > 0 then
    edtReceiptDate.Text := DateToStr(Table.ReceiptDate)
  else
    edtReceiptDate.Text := '';
  edtAccAccountId.Text := Table.AccountName;
  edtStkWarehouseId.Text := Table.WarehouseName;
  edtWaybillNo.Text := Table.WaybillNo;
  edtPurOrderId.Text := Table.OrderNo;
  edtCurrency.Text := Table.Currency;
  edtDescription.Text := Table.Description;
  ShowTotals;
end;

end.
