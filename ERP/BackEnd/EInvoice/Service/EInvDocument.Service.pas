unit EInvDocument.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EInvDocument.Repository, EInvDocument, EInvDocument.Exception, EInvSeries, EInvSeries.Repository,
  ApiService.Config, EInvIntegrator;

type
  TEInvDocumentService = class(TCrudService<TEInvDocument>)
  private
    FRepo: IRepository<TEInvDocument>;

    procedure DoAdd(AEntity: TEInvDocument);
    procedure DoUpdate(AEntity: TEInvDocument);
    procedure DoDelete(AId: Int64);

    function SeriesRepo: TEInvSeriesRepository;
    // Belge türünün (seri kapsamı) entegratörü: e-Belge Ayarları -> API servisi -> sağlayıcı. Eksikse yerelleştirilmiş hata
    function IntegratorFor(AScope: Integer; out AConfig: TApiServiceConfig): IEInvIntegrator;
    function DoSend(const ASource: string; AId: Int64; APermission: Integer; APermissionControl: Boolean): string;
    function DoQueryStatus(const ASource: string; AId: Int64; APermission: Integer; APermissionControl: Boolean): string;

  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEInvDocument; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEInvDocument>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEInvDocument; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEInvDocument; override;

    procedure Add(AEntity: TEInvDocument); override;
    procedure Update(AEntity: TEInvDocument); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvDocument; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvDocument>; override;
    procedure BusinessInsert(AEntity: TEInvDocument; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEInvDocument; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEInvDocument; AWithBegin, AWithCommit, APermissionControl: Boolean); override;

    // Fatura kaydında (TSlsInvoiceService.AfterDocumentSaved, açık transaction içinde): senaryolu faturanın UBL XML'i
    // üretilir, GİB şemasıyla doğrulanır ve einv_document'e yazılır; kağıt faturada kayıt silinir; gönderilmiş belgenin
    // XML'i değişmez. Veri / şema sorunları kaydı engellemez (is_valid = false + mesaj). GİB numarası henüz verilmemişse
    // (gönderimde verilir) önizleme numarası: varsayılan seri + yıl + 000000000.
    class procedure GenerateForInvoice(ARepo: TEInvDocumentRepository; ASeriesRepo: TEInvSeriesRepository;
      AInvoiceId: Int64); static;
    // Fatura listesi: kayıtlı XML (satış faturası okuma yetkisi); yoksa nil
    function BusinessFindByInvoice(AInvoiceId: Int64; APermissionControl: Boolean): TEInvDocument;
    // Yeniden üret (firma / cari bilgisi değiştiyse): satış faturası güncelleme yetkisi; gönderilmiş belgede ret
    procedure BusinessRegenerate(AInvoiceId: Int64; APermissionControl: Boolean);
    // İrsaliye kaydında (TSlsDispatchService.AfterDocumentSaved): GenerateForInvoice'un e-İrsaliye karşılığı (fiyatsız
    // DespatchAdvice; seri kapsamı e-İrsaliye)
    class procedure GenerateForDispatch(ARepo: TEInvDocumentRepository; ASeriesRepo: TEInvSeriesRepository;
      ADispatchId: Int64); static;
    // İrsaliye listesi: kayıtlı XML (satış irsaliyesi okuma yetkisi); yoksa nil
    function BusinessFindByDispatch(ADispatchId: Int64; APermissionControl: Boolean): TEInvDocument;
    // Yeniden üret: satış irsaliyesi güncelleme yetkisi; gönderilmiş belgede ret
    procedure BusinessRegenerateDispatch(ADispatchId: Int64; APermissionControl: Boolean);
    // GİB görselliğiyle HTML (fatura general.xslt, e-İrsaliye irsaliye.xslt)
    class function ToHtml(ADocument: TEInvDocument): string; static;

    // ---- Özel entegratör (sağlayıcı e-Belge Ayarları'ndaki API servisinden; EInvIntegrator)
    // e-Belge Gönder (kullanıcı komutu, kayıtta otomatik değil; belgenin güncelleme yetkisi):
    //   1) belge kilitlenir; durum taslak / hata olmalı; GİB numarası yoksa varsayılan seri + yıl + sayaç verilir, XML yeniden
    //      üretilir; XML şemaya uygun değilse, gönderici GB / alıcı PK etiketi eksikse her şey geri alınır; durum 2 (kuyrukta)
    //   2) belge entegratöre gönderilir (transaction dışında)
    //   3) sonuç yazılır: durum 3 gönderildi / 6 hata (+ einv_document gönderim bilgisi). Hata mesajla yükseltilir.
    // Dönen: kullanıcı mesajı
    function BusinessSendInvoice(AInvoiceId: Int64; APermissionControl: Boolean): string;
    function BusinessSendDispatch(ADispatchId: Int64; APermissionControl: Boolean): string;
    // Gönderilmiş belgenin entegratördeki durumu; uygulama durumu eşlenir (kabul / red / iptal geri alınmaz)
    function BusinessQueryInvoiceStatus(AInvoiceId: Int64; APermissionControl: Boolean): string;
    function BusinessQueryDispatchStatus(ADispatchId: Int64; APermissionControl: Boolean): string;
    // GİB mükellef sorgusu (e-Fatura servisi; cari okuma yetkisi): e-Fatura / e-İrsaliye PK / GB etiketleri
    function BusinessQueryTaxpayer(const ATaxNo: string; APermissionControl: Boolean): TEInvTaxpayerInfo;
    // Belge türü servisinin bağlantı + kimlik doğrulama denemesi (e-Belge Ayarları okuma yetkisi)
    function BusinessTestConnection(AScope: Integer; APermissionControl: Boolean): string;
  end;

