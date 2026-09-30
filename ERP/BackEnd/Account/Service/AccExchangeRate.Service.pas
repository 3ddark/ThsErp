unit AccExchangeRate.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  AccExchangeRate.Repository, AccExchangeRate, AccExchangeRate.Exception;

type
  TAccExchangeRateService = class(TCrudService<TAccExchangeRate>)
  private
    FRepo: IRepository<TAccExchangeRate>;

    procedure DoAdd(AEntity: TAccExchangeRate);
    procedure DoUpdate(AEntity: TAccExchangeRate);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TAccExchangeRate);
    procedure ValidateUnique(AEntity: TAccExchangeRate; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TAccExchangeRate; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccExchangeRate>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccExchangeRate; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TAccExchangeRate; override;

    procedure Add(AEntity: TAccExchangeRate); override;
    procedure Update(AEntity: TAccExchangeRate); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccExchangeRate; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccExchangeRate>; override;
    procedure BusinessInsert(AEntity: TAccExchangeRate; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccExchangeRate; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccExchangeRate; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TAccExchangeRateService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccExchangeRate, TAccExchangeRateRepository>;
  Self.PermissionCode := PERMISSION_ACC_EXCHANGE_RATE;
end;

destructor TAccExchangeRateService.Destroy;
begin
  inherited;
end;

procedure TAccExchangeRateService.ValidateRequiredReferences(AEntity: TAccExchangeRate);

  procedure Check(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  Check(Trunc(AEntity.RateDate), TLangKeys.TAccExchangeRate.ColRateDate, 'Date');
end;

procedure TAccExchangeRateService.ValidateUnique(AEntity: TAccExchangeRate; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TAccExchangeRate;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('rate_date', '=', TValue.From<TDate>(AEntity.RateDate)));
      LFilter.Add(TFilterCriterion.New('currency', '=', TValue.From<string>(AEntity.Currency)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EAccExchangeRateExceptionRateDateCurrencyUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TAccExchangeRateService.ValidateBusinessRules(AEntity: TAccExchangeRate; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.Currency := Trim(AEntity.Currency);
    ValidateRequiredReferences(AEntity);
    if AEntity.Rate <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TAccExchangeRate.ColRate, 'Rate') + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.NegativeValueNotAllowed, 'Negative values are not allowed'));
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TAccExchangeRateService.DoAdd(AEntity: TAccExchangeRate);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TAccExchangeRateService.DoUpdate(AEntity: TAccExchangeRate);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TAccExchangeRateService.DoDelete(AId: Int64);
var
  LEntity: TAccExchangeRate;
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

function TAccExchangeRateService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccExchangeRate>;
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

function TAccExchangeRateService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccExchangeRate;
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

procedure TAccExchangeRateService.BusinessInsert(AEntity: TAccExchangeRate; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccExchangeRateService.BusinessUpdate(AEntity: TAccExchangeRate; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccExchangeRateService.BusinessDelete(AEntity: TAccExchangeRate; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TAccExchangeRateService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccExchangeRateService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TAccExchangeRate>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TAccExchangeRateService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TAccExchangeRate;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TAccExchangeRateService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccExchangeRate;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TAccExchangeRateService.Add(AEntity: TAccExchangeRate);
begin
  DoAdd(AEntity);
end;

procedure TAccExchangeRateService.Update(AEntity: TAccExchangeRate);
begin
  DoUpdate(AEntity);
end;

procedure TAccExchangeRateService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
