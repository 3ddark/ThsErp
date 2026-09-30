unit StkInventory.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, StkInventory;

type
  TStkInventoryRepository = class(TRepository<TStkInventory>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TStkInventory; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TStkInventory; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TStkInventory; override;

    // stk_image: resim view'a konmaz (grid '*' ile okuyabilir); kartla aynı transaction'da yazılır
    procedure LoadImage(AModel: TStkInventory);
    procedure SaveImage(AModel: TStkInventory);

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TStkInventory>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TStkInventory; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TStkInventory; override;

    procedure DoAdd(AModel: TStkInventory); override;
    procedure DoAddBatch(AModels: TArray<TStkInventory>); override;

    procedure DoUpdate(AModel: TStkInventory); override;
    procedure DoUpdateBatch(AModels: TArray<TStkInventory>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TStkInventory); override;
    procedure DoDeleteBatch(AModels: TArray<TStkInventory>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);

    function GetDefaultCurrency: string;
  end;

implementation

constructor TStkInventoryRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TStkInventoryRepository.GetDefaultCurrency: string;
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

procedure TStkInventoryRepository.LoadImage(AModel: TStkInventory);
var
  Q: TFDQuery;
begin
  if AModel = nil then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT image FROM public.stk_image WHERE stk_inventory_id = :stk_inventory_id';
    Q.ParamByName('stk_inventory_id').AsLargeInt := AModel.Id;
    LogQuery(Q, 'LoadImage');
    Q.Open;
    if Q.IsEmpty or Q.FieldByName('image').IsNull then
      AModel.Image := nil
    else
      AModel.Image := Q.FieldByName('image').AsBytes;
  finally
    Q.Free;
  end;
end;

// Boş resim = satır silinir
procedure TStkInventoryRepository.SaveImage(AModel: TStkInventory);
var
  Q: TFDQuery;
  LStream: TBytesStream;
begin
  if (AModel = nil) or not AModel.ImageLoaded then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    if Length(AModel.Image) = 0 then
    begin
      Q.SQL.Text := 'DELETE FROM public.stk_image WHERE stk_inventory_id = :stk_inventory_id';
      Q.ParamByName('stk_inventory_id').AsLargeInt := AModel.Id;
    end
    else
    begin
      Q.SQL.Text := 'INSERT INTO public.stk_image (stk_inventory_id, image) VALUES (:stk_inventory_id, :image) ' +
                    ' ON CONFLICT (stk_inventory_id) DO UPDATE SET image = EXCLUDED.image';
      Q.ParamByName('stk_inventory_id').AsLargeInt := AModel.Id;
      LStream := TBytesStream.Create(AModel.Image);
      try
        Q.ParamByName('image').LoadFromStream(LStream, ftBlob);
      finally
        LStream.Free;
      end;
    end;
    LogQuery(Q, 'SaveImage');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TStkInventoryRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TStkInventory) +
            ' (code, name, stk_group_id, stk_product_type_id, sys_uom_id, sellable, buying_price, buying_currency, buying_discount, sales_price, sales_currency, sales_discount, export_price, export_currency, special_code, brand, width, length, height, weight, supply_duration, min_stock_amount, sys_country_id, hs_no, diib_product_description, product_overview) ' +
            ' VALUES (:code, :name, :stk_group_id, :stk_product_type_id, :sys_uom_id, :sellable, :buying_price, :buying_currency, :buying_discount, :sales_price, :sales_currency, :sales_discount, :export_price, :export_currency, :special_code, :brand, :width, :length, :height, :weight, :supply_duration, :min_stock_amount, :sys_country_id, :hs_no, :diib_product_description, :product_overview)';
end;

function TStkInventoryRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TStkInventory) +
            ' SET code = :code, name = :name, stk_group_id = :stk_group_id, stk_product_type_id = :stk_product_type_id, sys_uom_id = :sys_uom_id, sellable = :sellable, buying_price = :buying_price, buying_currency = :buying_currency, buying_discount = :buying_discount, sales_price = :sales_price, sales_currency = :sales_currency, sales_discount = :sales_discount, export_price = :export_price, export_currency = :export_currency, special_code = :special_code, brand = :brand, width = :width, length = :length, height = :height, weight = :weight, supply_duration = :supply_duration, min_stock_amount = :min_stock_amount, sys_country_id = :sys_country_id, hs_no = :hs_no, diib_product_description = :diib_product_description, product_overview = :product_overview ' +
            ' WHERE id = :id';
