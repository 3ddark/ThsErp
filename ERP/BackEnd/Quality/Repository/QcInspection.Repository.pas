unit QcInspection.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, QcInspection;

type
  TQcInspectionRepository = class(TRepository<TQcInspection>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TQcInspection; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TQcInspection; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TQcInspection; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TQcInspection>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TQcInspection; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TQcInspection; override;

    procedure DoAdd(AModel: TQcInspection); override;
    procedure DoAddBatch(AModels: TArray<TQcInspection>); override;

    procedure DoUpdate(AModel: TQcInspection); override;
    procedure DoUpdateBatch(AModels: TArray<TQcInspection>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TQcInspection); override;
    procedure DoDeleteBatch(AModels: TArray<TQcInspection>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function NextDocumentNo(const APrefix: string): string;
    // Mal kabul kalemi: stok, miktar ve (kurala göre) kontrol gerekliliği; False = kalem yok
    function ReadReceiptLine(AReceiptDetailId: Int64; out AInventoryId: Int64; out AQuantity: Currency;
      out ARequired: Boolean): Boolean;
    // Uygunsuz miktarın red ambarına transferi (ayar + uygunsuz miktar varsa; mal kabul ambarı red ambarından farklıysa)
    procedure SyncRejectTransfer(AInspectionId: Int64);
  end;

implementation

constructor TQcInspectionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;


function TQcInspectionRepository.NextDocumentNo(const APrefix: string): string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT :prefix || lpad((COALESCE(MAX(CAST(substr(inspection_no, length(:prefix) + 1) AS bigint)), 0) + 1)::text, 6, ''0'') AS v ' +
                  '  FROM public.qc_inspection WHERE inspection_no ~ (''^'' || :prefix || ''[0-9]+$'')';
    Q.ParamByName('prefix').DataType := ftWideString;
    Q.ParamByName('prefix').AsWideString := APrefix;
    LogQuery(Q, 'NextDocumentNo');
    Q.Open;
    Result := Q.FieldByName('v').AsString;
  finally
    Q.Free;
  end;
end;

function TQcInspectionRepository.ReadReceiptLine(AReceiptDetailId: Int64; out AInventoryId: Int64; out AQuantity: Currency;
  out ARequired: Boolean): Boolean;
var
  Q: TFDQuery;
begin
  Result := False;
  AInventoryId := 0;
  AQuantity := 0;
  ARequired := False;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT rd.stk_inventory_id, rd.quantity, COALESCE(ri.is_required, rg.is_required, false) AS is_required ' +
                  '  FROM public.pur_receipt_detail rd ' +
                  '  JOIN public.stk_inventory i ON i.id = rd.stk_inventory_id ' +
                  '  LEFT JOIN public.qc_rule ri ON ri.stk_inventory_id = rd.stk_inventory_id ' +
                  '  LEFT JOIN public.qc_rule rg ON rg.stk_group_id = i.stk_group_id ' +
                  ' WHERE rd.id = :id';
    Q.ParamByName('id').AsLargeInt := AReceiptDetailId;
    LogQuery(Q, 'ReadReceiptLine');
    Q.Open;
    if not Q.IsEmpty then
    begin
      Result := True;
      AInventoryId := Q.FieldByName('stk_inventory_id').AsLargeInt;
      AQuantity := Q.FieldByName('quantity').AsCurrency;
      ARequired := Q.FieldByName('is_required').AsBoolean;
    end;
  finally
    Q.Free;
  end;
end;

procedure TQcInspectionRepository.SyncRejectTransfer(AInspectionId: Int64);
const
  // transferin olması gereken satır (yoksa boş)
  WANTED =
    'SELECT 3 AS transaction_type, c.stk_inventory_id, p.stk_warehouse_id AS from_stk_warehouse_id, ' +
    '       s.reject_stk_warehouse_id AS to_stk_warehouse_id, c.rejected_quantity AS quantity, ' +
    '       round(c.rejected_quantity * rd.unit_price, 2) AS amount, p.currency, c.inspection_date AS transaction_date, ' +
    '       ''KK '' || c.inspection_no AS description, c.id AS qc_inspection_id ' +
    '  FROM public.qc_inspection c ' +
    '  JOIN public.pur_receipt_detail rd ON rd.id = c.pur_receipt_detail_id ' +
    '  JOIN public.pur_receipt p ON p.id = rd.pur_receipt_id ' +
    '  JOIN (SELECT reject_stk_warehouse_id FROM public.qc_setting ' +
    '         WHERE is_enabled AND reject_stk_warehouse_id IS NOT NULL ORDER BY id LIMIT 1) s ' +
    '    ON s.reject_stk_warehouse_id <> p.stk_warehouse_id ' +
    ' WHERE c.id = :id AND c.rejected_quantity > 0';
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'DELETE FROM public.stk_transaction t WHERE t.qc_inspection_id = :id AND NOT EXISTS (' + WANTED + ')';
    Q.ParamByName('id').AsLargeInt := AInspectionId;
    LogQuery(Q, 'SyncRejectTransfer');
    Q.ExecSQL;
    Q.SQL.Text := 'INSERT INTO public.stk_transaction (transaction_type, stk_inventory_id, from_stk_warehouse_id, to_stk_warehouse_id, ' +
                  '       quantity, amount, currency, transaction_date, description, qc_inspection_id) ' + WANTED +
                  ' ON CONFLICT ON CONSTRAINT stk_transaction_qc_inspection_key DO UPDATE SET ' +
                  '       stk_inventory_id = EXCLUDED.stk_inventory_id, from_stk_warehouse_id = EXCLUDED.from_stk_warehouse_id, ' +
                  '       to_stk_warehouse_id = EXCLUDED.to_stk_warehouse_id, quantity = EXCLUDED.quantity, amount = EXCLUDED.amount, ' +
                  '       currency = EXCLUDED.currency, transaction_date = EXCLUDED.transaction_date, description = EXCLUDED.description';
    Q.ParamByName('id').AsLargeInt := AInspectionId;
    LogQuery(Q, 'SyncRejectTransfer');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TQcInspectionRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TQcInspection) +
            ' (inspection_no, inspection_date, pur_receipt_detail_id, stk_inventory_id, quantity, accepted_quantity, rejected_quantity, result, disposition, emp_employee_id, description) ' +
            ' VALUES (:inspection_no, :inspection_date, :pur_receipt_detail_id, :stk_inventory_id, :quantity, :accepted_quantity, :rejected_quantity, :result, :disposition, :emp_employee_id, :description)';
end;

function TQcInspectionRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TQcInspection) +
            ' SET inspection_no = :inspection_no, inspection_date = :inspection_date, pur_receipt_detail_id = :pur_receipt_detail_id, stk_inventory_id = :stk_inventory_id, quantity = :quantity, accepted_quantity = :accepted_quantity, rejected_quantity = :rejected_quantity, result = :result, disposition = :disposition, emp_employee_id = :emp_employee_id, description = :description ' +
            ' WHERE id = :id';
