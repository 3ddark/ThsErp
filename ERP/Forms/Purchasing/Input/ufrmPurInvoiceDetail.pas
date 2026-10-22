unit ufrmPurInvoiceDetail;

// Alış faturası: başlık (pur_invoice) + kalemler (Table.Lines, pur_invoice_detail) tek ekranda. Kalemler bellekte fatura
// servisiyle eklenir / değişir / çıkar (satır formu TfrmPurInvoiceLine); Onayla Service.BusinessSaveWithDetails ile
// başlık ve kalemleri tek transaction'da yazar. Stok hareketi mal kabulde, cari borç türetilir.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.Generics.Collections,
  ufrmInputDetailedDB, Detail.Lines, Detail.Totals, Detail.TaxInfo, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  PurInvoice.Service, PurInvoice, PurInvoiceDetail.Service, PurInvoiceDetail;

type
  TfrmPurInvoiceDetail = class(TfrmInputDetailedDB<TPurInvoice, TPurInvoiceService>)
    pnlContent: TPanel;
    lblInvoiceNo: TLabel;
    edtInvoiceNo: TEdit;
    lblInvoiceDate: TLabel;
    edtInvoiceDate: TEdit;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblDueDate: TLabel;
    edtDueDate: TEdit;
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
    FLines: TDetailSet<TPurInvoiceDetail>;
    FPageTax: TTabSheet;
    FTaxInfo: TDocumentTaxInfo;
    // Vergi Bilgisi sekmesi: belgedeki cari kopyası; ALoadSummary ise kayıtlı belgenin vergi dökümü de okunur
    procedure ShowTaxInfo(ALoadSummary: Boolean);
    procedure ShowTotals;
    // Table toplamları panelde (para birimiyle)
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
  SysDecimalPlace.Cache,
  Grid.Types, ufrmPurInvoiceLine, SysDocumentTrail.Service,
  AccAccount, AccAccount.Service, ufrmAccAccounts,        // TfrmAccAccounts helper output form
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;    // TfrmSysCurrencies helper output form

procedure TfrmPurInvoiceDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.InvoiceNo := edtInvoiceNo.Text;
  Table.InvoiceDate := StrToDateDef(edtInvoiceDate.Text, 0);
  Table.DueDate := StrToDateDef(edtDueDate.Text, 0);
  Table.ExchangeRate := StrToCurrDef(edtExchangeRate.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmPurInvoiceDetail.FormCreate(Sender: TObject);
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
  edtCurrency.OnHelperProcess := HelperProcess;
  edtExchangeRate.thsInputDataType := itFloat;
  edtExchangeRate.thsDecimalDigitCount := TDecimalPlaces.ExchangeRate;
  edtDescription.thsInputDataType := itString;

  // Kalemler = Table.Lines (servis satır no sırasıyla okur); ekle / çıkar / hesap fatura servisinde,
  // satır formu modal, kayıt faturayla birlikte
  FPageLines := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TPurInvoice.MenuLines, 'Lines'));
  FPageTax := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TDocumentTaxInfo.TabTitle, 'Tax Information'));
  FTaxInfo := TDocumentTaxInfo.Create(Self, FPageTax);
  FLines := AddDetail<TPurInvoiceDetail>(FPageLines, 'vw_pur_order_detail',
    function: TObjectList<TPurInvoiceDetail>
    begin
      Result := Table.Lines;
    end,
    function: TPurInvoiceDetail
    begin
      Result := Service.CreateLine(Table);
    end,
    procedure(ALine: TPurInvoiceDetail)
    begin
      Service.AddLine(Table, ALine);
    end,
    procedure(ALine: TPurInvoiceDetail)
    begin
      Service.RemoveLine(Table, ALine);
    end,
    function(ALine: TPurInvoiceDetail; AMode: TInputFormMode): TForm
    begin
      Result := TfrmPurInvoiceLine.Create(Self, TPurInvoiceDetailService.Create, ALine, AMode, nil);
    end);

  FLines.Grid.AddFooterColumn('net_amount', atSum, TDecimalPlaces.TotalFormat);
  FLines.Grid.AddFooterColumn('vat_amount', atSum, TDecimalPlaces.TotalFormat);
  FLines.Grid.AddFooterColumn('total_amount', atSum, TDecimalPlaces.TotalFormat);
  FLines.Grid.BuildData;
  FLines.Grid.SetColumnProperty('id', 0);
  FLines.Grid.SetColumnProperty('pur_order_id', 0);
  FLines.Grid.SetColumnProperty('stk_inventory_id', 0);
  FLines.Grid.SetColumnProperty('pur_receipt_detail_id', 0);
  FLines.Grid.SetColumnProperty('acc_account_id', 0);
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

destructor TfrmPurInvoiceDetail.Destroy;
begin
  FreeAndNil(FTotals);
  FreeAndNil(FTaxInfo);
  inherited;
end;

procedure TfrmPurInvoiceDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtInvoiceNo.CanFocus then
    edtInvoiceNo.SetFocus;
end;

procedure TfrmPurInvoiceDetail.ShowTotalValues;
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
procedure TfrmPurInvoiceDetail.ShowTotals;
begin
  if not Assigned(Table) then
    Exit;
  Service.Recalculate(Table);
  ShowTotalValues;
end;