end;

function TStkInventoryRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TStkInventory) + ' WHERE';
end;

procedure TStkInventoryRepository.SetInsertParams(Q: TFDQuery; AModel: TStkInventory; AIndex: Integer);

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
    Q.ParamByName('code').AsString := AModel.Code;
    Q.ParamByName('name').AsString := AModel.Name;
    Q.ParamByName('sellable').AsBoolean := AModel.Sellable;
    Q.ParamByName('buying_price').AsCurrency := AModel.BuyingPrice;
    Q.ParamByName('buying_discount').AsCurrency := AModel.BuyingDiscount;
    Q.ParamByName('sales_price').AsCurrency := AModel.SalesPrice;
    Q.ParamByName('sales_discount').AsCurrency := AModel.SalesDiscount;
    Q.ParamByName('export_price').AsCurrency := AModel.ExportPrice;
    Q.ParamByName('special_code').AsString := AModel.SpecialCode;
    Q.ParamByName('brand').AsString := AModel.Brand;
    Q.ParamByName('width').AsFloat := AModel.Width;
    Q.ParamByName('length').AsFloat := AModel.Length;
    Q.ParamByName('height').AsFloat := AModel.Height;
    Q.ParamByName('weight').AsFloat := AModel.Weight;
    Q.ParamByName('supply_duration').AsSmallInt := AModel.SupplyDuration;
    Q.ParamByName('min_stock_amount').AsFloat := AModel.MinStockAmount;
    Q.ParamByName('hs_no').AsString := AModel.HsNo;
    Q.ParamByName('diib_product_description').AsString := AModel.DiibProductDescription;
    Q.ParamByName('product_overview').AsString := AModel.ProductOverview;
  end
  else
  begin
    Q.ParamByName('code').AsStrings[AIndex] := AModel.Code;
    Q.ParamByName('name').AsStrings[AIndex] := AModel.Name;
    Q.ParamByName('sellable').AsBooleans[AIndex] := AModel.Sellable;
    Q.ParamByName('buying_price').AsCurrencys[AIndex] := AModel.BuyingPrice;
    Q.ParamByName('buying_discount').AsCurrencys[AIndex] := AModel.BuyingDiscount;
    Q.ParamByName('sales_price').AsCurrencys[AIndex] := AModel.SalesPrice;
    Q.ParamByName('sales_discount').AsCurrencys[AIndex] := AModel.SalesDiscount;
    Q.ParamByName('export_price').AsCurrencys[AIndex] := AModel.ExportPrice;
    Q.ParamByName('special_code').AsStrings[AIndex] := AModel.SpecialCode;
    Q.ParamByName('brand').AsStrings[AIndex] := AModel.Brand;
    Q.ParamByName('width').AsFloats[AIndex] := AModel.Width;
    Q.ParamByName('length').AsFloats[AIndex] := AModel.Length;
    Q.ParamByName('height').AsFloats[AIndex] := AModel.Height;
    Q.ParamByName('weight').AsFloats[AIndex] := AModel.Weight;
    Q.ParamByName('supply_duration').AsSmallInts[AIndex] := AModel.SupplyDuration;
    Q.ParamByName('min_stock_amount').AsFloats[AIndex] := AModel.MinStockAmount;
    Q.ParamByName('hs_no').AsStrings[AIndex] := AModel.HsNo;
    Q.ParamByName('diib_product_description').AsStrings[AIndex] := AModel.DiibProductDescription;
    Q.ParamByName('product_overview').AsStrings[AIndex] := AModel.ProductOverview;
  end;

  SetNullableParam(Q.ParamByName('stk_group_id'), ftLargeint, AModel.StkGroupId, AIndex);
  SetNullableParam(Q.ParamByName('stk_product_type_id'), ftLargeint, AModel.StkProductTypeId, AIndex);
  SetNullableParam(Q.ParamByName('sys_uom_id'), ftLargeint, AModel.SysUomId, AIndex);
  SetCode('buying_currency', AModel.BuyingCurrency);
  SetCode('sales_currency', AModel.SalesCurrency);
  SetCode('export_currency', AModel.ExportCurrency);
  SetNullableParam(Q.ParamByName('sys_country_id'), ftLargeint, AModel.SysCountryId, AIndex);
