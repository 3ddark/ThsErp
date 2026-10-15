unit SysAuditLog.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysAuditLog.Repository, SysAuditLog, SysAuditLog.Exception;

const
  AUDIT_FLUSH_BATCH_SIZE  = 5000;
  AUDIT_FLUSH_MAX_BATCHES = 20;

type
  // İşlem geçmişi (yetki 1112, yalnız okuma) + yerel kuyruğun ortak audit DB'ye aktarımı (yetki gerekmez: sistem işi)
  TSysAuditLogService = class(TCrudService<TSysAuditLog>)
  private
    class var FAuditedTables: TArray<string>;
    class var FAuditedLoaded: Boolean;
    class var FDbFamily: string;
    FRepo: IRepository<TSysAuditLog>;

    procedure DoAdd(AEntity: TSysAuditLog);
    procedure DoUpdate(AEntity: TSysAuditLog);
    procedure DoDelete(AId: Int64);
    function AuditRepo: TSysAuditLogRepository;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysAuditLog; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysAuditLog>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysAuditLog; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysAuditLog; override;

    procedure Add(AEntity: TSysAuditLog); override;
    procedure Update(AEntity: TSysAuditLog); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysAuditLog; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysAuditLog>; override;
    procedure BusinessInsert(AEntity: TSysAuditLog; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysAuditLog; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysAuditLog; AWithBegin, AWithCommit, APermissionControl: Boolean); override;

    // Kuyruğu ths_audit'e taşır. Açık transaction varken (başka ekranda güncelleme) çalışmaz: Moved = 0.
    // Bağlantı / uzak hata kuyruğu bozmaz (Moved = -1, ErrorMessage).
    function Flush(ABatchSize: Integer = AUDIT_FLUSH_BATCH_SIZE; AMaxBatches: Integer = AUDIT_FLUSH_MAX_BATCHES): TAuditFlushResult;
    function PendingCount: Int64;

    // Tablo işlem geçmişi tutuyor mu (public.audit() tetikleyicisi; önbellekli)
    function IsAudited(const ATableName: string): Boolean;
    // Aynı firmanın tüm dönem DB'leri için ortak ad (ths_erp2026 -> ths_erp; önbellekli)
    function DbFamily: string;
    function ActivePeriod: SmallInt;
    class procedure ResetCache;
  end;

implementation

uses
  SysPermission.Service;

constructor TSysAuditLogService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysAuditLog, TSysAuditLogRepository>;
  Self.PermissionCode := PERMISSION_SYS_AUDIT_LOG;
end;

destructor TSysAuditLogService.Destroy;
begin
  inherited;
end;

function TSysAuditLogService.AuditRepo: TSysAuditLogRepository;
begin
  Result := TSysAuditLogRepository(FRepo);
end;

procedure TSysAuditLogService.ValidateBusinessRules(AEntity: TSysAuditLog; AOperation: TCrudOperation);
begin
  raise ESysAuditLogExceptionReadOnly.Create;
end;

procedure TSysAuditLogService.DoAdd(AEntity: TSysAuditLog);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSysAuditLogService.DoUpdate(AEntity: TSysAuditLog);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TSysAuditLogService.DoDelete(AId: Int64);
begin
  raise ESysAuditLogExceptionReadOnly.Create;
end;

function TSysAuditLogService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysAuditLog>;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.Find(AFilter, False);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TSysAuditLogService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysAuditLog;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.FindById(AId, False);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TSysAuditLogService.BusinessInsert(AEntity: TSysAuditLog; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  raise ESysAuditLogExceptionReadOnly.Create;
end;

procedure TSysAuditLogService.BusinessUpdate(AEntity: TSysAuditLog; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  raise ESysAuditLogExceptionReadOnly.Create;
end;

procedure TSysAuditLogService.BusinessDelete(AEntity: TSysAuditLog; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  raise ESysAuditLogExceptionReadOnly.Create;
end;

function TSysAuditLogService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysAuditLogService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysAuditLog>;
begin
  Result := FRepo.Find(AFilter, False);
end;

function TSysAuditLogService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysAuditLog;
begin
  Result := FRepo.FindById(AId, False);
end;

function TSysAuditLogService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysAuditLog;
begin
  Result := FRepo.FindOne(AFilter, False);
end;

procedure TSysAuditLogService.Add(AEntity: TSysAuditLog);
begin
  DoAdd(AEntity);
end;

procedure TSysAuditLogService.Update(AEntity: TSysAuditLog);
begin
  DoUpdate(AEntity);
end;

procedure TSysAuditLogService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

function TSysAuditLogService.Flush(ABatchSize, AMaxBatches: Integer): TAuditFlushResult;
begin
  Result.Moved := 0;
  Result.ErrorMessage := '';
  // Uzak (ths_audit) transaction'ı ekranın açık transaction'ına bağlanıp kilit tutmasın
  if Self.UoW.InTransaction then
    Exit;
  Result := AuditRepo.Flush(ABatchSize, AMaxBatches);
end;

function TSysAuditLogService.PendingCount: Int64;
begin
  Result := AuditRepo.PendingCount;
end;

function TSysAuditLogService.IsAudited(const ATableName: string): Boolean;
var
  LName: string;
begin
  if not FAuditedLoaded then
  begin
    FAuditedTables := AuditRepo.GetAuditedTables;
    FAuditedLoaded := True;
  end;
  for LName in FAuditedTables do
    if SameText(LName, ATableName) then
      Exit(True);
  Result := False;
end;

function TSysAuditLogService.DbFamily: string;
begin
  if FDbFamily = '' then
    FDbFamily := AuditRepo.GetDbFamily;
  Result := FDbFamily;
end;

function TSysAuditLogService.ActivePeriod: SmallInt;
begin
  Result := AuditRepo.GetActivePeriod;
end;

class procedure TSysAuditLogService.ResetCache;
begin
  FAuditedTables := nil;
  FAuditedLoaded := False;
  FDbFamily := '';
end;

end.
