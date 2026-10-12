unit FinMoneyTransaction.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, FinMoneyTransaction;

type
  TFinMoneyTransactionRepository = class(TRepository<TFinMoneyTransaction>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TFinMoneyTransaction; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TFinMoneyTransaction; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TFinMoneyTransaction; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TFinMoneyTransaction>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TFinMoneyTransaction; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TFinMoneyTransaction; override;

    procedure DoAdd(AModel: TFinMoneyTransaction); override;
    procedure DoAddBatch(AModels: TArray<TFinMoneyTransaction>); override;

    procedure DoUpdate(AModel: TFinMoneyTransaction); override;
    procedure DoUpdateBatch(AModels: TArray<TFinMoneyTransaction>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TFinMoneyTransaction); override;
    procedure DoDeleteBatch(AModels: TArray<TFinMoneyTransaction>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function NegativeCashBalance(AAccountId: Int64; out AName: string; out ABalance: Currency): Boolean;
  end;

implementation

constructor TFinMoneyTransactionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

// Kasa türündeki hesabın bakiyesi eksiye düştüyse True (banka hesabında kontrol yok: KMH)
function TFinMoneyTransactionRepository.NegativeCashBalance(AAccountId: Int64; out AName: string; out ABalance: Currency): Boolean;
var
  Q: TFDQuery;
begin
  Result := False;
  AName := '';
  ABalance := 0;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT name, balance FROM public.vw_fin_money_account ' +
                  ' WHERE id = :id AND account_kind = 1 AND balance < 0';
    Q.ParamByName('id').AsLargeInt := AAccountId;
    LogQuery(Q, 'NegativeCashBalance');
    Q.Open;
    if not Q.IsEmpty then
    begin
      Result := True;
      AName := Q.FieldByName('name').AsString;
      ABalance := Q.FieldByName('balance').AsCurrency;
    end;
  finally
    Q.Free;
  end;
end;

function TFinMoneyTransactionRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TFinMoneyTransaction) +
            ' (fin_money_account_id, transaction_date, transaction_type, transfer_method, acc_account_id, target_fin_money_account_id, amount, document_no, counterparty_name, counterparty_iban, description) ' +
            ' VALUES (:fin_money_account_id, :transaction_date, :transaction_type, :transfer_method, :acc_account_id, :target_fin_money_account_id, :amount, :document_no, :counterparty_name, :counterparty_iban, :description)';
end;

function TFinMoneyTransactionRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TFinMoneyTransaction) +
            ' SET fin_money_account_id = :fin_money_account_id, transaction_date = :transaction_date, transaction_type = :transaction_type, transfer_method = :transfer_method, acc_account_id = :acc_account_id, target_fin_money_account_id = :target_fin_money_account_id, amount = :amount, document_no = :document_no, counterparty_name = :counterparty_name, counterparty_iban = :counterparty_iban, description = :description ' +
            ' WHERE id = :id';
end;

function TFinMoneyTransactionRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TFinMoneyTransaction) + ' WHERE';
end;

