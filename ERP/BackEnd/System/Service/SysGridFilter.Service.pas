unit SysGridFilter.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext,
  SysGridFilter.Repository, SysGridFilter, SysGridFilter.Exception;

type
  TSysGridFilterService = class(TCrudService<TSysGridFilter>)
  private
    FRepo: IRepository<TSysGridFilter>;
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

function TSysGridFilterService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysGridFilter>;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.Find(AFilter, ALock);
  except
    if Self.UoW.InTransaction then
    begin
      Self.UoW.Rollback;
    end;
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
    begin
      Self.UoW.Rollback;
    end;
    raise;
  end;
end;

procedure TSysGridFilterService.BusinessInsert(AEntity: TSysGridFilter; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);

    ValidateAll(AEntity, coInsert);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Add(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Uow.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

procedure TSysGridFilterService.BusinessUpdate(AEntity: TSysGridFilter; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);

    ValidateAll(AEntity, coUpdate);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Update(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

procedure TSysGridFilterService.BusinessDelete(AEntity: TSysGridFilter; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptDelete, APermissionControl);

    ValidateAll(AEntity, coDelete);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Delete(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
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
  FRepo.Add(AEntity);
end;

procedure TSysGridFilterService.Update(AEntity: TSysGridFilter);
begin
  FRepo.Update(AEntity);
end;

procedure TSysGridFilterService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

procedure TSysGridFilterService.ValidateBusinessRules(AEntity: TSysGridFilter; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TSysGridFilter;
begin
  //check unique
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

end.