procedure TfrmPurInvoiceDetail.DetailsChanged;
begin
  inherited;
  ShowTotals;
end;

procedure TfrmPurInvoiceDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.TitleSingular, 'Purchase Invoice');
  lblInvoiceNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColInvoiceNo, 'Invoice No');
  lblInvoiceDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColInvoiceDate, 'Invoice Date');
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColAccAccountId, 'Supplier');
  lblDueDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColDueDate, 'Due Date');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColCurrency, 'Currency');
  lblExchangeRate.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColExchangeRate, 'Exchange Rate');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColDescription, 'Description');
  if Assigned(FTotals) then
  begin
    FTotals.SetCaption('gross', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColGrossAmount, 'Gross Amount'));
    FTotals.SetCaption('discount', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColDiscountAmount, 'Discount Amount'));
    FTotals.SetCaption('net', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColNetAmount, 'Net Amount'));
    FTotals.SetCaption('vat', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColVatAmount, 'VAT Amount'));
    FTotals.SetCaption('total', TLocalizationManager.Translate(TLangKeys.TPurInvoice.ColTotalAmount, 'Total'));
  end;

  if Assigned(FPageLines) then
    FPageLines.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.MenuLines, 'Lines');
  if Assigned(FPageTax) then
    FPageTax.Caption := TLocalizationManager.Translate(TLangKeys.TDocumentTaxInfo.TabTitle, 'Tax Information');
  if Assigned(FTaxInfo) then
    FTaxInfo.ApplyLocalization;
  if Assigned(FLines) then
  begin
    FLines.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColLineNo, 'Line No'));
    FLines.Grid.SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColInventoryCode, 'Stock Code'));
    FLines.Grid.SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColInventoryName, 'Stock Name'));
    FLines.Grid.SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColUomCode, 'Unit'));
    FLines.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColQuantity, 'Quantity'));
    FLines.Grid.SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColUnitPrice, 'Unit Price'));
    FLines.Grid.SetColumnTitle('discount_rate', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColDiscountRate, 'Discount (%)'));
    FLines.Grid.SetColumnTitle('vat_rate', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColVatRate, 'VAT (%)'));
    FLines.Grid.SetColumnTitle('gross_amount', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColGrossAmount, 'Gross Amount'));
    FLines.Grid.SetColumnTitle('discount_amount', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColDiscountAmount, 'Discount Amount'));
    FLines.Grid.SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColNetAmount, 'Net Amount'));
    FLines.Grid.SetColumnTitle('vat_amount', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColVatAmount, 'VAT Amount'));
    FLines.Grid.SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColTotalAmount, 'Total'));
    FLines.Grid.SetColumnTitle('receipt_no', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColReceiptNo, 'Receipt No'));
    FLines.Grid.SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.ColDescription, 'Description'));
  end;
end;

procedure TfrmPurInvoiceDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccAccountId: TfrmAccAccounts;
  LFrmCurrency: TfrmSysCurrencies;
  LLine: TPurInvoiceDetail;
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
          Table.AccountTitle := '';
          Table.TaxpayerType := 0;
          Table.TaxOffice := '';
          Table.TaxNo := '';
          LEdit.Clear;
          ShowTaxInfo(False);
        end
        else
        begin
          Table.AccAccountId := LFrmAccAccountId.Table.Id;
          Table.AccountCode := LFrmAccAccountId.Table.Code;
          Table.AccountName := LFrmAccAccountId.Table.Name;
          LEdit.Text := Table.AccountName;
          // belgeye cari kartının güncel bilgisi gelir (kayıtta tetikleyici aynısını belgeye yazar)
          Table.AccountTitle := LFrmAccAccountId.Table.Name;
          Table.TaxpayerType := LFrmAccAccountId.Table.TaxpayerType;
          Table.TaxOffice := LFrmAccAccountId.Table.TaxOffice;
          Table.TaxNo := LFrmAccAccountId.Table.TaxNo;
          ShowTaxInfo(False);
        end;
    finally
      LFrmAccAccountId.Free;
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

procedure TfrmPurInvoiceDetail.ShowTaxInfo(ALoadSummary: Boolean);
var
  LSvc: TSysDocumentTrailService;
begin
  if not Assigned(FTaxInfo) or not Assigned(Table) then
    Exit;
  FTaxInfo.SetParty(Table.AccountTitle, Table.TaxOffice, Table.TaxNo, Table.TaxpayerType, False);
  if not ALoadSummary then
    Exit;
  if Table.Id <= 0 then
  begin
    FTaxInfo.SetSummary([], Table.Currency);
    Exit;
  end;
  LSvc := TSysDocumentTrailService.Create;
  try
    FTaxInfo.SetSummary(LSvc.TaxSummary('pur_invoice', Table.Id, True), Table.Currency);
  finally
    LSvc.Free;
  end;
end;

procedure TfrmPurInvoiceDetail.RefreshData;
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
  edtCurrency.Text := Table.Currency;
  edtExchangeRate.Text := CurrToStr(Table.ExchangeRate);
  edtDescription.Text := Table.Description;
  // bellekte kalem varsa toplamlar onlardan
  if Table.Lines.Count > 0 then
    ShowTotals
  else
    ShowTotalValues;
  ShowTaxInfo(True);
end;

end.
