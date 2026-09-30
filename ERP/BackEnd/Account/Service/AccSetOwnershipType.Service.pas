unit AccSetOwnershipType.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  AccSetOwnershipType.Repository, AccSetOwnershipType, AccSetOwnershipType.Exception;

type
  TAccSetOwnershipTypeService = class(TCrudService<TAccSetOwnershipType>)
  private
    FRepo: IRepository<TAccSetOwnershipType>;

    procedure DoAdd(AEntity: TAccSetOwnershipType);
    procedure DoUpdate(AEntity: TAccSetOwnershipType);
    procedure DoDelete(AId: Int64);
    procedure ValidateUnique(AEntity: TAccSetOwnershipType; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TAccSetOwnershipType; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccSetOwnershipType>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccSetOwnershipType; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TAccSetOwnershipType; override;

    procedure Add(AEntity: TAccSetOwnershipType); override;
    procedure Update(AEntity: TAccSetOwnershipType); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccSetOwnershipType; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccSetOwnershipType>; override;
    procedure BusinessInsert(AEntity: TAccSetOwnershipType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccSetOwnershipType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccSetOwnershipType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TAccSetOwnershipTypeService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccSetOwnershipType, TAccSetOwnershipTypeRepository>;
  Self.PermissionCode := PERMISSION_ACC_OWNERSHIP_TYPE;
end;

destructor TAccSetOwnershipTypeService.Destroy;
begin
  inherited;
end;

procedure TAccSetOwnershipTypeService.ValidateUnique(AEntity: TAccSetOwnershipType; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TAccSetOwnershipType;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('ownership_type_key', '=', TValue.From<string>(AEntity.OwnershipTypeKey)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EAccSetOwnershipTypeExceptionOwnershipTypeKeyUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TAccSetOwnershipTypeService.ValidateBusinessRules(AEntity: TAccSetOwnershipType; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.OwnershipTypeKey := AnsiUpperCase(Trim(AEntity.OwnershipTypeKey));
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TAccSetOwnershipTypeService.DoAdd(AEntity: TAccSetOwnershipType);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TAccSetOwnershipTypeService.DoUpdate(AEntity: TAccSetOwnershipType);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TAccSetOwnershipTypeService.DoDelete(AId: Int64);
var
  LEntity: TAccSetOwnershipType;
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

function TAccSetOwnershipTypeService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccSetOwnershipType>;
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

function TAccSetOwnershipTypeService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccSetOwnershipType;
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

procedure TAccSetOwnershipTypeService.BusinessInsert(AEntity: TAccSetOwnershipType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccSetOwnershipTypeService.BusinessUpdate(AEntity: TAccSetOwnershipType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccSetOwnershipTypeService.BusinessDelete(AEntity: TAccSetOwnershipType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TAccSetOwnershipTypeService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccSetOwnershipTypeService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TAccSetOwnershipType>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TAccSetOwnershipTypeService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TAccSetOwnershipType;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TAccSetOwnershipTypeService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccSetOwnershipType;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TAccSetOwnershipTypeService.Add(AEntity: TAccSetOwnershipType);
begin
  DoAdd(AEntity);
end;

procedure TAccSetOwnershipTypeService.Update(AEntity: TAccSetOwnershipType);
begin
  DoUpdate(AEntity);
end;

procedure TAccSetOwnershipTypeService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
