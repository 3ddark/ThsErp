unit SysGridFilter.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysGridFilter.Repository, SysGridFilter, SysGridFilter.Exception;

type
  TSysGridFilterService = class(TCrudService<TSysGridFilter>)
  private
    FRepo: IRepository<TSysGridFilter>;

    procedure DoAdd(AEntity: TSysGridFilter);
    procedure DoUpdate(AEntity: TSysGridFilter);
    procedure DoDelete(AId: Int64);

    procedure ValidateInsert(AEntity: TSysGridFilter);
    procedure ValidateUpdate(AEntity: TSysGridFilter);
    procedure ValidateDelete(AEntity: TSysGridFilter);
    procedure ValidateTableNameUnique(AEntity: TSysGridFilter; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysGridFilter; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysGridFilter>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysGridFilter; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysGridFilter; override;

    procedure Add(AEntity: TSysGridFilter); override;
    procedure Update(AEntity: TSysGridFilter); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysGridFilter; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysGridFilter>; override;
    procedure BusinessInsert(AEntity: TSysGridFilter; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysGridFilter; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysGridFilter; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysGridFilterService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysGridFilter, TSysGridFilterRepository>;
  Self.PermissionCode := 1;
end;

destructor TSysGridFilterService.Destroy;
begin
  inherited;
end;

procedure TSysGridFilterService.ValidateInsert(AEntity: TSysGridFilter);
begin
  ValidateTableNameUnique(AEntity, coInsert);
end;

procedure TSysGridFilterService.ValidateUpdate(AEntity: TSysGridFilter);
begin
  ValidateTableNameUnique(AEntity, coUpdate);
end;

procedure TSysGridFilterService.ValidateDelete(AEntity: TSysGridFilter);
begin
end;

procedure TSysGridFilterService.ValidateTableNameUnique(AEntity: TSysGridFilter; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TSysGridFilter;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('table_name', '=', TValue.From<string>(AEntity.TableName)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise ESysGridFilterExceptionTableNameUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TSysGridFilterService.ValidateBusinessRules(AEntity: TSysGridFilter; AOperation: TCrudOperation);
begin
  inherited;
  case AOperation of
    coInsert: ValidateInsert(AEntity);
    coUpdate: ValidateUpdate(AEntity);
    coDelete: ValidateDelete(AEntity);
  end;
end;

procedure TSysGridFilterService.DoAdd(AEntity: TSysGridFilter);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSysGridFilterService.DoUpdate(AEntity: TSysGridFilter);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TSysGridFilterService.DoDelete(AId: Int64);
var
  LEntity: TSysGridFilter;
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

function TSysGridFilterService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysGridFilter>;
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

function TSysGridFilterService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysGridFilter;
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

procedure TSysGridFilterService.BusinessInsert(AEntity: TSysGridFilter; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoAdd(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
        Self.UoW.Rollback;
      raise;
    end;
  end;
end;

procedure TSysGridFilterService.BusinessUpdate(AEntity: TSysGridFilter; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoUpdate(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
        Self.UoW.Rollback;
      raise;
    end;
  end;
end;

procedure TSysGridFilterService.BusinessDelete(AEntity: TSysGridFilter; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptDelete, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoDelete(AEntity.Id);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
        Self.UoW.Rollback;
      raise;
    end;
  end;
end;

function TSysGridFilterService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysGridFilterService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysGridFilter>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysGridFilterService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysGridFilter;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysGridFilterService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysGridFilter;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysGridFilterService.Add(AEntity: TSysGridFilter);
begin
  DoAdd(AEntity);
end;

procedure TSysGridFilterService.Update(AEntity: TSysGridFilter);
begin
  DoUpdate(AEntity);
end;

procedure TSysGridFilterService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
