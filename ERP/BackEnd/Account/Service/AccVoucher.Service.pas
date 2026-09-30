unit AccVoucher.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  AccVoucher.Repository, AccVoucher, AccVoucher.Exception;

type
  TAccVoucherService = class(TCrudService<TAccVoucher>)
  private
    FRepo: IRepository<TAccVoucher>;

    procedure DoAdd(AEntity: TAccVoucher);
    procedure DoUpdate(AEntity: TAccVoucher);
    procedure DoDelete(AId: Int64);
    procedure ValidateUnique(AEntity: TAccVoucher; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TAccVoucher; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccVoucher>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccVoucher; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TAccVoucher; override;

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

uses
  SysPermission.Service;

constructor TAccVoucherService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccVoucher, TAccVoucherRepository>;
  Self.PermissionCode := PERMISSION_ACC_VOUCHER;
end;

destructor TAccVoucherService.Destroy;
begin
  inherited;
end;

procedure TAccVoucherService.ValidateUnique(AEntity: TAccVoucher; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TAccVoucher;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('journal_no', '=', TValue.From<Integer>(AEntity.JournalNo)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EAccVoucherExceptionJournalNoUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TAccVoucherService.ValidateBusinessRules(AEntity: TAccVoucher; AOperation: TCrudOperation);
begin
  ValidateUnique(AEntity, AOperation);
end;

procedure TAccVoucherService.DoAdd(AEntity: TAccVoucher);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TAccVoucherService.DoUpdate(AEntity: TAccVoucher);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TAccVoucherService.DoDelete(AId: Int64);
var
  LEntity: TAccVoucher;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    FRepo.Delete(LEntity);
  finally
    LEntity.Free;
  end;
end;

function TAccVoucherService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccVoucher>;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.Find(AFilter, ALock);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TAccVoucherService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccVoucher;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.FindById(AId, ALock);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TAccVoucherService.BusinessInsert(AEntity: TAccVoucher; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoAdd(AEntity);

    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TAccVoucherService.BusinessUpdate(AEntity: TAccVoucher; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoUpdate(AEntity);

    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TAccVoucherService.BusinessDelete(AEntity: TAccVoucher; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptDelete, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoDelete(AEntity.Id);

    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TAccVoucherService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccVoucherService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TAccVoucher>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TAccVoucherService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TAccVoucher;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TAccVoucherService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccVoucher;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TAccVoucherService.Add(AEntity: TAccVoucher);
begin
  DoAdd(AEntity);
end;

procedure TAccVoucherService.Update(AEntity: TAccVoucher);
begin
  DoUpdate(AEntity);
end;

procedure TAccVoucherService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
