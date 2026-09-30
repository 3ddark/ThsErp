unit StkWarehouse.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  StkWarehouse.Repository, StkWarehouse, StkWarehouse.Exception;

type
  TStkWarehouseService = class(TCrudService<TStkWarehouse>)
  private
    FRepo: IRepository<TStkWarehouse>;

    procedure DoAdd(AEntity: TStkWarehouse);
    procedure DoUpdate(AEntity: TStkWarehouse);
    procedure DoDelete(AId: Int64);
    procedure ValidateUnique(AEntity: TStkWarehouse; AOperation: TCrudOperation);
    procedure ValidateDefaults(AEntity: TStkWarehouse; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TStkWarehouse; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TStkWarehouse>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TStkWarehouse; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TStkWarehouse; override;

    procedure Add(AEntity: TStkWarehouse); override;
    procedure Update(AEntity: TStkWarehouse); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkWarehouse; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkWarehouse>; override;
    procedure BusinessInsert(AEntity: TStkWarehouse; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkWarehouse; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkWarehouse; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TStkWarehouseService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TStkWarehouse, TStkWarehouseRepository>;
  Self.PermissionCode := PERMISSION_STK_WAREHOUSE;
end;

destructor TStkWarehouseService.Destroy;
begin
  inherited;
end;

procedure TStkWarehouseService.ValidateUnique(AEntity: TStkWarehouse; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TStkWarehouse;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('warehouse_name', '=', TValue.From<string>(AEntity.WarehouseName)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EStkWarehouseExceptionWarehouseNameUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

// Her varsayılan tipte (hammadde / üretim / satış) en fazla bir ambar olabilir (DB: stk_warehouse_default_*_uidx)
procedure TStkWarehouseService.ValidateDefaults(AEntity: TStkWarehouse; AOperation: TCrudOperation);

  procedure Check(AIsDefault: Boolean; const AColumn, ALabelKey, ALabelDefault: string);
  var
    LFilter: TFilterCriteria;
    LModel: TStkWarehouse;
  begin
    if not AIsDefault then
      Exit;

    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New(AColumn, '=', TValue.From<Boolean>(True)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise Exception.Create(Format(
            TLocalizationManager.Translate(TLangKeys.TStkWarehouse.DefaultWarehouseExists, 'Another warehouse is already the default for: %s'),
            [TLocalizationManager.Translate(ALabelKey, ALabelDefault)]) + ' (' + LModel.WarehouseName + ')');
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;

begin
  if not (AOperation in [coInsert, coUpdate]) then
    Exit;

  Check(AEntity.DefaultRawMaterial, 'default_raw_material', TLangKeys.TStkWarehouse.ColDefaultRawMaterial, 'Default Raw Material');
  Check(AEntity.DefaultProduction, 'default_production', TLangKeys.TStkWarehouse.ColDefaultProduction, 'Default Production');
  Check(AEntity.DefaultSales, 'default_sales', TLangKeys.TStkWarehouse.ColDefaultSales, 'Default Sales');
end;

procedure TStkWarehouseService.ValidateBusinessRules(AEntity: TStkWarehouse; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.WarehouseName := AnsiUpperCase(Trim(AEntity.WarehouseName));
  end;

  ValidateUnique(AEntity, AOperation);
  ValidateDefaults(AEntity, AOperation);
end;

procedure TStkWarehouseService.DoAdd(AEntity: TStkWarehouse);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TStkWarehouseService.DoUpdate(AEntity: TStkWarehouse);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TStkWarehouseService.DoDelete(AId: Int64);
var
  LEntity: TStkWarehouse;
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

function TStkWarehouseService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkWarehouse>;
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

function TStkWarehouseService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkWarehouse;
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

procedure TStkWarehouseService.BusinessInsert(AEntity: TStkWarehouse; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkWarehouseService.BusinessUpdate(AEntity: TStkWarehouse; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkWarehouseService.BusinessDelete(AEntity: TStkWarehouse; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TStkWarehouseService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TStkWarehouseService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TStkWarehouse>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TStkWarehouseService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TStkWarehouse;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TStkWarehouseService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TStkWarehouse;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TStkWarehouseService.Add(AEntity: TStkWarehouse);
begin
  DoAdd(AEntity);
end;

procedure TStkWarehouseService.Update(AEntity: TStkWarehouse);
begin
  DoUpdate(AEntity);
end;

procedure TStkWarehouseService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
