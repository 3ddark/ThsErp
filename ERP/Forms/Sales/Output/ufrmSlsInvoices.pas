unit ufrmSlsInvoices;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SlsInvoice.Service, SlsInvoice, ufrmSlsInvoiceDetail, EInvDocument, EInvDocument.Service;

type
  TfrmSlsInvoices = class(TfrmGrid<TSlsInvoice, TSlsInvoiceService>)
  private
    FmniEInvPreview: TMenuItem;
    FmniEInvSaveXml: TMenuItem;
    FmniEInvRegenerate: TMenuItem;
    FmniEInvValidation: TMenuItem;
    FmniEInvSend: TMenuItem;
    FmniEInvQueryStatus: TMenuItem;
    procedure EinvStatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    // e-belge XML (einv_document): seçili faturanınki; yoksa mesaj + nil
    function SelectedEInvDocument(AService: TEInvDocumentService): TEInvDocument;
    procedure ShowEInvValidation(ADocument: TEInvDocument);
    procedure mniEInvPreviewClick(Sender: TObject);
    procedure mniEInvSaveXmlClick(Sender: TObject);
    procedure mniEInvRegenerateClick(Sender: TObject);
    procedure mniEInvValidationClick(Sender: TObject);
    procedure mniEInvSendClick(Sender: TObject);
    procedure mniEInvQueryStatusClick(Sender: TObject);
    procedure ShowEInvInformation(const AMessage: string);
  public
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
  SlsLookup, EInvLookup, Ths.DialogHelper, Winapi.ShellAPI, System.IOUtils;

procedure TfrmSlsInvoices.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;
  AddPopupMenuSpliter();
  FmniEInvPreview := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MenuEInvPreview, 'e-Document Preview'),
    'mniEInvPreview', mniEInvPreviewClick);
  FmniEInvValidation := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MenuEInvValidation, 'e-Document Validation Result'),
    'mniEInvValidation', mniEInvValidationClick);
  FmniEInvSaveXml := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MenuEInvSaveXml, 'Save e-Document XML...'),
    'mniEInvSaveXml', mniEInvSaveXmlClick);
  FmniEInvRegenerate := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MenuEInvRegenerate, 'Regenerate e-Document XML'),
    'mniEInvRegenerate', mniEInvRegenerateClick);
  AddPopupMenuSpliter();
  FmniEInvSend := AddMenu(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.MenuSend, 'Send e-Document'),
    'mniEInvSend', mniEInvSendClick);
  FmniEInvQueryStatus := AddMenu(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.MenuQueryStatus,
    'Query e-Document Status'), 'mniEInvQueryStatus', mniEInvQueryStatusClick);
end;

procedure TfrmSlsInvoices.ShowEInvInformation(const AMessage: string);
begin
  TThsDialogHelper.CustomMsgDlg(AMessage, mtInformation, [mbOK], [TLocalizationManager.Translate(TLangKeys.TGeneral.OK, 'Ok')],
    mbOK, TLocalizationManager.Translate(TLangKeys.TMessage.InformationTitle, 'Information'));
end;

// Entegratöre gönderim (onaylı; geri alınamaz). Hata durumunda belge "hata" durumunda kalır, mesaj gösterilir
procedure TfrmSlsInvoices.mniEInvSendClick(Sender: TObject);
var
  LSvc: TEInvDocumentService;
  LMessage: string;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;
  SetSelectedItem;
  if TThsDialogHelper.CustomMsgDlg(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.ConfirmSend,
    'Send the selected e-document to the integrator? This cannot be undone.'), mtConfirmation, [mbYes, mbNo],
    [TLocalizationManager.Translate(TLangKeys.TGeneral.Yes, 'Yes'), TLocalizationManager.Translate(TLangKeys.TGeneral.No, 'No')],
    mbNo, TLocalizationManager.Translate(TLangKeys.TMessage.UserConfirmationTitle, 'Confirmation')) <> mrYes then
    Exit;
  LSvc := TEInvDocumentService.Create;
  try
    Screen.Cursor := crHourGlass;
    try
      try
        LMessage := LSvc.BusinessSendInvoice(Table.Id, True);
      finally
        Screen.Cursor := crDefault;
        RefreshParentGrid(True);
      end;
    except
      on E: Exception do
        LMessage := E.Message;
    end;
    ShowEInvInformation(LMessage);
  finally
    LSvc.Free;
  end;
end;

