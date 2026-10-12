unit FinChequeNoteTransaction.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  FinChequeNoteTransaction.Repository, FinChequeNoteTransaction, FinChequeNoteTransaction.Exception, FinChequeNote, FinChequeNote.Repository;

type
  TFinChequeNoteTransactionService = class(TCrudService<TFinChequeNoteTransaction>)
  private
    FRepo: IRepository<TFinChequeNoteTransaction>;
    FNoteRepo: IRepository<TFinChequeNote>;

    procedure DoAdd(AEntity: TFinChequeNoteTransaction);
    procedure DoUpdate(AEntity: TFinChequeNoteTransaction);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    procedure ValidateTransition(AEntity: TFinChequeNoteTransaction; ANote: TFinChequeNote; APrevious: TFinChequeNoteTransaction);
    procedure RefreshNoteStatus(ANoteId: Int64);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TFinChequeNoteTransaction; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TFinChequeNoteTransaction>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TFinChequeNoteTransaction; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TFinChequeNoteTransaction; override;

    procedure Add(AEntity: TFinChequeNoteTransaction); override;
    procedure Update(AEntity: TFinChequeNoteTransaction); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinChequeNoteTransaction; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinChequeNoteTransaction>; override;
    procedure BusinessInsert(AEntity: TFinChequeNoteTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TFinChequeNoteTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TFinChequeNoteTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, FinLookup;

constructor TFinChequeNoteTransactionService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TFinChequeNoteTransaction, TFinChequeNoteTransactionRepository>;
  FNoteRepo := Self.UoW.GetRepository<TFinChequeNote, TFinChequeNoteRepository>;
  Self.PermissionCode := PERMISSION_FIN_CHEQUE_NOTE;
end;

destructor TFinChequeNoteTransactionService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TFinChequeNoteTransactionService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


// Önceki harekete (yoksa açılış) göre izin verilen durum geçişi + tarih sırası
procedure TFinChequeNoteTransactionService.ValidateTransition(AEntity: TFinChequeNoteTransaction; ANote: TFinChequeNote;
  APrevious: TFinChequeNoteTransaction);
var
  LFrom: SmallInt;
begin
  if Assigned(APrevious) then
    LFrom := APrevious.TransactionType
  else
    LFrom := 0;

  if not TFinLookup.CanTransit(ANote.Direction, LFrom, AEntity.TransactionType) then
    raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.InvalidTransition,
      '"%s" is not allowed while the document is "%s".'),
      [TFinLookup.Text(flkChequeStatus, AEntity.TransactionType), TFinLookup.Text(flkChequeStatus, LFrom)]));

  if Assigned(APrevious) and (AEntity.TransactionDate < APrevious.TransactionDate) then
    raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.DateBeforePrevious,
      'Transaction date cannot be earlier than the previous transaction (%s).'), [DateToStr(APrevious.TransactionDate)]));
end;

procedure TFinChequeNoteTransactionService.RefreshNoteStatus(ANoteId: Int64);
begin
  TFinChequeNoteTransactionRepository(FRepo).RefreshNoteStatus(ANoteId);
end;

procedure TFinChequeNoteTransactionService.ValidateBusinessRules(AEntity: TFinChequeNoteTransaction; AOperation: TCrudOperation);
var
  LRepo: TFinChequeNoteTransactionRepository;
  LNote: TFinChequeNote;
  LOld, LLast, LPrev: TFinChequeNoteTransaction;
