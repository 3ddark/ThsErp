unit SysCountry.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager, Logger,
  SysCountry.Repository, SysCountry, SysCountry.Exception;

type
  TSysCountryService = class(TCrudService<TSysCountry>)
  private
    FRepo: IRepository<TSysCountry>;

    procedure DoAdd(AEntity: TSysCountry);
    procedure DoUpdate(AEntity: TSysCountry);
    procedure DoDelete(AId: Int64);

    procedure ValidateInsert(AEntity: TSysCountry);
    procedure ValidateUpdate(AEntity: TSysCountry);
    procedure ValidateDelete(AEntity: TSysCountry);
    procedure ValidateRegionNameUnique(AEntity: TSysCountry; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysCountry; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysCountry>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysCountry; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysCountry; override;

    procedure Add(AEntity: TSysCountry); override;
    procedure Update(AEntity: TSysCountry); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysCountry; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysCountry>; override;
    procedure BusinessInsert(AEntity: TSysCountry; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysCountry; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysCountry; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TSysCountryService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysCountry, TSysCountryRepository>;
  Self.PermissionCode := PERMISSION_SYS_COUNTRY;
end;

destructor TSysCountryService.Destroy;
begin
  inherited;
end;

procedure TSysCountryService.ValidateInsert(AEntity: TSysCountry);
begin
  ValidateRegionNameUnique(AEntity, coInsert);
end;

procedure TSysCountryService.ValidateUpdate(AEntity: TSysCountry);
begin
  ValidateRegionNameUnique(AEntity, coUpdate);
end;

procedure TSysCountryService.ValidateDelete(AEntity: TSysCountry);
begin

end;

procedure TSysCountryService.ValidateRegionNameUnique(AEntity: TSysCountry; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TSysCountry;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('country_code', '=', TValue.From<string>(AEntity.CountryCode)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise ESysCountryExceptionCodeUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TSysCountryService.DoAdd(AEntity: TSysCountry);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSysCountryService.DoUpdate(AEntity: TSysCountry);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TSysCountryService.DoDelete(AId: Int64);
var
  LEntity: TSysCountry;
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

function TSysCountryService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysCountry>;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.Find(AFilter, ALock);
  except
    if Self.UoW.InTransaction then
    begin
      Self.UoW.Rollback;
    end;
    raise;
  end;
end;

function TSysCountryService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysCountry;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.FindById(AId, ALock);
  except
    if Self.UoW.InTransaction then
    begin
      Self.UoW.Rollback;
    end;
    raise;
  end;
end;

procedure TSysCountryService.BusinessInsert(AEntity: TSysCountry; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoAdd(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Uow.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

procedure TSysCountryService.BusinessUpdate(AEntity: TSysCountry; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoUpdate(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

procedure TSysCountryService.BusinessDelete(AEntity: TSysCountry; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptDelete, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoDelete(AEntity.Id);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

function TSysCountryService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysCountryService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysCountry>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysCountryService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysCountry;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysCountryService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysCountry;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysCountryService.Add(AEntity: TSysCountry);
begin
  DoAdd(AEntity)
end;

procedure TSysCountryService.Update(AEntity: TSysCountry);
begin
  DoUpdate(AEntity)
end;

procedure TSysCountryService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

procedure TSysCountryService.ValidateBusinessRules(AEntity: TSysCountry; AOperation: TCrudOperation);
begin
  case AOperation of
    coInsert: ValidateInsert(AEntity);
    coUpdate: ValidateUpdate(AEntity);
    coDelete: ValidateDelete(AEntity);
  end;
end;

end.
