unit StkTransaction.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections, System.Rtti,
  FireDAC.Comp.Client, FireDAC.Stan.Param, Entity, Repository, StkTransaction, FilterCriterion;

type
  TStkTransactionRepository = class(TRepository<TStkTransaction>)
  protected
    function PrepareSelectSql: string; virtual;
    function PrepareAddSql: string; virtual;
    function PrepareUpdateSql: string; virtual;
    function PrepareDeleteSql: string; virtual;

    procedure SetModelParams(Q: TFDQuery; AModel: TStkTransaction; AIndex: Integer = -1);
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function FindById(AId: TValue; ALock: Boolean = False): TStkTransaction; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TStkTransaction; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TStkTransaction>; override;

    procedure Add(AModel: TStkTransaction); override;
    procedure AddBatch(AModels: TArray<TStkTransaction>); override;

    procedure Update(AModel: TStkTransaction); override;
    procedure UpdateBatch(AModels: TArray<TStkTransaction>); override;

    procedure Delete(AID: TValue); override;
    procedure Delete(AModel: TStkTransaction); override;
    procedure DeleteBatch(AModels: TArray<TStkTransaction>); override;
  end;

implementation

constructor TStkTransactionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TStkTransactionRepository.PrepareSelectSql: string;
begin
  Result := 'SELECT id, sku, quantity, amount, amount_foreign, currency, direction, transaction_date, from_warehouse, to_warehouse, is_opening, description, dispatch_id, production_id FROM public.' + Self.GetTableName(TStkTransaction);
end;

function TStkTransactionRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TStkTransaction) +
    ' (sku, quantity, amount, amount_foreign, currency, direction, transaction_date, from_warehouse, to_warehouse, is_opening, description, dispatch_id, production_id)' +
    ' VALUES (:sku, :quantity, :amount, :amount_foreign, :currency, :direction, :transaction_date, :from_warehouse, :to_warehouse, :is_opening, :description, :dispatch_id, :production_id)';
end;

function TStkTransactionRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TStkTransaction) +
    ' SET sku = :sku, quantity = :quantity, amount = :amount, amount_foreign = :amount_foreign, currency = :currency, direction = :direction,' +
    ' transaction_date = :transaction_date, from_warehouse = :from_warehouse, to_warehouse = :to_warehouse, is_opening = :is_opening,' +
    ' description = :description, dispatch_id = :dispatch_id, production_id = :production_id WHERE id = :id';
end;

function TStkTransactionRepository.PrepareDeleteSql: string;
begin
  Result := 'DELETE FROM public.' + Self.GetTableName(TStkTransaction) + ' WHERE id = :id';
end;

