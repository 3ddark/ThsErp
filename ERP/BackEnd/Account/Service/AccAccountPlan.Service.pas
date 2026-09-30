unit AccAccountPlan.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  AccAccountPlan.Repository, AccAccountPlan, AccAccountPlan.Exception;

type
  TAccAccountPlanService = class(TCrudService<TAccAccountPlan>)
  private
    FRepo: IRepository<TAccAccountPlan>;

    procedure DoAdd(AEntity: TAccAccountPlan);
    procedure DoUpdate(AEntity: TAccAccountPlan);
    procedure DoDelete(AId: Int64);
    procedure ValidateUnique(AEntity: TAccAccountPlan; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TAccAccountPlan; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccAccountPlan>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccAccountPlan; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TAccAccountPlan; override;

    procedure Add(AEntity: TAccAccountPlan); override;
    procedure Update(AEntity: TAccAccountPlan); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccAccountPlan; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccAccountPlan>; override;
    procedure BusinessInsert(AEntity: TAccAccountPlan; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccAccountPlan; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccAccountPlan; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TAccAccountPlanService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccAccountPlan, TAccAccountPlanRepository>;
  Self.PermissionCode := PERMISSION_ACC_ACCOUNT_PLAN;
end;

destructor TAccAccountPlanService.Destroy;
begin
  inherited;
end;

procedure TAccAccountPlanService.ValidateUnique(AEntity: TAccAccountPlan; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TAccAccountPlan;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('code', '=', TValue.From<string>(AEntity.Code)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EAccAccountPlanExceptionCodeUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TAccAccountPlanService.ValidateBusinessRules(AEntity: TAccAccountPlan; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.Code := AnsiUpperCase(Trim(AEntity.Code));
    AEntity.Name := AnsiUpperCase(Trim(AEntity.Name));
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TAccAccountPlanService.DoAdd(AEntity: TAccAccountPlan);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TAccAccountPlanService.DoUpdate(AEntity: TAccAccountPlan);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TAccAccountPlanService.DoDelete(AId: Int64);
var
  LEntity: TAccAccountPlan;
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

function TAccAccountPlanService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccAccountPlan>;
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

function TAccAccountPlanService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccAccountPlan;
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

procedure TAccAccountPlanService.BusinessInsert(AEntity: TAccAccountPlan; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccAccountPlanService.BusinessUpdate(AEntity: TAccAccountPlan; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccAccountPlanService.BusinessDelete(AEntity: TAccAccountPlan; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TAccAccountPlanService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccAccountPlanService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TAccAccountPlan>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TAccAccountPlanService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TAccAccountPlan;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TAccAccountPlanService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccAccountPlan;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TAccAccountPlanService.Add(AEntity: TAccAccountPlan);
begin
  DoAdd(AEntity);
end;

procedure TAccAccountPlanService.Update(AEntity: TAccAccountPlan);
begin
  DoUpdate(AEntity);
end;

procedure TAccAccountPlanService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
