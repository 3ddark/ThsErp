unit StkTransaction.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, StkTransaction;

type
  TStkTransactionRepository = class(TRepository<TStkTransaction>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TStkTransaction; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TStkTransaction; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TStkTransaction; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TStkTransaction>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TStkTransaction; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TStkTransaction; override;

    procedure DoAdd(AModel: TStkTransaction); override;
    procedure DoAddBatch(AModels: TArray<TStkTransaction>); override;

    procedure DoUpdate(AModel: TStkTransaction); override;
    procedure DoUpdateBatch(AModels: TArray<TStkTransaction>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TStkTransaction); override;
    procedure DoDeleteBatch(AModels: TArray<TStkTransaction>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TStkTransactionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TStkTransactionRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TStkTransaction) +
            ' (transaction_date, transaction_type, stk_inventory_id, from_stk_warehouse_id, to_stk_warehouse_id, quantity, amount, amount_foreign, currency, is_opening, description, dispatch_id, production_id) ' +
            ' VALUES (:transaction_date, :transaction_type, :stk_inventory_id, :from_stk_warehouse_id, :to_stk_warehouse_id, :quantity, :amount, :amount_foreign, :currency, :is_opening, :description, :dispatch_id, :production_id)';
end;

function TStkTransactionRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TStkTransaction) +
            ' SET transaction_date = :transaction_date, transaction_type = :transaction_type, stk_inventory_id = :stk_inventory_id, from_stk_warehouse_id = :from_stk_warehouse_id, to_stk_warehouse_id = :to_stk_warehouse_id, quantity = :quantity, amount = :amount, amount_foreign = :amount_foreign, currency = :currency, is_opening = :is_opening, description = :description, dispatch_id = :dispatch_id, production_id = :production_id ' +
            ' WHERE id = :id';
end;

function TStkTransactionRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TStkTransaction) + ' WHERE';
end;

procedure TStkTransactionRepository.SetInsertParams(Q: TFDQuery; AModel: TStkTransaction; AIndex: Integer);

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


  // Kod ile bağlanan FK: boş değer NULL gönderilir
  procedure SetCode(const AName, AValue: string);
  begin
    Q.ParamByName(AName).DataType := ftString;
    if AValue <> '' then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsString := AValue
      else
        Q.ParamByName(AName).AsStrings[AIndex] := AValue;
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
    Q.ParamByName('quantity').AsCurrency := AModel.Quantity;
    Q.ParamByName('amount').AsCurrency := AModel.Amount;
    Q.ParamByName('amount_foreign').AsCurrency := AModel.AmountForeign;
    Q.ParamByName('is_opening').AsBoolean := AModel.IsOpening;
    Q.ParamByName('description').AsString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('transaction_type').AsSmallInts[AIndex] := AModel.TransactionType;
    Q.ParamByName('quantity').AsCurrencys[AIndex] := AModel.Quantity;
    Q.ParamByName('amount').AsCurrencys[AIndex] := AModel.Amount;
    Q.ParamByName('amount_foreign').AsCurrencys[AIndex] := AModel.AmountForeign;
    Q.ParamByName('is_opening').AsBooleans[AIndex] := AModel.IsOpening;
    Q.ParamByName('description').AsStrings[AIndex] := AModel.Description;
  end;

  SetDate('transaction_date', AModel.TransactionDate);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('from_stk_warehouse_id'), ftLargeint, AModel.FromStkWarehouseId, AIndex);
  SetNullableParam(Q.ParamByName('to_stk_warehouse_id'), ftLargeint, AModel.ToStkWarehouseId, AIndex);
  SetCode('currency', AModel.Currency);
  SetNullableParam(Q.ParamByName('dispatch_id'), ftLargeint, AModel.DispatchId, AIndex);
  SetNullableParam(Q.ParamByName('production_id'), ftLargeint, AModel.ProductionId, AIndex);
end;

