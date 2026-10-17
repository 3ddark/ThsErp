unit EInvDocument.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EInvDocument.Repository, EInvDocument, EInvDocument.Exception, EInvSeries, EInvSeries.Repository;

type
  TEInvDocumentService = class(TCrudService<TEInvDocument>)
  private
    FRepo: IRepository<TEInvDocument>;

    procedure DoAdd(AEntity: TEInvDocument);
    procedure DoUpdate(AEntity: TEInvDocument);
    procedure DoDelete(AId: Int64);

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
    // GİB görselliğiyle (general.xslt) HTML
    class function ToHtml(ADocument: TEInvDocument): string; static;
  end;

implementation

uses
  SysPermission.Service, EInvLookup, EInvUbl.Model, EInvUbl.Builder, EInvUbl.Validator, SlsInvoice.Exception, System.DateUtils;

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



procedure TEInvDocumentService.ValidateBusinessRules(AEntity: TEInvDocument; AOperation: TCrudOperation);
begin
  // kayıt fatura servisinden (GenerateForInvoice) yazılır; elle ekleme / değiştirme yok
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
