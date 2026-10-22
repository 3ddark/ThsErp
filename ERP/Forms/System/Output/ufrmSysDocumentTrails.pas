unit ufrmSysDocumentTrails;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, Grid.Types, SharedFormTypes, LocalizationManager,
  SysDocumentTrail, SysDocumentTrail.Service;

type
  // Evrak izi (salt okunur): kaynak belgenin önceki (talep, teklif, sipariş …) ve sonraki (irsaliye, fatura …)
  // belgeleri. Her belge listesinde sağ tık "Evrak İzi" (Ctrl+T) ve belge formunun başlık çubuğundaki düğmeyle açılır.
  // Çift tık / Enter: belge kendi formunda incelemede açılır (o belgenin okuma yetkisi servisinde denetlenir).
  TfrmSysDocumentTrails = class(TfrmGrid<TSysDocumentTrail, TSysDocumentTrailService>)
  private
    FCaptionSuffix: string;
    procedure TrailLevelGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure DocTableGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    function OpenDocument(const ADocTable: string; ADocId: Int64): TForm;
  public
    // Kaynak belge filtresi + başlık (servisin kaynağı form oluşturulmadan önce verilir: grid sorgusu constructor'da kurulur)
    procedure SetSource(const ADocTable: string; ADocId: Int64; const ADocCaption: string);

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;

    class function DocTypeText(const ADocTable: string): string;
    class procedure ShowDocumentTrail(AOwner: TComponent; const ADocTable: string; ADocId: Int64; const ADocCaption: string);
  end;

implementation

{$R *.dfm}

uses
  SlsLookup, PurLookup, SysDecimalPlace.Cache,
  PurRequest, PurRequest.Service, ufrmPurRequestDetail,
  PurQuotation, PurQuotation.Service, ufrmPurQuotationDetail,
  PurOrder, PurOrder.Service, ufrmPurOrderDetail,
  PurReceipt, PurReceipt.Service, ufrmPurReceiptDetail,
  PurInvoice, PurInvoice.Service, ufrmPurInvoiceDetail,
  SlsOffer, SlsOffer.Service, ufrmSlsOfferDetail,
  SlsOrder, SlsOrder.Service, ufrmSlsOrderDetail,
  SlsDispatch, SlsDispatch.Service, ufrmSlsDispatchDetail,
  SlsInvoice, SlsInvoice.Service, ufrmSlsInvoiceDetail,
  SysDocumentTrail.Exception;

class function TfrmSysDocumentTrails.DocTypeText(const ADocTable: string): string;
begin
  if ADocTable = 'pur_request' then
    Result := TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.DocPurRequest, 'Purchase Request')
  else if ADocTable = 'pur_quotation' then
    Result := TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.DocPurQuotation, 'Purchase Quotation')
  else if ADocTable = 'pur_order' then
    Result := TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.DocPurOrder, 'Purchase Order')
  else if ADocTable = 'pur_receipt' then
    Result := TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.DocPurReceipt, 'Goods Receipt')
  else if ADocTable = 'pur_invoice' then
    Result := TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.DocPurInvoice, 'Purchase Invoice')
  else if ADocTable = 'sls_offer' then
    Result := TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.DocSlsOffer, 'Sales Offer')
  else if ADocTable = 'sls_order' then
    Result := TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.DocSlsOrder, 'Sales Order')
  else if ADocTable = 'sls_dispatch' then
    Result := TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.DocSlsDispatch, 'Delivery Note')
  else if ADocTable = 'sls_invoice' then
    Result := TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.DocSlsInvoice, 'Sales Invoice')
  else
    Result := ADocTable;
end;

procedure TfrmSysDocumentTrails.TrailLevelGetText(Sender: TField; var Text: string; DisplayText: Boolean);
var
  LLevel: Integer;
