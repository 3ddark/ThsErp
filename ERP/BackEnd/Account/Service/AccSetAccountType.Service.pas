unit AccSetAccountType.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  AccSetAccountType.Repository, AccSetAccountType, AccSetAccountType.Exception;

type
  TAccSetAccountTypeService = class(TCrudService<TAccSetAccountType>)
  private
    FRepo: IRepository<TAccSetAccountType>;

    procedure DoAdd(AEntity: TAccSetAccountType);
    procedure DoUpdate(AEntity: TAccSetAccountType);
    procedure DoDelete(AId: Int64);
    procedure ValidateUnique(AEntity: TAccSetAccountType; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TAccSetAccountType; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccSetAccountType>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccSetAccountType; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TAccSetAccountType; override;

    procedure Add(AEntity: TAccSetAccountType); override;
    procedure Update(AEntity: TAccSetAccountType); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccSetAccountType; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccSetAccountType>; override;
    procedure BusinessInsert(AEntity: TAccSetAccountType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccSetAccountType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccSetAccountType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TAccSetAccountTypeService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccSetAccountType, TAccSetAccountTypeRepository>;
  Self.PermissionCode := PERMISSION_ACC_ACCOUNT_TYPE;
end;

destructor TAccSetAccountTypeService.Destroy;
begin
  inherited;
end;

procedure TAccSetAccountTypeService.ValidateUnique(AEntity: TAccSetAccountType; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TAccSetAccountType;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('account_type_key', '=', TValue.From<string>(AEntity.AccountTypeKey)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EAccSetAccountTypeExceptionAccountTypeKeyUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TAccSetAccountTypeService.ValidateBusinessRules(AEntity: TAccSetAccountType; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.AccountTypeKey := AnsiUpperCase(Trim(AEntity.AccountTypeKey));
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TAccSetAccountTypeService.DoAdd(AEntity: TAccSetAccountType);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TAccSetAccountTypeService.DoUpdate(AEntity: TAccSetAccountType);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TAccSetAccountTypeService.DoDelete(AId: Int64);
var
  LEntity: TAccSetAccountType;
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

function TAccSetAccountTypeService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccSetAccountType>;
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

function TAccSetAccountTypeService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccSetAccountType;
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

procedure TAccSetAccountTypeService.BusinessInsert(AEntity: TAccSetAccountType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccSetAccountTypeService.BusinessUpdate(AEntity: TAccSetAccountType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccSetAccountTypeService.BusinessDelete(AEntity: TAccSetAccountType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TAccSetAccountTypeService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccSetAccountTypeService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TAccSetAccountType>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TAccSetAccountTypeService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TAccSetAccountType;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TAccSetAccountTypeService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccSetAccountType;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TAccSetAccountTypeService.Add(AEntity: TAccSetAccountType);
begin
  DoAdd(AEntity);
end;

procedure TAccSetAccountTypeService.Update(AEntity: TAccSetAccountType);
begin
  DoUpdate(AEntity);
end;

procedure TAccSetAccountTypeService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
