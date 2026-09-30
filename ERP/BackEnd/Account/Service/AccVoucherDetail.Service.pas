unit AccVoucherDetail.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  AccVoucherDetail.Repository, AccVoucherDetail;

type
  TAccVoucherDetailService = class(TCrudService<TAccVoucherDetail>)
  private
    FRepo: IRepository<TAccVoucherDetail>;

    procedure DoAdd(AEntity: TAccVoucherDetail);
    procedure DoUpdate(AEntity: TAccVoucherDetail);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TAccVoucherDetail);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TAccVoucherDetail; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccVoucherDetail>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccVoucherDetail; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TAccVoucherDetail; override;

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

uses
  SysPermission.Service;

constructor TAccVoucherDetailService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccVoucherDetail, TAccVoucherDetailRepository>;
  Self.PermissionCode := PERMISSION_ACC_VOUCHER;
end;

destructor TAccVoucherDetailService.Destroy;
begin
  inherited;
end;

procedure TAccVoucherDetailService.ValidateRequiredReferences(AEntity: TAccVoucherDetail);

  procedure Check(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  Check(AEntity.AccVoucherId, TLangKeys.TAccVoucherDetail.ColVoucher, 'Voucher');
end;

procedure TAccVoucherDetailService.ValidateBusinessRules(AEntity: TAccVoucherDetail; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    ValidateRequiredReferences(AEntity);
  end;
end;

procedure TAccVoucherDetailService.DoAdd(AEntity: TAccVoucherDetail);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TAccVoucherDetailService.DoUpdate(AEntity: TAccVoucherDetail);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TAccVoucherDetailService.DoDelete(AId: Int64);
var
  LEntity: TAccVoucherDetail;
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

function TAccVoucherDetailService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccVoucherDetail>;
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

function TAccVoucherDetailService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccVoucherDetail;
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

procedure TAccVoucherDetailService.BusinessInsert(AEntity: TAccVoucherDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccVoucherDetailService.BusinessUpdate(AEntity: TAccVoucherDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccVoucherDetailService.BusinessDelete(AEntity: TAccVoucherDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TAccVoucherDetailService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccVoucherDetailService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TAccVoucherDetail>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TAccVoucherDetailService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TAccVoucherDetail;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TAccVoucherDetailService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccVoucherDetail;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TAccVoucherDetailService.Add(AEntity: TAccVoucherDetail);
begin
  DoAdd(AEntity);
end;

procedure TAccVoucherDetailService.Update(AEntity: TAccVoucherDetail);
begin
  DoUpdate(AEntity);
end;

procedure TAccVoucherDetailService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
