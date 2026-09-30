unit SysUserPermissionTemplate.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysUserPermissionTemplate.Repository, SysUserPermissionTemplate, SysUserPermissionTemplate.Exception;

type
  TSysUserPermissionTemplateService = class(TCrudService<TSysUserPermissionTemplate>)
  private
    FRepo: IRepository<TSysUserPermissionTemplate>;

    procedure DoAdd(AEntity: TSysUserPermissionTemplate);
    procedure DoUpdate(AEntity: TSysUserPermissionTemplate);
    procedure DoDelete(AId: Int64);

    procedure ValidateUnique(AEntity: TSysUserPermissionTemplate; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysUserPermissionTemplate; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysUserPermissionTemplate>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysUserPermissionTemplate; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysUserPermissionTemplate; override;

    procedure Add(AEntity: TSysUserPermissionTemplate); override;
    procedure Update(AEntity: TSysUserPermissionTemplate); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysUserPermissionTemplate; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysUserPermissionTemplate>; override;
    procedure BusinessInsert(AEntity: TSysUserPermissionTemplate; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysUserPermissionTemplate; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysUserPermissionTemplate; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TSysUserPermissionTemplateService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysUserPermissionTemplate, TSysUserPermissionTemplateRepository>;
  Self.PermissionCode := PERMISSION_SYS_USER_PERMISSION_TEMPLATE;
end;

destructor TSysUserPermissionTemplateService.Destroy;
begin
  inherited;
end;

procedure TSysUserPermissionTemplateService.ValidateUnique(AEntity: TSysUserPermissionTemplate; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TSysUserPermissionTemplate;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('sys_user_id', '=', TValue.From<Int64>(AEntity.SysUserId)));
      LFilter.Add(TFilterCriterion.New('sys_permission_template_id', '=', TValue.From<Int64>(AEntity.SysPermissionTemplateId)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise ESysUserPermissionTemplateExceptionUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TSysUserPermissionTemplateService.ValidateBusinessRules(AEntity: TSysUserPermissionTemplate; AOperation: TCrudOperation);
begin
  ValidateUnique(AEntity, AOperation);
end;

procedure TSysUserPermissionTemplateService.DoAdd(AEntity: TSysUserPermissionTemplate);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSysUserPermissionTemplateService.DoUpdate(AEntity: TSysUserPermissionTemplate);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TSysUserPermissionTemplateService.DoDelete(AId: Int64);
var
  LEntity: TSysUserPermissionTemplate;
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

function TSysUserPermissionTemplateService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysUserPermissionTemplate>;
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

function TSysUserPermissionTemplateService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysUserPermissionTemplate;
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

procedure TSysUserPermissionTemplateService.BusinessInsert(AEntity: TSysUserPermissionTemplate; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysUserPermissionTemplateService.BusinessUpdate(AEntity: TSysUserPermissionTemplate; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysUserPermissionTemplateService.BusinessDelete(AEntity: TSysUserPermissionTemplate; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSysUserPermissionTemplateService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysUserPermissionTemplateService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysUserPermissionTemplate>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysUserPermissionTemplateService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysUserPermissionTemplate;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysUserPermissionTemplateService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysUserPermissionTemplate;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysUserPermissionTemplateService.Add(AEntity: TSysUserPermissionTemplate);
begin
  DoAdd(AEntity);
end;

procedure TSysUserPermissionTemplateService.Update(AEntity: TSysUserPermissionTemplate);
begin
  DoUpdate(AEntity);
end;

procedure TSysUserPermissionTemplateService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
