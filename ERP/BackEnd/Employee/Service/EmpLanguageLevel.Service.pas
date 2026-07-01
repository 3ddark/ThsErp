unit EmpLanguageLevel.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  EmpLanguageLevel.Repository, EmpLanguageLevel;

type
  TEmpLanguageLevelService = class(TCrudService<TEmpLanguageLevel>)
  private
    FRepo: IRepository<TEmpLanguageLevel>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEmpLanguageLevel>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEmpLanguageLevel; override;
    procedure Add(AEntity: TEmpLanguageLevel); override;
    procedure Update(AEntity: TEmpLanguageLevel); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpLanguageLevel; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpLanguageLevel>; override;
    procedure BusinessInsert(AEntity: TEmpLanguageLevel; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEmpLanguageLevel; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEmpLanguageLevel; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TEmpLanguageLevelService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEmpLanguageLevel, TEmpLanguageLevelRepository>;
end;

destructor TEmpLanguageLevelService.Destroy;
begin
  inherited;
end;

function TEmpLanguageLevelService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpLanguageLevel>;
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

function TEmpLanguageLevelService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpLanguageLevel;
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

procedure TEmpLanguageLevelService.BusinessInsert(AEntity: TEmpLanguageLevel; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpLanguageLevelService.BusinessUpdate(AEntity: TEmpLanguageLevel; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpLanguageLevelService.BusinessDelete(AEntity: TEmpLanguageLevel; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEmpLanguageLevelService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEmpLanguageLevelService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TEmpLanguageLevel>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TEmpLanguageLevelService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TEmpLanguageLevel;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TEmpLanguageLevelService.Add(AEntity: TEmpLanguageLevel);
begin
  FRepo.Add(AEntity);
end;

procedure TEmpLanguageLevelService.Update(AEntity: TEmpLanguageLevel);
begin
  FRepo.Update(AEntity);
end;

procedure TEmpLanguageLevelService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
