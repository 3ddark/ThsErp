unit StkProductType.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  StkProductType.Repository, StkProductType, LocalizationManager;

type
  TStkProductTypeService = class(TCrudService<TStkProductType>)
  private
    FRepo: IRepository<TStkProductType>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TStkProductType>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TStkProductType; override;
    procedure Add(AEntity: TStkProductType); override;
    procedure Update(AEntity: TStkProductType); override;
    procedure Delete(AId: Int64); override;

    procedure ValidateBusinessRules(AEntity: TStkProductType; AOperation: TCrudOperation); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkProductType; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkProductType>; override;
    procedure BusinessInsert(AEntity: TStkProductType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkProductType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkProductType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TStkProductTypeService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TStkProductType, TStkProductTypeRepository>;
  PermissionCode := 1043;
end;

destructor TStkProductTypeService.Destroy;
begin
  FRepo := nil;
  inherited;
end;

procedure TStkProductTypeService.ValidateBusinessRules(AEntity: TStkProductType; AOperation: TCrudOperation);
begin
  if Trim(AEntity.ProductTypeName) = '' then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TStock.ProductTypeNameRequired, 'Ürün tipi adı boş bırakılamaz.'));
end;

function TStkProductTypeService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkProductType>;
var
  LStartedTx: Boolean;
begin
  Self.IsAuthorized(ptRead, APermissionControl);

  LStartedTx := False;
  if AWithBegin and not Self.UoW.InTransaction then
  begin
    Self.UoW.BeginTransaction;
    LStartedTx := True;
  end;

  try
    Result := FRepo.Find(AFilter, ALock);
  except
    if LStartedTx and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TStkProductTypeService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkProductType;
var
  LStartedTx: Boolean;
begin
  Self.IsAuthorized(ptRead, APermissionControl);

  LStartedTx := False;
  if AWithBegin and not Self.UoW.InTransaction then
  begin
    Self.UoW.BeginTransaction;
    LStartedTx := True;
  end;

  try
    Result := FRepo.FindById(AId, ALock);
    if (Result = nil) and LStartedTx and Self.UoW.InTransaction then
      Self.UoW.Rollback;
  except
    if LStartedTx and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TStkProductTypeService.BusinessInsert(AEntity: TStkProductType; AWithBegin, AWithCommit, APermissionControl: Boolean);
var
  LStartedTx: Boolean;
begin
  Self.IsAuthorized(ptAddRecord, APermissionControl);

  ValidateAll(AEntity, coInsert);

  LStartedTx := False;
  if AWithBegin and not Self.UoW.InTransaction then
  begin
    Self.UoW.BeginTransaction;
    LStartedTx := True;
  end;

  try
    FRepo.Add(AEntity);

    if AWithCommit and Self.UoW.InTransaction and (LStartedTx or AWithBegin) then
      Self.UoW.Commit;
  except
    if LStartedTx and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TStkProductTypeService.BusinessUpdate(AEntity: TStkProductType; AWithBegin, AWithCommit, APermissionControl: Boolean);
var
  LStartedTx: Boolean;
begin
  Self.IsAuthorized(ptUpdate, APermissionControl);

  ValidateAll(AEntity, coUpdate);

  LStartedTx := False;
  if AWithBegin and not Self.UoW.InTransaction then
  begin
    Self.UoW.BeginTransaction;
    LStartedTx := True;
  end;

  try
    FRepo.Update(AEntity);

    if AWithCommit and Self.UoW.InTransaction and (LStartedTx or AWithBegin) then
      Self.UoW.Commit;
  except
    if LStartedTx and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TStkProductTypeService.BusinessDelete(AEntity: TStkProductType; AWithBegin, AWithCommit, APermissionControl: Boolean);
var
  LStartedTx: Boolean;
begin
  Self.IsAuthorized(ptDelete, APermissionControl);

  ValidateAll(AEntity, coDelete);

  LStartedTx := False;
  if AWithBegin and not Self.UoW.InTransaction then
  begin
    Self.UoW.BeginTransaction;
    LStartedTx := True;
  end;

  try
    FRepo.Delete(AEntity);

    if AWithCommit and Self.UoW.InTransaction and (LStartedTx or AWithBegin) then
      Self.UoW.Commit;
  except
    if LStartedTx and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TStkProductTypeService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TStkProductTypeService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TStkProductType>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TStkProductTypeService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TStkProductType;
begin
  Result := FRepo.FindById(AId, ALock);
end;

procedure TStkProductTypeService.Add(AEntity: TStkProductType);
begin
  FRepo.Add(AEntity);
end;

procedure TStkProductTypeService.Update(AEntity: TStkProductType);
begin
  FRepo.Update(AEntity);
end;

procedure TStkProductTypeService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
