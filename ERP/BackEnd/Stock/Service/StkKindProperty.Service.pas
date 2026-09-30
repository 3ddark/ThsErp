unit StkKindProperty.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  StkKindProperty.Repository, StkKindProperty, StkKindProperty.Exception;

type
  TStkKindPropertyService = class(TCrudService<TStkKindProperty>)
  private
    FRepo: IRepository<TStkKindProperty>;

    procedure DoAdd(AEntity: TStkKindProperty);
    procedure DoUpdate(AEntity: TStkKindProperty);
    procedure DoDelete(AId: Int64);
    procedure ValidateUnique(AEntity: TStkKindProperty; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TStkKindProperty; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TStkKindProperty>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TStkKindProperty; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TStkKindProperty; override;

    procedure Add(AEntity: TStkKindProperty); override;
    procedure Update(AEntity: TStkKindProperty); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkKindProperty; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkKindProperty>; override;
    procedure BusinessInsert(AEntity: TStkKindProperty; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkKindProperty; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkKindProperty; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TStkKindPropertyService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TStkKindProperty, TStkKindPropertyRepository>;
  Self.PermissionCode := PERMISSION_STK_KIND_PROPERTY;
end;

destructor TStkKindPropertyService.Destroy;
begin
  inherited;
end;

procedure TStkKindPropertyService.ValidateUnique(AEntity: TStkKindProperty; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TStkKindProperty;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('kind', '=', TValue.From<string>(AEntity.Kind)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EStkKindPropertyExceptionKindUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TStkKindPropertyService.ValidateBusinessRules(AEntity: TStkKindProperty; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.Kind := AnsiUpperCase(Trim(AEntity.Kind));
    AEntity.Description := Trim(AEntity.Description);
    AEntity.S1 := Trim(AEntity.S1);
    AEntity.S2 := Trim(AEntity.S2);
    AEntity.S3 := Trim(AEntity.S3);
    AEntity.S4 := Trim(AEntity.S4);
    AEntity.S5 := Trim(AEntity.S5);
    AEntity.S6 := Trim(AEntity.S6);
    AEntity.S7 := Trim(AEntity.S7);
    AEntity.S8 := Trim(AEntity.S8);
    AEntity.S9 := Trim(AEntity.S9);
    AEntity.S10 := Trim(AEntity.S10);
    AEntity.I1 := Trim(AEntity.I1);
    AEntity.I2 := Trim(AEntity.I2);
    AEntity.I3 := Trim(AEntity.I3);
    AEntity.I4 := Trim(AEntity.I4);
    AEntity.I5 := Trim(AEntity.I5);
    AEntity.D1 := Trim(AEntity.D1);
    AEntity.D2 := Trim(AEntity.D2);
    AEntity.D3 := Trim(AEntity.D3);
    AEntity.D4 := Trim(AEntity.D4);
    AEntity.D5 := Trim(AEntity.D5);
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TStkKindPropertyService.DoAdd(AEntity: TStkKindProperty);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TStkKindPropertyService.DoUpdate(AEntity: TStkKindProperty);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TStkKindPropertyService.DoDelete(AId: Int64);
var
  LEntity: TStkKindProperty;
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

function TStkKindPropertyService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkKindProperty>;
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

function TStkKindPropertyService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkKindProperty;
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

procedure TStkKindPropertyService.BusinessInsert(AEntity: TStkKindProperty; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkKindPropertyService.BusinessUpdate(AEntity: TStkKindProperty; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkKindPropertyService.BusinessDelete(AEntity: TStkKindProperty; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TStkKindPropertyService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TStkKindPropertyService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TStkKindProperty>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TStkKindPropertyService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TStkKindProperty;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TStkKindPropertyService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TStkKindProperty;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TStkKindPropertyService.Add(AEntity: TStkKindProperty);
begin
  DoAdd(AEntity);
end;

procedure TStkKindPropertyService.Update(AEntity: TStkKindProperty);
begin
  DoUpdate(AEntity);
end;

procedure TStkKindPropertyService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
