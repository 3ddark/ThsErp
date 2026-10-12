unit FinChequeNoteTransaction.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, FinChequeNoteTransaction;

type
  TFinChequeNoteTransactionRepository = class(TRepository<TFinChequeNoteTransaction>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TFinChequeNoteTransaction; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TFinChequeNoteTransaction; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TFinChequeNoteTransaction; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TFinChequeNoteTransaction>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TFinChequeNoteTransaction; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TFinChequeNoteTransaction; override;

    procedure DoAdd(AModel: TFinChequeNoteTransaction); override;
    procedure DoAddBatch(AModels: TArray<TFinChequeNoteTransaction>); override;

    procedure DoUpdate(AModel: TFinChequeNoteTransaction); override;
    procedure DoUpdateBatch(AModels: TArray<TFinChequeNoteTransaction>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TFinChequeNoteTransaction); override;
    procedure DoDeleteBatch(AModels: TArray<TFinChequeNoteTransaction>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function FindLastOfNote(ANoteId, AExcludeId: Int64): TFinChequeNoteTransaction;
    procedure RefreshNoteStatus(ANoteId: Int64);
  end;

implementation

constructor TFinChequeNoteTransactionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

// Belgenin son hareketi (tarih, id sırasıyla); AExcludeId > 0 ise o hareket hariç
function TFinChequeNoteTransactionRepository.FindLastOfNote(ANoteId, AExcludeId: Int64): TFinChequeNoteTransaction;
var
  Q: TFDQuery;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT * FROM ' + Self.GetFullViewName(TFinChequeNoteTransaction) +
                  ' WHERE fin_cheque_note_id = :note_id AND id <> :exclude_id ' +
                  ' ORDER BY transaction_date DESC, id DESC LIMIT 1';
    Q.ParamByName('note_id').AsLargeInt := ANoteId;
    Q.ParamByName('exclude_id').AsLargeInt := AExcludeId;
    LogQuery(Q, 'FindLastOfNote');
    Q.Open;
    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

// Belge durumu = son hareketin tipi
procedure TFinChequeNoteTransactionRepository.RefreshNoteStatus(ANoteId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.fin_cheque_note n ' +
                  '   SET status = COALESCE((SELECT t.transaction_type FROM public.fin_cheque_note_transaction t ' +
                  '                           WHERE t.fin_cheque_note_id = n.id ' +
                  '                           ORDER BY t.transaction_date DESC, t.id DESC LIMIT 1), n.status) ' +
                  ' WHERE n.id = :id';
    Q.ParamByName('id').AsLargeInt := ANoteId;
    LogQuery(Q, 'RefreshNoteStatus');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TFinChequeNoteTransactionRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TFinChequeNoteTransaction) +
            ' (fin_cheque_note_id, transaction_date, transaction_type, acc_account_id, acc_bank_id, description) ' +
            ' VALUES (:fin_cheque_note_id, :transaction_date, :transaction_type, :acc_account_id, :acc_bank_id, :description)';
end;

function TFinChequeNoteTransactionRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TFinChequeNoteTransaction) +
            ' SET fin_cheque_note_id = :fin_cheque_note_id, transaction_date = :transaction_date, transaction_type = :transaction_type, acc_account_id = :acc_account_id, acc_bank_id = :acc_bank_id, description = :description ' +
            ' WHERE id = :id';
end;

function TFinChequeNoteTransactionRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TFinChequeNoteTransaction) + ' WHERE';
end;

procedure TFinChequeNoteTransactionRepository.SetInsertParams(Q: TFDQuery; AModel: TFinChequeNoteTransaction; AIndex: Integer);

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
    Q.ParamByName('transaction_type').AsSmallInt := AModel.TransactionType;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('transaction_type').AsSmallInts[AIndex] := AModel.TransactionType;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('fin_cheque_note_id'), ftLargeint, AModel.FinChequeNoteId, AIndex);
  SetDate('transaction_date', AModel.TransactionDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetNullableParam(Q.ParamByName('acc_bank_id'), ftLargeint, AModel.AccBankId, AIndex);
end;

procedure TFinChequeNoteTransactionRepository.SetUpdateParams(Q: TFDQuery; AModel: TFinChequeNoteTransaction; AIndex: Integer);

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
    Q.ParamByName('transaction_type').AsSmallInt := AModel.TransactionType;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('transaction_type').AsSmallInts[AIndex] := AModel.TransactionType;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('fin_cheque_note_id'), ftLargeint, AModel.FinChequeNoteId, AIndex);
  SetDate('transaction_date', AModel.TransactionDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetNullableParam(Q.ParamByName('acc_bank_id'), ftLargeint, AModel.AccBankId, AIndex);
end;

function TFinChequeNoteTransactionRepository.MapFromQuery(Q: TFDQuery): TFinChequeNoteTransaction;
begin
  Result := TFinChequeNoteTransaction.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.FinChequeNoteId := Q.FieldByName('fin_cheque_note_id').AsLargeInt;
  if Q.FieldByName('transaction_date').IsNull then
    Result.TransactionDate := 0
  else
    Result.TransactionDate := Q.FieldByName('transaction_date').AsDateTime;
  Result.TransactionType := Q.FieldByName('transaction_type').AsInteger;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  Result.AccBankId := Q.FieldByName('acc_bank_id').AsLargeInt;
  Result.Description := Q.FieldByName('description').AsString;
  Result.PortfolioNo := Q.FieldByName('portfolio_no').AsString;
  Result.SerialNo := Q.FieldByName('serial_no').AsString;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
  Result.BankName := Q.FieldByName('bank_name').AsString;
end;

function TFinChequeNoteTransactionRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TFinChequeNoteTransaction) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TFinChequeNoteTransactionRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TFinChequeNoteTransaction>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TFinChequeNoteTransaction>.Create(True);
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

function TFinChequeNoteTransactionRepository.DoFindById(AId: TValue; ALock: Boolean): TFinChequeNoteTransaction;
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

function TFinChequeNoteTransactionRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TFinChequeNoteTransaction;
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

procedure TFinChequeNoteTransactionRepository.DoAdd(AModel: TFinChequeNoteTransaction);
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

procedure TFinChequeNoteTransactionRepository.DoAddBatch(AModels: TArray<TFinChequeNoteTransaction>);
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

procedure TFinChequeNoteTransactionRepository.DoUpdate(AModel: TFinChequeNoteTransaction);
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

procedure TFinChequeNoteTransactionRepository.DoUpdateBatch(AModels: TArray<TFinChequeNoteTransaction>);
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

procedure TFinChequeNoteTransactionRepository.DoDelete(AID: TValue);
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

procedure TFinChequeNoteTransactionRepository.DoDelete(AModel: TFinChequeNoteTransaction);
begin
  Delete(AModel.Id);
end;

procedure TFinChequeNoteTransactionRepository.DoDeleteBatch(AModels: TArray<TFinChequeNoteTransaction>);
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

procedure TFinChequeNoteTransactionRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TFinChequeNoteTransactionRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
