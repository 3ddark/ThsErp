unit ufrmPurReceipts;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PurReceipt.Service, PurReceipt, ufrmPurReceipt;

type
  TfrmPurReceipts = class(TfrmGrid<TPurReceipt, TPurReceiptService>)
  private
    FFixedOrderName: string;
    FmniLines, FmniToInvoice: TMenuItem;
    procedure mniLinesClick(Sender: TObject);
    procedure mniToInvoiceClick(Sender: TObject);

  public
    procedure SetFixedOrder(AOrderId: Int64; const AOrderName: string);
    procedure PreparePopupMenu; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  PurLookup,
  ufrmPurReceiptDetails, PurReceiptDetail, PurReceiptDetail.Service,
  ufrmPurInvoiceDetails, PurInvoice, PurInvoice.Service, PurInvoiceDetail, PurInvoiceDetail.Service;

procedure TfrmPurReceipts.SetFixedOrder(AOrderId: Int64; const AOrderName: string);
begin
  FFixedOrderName := AOrderName;
  AddFixedFilter('pur_order_id', AOrderId);
end;

procedure TfrmPurReceipts.mniLinesClick(Sender: TObject);
var
  LFrm: TfrmPurReceiptDetails;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmPurReceiptDetails.Create(Self, TPurReceiptDetailService.Create, TPurReceiptDetail.Create);
  LFrm.SetFixedReceipt(Table.Id, Table.ReceiptNo);
  LFrm.Show;
end;

// Faturalanmamış miktarlarla alış faturası açılır (fatura no: irsaliye no, yoksa mal kabul no) ve kalemleri gösterilir
procedure TfrmPurReceipts.mniToInvoiceClick(Sender: TObject);
var
  LInvoiceSvc: TPurInvoiceService;
  LInvoice: TPurInvoice;
  LInvoiceId: Int64;
  LFrm: TfrmPurInvoiceDetails;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LInvoiceSvc := TPurInvoiceService.Create;
  try
    LInvoiceId := LInvoiceSvc.CreateFromReceipt(Table.Id, '', True);
    LInvoice := LInvoiceSvc.FindById(LInvoiceId, False);
    try
      LFrm := TfrmPurInvoiceDetails.Create(Self, TPurInvoiceDetailService.Create, TPurInvoiceDetail.Create);
      LFrm.SetFixedInvoice(LInvoice.Id, LInvoice.InvoiceNo, LInvoice.Currency);
      LFrm.Show;
    finally
      LInvoice.Free;
    end;
  finally
    LInvoiceSvc.Free;
  end;
end;

procedure TfrmPurReceipts.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniLines := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurReceipt.MenuLines, 'Lines'), 'mniLines', mniLinesClick);
  FmniToInvoice := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurReceipt.MenuToInvoice, 'Create Purchase Invoice'), 'mniToInvoice', mniToInvoiceClick);
end;

function TfrmPurReceipts.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TPurReceipt;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmPurReceipt.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmPurReceipt.Create(Self, Service, TPurReceipt.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
  begin
    LNew := Table.Clone;
    // Kopya: yeni numara, sipariş bağlantısı taşınmaz
    LNew.ReceiptNo := '';
    LNew.PurOrderId := 0;
    LNew.OrderNo := '';
    Result := TfrmPurReceipt.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPurReceipts.SetSelectedItem;

  function FieldText(const AFieldName: string): string;
  var
    LField: TField;
  begin
    LField := Grd.DataSource.DataSet.FindField(AFieldName);
    if Assigned(LField) then
      Result := LField.AsString
    else
      Result := '';
  end;

begin
  inherited;
  Table.AccountCode := FieldText('account_code');
  Table.AccountName := FieldText('account_name');
  Table.WarehouseName := FieldText('warehouse_name');
  Table.OrderNo := FieldText('order_no');
end;

procedure TfrmPurReceipts.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_account_id', 0);
  SetColumnProperty('stk_warehouse_id', 0);
  SetColumnProperty('pur_order_id', 0);

end;

procedure TfrmPurReceipts.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPurReceipts.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.TitlePlural, 'Goods Receipts');
  if FFixedOrderName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedOrderName;
  SetColumnTitle('receipt_no', TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColReceiptNo, 'Receipt No'));
  SetColumnTitle('receipt_date', TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColReceiptDate, 'Receipt Date'));
  SetColumnTitle('waybill_no', TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColWaybillNo, 'Supplier Waybill No'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColCurrency, 'Currency'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColDescription, 'Description'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColAccountCode, 'Supplier Code'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColAccountName, 'Supplier'));
  SetColumnTitle('warehouse_name', TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColWarehouseName, 'Warehouse'));
  SetColumnTitle('order_no', TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColOrderNo, 'Order No'));
  SetColumnTitle('line_count', TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColLineCount, 'Lines'));
  SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TPurReceipt.ColTotalAmount, 'Total'));
  if Assigned(FmniLines) then
    FmniLines.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.MenuLines, 'Lines');
  if Assigned(FmniToInvoice) then
    FmniToInvoice.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.MenuToInvoice, 'Create Purchase Invoice');
end;

end.
