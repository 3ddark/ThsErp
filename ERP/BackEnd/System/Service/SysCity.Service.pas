unit SysCity.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext,
  SysCity.Repository, SysCity, SysCity.Exception;

type
  TSysCityService = class(TCrudService<TSysCity>)
  private
    FRepo: IRepository<TSysCity>;

    procedure DoAdd(AEntity: TSysCity);
    procedure DoUpdate(AEntity: TSysCity);
    procedure DoDelete(AId: Int64);

    procedure ValidateInsert(AEntity: TSysCity);
    procedure ValidateUpdate(AEntity: TSysCity);
    procedure ValidateDelete(AEntity: TSysCity);
    procedure ValidateUniqueCountryCity(AEntity: TSysCity; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysCity; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysCity>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysCity; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysCity; override;

    procedure Add(AEntity: TSysCity); override;
    procedure Update(AEntity: TSysCity); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysCity; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysCity>; override;
    procedure BusinessInsert(AEntity: TSysCity; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysCity; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysCity; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TSysCityService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysCity, TSysCityRepository>;
  Self.PermissionCode := PERMISSION_SYS_CITY;
end;

destructor TSysCityService.Destroy;
begin
  inherited;
end;

procedure TSysCityService.ValidateInsert(AEntity: TSysCity);
begin
  ValidateUniqueCountryCity(AEntity, coInsert);
end;

procedure TSysCityService.ValidateUpdate(AEntity: TSysCity);
begin
  ValidateUniqueCountryCity(AEntity, coUpdate);
end;

procedure TSysCityService.ValidateDelete(AEntity: TSysCity);
begin

end;

procedure TSysCityService.ValidateUniqueCountryCity(AEntity: TSysCity; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TSysCity;
begin
  //check unique
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('country_id', '=', TValue.From<Int64>(AEntity.CountryId)));
      LFilter.Add(TFilterCriterion.New('city_name', '=', TValue.From<string>(AEntity.CityName)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      if Assigned(LModel) then
        raise ESysCityExceptionCityCountryUnique.Create;
    finally
      LFilter.Free;
      if Assigned(LModel) then
        LModel.Free;
    end;
  end;
end;

procedure TSysCityService.DoAdd(AEntity: TSysCity);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSysCityService.DoUpdate(AEntity: TSysCity);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TSysCityService.DoDelete(AId: Int64);
var
  LEntity: TSysCity;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.CreateFmt('Record not found: %d', [AId]);

    ValidateAll(LEntity, coDelete);
    FRepo.Delete(LEntity);
  finally
    LEntity.Free;
  end;
end;

function TSysCityService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysCity>;
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

function TSysCityService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysCity;
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

procedure TSysCityService.BusinessInsert(AEntity: TSysCity; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysCityService.BusinessUpdate(AEntity: TSysCity; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysCityService.BusinessDelete(AEntity: TSysCity; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSysCityService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysCityService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysCity>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysCityService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysCity;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysCityService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysCity;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysCityService.Add(AEntity: TSysCity);
begin
  DoAdd(AEntity)
end;

procedure TSysCityService.Update(AEntity: TSysCity);
begin
  DoUpdate(AEntity)
end;

procedure TSysCityService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

procedure TSysCityService.ValidateBusinessRules(AEntity: TSysCity; AOperation: TCrudOperation);
begin
  case AOperation of
    coInsert: ValidateInsert(AEntity);
    coUpdate: ValidateUpdate(AEntity);
    coDelete: ValidateDelete(AEntity);
  end;
end;

end.

