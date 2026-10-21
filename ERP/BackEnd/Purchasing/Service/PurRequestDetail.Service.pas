unit PurRequestDetail.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  PurRequestDetail.Repository, PurRequestDetail, PurRequestDetail.Exception, PurRequest, PurRequest.Repository;

type
  TPurRequestDetailService = class(TCrudService<TPurRequestDetail>)
  private
    FRepo: IRepository<TPurRequestDetail>;
    FRequestRepo: IRepository<TPurRequest>;

    procedure DoAdd(AEntity: TPurRequestDetail);
    procedure DoUpdate(AEntity: TPurRequestDetail);
    procedure DoDelete(AId: Int64);

    class procedure FailRequired(const AKey, ADefault: string); static;
    class procedure Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string); static;
    procedure EnsureDraft(ARequestId: Int64);
  public
    constructor Create;
    destructor Destroy; override;

    // Kalemin kendi alanları (DB'siz): stok, miktar. Tek kalem kaydı (ValidateBusinessRules) ve belge kaydı
    // (TPurRequestService.BusinessSaveWithDetails) ortak kullanır
    class procedure CheckLine(AEntity: TPurRequestDetail); static;
    procedure ValidateBusinessRules(AEntity: TPurRequestDetail; AOperation: TCrudOperation); override;

    // Satır formu: stok seçilince ölçü birimi
    function GetUomCode(AInventoryId: Int64): string;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPurRequestDetail>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPurRequestDetail; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPurRequestDetail; override;

    procedure Add(AEntity: TPurRequestDetail); override;
    procedure Update(AEntity: TPurRequestDetail); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurRequestDetail; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurRequestDetail>; override;
    procedure BusinessInsert(AEntity: TPurRequestDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPurRequestDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPurRequestDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, PurLookup, PurOrderDetail, PurOrderDetail.Repository;

constructor TPurRequestDetailService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPurRequestDetail, TPurRequestDetailRepository>;
  FRequestRepo := Self.UoW.GetRepository<TPurRequest, TPurRequestRepository>;
  Self.PermissionCode := PERMISSION_PUR_REQUEST;
end;

destructor TPurRequestDetailService.Destroy;
begin
  inherited;
end;

function TPurRequestDetailService.GetUomCode(AInventoryId: Int64): string;
begin
  Result := TPurOrderDetailRepository(Self.UoW.GetRepository<TPurOrderDetail, TPurOrderDetailRepository>).GetUomCode(AInventoryId);
end;

// Alan adı + "zorunludur" mesajı
class procedure TPurRequestDetailService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

// Alan adı + mesaj
class procedure TPurRequestDetailService.Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(AMsgKey, AMsgDefault));
end;

class procedure TPurRequestDetailService.CheckLine(AEntity: TPurRequestDetail);
begin
  AEntity.Description := Trim(AEntity.Description);
  if AEntity.StkInventoryId <= 0 then
    FailRequired(TLangKeys.TPurRequestDetail.ColStkInventoryId, 'Stock Card');
  if AEntity.Quantity <= 0 then
    Fail(TLangKeys.TPurRequestDetail.ColQuantity, 'Quantity', TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero');
end;

procedure TPurRequestDetailService.EnsureDraft(ARequestId: Int64);
var
  LRequest: TPurRequest;
begin
  LRequest := FRequestRepo.FindById(ARequestId, False);
  try
    if not Assigned(LRequest) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [ARequestId]));
    if LRequest.Status <> PUR_REQ_DRAFT then
      raise EPurRequestDetailExceptionDraftOnly.Create;
  finally
    LRequest.Free;
  end;
end;

procedure TPurRequestDetailService.ValidateBusinessRules(AEntity: TPurRequestDetail; AOperation: TCrudOperation);
var
  LOld: TPurRequestDetail;
  LFilter: TFilterCriteria;
  LModel: TPurRequestDetail;
begin
  if AOperation = coDelete then
  begin
    EnsureDraft(AEntity.PurRequestId);
    Exit;
  end;

  if AEntity.PurRequestId <= 0 then
    FailRequired(TLangKeys.TPurRequestDetail.ColPurRequestId, 'Request');
  CheckLine(AEntity);
  EnsureDraft(AEntity.PurRequestId);

  // sipariş edilen miktar servis tarafından tutulur
  if AOperation = coInsert then
    AEntity.OrderedQuantity := 0
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if Assigned(LOld) then
      begin
        AEntity.OrderedQuantity := LOld.OrderedQuantity;
        if LOld.PurRequestId <> AEntity.PurRequestId then
          EnsureDraft(LOld.PurRequestId);
      end;
    finally
      LOld.Free;
    end;
  end;

  if AEntity.LineNo <= 0 then
    AEntity.LineNo := TPurRequestDetailRepository(FRepo).NextLineNo(AEntity.PurRequestId);
  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('pur_request_id', '=', TValue.From<Int64>(AEntity.PurRequestId)));
    LFilter.Add(TFilterCriterion.New('line_no', '=', TValue.From<Integer>(AEntity.LineNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EPurRequestDetailExceptionLineUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('pur_request_id', '=', TValue.From<Int64>(AEntity.PurRequestId)));
    LFilter.Add(TFilterCriterion.New('stk_inventory_id', '=', TValue.From<Int64>(AEntity.StkInventoryId)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EPurRequestDetailExceptionInventoryUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TPurRequestDetailService.DoAdd(AEntity: TPurRequestDetail);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPurRequestDetailService.DoUpdate(AEntity: TPurRequestDetail);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TPurRequestDetailService.DoDelete(AId: Int64);
var
  LEntity: TPurRequestDetail;
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

function TPurRequestDetailService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurRequestDetail>;
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

function TPurRequestDetailService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurRequestDetail;
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

procedure TPurRequestDetailService.BusinessInsert(AEntity: TPurRequestDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurRequestDetailService.BusinessUpdate(AEntity: TPurRequestDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurRequestDetailService.BusinessDelete(AEntity: TPurRequestDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPurRequestDetailService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPurRequestDetailService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPurRequestDetail>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TPurRequestDetailService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPurRequestDetail;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TPurRequestDetailService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPurRequestDetail;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPurRequestDetailService.Add(AEntity: TPurRequestDetail);
begin
  DoAdd(AEntity);
end;

procedure TPurRequestDetailService.Update(AEntity: TPurRequestDetail);
begin
  DoUpdate(AEntity);
end;

procedure TPurRequestDetailService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
