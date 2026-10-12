unit FinChequeNote.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  FinChequeNote.Repository, FinChequeNote, FinChequeNote.Exception, FinChequeNoteTransaction, FinChequeNoteTransaction.Repository;

type
  TFinChequeNoteService = class(TCrudService<TFinChequeNote>)
  private
    FRepo: IRepository<TFinChequeNote>;
    FTxRepo: IRepository<TFinChequeNoteTransaction>;

    procedure DoAdd(AEntity: TFinChequeNote);
    procedure DoUpdate(AEntity: TFinChequeNote);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    procedure Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
    procedure ValidateUnique(AEntity: TFinChequeNote; AOperation: TCrudOperation);
    procedure SyncOpeningTransaction(AEntity: TFinChequeNote; AInsert: Boolean);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TFinChequeNote; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TFinChequeNote>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TFinChequeNote; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TFinChequeNote; override;

    procedure Add(AEntity: TFinChequeNote); override;
    procedure Update(AEntity: TFinChequeNote); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinChequeNote; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinChequeNote>; override;
    procedure BusinessInsert(AEntity: TFinChequeNote; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TFinChequeNote; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TFinChequeNote; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, FinLookup;

constructor TFinChequeNoteService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TFinChequeNote, TFinChequeNoteRepository>;
  FTxRepo := Self.UoW.GetRepository<TFinChequeNoteTransaction, TFinChequeNoteTransactionRepository>;
  Self.PermissionCode := PERMISSION_FIN_CHEQUE_NOTE;
end;

destructor TFinChequeNoteService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TFinChequeNoteService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

// Alan adı + mesaj
procedure TFinChequeNoteService.Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(AMsgKey, AMsgDefault));
end;