end;

procedure TStkInventoryRepository.SetUpdateParams(Q: TFDQuery; AModel: TStkInventory; AIndex: Integer);

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
    Q.ParamByName('code').AsString := AModel.Code;
    Q.ParamByName('name').AsString := AModel.Name;
    Q.ParamByName('sellable').AsBoolean := AModel.Sellable;
    Q.ParamByName('buying_price').AsCurrency := AModel.BuyingPrice;
    Q.ParamByName('buying_discount').AsCurrency := AModel.BuyingDiscount;
    Q.ParamByName('sales_price').AsCurrency := AModel.SalesPrice;
    Q.ParamByName('sales_discount').AsCurrency := AModel.SalesDiscount;
    Q.ParamByName('export_price').AsCurrency := AModel.ExportPrice;
    Q.ParamByName('special_code').AsString := AModel.SpecialCode;
    Q.ParamByName('brand').AsString := AModel.Brand;
    Q.ParamByName('width').AsFloat := AModel.Width;
    Q.ParamByName('length').AsFloat := AModel.Length;
    Q.ParamByName('height').AsFloat := AModel.Height;
    Q.ParamByName('weight').AsFloat := AModel.Weight;
    Q.ParamByName('supply_duration').AsSmallInt := AModel.SupplyDuration;
    Q.ParamByName('min_stock_amount').AsFloat := AModel.MinStockAmount;
    Q.ParamByName('hs_no').AsString := AModel.HsNo;
    Q.ParamByName('diib_product_description').AsString := AModel.DiibProductDescription;
    Q.ParamByName('product_overview').AsString := AModel.ProductOverview;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('code').AsStrings[AIndex] := AModel.Code;
    Q.ParamByName('name').AsStrings[AIndex] := AModel.Name;
    Q.ParamByName('sellable').AsBooleans[AIndex] := AModel.Sellable;
    Q.ParamByName('buying_price').AsCurrencys[AIndex] := AModel.BuyingPrice;
    Q.ParamByName('buying_discount').AsCurrencys[AIndex] := AModel.BuyingDiscount;
    Q.ParamByName('sales_price').AsCurrencys[AIndex] := AModel.SalesPrice;
    Q.ParamByName('sales_discount').AsCurrencys[AIndex] := AModel.SalesDiscount;
    Q.ParamByName('export_price').AsCurrencys[AIndex] := AModel.ExportPrice;
    Q.ParamByName('special_code').AsStrings[AIndex] := AModel.SpecialCode;
    Q.ParamByName('brand').AsStrings[AIndex] := AModel.Brand;
    Q.ParamByName('width').AsFloats[AIndex] := AModel.Width;
    Q.ParamByName('length').AsFloats[AIndex] := AModel.Length;
    Q.ParamByName('height').AsFloats[AIndex] := AModel.Height;
    Q.ParamByName('weight').AsFloats[AIndex] := AModel.Weight;
    Q.ParamByName('supply_duration').AsSmallInts[AIndex] := AModel.SupplyDuration;
    Q.ParamByName('min_stock_amount').AsFloats[AIndex] := AModel.MinStockAmount;
    Q.ParamByName('hs_no').AsStrings[AIndex] := AModel.HsNo;
    Q.ParamByName('diib_product_description').AsStrings[AIndex] := AModel.DiibProductDescription;
    Q.ParamByName('product_overview').AsStrings[AIndex] := AModel.ProductOverview;
  end;

  SetNullableParam(Q.ParamByName('stk_group_id'), ftLargeint, AModel.StkGroupId, AIndex);
  SetNullableParam(Q.ParamByName('stk_product_type_id'), ftLargeint, AModel.StkProductTypeId, AIndex);
  SetNullableParam(Q.ParamByName('sys_uom_id'), ftLargeint, AModel.SysUomId, AIndex);
  SetCode('buying_currency', AModel.BuyingCurrency);
  SetCode('sales_currency', AModel.SalesCurrency);
  SetCode('export_currency', AModel.ExportCurrency);
  SetNullableParam(Q.ParamByName('sys_country_id'), ftLargeint, AModel.SysCountryId, AIndex);
end;

