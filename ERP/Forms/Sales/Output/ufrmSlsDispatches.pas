unit ufrmSlsDispatches;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SlsDispatch.Service, SlsDispatch, ufrmSlsDispatch;

type
  TfrmSlsDispatches = class(TfrmGrid<TSlsDispatch, TSlsDispatchService>)
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
  SlsLookup,
  ufrmSlsDispatchDetails, SlsDispatchDetail, SlsDispatchDetail.Service,
  ufrmSlsInvoiceDetails, SlsInvoice, SlsInvoice.Service, SlsInvoiceDetail, SlsInvoiceDetail.Service;

procedure TfrmSlsDispatches.SetFixedOrder(AOrderId: Int64; const AOrderName: string);
begin
  FFixedOrderName := AOrderName;
  AddFixedFilter('sls_order_id', AOrderId);
end;

procedure TfrmSlsDispatches.mniLinesClick(Sender: TObject);
var
  LFrm: TfrmSlsDispatchDetails;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmSlsDispatchDetails.Create(Self, TSlsDispatchDetailService.Create, TSlsDispatchDetail.Create);
  LFrm.SetFixedDispatch(Table.Id, Table.DispatchNo);
  LFrm.Show;
end;

// Faturalanmamış miktarlarla satış faturası açılır ve kalemleri gösterilir
procedure TfrmSlsDispatches.mniToInvoiceClick(Sender: TObject);
var
  LInvoiceSvc: TSlsInvoiceService;
  LInvoice: TSlsInvoice;
  LInvoiceId: Int64;
  LFrm: TfrmSlsInvoiceDetails;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LInvoiceSvc := TSlsInvoiceService.Create;
  try
    LInvoiceId := LInvoiceSvc.CreateFromDispatch(Table.Id, True);
    LInvoice := LInvoiceSvc.FindById(LInvoiceId, False);
    try
      LFrm := TfrmSlsInvoiceDetails.Create(Self, TSlsInvoiceDetailService.Create, TSlsInvoiceDetail.Create);
      LFrm.SetFixedInvoice(LInvoice.Id, LInvoice.InvoiceNo, LInvoice.Currency);
      LFrm.Show;
    finally
      LInvoice.Free;
    end;
  finally
    LInvoiceSvc.Free;
  end;
end;

procedure TfrmSlsDispatches.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniLines := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsDispatch.MenuLines, 'Lines'), 'mniLines', mniLinesClick);
  FmniToInvoice := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsDispatch.MenuToInvoice, 'Create Sales Invoice'), 'mniToInvoice', mniToInvoiceClick);
end;

function TfrmSlsDispatches.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TSlsDispatch;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSlsDispatch.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSlsDispatch.Create(Self, Service, TSlsDispatch.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
  begin
    LNew := Table.Clone;
    // Kopya: yeni numara, sipariş bağlantısı taşınmaz
    LNew.DispatchNo := '';
    LNew.SlsOrderId := 0;
    LNew.OrderNo := '';
    Result := TfrmSlsDispatch.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end;
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
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_account_id', 0);
  SetColumnProperty('stk_warehouse_id', 0);
  SetColumnProperty('sls_order_id', 0);

end;

procedure TfrmSlsDispatches.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSlsDispatches.ApplyLocalization;
begin
  inherited;
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
  if Assigned(FmniLines) then
    FmniLines.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.MenuLines, 'Lines');
  if Assigned(FmniToInvoice) then
    FmniToInvoice.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.MenuToInvoice, 'Create Sales Invoice');
end;

end.
