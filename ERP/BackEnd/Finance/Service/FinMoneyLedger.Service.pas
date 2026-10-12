unit FinMoneyLedger.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  FinMoneyLedger.Repository, FinMoneyLedger, FinMoneyLedger.Exception;

type
  TFinMoneyLedgerService = class(TCrudService<TFinMoneyLedger>)
  private
    FRepo: IRepository<TFinMoneyLedger>;

    procedure DoAdd(AEntity: TFinMoneyLedger);
    procedure DoUpdate(AEntity: TFinMoneyLedger);
    procedure DoDelete(AId: Int64);

  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TFinMoneyLedger; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TFinMoneyLedger>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TFinMoneyLedger; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TFinMoneyLedger; override;

    procedure Add(AEntity: TFinMoneyLedger); override;
    procedure Update(AEntity: TFinMoneyLedger); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinMoneyLedger; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinMoneyLedger>; override;
    procedure BusinessInsert(AEntity: TFinMoneyLedger; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TFinMoneyLedger; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TFinMoneyLedger; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, FinLookup;

constructor TFinMoneyLedgerService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TFinMoneyLedger, TFinMoneyLedgerRepository>;
  Self.PermissionCode := PERMISSION_FIN_MONEY_ACCOUNT;
end;

destructor TFinMoneyLedgerService.Destroy;
begin
  inherited;
end;



procedure TFinMoneyLedgerService.ValidateBusinessRules(AEntity: TFinMoneyLedger; AOperation: TCrudOperation);
begin
  raise EFinMoneyLedgerExceptionReadOnly.Create;
end;

procedure TFinMoneyLedgerService.DoAdd(AEntity: TFinMoneyLedger);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TFinMoneyLedgerService.DoUpdate(AEntity: TFinMoneyLedger);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TFinMoneyLedgerService.DoDelete(AId: Int64);
var
  LEntity: TFinMoneyLedger;
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

function TFinMoneyLedgerService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinMoneyLedger>;
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

function TFinMoneyLedgerService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinMoneyLedger;
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

procedure TFinMoneyLedgerService.BusinessInsert(AEntity: TFinMoneyLedger; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinMoneyLedgerService.BusinessUpdate(AEntity: TFinMoneyLedger; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinMoneyLedgerService.BusinessDelete(AEntity: TFinMoneyLedger; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TFinMoneyLedgerService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TFinMoneyLedgerService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TFinMoneyLedger>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TFinMoneyLedgerService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TFinMoneyLedger;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TFinMoneyLedgerService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TFinMoneyLedger;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TFinMoneyLedgerService.Add(AEntity: TFinMoneyLedger);
begin
  DoAdd(AEntity);
end;

procedure TFinMoneyLedgerService.Update(AEntity: TFinMoneyLedger);
begin
  DoUpdate(AEntity);
end;

procedure TFinMoneyLedgerService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