procedure TStkTransactionRepository.SetUpdateParams(Q: TFDQuery; AModel: TStkTransaction; AIndex: Integer);

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


  // Kod ile bağlanan FK: boş değer NULL gönderilir
  procedure SetCode(const AName, AValue: string);
  begin
    Q.ParamByName(AName).DataType := ftString;
    if AValue <> '' then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsString := AValue
      else
        Q.ParamByName(AName).AsStrings[AIndex] := AValue;
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
    Q.ParamByName('quantity').AsCurrency := AModel.Quantity;
    Q.ParamByName('amount').AsCurrency := AModel.Amount;
    Q.ParamByName('amount_foreign').AsCurrency := AModel.AmountForeign;
    Q.ParamByName('is_opening').AsBoolean := AModel.IsOpening;
    Q.ParamByName('description').AsString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('transaction_type').AsSmallInts[AIndex] := AModel.TransactionType;
    Q.ParamByName('quantity').AsCurrencys[AIndex] := AModel.Quantity;
    Q.ParamByName('amount').AsCurrencys[AIndex] := AModel.Amount;
    Q.ParamByName('amount_foreign').AsCurrencys[AIndex] := AModel.AmountForeign;
    Q.ParamByName('is_opening').AsBooleans[AIndex] := AModel.IsOpening;
    Q.ParamByName('description').AsStrings[AIndex] := AModel.Description;
  end;

  SetDate('transaction_date', AModel.TransactionDate);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('from_stk_warehouse_id'), ftLargeint, AModel.FromStkWarehouseId, AIndex);
  SetNullableParam(Q.ParamByName('to_stk_warehouse_id'), ftLargeint, AModel.ToStkWarehouseId, AIndex);
  SetCode('currency', AModel.Currency);
  SetNullableParam(Q.ParamByName('dispatch_id'), ftLargeint, AModel.DispatchId, AIndex);
  SetNullableParam(Q.ParamByName('production_id'), ftLargeint, AModel.ProductionId, AIndex);
end;

function TStkTransactionRepository.MapFromQuery(Q: TFDQuery): TStkTransaction;
begin
  Result := TStkTransaction.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  if Q.FieldByName('transaction_date').IsNull then
    Result.TransactionDate := 0
  else
    Result.TransactionDate := Q.FieldByName('transaction_date').AsDateTime;
  Result.TransactionType := Q.FieldByName('transaction_type').AsInteger;
  Result.StkInventoryId := Q.FieldByName('stk_inventory_id').AsLargeInt;
  Result.FromStkWarehouseId := Q.FieldByName('from_stk_warehouse_id').AsLargeInt;
  Result.ToStkWarehouseId := Q.FieldByName('to_stk_warehouse_id').AsLargeInt;
  Result.Quantity := Q.FieldByName('quantity').AsCurrency;
  Result.Amount := Q.FieldByName('amount').AsCurrency;
  Result.AmountForeign := Q.FieldByName('amount_foreign').AsCurrency;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.IsOpening := Q.FieldByName('is_opening').AsBoolean;
  Result.Description := Q.FieldByName('description').AsString;
  Result.DispatchId := Q.FieldByName('dispatch_id').AsLargeInt;
  Result.ProductionId := Q.FieldByName('production_id').AsLargeInt;
  Result.InventoryName := Q.FieldByName('inventory_name').AsString;
  Result.FromWarehouseName := Q.FieldByName('from_warehouse_name').AsString;
  Result.ToWarehouseName := Q.FieldByName('to_warehouse_name').AsString;
  Result.InventoryCode := Q.FieldByName('inventory_code').AsString;
end;

function TStkTransactionRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TStkTransaction) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TStkTransactionRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TStkTransaction>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TStkTransaction>.Create(True);
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

function TStkTransactionRepository.DoFindById(AId: TValue; ALock: Boolean): TStkTransaction;
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

function TStkTransactionRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TStkTransaction;
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

procedure TStkTransactionRepository.DoAdd(AModel: TStkTransaction);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql + ' RETURNING id';
    SetInsertParams(Q, AModel);
    LogQuery(Q, 'DoAdd');
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;
end;

procedure TStkTransactionRepository.DoAddBatch(AModels: TArray<TStkTransaction>);
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

    LogQuery(Q, 'DoAddBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TStkTransactionRepository.DoUpdate(AModel: TStkTransaction);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    SetUpdateParams(Q, AModel);
    LogQuery(Q, 'DoUpdate');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TStkTransactionRepository.DoUpdateBatch(AModels: TArray<TStkTransaction>);
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

    LogQuery(Q, 'DoUpdateBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TStkTransactionRepository.DoDelete(AID: TValue);
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

procedure TStkTransactionRepository.DoDelete(AModel: TStkTransaction);
begin
  Delete(AModel.Id);
end;

procedure TStkTransactionRepository.DoDeleteBatch(AModels: TArray<TStkTransaction>);
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

procedure TStkTransactionRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TStkTransactionRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
