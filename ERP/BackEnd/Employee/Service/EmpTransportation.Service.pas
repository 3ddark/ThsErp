unit EmpTransportation.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EmpTransportation.Repository, EmpTransportation, EmpTransportation.Exception;

type
  TEmpTransportationService = class(TCrudService<TEmpTransportation>)
  private
    FRepo: IRepository<TEmpTransportation>;

    procedure DoAdd(AEntity: TEmpTransportation);
    procedure DoUpdate(AEntity: TEmpTransportation);
    procedure DoDelete(AId: Int64);
    procedure ValidateUnique(AEntity: TEmpTransportation; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEmpTransportation; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEmpTransportation>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEmpTransportation; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEmpTransportation; override;

    procedure Add(AEntity: TEmpTransportation); override;
    procedure Update(AEntity: TEmpTransportation); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpTransportation; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpTransportation>; override;
    procedure BusinessInsert(AEntity: TEmpTransportation; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEmpTransportation; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEmpTransportation; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TEmpTransportationService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEmpTransportation, TEmpTransportationRepository>;
  Self.PermissionCode := PERMISSION_EMP_TRANSPORTATION;
end;

destructor TEmpTransportationService.Destroy;
begin
  inherited;
end;

procedure TEmpTransportationService.ValidateUnique(AEntity: TEmpTransportation; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TEmpTransportation;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('car_no', '=', TValue.From<SmallInt>(AEntity.CarNo)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EEmpTransportationExceptionCarNoUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TEmpTransportationService.ValidateBusinessRules(AEntity: TEmpTransportation; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.CarName := Trim(AEntity.CarName);
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TEmpTransportationService.DoAdd(AEntity: TEmpTransportation);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEmpTransportationService.DoUpdate(AEntity: TEmpTransportation);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEmpTransportationService.DoDelete(AId: Int64);
var
  LEntity: TEmpTransportation;
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

function TEmpTransportationService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpTransportation>;
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

function TEmpTransportationService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpTransportation;
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

procedure TEmpTransportationService.BusinessInsert(AEntity: TEmpTransportation; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpTransportationService.BusinessUpdate(AEntity: TEmpTransportation; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpTransportationService.BusinessDelete(AEntity: TEmpTransportation; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEmpTransportationService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEmpTransportationService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEmpTransportation>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEmpTransportationService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEmpTransportation;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEmpTransportationService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEmpTransportation;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEmpTransportationService.Add(AEntity: TEmpTransportation);
begin
  DoAdd(AEntity);
end;

procedure TEmpTransportationService.Update(AEntity: TEmpTransportation);
begin
  DoUpdate(AEntity);
end;

procedure TEmpTransportationService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
