unit FinPosTerminal.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  FinPosTerminal.Repository, FinPosTerminal, FinPosTerminal.Exception;

type
  TFinPosTerminalService = class(TCrudService<TFinPosTerminal>)
  private
    FRepo: IRepository<TFinPosTerminal>;

    procedure DoAdd(AEntity: TFinPosTerminal);
    procedure DoUpdate(AEntity: TFinPosTerminal);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TFinPosTerminal; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TFinPosTerminal>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TFinPosTerminal; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TFinPosTerminal; override;

    procedure Add(AEntity: TFinPosTerminal); override;
    procedure Update(AEntity: TFinPosTerminal); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinPosTerminal; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinPosTerminal>; override;
    procedure BusinessInsert(AEntity: TFinPosTerminal; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TFinPosTerminal; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TFinPosTerminal; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, FinLookup;

constructor TFinPosTerminalService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TFinPosTerminal, TFinPosTerminalRepository>;
  Self.PermissionCode := PERMISSION_FIN_POS_TERMINAL;
end;

destructor TFinPosTerminalService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TFinPosTerminalService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TFinPosTerminalService.ValidateBusinessRules(AEntity: TFinPosTerminal; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TFinPosTerminal;
begin
  if AOperation = coDelete then
  begin
    if TFinPosTerminalRepository(FRepo).TransactionCount(AEntity.Id) > 0 then
      raise EFinPosTerminalExceptionHasTransactions.Create;
    Exit;
  end;

  AEntity.PosName := Trim(AEntity.PosName);
  AEntity.TerminalNo := Trim(AEntity.TerminalNo);
  AEntity.Currency := Trim(AEntity.Currency);
  AEntity.AccAccountCode := Trim(AEntity.AccAccountCode);

  if AEntity.AccBankId <= 0 then
    FailRequired(TLangKeys.TFinPosTerminal.ColAccBankId, 'Bank');
  if (AEntity.CommissionRate < 0) or (AEntity.CommissionRate > 100) then
    raise EFinPosTerminalExceptionRateRange.Create;
  if (AEntity.BlockedDays < 0) or (AEntity.BlockedDays > 365) then
    raise EFinPosTerminalExceptionBlockedDaysRange.Create;
  if AEntity.Currency = '' then
    AEntity.Currency := TFinPosTerminalRepository(FRepo).GetDefaultCurrency;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('pos_name', '=', TValue.From<string>(AEntity.PosName)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EFinPosTerminalExceptionNameUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TFinPosTerminalService.DoAdd(AEntity: TFinPosTerminal);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TFinPosTerminalService.DoUpdate(AEntity: TFinPosTerminal);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TFinPosTerminalService.DoDelete(AId: Int64);
var
  LEntity: TFinPosTerminal;
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

function TFinPosTerminalService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinPosTerminal>;
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

function TFinPosTerminalService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinPosTerminal;
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

procedure TFinPosTerminalService.BusinessInsert(AEntity: TFinPosTerminal; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinPosTerminalService.BusinessUpdate(AEntity: TFinPosTerminal; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinPosTerminalService.BusinessDelete(AEntity: TFinPosTerminal; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TFinPosTerminalService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TFinPosTerminalService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TFinPosTerminal>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TFinPosTerminalService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TFinPosTerminal;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TFinPosTerminalService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TFinPosTerminal;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TFinPosTerminalService.Add(AEntity: TFinPosTerminal);
begin
  DoAdd(AEntity);
end;

procedure TFinPosTerminalService.Update(AEntity: TFinPosTerminal);
begin
  DoUpdate(AEntity);
end;

procedure TFinPosTerminalService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