implementation

uses
  SysPermission.Service, EInvLookup, EInvUbl.Model, EInvUbl.Builder, EInvUbl.Validator, SlsInvoice.Exception,
  SlsDispatch.Exception, System.DateUtils;

constructor TEInvDocumentService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEInvDocument, TEInvDocumentRepository>;
  Self.PermissionCode := PERMISSION_SLS_INVOICE;
end;

destructor TEInvDocumentService.Destroy;
begin
  inherited;
end;

class procedure TEInvDocumentService.GenerateForInvoice(ARepo: TEInvDocumentRepository; ASeriesRepo: TEInvSeriesRepository;
  AInvoiceId: Int64);
var
  LData: TEInvUblInvoice;
  LProblems: TStringList;
  LXml, LSchemaMessage, LSeries: string;
  LSeriesId: Int64;
  LValid: Boolean;
begin
  if TEInvLookup.IsEInvLocked(ARepo.InvoiceEInvStatus(AInvoiceId)) then
    Exit;
  LData := ARepo.LoadSalesInvoice(AInvoiceId);
  try
    if not Assigned(LData) or (LData.ProfileCode = '') then
    begin
      ARepo.DeleteByInvoiceId(AInvoiceId);
      Exit;
    end;
    if LData.EInvNo = '' then
    begin
      LSeries := ASeriesRepo.DefaultSeries(TEInvLookup.SeriesScopeOf(LData.ProfileCode), LSeriesId);
      LData.EInvNo := TEInvLookup.MakeEInvNo(LSeries, YearOf(LData.IssueDate), 0);
    end;
    LProblems := TStringList.Create;
    try
      try
        LXml := TEInvUblBuilder.BuildInvoice(LData, LProblems);
        LValid := TEInvUblValidator.Validate(LXml, LSchemaMessage);
        if not LValid then
          LProblems.Add(LSchemaMessage);
      except
        // XML üretilemedi (beklenmeyen veri): kayıt engellenmez, sorun saklanır
        on E: Exception do
        begin
          LProblems.Add(E.Message);
          if LXml = '' then
            LXml := '<?xml version="1.0" encoding="UTF-8"?>';
        end;
      end;
      ARepo.SaveForInvoice(AInvoiceId, LData.Uuid, LData.EInvNo, LXml, LProblems.Count = 0, Trim(LProblems.Text));
    finally
      LProblems.Free;
    end;
  finally
    LData.Free;
  end;
