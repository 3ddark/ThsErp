unit PurRequest.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  DocumentService, PurRequest.Repository, PurRequest, PurRequest.Exception, PurRequestDetail, PurRequestDetail.Repository;

type
  // Talep belgesi = başlık + Lines (TDocumentService: kalem işlemleri, yükleme, tek transaction'lı kayıt + Reload).
  // Başlık ve kalemler yalnız taslakta değişir; sipariş edilen miktar sipariş kalemlerinden (DB) tutulur.
  TPurRequestService = class(TDocumentService<TPurRequest, TPurRequestDetail>)
  private
    FRepo: IRepository<TPurRequest>;

    procedure DoAdd(AEntity: TPurRequest);
    procedure DoUpdate(AEntity: TPurRequest);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  protected
    // ---- belge yapısı / kayıt adımları (TDocumentService)
    function GetLines(AHeader: TPurRequest): TObjectList<TPurRequestDetail>; override;
    function FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TPurRequestDetail>; override;
    function GetLineHeaderId(ALine: TPurRequestDetail): Int64; override;
    procedure SetLineHeaderId(ALine: TPurRequestDetail; AHeaderId: Int64); override;
    function GetLineNo(ALine: TPurRequestDetail): Integer; override;
    procedure SetLineNo(ALine: TPurRequestDetail; ANo: Integer); override;
    procedure RaiseDuplicateLineNo; override;
    procedure InitLine(AHeader: TPurRequest; ALine: TPurRequestDetail); override;
    procedure CheckLines(AHeader: TPurRequest; const ALines: TArray<TPurRequestDetail>; AOldLines: TObjectList<TPurRequestDetail>); override;
    procedure PrepareCopyHeader(AHeader: TPurRequest); override;
    procedure PrepareCopyLine(AHeader: TPurRequest; ALine: TPurRequestDetail); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPurRequest; AOperation: TCrudOperation); override;
    procedure ChangeStatus(AId: Int64; ANewStatus: SmallInt; APermissionControl: Boolean);

    // Talepte tutar yok: hesap gerekmez
    procedure RecalculateLine(ALine: TPurRequestDetail); override;
    procedure RecalculateTotals(AHeader: TPurRequest); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPurRequest>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPurRequest; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPurRequest; override;

    procedure Add(AEntity: TPurRequest); override;
    procedure Update(AEntity: TPurRequest); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurRequest; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurRequest>; override;
    procedure BusinessInsert(AEntity: TPurRequest; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPurRequest; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPurRequest; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, PurLookup, PurRequestDetail.Service, PurRequestDetail.Exception;

constructor TPurRequestService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPurRequest, TPurRequestRepository>;
  FHeaderRepo := FRepo;
  FLineRepo := Self.UoW.GetRepository<TPurRequestDetail, TPurRequestDetailRepository>;
  Self.PermissionCode := PERMISSION_PUR_REQUEST;
end;

{ Belge (TDocumentService) }

function TPurRequestService.GetLines(AHeader: TPurRequest): TObjectList<TPurRequestDetail>;
begin
  Result := AHeader.Lines;
end;

function TPurRequestService.FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TPurRequestDetail>;
begin
  Result := TPurRequestDetailRepository(FLineRepo).FindByRequestIds(AIds);
end;

function TPurRequestService.GetLineHeaderId(ALine: TPurRequestDetail): Int64;
begin
  Result := ALine.PurRequestId;
end;

procedure TPurRequestService.SetLineHeaderId(ALine: TPurRequestDetail; AHeaderId: Int64);
begin
  ALine.PurRequestId := AHeaderId;
end;

function TPurRequestService.GetLineNo(ALine: TPurRequestDetail): Integer;
begin
  Result := ALine.LineNo;
end;

procedure TPurRequestService.SetLineNo(ALine: TPurRequestDetail; ANo: Integer);
begin
  ALine.LineNo := ANo;
end;

procedure TPurRequestService.RaiseDuplicateLineNo;
begin
  raise EPurRequestDetailExceptionLineUnique.Create;
end;

// Belge no (görüntü), gerekli tarih başlıktan
procedure TPurRequestService.InitLine(AHeader: TPurRequest; ALine: TPurRequestDetail);
begin
  ALine.RequestNo := AHeader.RequestNo;
  ALine.RequiredDate := AHeader.RequiredDate;
end;

// Alanlar (tek kalem yoluyla ortak CheckLine), stok talepte bir kez; kalemler yalnız taslakta (başlık kuralı da
// taslak dışını reddeder); sipariş edilen miktar DB'den (sipariş kalemleri tutar)
procedure TPurRequestService.CheckLines(AHeader: TPurRequest; const ALines: TArray<TPurRequestDetail>;
  AOldLines: TObjectList<TPurRequestDetail>);
var
  LLine, LOld: TPurRequestDetail;
  LOldById: TDictionary<Int64, TPurRequestDetail>;
  LInventories: TDictionary<Int64, Boolean>;
begin
  LOldById := TDictionary<Int64, TPurRequestDetail>.Create;
  LInventories := TDictionary<Int64, Boolean>.Create;
  try
    for LOld in AOldLines do
      LOldById.AddOrSetValue(LOld.Id, LOld);

    // siparişe aktarılmış kalem silinemez
    for LLine in AHeader.Lines do
      if LLine.Deleted and LOldById.TryGetValue(LLine.Id, LOld) and (LOld.OrderedQuantity > 0) then
        raise EPurRequestExceptionHasOrders.Create;

    for LLine in ALines do
    begin
      TPurRequestDetailService.CheckLine(LLine);
      if LInventories.ContainsKey(LLine.StkInventoryId) then
        raise EPurRequestDetailExceptionInventoryUnique.Create;
      LInventories.Add(LLine.StkInventoryId, True);
      if LOldById.TryGetValue(LLine.Id, LOld) then
        LLine.OrderedQuantity := LOld.OrderedQuantity
      else
        LLine.OrderedQuantity := 0;
    end;
  finally
    LInventories.Free;
    LOldById.Free;
  end;
end;

procedure TPurRequestService.PrepareCopyHeader(AHeader: TPurRequest);
begin
  AHeader.RequestNo := '';
  AHeader.Status := PUR_REQ_DRAFT;
end;

procedure TPurRequestService.PrepareCopyLine(AHeader: TPurRequest; ALine: TPurRequestDetail);
begin
  inherited;
  ALine.RequestNo := '';
  ALine.OrderedQuantity := 0;
end;

procedure TPurRequestService.RecalculateLine(ALine: TPurRequestDetail);
begin
//
end;

procedure TPurRequestService.RecalculateTotals(AHeader: TPurRequest);
begin
//
end;

destructor TPurRequestService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TPurRequestService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


// Elle durum değişikliği (onay / taslağa alma / red / iptal / kapama); kendi açtığı transaction'ı commit eder
procedure TPurRequestService.ChangeStatus(AId: Int64; ANewStatus: SmallInt; APermissionControl: Boolean);
var
  LOld: TPurRequest;
  LStarted: Boolean;
begin
  LStarted := False;
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);
    if not Self.UoW.InTransaction then
    begin
      Self.UoW.BeginTransaction;
      LStarted := True;
    end;

    LOld := FRepo.FindById(AId, True);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));
      if not TPurLookup.CanChangeRequestStatus(LOld.Status, ANewStatus) then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TPurRequest.InvalidStatus,
          'Status cannot be changed from "%s" to "%s".'), [TPurLookup.Text(plkRequestStatus, LOld.Status), TPurLookup.Text(plkRequestStatus, ANewStatus)]));
      if (ANewStatus = PUR_REQ_APPROVED) and (TPurRequestRepository(FRepo).LineCount(AId) = 0) then
        raise EPurRequestExceptionNoLines.Create;
      if (ANewStatus in [PUR_REQ_DRAFT, PUR_REQ_REJECTED]) and (TPurRequestRepository(FRepo).OrderedTotal(AId) > 0) then
        raise EPurRequestExceptionHasOrders.Create;
      TPurRequestRepository(FRepo).SetStatus(AId, ANewStatus);
    finally
      LOld.Free;
    end;

    if LStarted and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TPurRequestService.ValidateBusinessRules(AEntity: TPurRequest; AOperation: TCrudOperation);
