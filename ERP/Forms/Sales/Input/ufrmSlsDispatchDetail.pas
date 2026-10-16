unit ufrmSlsDispatchDetail;

// Sevk irsaliyesi: başlık (sls_dispatch) + kalemler (Table.Lines, sls_dispatch_detail) tek ekranda. Kalemler bellekte
// irsaliye servisiyle eklenir / değişir / çıkar (satır formu TfrmSlsDispatchLine); Onayla Service.BusinessSaveWithDetails
// ile başlık ve kalemleri (stok çıkış hareketleri dahil) tek transaction'da yazar. Durum (bekliyor / kapandı)
// faturalardan, servis tutar; faturalanan kalem silinemez / azaltılamaz.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.Generics.Collections,
  ufrmInputDetailedDB, Detail.Lines, Detail.Totals, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SlsDispatch.Service, SlsDispatch, SlsDispatchDetail.Service, SlsDispatchDetail;

type
  TfrmSlsDispatchDetail = class(TfrmInputDetailedDB<TSlsDispatch, TSlsDispatchService>)
    pnlContent: TPanel;
    lblDispatchNo: TLabel;
    edtDispatchNo: TEdit;
    lblDispatchDate: TLabel;
    edtDispatchDate: TEdit;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblStkWarehouseId: TLabel;
    edtStkWarehouseId: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
    lblSlsOrderId: TLabel;
    edtSlsOrderId: TEdit;
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
    FLines: TDetailSet<TSlsDispatchDetail>;
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
  SlsLookup, Grid.Types, ufrmSlsDispatchLine,
  AccAccount, AccAccount.Service, ufrmAccAccounts,
  StkWarehouse, StkWarehouse.Service, ufrmStkWarehouses,
  SlsOrder, SlsOrder.Service, ufrmSlsOrders,
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;

procedure TfrmSlsDispatchDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.DispatchNo := edtDispatchNo.Text;
  Table.DispatchDate := StrToDateDef(edtDispatchDate.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmSlsDispatchDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  FTotals := TTotalsPanel.Create(pnlTotals);
  FTotals.AddRow('total', True);
  pnlTotals.Height := FTotals.RequiredHeight;

  edtDispatchNo.thsInputDataType := itString;
  edtDispatchNo.CharCase := TEditCharCase.ecUpperCase;
  edtDispatchDate.thsInputDataType := itDate;
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtStkWarehouseId.OnHelperProcess := HelperProcess;
  edtSlsOrderId.OnHelperProcess := HelperProcess;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtDescription.thsInputDataType := itString;

  // Kalemler = Table.Lines (servis satır no sırasıyla okur); ekle / çıkar / hesap irsaliye servisinde
  FPageLines := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TSlsDispatch.MenuLines, 'Lines'));
  FLines := AddDetail<TSlsDispatchDetail>(FPageLines, 'vw_sls_dispatch_detail',
    function: TObjectList<TSlsDispatchDetail>
    begin
      Result := Table.Lines;
    end,
    function: TSlsDispatchDetail
    begin
      Result := Service.CreateLine(Table);
    end,
    procedure(ALine: TSlsDispatchDetail)
    begin
      Service.AddLine(Table, ALine);
    end,
    procedure(ALine: TSlsDispatchDetail)
    begin
      Service.RemoveLine(Table, ALine);
    end,
    function(ALine: TSlsDispatchDetail; AMode: TInputFormMode): TForm
    begin
      Result := TfrmSlsDispatchLine.Create(Self, TSlsDispatchDetailService.Create, ALine, AMode, nil);
    end);

  FLines.Grid.AddFooterColumn('amount', atSum, '#,##0.00');
  FLines.Grid.BuildData;
  FLines.Grid.SetColumnProperty('id', 0);
  FLines.Grid.SetColumnProperty('sls_dispatch_id', 0);
  FLines.Grid.SetColumnProperty('stk_inventory_id', 0);
  FLines.Grid.SetColumnProperty('sls_order_detail_id', 0);
  FLines.Grid.SetColumnProperty('dispatch_no', 0);
  FLines.Grid.SetColumnProperty('currency', 0);
  FLines.Grid.SetColumnProperty('line_no', 50);
  FLines.Grid.SetColumnProperty('inventory_code', 90);
  FLines.Grid.SetColumnProperty('inventory_name', 200);
  FLines.Grid.SetColumnProperty('uom_code', 50);
  FLines.Grid.SetColumnProperty('description', 160);
end;

destructor TfrmSlsDispatchDetail.Destroy;
begin
  FreeAndNil(FTotals);
  inherited;
end;

procedure TfrmSlsDispatchDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtDispatchDate.CanFocus then
    edtDispatchDate.SetFocus;
end;

