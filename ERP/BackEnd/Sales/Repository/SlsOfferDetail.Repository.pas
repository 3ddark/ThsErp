unit SlsOfferDetail.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, SlsOfferDetail;

type
  TSlsOfferDetailRepository = class(TRepository<TSlsOfferDetail>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSlsOfferDetail; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSlsOfferDetail; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSlsOfferDetail; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSlsOfferDetail>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSlsOfferDetail; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSlsOfferDetail; override;

    procedure DoAdd(AModel: TSlsOfferDetail); override;
    procedure DoAddBatch(AModels: TArray<TSlsOfferDetail>); override;

    procedure DoUpdate(AModel: TSlsOfferDetail); override;
    procedure DoUpdateBatch(AModels: TArray<TSlsOfferDetail>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSlsOfferDetail); override;
    procedure DoDeleteBatch(AModels: TArray<TSlsOfferDetail>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function NextLineNo(AParentId: Int64): SmallInt;
    // Teklif(ler)in kalemleri tek sorguda, teklif + satır no sırasıyla (belge yükleme)
    function FindByOfferIds(const AOfferIds: TArray<Int64>): TObjectList<TSlsOfferDetail>;
    // Tanımlı KDV oranları (acc_set_tax_rate, artan)
    function GetVatRates: TArray<Currency>;
    // Stok kartının ölçü birimi kodu
    function GetUomCode(AInventoryId: Int64): string;
  end;

implementation

constructor TSlsOfferDetailRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSlsOfferDetailRepository.GetVatRates: TArray<Currency>;
var
  Q: TFDQuery;
  n: Integer;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT DISTINCT tax_rate FROM public.acc_set_tax_rate ORDER BY tax_rate';
    LogQuery(Q, 'GetVatRates');
    Q.Open;
    SetLength(Result, Q.RecordCount);
    n := 0;
    while not Q.Eof do
    begin
      Result[n] := Q.Fields[0].AsCurrency;
      Inc(n);
      Q.Next;
    end;
    SetLength(Result, n);
  finally
    Q.Free;
  end;
end;

function TSlsOfferDetailRepository.GetUomCode(AInventoryId: Int64): string;
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

function TSlsOfferDetailRepository.FindByOfferIds(const AOfferIds: TArray<Int64>): TObjectList<TSlsOfferDetail>;
var
  Q: TFDQuery;
  LIds: string;
  LId: Int64;
begin
  Result := TObjectList<TSlsOfferDetail>.Create(True);
  LIds := '';
  for LId in AOfferIds do
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
    Q.SQL.Text := 'SELECT v.* FROM ' + Self.GetFullViewName(TSlsOfferDetail) + ' v ' +
                  ' WHERE v.sls_offer_id IN (' + LIds + ') ORDER BY v.sls_offer_id, v.line_no, v.id';
    LogQuery(Q, 'FindByOfferIds');
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

function TSlsOfferDetailRepository.NextLineNo(AParentId: Int64): SmallInt;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(MAX(line_no), 0) + 1 AS v FROM public.sls_offer_detail WHERE sls_offer_id = :id';
    Q.ParamByName('id').AsLargeInt := AParentId;
    LogQuery(Q, 'NextLineNo');
    Q.Open;
    Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;

function TSlsOfferDetailRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSlsOfferDetail) +
            ' (sls_offer_id, line_no, stk_inventory_id, quantity, unit_price, discount_rate, vat_rate, gross_amount, discount_amount, net_amount, vat_amount, total_amount, ordered_quantity, description) ' +
            ' VALUES (:sls_offer_id, :line_no, :stk_inventory_id, :quantity, :unit_price, :discount_rate, :vat_rate, :gross_amount, :discount_amount, :net_amount, :vat_amount, :total_amount, :ordered_quantity, :description)';
end;

function TSlsOfferDetailRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSlsOfferDetail) +
            ' SET sls_offer_id = :sls_offer_id, line_no = :line_no, stk_inventory_id = :stk_inventory_id, quantity = :quantity, unit_price = :unit_price, discount_rate = :discount_rate, vat_rate = :vat_rate, gross_amount = :gross_amount, discount_amount = :discount_amount, net_amount = :net_amount, vat_amount = :vat_amount, total_amount = :total_amount, ordered_quantity = :ordered_quantity, description = :description ' +
            ' WHERE id = :id';
end;

function TSlsOfferDetailRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSlsOfferDetail) + ' WHERE';
end;

procedure TSlsOfferDetailRepository.SetInsertParams(Q: TFDQuery; AModel: TSlsOfferDetail; AIndex: Integer);

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
    Q.ParamByName('ordered_quantity').AsBCD := AModel.OrderedQuantity;
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
    Q.ParamByName('ordered_quantity').AsBCDs[AIndex] := AModel.OrderedQuantity;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('sls_offer_id'), ftLargeint, AModel.SlsOfferId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
end;

procedure TSlsOfferDetailRepository.SetUpdateParams(Q: TFDQuery; AModel: TSlsOfferDetail; AIndex: Integer);

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
    Q.ParamByName('ordered_quantity').AsBCD := AModel.OrderedQuantity;
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
    Q.ParamByName('ordered_quantity').AsBCDs[AIndex] := AModel.OrderedQuantity;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('sls_offer_id'), ftLargeint, AModel.SlsOfferId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
end;

function TSlsOfferDetailRepository.MapFromQuery(Q: TFDQuery): TSlsOfferDetail;
begin
  Result := TSlsOfferDetail.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.SlsOfferId := Q.FieldByName('sls_offer_id').AsLargeInt;
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
  Result.OrderedQuantity := Q.FieldByName('ordered_quantity').AsCurrency;
  Result.Description := Q.FieldByName('description').AsString;
  Result.OfferNo := Q.FieldByName('offer_no').AsString;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.InventoryCode := Q.FieldByName('inventory_code').AsString;
  Result.InventoryName := Q.FieldByName('inventory_name').AsString;
  Result.UomCode := Q.FieldByName('uom_code').AsString;
end;

function TSlsOfferDetailRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TSlsOfferDetail) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSlsOfferDetailRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSlsOfferDetail>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSlsOfferDetail>.Create(True);
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

function TSlsOfferDetailRepository.DoFindById(AId: TValue; ALock: Boolean): TSlsOfferDetail;
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

function TSlsOfferDetailRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSlsOfferDetail;
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

procedure TSlsOfferDetailRepository.DoAdd(AModel: TSlsOfferDetail);
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

procedure TSlsOfferDetailRepository.DoAddBatch(AModels: TArray<TSlsOfferDetail>);
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

procedure TSlsOfferDetailRepository.DoUpdate(AModel: TSlsOfferDetail);
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

procedure TSlsOfferDetailRepository.DoUpdateBatch(AModels: TArray<TSlsOfferDetail>);
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

procedure TSlsOfferDetailRepository.DoDelete(AID: TValue);
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

procedure TSlsOfferDetailRepository.DoDelete(AModel: TSlsOfferDetail);
begin
  Delete(AModel.Id);
end;

procedure TSlsOfferDetailRepository.DoDeleteBatch(AModels: TArray<TSlsOfferDetail>);
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

procedure TSlsOfferDetailRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TSlsOfferDetailRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
