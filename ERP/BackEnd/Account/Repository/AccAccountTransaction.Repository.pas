unit AccAccountTransaction.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, AccAccountTransaction;

type
  TAccAccountTransactionRepository = class(TRepository<TAccAccountTransaction>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TAccAccountTransaction; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TAccAccountTransaction; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TAccAccountTransaction; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TAccAccountTransaction>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TAccAccountTransaction; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TAccAccountTransaction; override;

    procedure DoAdd(AModel: TAccAccountTransaction); override;
    procedure DoAddBatch(AModels: TArray<TAccAccountTransaction>); override;

    procedure DoUpdate(AModel: TAccAccountTransaction); override;
    procedure DoUpdateBatch(AModels: TArray<TAccAccountTransaction>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TAccAccountTransaction); override;
    procedure DoDeleteBatch(AModels: TArray<TAccAccountTransaction>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TAccAccountTransactionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TAccAccountTransactionRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TAccAccountTransaction) +
            ' (acc_account_id, transaction_date, source_type, source_id, document_id, document_no, description, currency, debit, credit, balance) ' +
            ' VALUES (:acc_account_id, :transaction_date, :source_type, :source_id, :document_id, :document_no, :description, :currency, :debit, :credit, :balance)';
end;

function TAccAccountTransactionRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TAccAccountTransaction) +
            ' SET acc_account_id = :acc_account_id, transaction_date = :transaction_date, source_type = :source_type, source_id = :source_id, document_id = :document_id, document_no = :document_no, description = :description, currency = :currency, debit = :debit, credit = :credit, balance = :balance ' +
            ' WHERE id = :id';
end;

function TAccAccountTransactionRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TAccAccountTransaction) + ' WHERE';
end;

procedure TAccAccountTransactionRepository.SetInsertParams(Q: TFDQuery; AModel: TAccAccountTransaction; AIndex: Integer);

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
    Q.ParamByName('source_type').AsSmallInt := AModel.SourceType;
    Q.ParamByName('document_no').AsWideString := AModel.DocumentNo;
    Q.ParamByName('description').AsWideString := AModel.Description;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('debit').AsBCD := AModel.Debit;
    Q.ParamByName('credit').AsBCD := AModel.Credit;
    Q.ParamByName('balance').AsBCD := AModel.Balance;
  end
  else
  begin
    Q.ParamByName('source_type').AsSmallInts[AIndex] := AModel.SourceType;
    Q.ParamByName('document_no').AsWideStrings[AIndex] := AModel.DocumentNo;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('debit').AsBCDs[AIndex] := AModel.Debit;
    Q.ParamByName('credit').AsBCDs[AIndex] := AModel.Credit;
    Q.ParamByName('balance').AsBCDs[AIndex] := AModel.Balance;
  end;

  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetDate('transaction_date', AModel.TransactionDate);
  SetNullableParam(Q.ParamByName('source_id'), ftLargeint, AModel.SourceId, AIndex);
  SetNullableParam(Q.ParamByName('document_id'), ftLargeint, AModel.DocumentId, AIndex);
end;

procedure TAccAccountTransactionRepository.SetUpdateParams(Q: TFDQuery; AModel: TAccAccountTransaction; AIndex: Integer);

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
    Q.ParamByName('source_type').AsSmallInt := AModel.SourceType;
    Q.ParamByName('document_no').AsWideString := AModel.DocumentNo;
    Q.ParamByName('description').AsWideString := AModel.Description;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('debit').AsBCD := AModel.Debit;
    Q.ParamByName('credit').AsBCD := AModel.Credit;
    Q.ParamByName('balance').AsBCD := AModel.Balance;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('source_type').AsSmallInts[AIndex] := AModel.SourceType;
    Q.ParamByName('document_no').AsWideStrings[AIndex] := AModel.DocumentNo;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('debit').AsBCDs[AIndex] := AModel.Debit;
    Q.ParamByName('credit').AsBCDs[AIndex] := AModel.Credit;
    Q.ParamByName('balance').AsBCDs[AIndex] := AModel.Balance;
  end;

  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetDate('transaction_date', AModel.TransactionDate);
  SetNullableParam(Q.ParamByName('source_id'), ftLargeint, AModel.SourceId, AIndex);
  SetNullableParam(Q.ParamByName('document_id'), ftLargeint, AModel.DocumentId, AIndex);
end;

function TAccAccountTransactionRepository.MapFromQuery(Q: TFDQuery): TAccAccountTransaction;
begin
  Result := TAccAccountTransaction.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  if Q.FieldByName('transaction_date').IsNull then
    Result.TransactionDate := 0
  else
    Result.TransactionDate := Q.FieldByName('transaction_date').AsDateTime;
  Result.SourceType := Q.FieldByName('source_type').AsInteger;
  Result.SourceId := Q.FieldByName('source_id').AsLargeInt;
  Result.DocumentId := Q.FieldByName('document_id').AsLargeInt;
  Result.DocumentNo := Q.FieldByName('document_no').AsString;
  Result.Description := Q.FieldByName('description').AsString;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.Debit := Q.FieldByName('debit').AsCurrency;
  Result.Credit := Q.FieldByName('credit').AsCurrency;
  Result.Balance := Q.FieldByName('balance').AsCurrency;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
end;

function TAccAccountTransactionRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TAccAccountTransaction) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TAccAccountTransactionRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TAccAccountTransaction>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TAccAccountTransaction>.Create(True);
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

function TAccAccountTransactionRepository.DoFindById(AId: TValue; ALock: Boolean): TAccAccountTransaction;
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

function TAccAccountTransactionRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TAccAccountTransaction;
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

procedure TAccAccountTransactionRepository.DoAdd(AModel: TAccAccountTransaction);
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

procedure TAccAccountTransactionRepository.DoAddBatch(AModels: TArray<TAccAccountTransaction>);
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

procedure TAccAccountTransactionRepository.DoUpdate(AModel: TAccAccountTransaction);
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

procedure TAccAccountTransactionRepository.DoUpdateBatch(AModels: TArray<TAccAccountTransaction>);
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

procedure TAccAccountTransactionRepository.DoDelete(AID: TValue);
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

procedure TAccAccountTransactionRepository.DoDelete(AModel: TAccAccountTransaction);
begin
  Delete(AModel.Id);
end;

procedure TAccAccountTransactionRepository.DoDeleteBatch(AModels: TArray<TAccAccountTransaction>);
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

procedure TAccAccountTransactionRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TAccAccountTransactionRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