procedure TfrmSlsDispatchDetail.ShowTotalValues;
begin
  if Assigned(FTotals) and Assigned(Table) then
    FTotals.SetValue('total', Table.TotalAmount, Table.Currency);
end;

procedure TfrmSlsDispatchDetail.ShowTotals;
begin
  if not Assigned(Table) then
    Exit;
  Service.Recalculate(Table);
  ShowTotalValues;
end;

procedure TfrmSlsDispatchDetail.DetailsChanged;
begin
  inherited;
  ShowTotals;
end;

procedure TfrmSlsDispatchDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.TitleSingular, 'Delivery Note');
  lblDispatchNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColDispatchNo, 'Delivery Note No');
  lblDispatchDate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColDispatchDate, 'Delivery Note Date');
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColAccAccountId, 'Customer');
  lblStkWarehouseId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColStkWarehouseId, 'Warehouse');
  lblSlsOrderId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColSlsOrderId, 'Order');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColCurrency, 'Currency');
  lblStatusText.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColStatus, 'Status');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColDescription, 'Description');
  if Assigned(FTotals) then
    FTotals.SetCaption('total', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColTotalAmount, 'Total'));

  if Assigned(FPageLines) then
    FPageLines.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.MenuLines, 'Lines');
  if Assigned(FLines) then
  begin
    FLines.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColLineNo, 'Line No'));
    FLines.Grid.SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColInventoryCode, 'Stock Code'));
    FLines.Grid.SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColInventoryName, 'Stock Name'));
    FLines.Grid.SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColUomCode, 'Unit'));
    FLines.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColQuantity, 'Quantity'));
    FLines.Grid.SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColUnitPrice, 'Net Unit Price'));
    FLines.Grid.SetColumnTitle('amount', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColAmount, 'Amount'));
    FLines.Grid.SetColumnTitle('invoiced_quantity', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColInvoicedQuantity, 'Invoiced Quantity'));
    FLines.Grid.SetColumnTitle('order_no', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColOrderNo, 'Order No'));
    FLines.Grid.SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColDescription, 'Description'));
  end;
end;

procedure TfrmSlsDispatchDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccAccountId: TfrmAccAccounts;
  LFrmStkWarehouseId: TfrmStkWarehouses;
  LFrmSlsOrderId: TfrmSlsOrders;
  LFrmCurrency: TfrmSysCurrencies;
  LLine: TSlsDispatchDetail;
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
  else if LEdit.Name = edtSlsOrderId.Name then
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
          LEdit.Clear;
        end
        else
        begin
          Table.SlsOrderId := LFrmSlsOrderId.Table.Id;
          Table.OrderNo := LFrmSlsOrderId.Table.OrderNo;
          LEdit.Text := Table.OrderNo;
        end;
      // Sipariş seçilince müşteri / ambar / para birimi siparişten gelir
      if LFrmSlsOrderId.DataTransfer and not LFrmSlsOrderId.CleanAndClose then
      begin
        Table.AccAccountId := LFrmSlsOrderId.Table.AccAccountId;
        Table.AccountName := LFrmSlsOrderId.Table.AccountName;
        edtAccAccountId.Text := Table.AccountName;
        Table.Currency := LFrmSlsOrderId.Table.Currency;
        edtCurrency.Text := Table.Currency;
        if LFrmSlsOrderId.Table.StkWarehouseId > 0 then
        begin
          Table.StkWarehouseId := LFrmSlsOrderId.Table.StkWarehouseId;
          Table.WarehouseName := LFrmSlsOrderId.Table.WarehouseName;
          edtStkWarehouseId.Text := Table.WarehouseName;
        end;
        for LLine in Table.Lines do
          LLine.Currency := Table.Currency;
        ShowTotalValues;
      end;
    finally
      LFrmSlsOrderId.Free;
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
      // kalemlerin para birimi (fiyat önerisi) ve toplamın gösterimi belgeyle aynı
      for LLine in Table.Lines do
        LLine.Currency := Table.Currency;
      ShowTotalValues;
    finally
      LFrmCurrency.Free;
    end;
  end;
end;

procedure TfrmSlsDispatchDetail.RefreshData;
begin
  inherited;
  edtDispatchNo.Text := Table.DispatchNo;
  if Table.DispatchDate > 0 then
    edtDispatchDate.Text := DateToStr(Table.DispatchDate)
  else
    edtDispatchDate.Text := '';
  edtAccAccountId.Text := Table.AccountName;
  edtStkWarehouseId.Text := Table.WarehouseName;
  edtSlsOrderId.Text := Table.OrderNo;
  edtCurrency.Text := Table.Currency;
  edtStatusText.Text := TSlsLookup.Text(slkDispatchStatus, Table.Status);
  edtDescription.Text := Table.Description;
  if Table.Lines.Count > 0 then
    ShowTotals
  else
    ShowTotalValues;
end;

end.
