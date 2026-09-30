unit EmpTask.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EmpTask.Repository, EmpTask, EmpTask.Exception;

type
  TEmpTaskService = class(TCrudService<TEmpTask>)
  private
    FRepo: IRepository<TEmpTask>;

    procedure DoAdd(AEntity: TEmpTask);
    procedure DoUpdate(AEntity: TEmpTask);
    procedure DoDelete(AId: Int64);
    procedure ValidateUnique(AEntity: TEmpTask; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEmpTask; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEmpTask>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEmpTask; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEmpTask; override;

    procedure Add(AEntity: TEmpTask); override;
    procedure Update(AEntity: TEmpTask); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpTask; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpTask>; override;
    procedure BusinessInsert(AEntity: TEmpTask; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEmpTask; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEmpTask; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TEmpTaskService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEmpTask, TEmpTaskRepository>;
  Self.PermissionCode := PERMISSION_EMP_TASK;
end;

destructor TEmpTaskService.Destroy;
begin
  inherited;
end;

procedure TEmpTaskService.ValidateUnique(AEntity: TEmpTask; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TEmpTask;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('task_key', '=', TValue.From<string>(AEntity.TaskKey)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EEmpTaskExceptionTaskKeyUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TEmpTaskService.ValidateBusinessRules(AEntity: TEmpTask; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.TaskKey := Trim(AEntity.TaskKey);
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TEmpTaskService.DoAdd(AEntity: TEmpTask);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEmpTaskService.DoUpdate(AEntity: TEmpTask);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEmpTaskService.DoDelete(AId: Int64);
var
  LEntity: TEmpTask;
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

function TEmpTaskService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpTask>;
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

function TEmpTaskService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpTask;
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

procedure TEmpTaskService.BusinessInsert(AEntity: TEmpTask; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpTaskService.BusinessUpdate(AEntity: TEmpTask; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpTaskService.BusinessDelete(AEntity: TEmpTask; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEmpTaskService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEmpTaskService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEmpTask>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEmpTaskService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEmpTask;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEmpTaskService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEmpTask;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEmpTaskService.Add(AEntity: TEmpTask);
begin
  DoAdd(AEntity);
end;

procedure TEmpTaskService.Update(AEntity: TEmpTask);
begin
  DoUpdate(AEntity);
end;

procedure TEmpTaskService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
