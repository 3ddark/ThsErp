unit FinPosTransaction.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  FinPosTransaction.Repository, FinPosTransaction, FinPosTransaction.Exception, FinPosTerminal, FinPosTerminal.Repository;

type
  TFinPosTransactionService = class(TCrudService<TFinPosTransaction>)
  private
    FRepo: IRepository<TFinPosTransaction>;
    FPosRepo: IRepository<TFinPosTerminal>;

    procedure DoAdd(AEntity: TFinPosTransaction);
    procedure DoUpdate(AEntity: TFinPosTransaction);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    procedure Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TFinPosTransaction; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TFinPosTransaction>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TFinPosTransaction; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TFinPosTransaction; override;

    procedure Add(AEntity: TFinPosTransaction); override;
    procedure Update(AEntity: TFinPosTransaction); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinPosTransaction; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinPosTransaction>; override;
    procedure BusinessInsert(AEntity: TFinPosTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TFinPosTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TFinPosTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, FinLookup;

constructor TFinPosTransactionService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TFinPosTransaction, TFinPosTransactionRepository>;
  FPosRepo := Self.UoW.GetRepository<TFinPosTerminal, TFinPosTerminalRepository>;
  Self.PermissionCode := PERMISSION_FIN_POS_TERMINAL;
end;

destructor TFinPosTransactionService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TFinPosTransactionService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

// Alan adı + mesaj
procedure TFinPosTransactionService.Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(AMsgKey, AMsgDefault));
end;

procedure TFinPosTransactionService.ValidateBusinessRules(AEntity: TFinPosTransaction; AOperation: TCrudOperation);
var
  LPos: TFinPosTerminal;
begin
  if AOperation = coDelete then
    Exit;

  AEntity.CardHolder := Trim(AEntity.CardHolder);
  AEntity.CardLastDigits := Trim(AEntity.CardLastDigits);
  AEntity.Description := Trim(AEntity.Description);

  if AEntity.FinPosTerminalId <= 0 then
    FailRequired(TLangKeys.TFinPosTransaction.ColFinPosTerminalId, 'POS');
  if AEntity.TransactionDate <= 0 then
    FailRequired(TLangKeys.TFinPosTransaction.ColTransactionDate, 'Date');
  if not TFinLookup.IsValid(flkPosTxType, AEntity.TransactionType) then
    FailRequired(TLangKeys.TFinPosTransaction.ColTransactionType, 'Transaction Type');
  if AEntity.AccAccountId <= 0 then
    FailRequired(TLangKeys.TFinPosTransaction.ColAccAccountId, 'Account');
  if AEntity.Amount <= 0 then
    Fail(TLangKeys.TFinPosTransaction.ColAmount, 'Amount', TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero');
  if AEntity.InstallmentCount = 0 then
    AEntity.InstallmentCount := 1;
  if (AEntity.InstallmentCount < 1) or (AEntity.InstallmentCount > 36) then
    raise EFinPosTransactionExceptionInstallmentRange.Create;
  if (AEntity.CommissionRate < 0) or (AEntity.CommissionRate > 100) then
    raise EFinPosTransactionExceptionRateRange.Create;
  if not TFinLookup.IsValidLastDigits(AEntity.CardLastDigits) then
    raise EFinPosTransactionExceptionLastDigitsInvalid.Create;

  LPos := FPosRepo.FindById(AEntity.FinPosTerminalId, False);
  try
    if not Assigned(LPos) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.FinPosTerminalId]));
    if (AOperation = coInsert) and not LPos.IsActive then
      raise EFinPosTransactionExceptionPosPassive.Create;
    // Valör girilmezse işlem tarihi + POS bloke günü
    if AEntity.ValueDate <= 0 then
      AEntity.ValueDate := AEntity.TransactionDate + LPos.BlockedDays;
  finally
    LPos.Free;
  end;

  if AEntity.ValueDate < AEntity.TransactionDate then
    raise EFinPosTransactionExceptionValueDateBefore.Create;

  // Komisyon = tutar x oran / 100 (2 hane), net = tutar - komisyon
  AEntity.CommissionAmount := Round(AEntity.Amount * AEntity.CommissionRate) / 100;
  AEntity.NetAmount := AEntity.Amount - AEntity.CommissionAmount;
end;

procedure TFinPosTransactionService.DoAdd(AEntity: TFinPosTransaction);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TFinPosTransactionService.DoUpdate(AEntity: TFinPosTransaction);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TFinPosTransactionService.DoDelete(AId: Int64);
var
  LEntity: TFinPosTransaction;
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

function TFinPosTransactionService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinPosTransaction>;
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

function TFinPosTransactionService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinPosTransaction;
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

procedure TFinPosTransactionService.BusinessInsert(AEntity: TFinPosTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinPosTransactionService.BusinessUpdate(AEntity: TFinPosTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinPosTransactionService.BusinessDelete(AEntity: TFinPosTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TFinPosTransactionService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TFinPosTransactionService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TFinPosTransaction>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TFinPosTransactionService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TFinPosTransaction;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TFinPosTransactionService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TFinPosTransaction;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TFinPosTransactionService.Add(AEntity: TFinPosTransaction);
begin
  DoAdd(AEntity);
end;

procedure TFinPosTransactionService.Update(AEntity: TFinPosTransaction);
begin
  DoUpdate(AEntity);
end;

procedure TFinPosTransactionService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