end;

function TQcInspectionRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TQcInspection) + ' WHERE';
end;

procedure TQcInspectionRepository.SetInsertParams(Q: TFDQuery; AModel: TQcInspection; AIndex: Integer);

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
    Q.ParamByName('inspection_no').AsWideString := AModel.InspectionNo;
    Q.ParamByName('quantity').AsBCD := AModel.Quantity;
    Q.ParamByName('accepted_quantity').AsBCD := AModel.AcceptedQuantity;
    Q.ParamByName('rejected_quantity').AsBCD := AModel.RejectedQuantity;
    Q.ParamByName('result').AsSmallInt := AModel.InspectionResult;
    Q.ParamByName('disposition').AsSmallInt := AModel.Disposition;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('inspection_no').AsWideStrings[AIndex] := AModel.InspectionNo;
    Q.ParamByName('quantity').AsBCDs[AIndex] := AModel.Quantity;
    Q.ParamByName('accepted_quantity').AsBCDs[AIndex] := AModel.AcceptedQuantity;
    Q.ParamByName('rejected_quantity').AsBCDs[AIndex] := AModel.RejectedQuantity;
    Q.ParamByName('result').AsSmallInts[AIndex] := AModel.InspectionResult;
    Q.ParamByName('disposition').AsSmallInts[AIndex] := AModel.Disposition;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetDate('inspection_date', AModel.InspectionDate);
  SetNullableParam(Q.ParamByName('pur_receipt_detail_id'), ftLargeint, AModel.PurReceiptDetailId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('emp_employee_id'), ftLargeint, AModel.EmpEmployeeId, AIndex);
end;

