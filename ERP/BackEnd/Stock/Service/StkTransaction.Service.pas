unit StkTransaction.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  StkTransaction.Repository, StkTransaction, LocalizationManager;

type
  TStkTransactionService = class(TCrudService<TStkTransaction>)
  private
    FRepo: IRepository<TStkTransaction>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TStkTransaction>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TStkTransaction; override;
    procedure Add(AEntity: TStkTransaction); override;
    procedure Update(AEntity: TStkTransaction); override;
    procedure Delete(AId: Int64); override;

    procedure ValidateBusinessRules(AEntity: TStkTransaction; AOperation: TCrudOperation); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkTransaction; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkTransaction>; override;
    procedure BusinessInsert(AEntity: TStkTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TStkTransactionService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TStkTransaction, TStkTransactionRepository>;
  PermissionCode := 1042;
end;

destructor TStkTransactionService.Destroy;
begin
  FRepo := nil;
  inherited;
end;

procedure TStkTransactionService.ValidateBusinessRules(AEntity: TStkTransaction; AOperation: TCrudOperation);
begin
  if Trim(AEntity.Sku) = '' then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TStock.SkuRequired, 'Stok Kodu / SKU boş bırakılamaz.'));

  if AEntity.Quantity <= 0 then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TStock.QuantityMustBePositive, 'Stok hareket miktarı sıfırdan büyük olmalıdır.'));
end;

function TStkTransactionService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkTransaction>;
var
  LStartedTx: Boolean;
begin
  if APermissionControl then
    Self.IsAuthorized(ptRead, APermissionControl);

  LStartedTx := False;
  if AWithBegin and not Self.UoW.InTransaction then
  begin
    Self.UoW.BeginTransaction;
    LStartedTx := True;
  end;

  try
    Result := FRepo.Find(AFilter, ALock);
  except
    if LStartedTx and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TStkTransactionService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkTransaction;
var
  LStartedTx: Boolean;
begin
  if APermissionControl then
    Self.IsAuthorized(ptRead, APermissionControl);

  LStartedTx := False;
  if AWithBegin and not Self.UoW.InTransaction then
  begin
    Self.UoW.BeginTransaction;
    LStartedTx := True;
  end;

  try
    Result := FRepo.FindById(AId, ALock);
    if (Result = nil) and LStartedTx and Self.UoW.InTransaction then
      Self.UoW.Rollback;
  except
    if LStartedTx and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TStkTransactionService.BusinessInsert(AEntity: TStkTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
var
  LStartedTx: Boolean;
begin
  if APermissionControl then
    Self.IsAuthorized(ptAddRecord, APermissionControl);

  ValidateAll(AEntity, coInsert);

  LStartedTx := False;
  if AWithBegin and not Self.UoW.InTransaction then
  begin
    Self.UoW.BeginTransaction;
    LStartedTx := True;
  end;

  try
    FRepo.Add(AEntity);

    if AWithCommit and Self.UoW.InTransaction and (LStartedTx or AWithBegin) then
      Self.UoW.Commit;
  except
    if LStartedTx and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TStkTransactionService.BusinessUpdate(AEntity: TStkTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
var
  LStartedTx: Boolean;
begin
  if APermissionControl then
    Self.IsAuthorized(ptUpdate, APermissionControl);

  ValidateAll(AEntity, coUpdate);

  LStartedTx := False;
  if AWithBegin and not Self.UoW.InTransaction then
  begin
    Self.UoW.BeginTransaction;
    LStartedTx := True;
  end;

  try
    FRepo.Update(AEntity);

    if AWithCommit and Self.UoW.InTransaction and (LStartedTx or AWithBegin) then
      Self.UoW.Commit;
  except
    if LStartedTx and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TStkTransactionService.BusinessDelete(AEntity: TStkTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
var
  LStartedTx: Boolean;
begin
  if APermissionControl then
    Self.IsAuthorized(ptDelete, APermissionControl);

  ValidateAll(AEntity, coDelete);

  LStartedTx := False;
  if AWithBegin and not Self.UoW.InTransaction then
  begin
    Self.UoW.BeginTransaction;
    LStartedTx := True;
  end;

  try
    FRepo.Delete(AEntity);

    if AWithCommit and Self.UoW.InTransaction and (LStartedTx or AWithBegin) then
      Self.UoW.Commit;
  except
    if LStartedTx and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TStkTransactionService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TStkTransactionService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TStkTransaction>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TStkTransactionService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TStkTransaction;
begin
  Result := FRepo.FindById(AId, ALock);
end;

procedure TStkTransactionService.Add(AEntity: TStkTransaction);
begin
  FRepo.Add(AEntity);
end;

procedure TStkTransactionService.Update(AEntity: TStkTransaction);
begin
  FRepo.Update(AEntity);
end;

procedure TStkTransactionService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
