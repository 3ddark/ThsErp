unit FinCreditCard.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  FinCreditCard.Repository, FinCreditCard, FinCreditCard.Exception;

type
  TFinCreditCardService = class(TCrudService<TFinCreditCard>)
  private
    FRepo: IRepository<TFinCreditCard>;

    procedure DoAdd(AEntity: TFinCreditCard);
    procedure DoUpdate(AEntity: TFinCreditCard);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    procedure Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TFinCreditCard; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TFinCreditCard>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TFinCreditCard; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TFinCreditCard; override;

    procedure Add(AEntity: TFinCreditCard); override;
    procedure Update(AEntity: TFinCreditCard); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinCreditCard; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinCreditCard>; override;
    procedure BusinessInsert(AEntity: TFinCreditCard; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TFinCreditCard; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TFinCreditCard; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, FinLookup;

constructor TFinCreditCardService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TFinCreditCard, TFinCreditCardRepository>;
  Self.PermissionCode := PERMISSION_FIN_CREDIT_CARD;
end;

destructor TFinCreditCardService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TFinCreditCardService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

// Alan adı + mesaj
procedure TFinCreditCardService.Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(AMsgKey, AMsgDefault));
end;

procedure TFinCreditCardService.ValidateBusinessRules(AEntity: TFinCreditCard; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TFinCreditCard;
begin
  if AOperation = coDelete then
  begin
    if TFinCreditCardRepository(FRepo).TransactionCount(AEntity.Id) > 0 then
      raise EFinCreditCardExceptionHasTransactions.Create;
    Exit;
  end;

  AEntity.CardName := Trim(AEntity.CardName);
  AEntity.CardHolder := Trim(AEntity.CardHolder);
  AEntity.CardLastDigits := Trim(AEntity.CardLastDigits);
  AEntity.Currency := Trim(AEntity.Currency);
  AEntity.AccAccountCode := Trim(AEntity.AccAccountCode);

  if AEntity.AccBankId <= 0 then
    FailRequired(TLangKeys.TFinCreditCard.ColAccBankId, 'Bank');
  if not TFinLookup.IsValidLastDigits(AEntity.CardLastDigits) then
    raise EFinCreditCardExceptionLastDigitsInvalid.Create;
  if (AEntity.StatementDay < 0) or (AEntity.StatementDay > 31) or (AEntity.PaymentDay < 0) or (AEntity.PaymentDay > 31) then
    raise EFinCreditCardExceptionDayInvalid.Create;
  if AEntity.CardLimit < 0 then
    Fail(TLangKeys.TFinCreditCard.ColCardLimit, 'Card Limit', TLangKeys.TValidation.NegativeValueNotAllowed, 'Negative values are not allowed');
  if AEntity.Currency = '' then
    AEntity.Currency := TFinCreditCardRepository(FRepo).GetDefaultCurrency;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('card_name', '=', TValue.From<string>(AEntity.CardName)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EFinCreditCardExceptionNameUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TFinCreditCardService.DoAdd(AEntity: TFinCreditCard);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TFinCreditCardService.DoUpdate(AEntity: TFinCreditCard);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TFinCreditCardService.DoDelete(AId: Int64);
var
  LEntity: TFinCreditCard;
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

function TFinCreditCardService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinCreditCard>;
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

function TFinCreditCardService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinCreditCard;
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

procedure TFinCreditCardService.BusinessInsert(AEntity: TFinCreditCard; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinCreditCardService.BusinessUpdate(AEntity: TFinCreditCard; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinCreditCardService.BusinessDelete(AEntity: TFinCreditCard; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TFinCreditCardService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TFinCreditCardService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TFinCreditCard>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TFinCreditCardService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TFinCreditCard;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TFinCreditCardService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TFinCreditCard;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TFinCreditCardService.Add(AEntity: TFinCreditCard);
begin
  DoAdd(AEntity);
end;

procedure TFinCreditCardService.Update(AEntity: TFinCreditCard);
begin
  DoUpdate(AEntity);
end;

procedure TFinCreditCardService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
