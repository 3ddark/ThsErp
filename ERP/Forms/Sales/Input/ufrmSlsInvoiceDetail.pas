unit ufrmSlsInvoiceDetail;

// Satış faturası: başlık (sls_invoice) + kalemler (Table.Lines, sls_invoice_detail) tek ekranda. Kalemler bellekte fatura
// servisiyle eklenir / değişir / çıkar (satır formu TfrmSlsInvoiceLine); Onayla Service.BusinessSaveWithDetails ile
// başlık ve kalemleri (irsaliyesiz kalemlerin stok hareketleri dahil) tek transaction'da yazar.
// Durum ve e-Fatura alanları resmi dokümanlarla eklenecek.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.Generics.Collections,
  ufrmInputDetailedDB, Detail.Lines, Detail.Totals, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SlsInvoice.Service, SlsInvoice, SlsInvoiceDetail.Service, SlsInvoiceDetail;

type
  TfrmSlsInvoiceDetail = class(TfrmInputDetailedDB<TSlsInvoice, TSlsInvoiceService>)
    pnlContent: TPanel;
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
    procedure ShowTotals;
    procedure ShowTotalValues;
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
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;

procedure TfrmSlsInvoiceDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.InvoiceNo := edtInvoiceNo.Text;
  Table.InvoiceDate := StrToDateDef(edtInvoiceDate.Text, 0);
  Table.DueDate := StrToDateDef(edtDueDate.Text, 0);
  Table.ExchangeRate := StrToCurrDef(edtExchangeRate.Text, 0);
  Table.Description := edtDescription.Text;
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
  pnlTotals.Height := FTotals.RequiredHeight;

  edtInvoiceNo.thsInputDataType := itString;
  edtInvoiceNo.CharCase := TEditCharCase.ecUpperCase;
  edtInvoiceDate.thsInputDataType := itDate;
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtDueDate.thsInputDataType := itDate;
  edtStkWarehouseId.OnHelperProcess := HelperProcess;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtExchangeRate.thsInputDataType := itFloat;
  edtDescription.thsInputDataType := itString;

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
  end;

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
  end;
end;

procedure TfrmSlsInvoiceDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccAccountId: TfrmAccAccounts;
  LFrmStkWarehouseId: TfrmStkWarehouses;
  LFrmCurrency: TfrmSysCurrencies;
  LLine: TSlsInvoiceDetail;
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
  if Table.Lines.Count > 0 then
    ShowTotals
  else
    ShowTotalValues;
end;

end.
