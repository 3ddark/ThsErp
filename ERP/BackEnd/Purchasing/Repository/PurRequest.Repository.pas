unit PurRequest.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, PurRequest;

type
  TPurRequestRepository = class(TRepository<TPurRequest>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TPurRequest; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TPurRequest; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TPurRequest; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TPurRequest>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TPurRequest; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TPurRequest; override;

    procedure DoAdd(AModel: TPurRequest); override;
    procedure DoAddBatch(AModels: TArray<TPurRequest>); override;

    procedure DoUpdate(AModel: TPurRequest); override;
    procedure DoUpdateBatch(AModels: TArray<TPurRequest>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TPurRequest); override;
    procedure DoDeleteBatch(AModels: TArray<TPurRequest>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function NextDocumentNo(const APrefix: string): string;
    function LineCount(ARequestId: Int64): Integer;
    function OrderedTotal(ARequestId: Int64): Currency;
    procedure SetStatus(ARequestId: Int64; AStatus: SmallInt);
    procedure RefreshOrderedQuantities(ARequestId: Int64);
  end;

implementation

constructor TPurRequestRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TPurRequestRepository.NextDocumentNo(const APrefix: string): string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT :prefix || lpad((COALESCE(MAX(CAST(substr(request_no, length(:prefix) + 1) AS bigint)), 0) + 1)::text, 6, ''0'') AS v ' +
                  '  FROM public.pur_request WHERE request_no ~ (''^'' || :prefix || ''[0-9]+$'')';
    Q.ParamByName('prefix').DataType := ftWideString;
    Q.ParamByName('prefix').AsWideString := APrefix;
    LogQuery(Q, 'NextDocumentNo');
    Q.Open;
    Result := Q.FieldByName('v').AsString;
  finally
    Q.Free;
  end;
end;

function TPurRequestRepository.LineCount(ARequestId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) AS v FROM public.pur_request_detail WHERE pur_request_id = :id';
    Q.ParamByName('id').AsLargeInt := ARequestId;
    LogQuery(Q, 'LineCount');
    Q.Open;
    Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;

function TPurRequestRepository.OrderedTotal(ARequestId: Int64): Currency;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(sum(ordered_quantity), 0) AS v FROM public.pur_request_detail WHERE pur_request_id = :id';
    Q.ParamByName('id').AsLargeInt := ARequestId;
    LogQuery(Q, 'OrderedTotal');
    Q.Open;
    Result := Q.FieldByName('v').AsCurrency;
  finally
    Q.Free;
  end;
end;

procedure TPurRequestRepository.SetStatus(ARequestId: Int64; AStatus: SmallInt);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.pur_request SET status = :status WHERE id = :id';
    Q.ParamByName('id').AsLargeInt := ARequestId;
    Q.ParamByName('status').AsSmallInt := AStatus;
    LogQuery(Q, 'SetStatus');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TPurRequestRepository.RefreshOrderedQuantities(ARequestId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.pur_request_detail d ' +
                  '   SET ordered_quantity = COALESCE((SELECT sum(od.quantity) FROM public.pur_order_detail od ' +
                  '                                     JOIN public.pur_order o ON o.id = od.pur_order_id ' +
                  '                                    WHERE od.pur_request_detail_id = d.id AND o.status <> 5), 0) ' +
                  ' WHERE d.pur_request_id = :id';
    Q.ParamByName('id').AsLargeInt := ARequestId;
    LogQuery(Q, 'RefreshOrderedQuantities');
    Q.ExecSQL;
    Q.SQL.Text := 'UPDATE public.pur_request r ' +
                  '   SET status = CASE WHEN NOT EXISTS (SELECT 1 FROM public.pur_request_detail d ' +
                  '                                       WHERE d.pur_request_id = r.id AND d.ordered_quantity < d.quantity) ' +
                  '                     THEN 4 ELSE 2 END ' +
                  ' WHERE r.id = :id AND r.status IN (2, 4) ' +
                  '   AND EXISTS (SELECT 1 FROM public.pur_request_detail d WHERE d.pur_request_id = r.id)';
    Q.ParamByName('id').AsLargeInt := ARequestId;
    LogQuery(Q, 'RefreshOrderedQuantities');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TPurRequestRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TPurRequest) +
            ' (request_no, request_date, emp_employee_id, required_date, status, description) ' +
            ' VALUES (:request_no, :request_date, :emp_employee_id, :required_date, :status, :description)';
end;

function TPurRequestRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TPurRequest) +
            ' SET request_no = :request_no, request_date = :request_date, emp_employee_id = :emp_employee_id, required_date = :required_date, status = :status, description = :description ' +
            ' WHERE id = :id';
end;

function TPurRequestRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TPurRequest) + ' WHERE';
end;

