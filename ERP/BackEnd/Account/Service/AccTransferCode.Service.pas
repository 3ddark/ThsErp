unit AccTransferCode.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  AccTransferCode.Repository, AccTransferCode;

type
  TAccTransferCodeService = class(TCrudService<TAccTransferCode>)
  private
    FRepo: IRepository<TAccTransferCode>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccTransferCode>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccTransferCode; override;
    procedure Add(AEntity: TAccTransferCode); override;
    procedure Update(AEntity: TAccTransferCode); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccTransferCode; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccTransferCode>; override;
    procedure BusinessInsert(AEntity: TAccTransferCode; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccTransferCode; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccTransferCode; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TAccTransferCodeService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccTransferCode, TAccTransferCodeRepository>;
end;

destructor TAccTransferCodeService.Destroy;
begin
  FRepo := nil;
  inherited;
end;

function TAccTransferCodeService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccTransferCode>;
begin
  if APermissionControl then
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TAccTransferCodeService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccTransferCode;
begin
  if APermissionControl then
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TAccTransferCodeService.BusinessInsert(AEntity: TAccTransferCode; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
      Self.UoW.IsAuthorized(ptAddRecord, APermissionControl);

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

procedure TAccTransferCodeService.BusinessUpdate(AEntity: TAccTransferCode; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
      Self.UoW.IsAuthorized(ptUpdate, APermissionControl);

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

procedure TAccTransferCodeService.BusinessDelete(AEntity: TAccTransferCode; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
      Self.UoW.IsAuthorized(ptDelete, APermissionControl);

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

function TAccTransferCodeService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccTransferCodeService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TAccTransferCode>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TAccTransferCodeService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccTransferCode;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TAccTransferCodeService.Add(AEntity: TAccTransferCode);
begin
  FRepo.Add(AEntity);
end;

procedure TAccTransferCodeService.Update(AEntity: TAccTransferCode);
begin
  FRepo.Update(AEntity);
end;

procedure TAccTransferCodeService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
