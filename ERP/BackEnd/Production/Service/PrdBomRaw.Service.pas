unit PrdBomRaw.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  PrdBomRaw.Repository, PrdBomRaw, PrdBomRaw.Exception;

type
  TPrdBomRawService = class(TCrudService<TPrdBomRaw>)
  private
    FRepo: IRepository<TPrdBomRaw>;

    procedure DoAdd(AEntity: TPrdBomRaw);
    procedure DoUpdate(AEntity: TPrdBomRaw);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TPrdBomRaw);
    procedure ValidateUnique(AEntity: TPrdBomRaw; AOperation: TCrudOperation);
    procedure ValidateBomRules(AEntity: TPrdBomRaw);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPrdBomRaw; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrdBomRaw>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrdBomRaw; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPrdBomRaw; override;

    procedure Add(AEntity: TPrdBomRaw); override;
    procedure Update(AEntity: TPrdBomRaw); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdBomRaw; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdBomRaw>; override;
    procedure BusinessInsert(AEntity: TPrdBomRaw; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrdBomRaw; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrdBomRaw; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, PrdBom, PrdBom.Repository;

constructor TPrdBomRawService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPrdBomRaw, TPrdBomRawRepository>;
  Self.PermissionCode := PERMISSION_PRD_BOM;
end;

destructor TPrdBomRawService.Destroy;
begin
  inherited;
end;

procedure TPrdBomRawService.ValidateRequiredReferences(AEntity: TPrdBomRaw);

  procedure CheckId(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  CheckId(AEntity.PrdBomId, TLangKeys.TPrdBomRaw.ColPrdBomId, 'BoM');
  CheckId(AEntity.StkInventoryId, TLangKeys.TPrdBomRaw.ColStkInventoryId, 'Raw Material');
end;

procedure TPrdBomRawService.ValidateUnique(AEntity: TPrdBomRaw; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TPrdBomRaw;
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
          raise EPrdBomRawExceptionInventoryUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

// Alt reçete kendisi olamaz; reçetenin ürünü kendi hammaddesi olamaz
procedure TPrdBomRawService.ValidateBomRules(AEntity: TPrdBomRaw);
var
  LBom: TPrdBom;
begin
  if (AEntity.SubPrdBomId > 0) and (AEntity.SubPrdBomId = AEntity.PrdBomId) then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.SubBomSelf, 'A BoM cannot use itself as sub BoM.'));

  LBom := Self.UoW.GetRepository<TPrdBom, TPrdBomRepository>.FindById(AEntity.PrdBomId, False);
  try
    if Assigned(LBom) and (LBom.StkInventoryId = AEntity.StkInventoryId) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.RawIsProduct, 'The product of the BoM cannot be its own raw material.'));
  finally
    LBom.Free;
  end;
end;

procedure TPrdBomRawService.ValidateBusinessRules(AEntity: TPrdBomRaw; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    ValidateRequiredReferences(AEntity);
    if AEntity.Quantity <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.ColQuantity, 'Quantity') + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero'));
    if (AEntity.ScrapRate < 0) or (AEntity.ScrapRate >= 100) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.ColScrapRate, 'Scrap Rate (%)') + ': ' +
        Format(TLocalizationManager.Translate(TLangKeys.TValidation.Range, 'Field must be between %s and %s'), ['0', '99.99']));
    ValidateBomRules(AEntity);
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TPrdBomRawService.DoAdd(AEntity: TPrdBomRaw);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPrdBomRawService.DoUpdate(AEntity: TPrdBomRaw);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TPrdBomRawService.DoDelete(AId: Int64);
var
  LEntity: TPrdBomRaw;
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

function TPrdBomRawService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdBomRaw>;
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

function TPrdBomRawService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdBomRaw;
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

procedure TPrdBomRawService.BusinessInsert(AEntity: TPrdBomRaw; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdBomRawService.BusinessUpdate(AEntity: TPrdBomRaw; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdBomRawService.BusinessDelete(AEntity: TPrdBomRaw; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPrdBomRawService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPrdBomRawService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPrdBomRaw>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TPrdBomRawService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPrdBomRaw;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TPrdBomRawService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrdBomRaw;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPrdBomRawService.Add(AEntity: TPrdBomRaw);
begin
  DoAdd(AEntity);
end;

procedure TPrdBomRawService.Update(AEntity: TPrdBomRaw);
begin
  DoUpdate(AEntity);
end;

procedure TPrdBomRawService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
