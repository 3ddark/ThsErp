unit StkInventorySummary.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, StkInventorySummary;

type
  TStkInventorySummaryRepository = class(TRepository<TStkInventorySummary>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TStkInventorySummary; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TStkInventorySummary; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TStkInventorySummary; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TStkInventorySummary>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TStkInventorySummary; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TStkInventorySummary; override;

    procedure DoAdd(AModel: TStkInventorySummary); override;
    procedure DoAddBatch(AModels: TArray<TStkInventorySummary>); override;

    procedure DoUpdate(AModel: TStkInventorySummary); override;
    procedure DoUpdateBatch(AModels: TArray<TStkInventorySummary>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TStkInventorySummary); override;
    procedure DoDeleteBatch(AModels: TArray<TStkInventorySummary>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);

    // Özet satırını stk_transaction kayıtlarından yeniden hesaplar (upsert).
    //   mevcut = açılış + giriş - çıkış (transfer toplamı değiştirmez)
    //   ortalama maliyet = (açılış + giriş tutarı) / (açılış + giriş miktarı)
    //   son alış = açılış olmayan en son giriş hareketi
    procedure Recalculate(AInventoryId: Int64);
  end;

implementation

constructor TStkInventorySummaryRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TStkInventorySummaryRepository.Recalculate(AInventoryId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text :=
    'INSERT INTO public.stk_inventory_summary AS s ' +
    '      (stk_inventory_id, current_quantity, average_cost, opening_quantity, opening_amount, opening_price, ' +
    '       incoming_quantity, incoming_amount, outgoing_quantity, outgoing_amount, ' +
    '       last_buy_date, last_buy_quantity, last_buy_price, last_buy_currency, last_buy_exchange_rate) ' +
    'SELECT i.id, ' +
    '       COALESCE(a.opening_quantity, 0) + COALESCE(a.incoming_quantity, 0) - COALESCE(a.outgoing_quantity, 0), ' +
    '       CASE WHEN COALESCE(a.opening_quantity, 0) + COALESCE(a.incoming_quantity, 0) > 0 ' +
    '            THEN (COALESCE(a.opening_amount, 0) + COALESCE(a.incoming_amount, 0)) ' +
    '                 / (COALESCE(a.opening_quantity, 0) + COALESCE(a.incoming_quantity, 0)) ' +
    '            ELSE 0 END, ' +
    '       COALESCE(a.opening_quantity, 0), COALESCE(a.opening_amount, 0), ' +
    '       CASE WHEN COALESCE(a.opening_quantity, 0) > 0 THEN a.opening_amount / a.opening_quantity ELSE 0 END, ' +
    '       COALESCE(a.incoming_quantity, 0), COALESCE(a.incoming_amount, 0), ' +
    '       COALESCE(a.outgoing_quantity, 0), COALESCE(a.outgoing_amount, 0), ' +
    '       lb.transaction_date, COALESCE(lb.quantity, 0), ' +
    '       COALESCE(lb.amount / NULLIF(lb.quantity, 0), 0), lb.currency, ' +
    '       COALESCE(lb.amount / NULLIF(lb.amount_foreign, 0), 0) ' +
    '  FROM public.stk_inventory i ' +
    '  LEFT JOIN LATERAL ( ' +
    '        SELECT sum(t.quantity) FILTER (WHERE t.transaction_type = 1 AND t.is_opening) AS opening_quantity, ' +
    '               sum(t.amount)   FILTER (WHERE t.transaction_type = 1 AND t.is_opening) AS opening_amount, ' +
    '               sum(t.quantity) FILTER (WHERE t.transaction_type = 1 AND NOT t.is_opening) AS incoming_quantity, ' +
    '               sum(t.amount)   FILTER (WHERE t.transaction_type = 1 AND NOT t.is_opening) AS incoming_amount, ' +
    '               sum(t.quantity) FILTER (WHERE t.transaction_type = 2) AS outgoing_quantity, ' +
    '               sum(t.amount)   FILTER (WHERE t.transaction_type = 2) AS outgoing_amount ' +
    '          FROM public.stk_transaction t ' +
    '         WHERE t.stk_inventory_id = i.id) a ON true ' +
    '  LEFT JOIN LATERAL ( ' +
    '        SELECT t.transaction_date, t.quantity, t.amount, t.amount_foreign, t.currency ' +
    '          FROM public.stk_transaction t ' +
    '         WHERE t.stk_inventory_id = i.id AND t.transaction_type = 1 AND NOT t.is_opening ' +
    '         ORDER BY t.transaction_date DESC, t.id DESC ' +
    '         LIMIT 1) lb ON true ' +
    ' WHERE i.id = :stk_inventory_id ' +
    'ON CONFLICT (stk_inventory_id) DO UPDATE SET ' +
    '       current_quantity = EXCLUDED.current_quantity, average_cost = EXCLUDED.average_cost, ' +
    '       opening_quantity = EXCLUDED.opening_quantity, opening_amount = EXCLUDED.opening_amount, ' +
    '       opening_price = EXCLUDED.opening_price, ' +
    '       incoming_quantity = EXCLUDED.incoming_quantity, incoming_amount = EXCLUDED.incoming_amount, ' +
    '       outgoing_quantity = EXCLUDED.outgoing_quantity, outgoing_amount = EXCLUDED.outgoing_amount, ' +
    '       last_buy_date = EXCLUDED.last_buy_date, last_buy_quantity = EXCLUDED.last_buy_quantity, ' +
    '       last_buy_price = EXCLUDED.last_buy_price, last_buy_currency = EXCLUDED.last_buy_currency, ' +
    '       last_buy_exchange_rate = EXCLUDED.last_buy_exchange_rate ';
    Q.ParamByName('stk_inventory_id').AsLargeInt := AInventoryId;
    LogQuery(Q, 'Recalculate');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TStkInventorySummaryRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TStkInventorySummary) +
            ' (stk_inventory_id, current_quantity, average_cost, opening_quantity, opening_price, opening_amount, incoming_quantity, incoming_amount, outgoing_quantity, outgoing_amount, last_buy_date, last_buy_quantity, last_buy_price, last_buy_currency, last_buy_exchange_rate) ' +
            ' VALUES (:stk_inventory_id, :current_quantity, :average_cost, :opening_quantity, :opening_price, :opening_amount, :incoming_quantity, :incoming_amount, :outgoing_quantity, :outgoing_amount, :last_buy_date, :last_buy_quantity, :last_buy_price, :last_buy_currency, :last_buy_exchange_rate)';
end;

function TStkInventorySummaryRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TStkInventorySummary) +
            ' SET stk_inventory_id = :stk_inventory_id, current_quantity = :current_quantity, average_cost = :average_cost, opening_quantity = :opening_quantity, opening_price = :opening_price, opening_amount = :opening_amount, incoming_quantity = :incoming_quantity, incoming_amount = :incoming_amount, outgoing_quantity = :outgoing_quantity, outgoing_amount = :outgoing_amount, last_buy_date = :last_buy_date, last_buy_quantity = :last_buy_quantity, last_buy_price = :last_buy_price, last_buy_currency = :last_buy_currency, last_buy_exchange_rate = :last_buy_exchange_rate ' +
            ' WHERE id = :id';
