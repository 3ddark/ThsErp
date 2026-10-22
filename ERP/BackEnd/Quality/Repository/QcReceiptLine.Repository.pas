unit QcReceiptLine.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, QcReceiptLine;

type
  TQcReceiptLineRepository = class(TRepository<TQcReceiptLine>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TQcReceiptLine; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TQcReceiptLine; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TQcReceiptLine; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TQcReceiptLine>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TQcReceiptLine; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TQcReceiptLine; override;

    procedure DoAdd(AModel: TQcReceiptLine); override;
    procedure DoAddBatch(AModels: TArray<TQcReceiptLine>); override;

    procedure DoUpdate(AModel: TQcReceiptLine); override;
    procedure DoUpdateBatch(AModels: TArray<TQcReceiptLine>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TQcReceiptLine); override;
    procedure DoDeleteBatch(AModels: TArray<TQcReceiptLine>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TQcReceiptLineRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TQcReceiptLineRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TQcReceiptLine) +
            ' (pur_receipt_id, receipt_no, receipt_date, acc_account_id, account_name, stk_warehouse_id, warehouse_name, line_no, stk_inventory_id, inventory_code, inventory_name, uom_code, quantity, inspection_criteria, qc_inspection_id, inspection_no, inspection_date, inspected_quantity, accepted_quantity, rejected_quantity, result, qc_status) ' +
            ' VALUES (:pur_receipt_id, :receipt_no, :receipt_date, :acc_account_id, :account_name, :stk_warehouse_id, :warehouse_name, :line_no, :stk_inventory_id, :inventory_code, :inventory_name, :uom_code, :quantity, :inspection_criteria, :qc_inspection_id, :inspection_no, :inspection_date, :inspected_quantity, :accepted_quantity, :rejected_quantity, :result, :qc_status)';
end;

function TQcReceiptLineRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TQcReceiptLine) +
            ' SET pur_receipt_id = :pur_receipt_id, receipt_no = :receipt_no, receipt_date = :receipt_date, acc_account_id = :acc_account_id, account_name = :account_name, stk_warehouse_id = :stk_warehouse_id, warehouse_name = :warehouse_name, line_no = :line_no, stk_inventory_id = :stk_inventory_id, inventory_code = :inventory_code, inventory_name = :inventory_name, uom_code = :uom_code, quantity = :quantity, inspection_criteria = :inspection_criteria, qc_inspection_id = :qc_inspection_id, inspection_no = :inspection_no, inspection_date = :inspection_date, inspected_quantity = :inspected_quantity, accepted_quantity = :accepted_quantity, rejected_quantity = :rejected_quantity, result = :result, qc_status = :qc_status ' +
            ' WHERE id = :id';
end;

function TQcReceiptLineRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TQcReceiptLine) + ' WHERE';
end;

