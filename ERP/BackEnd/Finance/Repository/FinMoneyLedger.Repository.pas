unit FinMoneyLedger.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, FinMoneyLedger;

type
  TFinMoneyLedgerRepository = class(TRepository<TFinMoneyLedger>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TFinMoneyLedger; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TFinMoneyLedger; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TFinMoneyLedger; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TFinMoneyLedger>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TFinMoneyLedger; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TFinMoneyLedger; override;

    procedure DoAdd(AModel: TFinMoneyLedger); override;
    procedure DoAddBatch(AModels: TArray<TFinMoneyLedger>); override;

    procedure DoUpdate(AModel: TFinMoneyLedger); override;
    procedure DoUpdateBatch(AModels: TArray<TFinMoneyLedger>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TFinMoneyLedger); override;
    procedure DoDeleteBatch(AModels: TArray<TFinMoneyLedger>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TFinMoneyLedgerRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TFinMoneyLedgerRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TFinMoneyLedger) +
            ' (fin_money_transaction_id, fin_money_account_id, transaction_date, transaction_type, transfer_method, direction, amount_in, amount_out, balance, other_fin_money_account_id, acc_account_id, document_no, counterparty_name, description) ' +
            ' VALUES (:fin_money_transaction_id, :fin_money_account_id, :transaction_date, :transaction_type, :transfer_method, :direction, :amount_in, :amount_out, :balance, :other_fin_money_account_id, :acc_account_id, :document_no, :counterparty_name, :description)';
end;

function TFinMoneyLedgerRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TFinMoneyLedger) +
            ' SET fin_money_transaction_id = :fin_money_transaction_id, fin_money_account_id = :fin_money_account_id, transaction_date = :transaction_date, transaction_type = :transaction_type, transfer_method = :transfer_method, direction = :direction, amount_in = :amount_in, amount_out = :amount_out, balance = :balance, other_fin_money_account_id = :other_fin_money_account_id, acc_account_id = :acc_account_id, document_no = :document_no, counterparty_name = :counterparty_name, description = :description ' +
            ' WHERE id = :id';
end;

function TFinMoneyLedgerRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TFinMoneyLedger) + ' WHERE';
end;

procedure TFinMoneyLedgerRepository.SetInsertParams(Q: TFDQuery; AModel: TFinMoneyLedger; AIndex: Integer);

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
    Q.ParamByName('direction').AsSmallInt := AModel.Direction;
    Q.ParamByName('amount_in').AsBCD := AModel.AmountIn;
    Q.ParamByName('amount_out').AsBCD := AModel.AmountOut;
    Q.ParamByName('balance').AsBCD := AModel.Balance;
    Q.ParamByName('document_no').AsWideString := AModel.DocumentNo;
    Q.ParamByName('counterparty_name').AsWideString := AModel.CounterpartyName;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('transaction_type').AsSmallInts[AIndex] := AModel.TransactionType;
    Q.ParamByName('transfer_method').AsSmallInts[AIndex] := AModel.TransferMethod;
    Q.ParamByName('direction').AsSmallInts[AIndex] := AModel.Direction;
    Q.ParamByName('amount_in').AsBCDs[AIndex] := AModel.AmountIn;
    Q.ParamByName('amount_out').AsBCDs[AIndex] := AModel.AmountOut;
    Q.ParamByName('balance').AsBCDs[AIndex] := AModel.Balance;
    Q.ParamByName('document_no').AsWideStrings[AIndex] := AModel.DocumentNo;
    Q.ParamByName('counterparty_name').AsWideStrings[AIndex] := AModel.CounterpartyName;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('fin_money_transaction_id'), ftLargeint, AModel.FinMoneyTransactionId, AIndex);
  SetNullableParam(Q.ParamByName('fin_money_account_id'), ftLargeint, AModel.FinMoneyAccountId, AIndex);
  SetDate('transaction_date', AModel.TransactionDate);
  SetNullableParam(Q.ParamByName('other_fin_money_account_id'), ftLargeint, AModel.OtherFinMoneyAccountId, AIndex);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
end;

