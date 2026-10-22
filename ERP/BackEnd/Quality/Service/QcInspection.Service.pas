unit QcInspection.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  QcInspection.Repository, QcInspection, QcInspection.Exception, QcSetting, QcSetting.Repository;

type
  // Giriş kalite kontrol kaydı. Satın alma / mal kabul bu servisi bilmez: kayıt mal kabul kalemini okur, modül
  // kapalıyken (QcSetting) yeni kayıt / değişiklik reddedilir; silme her zaman serbest
  TQcInspectionService = class(TCrudService<TQcInspection>)
  private
    FRepo: IRepository<TQcInspection>;
    FSettingRepo: IRepository<TQcSetting>;

    procedure DoAdd(AEntity: TQcInspection);
    procedure DoUpdate(AEntity: TQcInspection);
    procedure DoDelete(AId: Int64);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TQcInspection; AOperation: TCrudOperation); override;
    // Uygun miktar ve sonuç uygunsuz miktardan (form + servis ortak)
    class procedure CalculateResult(AEntity: TQcInspection); static;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TQcInspection>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TQcInspection; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TQcInspection; override;

    procedure Add(AEntity: TQcInspection); override;
    procedure Update(AEntity: TQcInspection); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TQcInspection; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TQcInspection>; override;
    procedure BusinessInsert(AEntity: TQcInspection; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TQcInspection; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TQcInspection; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, QcLookup;

constructor TQcInspectionService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TQcInspection, TQcInspectionRepository>;
  FSettingRepo := Self.UoW.GetRepository<TQcSetting, TQcSettingRepository>;
  Self.PermissionCode := PERMISSION_QC_INSPECTION;
end;

destructor TQcInspectionService.Destroy;
begin
  inherited;
end;

class procedure TQcInspectionService.CalculateResult(AEntity: TQcInspection);
begin
  AEntity.AcceptedQuantity := AEntity.Quantity - AEntity.RejectedQuantity;
  if AEntity.RejectedQuantity = 0 then
    AEntity.InspectionResult := QC_RESULT_ACCEPTED
  else if AEntity.AcceptedQuantity = 0 then
    AEntity.InspectionResult := QC_RESULT_REJECTED
  else
    AEntity.InspectionResult := QC_RESULT_PARTIAL;
  if AEntity.RejectedQuantity = 0 then
    AEntity.Disposition := 0;
end;

procedure TQcInspectionService.ValidateBusinessRules(AEntity: TQcInspection; AOperation: TCrudOperation);
var
  LInventoryId: Int64;
  LQuantity: Currency;
  LRequired: Boolean;
  LFilter: TFilterCriteria;
  LModel: TQcInspection;
begin
  if AOperation = coDelete then
    Exit;

  // modül kapalı: kontrol adımı yok (satın alma / stok / fatura akışı etkilenmez)
  if not TQcSettingRepository(FSettingRepo).IsEnabled then
    raise EQcInspectionExceptionModuleDisabled.Create;

  AEntity.InspectionNo := AnsiUpperCase(Trim(AEntity.InspectionNo));
  AEntity.Description := Trim(AEntity.Description);
  if AEntity.InspectionDate <= 0 then
    AEntity.InspectionDate := Date;

  // stok ve kontrol edilen miktar mal kabul kaleminden
  if not TQcInspectionRepository(FRepo).ReadReceiptLine(AEntity.PurReceiptDetailId, LInventoryId, LQuantity, LRequired) then
    raise EQcInspectionExceptionReceiptLineNotFound.Create;
  if not LRequired then
    raise EQcInspectionExceptionNotRequired.Create;
  AEntity.StkInventoryId := LInventoryId;
  AEntity.Quantity := LQuantity;
  if (AEntity.RejectedQuantity < 0) or (AEntity.RejectedQuantity > AEntity.Quantity) then
    raise EQcInspectionExceptionRejectedQuantity.Create;
  CalculateResult(AEntity);
  if (AEntity.RejectedQuantity > 0) and not TQcLookup.IsValid(qlkDisposition, AEntity.Disposition) then
    raise EQcInspectionExceptionDispositionRequired.Create;

  if AEntity.InspectionNo = '' then
    if AOperation = coInsert then
      AEntity.InspectionNo := TQcInspectionRepository(FRepo).NextDocumentNo(QC_PREFIX_INSPECTION)
    else
    begin
      LModel := FRepo.FindById(AEntity.Id, False);
      try
        if Assigned(LModel) then
          AEntity.InspectionNo := LModel.InspectionNo;
      finally
        LModel.Free;
      end;
    end;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('inspection_no', '=', TValue.From<string>(AEntity.InspectionNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EQcInspectionExceptionNoUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('pur_receipt_detail_id', '=', TValue.From<Int64>(AEntity.PurReceiptDetailId)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EQcInspectionExceptionLineInspected.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TQcInspectionService.DoAdd(AEntity: TQcInspection);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
  TQcInspectionRepository(FRepo).SyncRejectTransfer(AEntity.Id);
end;

procedure TQcInspectionService.DoUpdate(AEntity: TQcInspection);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  TQcInspectionRepository(FRepo).SyncRejectTransfer(AEntity.Id);
end;

procedure TQcInspectionService.DoDelete(AId: Int64);
var
  LEntity: TQcInspection;
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

function TQcInspectionService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TQcInspection>;
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

function TQcInspectionService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TQcInspection;
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

procedure TQcInspectionService.BusinessInsert(AEntity: TQcInspection; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TQcInspectionService.BusinessUpdate(AEntity: TQcInspection; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TQcInspectionService.BusinessDelete(AEntity: TQcInspection; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TQcInspectionService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TQcInspectionService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TQcInspection>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TQcInspectionService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TQcInspection;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TQcInspectionService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TQcInspection;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TQcInspectionService.Add(AEntity: TQcInspection);
begin
  DoAdd(AEntity);
end;

procedure TQcInspectionService.Update(AEntity: TQcInspection);
begin
  DoUpdate(AEntity);
end;

procedure TQcInspectionService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