end;

class procedure TEInvDocumentService.GenerateForDispatch(ARepo: TEInvDocumentRepository; ASeriesRepo: TEInvSeriesRepository;
  ADispatchId: Int64);
var
  LData: TEInvUblDespatch;
  LProblems: TStringList;
  LXml, LSchemaMessage, LSeries: string;
  LSeriesId: Int64;
  LValid: Boolean;
begin
  if TEInvLookup.IsEInvLocked(ARepo.DispatchEInvStatus(ADispatchId)) then
    Exit;
  LData := ARepo.LoadSalesDispatch(ADispatchId);
  try
    if not Assigned(LData) or (LData.ProfileCode = '') then
    begin
      ARepo.DeleteByDispatchId(ADispatchId);
      Exit;
    end;
    if LData.EInvNo = '' then
    begin
      LSeries := ASeriesRepo.DefaultSeries(EINV_SERIES_DESPATCH, LSeriesId);
      LData.EInvNo := TEInvLookup.MakeEInvNo(LSeries, YearOf(LData.IssueDate), 0);
    end;
    LProblems := TStringList.Create;
    try
      try
        LXml := TEInvUblBuilder.BuildDespatch(LData, LProblems);
        LValid := TEInvUblValidator.Validate(LXml, LSchemaMessage);
        if not LValid then
          LProblems.Add(LSchemaMessage);
      except
        on E: Exception do
        begin
          LProblems.Add(E.Message);
          if LXml = '' then
            LXml := '<?xml version="1.0" encoding="UTF-8"?>';
        end;
      end;
      ARepo.SaveForDispatch(ADispatchId, LData.Uuid, LData.EInvNo, LXml, LProblems.Count = 0, Trim(LProblems.Text));
    finally
      LProblems.Free;
    end;
  finally
    LData.Free;
  end;
end;

function TEInvDocumentService.BusinessFindByDispatch(ADispatchId: Int64; APermissionControl: Boolean): TEInvDocument;
begin
  Self.UoW.EnsureAuthorized(PERMISSION_SLS_DISPATCH, ptRead, APermissionControl);
  Result := TEInvDocumentRepository(FRepo).FindByDispatchId(ADispatchId);
end;

procedure TEInvDocumentService.BusinessRegenerateDispatch(ADispatchId: Int64; APermissionControl: Boolean);
var
  LWithBegin: Boolean;
begin
  LWithBegin := not Self.UoW.InTransaction;
  try
    Self.UoW.EnsureAuthorized(PERMISSION_SLS_DISPATCH, ptUpdate, APermissionControl);
    if TEInvLookup.IsEInvLocked(TEInvDocumentRepository(FRepo).DispatchEInvStatus(ADispatchId)) then
      raise ESlsDispatchExceptionEInvLocked.Create;
    if LWithBegin then
      Self.UoW.BeginTransaction;
    GenerateForDispatch(TEInvDocumentRepository(FRepo),
      TEInvSeriesRepository(Self.UoW.GetRepository<TEInvSeries, TEInvSeriesRepository>), ADispatchId);
    if LWithBegin and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if LWithBegin and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TEInvDocumentService.BusinessFindByInvoice(AInvoiceId: Int64; APermissionControl: Boolean): TEInvDocument;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);
  Result := TEInvDocumentRepository(FRepo).FindByInvoiceId(AInvoiceId);
end;

procedure TEInvDocumentService.BusinessRegenerate(AInvoiceId: Int64; APermissionControl: Boolean);
var
  LWithBegin: Boolean;
