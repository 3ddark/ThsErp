unit FinMoneyAccount.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  FinMoneyAccount.Repository, FinMoneyAccount, FinMoneyAccount.Exception;

type
  TFinMoneyAccountService = class(TCrudService<TFinMoneyAccount>)
  private
    FRepo: IRepository<TFinMoneyAccount>;

    procedure DoAdd(AEntity: TFinMoneyAccount);
    procedure DoUpdate(AEntity: TFinMoneyAccount);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    procedure ValidateUnique(AEntity: TFinMoneyAccount; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TFinMoneyAccount; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TFinMoneyAccount>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TFinMoneyAccount; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TFinMoneyAccount; override;

    procedure Add(AEntity: TFinMoneyAccount); override;
    procedure Update(AEntity: TFinMoneyAccount); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinMoneyAccount; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinMoneyAccount>; override;
    procedure BusinessInsert(AEntity: TFinMoneyAccount; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TFinMoneyAccount; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TFinMoneyAccount; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, FinLookup;

constructor TFinMoneyAccountService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TFinMoneyAccount, TFinMoneyAccountRepository>;
  Self.PermissionCode := PERMISSION_FIN_MONEY_ACCOUNT;
end;

destructor TFinMoneyAccountService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TFinMoneyAccountService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TFinMoneyAccountService.ValidateUnique(AEntity: TFinMoneyAccount; AOperation: TCrudOperation);

  procedure CheckOne(const AColumn, AValue: string; AExceptionClass: TClass);
  var
    LFilter: TFilterCriteria;
    LModel: TFinMoneyAccount;
  begin
    if AValue = '' then
      Exit;
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New(AColumn, '=', TValue.From<string>(AValue)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
        begin
          if AExceptionClass = EFinMoneyAccountExceptionCodeUnique then
            raise EFinMoneyAccountExceptionCodeUnique.Create
          else if AExceptionClass = EFinMoneyAccountExceptionNameUnique then
            raise EFinMoneyAccountExceptionNameUnique.Create
          else
            raise EFinMoneyAccountExceptionIbanUnique.Create;
        end;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;

begin
  CheckOne('code', AEntity.Code, EFinMoneyAccountExceptionCodeUnique);
  CheckOne('name', AEntity.Name, EFinMoneyAccountExceptionNameUnique);
  CheckOne('iban', AEntity.Iban, EFinMoneyAccountExceptionIbanUnique);
end;

procedure TFinMoneyAccountService.ValidateBusinessRules(AEntity: TFinMoneyAccount; AOperation: TCrudOperation);
var
  LRepo: TFinMoneyAccountRepository;
  LOld: TFinMoneyAccount;
begin
  LRepo := TFinMoneyAccountRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.TransactionCount(AEntity.Id) > 0 then
      raise EFinMoneyAccountExceptionHasTransactions.Create;
    Exit;
  end;

  AEntity.Code := AnsiUpperCase(Trim(AEntity.Code));
  AEntity.Name := Trim(AEntity.Name);
  AEntity.AccountNo := Trim(AEntity.AccountNo);
  AEntity.Iban := TFinLookup.NormalizeIban(AEntity.Iban);
  AEntity.Currency := Trim(AEntity.Currency);
  AEntity.AccAccountCode := Trim(AEntity.AccAccountCode);

  if not TFinLookup.IsValid(flkMoneyAccountKind, AEntity.AccountKind) then
    FailRequired(TLangKeys.TFinMoneyAccount.ColAccountKind, 'Account Kind');

  if AEntity.AccountKind = FIN_MONEY_CASH then
  begin
    // Kasa: banka bilgileri tutulmaz
    AEntity.AccBankId := 0;
    AEntity.AccBankBranchId := 0;
    AEntity.AccountNo := '';
    AEntity.Iban := '';
  end
  else
  begin
    if AEntity.AccBankId <= 0 then
      raise EFinMoneyAccountExceptionBankRequired.Create;
    if (AEntity.AccBankBranchId > 0) and not LRepo.BranchBelongsToBank(AEntity.AccBankBranchId, AEntity.AccBankId) then
      raise EFinMoneyAccountExceptionBranchBank.Create;
    if not TFinLookup.IsValidIban(AEntity.Iban) then
      raise EFinMoneyAccountExceptionIbanInvalid.Create;
  end;

  if AEntity.Currency = '' then
    AEntity.Currency := LRepo.GetDefaultCurrency;

  if AOperation = coUpdate then
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if Assigned(LOld) and (LOld.Currency <> AEntity.Currency) and (LRepo.TransactionCount(AEntity.Id) > 0) then
        raise EFinMoneyAccountExceptionCurrencyLocked.Create;
    finally
      LOld.Free;
    end;
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TFinMoneyAccountService.DoAdd(AEntity: TFinMoneyAccount);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TFinMoneyAccountService.DoUpdate(AEntity: TFinMoneyAccount);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TFinMoneyAccountService.DoDelete(AId: Int64);
var
  LEntity: TFinMoneyAccount;
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

function TFinMoneyAccountService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinMoneyAccount>;
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

function TFinMoneyAccountService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinMoneyAccount;
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

procedure TFinMoneyAccountService.BusinessInsert(AEntity: TFinMoneyAccount; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinMoneyAccountService.BusinessUpdate(AEntity: TFinMoneyAccount; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinMoneyAccountService.BusinessDelete(AEntity: TFinMoneyAccount; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TFinMoneyAccountService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TFinMoneyAccountService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TFinMoneyAccount>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TFinMoneyAccountService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TFinMoneyAccount;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TFinMoneyAccountService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TFinMoneyAccount;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TFinMoneyAccountService.Add(AEntity: TFinMoneyAccount);
begin
  DoAdd(AEntity);
end;

procedure TFinMoneyAccountService.Update(AEntity: TFinMoneyAccount);
begin
  DoUpdate(AEntity);
end;

procedure TFinMoneyAccountService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
