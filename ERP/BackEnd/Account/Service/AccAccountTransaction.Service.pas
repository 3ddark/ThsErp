unit AccAccountTransaction.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  AccAccountTransaction.Repository, AccAccountTransaction, AccAccountTransaction.Exception;

type
  TAccAccountTransactionService = class(TCrudService<TAccAccountTransaction>)
  private
    FRepo: IRepository<TAccAccountTransaction>;

    procedure DoAdd(AEntity: TAccAccountTransaction);
    procedure DoUpdate(AEntity: TAccAccountTransaction);
    procedure DoDelete(AId: Int64);

  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TAccAccountTransaction; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccAccountTransaction>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccAccountTransaction; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TAccAccountTransaction; override;

    procedure Add(AEntity: TAccAccountTransaction); override;
    procedure Update(AEntity: TAccAccountTransaction); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccAccountTransaction; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccAccountTransaction>; override;
    procedure BusinessInsert(AEntity: TAccAccountTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccAccountTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccAccountTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, AccLookup;

constructor TAccAccountTransactionService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccAccountTransaction, TAccAccountTransactionRepository>;
  Self.PermissionCode := PERMISSION_ACC_ACCOUNT_TRANSACTION;
end;

destructor TAccAccountTransactionService.Destroy;
begin
  inherited;
end;



procedure TAccAccountTransactionService.ValidateBusinessRules(AEntity: TAccAccountTransaction; AOperation: TCrudOperation);
begin
  raise EAccAccountTransactionExceptionReadOnly.Create;
end;

procedure TAccAccountTransactionService.DoAdd(AEntity: TAccAccountTransaction);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TAccAccountTransactionService.DoUpdate(AEntity: TAccAccountTransaction);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TAccAccountTransactionService.DoDelete(AId: Int64);
var
  LEntity: TAccAccountTransaction;
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

function TAccAccountTransactionService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccAccountTransaction>;
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

function TAccAccountTransactionService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccAccountTransaction;
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

procedure TAccAccountTransactionService.BusinessInsert(AEntity: TAccAccountTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccAccountTransactionService.BusinessUpdate(AEntity: TAccAccountTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccAccountTransactionService.BusinessDelete(AEntity: TAccAccountTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TAccAccountTransactionService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccAccountTransactionService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TAccAccountTransaction>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TAccAccountTransactionService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TAccAccountTransaction;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TAccAccountTransactionService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccAccountTransaction;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TAccAccountTransactionService.Add(AEntity: TAccAccountTransaction);
begin
  DoAdd(AEntity);
end;

procedure TAccAccountTransactionService.Update(AEntity: TAccAccountTransaction);
begin
  DoUpdate(AEntity);
end;

procedure TAccAccountTransactionService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
