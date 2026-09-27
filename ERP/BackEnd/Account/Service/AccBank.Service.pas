unit AccBank.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  AccBank.Repository, AccBank, AccBank.Exception;

type
  TAccBankService = class(TCrudService<TAccBank>)
  private
    FRepo: IRepository<TAccBank>;

    procedure DoAdd(AEntity: TAccBank);
    procedure DoUpdate(AEntity: TAccBank);
    procedure DoDelete(AId: Int64);

    procedure ValidateInsert(AEntity: TAccBank);
    procedure ValidateUpdate(AEntity: TAccBank);
    procedure ValidateDelete(AEntity: TAccBank);
    procedure ValidateBankNameUnique(AEntity: TAccBank; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TAccBank; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccBank>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccBank; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TAccBank; override;

    procedure Add(AEntity: TAccBank); override;
    procedure Update(AEntity: TAccBank); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccBank; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccBank>; override;
    procedure BusinessInsert(AEntity: TAccBank; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccBank; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccBank; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TAccBankService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccBank, TAccBankRepository>;
  Self.PermissionCode := PERMISSION_ACC_BANK;
end;

destructor TAccBankService.Destroy;
begin
  inherited;
end;

procedure TAccBankService.ValidateInsert(AEntity: TAccBank);
begin
  ValidateBankNameUnique(AEntity, coInsert);
end;

procedure TAccBankService.ValidateUpdate(AEntity: TAccBank);
begin
  ValidateBankNameUnique(AEntity, coUpdate);
end;

procedure TAccBankService.ValidateDelete(AEntity: TAccBank);
begin

end;

procedure TAccBankService.ValidateBankNameUnique(AEntity: TAccBank; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TAccBank;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('bank_name', '=', TValue.From<string>(AEntity.BankName)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EAccBankExceptionBankNameUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TAccBankService.DoAdd(AEntity: TAccBank);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TAccBankService.DoUpdate(AEntity: TAccBank);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TAccBankService.DoDelete(AId: Int64);
var
  LEntity: TAccBank;
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

function TAccBankService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccBank>;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.Find(AFilter, ALock);
  except
    if Self.UoW.InTransaction then
    begin
      Self.UoW.Rollback;
    end;
    raise;
  end;
end;

function TAccBankService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccBank;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.FindById(AId, ALock);
  except
    if Self.UoW.InTransaction then
    begin
      Self.UoW.Rollback;
    end;
    raise;
  end;
end;

procedure TAccBankService.BusinessInsert(AEntity: TAccBank; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoAdd(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Uow.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

procedure TAccBankService.BusinessUpdate(AEntity: TAccBank; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoUpdate(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

procedure TAccBankService.BusinessDelete(AEntity: TAccBank; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptDelete, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoDelete(AEntity.Id);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

function TAccBankService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccBankService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TAccBank>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TAccBankService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TAccBank;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TAccBankService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccBank;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TAccBankService.Add(AEntity: TAccBank);
begin
  DoAdd(AEntity)
end;

procedure TAccBankService.Update(AEntity: TAccBank);
begin
  DoUpdate(AEntity)
end;

procedure TAccBankService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

procedure TAccBankService.ValidateBusinessRules(AEntity: TAccBank; AOperation: TCrudOperation);
begin
  case AOperation of
    coInsert: ValidateInsert(AEntity);
    coUpdate: ValidateUpdate(AEntity);
    coDelete: ValidateDelete(AEntity);
  end;
end;

end.
