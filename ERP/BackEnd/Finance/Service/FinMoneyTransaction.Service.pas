unit FinMoneyTransaction.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  FinMoneyTransaction.Repository, FinMoneyTransaction, FinMoneyTransaction.Exception, FinMoneyAccount, FinMoneyAccount.Repository;

type
  TFinMoneyTransactionService = class(TCrudService<TFinMoneyTransaction>)
  private
    FRepo: IRepository<TFinMoneyTransaction>;
    FAccRepo: IRepository<TFinMoneyAccount>;

    procedure DoAdd(AEntity: TFinMoneyTransaction);
    procedure DoUpdate(AEntity: TFinMoneyTransaction);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    procedure Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
    procedure CheckCashBalances(const AAccountIds: array of Int64);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TFinMoneyTransaction; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TFinMoneyTransaction>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TFinMoneyTransaction; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TFinMoneyTransaction; override;

    procedure Add(AEntity: TFinMoneyTransaction); override;
    procedure Update(AEntity: TFinMoneyTransaction); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinMoneyTransaction; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinMoneyTransaction>; override;
    procedure BusinessInsert(AEntity: TFinMoneyTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TFinMoneyTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TFinMoneyTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, FinLookup;

constructor TFinMoneyTransactionService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TFinMoneyTransaction, TFinMoneyTransactionRepository>;
  FAccRepo := Self.UoW.GetRepository<TFinMoneyAccount, TFinMoneyAccountRepository>;
  Self.PermissionCode := PERMISSION_FIN_MONEY_TRANSACTION;
end;

destructor TFinMoneyTransactionService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TFinMoneyTransactionService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

// Alan adı + mesaj
procedure TFinMoneyTransactionService.Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(AMsgKey, AMsgDefault));
end;

// Kasa (nakit) hesapları eksi bakiyeye düşemez; yazma sonrası, aynı transaction içinde kontrol edilir
procedure TFinMoneyTransactionService.CheckCashBalances(const AAccountIds: array of Int64);
var
  LId: Int64;
  LName: string;
  LBalance: Currency;
begin
  for LId in AAccountIds do
    if (LId > 0) and TFinMoneyTransactionRepository(FRepo).NegativeCashBalance(LId, LName, LBalance) then
      raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.CashInsufficient,
        'Insufficient cash balance in "%s" (balance would be %s).'), [LName, FormatFloat('#,##0.00', LBalance)]));
end;

procedure TFinMoneyTransactionService.ValidateBusinessRules(AEntity: TFinMoneyTransaction; AOperation: TCrudOperation);
var
  LAcc, LTarget: TFinMoneyAccount;