function TStkInventoryRepository.MapFromQuery(Q: TFDQuery): TStkInventory;
begin
  Result := TStkInventory.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.Code := Q.FieldByName('code').AsString;
  Result.Name := Q.FieldByName('name').AsString;
  Result.StkGroupId := Q.FieldByName('stk_group_id').AsLargeInt;
  Result.StkProductTypeId := Q.FieldByName('stk_product_type_id').AsLargeInt;
  Result.SysUomId := Q.FieldByName('sys_uom_id').AsLargeInt;
  Result.Sellable := Q.FieldByName('sellable').AsBoolean;
  Result.BuyingPrice := Q.FieldByName('buying_price').AsCurrency;
  Result.BuyingCurrency := Q.FieldByName('buying_currency').AsString;
  Result.BuyingDiscount := Q.FieldByName('buying_discount').AsCurrency;
  Result.SalesPrice := Q.FieldByName('sales_price').AsCurrency;
  Result.SalesCurrency := Q.FieldByName('sales_currency').AsString;
  Result.SalesDiscount := Q.FieldByName('sales_discount').AsCurrency;
  Result.ExportPrice := Q.FieldByName('export_price').AsCurrency;
  Result.ExportCurrency := Q.FieldByName('export_currency').AsString;
  Result.SpecialCode := Q.FieldByName('special_code').AsString;
  Result.Brand := Q.FieldByName('brand').AsString;
  Result.Width := Q.FieldByName('width').AsFloat;
  Result.Length := Q.FieldByName('length').AsFloat;
  Result.Height := Q.FieldByName('height').AsFloat;
  Result.Weight := Q.FieldByName('weight').AsFloat;
  Result.SupplyDuration := Q.FieldByName('supply_duration').AsInteger;
  Result.MinStockAmount := Q.FieldByName('min_stock_amount').AsFloat;
  Result.SysCountryId := Q.FieldByName('sys_country_id').AsLargeInt;
  Result.HsNo := Q.FieldByName('hs_no').AsString;
  Result.DiibProductDescription := Q.FieldByName('diib_product_description').AsString;
  Result.ProductOverview := Q.FieldByName('product_overview').AsString;
  Result.GroupName := Q.FieldByName('group_name').AsString;
  Result.ProductTypeName := Q.FieldByName('product_type_name').AsString;
  Result.UomName := Q.FieldByName('uom_name').AsString;
  Result.CountryName := Q.FieldByName('country_name').AsString;
  Result.CurrentQuantity := Q.FieldByName('current_quantity').AsString;
  Result.AverageCost := Q.FieldByName('average_cost').AsString;
end;

function TStkInventoryRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id', 'locale']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TStkInventory) + ' WHERE locale = :locale ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
  Result.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
end;

function TStkInventoryRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TStkInventory>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TStkInventory>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, True);

    if Assigned(AFilter) and (AFilter.Count > 0) then
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    Q.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;

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

function TStkInventoryRepository.DoFindById(AId: TValue; ALock: Boolean): TStkInventory;
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
    Q.SQL.Text := Self.PrepareSelectFromView(Criteria, ALock, True, True);

    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    Q.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
    LogQuery(Q, 'DoFindById');
    Q.Open;

    if not Q.IsEmpty then
    begin
      Result := MapFromQuery(Q);
      LoadImage(Result);
    end;
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TStkInventoryRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TStkInventory;
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
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, True, True);

    for Criteria in AFilter do
      Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    Q.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
    LogQuery(Q, 'DoFindOne');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TStkInventoryRepository.DoAdd(AModel: TStkInventory);
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

  SaveImage(AModel);
end;

procedure TStkInventoryRepository.DoAddBatch(AModels: TArray<TStkInventory>);
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

procedure TStkInventoryRepository.DoUpdate(AModel: TStkInventory);
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

  SaveImage(AModel);
end;

procedure TStkInventoryRepository.DoUpdateBatch(AModels: TArray<TStkInventory>);
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

procedure TStkInventoryRepository.DoDelete(AID: TValue);
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

procedure TStkInventoryRepository.DoDelete(AModel: TStkInventory);
begin
  Delete(AModel.Id);
end;

procedure TStkInventoryRepository.DoDeleteBatch(AModels: TArray<TStkInventory>);
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

procedure TStkInventoryRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TStkInventoryRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
