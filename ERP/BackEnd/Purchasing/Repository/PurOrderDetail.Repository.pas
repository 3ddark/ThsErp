unit PurOrderDetail.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, PurOrderDetail;

type
  TPurOrderDetailRepository = class(TRepository<TPurOrderDetail>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TPurOrderDetail; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TPurOrderDetail; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TPurOrderDetail; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TPurOrderDetail>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TPurOrderDetail; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TPurOrderDetail; override;

    procedure DoAdd(AModel: TPurOrderDetail); override;
    procedure DoAddBatch(AModels: TArray<TPurOrderDetail>); override;

    procedure DoUpdate(AModel: TPurOrderDetail); override;
    procedure DoUpdateBatch(AModels: TArray<TPurOrderDetail>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TPurOrderDetail); override;
    procedure DoDeleteBatch(AModels: TArray<TPurOrderDetail>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    // Siparişlerin kalemleri tek sorguda (başlık + satır no sırasıyla): belge yükleme
    function FindByOrderIds(const AIds: TArray<Int64>): TObjectList<TPurOrderDetail>;
    function NextLineNo(AParentId: Int64): SmallInt;
    function GetInventoryDefaults(AInventoryId: Int64; out APrice: Currency; out ACurrency: string;
      out ADiscountRate, AVatRate: Currency): Boolean;
    // Stok kartının ölçü birimi kodu (satır formunda miktarın yanında gösterilir)
    function GetUomCode(AInventoryId: Int64): string;
  end;

implementation

constructor TPurOrderDetailRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TPurOrderDetailRepository.FindByOrderIds(const AIds: TArray<Int64>): TObjectList<TPurOrderDetail>;
var
  Q: TFDQuery;
  LIds: string;
  LId: Int64;
begin
  Result := TObjectList<TPurOrderDetail>.Create(True);
  LIds := '';
  for LId in AIds do
    if LId > 0 then
    begin
      if LIds <> '' then
        LIds := LIds + ',';
      LIds := LIds + IntToStr(LId);   // sayısal id: doğrudan yazılır
    end;
  if LIds = '' then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT v.* FROM ' + Self.GetFullViewName(TPurOrderDetail) + ' v ' +
                  ' WHERE v.pur_order_id IN (' + LIds + ') ORDER BY v.pur_order_id, v.line_no, v.id';
    LogQuery(Q, 'FindByOrderIds');
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

function TPurOrderDetailRepository.NextLineNo(AParentId: Int64): SmallInt;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(MAX(line_no), 0) + 1 AS v FROM public.pur_order_detail WHERE pur_order_id = :id';
    Q.ParamByName('id').AsLargeInt := AParentId;
    LogQuery(Q, 'NextLineNo');
    Q.Open;
    Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;

// Stok kartının alış fiyatı / para birimi / alış iskontosu ve geçerli KDV oranı (kart, yoksa grup)
function TPurOrderDetailRepository.GetInventoryDefaults(AInventoryId: Int64; out APrice: Currency; out ACurrency: string;
  out ADiscountRate, AVatRate: Currency): Boolean;
var
  Q: TFDQuery;
begin
  Result := False;
  APrice := 0;
  ACurrency := '';
  ADiscountRate := 0;
  AVatRate := 0;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT i.buying_price, i.buying_currency, i.buying_discount, COALESCE(i.vat_rate, g.vat_rate, 0) AS vat_rate ' +
                  '  FROM public.stk_inventory i ' +
                  '  JOIN public.stk_group g ON g.id = i.stk_group_id ' +
                  ' WHERE i.id = :id';
    Q.ParamByName('id').AsLargeInt := AInventoryId;
    LogQuery(Q, 'GetInventoryDefaults');
    Q.Open;
    if not Q.IsEmpty then
    begin
      Result := True;
      APrice := Q.FieldByName('buying_price').AsCurrency;
      ACurrency := Q.FieldByName('buying_currency').AsString;
      ADiscountRate := Q.FieldByName('buying_discount').AsCurrency;
      AVatRate := Q.FieldByName('vat_rate').AsCurrency;
    end;
  finally
    Q.Free;
  end;
end;

function TPurOrderDetailRepository.GetUomCode(AInventoryId: Int64): string;
var
  Q: TFDQuery;
begin
  Result := '';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT u.unit_code FROM public.stk_inventory i JOIN public.sys_uom u ON u.id = i.sys_uom_id WHERE i.id = :id';
    Q.ParamByName('id').AsLargeInt := AInventoryId;
    LogQuery(Q, 'GetUomCode');
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.Fields[0].AsString;
  finally
    Q.Free;
  end;
end;

function TPurOrderDetailRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TPurOrderDetail) +
            ' (pur_order_id, line_no, stk_inventory_id, quantity, unit_price, discount_rate, vat_rate, gross_amount, discount_amount, net_amount, vat_amount, total_amount, received_quantity, delivery_date, pur_request_detail_id, description) ' +
            ' VALUES (:pur_order_id, :line_no, :stk_inventory_id, :quantity, :unit_price, :discount_rate, :vat_rate, :gross_amount, :discount_amount, :net_amount, :vat_amount, :total_amount, :received_quantity, :delivery_date, :pur_request_detail_id, :description)';
end;

function TPurOrderDetailRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TPurOrderDetail) +
            ' SET pur_order_id = :pur_order_id, line_no = :line_no, stk_inventory_id = :stk_inventory_id, quantity = :quantity, unit_price = :unit_price, discount_rate = :discount_rate, vat_rate = :vat_rate, gross_amount = :gross_amount, discount_amount = :discount_amount, net_amount = :net_amount, vat_amount = :vat_amount, total_amount = :total_amount, received_quantity = :received_quantity, delivery_date = :delivery_date, pur_request_detail_id = :pur_request_detail_id, description = :description ' +
            ' WHERE id = :id';
