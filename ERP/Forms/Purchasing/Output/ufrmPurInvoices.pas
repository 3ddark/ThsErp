unit ufrmPurInvoices;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PurInvoice.Service, PurInvoice, ufrmPurInvoiceDetail;

type
  TfrmPurInvoices = class(TfrmGrid<TPurInvoice, TPurInvoiceService>)
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
  PurLookup;

// Belge ekranı (başlık + kalemler); kopyada belge formu Service.PrepareCopy ile yeni kalemler verir (fatura no yeniden)
function TfrmPurInvoices.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) or (AFormMode = ifmCopyNewRecord) then
    Result := TfrmPurInvoiceDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmPurInvoiceDetail.Create(Self, Service, TPurInvoice.Create, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPurInvoices.SetSelectedItem;

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
end;

procedure TfrmPurInvoices.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_account_id', 0);

end;

procedure TfrmPurInvoices.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPurInvoices.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.TitlePlural, 'Purchase Invoices');
  SetColumnTitle('invoice_no', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColInvoiceNo, 'Invoice No'));
  SetColumnTitle('invoice_date', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColInvoiceDate, 'Invoice Date'));
  SetColumnTitle('due_date', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColDueDate, 'Due Date'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColCurrency, 'Currency'));
  SetColumnTitle('exchange_rate', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColExchangeRate, 'Exchange Rate'));
  SetColumnTitle('gross_amount', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColGrossAmount, 'Gross Amount'));
  SetColumnTitle('discount_amount', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColDiscountAmount, 'Discount Amount'));
  SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColNetAmount, 'Net Amount'));
  SetColumnTitle('vat_amount', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColVatAmount, 'VAT Amount'));
  SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColTotalAmount, 'Total'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColDescription, 'Description'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColAccountCode, 'Supplier Code'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColAccountName, 'Supplier'));
  SetColumnTitle('line_count', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColLineCount, 'Lines'));
end;

end.