begin
  LWithBegin := not Self.UoW.InTransaction;
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);
    if TEInvLookup.IsEInvLocked(TEInvDocumentRepository(FRepo).InvoiceEInvStatus(AInvoiceId)) then
      raise ESlsInvoiceExceptionEInvLocked.Create;
    if LWithBegin then
      Self.UoW.BeginTransaction;
    GenerateForInvoice(TEInvDocumentRepository(FRepo),
      TEInvSeriesRepository(Self.UoW.GetRepository<TEInvSeries, TEInvSeriesRepository>), AInvoiceId);
    if LWithBegin and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if LWithBegin and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

class function TEInvDocumentService.ToHtml(ADocument: TEInvDocument): string;
begin
  Result := TEInvUblValidator.ToHtml(ADocument.XmlContent);
end;

function TEInvDocumentService.SeriesRepo: TEInvSeriesRepository;
begin
  Result := TEInvSeriesRepository(Self.UoW.GetRepository<TEInvSeries, TEInvSeriesRepository>);
end;

function TEInvDocumentService.IntegratorFor(AScope: Integer; out AConfig: TApiServiceConfig): IEInvIntegrator;
var
  LKind: string;
begin
  LKind := TEInvDocumentRepository(FRepo).ServiceKindOf(AScope);
  if LKind = '' then
    raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.NoService,
      '%s: no integration (API) service is selected in e-Document Settings.'), [TEInvLookup.Text(elkSeriesScope, AScope)]));
  AConfig := TApiServiceConfigs.Get(LKind);
  if not AConfig.Found or not AConfig.Active then
    raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.ServiceInactive,
      'Integration service "%s" is not active.'), [LKind]));
  if not TEInvIntegrators.IsRegistered(AConfig.ProviderCode) then
    raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.UnknownProvider,
      'Integration service "%s": provider "%s" is not supported (supported: %s).'),
      [LKind, AConfig.ProviderCode, string.Join(', ', TEInvIntegrators.ProviderCodes)]));
  Result := TEInvIntegrators.CreateFor(AConfig);
end;

function TEInvDocumentService.DoSend(const ASource: string; AId: Int64; APermission: Integer;
  APermissionControl: Boolean): string;
var
  LRepo: TEInvDocumentRepository;
  LIsInvoice, LWithBegin, LIsExport: Boolean;
  LState: TEInvSendState;
  LScope, LYear: Integer;
  LConfig: TApiServiceConfig;
  LIntegrator: IEInvIntegrator;
  LRequest: TEInvSendRequest;
  LResult: TEInvSendResult;
  LSeries, LError: string;
  LSeriesId: Int64;
  LDoc: TEInvDocument;
  LInvoice: TEInvUblInvoice;
  LDespatch: TEInvUblDespatch;