procedure TFinMoneyTransactionRepository.SetInsertParams(Q: TFDQuery; AModel: TFinMoneyTransaction; AIndex: Integer);

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
    Q.ParamByName('transfer_method').AsSmallInt := AModel.TransferMethod;
    Q.ParamByName('amount').AsBCD := AModel.Amount;
    Q.ParamByName('document_no').AsWideString := AModel.DocumentNo;
    Q.ParamByName('counterparty_name').AsWideString := AModel.CounterpartyName;
    Q.ParamByName('counterparty_iban').AsWideString := AModel.CounterpartyIban;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('transaction_type').AsSmallInts[AIndex] := AModel.TransactionType;
    Q.ParamByName('transfer_method').AsSmallInts[AIndex] := AModel.TransferMethod;
    Q.ParamByName('amount').AsBCDs[AIndex] := AModel.Amount;
    Q.ParamByName('document_no').AsWideStrings[AIndex] := AModel.DocumentNo;
    Q.ParamByName('counterparty_name').AsWideStrings[AIndex] := AModel.CounterpartyName;
    Q.ParamByName('counterparty_iban').AsWideStrings[AIndex] := AModel.CounterpartyIban;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('fin_money_account_id'), ftLargeint, AModel.FinMoneyAccountId, AIndex);
  SetDate('transaction_date', AModel.TransactionDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetNullableParam(Q.ParamByName('target_fin_money_account_id'), ftLargeint, AModel.TargetFinMoneyAccountId, AIndex);
end;

procedure TFinMoneyTransactionRepository.SetUpdateParams(Q: TFDQuery; AModel: TFinMoneyTransaction; AIndex: Integer);

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
    Q.ParamByName('transfer_method').AsSmallInt := AModel.TransferMethod;
    Q.ParamByName('amount').AsBCD := AModel.Amount;
    Q.ParamByName('document_no').AsWideString := AModel.DocumentNo;
    Q.ParamByName('counterparty_name').AsWideString := AModel.CounterpartyName;
    Q.ParamByName('counterparty_iban').AsWideString := AModel.CounterpartyIban;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('transaction_type').AsSmallInts[AIndex] := AModel.TransactionType;
    Q.ParamByName('transfer_method').AsSmallInts[AIndex] := AModel.TransferMethod;
    Q.ParamByName('amount').AsBCDs[AIndex] := AModel.Amount;
    Q.ParamByName('document_no').AsWideStrings[AIndex] := AModel.DocumentNo;
    Q.ParamByName('counterparty_name').AsWideStrings[AIndex] := AModel.CounterpartyName;
    Q.ParamByName('counterparty_iban').AsWideStrings[AIndex] := AModel.CounterpartyIban;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('fin_money_account_id'), ftLargeint, AModel.FinMoneyAccountId, AIndex);
  SetDate('transaction_date', AModel.TransactionDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetNullableParam(Q.ParamByName('target_fin_money_account_id'), ftLargeint, AModel.TargetFinMoneyAccountId, AIndex);
end;

function TFinMoneyTransactionRepository.MapFromQuery(Q: TFDQuery): TFinMoneyTransaction;
begin
  Result := TFinMoneyTransaction.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.FinMoneyAccountId := Q.FieldByName('fin_money_account_id').AsLargeInt;
  if Q.FieldByName('transaction_date').IsNull then
    Result.TransactionDate := 0
  else
    Result.TransactionDate := Q.FieldByName('transaction_date').AsDateTime;
  Result.TransactionType := Q.FieldByName('transaction_type').AsInteger;
  Result.TransferMethod := Q.FieldByName('transfer_method').AsInteger;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  Result.TargetFinMoneyAccountId := Q.FieldByName('target_fin_money_account_id').AsLargeInt;
  Result.Amount := Q.FieldByName('amount').AsCurrency;
  Result.DocumentNo := Q.FieldByName('document_no').AsString;
  Result.CounterpartyName := Q.FieldByName('counterparty_name').AsString;
  Result.CounterpartyIban := Q.FieldByName('counterparty_iban').AsString;
  Result.Description := Q.FieldByName('description').AsString;
  Result.MoneyAccountName := Q.FieldByName('money_account_name').AsString;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
  Result.TargetMoneyAccountName := Q.FieldByName('target_money_account_name').AsString;
end;

function TFinMoneyTransactionRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TFinMoneyTransaction) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TFinMoneyTransactionRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TFinMoneyTransaction>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TFinMoneyTransaction>.Create(True);
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

function TFinMoneyTransactionRepository.DoFindById(AId: TValue; ALock: Boolean): TFinMoneyTransaction;
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

function TFinMoneyTransactionRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TFinMoneyTransaction;
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

procedure TFinMoneyTransactionRepository.DoAdd(AModel: TFinMoneyTransaction);
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

procedure TFinMoneyTransactionRepository.DoAddBatch(AModels: TArray<TFinMoneyTransaction>);
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

procedure TFinMoneyTransactionRepository.DoUpdate(AModel: TFinMoneyTransaction);
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

procedure TFinMoneyTransactionRepository.DoUpdateBatch(AModels: TArray<TFinMoneyTransaction>);
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

procedure TFinMoneyTransactionRepository.DoDelete(AID: TValue);
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

procedure TFinMoneyTransactionRepository.DoDelete(AModel: TFinMoneyTransaction);
begin
  Delete(AModel.Id);
end;

procedure TFinMoneyTransactionRepository.DoDeleteBatch(AModels: TArray<TFinMoneyTransaction>);
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

procedure TFinMoneyTransactionRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TFinMoneyTransactionRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
