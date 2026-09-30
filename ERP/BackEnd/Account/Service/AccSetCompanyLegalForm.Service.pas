unit AccSetCompanyLegalForm.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  AccSetCompanyLegalForm.Repository, AccSetCompanyLegalForm, AccSetCompanyLegalForm.Exception;

type
  TAccSetCompanyLegalFormService = class(TCrudService<TAccSetCompanyLegalForm>)
  private
    FRepo: IRepository<TAccSetCompanyLegalForm>;

    procedure DoAdd(AEntity: TAccSetCompanyLegalForm);
    procedure DoUpdate(AEntity: TAccSetCompanyLegalForm);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TAccSetCompanyLegalForm);
    procedure ValidateUnique(AEntity: TAccSetCompanyLegalForm; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TAccSetCompanyLegalForm; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccSetCompanyLegalForm>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccSetCompanyLegalForm; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TAccSetCompanyLegalForm; override;

    procedure Add(AEntity: TAccSetCompanyLegalForm); override;
    procedure Update(AEntity: TAccSetCompanyLegalForm); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccSetCompanyLegalForm; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccSetCompanyLegalForm>; override;
    procedure BusinessInsert(AEntity: TAccSetCompanyLegalForm; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccSetCompanyLegalForm; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccSetCompanyLegalForm; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TAccSetCompanyLegalFormService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccSetCompanyLegalForm, TAccSetCompanyLegalFormRepository>;
  Self.PermissionCode := PERMISSION_ACC_COMPANY_LEGAL_FORM;
end;

destructor TAccSetCompanyLegalFormService.Destroy;
begin
  inherited;
end;

procedure TAccSetCompanyLegalFormService.ValidateRequiredReferences(AEntity: TAccSetCompanyLegalForm);

  procedure Check(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  Check(AEntity.AccSetOwnershipTypeId, TLangKeys.TAccSetCompanyLegalForm.ColOwnershipType, 'Ownership Type');
end;

procedure TAccSetCompanyLegalFormService.ValidateUnique(AEntity: TAccSetCompanyLegalForm; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TAccSetCompanyLegalForm;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('legal_form_key', '=', TValue.From<string>(AEntity.LegalFormKey)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EAccSetCompanyLegalFormExceptionLegalFormKeyUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TAccSetCompanyLegalFormService.ValidateBusinessRules(AEntity: TAccSetCompanyLegalForm; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.LegalFormKey := AnsiUpperCase(Trim(AEntity.LegalFormKey));
    ValidateRequiredReferences(AEntity);
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TAccSetCompanyLegalFormService.DoAdd(AEntity: TAccSetCompanyLegalForm);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TAccSetCompanyLegalFormService.DoUpdate(AEntity: TAccSetCompanyLegalForm);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TAccSetCompanyLegalFormService.DoDelete(AId: Int64);
var
  LEntity: TAccSetCompanyLegalForm;
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

function TAccSetCompanyLegalFormService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccSetCompanyLegalForm>;
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

function TAccSetCompanyLegalFormService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccSetCompanyLegalForm;
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

procedure TAccSetCompanyLegalFormService.BusinessInsert(AEntity: TAccSetCompanyLegalForm; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccSetCompanyLegalFormService.BusinessUpdate(AEntity: TAccSetCompanyLegalForm; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccSetCompanyLegalFormService.BusinessDelete(AEntity: TAccSetCompanyLegalForm; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TAccSetCompanyLegalFormService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccSetCompanyLegalFormService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TAccSetCompanyLegalForm>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TAccSetCompanyLegalFormService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TAccSetCompanyLegalForm;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TAccSetCompanyLegalFormService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccSetCompanyLegalForm;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TAccSetCompanyLegalFormService.Add(AEntity: TAccSetCompanyLegalForm);
begin
  DoAdd(AEntity);
end;

procedure TAccSetCompanyLegalFormService.Update(AEntity: TAccSetCompanyLegalForm);
begin
  DoUpdate(AEntity);
end;

procedure TAccSetCompanyLegalFormService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
