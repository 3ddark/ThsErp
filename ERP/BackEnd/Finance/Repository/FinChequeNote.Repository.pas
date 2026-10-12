unit FinChequeNote.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, FinChequeNote;

type
  TFinChequeNoteRepository = class(TRepository<TFinChequeNote>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TFinChequeNote; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TFinChequeNote; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TFinChequeNote; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TFinChequeNote>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TFinChequeNote; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TFinChequeNote; override;

    procedure DoAdd(AModel: TFinChequeNote); override;
    procedure DoAddBatch(AModels: TArray<TFinChequeNote>); override;

    procedure DoUpdate(AModel: TFinChequeNote); override;
    procedure DoUpdateBatch(AModels: TArray<TFinChequeNote>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TFinChequeNote); override;
    procedure DoDeleteBatch(AModels: TArray<TFinChequeNote>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function NextPortfolioNo(const APrefix: string): string;
    function SerialExists(ADocKind, ADirection: SmallInt; ABankId: Int64; const ASerialNo: string; AExcludeId: Int64): Boolean;
    function BranchBelongsToBank(ABranchId, ABankId: Int64): Boolean;
    function TransactionCount(ANoteId: Int64): Integer;
    function GetDefaultCurrency: string;
  end;

implementation

constructor TFinChequeNoteRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TFinChequeNoteRepository.NextPortfolioNo(const APrefix: string): string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(MAX(CAST(substr(portfolio_no, length(:prefix) + 1) AS bigint)), 0) + 1 AS next_no ' +
                  '  FROM public.fin_cheque_note ' +
                  ' WHERE portfolio_no ~ (''^'' || :prefix || ''[0-9]+$'')';
    Q.ParamByName('prefix').DataType := ftWideString;
    Q.ParamByName('prefix').AsWideString := APrefix;
    LogQuery(Q, 'NextPortfolioNo');
    Q.Open;
    Result := APrefix + Format('%.6d', [Q.FieldByName('next_no').AsLargeInt]);
  finally
    Q.Free;
  end;
end;

function TFinChequeNoteRepository.SerialExists(ADocKind, ADirection: SmallInt; ABankId: Int64; const ASerialNo: string; AExcludeId: Int64): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT 1 FROM public.fin_cheque_note ' +
                  ' WHERE doc_kind = :doc_kind AND direction = :direction ' +
                  '   AND COALESCE(acc_bank_id, 0) = :acc_bank_id AND serial_no = :serial_no AND id <> :id LIMIT 1';
    Q.ParamByName('doc_kind').AsSmallInt := ADocKind;
    Q.ParamByName('direction').AsSmallInt := ADirection;
    Q.ParamByName('acc_bank_id').AsLargeInt := ABankId;
    Q.ParamByName('serial_no').DataType := ftWideString;
    Q.ParamByName('serial_no').AsWideString := ASerialNo;
    Q.ParamByName('id').AsLargeInt := AExcludeId;
    LogQuery(Q, 'SerialExists');
    Q.Open;
    Result := not Q.IsEmpty;
  finally
    Q.Free;
  end;
end;

function TFinChequeNoteRepository.BranchBelongsToBank(ABranchId, ABankId: Int64): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT 1 FROM public.acc_bank_branch WHERE id = :id AND acc_bank_id = :acc_bank_id';
    Q.ParamByName('id').AsLargeInt := ABranchId;
    Q.ParamByName('acc_bank_id').AsLargeInt := ABankId;
    LogQuery(Q, 'BranchBelongsToBank');
    Q.Open;
    Result := not Q.IsEmpty;
  finally
    Q.Free;
  end;
end;

function TFinChequeNoteRepository.TransactionCount(ANoteId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) AS cnt FROM public.fin_cheque_note_transaction WHERE fin_cheque_note_id = :id';
    Q.ParamByName('id').AsLargeInt := ANoteId;
    LogQuery(Q, 'TransactionCount');
    Q.Open;
    Result := Q.FieldByName('cnt').AsInteger;
  finally
    Q.Free;
  end;
end;

function TFinChequeNoteRepository.GetDefaultCurrency: string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT public.fn_default_currency() AS currency';
    LogQuery(Q, 'GetDefaultCurrency');
    Q.Open;
    Result := Q.FieldByName('currency').AsString;
  finally
    Q.Free;
  end;
end;

function TFinChequeNoteRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TFinChequeNote) +
            ' (doc_kind, direction, portfolio_no, serial_no, issue_date, due_date, amount, currency, acc_account_id, drawer_name, drawer_tax_no, issue_place, acc_bank_id, acc_bank_branch_id, bank_account_no, guarantor_name, fin_company_bank_account_id, status, notes) ' +
            ' VALUES (:doc_kind, :direction, :portfolio_no, :serial_no, :issue_date, :due_date, :amount, :currency, :acc_account_id, :drawer_name, :drawer_tax_no, :issue_place, :acc_bank_id, :acc_bank_branch_id, :bank_account_no, :guarantor_name, :fin_company_bank_account_id, :status, :notes)';
end;

function TFinChequeNoteRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TFinChequeNote) +
            ' SET doc_kind = :doc_kind, direction = :direction, portfolio_no = :portfolio_no, serial_no = :serial_no, issue_date = :issue_date, due_date = :due_date, amount = :amount, currency = :currency, acc_account_id = :acc_account_id, drawer_name = :drawer_name, drawer_tax_no = :drawer_tax_no, issue_place = :issue_place, acc_bank_id = :acc_bank_id, acc_bank_branch_id = :acc_bank_branch_id, bank_account_no = :bank_account_no, guarantor_name = :guarantor_name, fin_company_bank_account_id = :fin_company_bank_account_id, status = :status, notes = :notes ' +
            ' WHERE id = :id';
