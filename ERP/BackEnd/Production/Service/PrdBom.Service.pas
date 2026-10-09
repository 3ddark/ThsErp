unit PrdBom.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  PrdBom.Repository, PrdBom, PrdBom.Exception;

type
  TPrdBomService = class(TCrudService<TPrdBom>)
  private
    FRepo: IRepository<TPrdBom>;

    procedure DoAdd(AEntity: TPrdBom);
    procedure DoUpdate(AEntity: TPrdBom);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TPrdBom);
    procedure ValidateUnique(AEntity: TPrdBom; AOperation: TCrudOperation);
    procedure ValidateDefault(AEntity: TPrdBom; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPrdBom; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrdBom>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrdBom; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPrdBom; override;

    procedure Add(AEntity: TPrdBom); override;
    procedure Update(AEntity: TPrdBom); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdBom; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdBom>; override;
    procedure BusinessInsert(AEntity: TPrdBom; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrdBom; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrdBom; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TPrdBomService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPrdBom, TPrdBomRepository>;
  Self.PermissionCode := PERMISSION_PRD_BOM;
end;

destructor TPrdBomService.Destroy;
begin
  inherited;
end;

procedure TPrdBomService.ValidateRequiredReferences(AEntity: TPrdBom);

  procedure CheckId(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  CheckId(AEntity.StkInventoryId, TLangKeys.TPrdBom.ColStkInventoryId, 'Product');
end;

procedure TPrdBomService.ValidateUnique(AEntity: TPrdBom; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TPrdBom;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('stk_inventory_id', '=', TValue.From<Int64>(AEntity.StkInventoryId)));
      LFilter.Add(TFilterCriterion.New('bom_name', '=', TValue.From<string>(AEntity.BomName)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EPrdBomExceptionBomNameUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

// Ürün başına tek varsayılan reçete (DB: prd_bom_default_uidx)
procedure TPrdBomService.ValidateDefault(AEntity: TPrdBom; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TPrdBom;
begin
  if not (AOperation in [coInsert, coUpdate]) or not AEntity.IsDefault then
    Exit;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('stk_inventory_id', '=', TValue.From<Int64>(AEntity.StkInventoryId)));
    LFilter.Add(TFilterCriterion.New('is_default', '=', TValue.From<Boolean>(True)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TPrdBom.DefaultExists, 'This product already has a default BoM: %s'), [LModel.BomName]));
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TPrdBomService.ValidateBusinessRules(AEntity: TPrdBom; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.BomName := Trim(AEntity.BomName);
    AEntity.Description := Trim(AEntity.Description);
    ValidateRequiredReferences(AEntity);
    if AEntity.BaseQuantity <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TPrdBom.ColBaseQuantity, 'Base Quantity') + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero'));
  end;

  ValidateUnique(AEntity, AOperation);
  ValidateDefault(AEntity, AOperation);
end;

procedure TPrdBomService.DoAdd(AEntity: TPrdBom);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPrdBomService.DoUpdate(AEntity: TPrdBom);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TPrdBomService.DoDelete(AId: Int64);
var
  LEntity: TPrdBom;
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

function TPrdBomService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdBom>;
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

function TPrdBomService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdBom;
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

procedure TPrdBomService.BusinessInsert(AEntity: TPrdBom; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdBomService.BusinessUpdate(AEntity: TPrdBom; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdBomService.BusinessDelete(AEntity: TPrdBom; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPrdBomService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPrdBomService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPrdBom>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TPrdBomService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPrdBom;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TPrdBomService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrdBom;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPrdBomService.Add(AEntity: TPrdBom);
begin
  DoAdd(AEntity);
end;

procedure TPrdBomService.Update(AEntity: TPrdBom);
begin
  DoUpdate(AEntity);
end;

procedure TPrdBomService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
