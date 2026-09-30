unit StkProductType.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  StkProductType.Repository, StkProductType, StkProductType.Exception;

type
  TStkProductTypeService = class(TCrudService<TStkProductType>)
  private
    FRepo: IRepository<TStkProductType>;

    procedure DoAdd(AEntity: TStkProductType);
    procedure DoUpdate(AEntity: TStkProductType);
    procedure DoDelete(AId: Int64);
    procedure ValidateUnique(AEntity: TStkProductType; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TStkProductType; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TStkProductType>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TStkProductType; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TStkProductType; override;

    procedure Add(AEntity: TStkProductType); override;
    procedure Update(AEntity: TStkProductType); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkProductType; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkProductType>; override;
    procedure BusinessInsert(AEntity: TStkProductType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkProductType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkProductType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TStkProductTypeService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TStkProductType, TStkProductTypeRepository>;
  Self.PermissionCode := PERMISSION_STK_PRODUCT_TYPE;
end;

destructor TStkProductTypeService.Destroy;
begin
  inherited;
end;

procedure TStkProductTypeService.ValidateUnique(AEntity: TStkProductType; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TStkProductType;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('product_type_name', '=', TValue.From<string>(AEntity.ProductTypeName)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EStkProductTypeExceptionProductTypeNameUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TStkProductTypeService.ValidateBusinessRules(AEntity: TStkProductType; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.ProductTypeName := AnsiUpperCase(Trim(AEntity.ProductTypeName));
    AEntity.Description := Trim(AEntity.Description);
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TStkProductTypeService.DoAdd(AEntity: TStkProductType);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TStkProductTypeService.DoUpdate(AEntity: TStkProductType);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TStkProductTypeService.DoDelete(AId: Int64);
var
  LEntity: TStkProductType;
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

function TStkProductTypeService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkProductType>;
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

function TStkProductTypeService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkProductType;
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

procedure TStkProductTypeService.BusinessInsert(AEntity: TStkProductType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkProductTypeService.BusinessUpdate(AEntity: TStkProductType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkProductTypeService.BusinessDelete(AEntity: TStkProductType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TStkProductTypeService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TStkProductTypeService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TStkProductType>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TStkProductTypeService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TStkProductType;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TStkProductTypeService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TStkProductType;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TStkProductTypeService.Add(AEntity: TStkProductType);
begin
  DoAdd(AEntity);
end;

procedure TStkProductTypeService.Update(AEntity: TStkProductType);
begin
  DoUpdate(AEntity);
end;

procedure TStkProductTypeService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
