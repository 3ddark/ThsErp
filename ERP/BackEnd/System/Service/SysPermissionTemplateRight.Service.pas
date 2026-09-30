unit SysPermissionTemplateRight.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysPermissionTemplateRight.Repository, SysPermissionTemplateRight, SysPermissionTemplateRight.Exception;

type
  TSysPermissionTemplateRightService = class(TCrudService<TSysPermissionTemplateRight>)
  private
    FRepo: IRepository<TSysPermissionTemplateRight>;

    procedure DoAdd(AEntity: TSysPermissionTemplateRight);
    procedure DoUpdate(AEntity: TSysPermissionTemplateRight);
    procedure DoDelete(AId: Int64);

    procedure ValidateUnique(AEntity: TSysPermissionTemplateRight; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysPermissionTemplateRight; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysPermissionTemplateRight>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysPermissionTemplateRight; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysPermissionTemplateRight; override;

    procedure Add(AEntity: TSysPermissionTemplateRight); override;
    procedure Update(AEntity: TSysPermissionTemplateRight); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysPermissionTemplateRight; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysPermissionTemplateRight>; override;
    procedure BusinessInsert(AEntity: TSysPermissionTemplateRight; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysPermissionTemplateRight; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysPermissionTemplateRight; AWithBegin, AWithCommit, APermissionControl: Boolean); override;

    /// <summary>Şablonda olmayan tüm yetkileri kapalı bayraklarla ekler. Eklenen satır sayısını döner.</summary>
    function AddMissingPermissions(ATemplateId: Int64): Integer;
    /// <summary>Şablondaki tüm yetkileri topluca açar/kapatır.</summary>
    procedure SetAllFlags(ATemplateId: Int64; AValue: Boolean);
  end;

implementation

uses
  SysPermission.Service;

constructor TSysPermissionTemplateRightService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysPermissionTemplateRight, TSysPermissionTemplateRightRepository>;
  Self.PermissionCode := PERMISSION_SYS_PERMISSION_TEMPLATE;
end;

destructor TSysPermissionTemplateRightService.Destroy;
begin
  inherited;
end;

procedure TSysPermissionTemplateRightService.ValidateUnique(AEntity: TSysPermissionTemplateRight; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TSysPermissionTemplateRight;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('sys_permission_template_id', '=', TValue.From<Int64>(AEntity.SysPermissionTemplateId)));
      LFilter.Add(TFilterCriterion.New('sys_permission_id', '=', TValue.From<Int64>(AEntity.SysPermissionId)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise ESysPermissionTemplateRightExceptionUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TSysPermissionTemplateRightService.ValidateBusinessRules(AEntity: TSysPermissionTemplateRight; AOperation: TCrudOperation);
begin
  ValidateUnique(AEntity, AOperation);
end;

procedure TSysPermissionTemplateRightService.DoAdd(AEntity: TSysPermissionTemplateRight);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSysPermissionTemplateRightService.DoUpdate(AEntity: TSysPermissionTemplateRight);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TSysPermissionTemplateRightService.DoDelete(AId: Int64);
var
  LEntity: TSysPermissionTemplateRight;
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

function TSysPermissionTemplateRightService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysPermissionTemplateRight>;
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

function TSysPermissionTemplateRightService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysPermissionTemplateRight;
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

procedure TSysPermissionTemplateRightService.BusinessInsert(AEntity: TSysPermissionTemplateRight; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysPermissionTemplateRightService.BusinessUpdate(AEntity: TSysPermissionTemplateRight; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysPermissionTemplateRightService.BusinessDelete(AEntity: TSysPermissionTemplateRight; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSysPermissionTemplateRightService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysPermissionTemplateRightService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysPermissionTemplateRight>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysPermissionTemplateRightService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysPermissionTemplateRight;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysPermissionTemplateRightService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysPermissionTemplateRight;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysPermissionTemplateRightService.Add(AEntity: TSysPermissionTemplateRight);
begin
  DoAdd(AEntity);
end;

procedure TSysPermissionTemplateRightService.Update(AEntity: TSysPermissionTemplateRight);
begin
  DoUpdate(AEntity);
end;

procedure TSysPermissionTemplateRightService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

function TSysPermissionTemplateRightService.AddMissingPermissions(ATemplateId: Int64): Integer;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, True);

  if Self.UoW.InTransaction then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.ActiveTransactionExist, 'Active transaction exists'));

  Self.UoW.BeginTransaction;
  try
    Result := TSysPermissionTemplateRightRepository(FRepo).AddMissingPermissions(ATemplateId);
    Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TSysPermissionTemplateRightService.SetAllFlags(ATemplateId: Int64; AValue: Boolean);
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, True);

  if Self.UoW.InTransaction then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.ActiveTransactionExist, 'Active transaction exists'));

  Self.UoW.BeginTransaction;
  try
    TSysPermissionTemplateRightRepository(FRepo).SetAllFlags(ATemplateId, AValue);
    Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

end.
