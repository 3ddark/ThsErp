unit FinCreditCardTransaction.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  FinCreditCardTransaction.Repository, FinCreditCardTransaction, FinCreditCardTransaction.Exception, FinCreditCard, FinCreditCard.Repository;

type
  TFinCreditCardTransactionService = class(TCrudService<TFinCreditCardTransaction>)
  private
    FRepo: IRepository<TFinCreditCardTransaction>;
    FCardRepo: IRepository<TFinCreditCard>;

    procedure DoAdd(AEntity: TFinCreditCardTransaction);
    procedure DoUpdate(AEntity: TFinCreditCardTransaction);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    procedure Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TFinCreditCardTransaction; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TFinCreditCardTransaction>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TFinCreditCardTransaction; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TFinCreditCardTransaction; override;

    procedure Add(AEntity: TFinCreditCardTransaction); override;
    procedure Update(AEntity: TFinCreditCardTransaction); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinCreditCardTransaction; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinCreditCardTransaction>; override;
    procedure BusinessInsert(AEntity: TFinCreditCardTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TFinCreditCardTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TFinCreditCardTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, FinLookup;

constructor TFinCreditCardTransactionService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TFinCreditCardTransaction, TFinCreditCardTransactionRepository>;
  FCardRepo := Self.UoW.GetRepository<TFinCreditCard, TFinCreditCardRepository>;
  Self.PermissionCode := PERMISSION_FIN_CREDIT_CARD;
end;

destructor TFinCreditCardTransactionService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TFinCreditCardTransactionService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

// Alan adı + mesaj
procedure TFinCreditCardTransactionService.Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(AMsgKey, AMsgDefault));
end;

procedure TFinCreditCardTransactionService.ValidateBusinessRules(AEntity: TFinCreditCardTransaction; AOperation: TCrudOperation);
var
  LCard: TFinCreditCard;
  LBalance: Currency;
begin
  if AOperation = coDelete then
    Exit;

  AEntity.Description := Trim(AEntity.Description);
  if AEntity.FinCreditCardId <= 0 then
    FailRequired(TLangKeys.TFinCreditCardTransaction.ColFinCreditCardId, 'Credit Card');
  if AEntity.TransactionDate <= 0 then
    FailRequired(TLangKeys.TFinCreditCardTransaction.ColTransactionDate, 'Date');
  if not TFinLookup.IsValid(flkCardTxType, AEntity.TransactionType) then
    FailRequired(TLangKeys.TFinCreditCardTransaction.ColTransactionType, 'Transaction Type');
  if AEntity.Amount <= 0 then
    Fail(TLangKeys.TFinCreditCardTransaction.ColAmount, 'Amount', TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero');
  if AEntity.InstallmentCount = 0 then
    AEntity.InstallmentCount := 1;
  if (AEntity.InstallmentCount < 1) or (AEntity.InstallmentCount > 36) then
    raise EFinCreditCardTransactionExceptionInstallmentRange.Create;
  if (AEntity.TransactionType <> FIN_CARD_TX_SPENDING) and (AEntity.InstallmentCount <> 1) then
    raise EFinCreditCardTransactionExceptionInstallmentOnlySpending.Create;

  LCard := FCardRepo.FindById(AEntity.FinCreditCardId, False);
  try
    if not Assigned(LCard) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.FinCreditCardId]));

    if AEntity.TransactionType = FIN_CARD_TX_SPENDING then
    begin
      if not LCard.IsActive then
        raise EFinCreditCardTransactionExceptionCardPassive.Create;
      // Limit 0 = limitsiz
      if LCard.CardLimit > 0 then
      begin
        LBalance := TFinCreditCardTransactionRepository(FRepo).GetCardBalance(AEntity.FinCreditCardId, AEntity.Id);
        if LBalance + AEntity.Amount > LCard.CardLimit then
          raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.LimitExceeded,
            'Card limit exceeded. Available limit: %s'), [FormatFloat('#,##0.00', LCard.CardLimit - LBalance)]));
      end;
    end;
  finally
    LCard.Free;
  end;
end;

procedure TFinCreditCardTransactionService.DoAdd(AEntity: TFinCreditCardTransaction);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TFinCreditCardTransactionService.DoUpdate(AEntity: TFinCreditCardTransaction);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TFinCreditCardTransactionService.DoDelete(AId: Int64);
var
  LEntity: TFinCreditCardTransaction;
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

function TFinCreditCardTransactionService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinCreditCardTransaction>;
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

function TFinCreditCardTransactionService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinCreditCardTransaction;
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

procedure TFinCreditCardTransactionService.BusinessInsert(AEntity: TFinCreditCardTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinCreditCardTransactionService.BusinessUpdate(AEntity: TFinCreditCardTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinCreditCardTransactionService.BusinessDelete(AEntity: TFinCreditCardTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TFinCreditCardTransactionService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TFinCreditCardTransactionService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TFinCreditCardTransaction>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TFinCreditCardTransactionService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TFinCreditCardTransaction;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TFinCreditCardTransactionService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TFinCreditCardTransaction;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TFinCreditCardTransactionService.Add(AEntity: TFinCreditCardTransaction);
begin
  DoAdd(AEntity);
end;

procedure TFinCreditCardTransactionService.Update(AEntity: TFinCreditCardTransaction);
begin
  DoUpdate(AEntity);
end;

procedure TFinCreditCardTransactionService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
