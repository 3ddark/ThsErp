unit PrdBomByProduct.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, PrdBomByProduct;

type
  TPrdBomByProductRepository = class(TRepository<TPrdBomByProduct>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TPrdBomByProduct; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TPrdBomByProduct; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TPrdBomByProduct; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TPrdBomByProduct>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TPrdBomByProduct; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TPrdBomByProduct; override;

    procedure DoAdd(AModel: TPrdBomByProduct); override;
    procedure DoAddBatch(AModels: TArray<TPrdBomByProduct>); override;

    procedure DoUpdate(AModel: TPrdBomByProduct); override;
    procedure DoUpdateBatch(AModels: TArray<TPrdBomByProduct>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TPrdBomByProduct); override;
    procedure DoDeleteBatch(AModels: TArray<TPrdBomByProduct>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    // Reçetelerin kalemleri tek sorguda (başlık + satır no sırasıyla): belge yükleme
    function FindByBomIds(const AIds: TArray<Int64>): TObjectList<TPrdBomByProduct>;
    function NextLineNo(AParentId: Int64): SmallInt;
  end;

implementation

constructor TPrdBomByProductRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TPrdBomByProductRepository.FindByBomIds(const AIds: TArray<Int64>): TObjectList<TPrdBomByProduct>;
var
  Q: TFDQuery;
  LIds: string;
  LId: Int64;
begin
  Result := TObjectList<TPrdBomByProduct>.Create(True);
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
    Q.SQL.Text := 'SELECT v.* FROM ' + Self.GetFullViewName(TPrdBomByProduct) + ' v ' +
                  ' WHERE v.prd_bom_id IN (' + LIds + ') ORDER BY v.prd_bom_id, v.line_no, v.id';
    LogQuery(Q, 'FindByBomIds');
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

function TPrdBomByProductRepository.NextLineNo(AParentId: Int64): SmallInt;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(MAX(line_no), 0) + 1 AS v FROM public.prd_bom_by_product WHERE prd_bom_id = :id';
    Q.ParamByName('id').AsLargeInt := AParentId;
    LogQuery(Q, 'NextLineNo');
    Q.Open;
    Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;

function TPrdBomByProductRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TPrdBomByProduct) +
            ' (prd_bom_id, line_no, stk_inventory_id, quantity) ' +
            ' VALUES (:prd_bom_id, :line_no, :stk_inventory_id, :quantity)';
end;

function TPrdBomByProductRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TPrdBomByProduct) +
            ' SET prd_bom_id = :prd_bom_id, line_no = :line_no, stk_inventory_id = :stk_inventory_id, quantity = :quantity ' +
            ' WHERE id = :id';
end;

function TPrdBomByProductRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TPrdBomByProduct) + ' WHERE';
end;

procedure TPrdBomByProductRepository.SetInsertParams(Q: TFDQuery; AModel: TPrdBomByProduct; AIndex: Integer);
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
  SetNullableParam(Q.ParamByName('prd_bom_id'), ftLargeint, AModel.PrdBomId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
end;

procedure TPrdBomByProductRepository.SetUpdateParams(Q: TFDQuery; AModel: TPrdBomByProduct; AIndex: Integer);
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
  SetNullableParam(Q.ParamByName('prd_bom_id'), ftLargeint, AModel.PrdBomId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
end;

function TPrdBomByProductRepository.MapFromQuery(Q: TFDQuery): TPrdBomByProduct;
begin
  Result := TPrdBomByProduct.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.PrdBomId := Q.FieldByName('prd_bom_id').AsLargeInt;
  Result.LineNo := Q.FieldByName('line_no').AsInteger;
  Result.StkInventoryId := Q.FieldByName('stk_inventory_id').AsLargeInt;
  Result.Quantity := Q.FieldByName('quantity').AsCurrency;
  Result.BomName := Q.FieldByName('bom_name').AsString;
  Result.InventoryCode := Q.FieldByName('inventory_code').AsString;
  Result.InventoryName := Q.FieldByName('inventory_name').AsString;
end;

function TPrdBomByProductRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TPrdBomByProduct) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TPrdBomByProductRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TPrdBomByProduct>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TPrdBomByProduct>.Create(True);
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

function TPrdBomByProductRepository.DoFindById(AId: TValue; ALock: Boolean): TPrdBomByProduct;
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

function TPrdBomByProductRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TPrdBomByProduct;
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

procedure TPrdBomByProductRepository.DoAdd(AModel: TPrdBomByProduct);
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

procedure TPrdBomByProductRepository.DoAddBatch(AModels: TArray<TPrdBomByProduct>);
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

procedure TPrdBomByProductRepository.DoUpdate(AModel: TPrdBomByProduct);
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

procedure TPrdBomByProductRepository.DoUpdateBatch(AModels: TArray<TPrdBomByProduct>);
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

procedure TPrdBomByProductRepository.DoDelete(AID: TValue);
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

procedure TPrdBomByProductRepository.DoDelete(AModel: TPrdBomByProduct);
begin
  Delete(AModel.Id);
end;

procedure TPrdBomByProductRepository.DoDeleteBatch(AModels: TArray<TPrdBomByProduct>);
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

procedure TPrdBomByProductRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TPrdBomByProductRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