end;

function TStkInventorySummaryRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TStkInventorySummary) + ' WHERE';
end;

procedure TStkInventorySummaryRepository.SetInsertParams(Q: TFDQuery; AModel: TStkInventorySummary; AIndex: Integer);

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
    Q.ParamByName('current_quantity').AsCurrency := AModel.CurrentQuantity;
    Q.ParamByName('average_cost').AsCurrency := AModel.AverageCost;
    Q.ParamByName('opening_quantity').AsCurrency := AModel.OpeningQuantity;
    Q.ParamByName('opening_price').AsCurrency := AModel.OpeningPrice;
    Q.ParamByName('opening_amount').AsCurrency := AModel.OpeningAmount;
    Q.ParamByName('incoming_quantity').AsCurrency := AModel.IncomingQuantity;
    Q.ParamByName('incoming_amount').AsCurrency := AModel.IncomingAmount;
    Q.ParamByName('outgoing_quantity').AsCurrency := AModel.OutgoingQuantity;
    Q.ParamByName('outgoing_amount').AsCurrency := AModel.OutgoingAmount;
    Q.ParamByName('last_buy_quantity').AsCurrency := AModel.LastBuyQuantity;
    Q.ParamByName('last_buy_price').AsCurrency := AModel.LastBuyPrice;
    Q.ParamByName('last_buy_currency').AsString := AModel.LastBuyCurrency;
    Q.ParamByName('last_buy_exchange_rate').AsCurrency := AModel.LastBuyExchangeRate;
  end
  else
  begin
    Q.ParamByName('current_quantity').AsCurrencys[AIndex] := AModel.CurrentQuantity;
    Q.ParamByName('average_cost').AsCurrencys[AIndex] := AModel.AverageCost;
    Q.ParamByName('opening_quantity').AsCurrencys[AIndex] := AModel.OpeningQuantity;
    Q.ParamByName('opening_price').AsCurrencys[AIndex] := AModel.OpeningPrice;
    Q.ParamByName('opening_amount').AsCurrencys[AIndex] := AModel.OpeningAmount;
    Q.ParamByName('incoming_quantity').AsCurrencys[AIndex] := AModel.IncomingQuantity;
    Q.ParamByName('incoming_amount').AsCurrencys[AIndex] := AModel.IncomingAmount;
    Q.ParamByName('outgoing_quantity').AsCurrencys[AIndex] := AModel.OutgoingQuantity;
    Q.ParamByName('outgoing_amount').AsCurrencys[AIndex] := AModel.OutgoingAmount;
    Q.ParamByName('last_buy_quantity').AsCurrencys[AIndex] := AModel.LastBuyQuantity;
    Q.ParamByName('last_buy_price').AsCurrencys[AIndex] := AModel.LastBuyPrice;
    Q.ParamByName('last_buy_currency').AsStrings[AIndex] := AModel.LastBuyCurrency;
    Q.ParamByName('last_buy_exchange_rate').AsCurrencys[AIndex] := AModel.LastBuyExchangeRate;
  end;

  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetDate('last_buy_date', AModel.LastBuyDate);
