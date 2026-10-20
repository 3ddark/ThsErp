unit SysDecimalPlace.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysDecimalPlace.Repository, SysDecimalPlace, SysDecimalPlace.Exception;

type
  TSysDecimalPlaceService = class(TCrudService<TSysDecimalPlace>)
  private
    FRepo: IRepository<TSysDecimalPlace>;

    procedure DoAdd(AEntity: TSysDecimalPlace);
    procedure DoUpdate(AEntity: TSysDecimalPlace);
    procedure DoDelete(AId: Int64);

    procedure ValidateInsert(AEntity: TSysDecimalPlace);
    procedure ValidateUpdate(AEntity: TSysDecimalPlace);
    procedure ValidateDelete(AEntity: TSysDecimalPlace);
    procedure ValidateMustContainOneRecord(AEntity: TSysDecimalPlace; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysDecimalPlace; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysDecimalPlace>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysDecimalPlace; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysDecimalPlace; override;

    procedure Add(AEntity: TSysDecimalPlace); override;
    procedure Update(AEntity: TSysDecimalPlace); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysDecimalPlace; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysDecimalPlace>; override;
    procedure BusinessInsert(AEntity: TSysDecimalPlace; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysDecimalPlace; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysDecimalPlace; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, SysDecimalPlace.Cache;

constructor TSysDecimalPlaceService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysDecimalPlace, TSysDecimalPlaceRepository>;
  Self.PermissionCode := PERMISSION_SYS_DECIMAL_PLACE;
end;

destructor TSysDecimalPlaceService.Destroy;
begin
  inherited;
end;

// Saklanabilen hane: miktar / fiyat / stok miktarı / kur en çok 4 (Currency), tutar en çok 2 (numeric(18,2))
procedure CheckDigits(AValue, AMax: Integer; const AKey, ADefault: string);
begin
  if (AValue < 0) or (AValue > AMax) then
    raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSysDecimalPlace.Range,
      '%s must be between 0 and %d.'), [TLocalizationManager.Translate(AKey, ADefault), AMax]));
end;

procedure ValidateDigits(AEntity: TSysDecimalPlace);
begin
  CheckDigits(AEntity.Quantity, TDecimalPlaces.MAX_DIGITS, TLangKeys.TSysDecimalPlace.ColQuantity, 'Quantity Decimals');
  CheckDigits(AEntity.Price, TDecimalPlaces.MAX_DIGITS, TLangKeys.TSysDecimalPlace.ColPrice, 'Price Decimals');
  CheckDigits(AEntity.Total, TDecimalPlaces.MAX_TOTAL_DIGITS, TLangKeys.TSysDecimalPlace.ColTotal, 'Total Decimals');
  CheckDigits(AEntity.StockQuantity, TDecimalPlaces.MAX_DIGITS, TLangKeys.TSysDecimalPlace.ColStockQuantity, 'Stock Decimals');
  CheckDigits(AEntity.ExchangeRate, TDecimalPlaces.MAX_DIGITS, TLangKeys.TSysDecimalPlace.ColExchangeRate, 'Exchange Rate Decimals');
end;

procedure TSysDecimalPlaceService.ValidateInsert(AEntity: TSysDecimalPlace);
begin
  ValidateMustContainOneRecord(AEntity, coInsert);
  ValidateDigits(AEntity);
end;

procedure TSysDecimalPlaceService.ValidateUpdate(AEntity: TSysDecimalPlace);
begin
  ValidateMustContainOneRecord(AEntity, coUpdate);
  ValidateDigits(AEntity);
end;

procedure TSysDecimalPlaceService.ValidateDelete(AEntity: TSysDecimalPlace);
begin
  ValidateMustContainOneRecord(AEntity, coDelete);
end;

procedure TSysDecimalPlaceService.ValidateMustContainOneRecord(AEntity: TSysDecimalPlace; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TSysDecimalPlace;
begin
  LFilter := TFilterCriteria.Create;
  try
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)))
    else if AOperation = coDelete then
      raise ESysDecimalPlaceExceptionMustContainOnlyOneRecord.Create;

    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise ESysDecimalPlaceExceptionMustContainOnlyOneRecord.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TSysDecimalPlaceService.DoAdd(AEntity: TSysDecimalPlace);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSysDecimalPlaceService.DoUpdate(AEntity: TSysDecimalPlace);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TSysDecimalPlaceService.DoDelete(AId: Int64);
var
  LEntity: TSysDecimalPlace;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId], 'Record not found: %d'));

    ValidateAll(LEntity, coDelete);
    FRepo.Delete(LEntity);
  finally
    LEntity.Free;
  end;
end;

function TSysDecimalPlaceService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysDecimalPlace>;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.Find(AFilter, ALock);
  except
    if Self.UoW.InTransaction then
    begin
      Self.UoW.Rollback;
    end;
    raise;
  end;
end;

function TSysDecimalPlaceService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysDecimalPlace;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.FindById(AId, ALock);
  except
    if Self.UoW.InTransaction then
    begin
      Self.UoW.Rollback;
    end;
    raise;
  end;
end;

procedure TSysDecimalPlaceService.BusinessInsert(AEntity: TSysDecimalPlace; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoAdd(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Uow.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

procedure TSysDecimalPlaceService.BusinessUpdate(AEntity: TSysDecimalPlace; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoUpdate(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

procedure TSysDecimalPlaceService.BusinessDelete(AEntity: TSysDecimalPlace; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptDelete, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoDelete(AEntity.Id);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

function TSysDecimalPlaceService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysDecimalPlaceService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysDecimalPlace>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysDecimalPlaceService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysDecimalPlace;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysDecimalPlaceService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysDecimalPlace;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

// Hane ayarları önbellekte: bir sonraki kullanımda yeniden okunur
procedure TSysDecimalPlaceService.Add(AEntity: TSysDecimalPlace);
begin
  DoAdd(AEntity);
  TDecimalPlaces.Invalidate;
end;

procedure TSysDecimalPlaceService.Update(AEntity: TSysDecimalPlace);
begin
  DoUpdate(AEntity);
  TDecimalPlaces.Invalidate;
end;

procedure TSysDecimalPlaceService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

procedure TSysDecimalPlaceService.ValidateBusinessRules(AEntity: TSysDecimalPlace; AOperation: TCrudOperation);
begin
  case AOperation of
    coInsert: ValidateInsert(AEntity);
    coUpdate: ValidateUpdate(AEntity);
    coDelete: ValidateDelete(AEntity);
  end;
end;

end.