begin
  LRepo := TEInvDocumentRepository(FRepo);
  LIsInvoice := ASource = EINV_SOURCE_INVOICE;
  LRequest := Default(TEInvSendRequest);
  LIsExport := False;

  // ---- 1) hazırlık: numara + XML + etiketler; durum 2 (kuyrukta)
  LWithBegin := not Self.UoW.InTransaction;
  try
    Self.UoW.EnsureAuthorized(APermission, ptUpdate, APermissionControl);
    if LWithBegin then
      Self.UoW.BeginTransaction;
    if not LRepo.ReadSendState(ASource, AId, True, LState) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));
    if LState.ProfileCode = '' then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.NotEDocument,
        'This document has no e-document profile (paper document).'));
    if not (LState.Status in [EINV_STATUS_DRAFT, EINV_STATUS_ERROR]) then
      raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.NotSendable,
        'Only draft or failed e-documents can be sent (current status: %s).'),
        [TEInvLookup.Text(elkEInvStatus, LState.Status)]));
    if LIsInvoice then
      LScope := TEInvLookup.SeriesScopeOf(LState.ProfileCode)
    else
      LScope := EINV_SERIES_DESPATCH;
    LIntegrator := IntegratorFor(LScope, LConfig);

    // etiketler numara verilmeden önce denetlenir (eksikse numara harcanmaz)
    if LIsInvoice then
    begin
      LInvoice := LRepo.LoadSalesInvoice(AId);
      try
        LRequest.SenderAlias := LInvoice.SenderAlias;
        LRequest.ReceiverAlias := LInvoice.ReceiverAlias;
        LRequest.ReceiverTaxNo := LInvoice.Customer.TaxNo;
        LIsExport := LInvoice.IsExport;
      finally
        LInvoice.Free;
      end;
      if LScope = EINV_SERIES_ARCHIVE then
        LRequest.Kind := edkArchive
      else
        LRequest.Kind := edkInvoice;
    end
    else
    begin
      LDespatch := LRepo.LoadSalesDispatch(AId);
      try
        LRequest.SenderAlias := LDespatch.SenderAlias;
        LRequest.ReceiverAlias := LDespatch.ReceiverAlias;
        LRequest.ReceiverTaxNo := LDespatch.Customer.TaxNo;
      finally
        LDespatch.Free;
      end;
      LRequest.Kind := edkDespatch;
    end;
    // e-Arşiv GİB'e raporlanır (etiket yok); IHRACAT'ta alıcı GTB
    if LScope <> EINV_SERIES_ARCHIVE then
    begin
      if LRequest.SenderAlias = '' then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.NoSenderAlias,
          'Sender alias (GB) is not set in e-Document Settings (%s).'), [TEInvLookup.Text(elkSeriesScope, LScope)]));
      if (LRequest.ReceiverAlias = '') and not LIsExport then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.NoReceiverAlias,
          'The account has no %s mailbox alias (PK). Query it from GIB on the account card.'),
          [TEInvLookup.Text(elkSeriesScope, LScope)]));
    end;

    // GİB numarası bir kez verilir (hata sonrası yeniden gönderimde aynı numara)
    if LState.EInvNo = '' then
    begin
      LSeries := SeriesRepo.DefaultSeries(LScope, LSeriesId);
      if LSeriesId <= 0 then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.NoSeries,
          '%s: no active series is selected in e-Document Settings.'), [TEInvLookup.Text(elkSeriesScope, LScope)]));
      LYear := YearOf(LState.IssueDate);
      LState.EInvNo := TEInvLookup.MakeEInvNo(LSeries, LYear, SeriesRepo.NextNumber(LSeriesId, LYear));
      LRepo.SetEInvNo(ASource, AId, LState.EInvNo);
    end;

    if LIsInvoice then
    begin
      GenerateForInvoice(LRepo, SeriesRepo, AId);
      LDoc := LRepo.FindByInvoiceId(AId);
    end
    else
    begin
      GenerateForDispatch(LRepo, SeriesRepo, AId);
      LDoc := LRepo.FindByDispatchId(AId);
    end;
    try
      if not Assigned(LDoc) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.NotEDocument,
          'This document has no e-document profile (paper document).'));
      if not LDoc.IsValid then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.XmlInvalid,
          'The e-document XML is not valid and cannot be sent:') + sLineBreak + sLineBreak + LDoc.ValidationMessage);
      LRequest.Uuid := LDoc.EinvUuid;
      LRequest.EInvNo := LDoc.EinvNo;
      LRequest.Xml := LDoc.XmlContent;
    finally
      LDoc.Free;
    end;

    LRepo.SetEInvStatus(ASource, AId, EINV_STATUS_QUEUED);
    if LWithBegin and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if LWithBegin and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;

  // ---- 2) gönderim (ağ çağrısı transaction dışında; açık bir dış transaction varsa onun içinde kalır)
  LError := '';
  try
    LResult := LIntegrator.Send(LRequest);
  except
    on E: Exception do
      LError := E.Message;
  end;
  LIntegrator := nil;

  // ---- 3) sonuç
  LWithBegin := not Self.UoW.InTransaction;
  try
    if LWithBegin then
      Self.UoW.BeginTransaction;
    if LError = '' then
    begin
      LRepo.SetEInvStatus(ASource, AId, EINV_STATUS_SENT);
      LRepo.SaveTransmission(ASource, AId, LConfig.ProviderCode, LResult.ProviderRef, True, 0, LResult.Message);
    end
    else
    begin
      LRepo.SetEInvStatus(ASource, AId, EINV_STATUS_ERROR);
      LRepo.SaveTransmission(ASource, AId, LConfig.ProviderCode, '', False, 0, LError);
    end;
    if LWithBegin and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if LWithBegin and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;

  if LError <> '' then
    raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.SendFailed,
      'The e-document could not be sent (status set to error): %s'), [LError]));
  Result := Format(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.Sent,
    'The e-document %s was sent. Reference: %s'), [LRequest.EInvNo, LResult.ProviderRef]);
