unit EInvDiibLine.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, EInvDiibLine;

type
  TEInvDiibLineRepository = class(TRepository<TEInvDiibLine>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TEInvDiibLine; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TEInvDiibLine; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TEInvDiibLine; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TEInvDiibLine>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TEInvDiibLine; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TEInvDiibLine; override;

    procedure DoAdd(AModel: TEInvDiibLine); override;
    procedure DoAddBatch(AModels: TArray<TEInvDiibLine>); override;

    procedure DoUpdate(AModel: TEInvDiibLine); override;
    procedure DoUpdateBatch(AModels: TArray<TEInvDiibLine>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TEInvDiibLine); override;
    procedure DoDeleteBatch(AModels: TArray<TEInvDiibLine>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function LineCodeExists(ADiibId: Int64; const ALineCode: string; AExcludeId: Int64): Boolean;
    function UsageCount(AId: Int64): Integer;
    procedure FillFromInventory(AModel: TEInvDiibLine);
  end;

implementation

constructor TEInvDiibLineRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TEInvDiibLineRepository.LineCodeExists(ADiibId: Int64; const ALineCode: string; AExcludeId: Int64): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT 1 FROM public.einv_diib_line WHERE einv_diib_id = :einv_diib_id AND line_code = :line_code AND id <> :id';
    Q.ParamByName('einv_diib_id').AsLargeInt := ADiibId;
    Q.ParamByName('line_code').AsWideString := ALineCode;
    Q.ParamByName('id').AsLargeInt := AExcludeId;
    LogQuery(Q, 'LineCodeExists');
    Q.Open;
    Result := not Q.IsEmpty;
  finally
    Q.Free;
  end;
end;

function TEInvDiibLineRepository.UsageCount(AId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) AS cnt FROM public.sls_invoice_detail ' +
                  ' WHERE seller_einv_diib_line_id = :id OR buyer_einv_diib_line_id = :id';
    Q.ParamByName('id').AsLargeInt := AId;
    LogQuery(Q, 'UsageCount');
    Q.Open;
    Result := Q.FieldByName('cnt').AsInteger;
  finally
    Q.Free;
  end;
end;

// Boş GTİP ve DİİB ürün tanımı stok kartından (tanım yoksa stok adı)
procedure TEInvDiibLineRepository.FillFromInventory(AModel: TEInvDiibLine);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT i.einv_gtip_id, g.code AS gtip_code, g.name AS gtip_name, ' +
                  '       COALESCE(NULLIF(i.diib_product_description, ''''), i.name) AS product_description ' +
                  '  FROM public.stk_inventory i LEFT JOIN public.einv_gtip g ON g.id = i.einv_gtip_id ' +
                  ' WHERE i.id = :id';
    Q.ParamByName('id').AsLargeInt := AModel.StkInventoryId;
    LogQuery(Q, 'FillFromInventory');
    Q.Open;
    if Q.IsEmpty then
      Exit;
    if (AModel.EinvGtipId <= 0) and not Q.FieldByName('einv_gtip_id').IsNull then
    begin
      AModel.EinvGtipId := Q.FieldByName('einv_gtip_id').AsLargeInt;
      AModel.GtipCode := Q.FieldByName('gtip_code').AsString;
      AModel.GtipName := Q.FieldByName('gtip_name').AsString;
    end;
    if AModel.ProductDescription = '' then
      AModel.ProductDescription := Q.FieldByName('product_description').AsString;
  finally
    Q.Free;
  end;
end;

function TEInvDiibLineRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TEInvDiibLine) +
            ' (einv_diib_id, line_code, line_kind, einv_gtip_id, product_description, stk_inventory_id, quantity, sys_uom_id, is_active) ' +
            ' VALUES (:einv_diib_id, :line_code, :line_kind, :einv_gtip_id, :product_description, :stk_inventory_id, :quantity, :sys_uom_id, :is_active)';
end;

function TEInvDiibLineRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TEInvDiibLine) +
            ' SET einv_diib_id = :einv_diib_id, line_code = :line_code, line_kind = :line_kind, einv_gtip_id = :einv_gtip_id, product_description = :product_description, stk_inventory_id = :stk_inventory_id, quantity = :quantity, sys_uom_id = :sys_uom_id, is_active = :is_active ' +
            ' WHERE id = :id';
end;

function TEInvDiibLineRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TEInvDiibLine) + ' WHERE';
end;

procedure TEInvDiibLineRepository.SetInsertParams(Q: TFDQuery; AModel: TEInvDiibLine; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('line_code').AsWideString := AModel.LineCode;
    Q.ParamByName('line_kind').AsSmallInt := AModel.LineKind;
    Q.ParamByName('product_description').AsWideString := AModel.ProductDescription;
    Q.ParamByName('quantity').AsBCD := AModel.Quantity;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
  end
  else
  begin
    Q.ParamByName('line_code').AsWideStrings[AIndex] := AModel.LineCode;
    Q.ParamByName('line_kind').AsSmallInts[AIndex] := AModel.LineKind;
    Q.ParamByName('product_description').AsWideStrings[AIndex] := AModel.ProductDescription;
    Q.ParamByName('quantity').AsBCDs[AIndex] := AModel.Quantity;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
  end;

  SetNullableParam(Q.ParamByName('einv_diib_id'), ftLargeint, AModel.EinvDiibId, AIndex);
  SetNullableParam(Q.ParamByName('einv_gtip_id'), ftLargeint, AModel.EinvGtipId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('sys_uom_id'), ftLargeint, AModel.SysUomId, AIndex);
end;

procedure TEInvDiibLineRepository.SetUpdateParams(Q: TFDQuery; AModel: TEInvDiibLine; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('line_code').AsWideString := AModel.LineCode;
    Q.ParamByName('line_kind').AsSmallInt := AModel.LineKind;
    Q.ParamByName('product_description').AsWideString := AModel.ProductDescription;
    Q.ParamByName('quantity').AsBCD := AModel.Quantity;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('line_code').AsWideStrings[AIndex] := AModel.LineCode;
    Q.ParamByName('line_kind').AsSmallInts[AIndex] := AModel.LineKind;
    Q.ParamByName('product_description').AsWideStrings[AIndex] := AModel.ProductDescription;
    Q.ParamByName('quantity').AsBCDs[AIndex] := AModel.Quantity;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
  end;

  SetNullableParam(Q.ParamByName('einv_diib_id'), ftLargeint, AModel.EinvDiibId, AIndex);
  SetNullableParam(Q.ParamByName('einv_gtip_id'), ftLargeint, AModel.EinvGtipId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('sys_uom_id'), ftLargeint, AModel.SysUomId, AIndex);
end;

function TEInvDiibLineRepository.MapFromQuery(Q: TFDQuery): TEInvDiibLine;
begin
  Result := TEInvDiibLine.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.EinvDiibId := Q.FieldByName('einv_diib_id').AsLargeInt;
  Result.LineCode := Q.FieldByName('line_code').AsString;
  Result.LineKind := Q.FieldByName('line_kind').AsInteger;
  Result.EinvGtipId := Q.FieldByName('einv_gtip_id').AsLargeInt;
  Result.ProductDescription := Q.FieldByName('product_description').AsString;
  Result.StkInventoryId := Q.FieldByName('stk_inventory_id').AsLargeInt;
  Result.Quantity := Q.FieldByName('quantity').AsCurrency;
  Result.SysUomId := Q.FieldByName('sys_uom_id').AsLargeInt;
  Result.IsActive := Q.FieldByName('is_active').AsBoolean;
  Result.DocumentNo := Q.FieldByName('document_no').AsString;
  Result.HolderType := Q.FieldByName('holder_type').AsInteger;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  Result.AccountName := Q.FieldByName('account_name').AsString;
  Result.GtipCode := Q.FieldByName('gtip_code').AsString;
  Result.GtipName := Q.FieldByName('gtip_name').AsString;
  Result.InventoryCode := Q.FieldByName('inventory_code').AsString;
  Result.InventoryName := Q.FieldByName('inventory_name').AsString;
  Result.UnitCode := Q.FieldByName('unit_code').AsString;
  Result.UomEinvCode := Q.FieldByName('uom_einv_code').AsString;
  Result.DiibIsActive := Q.FieldByName('diib_is_active').AsBoolean;
end;

function TEInvDiibLineRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TEInvDiibLine) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TEInvDiibLineRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TEInvDiibLine>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TEInvDiibLine>.Create(True);
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

function TEInvDiibLineRepository.DoFindById(AId: TValue; ALock: Boolean): TEInvDiibLine;
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

function TEInvDiibLineRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TEInvDiibLine;
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

procedure TEInvDiibLineRepository.DoAdd(AModel: TEInvDiibLine);
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

procedure TEInvDiibLineRepository.DoAddBatch(AModels: TArray<TEInvDiibLine>);
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

procedure TEInvDiibLineRepository.DoUpdate(AModel: TEInvDiibLine);
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

procedure TEInvDiibLineRepository.DoUpdateBatch(AModels: TArray<TEInvDiibLine>);
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

procedure TEInvDiibLineRepository.DoDelete(AID: TValue);
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

procedure TEInvDiibLineRepository.DoDelete(AModel: TEInvDiibLine);
begin
  Delete(AModel.Id);
end;

procedure TEInvDiibLineRepository.DoDeleteBatch(AModels: TArray<TEInvDiibLine>);
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

procedure TEInvDiibLineRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TEInvDiibLineRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