procedure TfrmSlsInvoices.mniEInvQueryStatusClick(Sender: TObject);
var
  LSvc: TEInvDocumentService;
  LMessage: string;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;
  SetSelectedItem;
  LSvc := TEInvDocumentService.Create;
  try
    Screen.Cursor := crHourGlass;
    try
      LMessage := LSvc.BusinessQueryInvoiceStatus(Table.Id, True);
    finally
      Screen.Cursor := crDefault;
    end;
    RefreshParentGrid(True);
    ShowEInvInformation(LMessage);
  finally
    LSvc.Free;
  end;
end;

function TfrmSlsInvoices.SelectedEInvDocument(AService: TEInvDocumentService): TEInvDocument;
begin
  Result := nil;
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;
  SetSelectedItem;
  Result := AService.BusinessFindByInvoice(Table.Id, True);
  if not Assigned(Result) then
    TThsDialogHelper.CustomMsgDlg(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MsgEInvNoDocument,
      'This invoice has no e-document XML (paper invoice, or the invoice has not been saved with a profile).'),
      mtInformation, [mbOK], [TLocalizationManager.Translate(TLangKeys.TGeneral.OK, 'Ok')], mbOK,
      TLocalizationManager.Translate(TLangKeys.TMessage.InformationTitle, 'Information'));
end;

procedure TfrmSlsInvoices.ShowEInvValidation(ADocument: TEInvDocument);
begin
  if ADocument.IsValid then
    TThsDialogHelper.CustomMsgDlg(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MsgEInvValid,
      'The e-document XML is valid against the UBL-TR schema.'), mtInformation, [mbOK],
      [TLocalizationManager.Translate(TLangKeys.TGeneral.OK, 'Ok')], mbOK,
      TLocalizationManager.Translate(TLangKeys.TMessage.InformationTitle, 'Information'))
  else
    TThsDialogHelper.CustomMsgDlg(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MsgEInvInvalid,
      'The e-document XML has problems and would be rejected:') + sLineBreak + sLineBreak + ADocument.ValidationMessage,
      mtWarning, [mbOK], [TLocalizationManager.Translate(TLangKeys.TGeneral.OK, 'Ok')], mbOK,
      TLocalizationManager.Translate(TLangKeys.TMessage.InformationTitle, 'Information'));
end;

// GİB görselliğiyle (general.xslt) HTML; geçici dosya varsayılan tarayıcıda açılır. Sorunlu XML önce uyarılır
procedure TfrmSlsInvoices.mniEInvPreviewClick(Sender: TObject);
var
  LSvc: TEInvDocumentService;
  LDoc: TEInvDocument;
  LFile: string;
begin
  LSvc := TEInvDocumentService.Create;
  try
    LDoc := SelectedEInvDocument(LSvc);
    if not Assigned(LDoc) then
      Exit;
    try
      if not LDoc.IsValid then
        ShowEInvValidation(LDoc);
      LFile := TPath.Combine(TPath.GetTempPath, 'einv_' + LDoc.EinvUuid + '.html');
      TFile.WriteAllText(LFile, TEInvDocumentService.ToHtml(LDoc), TEncoding.UTF8);
      ShellExecute(0, 'open', PChar(LFile), nil, nil, SW_SHOWNORMAL);
    finally
      LDoc.Free;
    end;
  finally
    LSvc.Free;
  end;
end;

procedure TfrmSlsInvoices.mniEInvValidationClick(Sender: TObject);
var
  LSvc: TEInvDocumentService;
  LDoc: TEInvDocument;
begin
  LSvc := TEInvDocumentService.Create;
  try
    LDoc := SelectedEInvDocument(LSvc);
    if Assigned(LDoc) then
    try
      ShowEInvValidation(LDoc);
    finally
      LDoc.Free;
    end;
  finally
    LSvc.Free;
  end;
end;

// UTF-8 (BOM'suz) .xml: entegratör portalına elle yükleme / inceleme için
procedure TfrmSlsInvoices.mniEInvSaveXmlClick(Sender: TObject);
var
  LSvc: TEInvDocumentService;
  LDoc: TEInvDocument;
  LDialog: TSaveDialog;
  LEncoding: TEncoding;
begin
  LSvc := TEInvDocumentService.Create;
  try
    LDoc := SelectedEInvDocument(LSvc);
    if not Assigned(LDoc) then
      Exit;
    LDialog := TSaveDialog.Create(Self);
    LEncoding := TUTF8Encoding.Create(False);
    try
      LDialog.DefaultExt := 'xml';
      LDialog.Filter := 'XML (*.xml)|*.xml';
      LDialog.FileName := LDoc.EinvNo + '.xml';
      LDialog.Options := LDialog.Options + [ofOverwritePrompt];
      if LDialog.Execute then
        TFile.WriteAllText(LDialog.FileName, LDoc.XmlContent, LEncoding);
    finally
      LEncoding.Free;
      LDialog.Free;
      LDoc.Free;
    end;
  finally
    LSvc.Free;
  end;