end;

procedure TStkInventorySummaryRepository.SetUpdateParams(Q: TFDQuery; AModel: TStkInventorySummary; AIndex: Integer);

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
    Q.ParamByName('current_quantity').AsCurrency := AModel.CurrentQuantity;
    Q.ParamByName('average_cost').AsCurrency := AModel.AverageCost;
    Q.ParamByName('opening_quantity').AsCurrency := AModel.OpeningQuantity;
    Q.ParamByName('opening_price').AsCurrency := AModel.OpeningPrice;
    Q.ParamByName('opening_amount').AsCurrency := AModel.OpeningAmount;
    Q.ParamByName('incoming_quantity').AsCurrency := AModel.IncomingQuantity;
    Q.ParamByName('incoming_amount').AsCurrency := AModel.IncomingAmount;
    Q.ParamByName('outgoing_quantity').AsCurrency := AModel.OutgoingQuantity;
    Q.ParamByName('outgoing_amount').AsCurrency := AModel.OutgoingAmount;
    Q.ParamByName('last_buy_quantity').AsCurrency := AModel.LastBuyQuantity;
    Q.ParamByName('last_buy_price').AsCurrency := AModel.LastBuyPrice;
    Q.ParamByName('last_buy_currency').AsString := AModel.LastBuyCurrency;
    Q.ParamByName('last_buy_exchange_rate').AsCurrency := AModel.LastBuyExchangeRate;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('current_quantity').AsCurrencys[AIndex] := AModel.CurrentQuantity;
    Q.ParamByName('average_cost').AsCurrencys[AIndex] := AModel.AverageCost;
    Q.ParamByName('opening_quantity').AsCurrencys[AIndex] := AModel.OpeningQuantity;
    Q.ParamByName('opening_price').AsCurrencys[AIndex] := AModel.OpeningPrice;
    Q.ParamByName('opening_amount').AsCurrencys[AIndex] := AModel.OpeningAmount;
    Q.ParamByName('incoming_quantity').AsCurrencys[AIndex] := AModel.IncomingQuantity;
    Q.ParamByName('incoming_amount').AsCurrencys[AIndex] := AModel.IncomingAmount;
    Q.ParamByName('outgoing_quantity').AsCurrencys[AIndex] := AModel.OutgoingQuantity;
    Q.ParamByName('outgoing_amount').AsCurrencys[AIndex] := AModel.OutgoingAmount;
    Q.ParamByName('last_buy_quantity').AsCurrencys[AIndex] := AModel.LastBuyQuantity;
    Q.ParamByName('last_buy_price').AsCurrencys[AIndex] := AModel.LastBuyPrice;
    Q.ParamByName('last_buy_currency').AsStrings[AIndex] := AModel.LastBuyCurrency;
    Q.ParamByName('last_buy_exchange_rate').AsCurrencys[AIndex] := AModel.LastBuyExchangeRate;
  end;

  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetDate('last_buy_date', AModel.LastBuyDate);
