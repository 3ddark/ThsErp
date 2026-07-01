unit AccVoucher.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  AccVoucher.Repository, AccVoucher;

type
  TAccVoucherService = class(TCrudService<TAccVoucher>)
  private
    FRepo: IRepository<TAccVoucher>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccVoucher>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccVoucher; override;
    procedure Add(AEntity: TAccVoucher); override;
    procedure Update(AEntity: TAccVoucher); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccVoucher; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccVoucher>; override;
    procedure BusinessInsert(AEntity: TAccVoucher; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccVoucher; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccVoucher; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TAccVoucherService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccVoucher, TAccVoucherRepository>;
end;

destructor TAccVoucherService.Destroy;
begin
  FRepo := nil;
  inherited;
end;

function TAccVoucherService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccVoucher>;
begin
  if APermissionControl then
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TAccVoucherService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccVoucher;
begin
  if APermissionControl then
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TAccVoucherService.BusinessInsert(AEntity: TAccVoucher; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccVoucherService.BusinessUpdate(AEntity: TAccVoucher; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccVoucherService.BusinessDelete(AEntity: TAccVoucher; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TAccVoucherService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccVoucherService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TAccVoucher>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TAccVoucherService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccVoucher;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TAccVoucherService.Add(AEntity: TAccVoucher);
begin
  FRepo.Add(AEntity);
end;

procedure TAccVoucherService.Update(AEntity: TAccVoucher);
begin
  FRepo.Update(AEntity);
end;

procedure TAccVoucherService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
