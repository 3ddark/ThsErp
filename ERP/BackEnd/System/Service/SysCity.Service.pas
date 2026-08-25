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
  Self.PermissionCode := PERMISSION_CITY;
end;

destructor TSysCityService.Destroy;
begin
  inherited;
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

    ValidateAll(AEntity, coInsert);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Add(AEntity);

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

    ValidateAll(AEntity, coUpdate);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Update(AEntity);

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

    ValidateAll(AEntity, coDelete);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Delete(AEntity);

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
  FRepo.Add(AEntity);
end;

procedure TSysCityService.Update(AEntity: TSysCity);
begin
  FRepo.Update(AEntity);
end;

procedure TSysCityService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

procedure TSysCityService.ValidateBusinessRules(AEntity: TSysCity; AOperation: TCrudOperation);
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

end.