end;

function TStkInventorySummaryRepository.MapFromQuery(Q: TFDQuery): TStkInventorySummary;
begin
  Result := TStkInventorySummary.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.StkInventoryId := Q.FieldByName('stk_inventory_id').AsLargeInt;
  Result.CurrentQuantity := Q.FieldByName('current_quantity').AsCurrency;
  Result.AverageCost := Q.FieldByName('average_cost').AsCurrency;
  Result.OpeningQuantity := Q.FieldByName('opening_quantity').AsCurrency;
  Result.OpeningPrice := Q.FieldByName('opening_price').AsCurrency;
  Result.OpeningAmount := Q.FieldByName('opening_amount').AsCurrency;
  Result.IncomingQuantity := Q.FieldByName('incoming_quantity').AsCurrency;
  Result.IncomingAmount := Q.FieldByName('incoming_amount').AsCurrency;
  Result.OutgoingQuantity := Q.FieldByName('outgoing_quantity').AsCurrency;
  Result.OutgoingAmount := Q.FieldByName('outgoing_amount').AsCurrency;
  if Q.FieldByName('last_buy_date').IsNull then
    Result.LastBuyDate := 0
  else
    Result.LastBuyDate := Q.FieldByName('last_buy_date').AsDateTime;
  Result.LastBuyQuantity := Q.FieldByName('last_buy_quantity').AsCurrency;
  Result.LastBuyPrice := Q.FieldByName('last_buy_price').AsCurrency;
  Result.LastBuyCurrency := Q.FieldByName('last_buy_currency').AsString;
  Result.LastBuyExchangeRate := Q.FieldByName('last_buy_exchange_rate').AsCurrency;
  Result.InventoryName := Q.FieldByName('inventory_name').AsString;
  Result.InventoryCode := Q.FieldByName('inventory_code').AsString;
end;

function TStkInventorySummaryRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TStkInventorySummary) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TStkInventorySummaryRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TStkInventorySummary>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TStkInventorySummary>.Create(True);
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

function TStkInventorySummaryRepository.DoFindById(AId: TValue; ALock: Boolean): TStkInventorySummary;
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

function TStkInventorySummaryRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TStkInventorySummary;
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

procedure TStkInventorySummaryRepository.DoAdd(AModel: TStkInventorySummary);
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

procedure TStkInventorySummaryRepository.DoAddBatch(AModels: TArray<TStkInventorySummary>);
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

procedure TStkInventorySummaryRepository.DoUpdate(AModel: TStkInventorySummary);
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

procedure TStkInventorySummaryRepository.DoUpdateBatch(AModels: TArray<TStkInventorySummary>);
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

procedure TStkInventorySummaryRepository.DoDelete(AID: TValue);
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

procedure TStkInventorySummaryRepository.DoDelete(AModel: TStkInventorySummary);
begin
  Delete(AModel.Id);
end;

procedure TStkInventorySummaryRepository.DoDeleteBatch(AModels: TArray<TStkInventorySummary>);
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

procedure TStkInventorySummaryRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TStkInventorySummaryRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
