unit QcRule.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  QcRule.Repository, QcRule, QcRule.Exception;

type
  // Kalite kontrol kuralları (stok grubu / stok kartı bazında kontrol gerekliliği)
  TQcRuleService = class(TCrudService<TQcRule>)
  private
    FRepo: IRepository<TQcRule>;
    procedure CheckUnique(const AColumn: string; AValue, AId: Int64; AOperation: TCrudOperation);

    procedure DoAdd(AEntity: TQcRule);
    procedure DoUpdate(AEntity: TQcRule);
    procedure DoDelete(AId: Int64);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TQcRule; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TQcRule>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TQcRule; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TQcRule; override;

    procedure Add(AEntity: TQcRule); override;
    procedure Update(AEntity: TQcRule); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TQcRule; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TQcRule>; override;
    procedure BusinessInsert(AEntity: TQcRule; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TQcRule; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TQcRule; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TQcRuleService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TQcRule, TQcRuleRepository>;
  Self.PermissionCode := PERMISSION_QC_RULE;
end;

destructor TQcRuleService.Destroy;
begin
  inherited;
end;

procedure TQcRuleService.CheckUnique(const AColumn: string; AValue, AId: Int64; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TQcRule;
begin
  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New(AColumn, '=', TValue.From<Int64>(AValue)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AId)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        if AColumn = 'stk_group_id' then
          raise EQcRuleExceptionGroupUnique.Create
        else
          raise EQcRuleExceptionInventoryUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TQcRuleService.ValidateBusinessRules(AEntity: TQcRule; AOperation: TCrudOperation);
begin
  if AOperation = coDelete then
    Exit;

  AEntity.InspectionCriteria := Trim(AEntity.InspectionCriteria);
  // tam olarak biri: stok grubu ya da stok kartı
  if (AEntity.StkGroupId > 0) = (AEntity.StkInventoryId > 0) then
    raise EQcRuleExceptionTarget.Create;
  if AEntity.StkGroupId > 0 then
    CheckUnique('stk_group_id', AEntity.StkGroupId, AEntity.Id, AOperation)
  else
    CheckUnique('stk_inventory_id', AEntity.StkInventoryId, AEntity.Id, AOperation);
end;

procedure TQcRuleService.DoAdd(AEntity: TQcRule);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TQcRuleService.DoUpdate(AEntity: TQcRule);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TQcRuleService.DoDelete(AId: Int64);
var
  LEntity: TQcRule;
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

function TQcRuleService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TQcRule>;
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

function TQcRuleService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TQcRule;
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

procedure TQcRuleService.BusinessInsert(AEntity: TQcRule; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TQcRuleService.BusinessUpdate(AEntity: TQcRule; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TQcRuleService.BusinessDelete(AEntity: TQcRule; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TQcRuleService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TQcRuleService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TQcRule>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TQcRuleService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TQcRule;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TQcRuleService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TQcRule;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TQcRuleService.Add(AEntity: TQcRule);
begin
  DoAdd(AEntity);
end;

procedure TQcRuleService.Update(AEntity: TQcRule);
begin
  DoUpdate(AEntity);
end;

procedure TQcRuleService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