end;

// Firma / cari bilgisi düzeltildikten sonra XML yeniden üretilir (güncelleme yetkisi; gönderilmiş belgede ret)
procedure TfrmSlsInvoices.mniEInvRegenerateClick(Sender: TObject);
var
  LSvc: TEInvDocumentService;
  LDoc: TEInvDocument;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;
  SetSelectedItem;
  LSvc := TEInvDocumentService.Create;
  try
    LSvc.BusinessRegenerate(Table.Id, True);
    RefreshParentGrid(True);
    LDoc := SelectedEInvDocument(LSvc);
    if Assigned(LDoc) then
    try
      ShowEInvValidation(LDoc);
    finally
      LDoc.Free;
    end;
  finally
    LSvc.Free;
  end;
end;

procedure TfrmSlsInvoices.EinvStatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TEInvLookup.Text(elkEInvStatus, Sender.AsInteger);
end;

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
  Table.ProfileCode := FieldText('profile_code');
  Table.InvoiceTypeCode := FieldText('invoice_type_code');
  Table.TaxExemptionCode := FieldText('tax_exemption_code');
  Table.TaxExemptionName := FieldText('tax_exemption_name');
  Table.DeliveryTermCode := FieldText('delivery_term_code');
  Table.TransportModeName := FieldText('transport_mode_name');
  Table.PaymentMeansName := FieldText('payment_means_name');
end;

procedure TfrmSlsInvoices.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_account_id', 0);
  SetColumnProperty('stk_warehouse_id', 0);
  SetColumnProperty('einv_profile_id', 0);
  SetColumnProperty('einv_invoice_type_id', 0);
  SetColumnProperty('einv_tax_exemption_id', 0);
  SetColumnProperty('einv_delivery_term_id', 0);
  SetColumnProperty('einv_transport_mode_id', 0);
  SetColumnProperty('einv_payment_means_id', 0);
  LField := Grd.DataSource.DataSet.FindField('einv_status');
  if Assigned(LField) then
    LField.OnGetText := EinvStatusGetText;
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
  SetColumnTitle('profile_code', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColProfileCode, 'e-Document Profile'));
  SetColumnTitle('invoice_type_code', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColInvoiceTypeCode, 'Invoice Type'));
  SetColumnTitle('einv_uuid', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColEinvUuid, 'UUID (ETTN)'));
  SetColumnTitle('einv_status', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColEinvStatus, 'e-Document Status'));
  SetColumnTitle('tax_exemption_code', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColTaxExemptionCode, 'Exemption Code'));
  SetColumnTitle('tax_exemption_name', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColTaxExemptionName, 'Exemption Reason'));
  SetColumnTitle('delivery_term_code', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColDeliveryTermCode, 'Delivery Term'));
  SetColumnTitle('transport_mode_name', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColTransportModeName, 'Transport Mode'));
  SetColumnTitle('payment_means_name', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColPaymentMeansName, 'Payment Means'));
  SetColumnTitle('customs_declaration_no', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColCustomsDeclarationNo, 'Customs Exit Declaration No'));
  SetColumnTitle('gtb_ref_no', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColGtbRefNo, 'Customs Reference No'));
  SetColumnTitle('actual_export_date', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColActualExportDate, 'Actual Export Date'));
  SetColumnTitle('withholding_amount', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColWithholdingAmount, 'Withholding Amount'));
  SetColumnTitle('payable_amount', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColPayableAmount, 'Payable Amount'));
  SetColumnTitle('account_e_invoice_active', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColAccountEInvoiceActive, 'e-Invoice User'));
  SetColumnTitle('einv_no', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColEinvNo, 'e-Document No'));
  SetColumnTitle('einv_xml_valid', TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ColEinvXmlValid, 'XML Valid'));
  if Assigned(FmniEInvPreview) then
  begin
    FmniEInvPreview.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MenuEInvPreview, 'e-Document Preview');
    FmniEInvValidation.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MenuEInvValidation, 'e-Document Validation Result');
    FmniEInvSaveXml.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MenuEInvSaveXml, 'Save e-Document XML...');
    FmniEInvRegenerate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MenuEInvRegenerate, 'Regenerate e-Document XML');
  if Assigned(FmniEInvSend) then
  begin
    FmniEInvSend.Caption := TLocalizationManager.Translate(TLangKeys.TEInvIntegration.MenuSend, 'Send e-Document');
    FmniEInvQueryStatus.Caption := TLocalizationManager.Translate(TLangKeys.TEInvIntegration.MenuQueryStatus,
      'Query e-Document Status');
  end;
  end;
end;

end.
