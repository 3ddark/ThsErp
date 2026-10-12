unit FinPosTransaction.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, FinPosTransaction;

type
  TFinPosTransactionRepository = class(TRepository<TFinPosTransaction>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TFinPosTransaction; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TFinPosTransaction; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TFinPosTransaction; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TFinPosTransaction>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TFinPosTransaction; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TFinPosTransaction; override;

    procedure DoAdd(AModel: TFinPosTransaction); override;
    procedure DoAddBatch(AModels: TArray<TFinPosTransaction>); override;

    procedure DoUpdate(AModel: TFinPosTransaction); override;
    procedure DoUpdateBatch(AModels: TArray<TFinPosTransaction>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TFinPosTransaction); override;
    procedure DoDeleteBatch(AModels: TArray<TFinPosTransaction>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TFinPosTransactionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TFinPosTransactionRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TFinPosTransaction) +
            ' (fin_pos_terminal_id, transaction_date, transaction_type, acc_account_id, amount, installment_count, commission_rate, commission_amount, net_amount, value_date, card_holder, card_last_digits, description) ' +
            ' VALUES (:fin_pos_terminal_id, :transaction_date, :transaction_type, :acc_account_id, :amount, :installment_count, :commission_rate, :commission_amount, :net_amount, :value_date, :card_holder, :card_last_digits, :description)';
end;

function TFinPosTransactionRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TFinPosTransaction) +
            ' SET fin_pos_terminal_id = :fin_pos_terminal_id, transaction_date = :transaction_date, transaction_type = :transaction_type, acc_account_id = :acc_account_id, amount = :amount, installment_count = :installment_count, commission_rate = :commission_rate, commission_amount = :commission_amount, net_amount = :net_amount, value_date = :value_date, card_holder = :card_holder, card_last_digits = :card_last_digits, description = :description ' +
            ' WHERE id = :id';
end;

function TFinPosTransactionRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TFinPosTransaction) + ' WHERE';
end;

procedure TFinPosTransactionRepository.SetInsertParams(Q: TFDQuery; AModel: TFinPosTransaction; AIndex: Integer);

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
    Q.ParamByName('commission_rate').AsBCD := AModel.CommissionRate;
    Q.ParamByName('commission_amount').AsBCD := AModel.CommissionAmount;
    Q.ParamByName('net_amount').AsBCD := AModel.NetAmount;
    Q.ParamByName('card_holder').AsWideString := AModel.CardHolder;
    Q.ParamByName('card_last_digits').AsWideString := AModel.CardLastDigits;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('transaction_type').AsSmallInts[AIndex] := AModel.TransactionType;
    Q.ParamByName('amount').AsBCDs[AIndex] := AModel.Amount;
    Q.ParamByName('installment_count').AsSmallInts[AIndex] := AModel.InstallmentCount;
    Q.ParamByName('commission_rate').AsBCDs[AIndex] := AModel.CommissionRate;
    Q.ParamByName('commission_amount').AsBCDs[AIndex] := AModel.CommissionAmount;
    Q.ParamByName('net_amount').AsBCDs[AIndex] := AModel.NetAmount;
    Q.ParamByName('card_holder').AsWideStrings[AIndex] := AModel.CardHolder;
    Q.ParamByName('card_last_digits').AsWideStrings[AIndex] := AModel.CardLastDigits;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('fin_pos_terminal_id'), ftLargeint, AModel.FinPosTerminalId, AIndex);
  SetDate('transaction_date', AModel.TransactionDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetDate('value_date', AModel.ValueDate);
end;

procedure TFinPosTransactionRepository.SetUpdateParams(Q: TFDQuery; AModel: TFinPosTransaction; AIndex: Integer);

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
    Q.ParamByName('commission_rate').AsBCD := AModel.CommissionRate;
    Q.ParamByName('commission_amount').AsBCD := AModel.CommissionAmount;
    Q.ParamByName('net_amount').AsBCD := AModel.NetAmount;
    Q.ParamByName('card_holder').AsWideString := AModel.CardHolder;
    Q.ParamByName('card_last_digits').AsWideString := AModel.CardLastDigits;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('transaction_type').AsSmallInts[AIndex] := AModel.TransactionType;
    Q.ParamByName('amount').AsBCDs[AIndex] := AModel.Amount;
    Q.ParamByName('installment_count').AsSmallInts[AIndex] := AModel.InstallmentCount;
    Q.ParamByName('commission_rate').AsBCDs[AIndex] := AModel.CommissionRate;
    Q.ParamByName('commission_amount').AsBCDs[AIndex] := AModel.CommissionAmount;
    Q.ParamByName('net_amount').AsBCDs[AIndex] := AModel.NetAmount;
    Q.ParamByName('card_holder').AsWideStrings[AIndex] := AModel.CardHolder;
    Q.ParamByName('card_last_digits').AsWideStrings[AIndex] := AModel.CardLastDigits;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('fin_pos_terminal_id'), ftLargeint, AModel.FinPosTerminalId, AIndex);
  SetDate('transaction_date', AModel.TransactionDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetDate('value_date', AModel.ValueDate);
end;

function TFinPosTransactionRepository.MapFromQuery(Q: TFDQuery): TFinPosTransaction;
begin
  Result := TFinPosTransaction.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.FinPosTerminalId := Q.FieldByName('fin_pos_terminal_id').AsLargeInt;
  if Q.FieldByName('transaction_date').IsNull then
    Result.TransactionDate := 0
  else
    Result.TransactionDate := Q.FieldByName('transaction_date').AsDateTime;
  Result.TransactionType := Q.FieldByName('transaction_type').AsInteger;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  Result.Amount := Q.FieldByName('amount').AsCurrency;
  Result.InstallmentCount := Q.FieldByName('installment_count').AsInteger;
  Result.CommissionRate := Q.FieldByName('commission_rate').AsCurrency;
  Result.CommissionAmount := Q.FieldByName('commission_amount').AsCurrency;
  Result.NetAmount := Q.FieldByName('net_amount').AsCurrency;
  if Q.FieldByName('value_date').IsNull then
    Result.ValueDate := 0
  else
    Result.ValueDate := Q.FieldByName('value_date').AsDateTime;
  Result.CardHolder := Q.FieldByName('card_holder').AsString;
  Result.CardLastDigits := Q.FieldByName('card_last_digits').AsString;
  Result.Description := Q.FieldByName('description').AsString;
  Result.PosName := Q.FieldByName('pos_name').AsString;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
end;

function TFinPosTransactionRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TFinPosTransaction) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TFinPosTransactionRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TFinPosTransaction>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TFinPosTransaction>.Create(True);
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

function TFinPosTransactionRepository.DoFindById(AId: TValue; ALock: Boolean): TFinPosTransaction;
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

function TFinPosTransactionRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TFinPosTransaction;
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

procedure TFinPosTransactionRepository.DoAdd(AModel: TFinPosTransaction);
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

procedure TFinPosTransactionRepository.DoAddBatch(AModels: TArray<TFinPosTransaction>);
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

procedure TFinPosTransactionRepository.DoUpdate(AModel: TFinPosTransaction);
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

procedure TFinPosTransactionRepository.DoUpdateBatch(AModels: TArray<TFinPosTransaction>);
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

procedure TFinPosTransactionRepository.DoDelete(AID: TValue);
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

procedure TFinPosTransactionRepository.DoDelete(AModel: TFinPosTransaction);
begin
  Delete(AModel.Id);
end;

procedure TFinPosTransactionRepository.DoDeleteBatch(AModels: TArray<TFinPosTransaction>);
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

procedure TFinPosTransactionRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TFinPosTransactionRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
