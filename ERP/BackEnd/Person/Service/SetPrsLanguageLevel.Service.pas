unit SetPrsLanguageLevel.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SetPrsLanguageLevel.Repository, SetPrsLanguageLevel;

type
  TSetPrsLanguageLevelService = class(TCrudService<TSetPrsLanguageLevel>)
  private
    FRepo: IRepository<TSetPrsLanguageLevel>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetPrsLanguageLevel>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetPrsLanguageLevel; override;
    procedure Add(AEntity: TSetPrsLanguageLevel); override;
    procedure Update(AEntity: TSetPrsLanguageLevel); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetPrsLanguageLevel; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetPrsLanguageLevel>; override;
    procedure BusinessInsert(AEntity: TSetPrsLanguageLevel; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetPrsLanguageLevel; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetPrsLanguageLevel; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSetPrsLanguageLevelService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSetPrsLanguageLevel, TSetPrsLanguageLevelRepository>;
end;

destructor TSetPrsLanguageLevelService.Destroy;
begin
  inherited;
end;

function TSetPrsLanguageLevelService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetPrsLanguageLevel>;
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

function TSetPrsLanguageLevelService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetPrsLanguageLevel;
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

procedure TSetPrsLanguageLevelService.BusinessInsert(AEntity: TSetPrsLanguageLevel; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSetPrsLanguageLevelService.BusinessUpdate(AEntity: TSetPrsLanguageLevel; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSetPrsLanguageLevelService.BusinessDelete(AEntity: TSetPrsLanguageLevel; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSetPrsLanguageLevelService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSetPrsLanguageLevelService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetPrsLanguageLevel>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TSetPrsLanguageLevelService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetPrsLanguageLevel;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TSetPrsLanguageLevelService.Add(AEntity: TSetPrsLanguageLevel);
begin
  FRepo.Add(AEntity);
end;

procedure TSetPrsLanguageLevelService.Update(AEntity: TSetPrsLanguageLevel);
begin
  FRepo.Update(AEntity);
end;

procedure TSetPrsLanguageLevelService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