procedure TQcReceiptLineRepository.SetInsertParams(Q: TFDQuery; AModel: TQcReceiptLine; AIndex: Integer);

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
    Q.ParamByName('receipt_no').AsWideString := AModel.ReceiptNo;
    Q.ParamByName('account_name').AsWideString := AModel.AccountName;
    Q.ParamByName('warehouse_name').AsWideString := AModel.WarehouseName;
    Q.ParamByName('line_no').AsSmallInt := AModel.LineNo;
    Q.ParamByName('inventory_code').AsWideString := AModel.InventoryCode;
    Q.ParamByName('inventory_name').AsWideString := AModel.InventoryName;
    Q.ParamByName('uom_code').AsWideString := AModel.UomCode;
    Q.ParamByName('quantity').AsBCD := AModel.Quantity;
    Q.ParamByName('inspection_criteria').AsWideString := AModel.InspectionCriteria;
    Q.ParamByName('inspection_no').AsWideString := AModel.InspectionNo;
    Q.ParamByName('inspected_quantity').AsBCD := AModel.InspectedQuantity;
    Q.ParamByName('accepted_quantity').AsBCD := AModel.AcceptedQuantity;
    Q.ParamByName('rejected_quantity').AsBCD := AModel.RejectedQuantity;
    Q.ParamByName('result').AsSmallInt := AModel.InspectionResult;
    Q.ParamByName('qc_status').AsSmallInt := AModel.QcStatus;
  end
  else
  begin
    Q.ParamByName('receipt_no').AsWideStrings[AIndex] := AModel.ReceiptNo;
    Q.ParamByName('account_name').AsWideStrings[AIndex] := AModel.AccountName;
    Q.ParamByName('warehouse_name').AsWideStrings[AIndex] := AModel.WarehouseName;
    Q.ParamByName('line_no').AsSmallInts[AIndex] := AModel.LineNo;
    Q.ParamByName('inventory_code').AsWideStrings[AIndex] := AModel.InventoryCode;
    Q.ParamByName('inventory_name').AsWideStrings[AIndex] := AModel.InventoryName;
    Q.ParamByName('uom_code').AsWideStrings[AIndex] := AModel.UomCode;
    Q.ParamByName('quantity').AsBCDs[AIndex] := AModel.Quantity;
    Q.ParamByName('inspection_criteria').AsWideStrings[AIndex] := AModel.InspectionCriteria;
    Q.ParamByName('inspection_no').AsWideStrings[AIndex] := AModel.InspectionNo;
    Q.ParamByName('inspected_quantity').AsBCDs[AIndex] := AModel.InspectedQuantity;
    Q.ParamByName('accepted_quantity').AsBCDs[AIndex] := AModel.AcceptedQuantity;
    Q.ParamByName('rejected_quantity').AsBCDs[AIndex] := AModel.RejectedQuantity;
    Q.ParamByName('result').AsSmallInts[AIndex] := AModel.InspectionResult;
    Q.ParamByName('qc_status').AsSmallInts[AIndex] := AModel.QcStatus;
  end;

  SetNullableParam(Q.ParamByName('pur_receipt_id'), ftLargeint, AModel.PurReceiptId, AIndex);
  SetDate('receipt_date', AModel.ReceiptDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetNullableParam(Q.ParamByName('stk_warehouse_id'), ftLargeint, AModel.StkWarehouseId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('qc_inspection_id'), ftLargeint, AModel.QcInspectionId, AIndex);
  SetDate('inspection_date', AModel.InspectionDate);
end;

procedure TQcReceiptLineRepository.SetUpdateParams(Q: TFDQuery; AModel: TQcReceiptLine; AIndex: Integer);

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
    Q.ParamByName('receipt_no').AsWideString := AModel.ReceiptNo;
    Q.ParamByName('account_name').AsWideString := AModel.AccountName;
    Q.ParamByName('warehouse_name').AsWideString := AModel.WarehouseName;
    Q.ParamByName('line_no').AsSmallInt := AModel.LineNo;
    Q.ParamByName('inventory_code').AsWideString := AModel.InventoryCode;
    Q.ParamByName('inventory_name').AsWideString := AModel.InventoryName;
    Q.ParamByName('uom_code').AsWideString := AModel.UomCode;
    Q.ParamByName('quantity').AsBCD := AModel.Quantity;
    Q.ParamByName('inspection_criteria').AsWideString := AModel.InspectionCriteria;
    Q.ParamByName('inspection_no').AsWideString := AModel.InspectionNo;
    Q.ParamByName('inspected_quantity').AsBCD := AModel.InspectedQuantity;
    Q.ParamByName('accepted_quantity').AsBCD := AModel.AcceptedQuantity;
    Q.ParamByName('rejected_quantity').AsBCD := AModel.RejectedQuantity;
    Q.ParamByName('result').AsSmallInt := AModel.InspectionResult;
    Q.ParamByName('qc_status').AsSmallInt := AModel.QcStatus;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('receipt_no').AsWideStrings[AIndex] := AModel.ReceiptNo;
    Q.ParamByName('account_name').AsWideStrings[AIndex] := AModel.AccountName;
    Q.ParamByName('warehouse_name').AsWideStrings[AIndex] := AModel.WarehouseName;
    Q.ParamByName('line_no').AsSmallInts[AIndex] := AModel.LineNo;
    Q.ParamByName('inventory_code').AsWideStrings[AIndex] := AModel.InventoryCode;
    Q.ParamByName('inventory_name').AsWideStrings[AIndex] := AModel.InventoryName;
    Q.ParamByName('uom_code').AsWideStrings[AIndex] := AModel.UomCode;
    Q.ParamByName('quantity').AsBCDs[AIndex] := AModel.Quantity;
    Q.ParamByName('inspection_criteria').AsWideStrings[AIndex] := AModel.InspectionCriteria;
    Q.ParamByName('inspection_no').AsWideStrings[AIndex] := AModel.InspectionNo;
    Q.ParamByName('inspected_quantity').AsBCDs[AIndex] := AModel.InspectedQuantity;
    Q.ParamByName('accepted_quantity').AsBCDs[AIndex] := AModel.AcceptedQuantity;
    Q.ParamByName('rejected_quantity').AsBCDs[AIndex] := AModel.RejectedQuantity;
    Q.ParamByName('result').AsSmallInts[AIndex] := AModel.InspectionResult;
    Q.ParamByName('qc_status').AsSmallInts[AIndex] := AModel.QcStatus;
  end;

  SetNullableParam(Q.ParamByName('pur_receipt_id'), ftLargeint, AModel.PurReceiptId, AIndex);
  SetDate('receipt_date', AModel.ReceiptDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetNullableParam(Q.ParamByName('stk_warehouse_id'), ftLargeint, AModel.StkWarehouseId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('qc_inspection_id'), ftLargeint, AModel.QcInspectionId, AIndex);
  SetDate('inspection_date', AModel.InspectionDate);
end;

function TQcReceiptLineRepository.MapFromQuery(Q: TFDQuery): TQcReceiptLine;
begin
  Result := TQcReceiptLine.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.PurReceiptId := Q.FieldByName('pur_receipt_id').AsLargeInt;
  Result.ReceiptNo := Q.FieldByName('receipt_no').AsString;
  if Q.FieldByName('receipt_date').IsNull then
    Result.ReceiptDate := 0
  else
    Result.ReceiptDate := Q.FieldByName('receipt_date').AsDateTime;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  Result.AccountName := Q.FieldByName('account_name').AsString;
  Result.StkWarehouseId := Q.FieldByName('stk_warehouse_id').AsLargeInt;
  Result.WarehouseName := Q.FieldByName('warehouse_name').AsString;
  Result.LineNo := Q.FieldByName('line_no').AsInteger;
  Result.StkInventoryId := Q.FieldByName('stk_inventory_id').AsLargeInt;
  Result.InventoryCode := Q.FieldByName('inventory_code').AsString;
  Result.InventoryName := Q.FieldByName('inventory_name').AsString;
  Result.UomCode := Q.FieldByName('uom_code').AsString;
  Result.Quantity := Q.FieldByName('quantity').AsCurrency;
  Result.InspectionCriteria := Q.FieldByName('inspection_criteria').AsString;
  Result.QcInspectionId := Q.FieldByName('qc_inspection_id').AsLargeInt;
  Result.InspectionNo := Q.FieldByName('inspection_no').AsString;
  if Q.FieldByName('inspection_date').IsNull then
    Result.InspectionDate := 0
  else
    Result.InspectionDate := Q.FieldByName('inspection_date').AsDateTime;
  Result.InspectedQuantity := Q.FieldByName('inspected_quantity').AsCurrency;
  Result.AcceptedQuantity := Q.FieldByName('accepted_quantity').AsCurrency;
  Result.RejectedQuantity := Q.FieldByName('rejected_quantity').AsCurrency;
  Result.InspectionResult := Q.FieldByName('result').AsInteger;
  Result.QcStatus := Q.FieldByName('qc_status').AsInteger;
end;

function TQcReceiptLineRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TQcReceiptLine) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TQcReceiptLineRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TQcReceiptLine>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TQcReceiptLine>.Create(True);
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

function TQcReceiptLineRepository.DoFindById(AId: TValue; ALock: Boolean): TQcReceiptLine;
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

function TQcReceiptLineRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TQcReceiptLine;
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

procedure TQcReceiptLineRepository.DoAdd(AModel: TQcReceiptLine);
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

procedure TQcReceiptLineRepository.DoAddBatch(AModels: TArray<TQcReceiptLine>);
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

procedure TQcReceiptLineRepository.DoUpdate(AModel: TQcReceiptLine);
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

procedure TQcReceiptLineRepository.DoUpdateBatch(AModels: TArray<TQcReceiptLine>);
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

procedure TQcReceiptLineRepository.DoDelete(AID: TValue);
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

procedure TQcReceiptLineRepository.DoDelete(AModel: TQcReceiptLine);
begin
  Delete(AModel.Id);
end;

procedure TQcReceiptLineRepository.DoDeleteBatch(AModels: TArray<TQcReceiptLine>);
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

procedure TQcReceiptLineRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TQcReceiptLineRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