begin
  if Sender.IsNull then
    Exit;
  LLevel := Sender.AsInteger;
  if LLevel = 0 then
    Text := TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.LevelSource, 'This Document')
  else if LLevel < 0 then
    Text := Format(TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.LevelPrevious, 'Previous (%d)'), [-LLevel])
  else
    Text := Format(TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.LevelNext, 'Next (%d)'), [LLevel]);
end;

procedure TfrmSysDocumentTrails.DocTableGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  Text := DocTypeText(Sender.AsString);
end;

// Durum metni belge türüne göre (irsaliye / faturada durum yok)
procedure TfrmSysDocumentTrails.StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
var
  LDocTable: string;
begin
  Text := '';
  if Sender.IsNull then
    Exit;
  LDocTable := Sender.DataSet.FieldByName('doc_table').AsString;
  if LDocTable = 'pur_request' then
    Text := TPurLookup.Text(plkRequestStatus, Sender.AsInteger)
  else if LDocTable = 'pur_quotation' then
    Text := TPurLookup.Text(plkQuotationStatus, Sender.AsInteger)
  else if LDocTable = 'pur_order' then
    Text := TPurLookup.Text(plkOrderStatus, Sender.AsInteger)
  else if LDocTable = 'sls_offer' then
    Text := TSlsLookup.Text(slkOfferStatus, Sender.AsInteger)
  else if LDocTable = 'sls_order' then
    Text := TSlsLookup.Text(slkOrderStatus, Sender.AsInteger)
  else if LDocTable = 'sls_dispatch' then
    Text := TSlsLookup.Text(slkDispatchStatus, Sender.AsInteger);
end;

procedure TfrmSysDocumentTrails.SetSource(const ADocTable: string; ADocId: Int64; const ADocCaption: string);
begin
  if (Service.SourceTable <> LowerCase(ADocTable)) or (Service.SourceId <> ADocId) then
    Service.SetSource(ADocTable, ADocId);
  AddFixedFilter('source_table', Service.SourceTable);
  AddFixedFilter('source_id', ADocId);
  FCaptionSuffix := ' - ' + ADocCaption;
end;

class procedure TfrmSysDocumentTrails.ShowDocumentTrail(AOwner: TComponent; const ADocTable: string; ADocId: Int64;
  const ADocCaption: string);
var
  LFrm: TfrmSysDocumentTrails;
  LSvc: TSysDocumentTrailService;
begin
  LSvc := TSysDocumentTrailService.Create;
  try
    LSvc.SetSource(ADocTable, ADocId);
  except
    LSvc.Free;
    raise;
  end;
  LFrm := TfrmSysDocumentTrails.Create(AOwner, LSvc, TSysDocumentTrail.Create);
  LFrm.SetSource(ADocTable, ADocId, ADocCaption);
  LFrm.Show;
end;

// Belge kendi servisiyle okunur (okuma yetkisi orada denetlenir); form servisi ve kaydı sahiplenir
function TfrmSysDocumentTrails.OpenDocument(const ADocTable: string; ADocId: Int64): TForm;

  procedure CheckFound(AEntity: TObject);
  begin
    if not Assigned(AEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [ADocId]));
  end;

var
  LPurRequestSvc: TPurRequestService;
  LPurRequest: TPurRequest;
  LPurQuotationSvc: TPurQuotationService;
  LPurQuotation: TPurQuotation;
  LPurOrderSvc: TPurOrderService;
  LPurOrder: TPurOrder;
  LPurReceiptSvc: TPurReceiptService;
  LPurReceipt: TPurReceipt;
  LPurInvoiceSvc: TPurInvoiceService;
  LPurInvoice: TPurInvoice;
  LSlsOfferSvc: TSlsOfferService;
  LSlsOffer: TSlsOffer;
  LSlsOrderSvc: TSlsOrderService;
  LSlsOrder: TSlsOrder;
  LSlsDispatchSvc: TSlsDispatchService;
  LSlsDispatch: TSlsDispatch;
  LSlsInvoiceSvc: TSlsInvoiceService;
  LSlsInvoice: TSlsInvoice;