var
  LRepo: TPurRequestRepository;
  LOld: TPurRequest;
  LFilter: TFilterCriteria;
  LModel: TPurRequest;
begin
  LRepo := TPurRequestRepository(FRepo);
  if AOperation = coDelete then
  begin
    if not (AEntity.Status in [PUR_REQ_DRAFT, PUR_REQ_REJECTED]) then
      raise EPurRequestExceptionDraftOnly.Create;
    if LRepo.OrderedTotal(AEntity.Id) > 0 then
      raise EPurRequestExceptionHasOrders.Create;
    Exit;
  end;

  AEntity.RequestNo := AnsiUpperCase(Trim(AEntity.RequestNo));
  AEntity.Description := Trim(AEntity.Description);
  if AEntity.RequestDate <= 0 then
    FailRequired(TLangKeys.TPurRequest.ColRequestDate, 'Request Date');
  if (AEntity.RequiredDate > 0) and (AEntity.RequiredDate < AEntity.RequestDate) then
    raise EPurRequestExceptionRequiredDate.Create;

  if AOperation = coInsert then
  begin
    AEntity.Status := PUR_REQ_DRAFT;
    if AEntity.RequestNo = '' then
      AEntity.RequestNo := LRepo.NextDocumentNo(PUR_PREFIX_REQUEST);
  end
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
      if LOld.Status <> PUR_REQ_DRAFT then
        raise EPurRequestExceptionDraftOnly.Create;
      AEntity.Status := LOld.Status;
      if AEntity.RequestNo = '' then
        AEntity.RequestNo := LOld.RequestNo;
    finally
      LOld.Free;
    end;
  end;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('request_no', '=', TValue.From<string>(AEntity.RequestNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EPurRequestExceptionNoUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TPurRequestService.DoAdd(AEntity: TPurRequest);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPurRequestService.DoUpdate(AEntity: TPurRequest);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TPurRequestService.DoDelete(AId: Int64);
var
  LEntity: TPurRequest;
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

function TPurRequestService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurRequest>;
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

function TPurRequestService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurRequest;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    // belge: başlık + kalemler
    Result := FRepo.FindById(AId, ALock);
    if Assigned(Result) then
      LoadLines([Result]);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TPurRequestService.BusinessInsert(AEntity: TPurRequest; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurRequestService.BusinessUpdate(AEntity: TPurRequest; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurRequestService.BusinessDelete(AEntity: TPurRequest; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPurRequestService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

// AIncludeNestedEntities: kalemler de (tek sorguda)
function TPurRequestService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPurRequest>;
begin
  Result := FRepo.Find(AFilter, ALock);
  if AIncludeNestedEntities and (Result.Count > 0) then
    LoadLines(Result.ToArray);
end;

function TPurRequestService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPurRequest;
begin
  Result := FRepo.FindById(AId, ALock);
  if AIncludeNestedEntities and Assigned(Result) then
    LoadLines([Result]);
end;

function TPurRequestService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPurRequest;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPurRequestService.Add(AEntity: TPurRequest);
begin
  DoAdd(AEntity);
end;

procedure TPurRequestService.Update(AEntity: TPurRequest);
begin
  DoUpdate(AEntity);
end;

procedure TPurRequestService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