procedure TFinMoneyLedgerRepository.SetUpdateParams(Q: TFDQuery; AModel: TFinMoneyLedger; AIndex: Integer);

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
    Q.ParamByName('direction').AsSmallInt := AModel.Direction;
    Q.ParamByName('amount_in').AsBCD := AModel.AmountIn;
    Q.ParamByName('amount_out').AsBCD := AModel.AmountOut;
    Q.ParamByName('balance').AsBCD := AModel.Balance;
    Q.ParamByName('document_no').AsWideString := AModel.DocumentNo;
    Q.ParamByName('counterparty_name').AsWideString := AModel.CounterpartyName;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('transaction_type').AsSmallInts[AIndex] := AModel.TransactionType;
    Q.ParamByName('transfer_method').AsSmallInts[AIndex] := AModel.TransferMethod;
    Q.ParamByName('direction').AsSmallInts[AIndex] := AModel.Direction;
    Q.ParamByName('amount_in').AsBCDs[AIndex] := AModel.AmountIn;
    Q.ParamByName('amount_out').AsBCDs[AIndex] := AModel.AmountOut;
    Q.ParamByName('balance').AsBCDs[AIndex] := AModel.Balance;
    Q.ParamByName('document_no').AsWideStrings[AIndex] := AModel.DocumentNo;
    Q.ParamByName('counterparty_name').AsWideStrings[AIndex] := AModel.CounterpartyName;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('fin_money_transaction_id'), ftLargeint, AModel.FinMoneyTransactionId, AIndex);
  SetNullableParam(Q.ParamByName('fin_money_account_id'), ftLargeint, AModel.FinMoneyAccountId, AIndex);
  SetDate('transaction_date', AModel.TransactionDate);
  SetNullableParam(Q.ParamByName('other_fin_money_account_id'), ftLargeint, AModel.OtherFinMoneyAccountId, AIndex);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
end;

function TFinMoneyLedgerRepository.MapFromQuery(Q: TFDQuery): TFinMoneyLedger;
begin
  Result := TFinMoneyLedger.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.FinMoneyTransactionId := Q.FieldByName('fin_money_transaction_id').AsLargeInt;
  Result.FinMoneyAccountId := Q.FieldByName('fin_money_account_id').AsLargeInt;
  if Q.FieldByName('transaction_date').IsNull then
    Result.TransactionDate := 0
  else
    Result.TransactionDate := Q.FieldByName('transaction_date').AsDateTime;
  Result.TransactionType := Q.FieldByName('transaction_type').AsInteger;
  Result.TransferMethod := Q.FieldByName('transfer_method').AsInteger;
  Result.Direction := Q.FieldByName('direction').AsInteger;
  Result.AmountIn := Q.FieldByName('amount_in').AsCurrency;
  Result.AmountOut := Q.FieldByName('amount_out').AsCurrency;
  Result.Balance := Q.FieldByName('balance').AsCurrency;
  Result.OtherFinMoneyAccountId := Q.FieldByName('other_fin_money_account_id').AsLargeInt;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  Result.DocumentNo := Q.FieldByName('document_no').AsString;
  Result.CounterpartyName := Q.FieldByName('counterparty_name').AsString;
  Result.Description := Q.FieldByName('description').AsString;
  Result.MoneyAccountName := Q.FieldByName('money_account_name').AsString;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.OtherMoneyAccountName := Q.FieldByName('other_money_account_name').AsString;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
end;

function TFinMoneyLedgerRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TFinMoneyLedger) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TFinMoneyLedgerRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TFinMoneyLedger>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TFinMoneyLedger>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, False, False, False);

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

function TFinMoneyLedgerRepository.DoFindById(AId: TValue; ALock: Boolean): TFinMoneyLedger;
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
    Q.SQL.Text := Self.PrepareSelectFromView(Criteria, False, True, False);

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

function TFinMoneyLedgerRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TFinMoneyLedger;
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
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, False, True, False);

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

procedure TFinMoneyLedgerRepository.DoAdd(AModel: TFinMoneyLedger);
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

procedure TFinMoneyLedgerRepository.DoAddBatch(AModels: TArray<TFinMoneyLedger>);
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

procedure TFinMoneyLedgerRepository.DoUpdate(AModel: TFinMoneyLedger);
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

procedure TFinMoneyLedgerRepository.DoUpdateBatch(AModels: TArray<TFinMoneyLedger>);
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

procedure TFinMoneyLedgerRepository.DoDelete(AID: TValue);
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

procedure TFinMoneyLedgerRepository.DoDelete(AModel: TFinMoneyLedger);
begin
  Delete(AModel.Id);
end;

procedure TFinMoneyLedgerRepository.DoDeleteBatch(AModels: TArray<TFinMoneyLedger>);
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

procedure TFinMoneyLedgerRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TFinMoneyLedgerRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
