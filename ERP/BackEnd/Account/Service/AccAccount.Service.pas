unit AccAccount.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  AccAccount.Repository, AccAccount, AccAccount.Exception;

type
  TAccAccountService = class(TCrudService<TAccAccount>)
  private
    FRepo: IRepository<TAccAccount>;

    procedure DoAdd(AEntity: TAccAccount);
    procedure DoUpdate(AEntity: TAccAccount);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TAccAccount);
    procedure ValidateUnique(AEntity: TAccAccount; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TAccAccount; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccAccount>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccAccount; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TAccAccount; override;

    procedure Add(AEntity: TAccAccount); override;
    procedure Update(AEntity: TAccAccount); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccAccount; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccAccount>; override;
    procedure BusinessInsert(AEntity: TAccAccount; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccAccount; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccAccount; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TAccAccountService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccAccount, TAccAccountRepository>;
  Self.PermissionCode := PERMISSION_ACC_ACCOUNT;
end;

destructor TAccAccountService.Destroy;
begin
  inherited;
end;

procedure TAccAccountService.ValidateRequiredReferences(AEntity: TAccAccount);

  procedure Check(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  Check(AEntity.AccSetAccountTypeId, TLangKeys.TAccAccount.ColAccountType, 'Account Type');
end;

procedure TAccAccountService.ValidateUnique(AEntity: TAccAccount; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TAccAccount;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('code', '=', TValue.From<string>(AEntity.Code)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EAccAccountExceptionCodeUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TAccAccountService.ValidateBusinessRules(AEntity: TAccAccount; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.Code := AnsiUpperCase(Trim(AEntity.Code));
    AEntity.Name := AnsiUpperCase(Trim(AEntity.Name));
    AEntity.Iban := AnsiUpperCase(Trim(AEntity.Iban));
    AEntity.IbanCurrency := Trim(AEntity.IbanCurrency);
    AEntity.EInvoicePackageName := Trim(AEntity.EInvoicePackageName);
    AEntity.Notes := Trim(AEntity.Notes);
    AEntity.TaxpayerName := Trim(AEntity.TaxpayerName);
    AEntity.TaxpayerName2 := Trim(AEntity.TaxpayerName2);
    AEntity.TaxpayerSurname := Trim(AEntity.TaxpayerSurname);
    AEntity.TaxOffice := Trim(AEntity.TaxOffice);
    AEntity.TaxNo := Trim(AEntity.TaxNo);
    AEntity.NaceCode := Trim(AEntity.NaceCode);
    AEntity.AuthorizedPerson1 := Trim(AEntity.AuthorizedPerson1);
    AEntity.AuthorizedPhone1 := Trim(AEntity.AuthorizedPhone1);
    AEntity.AuthorizedPerson2 := Trim(AEntity.AuthorizedPerson2);
    AEntity.AuthorizedPhone2 := Trim(AEntity.AuthorizedPhone2);
    AEntity.AuthorizedPerson3 := Trim(AEntity.AuthorizedPerson3);
    AEntity.AuthorizedPhone3 := Trim(AEntity.AuthorizedPhone3);
    AEntity.Fax := Trim(AEntity.Fax);
    AEntity.AccountantPhone := Trim(AEntity.AccountantPhone);
    AEntity.AccountantEmail := Trim(AEntity.AccountantEmail);
    AEntity.AccountantAuthorized := Trim(AEntity.AccountantAuthorized);
    ValidateRequiredReferences(AEntity);
    // Hesap kodu yapısı: 120 / 120-001 / 120-001-001
    //   root_code = ilk 3 karakter, sub_code = üç seviyeli kodlarda üst (ara) hesap kodu
    AEntity.RootCode := Copy(AEntity.Code, 1, 3);
    if AEntity.Code.CountChar('-') >= 2 then
      AEntity.SubCode := Copy(AEntity.Code, 1, AEntity.Code.LastIndexOf('-'))
    else
      AEntity.SubCode := '';
    if (AEntity.DiscountRate < 0) or (AEntity.DiscountRate > 100) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TAccAccount.ColDiscountRate, 'Discount Rate') + ': ' +
        Format(TLocalizationManager.Translate(TLangKeys.TValidation.Range, 'Field must be between %s and %s'), ['0', '100']));
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TAccAccountService.DoAdd(AEntity: TAccAccount);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TAccAccountService.DoUpdate(AEntity: TAccAccount);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TAccAccountService.DoDelete(AId: Int64);
var
  LEntity: TAccAccount;
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

function TAccAccountService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccAccount>;
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

function TAccAccountService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccAccount;
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

procedure TAccAccountService.BusinessInsert(AEntity: TAccAccount; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccAccountService.BusinessUpdate(AEntity: TAccAccount; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccAccountService.BusinessDelete(AEntity: TAccAccount; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TAccAccountService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccAccountService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TAccAccount>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TAccAccountService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TAccAccount;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TAccAccountService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccAccount;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TAccAccountService.Add(AEntity: TAccAccount);
begin
  DoAdd(AEntity);
end;

procedure TAccAccountService.Update(AEntity: TAccAccount);
begin
  DoUpdate(AEntity);
end;

procedure TAccAccountService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
