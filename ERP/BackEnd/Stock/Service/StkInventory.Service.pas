unit StkInventory.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  StkInventory.Repository, StkInventory, StkInventory.Exception;

type
  TStkInventoryService = class(TCrudService<TStkInventory>)
  private
    FRepo: IRepository<TStkInventory>;

    procedure DoAdd(AEntity: TStkInventory);
    procedure DoUpdate(AEntity: TStkInventory);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TStkInventory);
    procedure ValidateUnique(AEntity: TStkInventory; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TStkInventory; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TStkInventory>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TStkInventory; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TStkInventory; override;

    procedure Add(AEntity: TStkInventory); override;
    procedure Update(AEntity: TStkInventory); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkInventory; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkInventory>; override;
    procedure BusinessInsert(AEntity: TStkInventory; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkInventory; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkInventory; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TStkInventoryService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TStkInventory, TStkInventoryRepository>;
  Self.PermissionCode := PERMISSION_STK_INVENTORY;
end;

destructor TStkInventoryService.Destroy;
begin
  inherited;
end;

procedure TStkInventoryService.ValidateRequiredReferences(AEntity: TStkInventory);

  procedure Check(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  Check(AEntity.StkGroupId, TLangKeys.TStkInventory.ColGroup, 'Group');
  Check(AEntity.StkProductTypeId, TLangKeys.TStkInventory.ColProductType, 'Product Type');
  Check(AEntity.SysUomId, TLangKeys.TStkInventory.ColUom, 'Unit');
end;

procedure TStkInventoryService.ValidateUnique(AEntity: TStkInventory; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TStkInventory;
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
          raise EStkInventoryExceptionCodeUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TStkInventoryService.ValidateBusinessRules(AEntity: TStkInventory; AOperation: TCrudOperation);
var
  LDefaultCurrency: string;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.Code := AnsiUpperCase(Trim(AEntity.Code));
    AEntity.Name := Trim(AEntity.Name);
    AEntity.BuyingCurrency := Trim(AEntity.BuyingCurrency);
    AEntity.SalesCurrency := Trim(AEntity.SalesCurrency);
    AEntity.ExportCurrency := Trim(AEntity.ExportCurrency);
    AEntity.SpecialCode := Trim(AEntity.SpecialCode);
    AEntity.Brand := Trim(AEntity.Brand);
    AEntity.HsNo := AnsiUpperCase(Trim(AEntity.HsNo));
    AEntity.DiibProductDescription := Trim(AEntity.DiibProductDescription);
    AEntity.ProductOverview := Trim(AEntity.ProductOverview);
    ValidateRequiredReferences(AEntity);
    // Boş para birimleri fn_default_currency() (uygulama ayarı) ile doldurulur; DB kolonları NOT NULL
    if (AEntity.BuyingCurrency = '') or (AEntity.SalesCurrency = '') or (AEntity.ExportCurrency = '') then
    begin
      LDefaultCurrency := TStkInventoryRepository(FRepo).GetDefaultCurrency;
      if AEntity.BuyingCurrency = '' then
        AEntity.BuyingCurrency := LDefaultCurrency;
      if AEntity.SalesCurrency = '' then
        AEntity.SalesCurrency := LDefaultCurrency;
      if AEntity.ExportCurrency = '' then
        AEntity.ExportCurrency := LDefaultCurrency;
    end;
    if (AEntity.BuyingDiscount < 0) or (AEntity.BuyingDiscount > 100) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TStkInventory.ColBuyingDiscount, 'Buying Discount (%)') + ': ' +
        Format(TLocalizationManager.Translate(TLangKeys.TValidation.Range, 'Field must be between %s and %s'), ['0', '100']));
    if (AEntity.SalesDiscount < 0) or (AEntity.SalesDiscount > 100) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TStkInventory.ColSalesDiscount, 'Sales Discount (%)') + ': ' +
        Format(TLocalizationManager.Translate(TLangKeys.TValidation.Range, 'Field must be between %s and %s'), ['0', '100']));
    if AEntity.MinStockAmount < 0 then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TStkInventory.ColMinStockAmount, 'Minimum Stock') + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.NegativeValueNotAllowed, 'Negative values are not allowed'));
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TStkInventoryService.DoAdd(AEntity: TStkInventory);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TStkInventoryService.DoUpdate(AEntity: TStkInventory);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TStkInventoryService.DoDelete(AId: Int64);
var
  LEntity: TStkInventory;
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

function TStkInventoryService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkInventory>;
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

function TStkInventoryService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkInventory;
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

procedure TStkInventoryService.BusinessInsert(AEntity: TStkInventory; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkInventoryService.BusinessUpdate(AEntity: TStkInventory; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkInventoryService.BusinessDelete(AEntity: TStkInventory; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TStkInventoryService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TStkInventoryService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TStkInventory>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TStkInventoryService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TStkInventory;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TStkInventoryService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TStkInventory;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TStkInventoryService.Add(AEntity: TStkInventory);
begin
  DoAdd(AEntity);
end;

procedure TStkInventoryService.Update(AEntity: TStkInventory);
begin
  DoUpdate(AEntity);
end;

procedure TStkInventoryService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
