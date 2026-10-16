unit ufrmSlsInvoices;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SlsInvoice.Service, SlsInvoice, ufrmSlsInvoiceDetail;

type
  TfrmSlsInvoices = class(TfrmGrid<TSlsInvoice, TSlsInvoiceService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SlsLookup;

// Başlık + kalemler tek ekranda (TfrmSlsInvoiceDetail); Table = BusinessFindById ile kalemli belge, Clone derin kopya.
// Kopya modunda form Service.PrepareCopy ile yeni numara / irsaliye-sipariş bağlantısız yeni kalemler hazırlar
function TfrmSlsInvoices.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) or (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSlsInvoiceDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSlsInvoiceDetail.Create(Self, Service, TSlsInvoice.Create, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmSlsInvoices.SetSelectedItem;

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
end;

procedure TfrmSlsInvoices.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_account_id', 0);
  SetColumnProperty('stk_warehouse_id', 0);

end;

procedure TfrmSlsInvoices.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSlsInvoices.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.TitlePlural, 'Sales Invoices');
  SetColumnTitle('invoice_no', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColInvoiceNo, 'Invoice No'));
  SetColumnTitle('invoice_date', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColInvoiceDate, 'Invoice Date'));
  SetColumnTitle('due_date', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColDueDate, 'Due Date'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColCurrency, 'Currency'));
  SetColumnTitle('exchange_rate', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColExchangeRate, 'Exchange Rate'));
  SetColumnTitle('gross_amount', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColGrossAmount, 'Gross Amount'));
  SetColumnTitle('discount_amount', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColDiscountAmount, 'Discount Amount'));
  SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColNetAmount, 'Net Amount'));
  SetColumnTitle('vat_amount', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColVatAmount, 'VAT Amount'));
  SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColTotalAmount, 'Total'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColDescription, 'Description'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColAccountCode, 'Customer Code'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColAccountName, 'Customer'));
  SetColumnTitle('warehouse_name', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColWarehouseName, 'Shipping Warehouse'));
  SetColumnTitle('line_count', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColLineCount, 'Lines'));
end;

end.
