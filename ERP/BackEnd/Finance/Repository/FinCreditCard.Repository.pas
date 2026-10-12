unit FinCreditCard.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, FinCreditCard;

type
  TFinCreditCardRepository = class(TRepository<TFinCreditCard>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TFinCreditCard; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TFinCreditCard; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TFinCreditCard; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TFinCreditCard>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TFinCreditCard; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TFinCreditCard; override;

    procedure DoAdd(AModel: TFinCreditCard); override;
    procedure DoAddBatch(AModels: TArray<TFinCreditCard>); override;

    procedure DoUpdate(AModel: TFinCreditCard); override;
    procedure DoUpdateBatch(AModels: TArray<TFinCreditCard>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TFinCreditCard); override;
    procedure DoDeleteBatch(AModels: TArray<TFinCreditCard>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function TransactionCount(ACardId: Int64): Integer;
    function GetDefaultCurrency: string;
  end;

implementation

constructor TFinCreditCardRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TFinCreditCardRepository.TransactionCount(ACardId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) AS cnt FROM public.fin_credit_card_transaction WHERE fin_credit_card_id = :id';
    Q.ParamByName('id').AsLargeInt := ACardId;
    LogQuery(Q, 'TransactionCount');
    Q.Open;
    Result := Q.FieldByName('cnt').AsInteger;
  finally
    Q.Free;
  end;
end;

function TFinCreditCardRepository.GetDefaultCurrency: string;
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

function TFinCreditCardRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TFinCreditCard) +
            ' (card_name, acc_bank_id, card_holder, card_last_digits, card_limit, statement_day, payment_day, currency, acc_account_code, is_active, notes) ' +
            ' VALUES (:card_name, :acc_bank_id, :card_holder, :card_last_digits, :card_limit, :statement_day, :payment_day, :currency, :acc_account_code, :is_active, :notes)';
end;

function TFinCreditCardRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TFinCreditCard) +
            ' SET card_name = :card_name, acc_bank_id = :acc_bank_id, card_holder = :card_holder, card_last_digits = :card_last_digits, card_limit = :card_limit, statement_day = :statement_day, payment_day = :payment_day, currency = :currency, acc_account_code = :acc_account_code, is_active = :is_active, notes = :notes ' +
            ' WHERE id = :id';
end;

function TFinCreditCardRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TFinCreditCard) + ' WHERE';
end;

