unit SysGridSort.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysGridSort.Repository, SysGridSort, SysGridSort.Exception;

type
  TSysGridSortService = class(TCrudService<TSysGridSort>)
  private
    FRepo: IRepository<TSysGridSort>;

    procedure DoAdd(AEntity: TSysGridSort);
    procedure DoUpdate(AEntity: TSysGridSort);
    procedure DoDelete(AId: Int64);

    procedure ValidateInsert(AEntity: TSysGridSort);
    procedure ValidateUpdate(AEntity: TSysGridSort);
    procedure ValidateDelete(AEntity: TSysGridSort);
    procedure ValidateTableNameUnique(AEntity: TSysGridSort; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysGridSort; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysGridSort>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysGridSort; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysGridSort; override;

    procedure Add(AEntity: TSysGridSort); override;
    procedure Update(AEntity: TSysGridSort); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysGridSort; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysGridSort>; override;
    procedure BusinessInsert(AEntity: TSysGridSort; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysGridSort; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysGridSort; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TSysGridSortService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysGridSort, TSysGridSortRepository>;
  Self.PermissionCode := PERMISSION_TEMPLATE;
end;

destructor TSysGridSortService.Destroy;
begin
  inherited;
end;

procedure TSysGridSortService.ValidateInsert(AEntity: TSysGridSort);
begin
  ValidateTableNameUnique(AEntity, coInsert);
end;

procedure TSysGridSortService.ValidateUpdate(AEntity: TSysGridSort);
begin
  ValidateTableNameUnique(AEntity, coUpdate);
end;

procedure TSysGridSortService.ValidateDelete(AEntity: TSysGridSort);
begin
end;

procedure TSysGridSortService.ValidateTableNameUnique(AEntity: TSysGridSort; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TSysGridSort;
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
          raise ESysGridSortExceptionTableNameUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TSysGridSortService.ValidateBusinessRules(AEntity: TSysGridSort; AOperation: TCrudOperation);
begin
  inherited;
  case AOperation of
    coInsert: ValidateInsert(AEntity);
    coUpdate: ValidateUpdate(AEntity);
    coDelete: ValidateDelete(AEntity);
  end;
end;

procedure TSysGridSortService.DoAdd(AEntity: TSysGridSort);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSysGridSortService.DoUpdate(AEntity: TSysGridSort);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TSysGridSortService.DoDelete(AId: Int64);
var
  LEntity: TSysGridSort;
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

function TSysGridSortService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysGridSort>;
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

function TSysGridSortService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysGridSort;
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

procedure TSysGridSortService.BusinessInsert(AEntity: TSysGridSort; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysGridSortService.BusinessUpdate(AEntity: TSysGridSort; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysGridSortService.BusinessDelete(AEntity: TSysGridSort; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSysGridSortService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysGridSortService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysGridSort>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysGridSortService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysGridSort;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysGridSortService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysGridSort;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysGridSortService.Add(AEntity: TSysGridSort);
begin
  DoAdd(AEntity);
end;

procedure TSysGridSortService.Update(AEntity: TSysGridSort);
begin
  DoUpdate(AEntity);
end;

procedure TSysGridSortService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
