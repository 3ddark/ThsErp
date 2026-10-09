unit PrdLabour.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  PrdLabour.Repository, PrdLabour, PrdLabour.Exception;

type
  TPrdLabourService = class(TCrudService<TPrdLabour>)
  private
    FRepo: IRepository<TPrdLabour>;

    procedure DoAdd(AEntity: TPrdLabour);
    procedure DoUpdate(AEntity: TPrdLabour);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TPrdLabour);
    procedure ValidateUnique(AEntity: TPrdLabour; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPrdLabour; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrdLabour>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrdLabour; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPrdLabour; override;

    procedure Add(AEntity: TPrdLabour); override;
    procedure Update(AEntity: TPrdLabour); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdLabour; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdLabour>; override;
    procedure BusinessInsert(AEntity: TPrdLabour; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrdLabour; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrdLabour; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, PrdLookup;

constructor TPrdLabourService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPrdLabour, TPrdLabourRepository>;
  Self.PermissionCode := PERMISSION_PRD_LABOUR;
end;

destructor TPrdLabourService.Destroy;
begin
  inherited;
end;

procedure TPrdLabourService.ValidateRequiredReferences(AEntity: TPrdLabour);

  procedure CheckId(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  if not TPrdLookup.IsValid(plkCostType, AEntity.CostType) then
    CheckId(0, TLangKeys.TPrdLabour.ColCostType, 'Cost Type');
  CheckId(AEntity.SysUomId, TLangKeys.TPrdLabour.ColSysUomId, 'Unit');
end;

procedure TPrdLabourService.ValidateUnique(AEntity: TPrdLabour; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TPrdLabour;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('code', '=', TValue.From<string>(AEntity.Code)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EPrdLabourExceptionCodeUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TPrdLabourService.ValidateBusinessRules(AEntity: TPrdLabour; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.Code := AnsiUpperCase(Trim(AEntity.Code));
    AEntity.Name := Trim(AEntity.Name);
    AEntity.Currency := Trim(AEntity.Currency);
    AEntity.AccAccountCode := Trim(AEntity.AccAccountCode);
    ValidateRequiredReferences(AEntity);
    if AEntity.Currency = '' then
      AEntity.Currency := TPrdLabourRepository(FRepo).GetDefaultCurrency;
    if AEntity.UnitPrice < 0 then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TPrdLabour.ColUnitPrice, 'Unit Price') + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.NegativeValueNotAllowed, 'Negative values are not allowed'));
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TPrdLabourService.DoAdd(AEntity: TPrdLabour);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPrdLabourService.DoUpdate(AEntity: TPrdLabour);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TPrdLabourService.DoDelete(AId: Int64);
var
  LEntity: TPrdLabour;
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

function TPrdLabourService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdLabour>;
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

function TPrdLabourService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdLabour;
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

procedure TPrdLabourService.BusinessInsert(AEntity: TPrdLabour; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdLabourService.BusinessUpdate(AEntity: TPrdLabour; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdLabourService.BusinessDelete(AEntity: TPrdLabour; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPrdLabourService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPrdLabourService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPrdLabour>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TPrdLabourService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPrdLabour;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TPrdLabourService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrdLabour;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPrdLabourService.Add(AEntity: TPrdLabour);
begin
  DoAdd(AEntity);
end;

procedure TPrdLabourService.Update(AEntity: TPrdLabour);
begin
  DoUpdate(AEntity);
end;

procedure TPrdLabourService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
