unit ufrmSlsDispatches;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SlsDispatch.Service, SlsDispatch, ufrmSlsDispatchDetail, EInvDocument, EInvDocument.Service;

type
  TfrmSlsDispatches = class(TfrmGrid<TSlsDispatch, TSlsDispatchService>)
  private
    FFixedOrderName: string;
    FmniToInvoice: TMenuItem;
    FmniEInvPreview: TMenuItem;
    FmniEInvSaveXml: TMenuItem;
    FmniEInvRegenerate: TMenuItem;
    FmniEInvValidation: TMenuItem;
    procedure mniToInvoiceClick(Sender: TObject);
    procedure StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    function SelectedEInvDocument(AService: TEInvDocumentService): TEInvDocument;
    procedure ShowEInvValidation(ADocument: TEInvDocument);
    procedure mniEInvPreviewClick(Sender: TObject);
    procedure mniEInvSaveXmlClick(Sender: TObject);
    procedure mniEInvRegenerateClick(Sender: TObject);
    procedure mniEInvValidationClick(Sender: TObject);
    procedure EinvStatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);

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
  SlsLookup, EInvLookup, Ths.DialogHelper, Winapi.ShellAPI, System.IOUtils,
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

// e-İrsaliye XML (einv_document): seçili irsaliyeninki; yoksa mesaj + nil
function TfrmSlsDispatches.SelectedEInvDocument(AService: TEInvDocumentService): TEInvDocument;
begin
  Result := nil;
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;
  SetSelectedItem;
  Result := AService.BusinessFindByDispatch(Table.Id, True);
  if not Assigned(Result) then
    TThsDialogHelper.CustomMsgDlg(TLocalizationManager.Translate(TLangKeys.TSlsDispatch.MsgEInvNoDocument,
      'This delivery note has no e-despatch XML (paper delivery note, or not saved with a profile).'),
      mtInformation, [mbOK], [TLocalizationManager.Translate(TLangKeys.TGeneral.OK, 'Ok')], mbOK,
      TLocalizationManager.Translate(TLangKeys.TMessage.InformationTitle, 'Information'));
end;

procedure TfrmSlsDispatches.ShowEInvValidation(ADocument: TEInvDocument);
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

// GİB görselliğiyle (irsaliye.xslt) HTML; geçici dosya varsayılan tarayıcıda açılır. Sorunlu XML önce uyarılır
procedure TfrmSlsDispatches.mniEInvPreviewClick(Sender: TObject);
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
      LFile := TPath.Combine(TPath.GetTempPath, 'edesp_' + LDoc.EinvUuid + '.html');
      TFile.WriteAllText(LFile, TEInvDocumentService.ToHtml(LDoc), TEncoding.UTF8);
      ShellExecute(0, 'open', PChar(LFile), nil, nil, SW_SHOWNORMAL);
    finally
      LDoc.Free;
    end;
  finally
    LSvc.Free;
  end;
end;

procedure TfrmSlsDispatches.mniEInvValidationClick(Sender: TObject);
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
procedure TfrmSlsDispatches.mniEInvSaveXmlClick(Sender: TObject);
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

// Firma / cari / araç bilgisi düzeltildikten sonra XML yeniden üretilir (güncelleme yetkisi; gönderilmiş belgede ret)
procedure TfrmSlsDispatches.mniEInvRegenerateClick(Sender: TObject);
var
  LSvc: TEInvDocumentService;
  LDoc: TEInvDocument;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;
  SetSelectedItem;
  LSvc := TEInvDocumentService.Create;
  try
    LSvc.BusinessRegenerateDispatch(Table.Id, True);
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

procedure TfrmSlsDispatches.EinvStatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TEInvLookup.Text(elkEInvStatus, Sender.AsInteger);
end;

procedure TfrmSlsDispatches.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniToInvoice := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsDispatch.MenuToInvoice, 'Create Sales Invoice'), 'mniToInvoice', mniToInvoiceClick);
  AddPopupMenuSpliter();
  FmniEInvPreview := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MenuEInvPreview, 'e-Document Preview'),
    'mniEInvPreview', mniEInvPreviewClick);
  FmniEInvValidation := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MenuEInvValidation, 'e-Document Validation Result'),
    'mniEInvValidation', mniEInvValidationClick);
  FmniEInvSaveXml := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MenuEInvSaveXml, 'Save e-Document XML...'),
    'mniEInvSaveXml', mniEInvSaveXmlClick);
  FmniEInvRegenerate := AddMenu(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MenuEInvRegenerate, 'Regenerate e-Document XML'),
    'mniEInvRegenerate', mniEInvRegenerateClick);
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
  SetColumnProperty('einv_profile_id', 0);
  SetColumnProperty('carrier_acc_account_id', 0);
  SetColumnProperty('einv_vehicle_id', 0);
  SetColumnProperty('trailer1_einv_vehicle_id', 0);
  SetColumnProperty('trailer2_einv_vehicle_id', 0);
  SetColumnProperty('driver1_einv_driver_id', 0);
  SetColumnProperty('driver2_einv_driver_id', 0);
  LField := Grd.DataSource.DataSet.FindField('status');
  if Assigned(LField) then
    LField.OnGetText := StatusGetText;
  LField := Grd.DataSource.DataSet.FindField('einv_status');
  if Assigned(LField) then
    LField.OnGetText := EinvStatusGetText;

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
  SetColumnTitle('profile_code', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColProfileCode, 'Profile'));
  SetColumnTitle('einv_uuid', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColEinvUuid, 'UUID (ETTN)'));
  SetColumnTitle('einv_status', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColEinvStatus, 'e-Document Status'));
  SetColumnTitle('einv_no', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColEinvNo, 'e-Document No'));
  SetColumnTitle('despatch_time', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColDespatchTime, 'Despatch Time'));
  SetColumnTitle('carrier_code', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColCarrierCode, 'Carrier Code'));
  SetColumnTitle('carrier_name', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColCarrierName, 'Carrier'));
  SetColumnTitle('vehicle_plate', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColVehiclePlate, 'Vehicle Plate'));
  SetColumnTitle('trailer1_plate', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColTrailer1Plate, 'Trailer 1'));
  SetColumnTitle('trailer2_plate', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColTrailer2Plate, 'Trailer 2'));
  SetColumnTitle('driver1_name', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColDriver1Name, 'Driver 1'));
  SetColumnTitle('driver2_name', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColDriver2Name, 'Driver 2'));
  SetColumnTitle('account_e_despatch_active', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColAccountEDespatchActive, 'e-Despatch Customer'));
  SetColumnTitle('einv_xml_valid', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColEinvXmlValid, 'XML Valid'));
  if Assigned(FmniToInvoice) then
    FmniToInvoice.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.MenuToInvoice, 'Create Sales Invoice');
  if Assigned(FmniEInvPreview) then
    FmniEInvPreview.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MenuEInvPreview, 'e-Document Preview');
  if Assigned(FmniEInvValidation) then
    FmniEInvValidation.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MenuEInvValidation, 'e-Document Validation Result');
  if Assigned(FmniEInvSaveXml) then
    FmniEInvSaveXml.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MenuEInvSaveXml, 'Save e-Document XML...');
  if Assigned(FmniEInvRegenerate) then
    FmniEInvRegenerate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.MenuEInvRegenerate, 'Regenerate e-Document XML');
end;

end.
