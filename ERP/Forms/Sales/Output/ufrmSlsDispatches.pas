unit ufrmSlsDispatches;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SlsDispatch.Service, SlsDispatch, ufrmSlsDispatchDetail;

type
  TfrmSlsDispatches = class(TfrmGrid<TSlsDispatch, TSlsDispatchService>)
  private
    FFixedOrderName: string;
    FmniToInvoice: TMenuItem;
    procedure mniToInvoiceClick(Sender: TObject);
    procedure StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);

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
  SlsLookup,
  ufrmSlsInvoiceDetail, SlsInvoice, SlsInvoice.Service;

procedure TfrmSlsDispatches.SetFixedOrder(AOrderId: Int64; const AOrderName: string);
begin
  FFixedOrderName := AOrderName;
  AddFixedFilter('sls_order_id', AOrderId);
end;

procedure TfrmSlsDispatches.StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TSlsLookup.Text(slkDispatchStatus, Sender.AsInteger);
end;

// Faturalanmamış miktarlarla satış faturası oluşur ve belge ekranında açılır
procedure TfrmSlsDispatches.mniToInvoiceClick(Sender: TObject);
var
  LInvoiceSvc: TSlsInvoiceService;
  LInvoice: TSlsInvoice;
  LInvoiceId: Int64;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LInvoiceSvc := TSlsInvoiceService.Create;
  try
    LInvoiceId := LInvoiceSvc.CreateFromDispatch(Table.Id, True);
  finally
    LInvoiceSvc.Free;
  end;
  // oluşan fatura belge ekranında (inceleme; Güncelle ile kalemler düzenlenir)
  LInvoiceSvc := TSlsInvoiceService.Create;
  LInvoice := LInvoiceSvc.FindById(LInvoiceId, False, True);
  TfrmSlsInvoiceDetail.Create(Self, LInvoiceSvc, LInvoice, ifmRewiev, nil, ivmNormal, True).Show;
  RefreshParentGrid(True);
end;

procedure TfrmSlsDispatches.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniToInvoice := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsDispatch.MenuToInvoice, 'Create Sales Invoice'), 'mniToInvoice', mniToInvoiceClick);
end;

// Başlık + kalemler tek ekranda (TfrmSlsDispatchDetail); Table = BusinessFindById ile kalemli belge, Clone derin kopya.
// Kopya modunda form Service.PrepareCopy ile yeni numara / bekliyor / sipariş bağlantısız yeni kalemler hazırlar
function TfrmSlsDispatches.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) or (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSlsDispatchDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSlsDispatchDetail.Create(Self, Service, TSlsDispatch.Create, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmSlsDispatches.SetSelectedItem;

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

procedure TfrmSlsDispatches.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_account_id', 0);
  SetColumnProperty('stk_warehouse_id', 0);
  SetColumnProperty('sls_order_id', 0);
  LField := Grd.DataSource.DataSet.FindField('status');
  if Assigned(LField) then
    LField.OnGetText := StatusGetText;

end;

procedure TfrmSlsDispatches.FormShow(Sender: TObject);
begin
  // Hızlı filtre: bekleyen (faturalanmamış) / kapanan (faturalanmış) irsaliyeler
  if QuickFilterCount = 0 then
  begin
    AddQuickFilter('', '', []);
    AddQuickFilter('', 'status = :qc0', [SLS_DSP_WAITING]);
    AddQuickFilter('', 'status = :qc0', [SLS_DSP_CLOSED]);
  end;
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSlsDispatches.ApplyLocalization;
begin
  inherited;
  SetQuickFilterCaption(0, TLocalizationManager.Translate(TLangKeys.TGeneral.QuickAll, 'All'));
  SetQuickFilterCaption(1, TLocalizationManager.Translate(TLangKeys.TSlsDispatch.QuickWaiting, 'Waiting'));
  SetQuickFilterCaption(2, TLocalizationManager.Translate(TLangKeys.TSlsDispatch.QuickClosed, 'Closed'));
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.TitlePlural, 'Delivery Notes');
  if FFixedOrderName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedOrderName;
  SetColumnTitle('dispatch_no', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColDispatchNo, 'Delivery Note No'));
  SetColumnTitle('dispatch_date', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColDispatchDate, 'Delivery Note Date'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColCurrency, 'Currency'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColDescription, 'Description'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColAccountCode, 'Customer Code'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColAccountName, 'Customer'));
  SetColumnTitle('warehouse_name', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColWarehouseName, 'Warehouse'));
  SetColumnTitle('order_no', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColOrderNo, 'Order No'));
  SetColumnTitle('line_count', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColLineCount, 'Lines'));
  SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColTotalAmount, 'Total'));
  SetColumnTitle('status', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColStatus, 'Status'));
  if Assigned(FmniToInvoice) then
    FmniToInvoice.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.MenuToInvoice, 'Create Sales Invoice');
end;

end.
