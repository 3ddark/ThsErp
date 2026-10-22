unit AccVoucherDetail.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  AccVoucherDetail.Repository, AccVoucherDetail, AccVoucher.Exception, AccVoucher, AccVoucher.Repository;

type
  TAccVoucherDetailService = class(TCrudService<TAccVoucherDetail>)
  private
    FRepo: IRepository<TAccVoucherDetail>;
    FVoucherRepo: IRepository<TAccVoucher>;

    procedure DoAdd(AEntity: TAccVoucherDetail);
    procedure DoUpdate(AEntity: TAccVoucherDetail);
    procedure DoDelete(AId: Int64);

    class procedure FailRequired(const AKey, ADefault: string); static;
  public
    constructor Create;
    destructor Destroy; override;

    // Kalemin kendi alanları (DB'siz): hesap, borç ya da alacak (biri, sıfırdan büyük). Tek kalem kaydı
    // (ValidateBusinessRules) ve belge kaydı (TAccVoucherService.BusinessSaveWithDetails) ortak kullanır
    class procedure CheckLine(AEntity: TAccVoucherDetail); static;
    procedure ValidateBusinessRules(AEntity: TAccVoucherDetail; AOperation: TCrudOperation); override;

    // Fişte yalnız hareket gören (SON) hesaplar
    procedure CheckAccounts(const ALines: TArray<TAccVoucherDetail>);

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
  SysPermission.Service, AccLookup;

constructor TAccVoucherDetailService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccVoucherDetail, TAccVoucherDetailRepository>;
  FVoucherRepo := Self.UoW.GetRepository<TAccVoucher, TAccVoucherRepository>;
  Self.PermissionCode := PERMISSION_ACC_VOUCHER;
end;

destructor TAccVoucherDetailService.Destroy;
begin
  inherited;
end;

procedure TAccVoucherDetailService.CheckAccounts(const ALines: TArray<TAccVoucherDetail>);
var
  LIds: TArray<Int64>;
  LLine: TAccVoucherDetail;
  LTypes: TDictionary<Int64, Int64>;
  LType: Int64;
begin
  LIds := [];
  for LLine in ALines do
    LIds := LIds + [LLine.AccAccountId];
  LTypes := TAccVoucherDetailRepository(FRepo).AccountTypes(LIds);
  try
    for LLine in ALines do
      if not LTypes.TryGetValue(LLine.AccAccountId, LType) or (LType <> ACC_ACCOUNT_TYPE_DETAIL) then
        raise EAccVoucherDetailExceptionDetailAccountOnly.Create;
  finally
    LTypes.Free;
  end;
end;

// Alan adı + "zorunludur" mesajı
class procedure TAccVoucherDetailService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

class procedure TAccVoucherDetailService.CheckLine(AEntity: TAccVoucherDetail);
begin
  AEntity.Description := Trim(AEntity.Description);
  if AEntity.AccAccountId <= 0 then
    FailRequired(TLangKeys.TAccVoucherDetail.ColAccAccountId, 'Account');
  if (AEntity.Debit < 0) or (AEntity.Credit < 0) or ((AEntity.Debit <> 0) and (AEntity.Credit <> 0)) or
    (AEntity.Debit + AEntity.Credit <= 0) then
    raise EAccVoucherDetailExceptionAmountRule.Create;
end;

procedure TAccVoucherDetailService.ValidateBusinessRules(AEntity: TAccVoucherDetail; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TAccVoucherDetail;
begin
  if AOperation = coDelete then
    Exit;

  if AEntity.AccVoucherId <= 0 then
    FailRequired(TLangKeys.TAccVoucherDetail.ColVoucher, 'Voucher');
  CheckLine(AEntity);
  CheckAccounts([AEntity]);

  if AEntity.LineNo <= 0 then
    AEntity.LineNo := TAccVoucherDetailRepository(FRepo).NextLineNo(AEntity.AccVoucherId);
  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('acc_voucher_id', '=', TValue.From<Int64>(AEntity.AccVoucherId)));
    LFilter.Add(TFilterCriterion.New('line_no', '=', TValue.From<Integer>(AEntity.LineNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TDetailForm.LineNoUnique, 'This line number is already used on the document.'));
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

// Tek kalem yolu: başlığın borç / alacak toplamları kalemlerden yenilenir (belge yolunda bellekte hesaplanır)
procedure TAccVoucherDetailService.DoAdd(AEntity: TAccVoucherDetail);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
  TAccVoucherRepository(FVoucherRepo).RecalculateTotals(AEntity.AccVoucherId);
end;

procedure TAccVoucherDetailService.DoUpdate(AEntity: TAccVoucherDetail);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  TAccVoucherRepository(FVoucherRepo).RecalculateTotals(AEntity.AccVoucherId);
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
    TAccVoucherRepository(FVoucherRepo).RecalculateTotals(LEntity.AccVoucherId);
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
