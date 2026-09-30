unit AccGroup.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  AccGroup.Repository, AccGroup, AccGroup.Exception;

type
  TAccGroupService = class(TCrudService<TAccGroup>)
  private
    FRepo: IRepository<TAccGroup>;

    procedure DoAdd(AEntity: TAccGroup);
    procedure DoUpdate(AEntity: TAccGroup);
    procedure DoDelete(AId: Int64);
    procedure ValidateUnique(AEntity: TAccGroup; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TAccGroup; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccGroup>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccGroup; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TAccGroup; override;

    procedure Add(AEntity: TAccGroup); override;
    procedure Update(AEntity: TAccGroup); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccGroup; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccGroup>; override;
    procedure BusinessInsert(AEntity: TAccGroup; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccGroup; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccGroup; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TAccGroupService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccGroup, TAccGroupRepository>;
  Self.PermissionCode := PERMISSION_ACC_GROUP;
end;

destructor TAccGroupService.Destroy;
begin
  inherited;
end;

procedure TAccGroupService.ValidateUnique(AEntity: TAccGroup; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TAccGroup;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('name', '=', TValue.From<string>(AEntity.Name)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EAccGroupExceptionNameUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TAccGroupService.ValidateBusinessRules(AEntity: TAccGroup; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.Name := AnsiUpperCase(Trim(AEntity.Name));
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TAccGroupService.DoAdd(AEntity: TAccGroup);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TAccGroupService.DoUpdate(AEntity: TAccGroup);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TAccGroupService.DoDelete(AId: Int64);
var
  LEntity: TAccGroup;
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

function TAccGroupService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccGroup>;
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

function TAccGroupService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccGroup;
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

procedure TAccGroupService.BusinessInsert(AEntity: TAccGroup; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccGroupService.BusinessUpdate(AEntity: TAccGroup; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccGroupService.BusinessDelete(AEntity: TAccGroup; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TAccGroupService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccGroupService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TAccGroup>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TAccGroupService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TAccGroup;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TAccGroupService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccGroup;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TAccGroupService.Add(AEntity: TAccGroup);
begin
  DoAdd(AEntity);
end;

procedure TAccGroupService.Update(AEntity: TAccGroup);
begin
  DoUpdate(AEntity);
end;

procedure TAccGroupService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
