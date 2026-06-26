unit SetPrsPersonType.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SetPrsPersonType.Repository, SetPrsPersonType;

type
  TSetPrsPersonTypeService = class(TCrudService<TSetPrsPersonType>)
  private
    FRepo: IRepository<TSetPrsPersonType>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetPrsPersonType>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetPrsPersonType; override;
    procedure Add(AEntity: TSetPrsPersonType); override;
    procedure Update(AEntity: TSetPrsPersonType); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetPrsPersonType; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetPrsPersonType>; override;
    procedure BusinessInsert(AEntity: TSetPrsPersonType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetPrsPersonType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetPrsPersonType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSetPrsPersonTypeService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSetPrsPersonType, TSetPrsPersonTypeRepository>;
end;

destructor TSetPrsPersonTypeService.Destroy;
begin
  inherited;
end;

function TSetPrsPersonTypeService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetPrsPersonType>;
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

function TSetPrsPersonTypeService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetPrsPersonType;
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

procedure TSetPrsPersonTypeService.BusinessInsert(AEntity: TSetPrsPersonType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSetPrsPersonTypeService.BusinessUpdate(AEntity: TSetPrsPersonType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSetPrsPersonTypeService.BusinessDelete(AEntity: TSetPrsPersonType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSetPrsPersonTypeService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSetPrsPersonTypeService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetPrsPersonType>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TSetPrsPersonTypeService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetPrsPersonType;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TSetPrsPersonTypeService.Add(AEntity: TSetPrsPersonType);
begin
  FRepo.Add(AEntity);
end;

procedure TSetPrsPersonTypeService.Update(AEntity: TSetPrsPersonType);
begin
  FRepo.Update(AEntity);
end;

procedure TSetPrsPersonTypeService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