end;

function TFinChequeNoteRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TFinChequeNote) + ' WHERE';
end;

procedure TFinChequeNoteRepository.SetInsertParams(Q: TFDQuery; AModel: TFinChequeNote; AIndex: Integer);

  procedure SetDate(const AName: string; AValue: TDate);
  begin
    Q.ParamByName(AName).DataType := ftDate;
    if AValue > 0 then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsDate := AValue
      else
        Q.ParamByName(AName).AsDates[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('doc_kind').AsSmallInt := AModel.DocKind;
    Q.ParamByName('direction').AsSmallInt := AModel.Direction;
    Q.ParamByName('portfolio_no').AsWideString := AModel.PortfolioNo;
    Q.ParamByName('serial_no').AsWideString := AModel.SerialNo;
    Q.ParamByName('amount').AsBCD := AModel.Amount;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('drawer_name').AsWideString := AModel.DrawerName;
    Q.ParamByName('drawer_tax_no').AsWideString := AModel.DrawerTaxNo;
    Q.ParamByName('issue_place').AsWideString := AModel.IssuePlace;
    Q.ParamByName('bank_account_no').AsWideString := AModel.BankAccountNo;
    Q.ParamByName('guarantor_name').AsWideString := AModel.GuarantorName;
    Q.ParamByName('status').AsSmallInt := AModel.Status;
    Q.ParamByName('notes').AsWideString := AModel.Notes;
  end
  else
  begin
    Q.ParamByName('doc_kind').AsSmallInts[AIndex] := AModel.DocKind;
    Q.ParamByName('direction').AsSmallInts[AIndex] := AModel.Direction;
    Q.ParamByName('portfolio_no').AsWideStrings[AIndex] := AModel.PortfolioNo;
    Q.ParamByName('serial_no').AsWideStrings[AIndex] := AModel.SerialNo;
    Q.ParamByName('amount').AsBCDs[AIndex] := AModel.Amount;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('drawer_name').AsWideStrings[AIndex] := AModel.DrawerName;
    Q.ParamByName('drawer_tax_no').AsWideStrings[AIndex] := AModel.DrawerTaxNo;
    Q.ParamByName('issue_place').AsWideStrings[AIndex] := AModel.IssuePlace;
    Q.ParamByName('bank_account_no').AsWideStrings[AIndex] := AModel.BankAccountNo;
    Q.ParamByName('guarantor_name').AsWideStrings[AIndex] := AModel.GuarantorName;
    Q.ParamByName('status').AsSmallInts[AIndex] := AModel.Status;
    Q.ParamByName('notes').AsWideStrings[AIndex] := AModel.Notes;
  end;

  SetDate('issue_date', AModel.IssueDate);
  SetDate('due_date', AModel.DueDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetNullableParam(Q.ParamByName('acc_bank_id'), ftLargeint, AModel.AccBankId, AIndex);
  SetNullableParam(Q.ParamByName('acc_bank_branch_id'), ftLargeint, AModel.AccBankBranchId, AIndex);
  SetNullableParam(Q.ParamByName('fin_company_bank_account_id'), ftLargeint, AModel.FinCompanyBankAccountId, AIndex);
end;

procedure TFinChequeNoteRepository.SetUpdateParams(Q: TFDQuery; AModel: TFinChequeNote; AIndex: Integer);

  procedure SetDate(const AName: string; AValue: TDate);
  begin
    Q.ParamByName(AName).DataType := ftDate;
    if AValue > 0 then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsDate := AValue
      else
        Q.ParamByName(AName).AsDates[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('doc_kind').AsSmallInt := AModel.DocKind;
    Q.ParamByName('direction').AsSmallInt := AModel.Direction;
    Q.ParamByName('portfolio_no').AsWideString := AModel.PortfolioNo;
    Q.ParamByName('serial_no').AsWideString := AModel.SerialNo;
    Q.ParamByName('amount').AsBCD := AModel.Amount;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('drawer_name').AsWideString := AModel.DrawerName;
    Q.ParamByName('drawer_tax_no').AsWideString := AModel.DrawerTaxNo;
    Q.ParamByName('issue_place').AsWideString := AModel.IssuePlace;
    Q.ParamByName('bank_account_no').AsWideString := AModel.BankAccountNo;
    Q.ParamByName('guarantor_name').AsWideString := AModel.GuarantorName;
    Q.ParamByName('status').AsSmallInt := AModel.Status;
    Q.ParamByName('notes').AsWideString := AModel.Notes;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('doc_kind').AsSmallInts[AIndex] := AModel.DocKind;
    Q.ParamByName('direction').AsSmallInts[AIndex] := AModel.Direction;
    Q.ParamByName('portfolio_no').AsWideStrings[AIndex] := AModel.PortfolioNo;
    Q.ParamByName('serial_no').AsWideStrings[AIndex] := AModel.SerialNo;
    Q.ParamByName('amount').AsBCDs[AIndex] := AModel.Amount;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('drawer_name').AsWideStrings[AIndex] := AModel.DrawerName;
    Q.ParamByName('drawer_tax_no').AsWideStrings[AIndex] := AModel.DrawerTaxNo;
    Q.ParamByName('issue_place').AsWideStrings[AIndex] := AModel.IssuePlace;
    Q.ParamByName('bank_account_no').AsWideStrings[AIndex] := AModel.BankAccountNo;
    Q.ParamByName('guarantor_name').AsWideStrings[AIndex] := AModel.GuarantorName;
    Q.ParamByName('status').AsSmallInts[AIndex] := AModel.Status;
    Q.ParamByName('notes').AsWideStrings[AIndex] := AModel.Notes;
  end;

  SetDate('issue_date', AModel.IssueDate);
  SetDate('due_date', AModel.DueDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetNullableParam(Q.ParamByName('acc_bank_id'), ftLargeint, AModel.AccBankId, AIndex);
  SetNullableParam(Q.ParamByName('acc_bank_branch_id'), ftLargeint, AModel.AccBankBranchId, AIndex);
  SetNullableParam(Q.ParamByName('fin_company_bank_account_id'), ftLargeint, AModel.FinCompanyBankAccountId, AIndex);
end;

function TFinChequeNoteRepository.MapFromQuery(Q: TFDQuery): TFinChequeNote;
begin
  Result := TFinChequeNote.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.DocKind := Q.FieldByName('doc_kind').AsInteger;
  Result.Direction := Q.FieldByName('direction').AsInteger;
  Result.PortfolioNo := Q.FieldByName('portfolio_no').AsString;
  Result.SerialNo := Q.FieldByName('serial_no').AsString;
  if Q.FieldByName('issue_date').IsNull then
    Result.IssueDate := 0
  else
    Result.IssueDate := Q.FieldByName('issue_date').AsDateTime;
  if Q.FieldByName('due_date').IsNull then
    Result.DueDate := 0
  else
    Result.DueDate := Q.FieldByName('due_date').AsDateTime;
  Result.Amount := Q.FieldByName('amount').AsCurrency;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  Result.DrawerName := Q.FieldByName('drawer_name').AsString;
  Result.DrawerTaxNo := Q.FieldByName('drawer_tax_no').AsString;
  Result.IssuePlace := Q.FieldByName('issue_place').AsString;
  Result.AccBankId := Q.FieldByName('acc_bank_id').AsLargeInt;
  Result.AccBankBranchId := Q.FieldByName('acc_bank_branch_id').AsLargeInt;
  Result.BankAccountNo := Q.FieldByName('bank_account_no').AsString;
  Result.GuarantorName := Q.FieldByName('guarantor_name').AsString;
  Result.FinCompanyBankAccountId := Q.FieldByName('fin_company_bank_account_id').AsLargeInt;
  Result.Status := Q.FieldByName('status').AsInteger;
  Result.Notes := Q.FieldByName('notes').AsString;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
  Result.BankName := Q.FieldByName('bank_name').AsString;
  Result.BranchName := Q.FieldByName('branch_name').AsString;
  Result.CurrentHolder := Q.FieldByName('current_holder').AsString;
  Result.CompanyBankIban := Q.FieldByName('company_bank_iban').AsString;
end;

function TFinChequeNoteRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TFinChequeNote) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TFinChequeNoteRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TFinChequeNote>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TFinChequeNote>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, False);

    if Assigned(AFilter) and (AFilter.Count > 0) then
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;

    LogQuery(Q, 'DoFind');
    Q.Open;
    while not Q.Eof do
    begin
      Result.Add(MapFromQuery(Q));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TFinChequeNoteRepository.DoFindById(AId: TValue; ALock: Boolean): TFinChequeNote;
var
  Q: TFDQuery;
  Criteria: TFilterCriteria;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  Criteria := TFilterCriteria.Create;
  try
    Q.Connection := Connection;

    Criteria.Add(TFilterCriterion.New('id', '=', AId));
    Q.SQL.Text := Self.PrepareSelectFromView(Criteria, ALock, True, False);

    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    LogQuery(Q, 'DoFindById');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TFinChequeNoteRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TFinChequeNote;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := nil;
  if not Assigned(AFilter) or (AFilter.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, True, False);

    for Criteria in AFilter do
      Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    LogQuery(Q, 'DoFindOne');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TFinChequeNoteRepository.DoAdd(AModel: TFinChequeNote);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql + ' RETURNING id';
    SetInsertParams(Q, AModel);
    ApplyNullPolicy(Q);
    LogQuery(Q, 'DoAdd');
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;
end;

procedure TFinChequeNoteRepository.DoAddBatch(AModels: TArray<TFinChequeNote>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      SetInsertParams(Q, AModels[I], I);

    ApplyNullPolicy(Q);

    LogQuery(Q, 'DoAddBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TFinChequeNoteRepository.DoUpdate(AModel: TFinChequeNote);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    SetUpdateParams(Q, AModel);
    ApplyNullPolicy(Q);
    LogQuery(Q, 'DoUpdate');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TFinChequeNoteRepository.DoUpdateBatch(AModels: TArray<TFinChequeNote>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      SetUpdateParams(Q, AModels[I], I);

    ApplyNullPolicy(Q);

    LogQuery(Q, 'DoUpdateBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TFinChequeNoteRepository.DoDelete(AID: TValue);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.ParamByName('id').AsLargeInt := AID.AsInt64;
    LogQuery(Q, 'DoDelete');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TFinChequeNoteRepository.DoDelete(AModel: TFinChequeNote);
begin
  Delete(AModel.Id);
end;

procedure TFinChequeNoteRepository.DoDeleteBatch(AModels: TArray<TFinChequeNote>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AModels[I].Id;

    LogQuery(Q, 'DoDeleteBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TFinChequeNoteRepository.DoDeleteBatch(AIDs: TArray<TValue>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AIDs);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AIDs[I].AsInt64;

    LogQuery(Q, 'DoDeleteBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TFinChequeNoteRepository.DoDeleteBatch(AFilter: TFilterCriteria);
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  if not Assigned(AFilter) or (AFilter.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' 1=1 ';

    for Criteria in AFilter do
      Q.SQL.Text := Q.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;

    for Criteria in AFilter do
      Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;

    LogQuery(Q, 'DoDeleteBatch');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

end.
