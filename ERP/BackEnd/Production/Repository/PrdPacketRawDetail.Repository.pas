unit PrdPacketRawDetail.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, PrdPacketRawDetail;

type
  TPrdPacketRawDetailRepository = class(TRepository<TPrdPacketRawDetail>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TPrdPacketRawDetail; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TPrdPacketRawDetail; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TPrdPacketRawDetail; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TPrdPacketRawDetail>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TPrdPacketRawDetail; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TPrdPacketRawDetail; override;

    procedure DoAdd(AModel: TPrdPacketRawDetail); override;
    procedure DoAddBatch(AModels: TArray<TPrdPacketRawDetail>); override;

    procedure DoUpdate(AModel: TPrdPacketRawDetail); override;
    procedure DoUpdateBatch(AModels: TArray<TPrdPacketRawDetail>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TPrdPacketRawDetail); override;
    procedure DoDeleteBatch(AModels: TArray<TPrdPacketRawDetail>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    // Paketlerin kalemleri tek sorguda (başlık + satır no sırasıyla): belge yükleme
    function FindByPacketIds(const AIds: TArray<Int64>): TObjectList<TPrdPacketRawDetail>;
    function NextLineNo(AParentId: Int64): SmallInt;
  end;

implementation

constructor TPrdPacketRawDetailRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TPrdPacketRawDetailRepository.FindByPacketIds(const AIds: TArray<Int64>): TObjectList<TPrdPacketRawDetail>;
var
  Q: TFDQuery;
  LIds: string;
  LId: Int64;
begin
  Result := TObjectList<TPrdPacketRawDetail>.Create(True);
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
    Q.SQL.Text := 'SELECT v.* FROM ' + Self.GetFullViewName(TPrdPacketRawDetail) + ' v ' +
                  ' WHERE v.prd_packet_raw_id IN (' + LIds + ') ORDER BY v.prd_packet_raw_id, v.line_no, v.id';
    LogQuery(Q, 'FindByPacketIds');
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

function TPrdPacketRawDetailRepository.NextLineNo(AParentId: Int64): SmallInt;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(MAX(line_no), 0) + 1 AS v FROM public.prd_packet_raw_detail WHERE prd_packet_raw_id = :id';
    Q.ParamByName('id').AsLargeInt := AParentId;
    LogQuery(Q, 'NextLineNo');
    Q.Open;
    Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;

function TPrdPacketRawDetailRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TPrdPacketRawDetail) +
            ' (prd_packet_raw_id, line_no, stk_inventory_id, sub_prd_bom_id, quantity) ' +
            ' VALUES (:prd_packet_raw_id, :line_no, :stk_inventory_id, :sub_prd_bom_id, :quantity)';
end;

function TPrdPacketRawDetailRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TPrdPacketRawDetail) +
            ' SET prd_packet_raw_id = :prd_packet_raw_id, line_no = :line_no, stk_inventory_id = :stk_inventory_id, sub_prd_bom_id = :sub_prd_bom_id, quantity = :quantity ' +
            ' WHERE id = :id';
end;

function TPrdPacketRawDetailRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TPrdPacketRawDetail) + ' WHERE';
end;

procedure TPrdPacketRawDetailRepository.SetInsertParams(Q: TFDQuery; AModel: TPrdPacketRawDetail; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('quantity').AsBCD := AModel.Quantity;
  end
  else
  begin
    Q.ParamByName('quantity').AsBCDs[AIndex] := AModel.Quantity;
  end;

  if AIndex < 0 then
    Q.ParamByName('line_no').AsSmallInt := AModel.LineNo
  else
    Q.ParamByName('line_no').AsSmallInts[AIndex] := AModel.LineNo;
  SetNullableParam(Q.ParamByName('prd_packet_raw_id'), ftLargeint, AModel.PrdPacketRawId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('sub_prd_bom_id'), ftLargeint, AModel.SubPrdBomId, AIndex);
end;

procedure TPrdPacketRawDetailRepository.SetUpdateParams(Q: TFDQuery; AModel: TPrdPacketRawDetail; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('quantity').AsBCD := AModel.Quantity;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('quantity').AsBCDs[AIndex] := AModel.Quantity;
  end;

  if AIndex < 0 then
    Q.ParamByName('line_no').AsSmallInt := AModel.LineNo
  else
    Q.ParamByName('line_no').AsSmallInts[AIndex] := AModel.LineNo;
  SetNullableParam(Q.ParamByName('prd_packet_raw_id'), ftLargeint, AModel.PrdPacketRawId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('sub_prd_bom_id'), ftLargeint, AModel.SubPrdBomId, AIndex);
end;

function TPrdPacketRawDetailRepository.MapFromQuery(Q: TFDQuery): TPrdPacketRawDetail;
begin
  Result := TPrdPacketRawDetail.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.PrdPacketRawId := Q.FieldByName('prd_packet_raw_id').AsLargeInt;
  Result.LineNo := Q.FieldByName('line_no').AsInteger;
  Result.StkInventoryId := Q.FieldByName('stk_inventory_id').AsLargeInt;
  Result.SubPrdBomId := Q.FieldByName('sub_prd_bom_id').AsLargeInt;
  Result.Quantity := Q.FieldByName('quantity').AsCurrency;
  Result.PacketName := Q.FieldByName('packet_name').AsString;
  Result.InventoryCode := Q.FieldByName('inventory_code').AsString;
  Result.InventoryName := Q.FieldByName('inventory_name').AsString;
  Result.SubBomName := Q.FieldByName('sub_bom_name').AsString;
end;

function TPrdPacketRawDetailRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TPrdPacketRawDetail) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TPrdPacketRawDetailRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TPrdPacketRawDetail>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TPrdPacketRawDetail>.Create(True);
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

function TPrdPacketRawDetailRepository.DoFindById(AId: TValue; ALock: Boolean): TPrdPacketRawDetail;
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

function TPrdPacketRawDetailRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TPrdPacketRawDetail;
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

procedure TPrdPacketRawDetailRepository.DoAdd(AModel: TPrdPacketRawDetail);
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

procedure TPrdPacketRawDetailRepository.DoAddBatch(AModels: TArray<TPrdPacketRawDetail>);
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

procedure TPrdPacketRawDetailRepository.DoUpdate(AModel: TPrdPacketRawDetail);
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

procedure TPrdPacketRawDetailRepository.DoUpdateBatch(AModels: TArray<TPrdPacketRawDetail>);
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

procedure TPrdPacketRawDetailRepository.DoDelete(AID: TValue);
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

procedure TPrdPacketRawDetailRepository.DoDelete(AModel: TPrdPacketRawDetail);
begin
  Delete(AModel.Id);
end;

procedure TPrdPacketRawDetailRepository.DoDeleteBatch(AModels: TArray<TPrdPacketRawDetail>);
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

procedure TPrdPacketRawDetailRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TPrdPacketRawDetailRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
