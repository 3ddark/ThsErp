unit PrdBomByProduct.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  PrdBomByProduct.Repository, PrdBomByProduct, PrdBomByProduct.Exception;

type
  TPrdBomByProductService = class(TCrudService<TPrdBomByProduct>)
  private
    FRepo: IRepository<TPrdBomByProduct>;

    procedure DoAdd(AEntity: TPrdBomByProduct);
    procedure DoUpdate(AEntity: TPrdBomByProduct);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TPrdBomByProduct);
    procedure ValidateUnique(AEntity: TPrdBomByProduct; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPrdBomByProduct; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrdBomByProduct>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrdBomByProduct; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPrdBomByProduct; override;

    procedure Add(AEntity: TPrdBomByProduct); override;
    procedure Update(AEntity: TPrdBomByProduct); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdBomByProduct; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdBomByProduct>; override;
    procedure BusinessInsert(AEntity: TPrdBomByProduct; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrdBomByProduct; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrdBomByProduct; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TPrdBomByProductService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPrdBomByProduct, TPrdBomByProductRepository>;
  Self.PermissionCode := PERMISSION_PRD_BOM;
end;

destructor TPrdBomByProductService.Destroy;
begin
  inherited;
end;

procedure TPrdBomByProductService.ValidateRequiredReferences(AEntity: TPrdBomByProduct);

  procedure CheckId(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  CheckId(AEntity.PrdBomId, TLangKeys.TPrdBomByProduct.ColPrdBomId, 'BoM');
  CheckId(AEntity.StkInventoryId, TLangKeys.TPrdBomByProduct.ColStkInventoryId, 'By-Product');
end;

procedure TPrdBomByProductService.ValidateUnique(AEntity: TPrdBomByProduct; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TPrdBomByProduct;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('prd_bom_id', '=', TValue.From<Int64>(AEntity.PrdBomId)));
      LFilter.Add(TFilterCriterion.New('stk_inventory_id', '=', TValue.From<Int64>(AEntity.StkInventoryId)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EPrdBomByProductExceptionInventoryUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TPrdBomByProductService.ValidateBusinessRules(AEntity: TPrdBomByProduct; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    ValidateRequiredReferences(AEntity);
    if AEntity.Quantity <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TPrdBomByProduct.ColQuantity, 'Quantity') + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero'));
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TPrdBomByProductService.DoAdd(AEntity: TPrdBomByProduct);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPrdBomByProductService.DoUpdate(AEntity: TPrdBomByProduct);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TPrdBomByProductService.DoDelete(AId: Int64);
var
  LEntity: TPrdBomByProduct;
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

function TPrdBomByProductService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdBomByProduct>;
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

function TPrdBomByProductService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdBomByProduct;
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

procedure TPrdBomByProductService.BusinessInsert(AEntity: TPrdBomByProduct; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdBomByProductService.BusinessUpdate(AEntity: TPrdBomByProduct; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdBomByProductService.BusinessDelete(AEntity: TPrdBomByProduct; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPrdBomByProductService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPrdBomByProductService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPrdBomByProduct>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TPrdBomByProductService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPrdBomByProduct;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TPrdBomByProductService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrdBomByProduct;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPrdBomByProductService.Add(AEntity: TPrdBomByProduct);
begin
  DoAdd(AEntity);
end;

procedure TPrdBomByProductService.Update(AEntity: TPrdBomByProduct);
begin
  DoUpdate(AEntity);
end;

procedure TPrdBomByProductService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
