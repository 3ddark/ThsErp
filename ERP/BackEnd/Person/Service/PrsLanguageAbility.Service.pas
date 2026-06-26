unit PrsLanguageAbility.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  PrsLanguageAbility.Repository, PrsLanguageAbility;

type
  TPrsLanguageAbilityService = class(TCrudService<TPrsLisanBilgisi>)
  private
    FRepo: IRepository<TPrsLisanBilgisi>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrsLisanBilgisi>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrsLisanBilgisi; override;
    procedure Add(AEntity: TPrsLisanBilgisi); override;
    procedure Update(AEntity: TPrsLisanBilgisi); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrsLisanBilgisi; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrsLisanBilgisi>; override;
    procedure BusinessInsert(AEntity: TPrsLisanBilgisi; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrsLisanBilgisi; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrsLisanBilgisi; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TPrsLanguageAbilityService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPrsLisanBilgisi, TPrsLanguageAbilityRepository>;
end;

destructor TPrsLanguageAbilityService.Destroy;
begin
  inherited;
end;

function TPrsLanguageAbilityService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrsLisanBilgisi>;
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

function TPrsLanguageAbilityService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrsLisanBilgisi;
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

procedure TPrsLanguageAbilityService.BusinessInsert(AEntity: TPrsLisanBilgisi; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrsLanguageAbilityService.BusinessUpdate(AEntity: TPrsLisanBilgisi; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrsLanguageAbilityService.BusinessDelete(AEntity: TPrsLisanBilgisi; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPrsLanguageAbilityService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPrsLanguageAbilityService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TPrsLisanBilgisi>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TPrsLanguageAbilityService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrsLisanBilgisi;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TPrsLanguageAbilityService.Add(AEntity: TPrsLisanBilgisi);
begin
  FRepo.Add(AEntity);
end;

procedure TPrsLanguageAbilityService.Update(AEntity: TPrsLisanBilgisi);
begin
  FRepo.Update(AEntity);
end;

procedure TPrsLanguageAbilityService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
