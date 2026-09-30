unit AccRegion.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  AccRegion.Repository, AccRegion, AccRegion.Exception;

type
  TAccRegionService = class(TCrudService<TAccRegion>)
  private
    FRepo: IRepository<TAccRegion>;

    procedure DoAdd(AEntity: TAccRegion);
    procedure DoUpdate(AEntity: TAccRegion);
    procedure DoDelete(AId: Int64);
    procedure ValidateUnique(AEntity: TAccRegion; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TAccRegion; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccRegion>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccRegion; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TAccRegion; override;

    procedure Add(AEntity: TAccRegion); override;
    procedure Update(AEntity: TAccRegion); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccRegion; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccRegion>; override;
    procedure BusinessInsert(AEntity: TAccRegion; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccRegion; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccRegion; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TAccRegionService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccRegion, TAccRegionRepository>;
  Self.PermissionCode := PERMISSION_ACC_REGION;
end;

destructor TAccRegionService.Destroy;
begin
  inherited;
end;

procedure TAccRegionService.ValidateUnique(AEntity: TAccRegion; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TAccRegion;
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
          raise EAccRegionExceptionNameUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TAccRegionService.ValidateBusinessRules(AEntity: TAccRegion; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.Name := AnsiUpperCase(Trim(AEntity.Name));
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TAccRegionService.DoAdd(AEntity: TAccRegion);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TAccRegionService.DoUpdate(AEntity: TAccRegion);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TAccRegionService.DoDelete(AId: Int64);
var
  LEntity: TAccRegion;
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

function TAccRegionService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccRegion>;
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

function TAccRegionService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccRegion;
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

procedure TAccRegionService.BusinessInsert(AEntity: TAccRegion; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccRegionService.BusinessUpdate(AEntity: TAccRegion; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccRegionService.BusinessDelete(AEntity: TAccRegion; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TAccRegionService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccRegionService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TAccRegion>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TAccRegionService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TAccRegion;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TAccRegionService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccRegion;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TAccRegionService.Add(AEntity: TAccRegion);
begin
  DoAdd(AEntity);
end;

procedure TAccRegionService.Update(AEntity: TAccRegion);
begin
  DoUpdate(AEntity);
end;

procedure TAccRegionService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