begin
  if ADocTable = 'pur_request' then
  begin
    LPurRequestSvc := TPurRequestService.Create;
    try
      LPurRequest := LPurRequestSvc.BusinessFindById(ADocId, False, False, True);
      CheckFound(LPurRequest);
    except
      LPurRequestSvc.Free;
      raise;
    end;
    Result := TfrmPurRequestDetail.Create(Self, LPurRequestSvc, LPurRequest, ifmRewiev, nil, ivmNormal, True);
  end
  else if ADocTable = 'pur_quotation' then
  begin
    LPurQuotationSvc := TPurQuotationService.Create;
    try
      LPurQuotation := LPurQuotationSvc.BusinessFindById(ADocId, False, False, True);
      CheckFound(LPurQuotation);
    except
      LPurQuotationSvc.Free;
      raise;
    end;
    Result := TfrmPurQuotationDetail.Create(Self, LPurQuotationSvc, LPurQuotation, ifmRewiev, nil, ivmNormal, True);
  end
  else if ADocTable = 'pur_order' then
  begin
    LPurOrderSvc := TPurOrderService.Create;
    try
      LPurOrder := LPurOrderSvc.BusinessFindById(ADocId, False, False, True);
      CheckFound(LPurOrder);
    except
      LPurOrderSvc.Free;
      raise;
    end;
    Result := TfrmPurOrderDetail.Create(Self, LPurOrderSvc, LPurOrder, ifmRewiev, nil, ivmNormal, True);
  end
  else if ADocTable = 'pur_receipt' then
  begin
    LPurReceiptSvc := TPurReceiptService.Create;
    try
      LPurReceipt := LPurReceiptSvc.BusinessFindById(ADocId, False, False, True);
      CheckFound(LPurReceipt);
    except
      LPurReceiptSvc.Free;
      raise;
    end;
    Result := TfrmPurReceiptDetail.Create(Self, LPurReceiptSvc, LPurReceipt, ifmRewiev, nil, ivmNormal, True);
  end
  else if ADocTable = 'pur_invoice' then
  begin
    LPurInvoiceSvc := TPurInvoiceService.Create;
    try
      LPurInvoice := LPurInvoiceSvc.BusinessFindById(ADocId, False, False, True);
      CheckFound(LPurInvoice);
    except
      LPurInvoiceSvc.Free;
      raise;
    end;
    Result := TfrmPurInvoiceDetail.Create(Self, LPurInvoiceSvc, LPurInvoice, ifmRewiev, nil, ivmNormal, True);
  end
  else if ADocTable = 'sls_offer' then
  begin
    LSlsOfferSvc := TSlsOfferService.Create;
    try
      LSlsOffer := LSlsOfferSvc.BusinessFindById(ADocId, False, False, True);
      CheckFound(LSlsOffer);
    except
      LSlsOfferSvc.Free;
      raise;
    end;
    Result := TfrmSlsOfferDetail.Create(Self, LSlsOfferSvc, LSlsOffer, ifmRewiev, nil, ivmNormal, True);
  end
  else if ADocTable = 'sls_order' then
  begin
    LSlsOrderSvc := TSlsOrderService.Create;
    try
      LSlsOrder := LSlsOrderSvc.BusinessFindById(ADocId, False, False, True);
      CheckFound(LSlsOrder);
    except
      LSlsOrderSvc.Free;
      raise;
    end;
    Result := TfrmSlsOrderDetail.Create(Self, LSlsOrderSvc, LSlsOrder, ifmRewiev, nil, ivmNormal, True);
  end
  else if ADocTable = 'sls_dispatch' then
  begin
    LSlsDispatchSvc := TSlsDispatchService.Create;
    try
      LSlsDispatch := LSlsDispatchSvc.BusinessFindById(ADocId, False, False, True);
      CheckFound(LSlsDispatch);
    except
      LSlsDispatchSvc.Free;
      raise;
    end;
    Result := TfrmSlsDispatchDetail.Create(Self, LSlsDispatchSvc, LSlsDispatch, ifmRewiev, nil, ivmNormal, True);
  end
  else if ADocTable = 'sls_invoice' then
  begin
    LSlsInvoiceSvc := TSlsInvoiceService.Create;
    try
      LSlsInvoice := LSlsInvoiceSvc.BusinessFindById(ADocId, False, False, True);
      CheckFound(LSlsInvoice);
    except
      LSlsInvoiceSvc.Free;
      raise;
    end;
    Result := TfrmSlsInvoiceDetail.Create(Self, LSlsInvoiceSvc, LSlsInvoice, ifmRewiev, nil, ivmNormal, True);
  end
  else
    raise ESysDocumentTrailExceptionUnknownDocument.Create;
