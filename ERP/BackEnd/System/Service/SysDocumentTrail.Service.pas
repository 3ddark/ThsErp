unit SysDocumentTrail.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysDocumentTrail.Repository, SysDocumentTrail, SysDocumentTrail.Exception;

type
  // Evrak izi (salt okunur): bir belgenin önceki / sonraki belgeleri (vw_sys_document_trail, fn_document_trail).
  // Ayrı yetki kodu yok: okuma yetkisi kaynak belgenin kodudur (SetSource), izde yalnız kullanıcının okuyabildiği
  // belge türleri listelenir.
  TSysDocumentTrailService = class(TCrudService<TSysDocumentTrail>)
  private
    FRepo: IRepository<TSysDocumentTrail>;
    FSourceTable: string;
    FSourceId: Int64;

    procedure CheckSource;
    // Kaynak belge filtresi (her okuma kaynakla sınırlanır); çağıran serbest bırakır
    function SourceFilter: TFilterCriteria;
    procedure ApplyReadableDocTables;
  public
    constructor Create;
    destructor Destroy; override;

    // İzi olan belge tablosunun okuma yetki kodu; değilse 0
    class function PermissionCodeOf(const ADocTable: string): Integer;
    class function IsTrailDocument(const ADocTable: string): Boolean;

    // Kaynak belge; yetki kodu kaynağın kodu olur. Liste açılmadan önce çağrılır.
    procedure SetSource(const ADocTable: string; ADocId: Int64);
    // Kullanıcının okuyabildiği belge tabloları
    function ReadableDocTables: TArray<string>;
    // Belgenin vergi özeti (KDV oran bazında + KDV tevkifatı); okuma yetkisi belgenin kodu
    function TaxSummary(const ADocTable: string; ADocId: Int64; APermissionControl: Boolean): TArray<TSysDocumentTaxRow>;

    procedure ValidateBusinessRules(AEntity: TSysDocumentTrail; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysDocumentTrail>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysDocumentTrail; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysDocumentTrail; override;

    procedure Add(AEntity: TSysDocumentTrail); override;
    procedure Update(AEntity: TSysDocumentTrail); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysDocumentTrail; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysDocumentTrail>; override;
    procedure BusinessInsert(AEntity: TSysDocumentTrail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysDocumentTrail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysDocumentTrail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;

    property SourceTable: string read FSourceTable;
    property SourceId: Int64 read FSourceId;
  end;

implementation

uses
  SysPermission.Service;

type
  TTrailDocument = record
    TableName: string;
    PermissionCode: Integer;
  end;

const
  // fn_document_trail / vw_sys_document_link'teki belge tabloları
  TRAIL_DOCUMENTS: array[0..8] of TTrailDocument = (
    (TableName: 'pur_request';   PermissionCode: PERMISSION_PUR_REQUEST),
    (TableName: 'pur_quotation'; PermissionCode: PERMISSION_PUR_QUOTATION),
    (TableName: 'pur_order';     PermissionCode: PERMISSION_PUR_ORDER),
    (TableName: 'pur_receipt';   PermissionCode: PERMISSION_PUR_RECEIPT),
    (TableName: 'pur_invoice';   PermissionCode: PERMISSION_PUR_INVOICE),
    (TableName: 'sls_offer';     PermissionCode: PERMISSION_SLS_OFFER),
    (TableName: 'sls_order';     PermissionCode: PERMISSION_SLS_ORDER),
    (TableName: 'sls_dispatch';  PermissionCode: PERMISSION_SLS_DISPATCH),
    (TableName: 'sls_invoice';   PermissionCode: PERMISSION_SLS_INVOICE)
  );

constructor TSysDocumentTrailService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysDocumentTrail, TSysDocumentTrailRepository>;
  // SetSource kaynağın koduyla değiştirir; kaynaksız okuma CheckSource ile reddedilir
  Self.PermissionCode := 0;
end;

destructor TSysDocumentTrailService.Destroy;
begin
  inherited;
end;

class function TSysDocumentTrailService.PermissionCodeOf(const ADocTable: string): Integer;
var
  LDoc: TTrailDocument;
begin
  Result := 0;
  for LDoc in TRAIL_DOCUMENTS do
    if SameText(LDoc.TableName, ADocTable) then
      Exit(LDoc.PermissionCode);
end;

class function TSysDocumentTrailService.IsTrailDocument(const ADocTable: string): Boolean;
begin
  Result := PermissionCodeOf(ADocTable) > 0;
end;

procedure TSysDocumentTrailService.SetSource(const ADocTable: string; ADocId: Int64);
begin
  if not IsTrailDocument(ADocTable) then
    raise ESysDocumentTrailExceptionUnknownDocument.Create;
  FSourceTable := LowerCase(ADocTable);
  FSourceId := ADocId;
  Self.PermissionCode := PermissionCodeOf(FSourceTable);
end;

procedure TSysDocumentTrailService.CheckSource;
begin
  if (FSourceTable = '') or (FSourceId <= 0) then
    raise ESysDocumentTrailExceptionNoSource.Create;
end;

function TSysDocumentTrailService.SourceFilter: TFilterCriteria;
begin
  CheckSource;
  Result := TFilterCriteria.Create;
  Result.Add(TFilterCriterion.New('source_table', '=', FSourceTable));
  Result.Add(TFilterCriterion.New('source_id', '=', FSourceId));
end;

function TSysDocumentTrailService.ReadableDocTables: TArray<string>;
var
  LDoc: TTrailDocument;
begin
  Result := [];
  for LDoc in TRAIL_DOCUMENTS do
    if Self.UoW.IsAuthorized(LDoc.PermissionCode, ptRead, True) then
      Result := Result + [LDoc.TableName];
end;

function TSysDocumentTrailService.TaxSummary(const ADocTable: string; ADocId: Int64;
  APermissionControl: Boolean): TArray<TSysDocumentTaxRow>;
begin
  if not IsTrailDocument(ADocTable) then
    raise ESysDocumentTrailExceptionUnknownDocument.Create;
  Self.UoW.EnsureAuthorized(PermissionCodeOf(ADocTable), ptRead, APermissionControl);
  Result := TSysDocumentTrailRepository(FRepo).ReadTaxSummary(LowerCase(ADocTable), ADocId);
end;

procedure TSysDocumentTrailService.ApplyReadableDocTables;
begin
  TSysDocumentTrailRepository(FRepo).AllowedDocTables := ReadableDocTables;
end;

procedure TSysDocumentTrailService.ValidateBusinessRules(AEntity: TSysDocumentTrail; AOperation: TCrudOperation);
begin
  raise ESysDocumentTrailExceptionReadOnly.Create;
end;

// Liste: form kaynak filtresini sabit filtre olarak verir (source_table + source_id). Kaynaksız açılış (ör. genel
// liste testi) boş liste: izin verilen tablo yok -> 1=0, view hiç hesaplanmaz
function TSysDocumentTrailService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  if (FSourceTable = '') or (FSourceId <= 0) then
    TSysDocumentTrailRepository(FRepo).AllowedDocTables := []
  else
    ApplyReadableDocTables;
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysDocumentTrailService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysDocumentTrail>;
var
  LFilter: TFilterCriteria;
  LCriterion: TFilterCriterion;
begin
  LFilter := SourceFilter;
  try
    if Assigned(AFilter) then
      for LCriterion in AFilter do
        LFilter.Add(LCriterion);
    Result := FRepo.Find(LFilter, False);
  finally
    LFilter.Free;
  end;
end;

function TSysDocumentTrailService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysDocumentTrail;
var
  LFilter: TFilterCriteria;
begin
  LFilter := SourceFilter;
  try
    LFilter.Add(TFilterCriterion.New('id', '=', AId));
    Result := FRepo.FindOne(LFilter, False);
  finally
    LFilter.Free;
  end;
end;

function TSysDocumentTrailService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysDocumentTrail;
var
  LFilter: TFilterCriteria;
  LCriterion: TFilterCriterion;
begin
  LFilter := SourceFilter;
  try
    if Assigned(AFilter) then
      for LCriterion in AFilter do
        LFilter.Add(LCriterion);
    Result := FRepo.FindOne(LFilter, False);
  finally
    LFilter.Free;
  end;
end;

procedure TSysDocumentTrailService.Add(AEntity: TSysDocumentTrail);
begin
  raise ESysDocumentTrailExceptionReadOnly.Create;
end;

procedure TSysDocumentTrailService.Update(AEntity: TSysDocumentTrail);
begin
  raise ESysDocumentTrailExceptionReadOnly.Create;
end;

procedure TSysDocumentTrailService.Delete(AId: Int64);
begin
  raise ESysDocumentTrailExceptionReadOnly.Create;
end;

function TSysDocumentTrailService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysDocumentTrail>;
begin
  CheckSource;
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := Find(AFilter, False);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TSysDocumentTrailService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysDocumentTrail;
begin
  CheckSource;
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FindById(AId, False);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TSysDocumentTrailService.BusinessInsert(AEntity: TSysDocumentTrail; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  raise ESysDocumentTrailExceptionReadOnly.Create;
end;

procedure TSysDocumentTrailService.BusinessUpdate(AEntity: TSysDocumentTrail; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  raise ESysDocumentTrailExceptionReadOnly.Create;
end;

procedure TSysDocumentTrailService.BusinessDelete(AEntity: TSysDocumentTrail; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  raise ESysDocumentTrailExceptionReadOnly.Create;
end;

end.