procedure TFinChequeNoteService.ValidateUnique(AEntity: TFinChequeNote; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TFinChequeNote;
begin
  if TFinChequeNoteRepository(FRepo).SerialExists(AEntity.DocKind, AEntity.Direction, AEntity.AccBankId,
    AEntity.SerialNo, AEntity.Id) then
    raise EFinChequeNoteExceptionSerialUnique.Create;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('portfolio_no', '=', TValue.From<string>(AEntity.PortfolioNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EFinChequeNoteExceptionPortfolioNoUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

// Açılış hareketi (portföye giriş / verildi) belgeyle birlikte yazılır; başka hareket yoksa belgeyle senkron tutulur
procedure TFinChequeNoteService.SyncOpeningTransaction(AEntity: TFinChequeNote; AInsert: Boolean);
var
  LFilter: TFilterCriteria;
  LList: TList<TFinChequeNoteTransaction>;
  LTx: TFinChequeNoteTransaction;
begin
  if AInsert then
  begin
    LTx := TFinChequeNoteTransaction.Create;
    try
      LTx.FinChequeNoteId := AEntity.Id;
      LTx.TransactionDate := AEntity.IssueDate;
      LTx.TransactionType := TFinLookup.InitialStatus(AEntity.Direction);
      LTx.AccAccountId := AEntity.AccAccountId;
      FTxRepo.Add(LTx);
    finally
      LTx.Free;
    end;
    Exit;
  end;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('fin_cheque_note_id', '=', TValue.From<Int64>(AEntity.Id)));
    LList := FTxRepo.Find(LFilter, False);
    try
      if LList.Count = 1 then
      begin
        LTx := LList[0];
        LTx.TransactionDate := AEntity.IssueDate;
        LTx.TransactionType := TFinLookup.InitialStatus(AEntity.Direction);
        LTx.AccAccountId := AEntity.AccAccountId;
        LTx.AccBankId := 0;
        FTxRepo.Update(LTx);
      end;
    finally
      LList.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TFinChequeNoteService.ValidateBusinessRules(AEntity: TFinChequeNote; AOperation: TCrudOperation);
var
  LOld: TFinChequeNote;
  LTxCount: Integer;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.PortfolioNo := AnsiUpperCase(Trim(AEntity.PortfolioNo));
    AEntity.SerialNo := AnsiUpperCase(Trim(AEntity.SerialNo));
    AEntity.DrawerName := Trim(AEntity.DrawerName);
    AEntity.DrawerTaxNo := Trim(AEntity.DrawerTaxNo);
    AEntity.IssuePlace := Trim(AEntity.IssuePlace);
    AEntity.BankAccountNo := Trim(AEntity.BankAccountNo);
    AEntity.GuarantorName := Trim(AEntity.GuarantorName);
    AEntity.Currency := Trim(AEntity.Currency);

    if not TFinLookup.IsValid(flkDocKind, AEntity.DocKind) then
      FailRequired(TLangKeys.TFinChequeNote.ColDocKind, 'Document Kind');
    if not TFinLookup.IsValid(flkDirection, AEntity.Direction) then
      FailRequired(TLangKeys.TFinChequeNote.ColDirection, 'Direction');
    if AEntity.AccAccountId <= 0 then
      FailRequired(TLangKeys.TFinChequeNote.ColAccAccountId, 'Account');
    if AEntity.SerialNo = '' then
      FailRequired(TLangKeys.TFinChequeNote.ColSerialNo, 'Serial No');
    if AEntity.IssueDate <= 0 then
      FailRequired(TLangKeys.TFinChequeNote.ColIssueDate, 'Issue Date');
    if AEntity.DueDate <= 0 then
      FailRequired(TLangKeys.TFinChequeNote.ColDueDate, 'Due Date');
    if AEntity.Amount <= 0 then
      Fail(TLangKeys.TFinChequeNote.ColAmount, 'Amount', TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero');
    if AEntity.DueDate < AEntity.IssueDate then
      raise EFinChequeNoteExceptionDueBeforeIssue.Create;
    if (AEntity.DocKind = FIN_DOC_CHEQUE) and (AEntity.AccBankId <= 0) then
      raise EFinChequeNoteExceptionBankRequired.Create;
    if AEntity.AccBankId <= 0 then
      AEntity.AccBankBranchId := 0;
    if (AEntity.AccBankBranchId > 0) and
      not TFinChequeNoteRepository(FRepo).BranchBelongsToBank(AEntity.AccBankBranchId, AEntity.AccBankId) then
      raise EFinChequeNoteExceptionBranchBank.Create;
    if AEntity.Currency = '' then
      AEntity.Currency := TFinChequeNoteRepository(FRepo).GetDefaultCurrency;

    if AOperation = coInsert then
    begin
      // Durum yalnızca hareketlerle değişir
      AEntity.Status := TFinLookup.InitialStatus(AEntity.Direction);
      if AEntity.PortfolioNo = '' then
        AEntity.PortfolioNo := TFinChequeNoteRepository(FRepo).NextPortfolioNo(
          TFinLookup.PortfolioPrefix(AEntity.DocKind, AEntity.Direction));
    end
    else
    begin
      LOld := FRepo.FindById(AEntity.Id, False);
      try
        if not Assigned(LOld) then
          raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
        AEntity.Status := LOld.Status;
        if AEntity.PortfolioNo = '' then
          AEntity.PortfolioNo := LOld.PortfolioNo;
        LTxCount := TFinChequeNoteRepository(FRepo).TransactionCount(AEntity.Id);
        if (LTxCount > 1) and ((LOld.DocKind <> AEntity.DocKind) or (LOld.Direction <> AEntity.Direction) or
          (LOld.AccAccountId <> AEntity.AccAccountId)) then
          raise EFinChequeNoteExceptionKeyFieldsLocked.Create;
      finally
        LOld.Free;
      end;
    end;

    ValidateUnique(AEntity, AOperation);
  end
  else if AOperation = coDelete then
  begin
    if TFinChequeNoteRepository(FRepo).TransactionCount(AEntity.Id) > 1 then
      raise EFinChequeNoteExceptionHasTransactions.Create;
  end;
end;

procedure TFinChequeNoteService.DoAdd(AEntity: TFinChequeNote);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
  SyncOpeningTransaction(AEntity, True);
end;

procedure TFinChequeNoteService.DoUpdate(AEntity: TFinChequeNote);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  SyncOpeningTransaction(AEntity, False);
end;

procedure TFinChequeNoteService.DoDelete(AId: Int64);
var
  LEntity: TFinChequeNote;
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

function TFinChequeNoteService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TFinChequeNote>;
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

function TFinChequeNoteService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TFinChequeNote;
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

procedure TFinChequeNoteService.BusinessInsert(AEntity: TFinChequeNote; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinChequeNoteService.BusinessUpdate(AEntity: TFinChequeNote; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TFinChequeNoteService.BusinessDelete(AEntity: TFinChequeNote; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TFinChequeNoteService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TFinChequeNoteService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TFinChequeNote>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TFinChequeNoteService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TFinChequeNote;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TFinChequeNoteService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TFinChequeNote;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TFinChequeNoteService.Add(AEntity: TFinChequeNote);
begin
  DoAdd(AEntity);
end;

procedure TFinChequeNoteService.Update(AEntity: TFinChequeNote);
begin
  DoUpdate(AEntity);
end;

procedure TFinChequeNoteService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