procedure TPurRequestRepository.SetInsertParams(Q: TFDQuery; AModel: TPurRequest; AIndex: Integer);

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
    Q.ParamByName('request_no').AsWideString := AModel.RequestNo;
    Q.ParamByName('status').AsSmallInt := AModel.Status;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('request_no').AsWideStrings[AIndex] := AModel.RequestNo;
    Q.ParamByName('status').AsSmallInts[AIndex] := AModel.Status;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetDate('request_date', AModel.RequestDate);
  SetNullableParam(Q.ParamByName('emp_employee_id'), ftLargeint, AModel.EmpEmployeeId, AIndex);
  SetDate('required_date', AModel.RequiredDate);
end;

procedure TPurRequestRepository.SetUpdateParams(Q: TFDQuery; AModel: TPurRequest; AIndex: Integer);

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
    Q.ParamByName('request_no').AsWideString := AModel.RequestNo;
    Q.ParamByName('status').AsSmallInt := AModel.Status;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('request_no').AsWideStrings[AIndex] := AModel.RequestNo;
    Q.ParamByName('status').AsSmallInts[AIndex] := AModel.Status;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetDate('request_date', AModel.RequestDate);
  SetNullableParam(Q.ParamByName('emp_employee_id'), ftLargeint, AModel.EmpEmployeeId, AIndex);
  SetDate('required_date', AModel.RequiredDate);
end;

function TPurRequestRepository.MapFromQuery(Q: TFDQuery): TPurRequest;
begin
  Result := TPurRequest.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.RequestNo := Q.FieldByName('request_no').AsString;
  if Q.FieldByName('request_date').IsNull then
    Result.RequestDate := 0
  else
    Result.RequestDate := Q.FieldByName('request_date').AsDateTime;
  Result.EmpEmployeeId := Q.FieldByName('emp_employee_id').AsLargeInt;
  if Q.FieldByName('required_date').IsNull then
    Result.RequiredDate := 0
  else
    Result.RequiredDate := Q.FieldByName('required_date').AsDateTime;
  Result.Status := Q.FieldByName('status').AsInteger;
  Result.Description := Q.FieldByName('description').AsString;
  Result.EmployeeName := Q.FieldByName('employee_name').AsString;
end;

function TPurRequestRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TPurRequest) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TPurRequestRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TPurRequest>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TPurRequest>.Create(True);
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

function TPurRequestRepository.DoFindById(AId: TValue; ALock: Boolean): TPurRequest;
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

function TPurRequestRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TPurRequest;
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

procedure TPurRequestRepository.DoAdd(AModel: TPurRequest);
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

procedure TPurRequestRepository.DoAddBatch(AModels: TArray<TPurRequest>);
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

procedure TPurRequestRepository.DoUpdate(AModel: TPurRequest);
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

procedure TPurRequestRepository.DoUpdateBatch(AModels: TArray<TPurRequest>);
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

procedure TPurRequestRepository.DoDelete(AID: TValue);
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

procedure TPurRequestRepository.DoDelete(AModel: TPurRequest);
begin
  Delete(AModel.Id);
end;

procedure TPurRequestRepository.DoDeleteBatch(AModels: TArray<TPurRequest>);
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

procedure TPurRequestRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TPurRequestRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