procedure TFinCreditCardRepository.SetInsertParams(Q: TFDQuery; AModel: TFinCreditCard; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('card_name').AsWideString := AModel.CardName;
    Q.ParamByName('card_holder').AsWideString := AModel.CardHolder;
    Q.ParamByName('card_last_digits').AsWideString := AModel.CardLastDigits;
    Q.ParamByName('card_limit').AsBCD := AModel.CardLimit;
    Q.ParamByName('statement_day').AsSmallInt := AModel.StatementDay;
    Q.ParamByName('payment_day').AsSmallInt := AModel.PaymentDay;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('acc_account_code').AsWideString := AModel.AccAccountCode;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
    Q.ParamByName('notes').AsWideString := AModel.Notes;
  end
  else
  begin
    Q.ParamByName('card_name').AsWideStrings[AIndex] := AModel.CardName;
    Q.ParamByName('card_holder').AsWideStrings[AIndex] := AModel.CardHolder;
    Q.ParamByName('card_last_digits').AsWideStrings[AIndex] := AModel.CardLastDigits;
    Q.ParamByName('card_limit').AsBCDs[AIndex] := AModel.CardLimit;
    Q.ParamByName('statement_day').AsSmallInts[AIndex] := AModel.StatementDay;
    Q.ParamByName('payment_day').AsSmallInts[AIndex] := AModel.PaymentDay;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('acc_account_code').AsWideStrings[AIndex] := AModel.AccAccountCode;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
    Q.ParamByName('notes').AsWideStrings[AIndex] := AModel.Notes;
  end;

  SetNullableParam(Q.ParamByName('acc_bank_id'), ftLargeint, AModel.AccBankId, AIndex);
end;

procedure TFinCreditCardRepository.SetUpdateParams(Q: TFDQuery; AModel: TFinCreditCard; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('card_name').AsWideString := AModel.CardName;
    Q.ParamByName('card_holder').AsWideString := AModel.CardHolder;
    Q.ParamByName('card_last_digits').AsWideString := AModel.CardLastDigits;
    Q.ParamByName('card_limit').AsBCD := AModel.CardLimit;
    Q.ParamByName('statement_day').AsSmallInt := AModel.StatementDay;
    Q.ParamByName('payment_day').AsSmallInt := AModel.PaymentDay;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('acc_account_code').AsWideString := AModel.AccAccountCode;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
    Q.ParamByName('notes').AsWideString := AModel.Notes;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('card_name').AsWideStrings[AIndex] := AModel.CardName;
    Q.ParamByName('card_holder').AsWideStrings[AIndex] := AModel.CardHolder;
    Q.ParamByName('card_last_digits').AsWideStrings[AIndex] := AModel.CardLastDigits;
    Q.ParamByName('card_limit').AsBCDs[AIndex] := AModel.CardLimit;
    Q.ParamByName('statement_day').AsSmallInts[AIndex] := AModel.StatementDay;
    Q.ParamByName('payment_day').AsSmallInts[AIndex] := AModel.PaymentDay;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('acc_account_code').AsWideStrings[AIndex] := AModel.AccAccountCode;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
    Q.ParamByName('notes').AsWideStrings[AIndex] := AModel.Notes;
  end;

  SetNullableParam(Q.ParamByName('acc_bank_id'), ftLargeint, AModel.AccBankId, AIndex);
end;

function TFinCreditCardRepository.MapFromQuery(Q: TFDQuery): TFinCreditCard;
begin
  Result := TFinCreditCard.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.CardName := Q.FieldByName('card_name').AsString;
  Result.AccBankId := Q.FieldByName('acc_bank_id').AsLargeInt;
  Result.CardHolder := Q.FieldByName('card_holder').AsString;
  Result.CardLastDigits := Q.FieldByName('card_last_digits').AsString;
  Result.CardLimit := Q.FieldByName('card_limit').AsCurrency;
  Result.StatementDay := Q.FieldByName('statement_day').AsInteger;
  Result.PaymentDay := Q.FieldByName('payment_day').AsInteger;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.AccAccountCode := Q.FieldByName('acc_account_code').AsString;
  Result.IsActive := Q.FieldByName('is_active').AsBoolean;
  Result.Notes := Q.FieldByName('notes').AsString;
  Result.BankName := Q.FieldByName('bank_name').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
end;

function TFinCreditCardRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TFinCreditCard) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TFinCreditCardRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TFinCreditCard>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TFinCreditCard>.Create(True);
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

function TFinCreditCardRepository.DoFindById(AId: TValue; ALock: Boolean): TFinCreditCard;
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

function TFinCreditCardRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TFinCreditCard;
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

procedure TFinCreditCardRepository.DoAdd(AModel: TFinCreditCard);
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

procedure TFinCreditCardRepository.DoAddBatch(AModels: TArray<TFinCreditCard>);
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

procedure TFinCreditCardRepository.DoUpdate(AModel: TFinCreditCard);
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

procedure TFinCreditCardRepository.DoUpdateBatch(AModels: TArray<TFinCreditCard>);
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

procedure TFinCreditCardRepository.DoDelete(AID: TValue);
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

procedure TFinCreditCardRepository.DoDelete(AModel: TFinCreditCard);
begin
  Delete(AModel.Id);
end;

procedure TFinCreditCardRepository.DoDeleteBatch(AModels: TArray<TFinCreditCard>);
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

procedure TFinCreditCardRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TFinCreditCardRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