begin
  if AOperation = coDelete then
    Exit;

  AEntity.DocumentNo := AnsiUpperCase(Trim(AEntity.DocumentNo));
  AEntity.CounterpartyName := Trim(AEntity.CounterpartyName);
  AEntity.CounterpartyIban := TFinLookup.NormalizeIban(AEntity.CounterpartyIban);
  AEntity.Description := Trim(AEntity.Description);

  if AEntity.FinMoneyAccountId <= 0 then
    FailRequired(TLangKeys.TFinMoneyTransaction.ColFinMoneyAccountId, 'Cash / Bank Account');
  if AEntity.TransactionDate <= 0 then
    FailRequired(TLangKeys.TFinMoneyTransaction.ColTransactionDate, 'Date');
  if not TFinLookup.IsValid(flkMoneyTxType, AEntity.TransactionType) then
    FailRequired(TLangKeys.TFinMoneyTransaction.ColTransactionType, 'Transaction Type');
  if (AEntity.TransferMethod <> 0) and not TFinLookup.IsValid(flkTransferMethod, AEntity.TransferMethod) then
    FailRequired(TLangKeys.TFinMoneyTransaction.ColTransferMethod, 'Transfer Method');
  if AEntity.Amount <= 0 then
    Fail(TLangKeys.TFinMoneyTransaction.ColAmount, 'Amount', TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero');
  if (AEntity.TransactionType in [FIN_MONEY_TX_COLLECTION, FIN_MONEY_TX_PAYMENT]) and (AEntity.AccAccountId <= 0) then
    FailRequired(TLangKeys.TFinMoneyTransaction.ColAccAccountId, 'Account');
  if not TFinLookup.IsValidIban(AEntity.CounterpartyIban) then
    raise EFinMoneyTransactionExceptionIbanInvalid.Create;

  LAcc := FAccRepo.FindById(AEntity.FinMoneyAccountId, False);
  try
    if not Assigned(LAcc) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.FinMoneyAccountId]));
    if (AOperation = coInsert) and not LAcc.IsActive then
      raise EFinMoneyTransactionExceptionAccountPassive.Create;

    if AEntity.TransactionType = FIN_MONEY_TX_TRANSFER then
    begin
      if AEntity.TargetFinMoneyAccountId <= 0 then
        FailRequired(TLangKeys.TFinMoneyTransaction.ColTargetFinMoneyAccountId, 'Target Account (Transfer)');
      if AEntity.TargetFinMoneyAccountId = AEntity.FinMoneyAccountId then
        raise EFinMoneyTransactionExceptionSameAccount.Create;
      LTarget := FAccRepo.FindById(AEntity.TargetFinMoneyAccountId, False);
      try
        if not Assigned(LTarget) then
          raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.TargetFinMoneyAccountId]));
        if LTarget.Currency <> LAcc.Currency then
          raise EFinMoneyTransactionExceptionCurrencyMismatch.Create;
        if (AOperation = coInsert) and not LTarget.IsActive then
          raise EFinMoneyTransactionExceptionAccountPassive.Create;
      finally
        LTarget.Free;
      end;
    end
    else
      AEntity.TargetFinMoneyAccountId := 0;
  finally
    LAcc.Free;
  end;
end;

procedure TFinMoneyTransactionService.DoAdd(AEntity: TFinMoneyTransaction);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
  CheckCashBalances([AEntity.FinMoneyAccountId, AEntity.TargetFinMoneyAccountId]);
end;

procedure TFinMoneyTransactionService.DoUpdate(AEntity: TFinMoneyTransaction);
var
  LOld: TFinMoneyTransaction;
  LOldSource, LOldTarget: Int64;
begin
  LOld := FRepo.FindById(AEntity.Id, False);
  try
    if not Assigned(LOld) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
    LOldSource := LOld.FinMoneyAccountId;
    LOldTarget := LOld.TargetFinMoneyAccountId;
  finally
    LOld.Free;
  end;

  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  CheckCashBalances([AEntity.FinMoneyAccountId, AEntity.TargetFinMoneyAccountId, LOldSource, LOldTarget]);
end;

procedure TFinMoneyTransactionService.DoDelete(AId: Int64);
var
  LEntity: TFinMoneyTransaction;
  LSource, LTarget: Int64;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    LSource := LEntity.FinMoneyAccountId;
    LTarget := LEntity.TargetFinMoneyAccountId;
    FRepo.Delete(LEntity);
    CheckCashBalances([LSource, LTarget]);
  finally
    LEntity.Free;
  end;
end;

function TFinMoneyTransactionService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinMoneyTransaction>;
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

function TFinMoneyTransactionService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinMoneyTransaction;
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

procedure TFinMoneyTransactionService.BusinessInsert(AEntity: TFinMoneyTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinMoneyTransactionService.BusinessUpdate(AEntity: TFinMoneyTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinMoneyTransactionService.BusinessDelete(AEntity: TFinMoneyTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TFinMoneyTransactionService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TFinMoneyTransactionService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TFinMoneyTransaction>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TFinMoneyTransactionService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TFinMoneyTransaction;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TFinMoneyTransactionService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TFinMoneyTransaction;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TFinMoneyTransactionService.Add(AEntity: TFinMoneyTransaction);
begin
  DoAdd(AEntity);
end;

procedure TFinMoneyTransactionService.Update(AEntity: TFinMoneyTransaction);
begin
  DoUpdate(AEntity);
end;

procedure TFinMoneyTransactionService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
