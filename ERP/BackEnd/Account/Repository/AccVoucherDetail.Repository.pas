unit AccVoucherDetail.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, AccVoucherDetail;

type
  TAccVoucherDetailRepository = class(TRepository<TAccVoucherDetail>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TAccVoucherDetail; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TAccVoucherDetail; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TAccVoucherDetail; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TAccVoucherDetail>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TAccVoucherDetail; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TAccVoucherDetail; override;

    procedure DoAdd(AModel: TAccVoucherDetail); override;
    procedure DoAddBatch(AModels: TArray<TAccVoucherDetail>); override;

    procedure DoUpdate(AModel: TAccVoucherDetail); override;
    procedure DoUpdateBatch(AModels: TArray<TAccVoucherDetail>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TAccVoucherDetail); override;
    procedure DoDeleteBatch(AModels: TArray<TAccVoucherDetail>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);

    function NextLineNo(AParentId: Int64): SmallInt;
    // Hesapların tipi (acc_set_account_type_id): id -> tip
    function AccountTypes(const AAccountIds: TArray<Int64>): TDictionary<Int64, Int64>;
    // Fişlerin kalemleri tek sorguda (talep + satır no sırasıyla): belge yükleme
    function FindByVoucherIds(const AVoucherIds: TArray<Int64>): TObjectList<TAccVoucherDetail>;
  end;

implementation

constructor TAccVoucherDetailRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TAccVoucherDetailRepository.AccountTypes(const AAccountIds: TArray<Int64>): TDictionary<Int64, Int64>;
var
  Q: TFDQuery;
  LIds: string;
  LId: Int64;
begin
  Result := TDictionary<Int64, Int64>.Create;
  LIds := '';
  for LId in AAccountIds do
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
    Q.SQL.Text := 'SELECT id, acc_set_account_type_id FROM public.acc_account WHERE id IN (' + LIds + ')';
    LogQuery(Q, 'AccountTypes');
    Q.Open;
    while not Q.Eof do
    begin
      Result.AddOrSetValue(Q.Fields[0].AsLargeInt, Q.Fields[1].AsLargeInt);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TAccVoucherDetailRepository.NextLineNo(AParentId: Int64): SmallInt;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(MAX(line_no), 0) + 1 AS v FROM public.acc_voucher_detail WHERE acc_voucher_id = :id';
    Q.ParamByName('id').AsLargeInt := AParentId;
    LogQuery(Q, 'NextLineNo');
    Q.Open;
    Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;

function TAccVoucherDetailRepository.FindByVoucherIds(const AVoucherIds: TArray<Int64>): TObjectList<TAccVoucherDetail>;
var
  Q: TFDQuery;
  LIds: string;
  LId: Int64;
begin
  Result := TObjectList<TAccVoucherDetail>.Create(True);
  LIds := '';
  for LId in AVoucherIds do
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
    Q.SQL.Text := 'SELECT v.* FROM ' + Self.GetFullViewName(TAccVoucherDetail) + ' v ' +
                  ' WHERE v.acc_voucher_id IN (' + LIds + ') ORDER BY v.acc_voucher_id, v.line_no, v.id';
    LogQuery(Q, 'FindByVoucherIds');
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

function TAccVoucherDetailRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TAccVoucherDetail) +
            ' (acc_voucher_id, line_no, acc_account_id, description, debit, credit) ' +
            ' VALUES (:acc_voucher_id, :line_no, :acc_account_id, :description, :debit, :credit)';
end;

function TAccVoucherDetailRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TAccVoucherDetail) +
            ' SET acc_voucher_id = :acc_voucher_id, line_no = :line_no, acc_account_id = :acc_account_id, description = :description, debit = :debit, credit = :credit ' +
            ' WHERE id = :id';
end;

function TAccVoucherDetailRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TAccVoucherDetail) + ' WHERE';
end;

procedure TAccVoucherDetailRepository.SetInsertParams(Q: TFDQuery; AModel: TAccVoucherDetail; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('line_no').AsSmallInt := AModel.LineNo;
    Q.ParamByName('description').AsWideString := AModel.Description;
    Q.ParamByName('debit').AsBCD := AModel.Debit;
    Q.ParamByName('credit').AsBCD := AModel.Credit;
  end
  else
  begin
    Q.ParamByName('line_no').AsSmallInts[AIndex] := AModel.LineNo;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
    Q.ParamByName('debit').AsBCDs[AIndex] := AModel.Debit;
    Q.ParamByName('credit').AsBCDs[AIndex] := AModel.Credit;
  end;

  SetNullableParam(Q.ParamByName('acc_voucher_id'), ftLargeint, AModel.AccVoucherId, AIndex);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
end;

procedure TAccVoucherDetailRepository.SetUpdateParams(Q: TFDQuery; AModel: TAccVoucherDetail; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('line_no').AsSmallInt := AModel.LineNo;
    Q.ParamByName('description').AsWideString := AModel.Description;
    Q.ParamByName('debit').AsBCD := AModel.Debit;
    Q.ParamByName('credit').AsBCD := AModel.Credit;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('line_no').AsSmallInts[AIndex] := AModel.LineNo;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
    Q.ParamByName('debit').AsBCDs[AIndex] := AModel.Debit;
    Q.ParamByName('credit').AsBCDs[AIndex] := AModel.Credit;
  end;

  SetNullableParam(Q.ParamByName('acc_voucher_id'), ftLargeint, AModel.AccVoucherId, AIndex);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
end;

function TAccVoucherDetailRepository.MapFromQuery(Q: TFDQuery): TAccVoucherDetail;
begin
  Result := TAccVoucherDetail.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.AccVoucherId := Q.FieldByName('acc_voucher_id').AsLargeInt;
  Result.LineNo := Q.FieldByName('line_no').AsInteger;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  Result.Description := Q.FieldByName('description').AsString;
  Result.Debit := Q.FieldByName('debit').AsCurrency;
  Result.Credit := Q.FieldByName('credit').AsCurrency;
  Result.VoucherNo := Q.FieldByName('voucher_no').AsString;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
end;

function TAccVoucherDetailRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TAccVoucherDetail) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TAccVoucherDetailRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TAccVoucherDetail>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TAccVoucherDetail>.Create(True);
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

function TAccVoucherDetailRepository.DoFindById(AId: TValue; ALock: Boolean): TAccVoucherDetail;
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

function TAccVoucherDetailRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TAccVoucherDetail;
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

procedure TAccVoucherDetailRepository.DoAdd(AModel: TAccVoucherDetail);
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

procedure TAccVoucherDetailRepository.DoAddBatch(AModels: TArray<TAccVoucherDetail>);
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

procedure TAccVoucherDetailRepository.DoUpdate(AModel: TAccVoucherDetail);
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

procedure TAccVoucherDetailRepository.DoUpdateBatch(AModels: TArray<TAccVoucherDetail>);
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

procedure TAccVoucherDetailRepository.DoDelete(AID: TValue);
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

procedure TAccVoucherDetailRepository.DoDelete(AModel: TAccVoucherDetail);
begin
  Delete(AModel.Id);
end;

procedure TAccVoucherDetailRepository.DoDeleteBatch(AModels: TArray<TAccVoucherDetail>);
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

procedure TAccVoucherDetailRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TAccVoucherDetailRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
