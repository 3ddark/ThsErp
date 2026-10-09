unit PrdBomPacketRaw.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  PrdBomPacketRaw.Repository, PrdBomPacketRaw, PrdBomPacketRaw.Exception;

type
  TPrdBomPacketRawService = class(TCrudService<TPrdBomPacketRaw>)
  private
    FRepo: IRepository<TPrdBomPacketRaw>;

    procedure DoAdd(AEntity: TPrdBomPacketRaw);
    procedure DoUpdate(AEntity: TPrdBomPacketRaw);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TPrdBomPacketRaw);
    procedure ValidateUnique(AEntity: TPrdBomPacketRaw; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPrdBomPacketRaw; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrdBomPacketRaw>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrdBomPacketRaw; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPrdBomPacketRaw; override;

    procedure Add(AEntity: TPrdBomPacketRaw); override;
    procedure Update(AEntity: TPrdBomPacketRaw); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdBomPacketRaw; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdBomPacketRaw>; override;
    procedure BusinessInsert(AEntity: TPrdBomPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrdBomPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrdBomPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TPrdBomPacketRawService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPrdBomPacketRaw, TPrdBomPacketRawRepository>;
  Self.PermissionCode := PERMISSION_PRD_BOM;
end;

destructor TPrdBomPacketRawService.Destroy;
begin
  inherited;
end;

procedure TPrdBomPacketRawService.ValidateRequiredReferences(AEntity: TPrdBomPacketRaw);

  procedure CheckId(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  CheckId(AEntity.PrdBomId, TLangKeys.TPrdBomPacketRaw.ColPrdBomId, 'BoM');
  CheckId(AEntity.PrdPacketRawId, TLangKeys.TPrdBomPacketRaw.ColPrdPacketRawId, 'Raw Material Packet');
end;

procedure TPrdBomPacketRawService.ValidateUnique(AEntity: TPrdBomPacketRaw; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TPrdBomPacketRaw;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('prd_bom_id', '=', TValue.From<Int64>(AEntity.PrdBomId)));
      LFilter.Add(TFilterCriterion.New('prd_packet_raw_id', '=', TValue.From<Int64>(AEntity.PrdPacketRawId)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EPrdBomPacketRawExceptionPacketUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TPrdBomPacketRawService.ValidateBusinessRules(AEntity: TPrdBomPacketRaw; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    ValidateRequiredReferences(AEntity);
    if AEntity.Quantity <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TPrdBomPacketRaw.ColQuantity, 'Quantity') + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero'));
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TPrdBomPacketRawService.DoAdd(AEntity: TPrdBomPacketRaw);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPrdBomPacketRawService.DoUpdate(AEntity: TPrdBomPacketRaw);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TPrdBomPacketRawService.DoDelete(AId: Int64);
var
  LEntity: TPrdBomPacketRaw;
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

function TPrdBomPacketRawService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdBomPacketRaw>;
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

function TPrdBomPacketRawService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdBomPacketRaw;
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

procedure TPrdBomPacketRawService.BusinessInsert(AEntity: TPrdBomPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdBomPacketRawService.BusinessUpdate(AEntity: TPrdBomPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdBomPacketRawService.BusinessDelete(AEntity: TPrdBomPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPrdBomPacketRawService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPrdBomPacketRawService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPrdBomPacketRaw>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TPrdBomPacketRawService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPrdBomPacketRaw;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TPrdBomPacketRawService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrdBomPacketRaw;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPrdBomPacketRawService.Add(AEntity: TPrdBomPacketRaw);
begin
  DoAdd(AEntity);
end;

procedure TPrdBomPacketRawService.Update(AEntity: TPrdBomPacketRaw);
begin
  DoUpdate(AEntity);
end;

procedure TPrdBomPacketRawService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