end;

function TPurOrderDetailRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TPurOrderDetail) + ' WHERE';
end;

procedure TPurOrderDetailRepository.SetInsertParams(Q: TFDQuery; AModel: TPurOrderDetail; AIndex: Integer);

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
    Q.ParamByName('line_no').AsSmallInt := AModel.LineNo;
    Q.ParamByName('quantity').AsBCD := AModel.Quantity;
    Q.ParamByName('unit_price').AsBCD := AModel.UnitPrice;
    Q.ParamByName('discount_rate').AsBCD := AModel.DiscountRate;
    Q.ParamByName('vat_rate').AsBCD := AModel.VatRate;
    Q.ParamByName('gross_amount').AsBCD := AModel.GrossAmount;
    Q.ParamByName('discount_amount').AsBCD := AModel.DiscountAmount;
    Q.ParamByName('net_amount').AsBCD := AModel.NetAmount;
    Q.ParamByName('vat_amount').AsBCD := AModel.VatAmount;
    Q.ParamByName('total_amount').AsBCD := AModel.TotalAmount;
    Q.ParamByName('received_quantity').AsBCD := AModel.ReceivedQuantity;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('line_no').AsSmallInts[AIndex] := AModel.LineNo;
    Q.ParamByName('quantity').AsBCDs[AIndex] := AModel.Quantity;
    Q.ParamByName('unit_price').AsBCDs[AIndex] := AModel.UnitPrice;
    Q.ParamByName('discount_rate').AsBCDs[AIndex] := AModel.DiscountRate;
    Q.ParamByName('vat_rate').AsBCDs[AIndex] := AModel.VatRate;
    Q.ParamByName('gross_amount').AsBCDs[AIndex] := AModel.GrossAmount;
    Q.ParamByName('discount_amount').AsBCDs[AIndex] := AModel.DiscountAmount;
    Q.ParamByName('net_amount').AsBCDs[AIndex] := AModel.NetAmount;
    Q.ParamByName('vat_amount').AsBCDs[AIndex] := AModel.VatAmount;
    Q.ParamByName('total_amount').AsBCDs[AIndex] := AModel.TotalAmount;
    Q.ParamByName('received_quantity').AsBCDs[AIndex] := AModel.ReceivedQuantity;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('pur_order_id'), ftLargeint, AModel.PurOrderId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetDate('delivery_date', AModel.DeliveryDate);
  SetNullableParam(Q.ParamByName('pur_request_detail_id'), ftLargeint, AModel.PurRequestDetailId, AIndex);
end;

