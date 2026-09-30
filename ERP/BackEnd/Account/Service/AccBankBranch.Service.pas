unit AccBankBranch.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  AccBankBranch.Repository, AccBankBranch, AccBankBranch.Exception;

type
  TAccBankBranchService = class(TCrudService<TAccBankBranch>)
  private
    FRepo: IRepository<TAccBankBranch>;

    procedure DoAdd(AEntity: TAccBankBranch);
    procedure DoUpdate(AEntity: TAccBankBranch);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TAccBankBranch);
    procedure ValidateUnique(AEntity: TAccBankBranch; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TAccBankBranch; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccBankBranch>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccBankBranch; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TAccBankBranch; override;

    procedure Add(AEntity: TAccBankBranch); override;
    procedure Update(AEntity: TAccBankBranch); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccBankBranch; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccBankBranch>; override;
    procedure BusinessInsert(AEntity: TAccBankBranch; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccBankBranch; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccBankBranch; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TAccBankBranchService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccBankBranch, TAccBankBranchRepository>;
  Self.PermissionCode := PERMISSION_ACC_BANK;
end;

destructor TAccBankBranchService.Destroy;
begin
  inherited;
end;

procedure TAccBankBranchService.ValidateRequiredReferences(AEntity: TAccBankBranch);

  procedure Check(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  Check(AEntity.AccBankId, TLangKeys.TAccBankBranch.ColBank, 'Bank');
  Check(AEntity.SysCityId, TLangKeys.TAccBankBranch.ColCity, 'City');
end;

procedure TAccBankBranchService.ValidateUnique(AEntity: TAccBankBranch; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TAccBankBranch;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('acc_bank_id', '=', TValue.From<Int64>(AEntity.AccBankId)));
      LFilter.Add(TFilterCriterion.New('branch_code', '=', TValue.From<Integer>(AEntity.BranchCode)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EAccBankBranchExceptionBranchCodeUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TAccBankBranchService.ValidateBusinessRules(AEntity: TAccBankBranch; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.BranchName := AnsiUpperCase(Trim(AEntity.BranchName));
    ValidateRequiredReferences(AEntity);
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TAccBankBranchService.DoAdd(AEntity: TAccBankBranch);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TAccBankBranchService.DoUpdate(AEntity: TAccBankBranch);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TAccBankBranchService.DoDelete(AId: Int64);
var
  LEntity: TAccBankBranch;
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

function TAccBankBranchService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccBankBranch>;
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

function TAccBankBranchService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccBankBranch;
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

procedure TAccBankBranchService.BusinessInsert(AEntity: TAccBankBranch; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccBankBranchService.BusinessUpdate(AEntity: TAccBankBranch; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccBankBranchService.BusinessDelete(AEntity: TAccBankBranch; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TAccBankBranchService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccBankBranchService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TAccBankBranch>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TAccBankBranchService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TAccBankBranch;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TAccBankBranchService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccBankBranch;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TAccBankBranchService.Add(AEntity: TAccBankBranch);
begin
  DoAdd(AEntity);
end;

procedure TAccBankBranchService.Update(AEntity: TAccBankBranch);
begin
  DoUpdate(AEntity);
end;

procedure TAccBankBranchService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
