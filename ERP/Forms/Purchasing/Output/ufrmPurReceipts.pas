unit ufrmPurReceipts;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PurReceipt.Service, PurReceipt, ufrmPurReceiptDetail;

type
  TfrmPurReceipts = class(TfrmGrid<TPurReceipt, TPurReceiptService>)
  private
    FFixedOrderName: string;
    FmniToInvoice, FmniQuality: TMenuItem;
    procedure mniToInvoiceClick(Sender: TObject);
    procedure mniQualityClick(Sender: TObject);

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
  ufrmPurInvoiceDetail, PurInvoice, PurInvoice.Service, PurReceiptExtension;

procedure TfrmPurReceipts.SetFixedOrder(AOrderId: Int64; const AOrderName: string);
begin
  FFixedOrderName := AOrderName;
  AddFixedFilter('pur_order_id', AOrderId);
end;

// Faturalanmamış miktarlarla alış faturası açılır (fatura no: irsaliye no, yoksa mal kabul no) ve belge ekranında
// gösterilir
procedure TfrmPurReceipts.mniToInvoiceClick(Sender: TObject);
var
  LInvoiceSvc: TPurInvoiceService;
  LInvoice: TPurInvoice;
  LInvoiceId: Int64;
  LFrm: TfrmPurInvoiceDetail;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LInvoiceSvc := TPurInvoiceService.Create;
  try
    LInvoiceId := LInvoiceSvc.CreateFromReceipt(Table.Id, '', True);
  finally
    LInvoiceSvc.Free;
  end;
  // oluşan fatura belge ekranında (inceleme; Güncelle ile no / kalemler düzenlenir)
  LInvoiceSvc := TPurInvoiceService.Create;
  LInvoice := LInvoiceSvc.FindById(LInvoiceId, False, True);
  LFrm := TfrmPurInvoiceDetail.Create(Self, LInvoiceSvc, LInvoice, ifmRewiev, nil, ivmNormal, True);
  LFrm.Show;
  RefreshParentGrid(True);
end;

// Giriş kalite kontrol (gevşek bağlı eklenti): mal kabulün kontrol listesi
procedure TfrmPurReceipts.mniQualityClick(Sender: TObject);
begin
  if Grd.DataSource.DataSet.IsEmpty or not Assigned(GReceiptQualityShow) then
    Exit;

  SetSelectedItem;
  GReceiptQualityShow(Self, Table.Id, Table.ReceiptNo);
end;

procedure TfrmPurReceipts.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniToInvoice := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurReceipt.MenuToInvoice, 'Create Purchase Invoice'), 'mniToInvoice', mniToInvoiceClick);
  // kalite kontrol modülü kayıtlı ve açıksa
  if Assigned(GReceiptQualityAvailable) and Assigned(GReceiptQualityShow) and GReceiptQualityAvailable() then
    FmniQuality := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurReceipt.MenuQuality, 'Quality Inspection'), 'mniQuality', mniQualityClick);
end;

// Belge ekranı (başlık + kalemler); kopyada belge formu Service.PrepareCopy ile yeni no / siparişsiz / yeni kalemler verir
function TfrmPurReceipts.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) or (AFormMode = ifmCopyNewRecord) then
    Result := TfrmPurReceiptDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmPurReceiptDetail.Create(Self, Service, TPurReceipt.Create, AFormMode, Self.RefreshParentGrid);
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
  if Assigned(FmniToInvoice) then
    FmniToInvoice.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.MenuToInvoice, 'Create Purchase Invoice');
  if Assigned(FmniQuality) then
    FmniQuality.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.MenuQuality, 'Quality Inspection');
end;

end.