begin
  LRepo := TFinChequeNoteTransactionRepository(FRepo);

  if AOperation = coDelete then
  begin
    LLast := LRepo.FindLastOfNote(AEntity.FinChequeNoteId, 0);
    try
      if Assigned(LLast) and (LLast.Id <> AEntity.Id) then
        raise EFinChequeNoteTransactionExceptionOnlyLast.Create;
    finally
      LLast.Free;
    end;
    LPrev := LRepo.FindLastOfNote(AEntity.FinChequeNoteId, AEntity.Id);
    try
      if not Assigned(LPrev) then
        raise EFinChequeNoteTransactionExceptionOpeningLocked.Create;
    finally
      LPrev.Free;
    end;
    Exit;
  end;

  AEntity.Description := Trim(AEntity.Description);
  if AEntity.FinChequeNoteId <= 0 then
    FailRequired(TLangKeys.TFinChequeNoteTransaction.ColFinChequeNoteId, 'Cheque / Note');
  if AEntity.TransactionDate <= 0 then
    FailRequired(TLangKeys.TFinChequeNoteTransaction.ColTransactionDate, 'Date');
  if not TFinLookup.IsValid(flkChequeStatus, AEntity.TransactionType) then
    FailRequired(TLangKeys.TFinChequeNoteTransaction.ColTransactionType, 'Transaction Type');

  LNote := FNoteRepo.FindById(AEntity.FinChequeNoteId, False);
  try
    if not Assigned(LNote) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.FinChequeNoteId]));

    // İade: cari seçilmezse belgenin carisi
    if (AEntity.TransactionType = FIN_STATUS_RETURNED) and (AEntity.AccAccountId <= 0) then
      AEntity.AccAccountId := LNote.AccAccountId;
    if (AEntity.TransactionType in [FIN_STATUS_ENDORSED, FIN_STATUS_ISSUED]) and (AEntity.AccAccountId <= 0) then
      FailRequired(TLangKeys.TFinChequeNoteTransaction.ColAccAccountId, 'Account');
    if (AEntity.TransactionType in [FIN_STATUS_AT_BANK_COLLECTION, FIN_STATUS_AT_BANK_COLLATERAL]) and (AEntity.AccBankId <= 0) then
      FailRequired(TLangKeys.TFinChequeNoteTransaction.ColAccBankId, 'Bank');

    if AOperation = coInsert then
    begin
      LPrev := LRepo.FindLastOfNote(AEntity.FinChequeNoteId, 0);
      try
        ValidateTransition(AEntity, LNote, LPrev);
      finally
        LPrev.Free;
      end;
    end
    else
    begin
      LOld := FRepo.FindById(AEntity.Id, False);
      try
        if not Assigned(LOld) then
          raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
        if LOld.FinChequeNoteId <> AEntity.FinChequeNoteId then
          raise EFinChequeNoteTransactionExceptionNoteChanged.Create;
      finally
        LOld.Free;
      end;

      LLast := LRepo.FindLastOfNote(AEntity.FinChequeNoteId, 0);
      try
        if Assigned(LLast) and (LLast.Id <> AEntity.Id) then
          raise EFinChequeNoteTransactionExceptionOnlyLast.Create;
      finally
        LLast.Free;
      end;

      LPrev := LRepo.FindLastOfNote(AEntity.FinChequeNoteId, AEntity.Id);
      try
        ValidateTransition(AEntity, LNote, LPrev);
      finally
        LPrev.Free;
      end;
    end;
  finally
    LNote.Free;
  end;
end;

procedure TFinChequeNoteTransactionService.DoAdd(AEntity: TFinChequeNoteTransaction);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
  RefreshNoteStatus(AEntity.FinChequeNoteId);
end;

procedure TFinChequeNoteTransactionService.DoUpdate(AEntity: TFinChequeNoteTransaction);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  RefreshNoteStatus(AEntity.FinChequeNoteId);
end;

procedure TFinChequeNoteTransactionService.DoDelete(AId: Int64);
var
  LEntity: TFinChequeNoteTransaction;
  LNoteId: Int64;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    LNoteId := LEntity.FinChequeNoteId;
    FRepo.Delete(LEntity);
    RefreshNoteStatus(LNoteId);
  finally
    LEntity.Free;
  end;
end;

function TFinChequeNoteTransactionService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinChequeNoteTransaction>;
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

function TFinChequeNoteTransactionService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinChequeNoteTransaction;
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

procedure TFinChequeNoteTransactionService.BusinessInsert(AEntity: TFinChequeNoteTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinChequeNoteTransactionService.BusinessUpdate(AEntity: TFinChequeNoteTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinChequeNoteTransactionService.BusinessDelete(AEntity: TFinChequeNoteTransaction; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TFinChequeNoteTransactionService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TFinChequeNoteTransactionService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TFinChequeNoteTransaction>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TFinChequeNoteTransactionService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TFinChequeNoteTransaction;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TFinChequeNoteTransactionService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TFinChequeNoteTransaction;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TFinChequeNoteTransactionService.Add(AEntity: TFinChequeNoteTransaction);
begin
  DoAdd(AEntity);
end;

procedure TFinChequeNoteTransactionService.Update(AEntity: TFinChequeNoteTransaction);
begin
  DoUpdate(AEntity);
end;

procedure TFinChequeNoteTransactionService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