procedure TStkTransactionRepository.SetModelParams(Q: TFDQuery; AModel: TStkTransaction; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('sku').AsString := AModel.Sku;
    Q.ParamByName('quantity').AsFloat := AModel.Quantity;
    Q.ParamByName('amount').AsFloat := AModel.Amount;
    Q.ParamByName('amount_foreign').AsFloat := AModel.AmountForeign;
    Q.ParamByName('currency').AsString := AModel.Currency;
    Q.ParamByName('direction').AsInteger := AModel.Direction;
    Q.ParamByName('transaction_date').AsDateTime := AModel.TransactionDate;

    if AModel.FromWarehouseId > 0 then Q.ParamByName('from_warehouse').AsLargeInt := AModel.FromWarehouseId else Q.ParamByName('from_warehouse').Clear;
    if AModel.ToWarehouseId > 0 then Q.ParamByName('to_warehouse').AsLargeInt := AModel.ToWarehouseId else Q.ParamByName('to_warehouse').Clear;
    Q.ParamByName('is_opening').AsBoolean := AModel.IsOpening;
    Q.ParamByName('description').AsString := AModel.Description;
    if AModel.DispatchId > 0 then Q.ParamByName('dispatch_id').AsLargeInt := AModel.DispatchId else Q.ParamByName('dispatch_id').Clear;
    if AModel.ProductionId > 0 then Q.ParamByName('production_id').AsLargeInt := AModel.ProductionId else Q.ParamByName('production_id').Clear;

    if (AModel.Id > 0) and (Q.FindParam('id') <> nil) then
      Q.ParamByName('id').AsLargeInt := AModel.Id;
  end
  else
  begin
    Q.ParamByName('sku').AsStrings[AIndex] := AModel.Sku;
    Q.ParamByName('quantity').AsFloats[AIndex] := AModel.Quantity;
    Q.ParamByName('amount').AsFloats[AIndex] := AModel.Amount;
    Q.ParamByName('amount_foreign').AsFloats[AIndex] := AModel.AmountForeign;
    Q.ParamByName('currency').AsStrings[AIndex] := AModel.Currency;
    Q.ParamByName('direction').AsIntegers[AIndex] := AModel.Direction;
    Q.ParamByName('transaction_date').AsDateTimes[AIndex] := AModel.TransactionDate;

    if AModel.FromWarehouseId > 0 then Q.ParamByName('from_warehouse').AsLargeInts[AIndex] := AModel.FromWarehouseId else Q.ParamByName('from_warehouse').Clear(AIndex);
    if AModel.ToWarehouseId > 0 then Q.ParamByName('to_warehouse').AsLargeInts[AIndex] := AModel.ToWarehouseId else Q.ParamByName('to_warehouse').Clear(AIndex);
    Q.ParamByName('is_opening').AsBooleans[AIndex] := AModel.IsOpening;
    Q.ParamByName('description').AsStrings[AIndex] := AModel.Description;
    if AModel.DispatchId > 0 then Q.ParamByName('dispatch_id').AsLargeInts[AIndex] := AModel.DispatchId else Q.ParamByName('dispatch_id').Clear(AIndex);
    if AModel.ProductionId > 0 then Q.ParamByName('production_id').AsLargeInts[AIndex] := AModel.ProductionId else Q.ParamByName('production_id').Clear(AIndex);

    if (AModel.Id > 0) and (Q.FindParam('id') <> nil) then
      Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
  end;
end;

function TStkTransactionRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM public.stk_transaction WHERE 1=1 ';
end;

procedure TStkTransactionRepository.Add(AModel: TStkTransaction);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql + ' RETURNING id';
    SetModelParams(Q, AModel);
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;
end;

procedure TStkTransactionRepository.AddBatch(AModels: TArray<TStkTransaction>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      SetModelParams(Q, AModels[I], I);

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TStkTransactionRepository.Update(AModel: TStkTransaction);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    SetModelParams(Q, AModel);
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TStkTransactionRepository.UpdateBatch(AModels: TArray<TStkTransaction>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      SetModelParams(Q, AModels[I], I);

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TStkTransactionRepository.Delete(AID: TValue);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql;
    Q.ParamByName('id').AsLargeInt := AID.AsInt64;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TStkTransactionRepository.Delete(AModel: TStkTransaction);
begin
  Delete(AModel.Id);
end;

procedure TStkTransactionRepository.DeleteBatch(AModels: TArray<TStkTransaction>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AModels[I].Id;

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

function TStkTransactionRepository.FindById(AId: TValue; ALock: Boolean): TStkTransaction;
var
  Q: TFDQuery;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSelectSql + ' WHERE id = :id';
    if ALock then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE';

    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    Q.Open;

    if not Q.IsEmpty then
    begin
      Result := TStkTransaction.Create;
      Result.Id := Q.FieldByName('id').AsLargeInt;
      Result.Sku := Q.FieldByName('sku').AsString;
      Result.Quantity := Q.FieldByName('quantity').AsFloat;
      Result.Amount := Q.FieldByName('amount').AsFloat;
      Result.AmountForeign := Q.FieldByName('amount_foreign').AsFloat;
      Result.Currency := Q.FieldByName('currency').AsString;
      Result.Direction := Q.FieldByName('direction').AsInteger;
      Result.TransactionDate := Q.FieldByName('transaction_date').AsDateTime;
      Result.FromWarehouseId := Q.FieldByName('from_warehouse').AsLargeInt;
      Result.ToWarehouseId := Q.FieldByName('to_warehouse').AsLargeInt;
      Result.IsOpening := Q.FieldByName('is_opening').AsBoolean;
      Result.Description := Q.FieldByName('description').AsString;
      Result.DispatchId := Q.FieldByName('dispatch_id').AsLargeInt;
      Result.ProductionId := Q.FieldByName('production_id').AsLargeInt;
    end;
  finally
    Q.Free;
  end;
end;

function TStkTransactionRepository.FindOne(AFilter: TFilterCriteria; ALock: Boolean): TStkTransaction;
var
  Q: TFDQuery;
  Criterion: TFilterCriterion;
begin
  Result := nil;
  if not Assigned(AFilter) or (AFilter.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSelectSql + ' WHERE 1=1';

    for Criterion in AFilter do
      Q.SQL.Text := Q.SQL.Text + ' AND ' + Criterion.FieldName + ' ' + Criterion.Operator + ' :' + Criterion.FieldName;

    if ALock then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE';

    Q.SQL.Text := Q.SQL.Text + ' LIMIT 1';

    for Criterion in AFilter do
      Q.ParamByName(Criterion.FieldName).Value := Criterion.Value.AsVariant;

    Q.Open;

    if not Q.IsEmpty then
    begin
      Result := TStkTransaction.Create;
      Result.Id := Q.FieldByName('id').AsLargeInt;
      Result.Sku := Q.FieldByName('sku').AsString;
      Result.Quantity := Q.FieldByName('quantity').AsFloat;
      Result.Amount := Q.FieldByName('amount').AsFloat;
      Result.AmountForeign := Q.FieldByName('amount_foreign').AsFloat;
      Result.Currency := Q.FieldByName('currency').AsString;
      Result.Direction := Q.FieldByName('direction').AsInteger;
      Result.TransactionDate := Q.FieldByName('transaction_date').AsDateTime;
      Result.FromWarehouseId := Q.FieldByName('from_warehouse').AsLargeInt;
      Result.ToWarehouseId := Q.FieldByName('to_warehouse').AsLargeInt;
      Result.IsOpening := Q.FieldByName('is_opening').AsBoolean;
      Result.Description := Q.FieldByName('description').AsString;
      Result.DispatchId := Q.FieldByName('dispatch_id').AsLargeInt;
      Result.ProductionId := Q.FieldByName('production_id').AsLargeInt;
    end;
  finally
    Q.Free;
  end;
end;

function TStkTransactionRepository.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TStkTransaction>;
var
  Q: TFDQuery;
  Item: TStkTransaction;
  Criterion: TFilterCriterion;
begin
  Result := TObjectList<TStkTransaction>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSelectSql + ' WHERE 1=1';

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for Criterion in AFilter do
        Q.SQL.Text := Q.SQL.Text + ' AND ' + Criterion.FieldName + ' ' + Criterion.Operator + ' :' + Criterion.FieldName;
    end;

    if ALock then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE';

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for Criterion in AFilter do
        Q.ParamByName(Criterion.FieldName).Value := Criterion.Value.AsVariant;
    end;

    Q.Open;
    while not Q.Eof do
    begin
      Item := TStkTransaction.Create;
      Item.Id := Q.FieldByName('id').AsLargeInt;
      Item.Sku := Q.FieldByName('sku').AsString;
      Item.Quantity := Q.FieldByName('quantity').AsFloat;
      Item.Amount := Q.FieldByName('amount').AsFloat;
      Item.AmountForeign := Q.FieldByName('amount_foreign').AsFloat;
      Item.Currency := Q.FieldByName('currency').AsString;
      Item.Direction := Q.FieldByName('direction').AsInteger;
      Item.TransactionDate := Q.FieldByName('transaction_date').AsDateTime;
      Item.FromWarehouseId := Q.FieldByName('from_warehouse').AsLargeInt;
      Item.ToWarehouseId := Q.FieldByName('to_warehouse').AsLargeInt;
      Item.IsOpening := Q.FieldByName('is_opening').AsBoolean;
      Item.Description := Q.FieldByName('description').AsString;
      Item.DispatchId := Q.FieldByName('dispatch_id').AsLargeInt;
      Item.ProductionId := Q.FieldByName('production_id').AsLargeInt;
      Result.Add(Item);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

end.