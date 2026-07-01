unit EmpLanguageAbility.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  EmpLanguageAbility.Repository, EmpLanguageAbility;

type
  TEmpLanguageAbilityService = class(TCrudService<TEmpLanguageAbility>)
  private
    FRepo: IRepository<TEmpLanguageAbility>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEmpLanguageAbility>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEmpLanguageAbility; override;
    procedure Add(AEntity: TEmpLanguageAbility); override;
    procedure Update(AEntity: TEmpLanguageAbility); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpLanguageAbility; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpLanguageAbility>; override;
    procedure BusinessInsert(AEntity: TEmpLanguageAbility; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEmpLanguageAbility; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEmpLanguageAbility; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TEmpLanguageAbilityService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEmpLanguageAbility, TEmpLanguageAbilityRepository>;
end;

destructor TEmpLanguageAbilityService.Destroy;
begin
  inherited;
end;

function TEmpLanguageAbilityService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpLanguageAbility>;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
    //CheckPermission if not throw exception
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TEmpLanguageAbilityService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpLanguageAbility;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
    //CheckPermission if not throw exception
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TEmpLanguageAbilityService.BusinessInsert(AEntity: TEmpLanguageAbility; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      Self.UoW.IsAuthorized(ptAddRecord, APermissionControl);
      //CheckPermission if not throw exception
    end;

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Add(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Uow.InTransaction then
        Self.UoW.Rollback;
      raise
    end;
  end;
end;

procedure TEmpLanguageAbilityService.BusinessUpdate(AEntity: TEmpLanguageAbility; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      Self.UoW.IsAuthorized(ptUpdate, APermissionControl);
      //CheckPermission if not throw exception
    end;

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Update(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
        Self.UoW.Rollback;
      raise;
    end;
  end;
end;

procedure TEmpLanguageAbilityService.BusinessDelete(AEntity: TEmpLanguageAbility; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      Self.UoW.IsAuthorized(ptDelete, APermissionControl);
      //CheckPermission if not throw exception
    end;

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Delete(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
        Self.UoW.Rollback;
      raise;
    end;
  end;
end;

function TEmpLanguageAbilityService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEmpLanguageAbilityService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TEmpLanguageAbility>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TEmpLanguageAbilityService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TEmpLanguageAbility;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TEmpLanguageAbilityService.Add(AEntity: TEmpLanguageAbility);
begin
  FRepo.Add(AEntity);
end;

procedure TEmpLanguageAbilityService.Update(AEntity: TEmpLanguageAbility);
begin
  FRepo.Update(AEntity);
end;

procedure TEmpLanguageAbilityService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