end;

function TEInvDocumentService.DoQueryStatus(const ASource: string; AId: Int64; APermission: Integer;
  APermissionControl: Boolean): string;
var
  LRepo: TEInvDocumentRepository;
  LState: TEInvSendState;
  LScope, LNewStatus: Integer;
  LKind: TEInvDocKind;
  LConfig: TApiServiceConfig;
  LIntegrator: IEInvIntegrator;
  LRemote: TEInvStatusResult;
  LWithBegin: Boolean;
begin
  LRepo := TEInvDocumentRepository(FRepo);
  Self.UoW.EnsureAuthorized(APermission, ptUpdate, APermissionControl);
  if not LRepo.ReadSendState(ASource, AId, False, LState) then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));
  if (LState.ProfileCode = '') or (LState.Status in [0, EINV_STATUS_DRAFT]) or (LState.Uuid = '') then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.NotSent,
      'The e-document has not been sent yet.'));
  if ASource = EINV_SOURCE_INVOICE then
  begin
    LScope := TEInvLookup.SeriesScopeOf(LState.ProfileCode);
    if LScope = EINV_SERIES_ARCHIVE then
      LKind := edkArchive
    else
      LKind := edkInvoice;
  end
  else
  begin
    LScope := EINV_SERIES_DESPATCH;
    LKind := edkDespatch;
  end;
  LIntegrator := IntegratorFor(LScope, LConfig);
  LRemote := LIntegrator.QueryStatus(LKind, LState.Uuid);
  LIntegrator := nil;

  // uzak durum -> einv_status; kesinleşmiş durum (kabul / red / iptal) "gönderildi"ye düşürülmez
  case LRemote.Status of
    ersProcessing, ersDelivered: LNewStatus := EINV_STATUS_SENT;
    ersAccepted: LNewStatus := EINV_STATUS_ACCEPTED;
    ersRejected: LNewStatus := EINV_STATUS_REJECTED;
    ersFailed: LNewStatus := EINV_STATUS_ERROR;
    ersCancelled: LNewStatus := EINV_STATUS_CANCELLED;
  else
    LNewStatus := LState.Status;
  end;
  if (LNewStatus = EINV_STATUS_SENT) and
    (LState.Status in [EINV_STATUS_ACCEPTED, EINV_STATUS_REJECTED, EINV_STATUS_CANCELLED]) then
    LNewStatus := LState.Status;

  LWithBegin := not Self.UoW.InTransaction;
  try
    if LWithBegin then
      Self.UoW.BeginTransaction;
    if LNewStatus <> LState.Status then
      LRepo.SetEInvStatus(ASource, AId, LNewStatus);
    LRepo.SaveTransmission(ASource, AId, LConfig.ProviderCode, '', False, LRemote.Code, LRemote.Description);
    if LWithBegin and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if LWithBegin and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
  Result := Format(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.StatusResult,
    'Status: %s' + sLineBreak + 'Provider: %d %s'), [TEInvLookup.Text(elkEInvStatus, LNewStatus), LRemote.Code,
    LRemote.Description]);
end;

function TEInvDocumentService.BusinessSendInvoice(AInvoiceId: Int64; APermissionControl: Boolean): string;
begin
  Result := DoSend(EINV_SOURCE_INVOICE, AInvoiceId, PERMISSION_SLS_INVOICE, APermissionControl);