procedure TPurOrderDetailRepository.SetUpdateParams(Q: TFDQuery; AModel: TPurOrderDetail; AIndex: Integer);

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
    Q.ParamByName('line_no').AsSmallInt := AModel.LineNo;
    Q.ParamByName('quantity').AsBCD := AModel.Quantity;
    Q.ParamByName('unit_price').AsBCD := AModel.UnitPrice;
    Q.ParamByName('discount_rate').AsBCD := AModel.DiscountRate;
    Q.ParamByName('vat_rate').AsBCD := AModel.VatRate;
    Q.ParamByName('gross_amount').AsBCD := AModel.GrossAmount;
    Q.ParamByName('discount_amount').AsBCD := AModel.DiscountAmount;
    Q.ParamByName('net_amount').AsBCD := AModel.NetAmount;
    Q.ParamByName('vat_amount').AsBCD := AModel.VatAmount;
    Q.ParamByName('total_amount').AsBCD := AModel.TotalAmount;
    Q.ParamByName('received_quantity').AsBCD := AModel.ReceivedQuantity;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('line_no').AsSmallInts[AIndex] := AModel.LineNo;
    Q.ParamByName('quantity').AsBCDs[AIndex] := AModel.Quantity;
    Q.ParamByName('unit_price').AsBCDs[AIndex] := AModel.UnitPrice;
    Q.ParamByName('discount_rate').AsBCDs[AIndex] := AModel.DiscountRate;
    Q.ParamByName('vat_rate').AsBCDs[AIndex] := AModel.VatRate;
    Q.ParamByName('gross_amount').AsBCDs[AIndex] := AModel.GrossAmount;
    Q.ParamByName('discount_amount').AsBCDs[AIndex] := AModel.DiscountAmount;
    Q.ParamByName('net_amount').AsBCDs[AIndex] := AModel.NetAmount;
    Q.ParamByName('vat_amount').AsBCDs[AIndex] := AModel.VatAmount;
    Q.ParamByName('total_amount').AsBCDs[AIndex] := AModel.TotalAmount;
    Q.ParamByName('received_quantity').AsBCDs[AIndex] := AModel.ReceivedQuantity;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('pur_order_id'), ftLargeint, AModel.PurOrderId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetDate('delivery_date', AModel.DeliveryDate);
  SetNullableParam(Q.ParamByName('pur_request_detail_id'), ftLargeint, AModel.PurRequestDetailId, AIndex);
end;

function TPurOrderDetailRepository.MapFromQuery(Q: TFDQuery): TPurOrderDetail;
begin
  Result := TPurOrderDetail.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.PurOrderId := Q.FieldByName('pur_order_id').AsLargeInt;
  Result.LineNo := Q.FieldByName('line_no').AsInteger;
  Result.StkInventoryId := Q.FieldByName('stk_inventory_id').AsLargeInt;
  Result.Quantity := Q.FieldByName('quantity').AsCurrency;
  Result.UnitPrice := Q.FieldByName('unit_price').AsCurrency;
  Result.DiscountRate := Q.FieldByName('discount_rate').AsCurrency;
  Result.VatRate := Q.FieldByName('vat_rate').AsCurrency;
  Result.GrossAmount := Q.FieldByName('gross_amount').AsCurrency;
  Result.DiscountAmount := Q.FieldByName('discount_amount').AsCurrency;
  Result.NetAmount := Q.FieldByName('net_amount').AsCurrency;
  Result.VatAmount := Q.FieldByName('vat_amount').AsCurrency;
  Result.TotalAmount := Q.FieldByName('total_amount').AsCurrency;
  Result.ReceivedQuantity := Q.FieldByName('received_quantity').AsCurrency;
  if Q.FieldByName('delivery_date').IsNull then
    Result.DeliveryDate := 0
  else
    Result.DeliveryDate := Q.FieldByName('delivery_date').AsDateTime;
  Result.PurRequestDetailId := Q.FieldByName('pur_request_detail_id').AsLargeInt;
  Result.Description := Q.FieldByName('description').AsString;
  Result.OrderNo := Q.FieldByName('order_no').AsString;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.InventoryCode := Q.FieldByName('inventory_code').AsString;
  Result.InventoryName := Q.FieldByName('inventory_name').AsString;
  Result.UomCode := Q.FieldByName('uom_code').AsString;
  Result.RequestNo := Q.FieldByName('request_no').AsString;
end;

function TPurOrderDetailRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TPurOrderDetail) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TPurOrderDetailRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TPurOrderDetail>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TPurOrderDetail>.Create(True);
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

function TPurOrderDetailRepository.DoFindById(AId: TValue; ALock: Boolean): TPurOrderDetail;
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

function TPurOrderDetailRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TPurOrderDetail;
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

procedure TPurOrderDetailRepository.DoAdd(AModel: TPurOrderDetail);
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

procedure TPurOrderDetailRepository.DoAddBatch(AModels: TArray<TPurOrderDetail>);
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

procedure TPurOrderDetailRepository.DoUpdate(AModel: TPurOrderDetail);
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

procedure TPurOrderDetailRepository.DoUpdateBatch(AModels: TArray<TPurOrderDetail>);
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

procedure TPurOrderDetailRepository.DoDelete(AID: TValue);
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

procedure TPurOrderDetailRepository.DoDelete(AModel: TPurOrderDetail);
begin
  Delete(AModel.Id);
end;

procedure TPurOrderDetailRepository.DoDeleteBatch(AModels: TArray<TPurOrderDetail>);
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

procedure TPurOrderDetailRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TPurOrderDetailRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
