unit StkGroup.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  StkGroup.Repository, StkGroup, StkGroup.Exception;

type
  TStkGroupService = class(TCrudService<TStkGroup>)
  private
    FRepo: IRepository<TStkGroup>;

    procedure DoAdd(AEntity: TStkGroup);
    procedure DoUpdate(AEntity: TStkGroup);
    procedure DoDelete(AId: Int64);
    procedure ValidateUnique(AEntity: TStkGroup; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TStkGroup; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TStkGroup>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TStkGroup; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TStkGroup; override;

    procedure Add(AEntity: TStkGroup); override;
    procedure Update(AEntity: TStkGroup); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkGroup; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkGroup>; override;
    procedure BusinessInsert(AEntity: TStkGroup; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkGroup; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkGroup; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TStkGroupService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TStkGroup, TStkGroupRepository>;
  Self.PermissionCode := PERMISSION_STK_GROUP;
end;

destructor TStkGroupService.Destroy;
begin
  inherited;
end;

procedure TStkGroupService.ValidateUnique(AEntity: TStkGroup; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TStkGroup;
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
          raise EStkGroupExceptionNameUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TStkGroupService.ValidateBusinessRules(AEntity: TStkGroup; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.Name := AnsiUpperCase(Trim(AEntity.Name));
    AEntity.RawMaterialStockAccount := Trim(AEntity.RawMaterialStockAccount);
    AEntity.RawMaterialUsageAccount := Trim(AEntity.RawMaterialUsageAccount);
    AEntity.SemiProductAccount := Trim(AEntity.SemiProductAccount);
    if (AEntity.VatRate < 0) or (AEntity.VatRate > 100) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TStkGroup.ColVatRate, 'VAT Rate (%)') + ': ' +
        Format(TLocalizationManager.Translate(TLangKeys.TValidation.Range, 'Field must be between %s and %s'), ['0', '100']));
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TStkGroupService.DoAdd(AEntity: TStkGroup);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TStkGroupService.DoUpdate(AEntity: TStkGroup);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TStkGroupService.DoDelete(AId: Int64);
var
  LEntity: TStkGroup;
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

function TStkGroupService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkGroup>;
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

function TStkGroupService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkGroup;
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

procedure TStkGroupService.BusinessInsert(AEntity: TStkGroup; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkGroupService.BusinessUpdate(AEntity: TStkGroup; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkGroupService.BusinessDelete(AEntity: TStkGroup; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TStkGroupService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TStkGroupService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TStkGroup>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TStkGroupService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TStkGroup;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TStkGroupService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TStkGroup;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TStkGroupService.Add(AEntity: TStkGroup);
begin
  DoAdd(AEntity);
end;

procedure TStkGroupService.Update(AEntity: TStkGroup);
begin
  DoUpdate(AEntity);
end;

procedure TStkGroupService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