end;

function TEInvDocumentService.BusinessSendDispatch(ADispatchId: Int64; APermissionControl: Boolean): string;
begin
  Result := DoSend(EINV_SOURCE_DISPATCH, ADispatchId, PERMISSION_SLS_DISPATCH, APermissionControl);
end;

function TEInvDocumentService.BusinessQueryInvoiceStatus(AInvoiceId: Int64; APermissionControl: Boolean): string;
begin
  Result := DoQueryStatus(EINV_SOURCE_INVOICE, AInvoiceId, PERMISSION_SLS_INVOICE, APermissionControl);
end;

function TEInvDocumentService.BusinessQueryDispatchStatus(ADispatchId: Int64; APermissionControl: Boolean): string;
begin
  Result := DoQueryStatus(EINV_SOURCE_DISPATCH, ADispatchId, PERMISSION_SLS_DISPATCH, APermissionControl);
end;

function TEInvDocumentService.BusinessQueryTaxpayer(const ATaxNo: string; APermissionControl: Boolean): TEInvTaxpayerInfo;
var
  LTaxNo: string;
  LChar: Char;
  LValid: Boolean;
  LConfig: TApiServiceConfig;
begin
  Self.UoW.EnsureAuthorized(PERMISSION_ACC_ACCOUNT, ptRead, APermissionControl);
  LTaxNo := Trim(ATaxNo);
  LValid := Length(LTaxNo) in [10, 11];
  for LChar in LTaxNo do
    LValid := LValid and CharInSet(LChar, ['0'..'9']);
  if not LValid then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.TaxNoInvalid,
      'Enter a 10-digit tax number or an 11-digit citizenship number.'));
  Result := IntegratorFor(EINV_SERIES_INVOICE, LConfig).QueryTaxpayer(LTaxNo);
end;

function TEInvDocumentService.BusinessTestConnection(AScope: Integer; APermissionControl: Boolean): string;
var
  LConfig: TApiServiceConfig;
begin
  Self.UoW.EnsureAuthorized(PERMISSION_EINV_DOCUMENT_SETTING, ptRead, APermissionControl);
  Result := Format(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.ConnectionOk,
    'Connection succeeded (%s).'), [IntegratorFor(AScope, LConfig).TestConnection]);
end;



procedure TEInvDocumentService.ValidateBusinessRules(AEntity: TEInvDocument; AOperation: TCrudOperation);
begin
  // kayıt fatura / irsaliye servisinden (GenerateForInvoice / GenerateForDispatch) yazılır; elle ekleme / değiştirme yok
end;

procedure TEInvDocumentService.DoAdd(AEntity: TEInvDocument);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEInvDocumentService.DoUpdate(AEntity: TEInvDocument);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEInvDocumentService.DoDelete(AId: Int64);
var
  LEntity: TEInvDocument;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    FRepo.Delete(LEntity);
  finally
    LEntity.Free;
  end;
end;

function TEInvDocumentService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvDocument>;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.Find(AFilter, ALock);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TEInvDocumentService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvDocument;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.FindById(AId, ALock);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TEInvDocumentService.BusinessInsert(AEntity: TEInvDocument; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoAdd(AEntity);

    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TEInvDocumentService.BusinessUpdate(AEntity: TEInvDocument; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoUpdate(AEntity);

    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TEInvDocumentService.BusinessDelete(AEntity: TEInvDocument; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptDelete, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoDelete(AEntity.Id);

    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TEInvDocumentService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEInvDocumentService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEInvDocument>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEInvDocumentService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEInvDocument;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEInvDocumentService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEInvDocument;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEInvDocumentService.Add(AEntity: TEInvDocument);
begin
  DoAdd(AEntity);
end;

procedure TEInvDocumentService.Update(AEntity: TEInvDocument);
begin
  DoUpdate(AEntity);
end;

procedure TEInvDocumentService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
