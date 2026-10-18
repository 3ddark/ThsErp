unit SlsDispatch.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, SlsDispatch;

type
  // e-İrsaliye kuralları için seçilen kayıtların bayrakları (bulunmayan kayıt: aktif değil / tür 0)
  TSlsEDespatchRules = record
    ProfileKind: Integer;
    ProfileActive: Boolean;
    ProfileCode: string;
    VehicleIsTrailer, VehicleActive: Boolean;
    Trailer1IsTrailer, Trailer1Active: Boolean;
    Trailer2IsTrailer, Trailer2Active: Boolean;
    Driver1Active, Driver2Active: Boolean;
  end;

  TSlsDispatchRepository = class(TRepository<TSlsDispatch>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSlsDispatch; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSlsDispatch; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSlsDispatch; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSlsDispatch>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSlsDispatch; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSlsDispatch; override;

    procedure DoAdd(AModel: TSlsDispatch); override;
    procedure DoAddBatch(AModels: TArray<TSlsDispatch>); override;

    procedure DoUpdate(AModel: TSlsDispatch); override;
    procedure DoUpdateBatch(AModels: TArray<TSlsDispatch>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSlsDispatch); override;
    procedure DoDeleteBatch(AModels: TArray<TSlsDispatch>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function NextDocumentNo(const APrefix: string): string;
    function LineCount(ADispatchId: Int64): Integer;
    function InvoicedQuantity(ADispatchId: Int64): Currency;
    procedure SyncStockTransactions(ADispatchId: Int64);
    function InventoryIdsOfDispatch(ADispatchId: Int64): TArray<Int64>;
    function GetDefaultCurrency: string;
    // Durum faturalardan: kalemi olan ve tüm kalemleri tamamen faturalanmış irsaliye 2 (kapandı), değilse 1 (bekliyor)
    procedure RefreshInvoiceStatus(ADispatchId: Int64);
    function ReadEDespatchRules(AHeader: TSlsDispatch): TSlsEDespatchRules;
    // e-belge durumu (silme / tek kalem yolu kilidi)
    function EInvStatus(ADispatchId: Int64): Integer;
    // aktif senaryonun id'si (yoksa 0)
    function EInvProfileIdByCode(const ACode: string): Int64;
  end;

implementation

constructor TSlsDispatchRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSlsDispatchRepository.NextDocumentNo(const APrefix: string): string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT :prefix || lpad((COALESCE(MAX(CAST(substr(dispatch_no, length(:prefix) + 1) AS bigint)), 0) + 1)::text, 6, ''0'') AS v ' +
                  '  FROM public.sls_dispatch WHERE dispatch_no ~ (''^'' || :prefix || ''[0-9]+$'')';
    Q.ParamByName('prefix').DataType := ftWideString;
    Q.ParamByName('prefix').AsWideString := APrefix;
    LogQuery(Q, 'NextDocumentNo');
    Q.Open;
    Result := Q.FieldByName('v').AsString;
  finally
    Q.Free;
  end;
end;

function TSlsDispatchRepository.LineCount(ADispatchId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) AS v FROM public.sls_dispatch_detail WHERE sls_dispatch_id = :id';
    Q.ParamByName('id').AsLargeInt := ADispatchId;
    LogQuery(Q, 'LineCount');
    Q.Open;
    Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;

function TSlsDispatchRepository.InvoicedQuantity(ADispatchId: Int64): Currency;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(sum(f.quantity), 0) AS v FROM public.sls_invoice_detail f ' +
                  '  JOIN public.sls_dispatch_detail d ON d.id = f.sls_dispatch_detail_id WHERE d.sls_dispatch_id = :id';
    Q.ParamByName('id').AsLargeInt := ADispatchId;
    LogQuery(Q, 'InvoicedQuantity');
    Q.Open;
    Result := Q.FieldByName('v').AsCurrency;
  finally
    Q.Free;
  end;
end;

procedure TSlsDispatchRepository.SyncStockTransactions(ADispatchId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.stk_transaction t ' +
                  '   SET transaction_date = p.dispatch_date, from_stk_warehouse_id = p.stk_warehouse_id, currency = p.currency, ' +
                  '       description = p.dispatch_no ' +
                  '  FROM public.sls_dispatch_detail d JOIN public.sls_dispatch p ON p.id = d.sls_dispatch_id ' +
                  ' WHERE t.sls_dispatch_detail_id = d.id AND p.id = :id';
    Q.ParamByName('id').AsLargeInt := ADispatchId;
    LogQuery(Q, 'SyncStockTransactions');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TSlsDispatchRepository.InventoryIdsOfDispatch(ADispatchId: Int64): TArray<Int64>;
var
  Q: TFDQuery;
begin
  Result := [];
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT DISTINCT stk_inventory_id FROM public.sls_dispatch_detail WHERE sls_dispatch_id = :id';
    Q.ParamByName('id').AsLargeInt := ADispatchId;
    LogQuery(Q, 'InventoryIdsOfDispatch');
    Q.Open;
    while not Q.Eof do
    begin
      Result := Result + [Q.Fields[0].AsLargeInt];
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TSlsDispatchRepository.RefreshInvoiceStatus(ADispatchId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.sls_dispatch p ' +
                  '   SET status = CASE WHEN EXISTS (SELECT 1 FROM public.sls_dispatch_detail d WHERE d.sls_dispatch_id = p.id) ' +
                  '                      AND NOT EXISTS (SELECT 1 FROM public.sls_dispatch_detail d ' +
                  '                                       WHERE d.sls_dispatch_id = p.id ' +
                  '                                         AND d.quantity > COALESCE((SELECT sum(i.quantity) FROM public.sls_invoice_detail i ' +
                  '                                                                     WHERE i.sls_dispatch_detail_id = d.id), 0)) ' +
                  '                     THEN 2 ELSE 1 END ' +
                  ' WHERE p.id = :id';
    Q.ParamByName('id').AsLargeInt := ADispatchId;
    LogQuery(Q, 'RefreshInvoiceStatus');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TSlsDispatchRepository.ReadEDespatchRules(AHeader: TSlsDispatch): TSlsEDespatchRules;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text :=
      'SELECT COALESCE(p.document_kind, 0) AS profile_kind, COALESCE(p.is_active, false) AS profile_active, ' +
      '       COALESCE(p.code, '''') AS profile_code, ' +
      '       COALESCE(v.is_trailer, false) AS v_trailer, COALESCE(v.is_active, false) AS v_active, ' +
      '       COALESCE(t1.is_trailer, false) AS t1_trailer, COALESCE(t1.is_active, false) AS t1_active, ' +
      '       COALESCE(t2.is_trailer, false) AS t2_trailer, COALESCE(t2.is_active, false) AS t2_active, ' +
      '       COALESCE(d1.is_active, false) AS d1_active, COALESCE(d2.is_active, false) AS d2_active ' +
      '  FROM (SELECT 1) x ' +
      '  LEFT JOIN public.einv_profile p ON p.id = :profile ' +
      '  LEFT JOIN public.einv_vehicle v ON v.id = :vehicle ' +
      '  LEFT JOIN public.einv_vehicle t1 ON t1.id = :trailer1 ' +
      '  LEFT JOIN public.einv_vehicle t2 ON t2.id = :trailer2 ' +
      '  LEFT JOIN public.einv_driver d1 ON d1.id = :driver1 ' +
      '  LEFT JOIN public.einv_driver d2 ON d2.id = :driver2';
    Q.ParamByName('profile').AsLargeInt := AHeader.EinvProfileId;
    Q.ParamByName('vehicle').AsLargeInt := AHeader.EinvVehicleId;
    Q.ParamByName('trailer1').AsLargeInt := AHeader.Trailer1EinvVehicleId;
    Q.ParamByName('trailer2').AsLargeInt := AHeader.Trailer2EinvVehicleId;
    Q.ParamByName('driver1').AsLargeInt := AHeader.Driver1EinvDriverId;
    Q.ParamByName('driver2').AsLargeInt := AHeader.Driver2EinvDriverId;
    LogQuery(Q, 'ReadEDespatchRules');
    Q.Open;
    Result.ProfileKind := Q.FieldByName('profile_kind').AsInteger;
    Result.ProfileActive := Q.FieldByName('profile_active').AsBoolean;
    Result.ProfileCode := Q.FieldByName('profile_code').AsString;
    Result.VehicleIsTrailer := Q.FieldByName('v_trailer').AsBoolean;
    Result.VehicleActive := Q.FieldByName('v_active').AsBoolean;
    Result.Trailer1IsTrailer := Q.FieldByName('t1_trailer').AsBoolean;
    Result.Trailer1Active := Q.FieldByName('t1_active').AsBoolean;
    Result.Trailer2IsTrailer := Q.FieldByName('t2_trailer').AsBoolean;
    Result.Trailer2Active := Q.FieldByName('t2_active').AsBoolean;
    Result.Driver1Active := Q.FieldByName('d1_active').AsBoolean;
    Result.Driver2Active := Q.FieldByName('d2_active').AsBoolean;
  finally
    Q.Free;
  end;
end;

function TSlsDispatchRepository.EInvStatus(ADispatchId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(einv_status, 0) AS v FROM public.sls_dispatch WHERE id = :id';
    Q.ParamByName('id').AsLargeInt := ADispatchId;
    LogQuery(Q, 'EInvStatus');
    Q.Open;
    Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;

function TSlsDispatchRepository.EInvProfileIdByCode(const ACode: string): Int64;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT id FROM public.einv_profile WHERE code = :code AND is_active';
    Q.ParamByName('code').AsWideString := ACode;
    LogQuery(Q, 'EInvProfileIdByCode');
    Q.Open;
    if Q.IsEmpty then
      Result := 0
    else
      Result := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;
end;

function TSlsDispatchRepository.GetDefaultCurrency: string;
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

function TSlsDispatchRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSlsDispatch) +
            ' (dispatch_no, dispatch_date, acc_account_id, stk_warehouse_id, sls_order_id, currency, description, status, ' +
            '  einv_profile_id, carrier_acc_account_id, einv_vehicle_id, trailer1_einv_vehicle_id, trailer2_einv_vehicle_id, driver1_einv_driver_id, driver2_einv_driver_id, einv_uuid, einv_status, despatch_time) ' +
            ' VALUES (:dispatch_no, :dispatch_date, :acc_account_id, :stk_warehouse_id, :sls_order_id, :currency, :description, :status, ' +
            '  :einv_profile_id, :carrier_acc_account_id, :einv_vehicle_id, :trailer1_einv_vehicle_id, :trailer2_einv_vehicle_id, :driver1_einv_driver_id, :driver2_einv_driver_id, CAST(:einv_uuid AS uuid), :einv_status, :despatch_time)';
end;

function TSlsDispatchRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSlsDispatch) +
            ' SET dispatch_no = :dispatch_no, dispatch_date = :dispatch_date, acc_account_id = :acc_account_id, stk_warehouse_id = :stk_warehouse_id, sls_order_id = :sls_order_id, currency = :currency, description = :description, status = :status, ' +
            '     einv_profile_id = :einv_profile_id, carrier_acc_account_id = :carrier_acc_account_id, einv_vehicle_id = :einv_vehicle_id, trailer1_einv_vehicle_id = :trailer1_einv_vehicle_id, trailer2_einv_vehicle_id = :trailer2_einv_vehicle_id, driver1_einv_driver_id = :driver1_einv_driver_id, driver2_einv_driver_id = :driver2_einv_driver_id, einv_uuid = CAST(:einv_uuid AS uuid), einv_status = :einv_status, despatch_time = :despatch_time ' +
            ' WHERE id = :id';
end;

function TSlsDispatchRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSlsDispatch) + ' WHERE';
end;

procedure TSlsDispatchRepository.SetInsertParams(Q: TFDQuery; AModel: TSlsDispatch; AIndex: Integer);

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

  // uuid kolonu: boş = NULL (SQL tarafında CAST(:x AS uuid))
  procedure SetUuid(const AName: string; const AValue: string);
  begin
    Q.ParamByName(AName).DataType := ftWideString;
    if AValue <> '' then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsWideString := AValue
      else
        Q.ParamByName(AName).AsWideStrings[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;

  // saat kolonu: 0 = NULL
  procedure SetTime(const AName: string; AValue: TTime);
  begin
    Q.ParamByName(AName).DataType := ftTime;
    if AValue > 0 then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsTime := AValue
      else
        Q.ParamByName(AName).AsTimes[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('dispatch_no').AsWideString := AModel.DispatchNo;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('description').AsWideString := AModel.Description;
    Q.ParamByName('status').AsSmallInt := AModel.Status;
  end
  else
  begin
    Q.ParamByName('dispatch_no').AsWideStrings[AIndex] := AModel.DispatchNo;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
    Q.ParamByName('status').AsSmallInts[AIndex] := AModel.Status;
  end;

  SetDate('dispatch_date', AModel.DispatchDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetNullableParam(Q.ParamByName('stk_warehouse_id'), ftLargeint, AModel.StkWarehouseId, AIndex);
  SetNullableParam(Q.ParamByName('sls_order_id'), ftLargeint, AModel.SlsOrderId, AIndex);
  SetNullableParam(Q.ParamByName('einv_profile_id'), ftLargeint, AModel.EinvProfileId, AIndex);
  SetNullableParam(Q.ParamByName('carrier_acc_account_id'), ftLargeint, AModel.CarrierAccAccountId, AIndex);
  SetNullableParam(Q.ParamByName('einv_vehicle_id'), ftLargeint, AModel.EinvVehicleId, AIndex);
  SetNullableParam(Q.ParamByName('trailer1_einv_vehicle_id'), ftLargeint, AModel.Trailer1EinvVehicleId, AIndex);
  SetNullableParam(Q.ParamByName('trailer2_einv_vehicle_id'), ftLargeint, AModel.Trailer2EinvVehicleId, AIndex);
  SetNullableParam(Q.ParamByName('driver1_einv_driver_id'), ftLargeint, AModel.Driver1EinvDriverId, AIndex);
  SetNullableParam(Q.ParamByName('driver2_einv_driver_id'), ftLargeint, AModel.Driver2EinvDriverId, AIndex);
  SetNullableParam(Q.ParamByName('einv_status'), ftInteger, AModel.EinvStatus, AIndex);
  SetUuid('einv_uuid', AModel.EinvUuid);
  SetTime('despatch_time', AModel.DespatchTime);
end;

procedure TSlsDispatchRepository.SetUpdateParams(Q: TFDQuery; AModel: TSlsDispatch; AIndex: Integer);

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

  // uuid kolonu: boş = NULL (SQL tarafında CAST(:x AS uuid))
  procedure SetUuid(const AName: string; const AValue: string);
  begin
    Q.ParamByName(AName).DataType := ftWideString;
    if AValue <> '' then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsWideString := AValue
      else
        Q.ParamByName(AName).AsWideStrings[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;

  // saat kolonu: 0 = NULL
  procedure SetTime(const AName: string; AValue: TTime);
  begin
    Q.ParamByName(AName).DataType := ftTime;
    if AValue > 0 then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsTime := AValue
      else
        Q.ParamByName(AName).AsTimes[AIndex] := AValue;
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
    Q.ParamByName('dispatch_no').AsWideString := AModel.DispatchNo;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('description').AsWideString := AModel.Description;
    Q.ParamByName('status').AsSmallInt := AModel.Status;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('dispatch_no').AsWideStrings[AIndex] := AModel.DispatchNo;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
    Q.ParamByName('status').AsSmallInts[AIndex] := AModel.Status;
  end;

  SetDate('dispatch_date', AModel.DispatchDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetNullableParam(Q.ParamByName('stk_warehouse_id'), ftLargeint, AModel.StkWarehouseId, AIndex);
  SetNullableParam(Q.ParamByName('sls_order_id'), ftLargeint, AModel.SlsOrderId, AIndex);
  SetNullableParam(Q.ParamByName('einv_profile_id'), ftLargeint, AModel.EinvProfileId, AIndex);
  SetNullableParam(Q.ParamByName('carrier_acc_account_id'), ftLargeint, AModel.CarrierAccAccountId, AIndex);
  SetNullableParam(Q.ParamByName('einv_vehicle_id'), ftLargeint, AModel.EinvVehicleId, AIndex);
  SetNullableParam(Q.ParamByName('trailer1_einv_vehicle_id'), ftLargeint, AModel.Trailer1EinvVehicleId, AIndex);
  SetNullableParam(Q.ParamByName('trailer2_einv_vehicle_id'), ftLargeint, AModel.Trailer2EinvVehicleId, AIndex);
  SetNullableParam(Q.ParamByName('driver1_einv_driver_id'), ftLargeint, AModel.Driver1EinvDriverId, AIndex);
  SetNullableParam(Q.ParamByName('driver2_einv_driver_id'), ftLargeint, AModel.Driver2EinvDriverId, AIndex);
  SetNullableParam(Q.ParamByName('einv_status'), ftInteger, AModel.EinvStatus, AIndex);
  SetUuid('einv_uuid', AModel.EinvUuid);
  SetTime('despatch_time', AModel.DespatchTime);
end;

function TSlsDispatchRepository.MapFromQuery(Q: TFDQuery): TSlsDispatch;
begin
  Result := TSlsDispatch.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.DispatchNo := Q.FieldByName('dispatch_no').AsString;
  if Q.FieldByName('dispatch_date').IsNull then
    Result.DispatchDate := 0
  else
    Result.DispatchDate := Q.FieldByName('dispatch_date').AsDateTime;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  Result.StkWarehouseId := Q.FieldByName('stk_warehouse_id').AsLargeInt;
  Result.SlsOrderId := Q.FieldByName('sls_order_id').AsLargeInt;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.Description := Q.FieldByName('description').AsString;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
  Result.WarehouseName := Q.FieldByName('warehouse_name').AsString;
  Result.OrderNo := Q.FieldByName('order_no').AsString;
  Result.Status := Q.FieldByName('status').AsInteger;
  Result.TotalAmount := Q.FieldByName('total_amount').AsCurrency;
  Result.EinvProfileId := Q.FieldByName('einv_profile_id').AsLargeInt;
  Result.CarrierAccAccountId := Q.FieldByName('carrier_acc_account_id').AsLargeInt;
  Result.EinvVehicleId := Q.FieldByName('einv_vehicle_id').AsLargeInt;
  Result.Trailer1EinvVehicleId := Q.FieldByName('trailer1_einv_vehicle_id').AsLargeInt;
  Result.Trailer2EinvVehicleId := Q.FieldByName('trailer2_einv_vehicle_id').AsLargeInt;
  Result.Driver1EinvDriverId := Q.FieldByName('driver1_einv_driver_id').AsLargeInt;
  Result.Driver2EinvDriverId := Q.FieldByName('driver2_einv_driver_id').AsLargeInt;
  Result.EinvUuid := LowerCase(Q.FieldByName('einv_uuid').AsString.Replace('{', '').Replace('}', ''));
  Result.EinvStatus := Q.FieldByName('einv_status').AsInteger;
  if Q.FieldByName('despatch_time').IsNull then
    Result.DespatchTime := 0
  else
    Result.DespatchTime := Frac(Q.FieldByName('despatch_time').AsDateTime);
  Result.ProfileCode := Q.FieldByName('profile_code').AsString;
  Result.EinvNo := Q.FieldByName('einv_no').AsString;
  Result.CarrierCode := Q.FieldByName('carrier_code').AsString;
  Result.CarrierName := Q.FieldByName('carrier_name').AsString;
  Result.VehiclePlate := Q.FieldByName('vehicle_plate').AsString;
  Result.Trailer1Plate := Q.FieldByName('trailer1_plate').AsString;
  Result.Trailer2Plate := Q.FieldByName('trailer2_plate').AsString;
  Result.Driver1Name := Q.FieldByName('driver1_name').AsString;
  Result.Driver2Name := Q.FieldByName('driver2_name').AsString;
  Result.AccountEDespatchActive := Q.FieldByName('account_e_despatch_active').AsBoolean;
end;

function TSlsDispatchRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TSlsDispatch) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSlsDispatchRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSlsDispatch>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSlsDispatch>.Create(True);
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

function TSlsDispatchRepository.DoFindById(AId: TValue; ALock: Boolean): TSlsDispatch;
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

function TSlsDispatchRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSlsDispatch;
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

procedure TSlsDispatchRepository.DoAdd(AModel: TSlsDispatch);
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

procedure TSlsDispatchRepository.DoAddBatch(AModels: TArray<TSlsDispatch>);
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

procedure TSlsDispatchRepository.DoUpdate(AModel: TSlsDispatch);
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

procedure TSlsDispatchRepository.DoUpdateBatch(AModels: TArray<TSlsDispatch>);
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

procedure TSlsDispatchRepository.DoDelete(AID: TValue);
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

procedure TSlsDispatchRepository.DoDelete(AModel: TSlsDispatch);
begin
  Delete(AModel.Id);
end;

procedure TSlsDispatchRepository.DoDeleteBatch(AModels: TArray<TSlsDispatch>);
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

procedure TSlsDispatchRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TSlsDispatchRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
