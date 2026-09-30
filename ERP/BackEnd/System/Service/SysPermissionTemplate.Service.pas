unit SysPermissionTemplate.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysPermissionTemplate.Repository, SysPermissionTemplate, SysPermissionTemplate.Exception;

type
  TSysPermissionTemplateService = class(TCrudService<TSysPermissionTemplate>)
  private
    FRepo: IRepository<TSysPermissionTemplate>;

    procedure DoAdd(AEntity: TSysPermissionTemplate);
    procedure DoUpdate(AEntity: TSysPermissionTemplate);
    procedure DoDelete(AId: Int64);

    procedure ValidateUnique(AEntity: TSysPermissionTemplate; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysPermissionTemplate; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysPermissionTemplate>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysPermissionTemplate; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysPermissionTemplate; override;

    procedure Add(AEntity: TSysPermissionTemplate); override;
    procedure Update(AEntity: TSysPermissionTemplate); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysPermissionTemplate; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysPermissionTemplate>; override;
    procedure BusinessInsert(AEntity: TSysPermissionTemplate; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysPermissionTemplate; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysPermissionTemplate; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TSysPermissionTemplateService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysPermissionTemplate, TSysPermissionTemplateRepository>;
  Self.PermissionCode := PERMISSION_SYS_PERMISSION_TEMPLATE;
end;

destructor TSysPermissionTemplateService.Destroy;
begin
  inherited;
end;

procedure TSysPermissionTemplateService.ValidateUnique(AEntity: TSysPermissionTemplate; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TSysPermissionTemplate;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('template_key', '=', TValue.From<string>(AEntity.TemplateKey)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise ESysPermissionTemplateExceptionKeyUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TSysPermissionTemplateService.ValidateBusinessRules(AEntity: TSysPermissionTemplate; AOperation: TCrudOperation);
begin
  ValidateUnique(AEntity, AOperation);
end;

procedure TSysPermissionTemplateService.DoAdd(AEntity: TSysPermissionTemplate);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSysPermissionTemplateService.DoUpdate(AEntity: TSysPermissionTemplate);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TSysPermissionTemplateService.DoDelete(AId: Int64);
var
  LEntity: TSysPermissionTemplate;
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

function TSysPermissionTemplateService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysPermissionTemplate>;
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

function TSysPermissionTemplateService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysPermissionTemplate;
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

procedure TSysPermissionTemplateService.BusinessInsert(AEntity: TSysPermissionTemplate; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysPermissionTemplateService.BusinessUpdate(AEntity: TSysPermissionTemplate; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysPermissionTemplateService.BusinessDelete(AEntity: TSysPermissionTemplate; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSysPermissionTemplateService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysPermissionTemplateService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysPermissionTemplate>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysPermissionTemplateService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysPermissionTemplate;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysPermissionTemplateService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysPermissionTemplate;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysPermissionTemplateService.Add(AEntity: TSysPermissionTemplate);
begin
  DoAdd(AEntity);
end;

procedure TSysPermissionTemplateService.Update(AEntity: TSysPermissionTemplate);
begin
  DoUpdate(AEntity);
end;

procedure TSysPermissionTemplateService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
