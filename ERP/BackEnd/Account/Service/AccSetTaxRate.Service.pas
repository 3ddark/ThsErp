unit AccSetTaxRate.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  AccSetTaxRate.Repository, AccSetTaxRate, AccSetTaxRate.Exception;

type
  TAccSetTaxRateService = class(TCrudService<TAccSetTaxRate>)
  private
    FRepo: IRepository<TAccSetTaxRate>;

    procedure DoAdd(AEntity: TAccSetTaxRate);
    procedure DoUpdate(AEntity: TAccSetTaxRate);
    procedure DoDelete(AId: Int64);
    procedure ValidateUnique(AEntity: TAccSetTaxRate; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TAccSetTaxRate; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccSetTaxRate>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccSetTaxRate; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TAccSetTaxRate; override;

    procedure Add(AEntity: TAccSetTaxRate); override;
    procedure Update(AEntity: TAccSetTaxRate); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccSetTaxRate; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccSetTaxRate>; override;
    procedure BusinessInsert(AEntity: TAccSetTaxRate; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccSetTaxRate; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccSetTaxRate; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TAccSetTaxRateService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccSetTaxRate, TAccSetTaxRateRepository>;
  Self.PermissionCode := PERMISSION_ACC_TAX_RATE;
end;

destructor TAccSetTaxRateService.Destroy;
begin
  inherited;
end;

procedure TAccSetTaxRateService.ValidateUnique(AEntity: TAccSetTaxRate; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TAccSetTaxRate;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('tax_rate', '=', TValue.From<Currency>(AEntity.TaxRate)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EAccSetTaxRateExceptionTaxRateUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TAccSetTaxRateService.ValidateBusinessRules(AEntity: TAccSetTaxRate; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.SalesAccount := Trim(AEntity.SalesAccount);
    AEntity.SalesReturnAccount := Trim(AEntity.SalesReturnAccount);
    AEntity.PurchaseAccount := Trim(AEntity.PurchaseAccount);
    AEntity.PurchaseReturnAccount := Trim(AEntity.PurchaseReturnAccount);
    if AEntity.TaxRate < 0 then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TAccSetTaxRate.ColTaxRate, 'Tax Rate') + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.NegativeValueNotAllowed, 'Negative values are not allowed'));
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TAccSetTaxRateService.DoAdd(AEntity: TAccSetTaxRate);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TAccSetTaxRateService.DoUpdate(AEntity: TAccSetTaxRate);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TAccSetTaxRateService.DoDelete(AId: Int64);
var
  LEntity: TAccSetTaxRate;
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

function TAccSetTaxRateService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccSetTaxRate>;
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

function TAccSetTaxRateService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccSetTaxRate;
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

procedure TAccSetTaxRateService.BusinessInsert(AEntity: TAccSetTaxRate; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccSetTaxRateService.BusinessUpdate(AEntity: TAccSetTaxRate; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccSetTaxRateService.BusinessDelete(AEntity: TAccSetTaxRate; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TAccSetTaxRateService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccSetTaxRateService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TAccSetTaxRate>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TAccSetTaxRateService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TAccSetTaxRate;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TAccSetTaxRateService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccSetTaxRate;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TAccSetTaxRateService.Add(AEntity: TAccSetTaxRate);
begin
  DoAdd(AEntity);
end;

procedure TAccSetTaxRateService.Update(AEntity: TAccSetTaxRate);
begin
  DoUpdate(AEntity);
end;

procedure TAccSetTaxRateService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
