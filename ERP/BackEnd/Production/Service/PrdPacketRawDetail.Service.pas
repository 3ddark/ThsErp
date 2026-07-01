unit PrdPacketRawDetail.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  PrdPacketRawDetail.Repository, PrdPacketRawDetail;

type
  TPrdPacketRawDetailService = class(TCrudService<TPrdPacketRawDetail>)
  private
    FRepo: IRepository<TPrdPacketRawDetail>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrdPacketRawDetail>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrdPacketRawDetail; override;
    procedure Add(AEntity: TPrdPacketRawDetail); override;
    procedure Update(AEntity: TPrdPacketRawDetail); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdPacketRawDetail; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdPacketRawDetail>; override;
    procedure BusinessInsert(AEntity: TPrdPacketRawDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrdPacketRawDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrdPacketRawDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TPrdPacketRawDetailService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPrdPacketRawDetail, TPrdPacketRawDetailRepository>;
end;

destructor TPrdPacketRawDetailService.Destroy;
begin
  inherited;
end;

function TPrdPacketRawDetailService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdPacketRawDetail>;
begin
  if APermissionControl then
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;
  Result := FRepo.Find(AFilter, ALock);
end;

function TPrdPacketRawDetailService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdPacketRawDetail;
begin
  if APermissionControl then
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;
  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TPrdPacketRawDetailService.BusinessInsert(AEntity: TPrdPacketRawDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdPacketRawDetailService.BusinessUpdate(AEntity: TPrdPacketRawDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdPacketRawDetailService.BusinessDelete(AEntity: TPrdPacketRawDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPrdPacketRawDetailService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPrdPacketRawDetailService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TPrdPacketRawDetail>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TPrdPacketRawDetailService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrdPacketRawDetail;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TPrdPacketRawDetailService.Add(AEntity: TPrdPacketRawDetail);
begin
  FRepo.Add(AEntity);
end;

procedure TPrdPacketRawDetailService.Update(AEntity: TPrdPacketRawDetail);
begin
  FRepo.Update(AEntity);
end;

procedure TPrdPacketRawDetailService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