end;

function TfrmSysDocumentTrails.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) and Assigned(Table) and (Table.DocId > 0) then
    Result := OpenDocument(Table.DocTable, Table.DocId);
end;

procedure TfrmSysDocumentTrails.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('source_table', 0);
  SetColumnProperty('source_id', 0);
  SetColumnProperty('doc_id', 0);
  SetColumnProperty('acc_account_id', 0);

  LField := Grd.DataSource.DataSet.FindField('trail_level');
  if Assigned(LField) then
    LField.OnGetText := TrailLevelGetText;
  LField := Grd.DataSource.DataSet.FindField('doc_table');
  if Assigned(LField) then
    LField.OnGetText := DocTableGetText;
  LField := Grd.DataSource.DataSet.FindField('status');
  if Assigned(LField) then
    LField.OnGetText := StatusGetText;
  LField := Grd.DataSource.DataSet.FindField('total_amount');
  if LField is TNumericField then
    TNumericField(LField).DisplayFormat := TDecimalPlaces.TotalFormat;
end;

procedure TfrmSysDocumentTrails.FormShow(Sender: TObject);
begin
  inherited;
  if Assigned(BtnAdd) then
    BtnAdd.Visible := False;
  if Assigned(mniDuplicate) then
    mniDuplicate.Visible := False;
  ApplyLocalization;
end;

procedure TfrmSysDocumentTrails.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.TitlePlural, 'Document Trail') + FCaptionSuffix;

  SetColumnTitle('trail_level',  TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.ColTrailLevel, 'Level'));
  SetColumnTitle('doc_table',    TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.ColDocTable, 'Document Type'));
  SetColumnTitle('doc_no',       TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.ColDocNo, 'Document No'));
  SetColumnTitle('doc_date',     TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.ColDocDate, 'Document Date'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.ColAccountCode, 'Account Code'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.ColAccountName, 'Account / Requester'));
  SetColumnTitle('status',       TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.ColStatus, 'Status'));
  SetColumnTitle('currency',     TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.ColCurrency, 'Currency'));
  SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.ColTotalAmount, 'Total Amount'));
end;

// Her belge listesinde ve belge formunda "Evrak İzi": izi olan belge tablosu ve kaynak belgeyi okuma yetkisi
function DocumentTrailAvailable(const ATableName: string): Boolean;
var
  LSvc: TSysDocumentTrailService;
begin
  Result := False;
  if not TSysDocumentTrailService.IsTrailDocument(ATableName) then
    Exit;
  LSvc := TSysDocumentTrailService.Create;
  try
    Result := LSvc.UoW.IsAuthorized(TSysDocumentTrailService.PermissionCodeOf(ATableName), ptRead, True);
  finally
    LSvc.Free;
  end;
end;

procedure DocumentTrailShow(AOwner: TComponent; const ATableName: string; ADocId: Int64; const ADocCaption: string);
begin
  TfrmSysDocumentTrails.ShowDocumentTrail(AOwner, ATableName, ADocId, ADocCaption);
end;

initialization
  GDocumentTrailAvailable := DocumentTrailAvailable;
  GDocumentTrailShow := DocumentTrailShow;

end.
