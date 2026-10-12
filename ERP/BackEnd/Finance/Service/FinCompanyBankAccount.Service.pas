unit FinCompanyBankAccount.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  FinCompanyBankAccount.Repository, FinCompanyBankAccount, FinCompanyBankAccount.Exception;

type
  TFinCompanyBankAccountService = class(TCrudService<TFinCompanyBankAccount>)
  private
    FRepo: IRepository<TFinCompanyBankAccount>;

    procedure DoAdd(AEntity: TFinCompanyBankAccount);
    procedure DoUpdate(AEntity: TFinCompanyBankAccount);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TFinCompanyBankAccount; AOperation: TCrudOperation); override;
    // Çek / senet / çıktı altında basılacak hesap satırları (aktif, ilgili bayrağı açık, sıraya göre)
    function GetPrintLines(AUsage: SmallInt): TArray<string>;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TFinCompanyBankAccount>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TFinCompanyBankAccount; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TFinCompanyBankAccount; override;

    procedure Add(AEntity: TFinCompanyBankAccount); override;
    procedure Update(AEntity: TFinCompanyBankAccount); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinCompanyBankAccount; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinCompanyBankAccount>; override;
    procedure BusinessInsert(AEntity: TFinCompanyBankAccount; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TFinCompanyBankAccount; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TFinCompanyBankAccount; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, FinLookup;

constructor TFinCompanyBankAccountService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TFinCompanyBankAccount, TFinCompanyBankAccountRepository>;
  Self.PermissionCode := PERMISSION_FIN_COMPANY_BANK_ACCOUNT;
end;

destructor TFinCompanyBankAccountService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TFinCompanyBankAccountService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


function TFinCompanyBankAccountService.GetPrintLines(AUsage: SmallInt): TArray<string>;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, False);
  Result := TFinCompanyBankAccountRepository(FRepo).GetPrintLines(AUsage);
end;

procedure TFinCompanyBankAccountService.ValidateBusinessRules(AEntity: TFinCompanyBankAccount; AOperation: TCrudOperation);
var
  LRepo: TFinCompanyBankAccountRepository;
  LOld: TFinCompanyBankAccount;
  LFilter: TFilterCriteria;
  LModel: TFinCompanyBankAccount;
begin
  LRepo := TFinCompanyBankAccountRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.UsageCount(AEntity.Id) > 0 then
      raise EFinCompanyBankAccountExceptionInUse.Create;
    Exit;
  end;

  AEntity.BranchCode := AnsiUpperCase(Trim(AEntity.BranchCode));
  AEntity.BranchName := Trim(AEntity.BranchName);
  AEntity.AccountNo := Trim(AEntity.AccountNo);
  AEntity.Iban := TFinLookup.NormalizeIban(AEntity.Iban);
  AEntity.Currency := Trim(AEntity.Currency);
  AEntity.AccountHolder := Trim(AEntity.AccountHolder);
  AEntity.Description := Trim(AEntity.Description);

  if AEntity.AccBankId <= 0 then
    FailRequired(TLangKeys.TFinCompanyBankAccount.ColAccBankId, 'Bank');
  if AEntity.Iban = '' then
    FailRequired(TLangKeys.TFinCompanyBankAccount.ColIban, 'IBAN');
  if not TFinLookup.IsValidIban(AEntity.Iban) then
    raise EFinCompanyBankAccountExceptionIbanInvalid.Create;
  if (AEntity.SortOrder < 0) or (AEntity.SortOrder > 999) then
    raise EFinCompanyBankAccountExceptionSortRange.Create;
  if AEntity.Currency = '' then
    AEntity.Currency := LRepo.GetDefaultCurrency;

  if AOperation = coUpdate then
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if Assigned(LOld) and (LOld.Currency <> AEntity.Currency) and (LRepo.UsageCount(AEntity.Id) > 0) then
        raise EFinCompanyBankAccountExceptionCurrencyLocked.Create;
    finally
      LOld.Free;
    end;
  end;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('iban', '=', TValue.From<string>(AEntity.Iban)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EFinCompanyBankAccountExceptionIbanUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TFinCompanyBankAccountService.DoAdd(AEntity: TFinCompanyBankAccount);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TFinCompanyBankAccountService.DoUpdate(AEntity: TFinCompanyBankAccount);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TFinCompanyBankAccountService.DoDelete(AId: Int64);
var
  LEntity: TFinCompanyBankAccount;
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

function TFinCompanyBankAccountService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinCompanyBankAccount>;
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

function TFinCompanyBankAccountService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinCompanyBankAccount;
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

procedure TFinCompanyBankAccountService.BusinessInsert(AEntity: TFinCompanyBankAccount; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinCompanyBankAccountService.BusinessUpdate(AEntity: TFinCompanyBankAccount; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinCompanyBankAccountService.BusinessDelete(AEntity: TFinCompanyBankAccount; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TFinCompanyBankAccountService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TFinCompanyBankAccountService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TFinCompanyBankAccount>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TFinCompanyBankAccountService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TFinCompanyBankAccount;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TFinCompanyBankAccountService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TFinCompanyBankAccount;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TFinCompanyBankAccountService.Add(AEntity: TFinCompanyBankAccount);
begin
  DoAdd(AEntity);
end;

procedure TFinCompanyBankAccountService.Update(AEntity: TFinCompanyBankAccount);
begin
  DoUpdate(AEntity);
end;

procedure TFinCompanyBankAccountService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
