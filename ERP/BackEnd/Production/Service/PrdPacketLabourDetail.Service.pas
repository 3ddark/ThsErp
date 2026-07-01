unit PrdPacketLabourDetail.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  PrdPacketLabourDetail.Repository, PrdPacketLabourDetail;

type
  TPrdPacketLabourDetailService = class(TCrudService<TPrdPacketLabourDetail>)
  private
    FRepo: IRepository<TPrdPacketLabourDetail>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrdPacketLabourDetail>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrdPacketLabourDetail; override;
    procedure Add(AEntity: TPrdPacketLabourDetail); override;
    procedure Update(AEntity: TPrdPacketLabourDetail); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdPacketLabourDetail; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdPacketLabourDetail>; override;
    procedure BusinessInsert(AEntity: TPrdPacketLabourDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrdPacketLabourDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrdPacketLabourDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TPrdPacketLabourDetailService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPrdPacketLabourDetail, TPrdPacketLabourDetailRepository>;
end;

destructor TPrdPacketLabourDetailService.Destroy;
begin
  inherited;
end;

function TPrdPacketLabourDetailService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdPacketLabourDetail>;
begin
  if APermissionControl then
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;
  Result := FRepo.Find(AFilter, ALock);
end;

function TPrdPacketLabourDetailService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdPacketLabourDetail;
begin
  if APermissionControl then
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;
  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TPrdPacketLabourDetailService.BusinessInsert(AEntity: TPrdPacketLabourDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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
      if Uow.InTransaction then Self.UoW.Rollback;
      raise;
    end;
  end;
end;

procedure TPrdPacketLabourDetailService.BusinessUpdate(AEntity: TPrdPacketLabourDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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
      if Self.UoW.InTransaction then Self.UoW.Rollback;
      raise;
    end;
  end;
end;

procedure TPrdPacketLabourDetailService.BusinessDelete(AEntity: TPrdPacketLabourDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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
      if Self.UoW.InTransaction then Self.UoW.Rollback;
      raise;
    end;
  end;
end;

function TPrdPacketLabourDetailService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPrdPacketLabourDetailService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TPrdPacketLabourDetail>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TPrdPacketLabourDetailService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrdPacketLabourDetail;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TPrdPacketLabourDetailService.Add(AEntity: TPrdPacketLabourDetail);
begin
  FRepo.Add(AEntity);
end;

procedure TPrdPacketLabourDetailService.Update(AEntity: TPrdPacketLabourDetail);
begin
  FRepo.Update(AEntity);
end;

procedure TPrdPacketLabourDetailService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
