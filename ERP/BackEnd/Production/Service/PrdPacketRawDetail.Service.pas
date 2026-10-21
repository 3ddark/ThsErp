unit PrdPacketRawDetail.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  PrdPacketRawDetail.Repository, PrdPacketRawDetail, PrdPacketRawDetail.Exception;

type
  TPrdPacketRawDetailService = class(TCrudService<TPrdPacketRawDetail>)
  private
    FRepo: IRepository<TPrdPacketRawDetail>;

    procedure DoAdd(AEntity: TPrdPacketRawDetail);
    procedure DoUpdate(AEntity: TPrdPacketRawDetail);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TPrdPacketRawDetail);
    procedure ValidateUnique(AEntity: TPrdPacketRawDetail; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPrdPacketRawDetail; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrdPacketRawDetail>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrdPacketRawDetail; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPrdPacketRawDetail; override;

    procedure Add(AEntity: TPrdPacketRawDetail); override;
    procedure Update(AEntity: TPrdPacketRawDetail); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdPacketRawDetail; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdPacketRawDetail>; override;
    procedure BusinessInsert(AEntity: TPrdPacketRawDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrdPacketRawDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrdPacketRawDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TPrdPacketRawDetailService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPrdPacketRawDetail, TPrdPacketRawDetailRepository>;
  Self.PermissionCode := PERMISSION_PRD_PACKET_RAW;
end;

destructor TPrdPacketRawDetailService.Destroy;
begin
  inherited;
end;

procedure TPrdPacketRawDetailService.ValidateRequiredReferences(AEntity: TPrdPacketRawDetail);

  procedure CheckId(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  CheckId(AEntity.PrdPacketRawId, TLangKeys.TPrdPacketRawDetail.ColPrdPacketRawId, 'Packet');
  CheckId(AEntity.StkInventoryId, TLangKeys.TPrdPacketRawDetail.ColStkInventoryId, 'Raw Material');
end;

procedure TPrdPacketRawDetailService.ValidateUnique(AEntity: TPrdPacketRawDetail; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TPrdPacketRawDetail;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('prd_packet_raw_id', '=', TValue.From<Int64>(AEntity.PrdPacketRawId)));
      LFilter.Add(TFilterCriterion.New('stk_inventory_id', '=', TValue.From<Int64>(AEntity.StkInventoryId)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EPrdPacketRawDetailExceptionInventoryUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TPrdPacketRawDetailService.ValidateBusinessRules(AEntity: TPrdPacketRawDetail; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    ValidateRequiredReferences(AEntity);
    if AEntity.LineNo <= 0 then
      AEntity.LineNo := TPrdPacketRawDetailRepository(FRepo).NextLineNo(AEntity.PrdPacketRawId);
    if AEntity.Quantity <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColQuantity, 'Quantity') + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero'));
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TPrdPacketRawDetailService.DoAdd(AEntity: TPrdPacketRawDetail);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPrdPacketRawDetailService.DoUpdate(AEntity: TPrdPacketRawDetail);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TPrdPacketRawDetailService.DoDelete(AId: Int64);
var
  LEntity: TPrdPacketRawDetail;
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

function TPrdPacketRawDetailService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdPacketRawDetail>;
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

function TPrdPacketRawDetailService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdPacketRawDetail;
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

procedure TPrdPacketRawDetailService.BusinessInsert(AEntity: TPrdPacketRawDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdPacketRawDetailService.BusinessUpdate(AEntity: TPrdPacketRawDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdPacketRawDetailService.BusinessDelete(AEntity: TPrdPacketRawDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPrdPacketRawDetailService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPrdPacketRawDetailService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPrdPacketRawDetail>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TPrdPacketRawDetailService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPrdPacketRawDetail;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TPrdPacketRawDetailService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrdPacketRawDetail;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPrdPacketRawDetailService.Add(AEntity: TPrdPacketRawDetail);
begin
  DoAdd(AEntity);
end;

procedure TPrdPacketRawDetailService.Update(AEntity: TPrdPacketRawDetail);
begin
  DoUpdate(AEntity);
end;

procedure TPrdPacketRawDetailService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
