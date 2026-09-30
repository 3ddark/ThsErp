unit StkTransaction.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  StkTransaction.Repository, StkTransaction, StkInventorySummary, StkInventorySummary.Repository;

type
  TStkTransactionService = class(TCrudService<TStkTransaction>)
  private
    FRepo: IRepository<TStkTransaction>;
    FSummaryRepo: IRepository<TStkInventorySummary>;

    procedure DoAdd(AEntity: TStkTransaction);
    procedure DoUpdate(AEntity: TStkTransaction);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TStkTransaction);
    procedure ValidateWarehouses(AEntity: TStkTransaction);
    procedure RecalculateSummary(AInventoryId: Int64);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TStkTransaction; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TStkTransaction>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TStkTransaction; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TStkTransaction; override;

    procedure Add(AEntity: TStkTransaction); override;
    procedure Update(AEntity: TStkTransaction); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkTransaction; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkTransaction>; override;
    procedure BusinessInsert(AEntity: TStkTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, StkLookup;

constructor TStkTransactionService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TStkTransaction, TStkTransactionRepository>;
  FSummaryRepo := Self.UoW.GetRepository<TStkInventorySummary, TStkInventorySummaryRepository>;
  Self.PermissionCode := PERMISSION_STK_TRANSACTION;
end;

destructor TStkTransactionService.Destroy;
begin
  inherited;
end;

procedure TStkTransactionService.ValidateRequiredReferences(AEntity: TStkTransaction);

  procedure Check(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  Check(Trunc(AEntity.TransactionDate), TLangKeys.TStkTransaction.ColTransactionDate, 'Date');
  Check(AEntity.TransactionType, TLangKeys.TStkTransaction.ColTransactionType, 'Transaction Type');
  Check(AEntity.StkInventoryId, TLangKeys.TStkTransaction.ColInventory, 'Stock Card');
end;

// Hareket tipine göre ambar alanları (DB'de stk_transaction_transaction_type_check ile aynı kural)
//   giriş: yalnız hedef, çıkış: yalnız kaynak, transfer: ikisi de ve farklı; açılış yalnız giriş olabilir
procedure TStkTransactionService.ValidateWarehouses(AEntity: TStkTransaction);

  procedure Fail(const AKey, ADefault: string);
  begin
    raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault));
  end;

begin
  if not TStkLookup.IsValid(slkTransactionType, AEntity.TransactionType) then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColTransactionType, 'Transaction Type') + ': ' +
      TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));

  case AEntity.TransactionType of
    STK_TRANSACTION_IN:
      begin
        AEntity.FromStkWarehouseId := 0;
        AEntity.FromWarehouseName := '';
      end;
    STK_TRANSACTION_OUT:
      begin
        AEntity.ToStkWarehouseId := 0;
        AEntity.ToWarehouseName := '';
      end;
  end;

  if (AEntity.TransactionType in [STK_TRANSACTION_OUT, STK_TRANSACTION_TRANSFER]) and (AEntity.FromStkWarehouseId <= 0) then
    Fail(TLangKeys.TStkTransaction.FromWarehouseRequired, 'Source warehouse is required for this transaction type.');
  if (AEntity.TransactionType in [STK_TRANSACTION_IN, STK_TRANSACTION_TRANSFER]) and (AEntity.ToStkWarehouseId <= 0) then
    Fail(TLangKeys.TStkTransaction.ToWarehouseRequired, 'Target warehouse is required for this transaction type.');
  if (AEntity.TransactionType = STK_TRANSACTION_TRANSFER) and (AEntity.FromStkWarehouseId = AEntity.ToStkWarehouseId) then
    Fail(TLangKeys.TStkTransaction.WarehousesSame, 'Source and target warehouses must be different.');
  if AEntity.IsOpening and (AEntity.TransactionType <> STK_TRANSACTION_IN) then
    Fail(TLangKeys.TStkTransaction.OpeningOnlyIncoming, 'An opening balance can only be an incoming transaction.');
end;

// Stok kartı özeti (stk_inventory_summary) hareketlerden aynı transaction içinde yeniden hesaplanır
procedure TStkTransactionService.RecalculateSummary(AInventoryId: Int64);
begin
  if AInventoryId > 0 then
    TStkInventorySummaryRepository(FSummaryRepo).Recalculate(AInventoryId);
end;

procedure TStkTransactionService.ValidateBusinessRules(AEntity: TStkTransaction; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.Currency := Trim(AEntity.Currency);
    AEntity.Description := Trim(AEntity.Description);
    ValidateRequiredReferences(AEntity);
    if AEntity.Quantity <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColQuantity, 'Quantity') + ': ' +
        TLocalizationManager.Translate(TLangKeys.TStkTransaction.QuantityPositive, 'Quantity must be greater than zero.'));
    if AEntity.Amount < 0 then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColAmount, 'Amount') + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.NegativeValueNotAllowed, 'Negative values are not allowed'));
    if AEntity.AmountForeign < 0 then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TStkTransaction.ColAmountForeign, 'Foreign Amount') + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.NegativeValueNotAllowed, 'Negative values are not allowed'));
    ValidateWarehouses(AEntity);
  end;
end;

procedure TStkTransactionService.DoAdd(AEntity: TStkTransaction);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
  RecalculateSummary(AEntity.StkInventoryId);
end;

procedure TStkTransactionService.DoUpdate(AEntity: TStkTransaction);
var
  LOld: TStkTransaction;
  LOldInventoryId: Int64;
begin
  ValidateAll(AEntity, coUpdate);

  LOldInventoryId := 0;
  LOld := FRepo.FindById(AEntity.Id, False);
  try
    if Assigned(LOld) then
      LOldInventoryId := LOld.StkInventoryId;
  finally
    LOld.Free;
  end;

  FRepo.Update(AEntity);
  RecalculateSummary(AEntity.StkInventoryId);
  if LOldInventoryId <> AEntity.StkInventoryId then
    RecalculateSummary(LOldInventoryId);
end;

procedure TStkTransactionService.DoDelete(AId: Int64);
var
  LEntity: TStkTransaction;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    FRepo.Delete(LEntity);
    RecalculateSummary(LEntity.StkInventoryId);
  finally
    LEntity.Free;
  end;
end;

function TStkTransactionService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkTransaction>;
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

function TStkTransactionService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkTransaction;
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

procedure TStkTransactionService.BusinessInsert(AEntity: TStkTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkTransactionService.BusinessUpdate(AEntity: TStkTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkTransactionService.BusinessDelete(AEntity: TStkTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TStkTransactionService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TStkTransactionService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TStkTransaction>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TStkTransactionService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TStkTransaction;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TStkTransactionService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TStkTransaction;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TStkTransactionService.Add(AEntity: TStkTransaction);
begin
  DoAdd(AEntity);
end;

procedure TStkTransactionService.Update(AEntity: TStkTransaction);
begin
  DoUpdate(AEntity);
end;

procedure TStkTransactionService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
