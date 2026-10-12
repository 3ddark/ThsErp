unit FinCreditCardTransaction.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, FinCreditCardTransaction;

type
  TFinCreditCardTransactionRepository = class(TRepository<TFinCreditCardTransaction>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TFinCreditCardTransaction; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TFinCreditCardTransaction; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TFinCreditCardTransaction; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TFinCreditCardTransaction>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TFinCreditCardTransaction; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TFinCreditCardTransaction; override;

    procedure DoAdd(AModel: TFinCreditCardTransaction); override;
    procedure DoAddBatch(AModels: TArray<TFinCreditCardTransaction>); override;

    procedure DoUpdate(AModel: TFinCreditCardTransaction); override;
    procedure DoUpdateBatch(AModels: TArray<TFinCreditCardTransaction>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TFinCreditCardTransaction); override;
    procedure DoDeleteBatch(AModels: TArray<TFinCreditCardTransaction>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function GetCardBalance(ACardId, AExcludeId: Int64): Currency;
  end;

implementation

constructor TFinCreditCardTransactionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

// Kart borcu: harcama - ödeme - iade (AExcludeId hareketi hariç)
function TFinCreditCardTransactionRepository.GetCardBalance(ACardId, AExcludeId: Int64): Currency;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(sum(CASE WHEN transaction_type = 1 THEN amount ELSE -amount END), 0) AS balance ' +
                  '  FROM public.fin_credit_card_transaction ' +
                  ' WHERE fin_credit_card_id = :card_id AND id <> :exclude_id';
    Q.ParamByName('card_id').AsLargeInt := ACardId;
    Q.ParamByName('exclude_id').AsLargeInt := AExcludeId;
    LogQuery(Q, 'GetCardBalance');
    Q.Open;
    Result := Q.FieldByName('balance').AsCurrency;
  finally
    Q.Free;
  end;
end;

function TFinCreditCardTransactionRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TFinCreditCardTransaction) +
            ' (fin_credit_card_id, transaction_date, transaction_type, acc_account_id, amount, installment_count, description) ' +
            ' VALUES (:fin_credit_card_id, :transaction_date, :transaction_type, :acc_account_id, :amount, :installment_count, :description)';
end;

function TFinCreditCardTransactionRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TFinCreditCardTransaction) +
            ' SET fin_credit_card_id = :fin_credit_card_id, transaction_date = :transaction_date, transaction_type = :transaction_type, acc_account_id = :acc_account_id, amount = :amount, installment_count = :installment_count, description = :description ' +
            ' WHERE id = :id';
end;

function TFinCreditCardTransactionRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TFinCreditCardTransaction) + ' WHERE';
end;

procedure TFinCreditCardTransactionRepository.SetInsertParams(Q: TFDQuery; AModel: TFinCreditCardTransaction; AIndex: Integer);

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
    Q.ParamByName('amount').AsBCD := AModel.Amount;
    Q.ParamByName('installment_count').AsSmallInt := AModel.InstallmentCount;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('transaction_type').AsSmallInts[AIndex] := AModel.TransactionType;
    Q.ParamByName('amount').AsBCDs[AIndex] := AModel.Amount;
    Q.ParamByName('installment_count').AsSmallInts[AIndex] := AModel.InstallmentCount;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('fin_credit_card_id'), ftLargeint, AModel.FinCreditCardId, AIndex);
  SetDate('transaction_date', AModel.TransactionDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
end;

procedure TFinCreditCardTransactionRepository.SetUpdateParams(Q: TFDQuery; AModel: TFinCreditCardTransaction; AIndex: Integer);

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
    Q.ParamByName('amount').AsBCD := AModel.Amount;
    Q.ParamByName('installment_count').AsSmallInt := AModel.InstallmentCount;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('transaction_type').AsSmallInts[AIndex] := AModel.TransactionType;
    Q.ParamByName('amount').AsBCDs[AIndex] := AModel.Amount;
    Q.ParamByName('installment_count').AsSmallInts[AIndex] := AModel.InstallmentCount;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('fin_credit_card_id'), ftLargeint, AModel.FinCreditCardId, AIndex);
  SetDate('transaction_date', AModel.TransactionDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
end;

function TFinCreditCardTransactionRepository.MapFromQuery(Q: TFDQuery): TFinCreditCardTransaction;
begin
  Result := TFinCreditCardTransaction.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.FinCreditCardId := Q.FieldByName('fin_credit_card_id').AsLargeInt;
  if Q.FieldByName('transaction_date').IsNull then
    Result.TransactionDate := 0
  else
    Result.TransactionDate := Q.FieldByName('transaction_date').AsDateTime;
  Result.TransactionType := Q.FieldByName('transaction_type').AsInteger;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  Result.Amount := Q.FieldByName('amount').AsCurrency;
  Result.InstallmentCount := Q.FieldByName('installment_count').AsInteger;
  Result.Description := Q.FieldByName('description').AsString;
  Result.CardName := Q.FieldByName('card_name').AsString;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
end;

function TFinCreditCardTransactionRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TFinCreditCardTransaction) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TFinCreditCardTransactionRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TFinCreditCardTransaction>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TFinCreditCardTransaction>.Create(True);
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

function TFinCreditCardTransactionRepository.DoFindById(AId: TValue; ALock: Boolean): TFinCreditCardTransaction;
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

function TFinCreditCardTransactionRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TFinCreditCardTransaction;
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

procedure TFinCreditCardTransactionRepository.DoAdd(AModel: TFinCreditCardTransaction);
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

procedure TFinCreditCardTransactionRepository.DoAddBatch(AModels: TArray<TFinCreditCardTransaction>);
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

procedure TFinCreditCardTransactionRepository.DoUpdate(AModel: TFinCreditCardTransaction);
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

procedure TFinCreditCardTransactionRepository.DoUpdateBatch(AModels: TArray<TFinCreditCardTransaction>);
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

procedure TFinCreditCardTransactionRepository.DoDelete(AID: TValue);
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

procedure TFinCreditCardTransactionRepository.DoDelete(AModel: TFinCreditCardTransaction);
begin
  Delete(AModel.Id);
end;

procedure TFinCreditCardTransactionRepository.DoDeleteBatch(AModels: TArray<TFinCreditCardTransaction>);
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

procedure TFinCreditCardTransactionRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TFinCreditCardTransactionRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
