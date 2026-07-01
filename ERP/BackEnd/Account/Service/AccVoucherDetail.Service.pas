unit AccVoucherDetail.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  AccVoucherDetail.Repository, AccVoucherDetail;

type
  TAccVoucherDetailService = class(TCrudService<TAccVoucherDetail>)
  private
    FRepo: IRepository<TAccVoucherDetail>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccVoucherDetail>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccVoucherDetail; override;
    procedure Add(AEntity: TAccVoucherDetail); override;
    procedure Update(AEntity: TAccVoucherDetail); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccVoucherDetail; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccVoucherDetail>; override;
    procedure BusinessInsert(AEntity: TAccVoucherDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccVoucherDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccVoucherDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TAccVoucherDetailService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccVoucherDetail, TAccVoucherDetailRepository>;
end;

destructor TAccVoucherDetailService.Destroy;
begin
  FRepo := nil;
  inherited;
end;

function TAccVoucherDetailService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccVoucherDetail>;
begin
  if APermissionControl then
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TAccVoucherDetailService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccVoucherDetail;
begin
  if APermissionControl then
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TAccVoucherDetailService.BusinessInsert(AEntity: TAccVoucherDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccVoucherDetailService.BusinessUpdate(AEntity: TAccVoucherDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccVoucherDetailService.BusinessDelete(AEntity: TAccVoucherDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TAccVoucherDetailService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccVoucherDetailService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TAccVoucherDetail>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TAccVoucherDetailService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccVoucherDetail;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TAccVoucherDetailService.Add(AEntity: TAccVoucherDetail);
begin
  FRepo.Add(AEntity);
end;

procedure TAccVoucherDetailService.Update(AEntity: TAccVoucherDetail);
begin
  FRepo.Update(AEntity);
end;

procedure TAccVoucherDetailService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