procedure TQcInspectionRepository.SetUpdateParams(Q: TFDQuery; AModel: TQcInspection; AIndex: Integer);

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
    Q.ParamByName('inspection_no').AsWideString := AModel.InspectionNo;
    Q.ParamByName('quantity').AsBCD := AModel.Quantity;
    Q.ParamByName('accepted_quantity').AsBCD := AModel.AcceptedQuantity;
    Q.ParamByName('rejected_quantity').AsBCD := AModel.RejectedQuantity;
    Q.ParamByName('result').AsSmallInt := AModel.InspectionResult;
    Q.ParamByName('disposition').AsSmallInt := AModel.Disposition;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('inspection_no').AsWideStrings[AIndex] := AModel.InspectionNo;
    Q.ParamByName('quantity').AsBCDs[AIndex] := AModel.Quantity;
    Q.ParamByName('accepted_quantity').AsBCDs[AIndex] := AModel.AcceptedQuantity;
    Q.ParamByName('rejected_quantity').AsBCDs[AIndex] := AModel.RejectedQuantity;
    Q.ParamByName('result').AsSmallInts[AIndex] := AModel.InspectionResult;
    Q.ParamByName('disposition').AsSmallInts[AIndex] := AModel.Disposition;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetDate('inspection_date', AModel.InspectionDate);
  SetNullableParam(Q.ParamByName('pur_receipt_detail_id'), ftLargeint, AModel.PurReceiptDetailId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('emp_employee_id'), ftLargeint, AModel.EmpEmployeeId, AIndex);
end;

function TQcInspectionRepository.MapFromQuery(Q: TFDQuery): TQcInspection;
begin
  Result := TQcInspection.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.InspectionNo := Q.FieldByName('inspection_no').AsString;
  if Q.FieldByName('inspection_date').IsNull then
    Result.InspectionDate := 0
  else
    Result.InspectionDate := Q.FieldByName('inspection_date').AsDateTime;
  Result.PurReceiptDetailId := Q.FieldByName('pur_receipt_detail_id').AsLargeInt;
  Result.StkInventoryId := Q.FieldByName('stk_inventory_id').AsLargeInt;
  Result.Quantity := Q.FieldByName('quantity').AsCurrency;
  Result.AcceptedQuantity := Q.FieldByName('accepted_quantity').AsCurrency;
  Result.RejectedQuantity := Q.FieldByName('rejected_quantity').AsCurrency;
  Result.InspectionResult := Q.FieldByName('result').AsInteger;
  Result.Disposition := Q.FieldByName('disposition').AsInteger;
  Result.EmpEmployeeId := Q.FieldByName('emp_employee_id').AsLargeInt;
  Result.Description := Q.FieldByName('description').AsString;
  Result.PurReceiptId := Q.FieldByName('pur_receipt_id').AsLargeInt;
  Result.ReceiptNo := Q.FieldByName('receipt_no').AsString;
  if Q.FieldByName('receipt_date').IsNull then
    Result.ReceiptDate := 0
  else
    Result.ReceiptDate := Q.FieldByName('receipt_date').AsDateTime;
  Result.AccountName := Q.FieldByName('account_name').AsString;
  Result.WarehouseName := Q.FieldByName('warehouse_name').AsString;
  Result.ReceiptLineNo := Q.FieldByName('receipt_line_no').AsInteger;
  Result.InventoryCode := Q.FieldByName('inventory_code').AsString;
  Result.InventoryName := Q.FieldByName('inventory_name').AsString;
  Result.UomCode := Q.FieldByName('uom_code').AsString;
  Result.EmployeeName := Q.FieldByName('employee_name').AsString;
  Result.StkTransactionId := Q.FieldByName('stk_transaction_id').AsLargeInt;
  Result.RejectStkWarehouseId := Q.FieldByName('reject_stk_warehouse_id').AsLargeInt;
end;

function TQcInspectionRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TQcInspection) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TQcInspectionRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TQcInspection>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TQcInspection>.Create(True);
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

function TQcInspectionRepository.DoFindById(AId: TValue; ALock: Boolean): TQcInspection;
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

function TQcInspectionRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TQcInspection;
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

procedure TQcInspectionRepository.DoAdd(AModel: TQcInspection);
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

procedure TQcInspectionRepository.DoAddBatch(AModels: TArray<TQcInspection>);
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

procedure TQcInspectionRepository.DoUpdate(AModel: TQcInspection);
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

procedure TQcInspectionRepository.DoUpdateBatch(AModels: TArray<TQcInspection>);
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

procedure TQcInspectionRepository.DoDelete(AID: TValue);
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

procedure TQcInspectionRepository.DoDelete(AModel: TQcInspection);
begin
  Delete(AModel.Id);
end;

procedure TQcInspectionRepository.DoDeleteBatch(AModels: TArray<TQcInspection>);
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

procedure TQcInspectionRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TQcInspectionRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
