unit StkCardKindInfo.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  StkCardKindInfo.Repository, StkCardKindInfo, StkCardKindInfo.Exception;

type
  TStkCardKindInfoService = class(TCrudService<TStkCardKindInfo>)
  private
    FRepo: IRepository<TStkCardKindInfo>;

    procedure DoAdd(AEntity: TStkCardKindInfo);
    procedure DoUpdate(AEntity: TStkCardKindInfo);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TStkCardKindInfo);
    procedure ValidateUnique(AEntity: TStkCardKindInfo; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TStkCardKindInfo; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TStkCardKindInfo>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TStkCardKindInfo; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TStkCardKindInfo; override;

    procedure Add(AEntity: TStkCardKindInfo); override;
    procedure Update(AEntity: TStkCardKindInfo); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkCardKindInfo; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkCardKindInfo>; override;
    procedure BusinessInsert(AEntity: TStkCardKindInfo; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkCardKindInfo; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkCardKindInfo; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TStkCardKindInfoService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TStkCardKindInfo, TStkCardKindInfoRepository>;
  Self.PermissionCode := PERMISSION_STK_INVENTORY;
end;

destructor TStkCardKindInfoService.Destroy;
begin
  inherited;
end;

procedure TStkCardKindInfoService.ValidateRequiredReferences(AEntity: TStkCardKindInfo);

  procedure Check(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  Check(AEntity.StkInventoryId, TLangKeys.TStkCardKindInfo.ColInventory, 'Stock Card');
  Check(AEntity.StkKindPropertyId, TLangKeys.TStkCardKindInfo.ColKind, 'Kind');
end;

procedure TStkCardKindInfoService.ValidateUnique(AEntity: TStkCardKindInfo; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TStkCardKindInfo;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('stk_inventory_id', '=', TValue.From<Int64>(AEntity.StkInventoryId)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EStkCardKindInfoExceptionInventoryUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TStkCardKindInfoService.ValidateBusinessRules(AEntity: TStkCardKindInfo; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
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
    ValidateRequiredReferences(AEntity);
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TStkCardKindInfoService.DoAdd(AEntity: TStkCardKindInfo);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TStkCardKindInfoService.DoUpdate(AEntity: TStkCardKindInfo);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TStkCardKindInfoService.DoDelete(AId: Int64);
var
  LEntity: TStkCardKindInfo;
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

function TStkCardKindInfoService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkCardKindInfo>;
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

function TStkCardKindInfoService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkCardKindInfo;
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

procedure TStkCardKindInfoService.BusinessInsert(AEntity: TStkCardKindInfo; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkCardKindInfoService.BusinessUpdate(AEntity: TStkCardKindInfo; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkCardKindInfoService.BusinessDelete(AEntity: TStkCardKindInfo; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TStkCardKindInfoService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TStkCardKindInfoService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TStkCardKindInfo>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TStkCardKindInfoService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TStkCardKindInfo;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TStkCardKindInfoService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TStkCardKindInfo;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TStkCardKindInfoService.Add(AEntity: TStkCardKindInfo);
begin
  DoAdd(AEntity);
end;

procedure TStkCardKindInfoService.Update(AEntity: TStkCardKindInfo);
begin
  DoUpdate(AEntity);
end;

procedure TStkCardKindInfoService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
