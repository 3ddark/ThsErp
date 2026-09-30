unit StkKindFamily.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  StkKindFamily.Repository, StkKindFamily, StkKindFamily.Exception;

type
  TStkKindFamilyService = class(TCrudService<TStkKindFamily>)
  private
    FRepo: IRepository<TStkKindFamily>;

    procedure DoAdd(AEntity: TStkKindFamily);
    procedure DoUpdate(AEntity: TStkKindFamily);
    procedure DoDelete(AId: Int64);
    procedure ValidateUnique(AEntity: TStkKindFamily; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TStkKindFamily; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TStkKindFamily>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TStkKindFamily; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TStkKindFamily; override;

    procedure Add(AEntity: TStkKindFamily); override;
    procedure Update(AEntity: TStkKindFamily); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkKindFamily; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkKindFamily>; override;
    procedure BusinessInsert(AEntity: TStkKindFamily; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkKindFamily; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkKindFamily; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TStkKindFamilyService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TStkKindFamily, TStkKindFamilyRepository>;
  Self.PermissionCode := PERMISSION_STK_KIND_FAMILY;
end;

destructor TStkKindFamilyService.Destroy;
begin
  inherited;
end;

procedure TStkKindFamilyService.ValidateUnique(AEntity: TStkKindFamily; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TStkKindFamily;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('family', '=', TValue.From<string>(AEntity.Family)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EStkKindFamilyExceptionFamilyUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TStkKindFamilyService.ValidateBusinessRules(AEntity: TStkKindFamily; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.Family := AnsiUpperCase(Trim(AEntity.Family));
    AEntity.Description := Trim(AEntity.Description);
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TStkKindFamilyService.DoAdd(AEntity: TStkKindFamily);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TStkKindFamilyService.DoUpdate(AEntity: TStkKindFamily);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TStkKindFamilyService.DoDelete(AId: Int64);
var
  LEntity: TStkKindFamily;
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

function TStkKindFamilyService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkKindFamily>;
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

function TStkKindFamilyService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkKindFamily;
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

procedure TStkKindFamilyService.BusinessInsert(AEntity: TStkKindFamily; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkKindFamilyService.BusinessUpdate(AEntity: TStkKindFamily; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkKindFamilyService.BusinessDelete(AEntity: TStkKindFamily; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TStkKindFamilyService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TStkKindFamilyService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TStkKindFamily>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TStkKindFamilyService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TStkKindFamily;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TStkKindFamilyService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TStkKindFamily;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TStkKindFamilyService.Add(AEntity: TStkKindFamily);
begin
  DoAdd(AEntity);
end;

procedure TStkKindFamilyService.Update(AEntity: TStkKindFamily);
begin
  DoUpdate(AEntity);
end;

procedure TStkKindFamilyService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
