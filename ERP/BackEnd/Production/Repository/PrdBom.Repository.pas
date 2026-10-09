unit PrdBom.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, PrdBom;

type
  TPrdBomRepository = class(TRepository<TPrdBom>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TPrdBom; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TPrdBom; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TPrdBom; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TPrdBom>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TPrdBom; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TPrdBom; override;

    procedure DoAdd(AModel: TPrdBom); override;
    procedure DoAddBatch(AModels: TArray<TPrdBom>); override;

    procedure DoUpdate(AModel: TPrdBom); override;
    procedure DoUpdateBatch(AModels: TArray<TPrdBom>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TPrdBom); override;
    procedure DoDeleteBatch(AModels: TArray<TPrdBom>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TPrdBomRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TPrdBomRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TPrdBom) +
            ' (stk_inventory_id, bom_name, base_quantity, is_default, is_active, description) ' +
            ' VALUES (:stk_inventory_id, :bom_name, :base_quantity, :is_default, :is_active, :description)';
end;

function TPrdBomRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TPrdBom) +
            ' SET stk_inventory_id = :stk_inventory_id, bom_name = :bom_name, base_quantity = :base_quantity, is_default = :is_default, is_active = :is_active, description = :description ' +
            ' WHERE id = :id';
end;

function TPrdBomRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TPrdBom) + ' WHERE';
end;

procedure TPrdBomRepository.SetInsertParams(Q: TFDQuery; AModel: TPrdBom; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('bom_name').AsString := AModel.BomName;
    Q.ParamByName('base_quantity').AsCurrency := AModel.BaseQuantity;
    Q.ParamByName('is_default').AsBoolean := AModel.IsDefault;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
    Q.ParamByName('description').AsString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('bom_name').AsStrings[AIndex] := AModel.BomName;
    Q.ParamByName('base_quantity').AsCurrencys[AIndex] := AModel.BaseQuantity;
    Q.ParamByName('is_default').AsBooleans[AIndex] := AModel.IsDefault;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
    Q.ParamByName('description').AsStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
end;

procedure TPrdBomRepository.SetUpdateParams(Q: TFDQuery; AModel: TPrdBom; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('bom_name').AsString := AModel.BomName;
    Q.ParamByName('base_quantity').AsCurrency := AModel.BaseQuantity;
    Q.ParamByName('is_default').AsBoolean := AModel.IsDefault;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
    Q.ParamByName('description').AsString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('bom_name').AsStrings[AIndex] := AModel.BomName;
    Q.ParamByName('base_quantity').AsCurrencys[AIndex] := AModel.BaseQuantity;
    Q.ParamByName('is_default').AsBooleans[AIndex] := AModel.IsDefault;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
    Q.ParamByName('description').AsStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
end;

function TPrdBomRepository.MapFromQuery(Q: TFDQuery): TPrdBom;
begin
  Result := TPrdBom.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.StkInventoryId := Q.FieldByName('stk_inventory_id').AsLargeInt;
  Result.BomName := Q.FieldByName('bom_name').AsString;
  Result.BaseQuantity := Q.FieldByName('base_quantity').AsCurrency;
  Result.IsDefault := Q.FieldByName('is_default').AsBoolean;
  Result.IsActive := Q.FieldByName('is_active').AsBoolean;
  Result.Description := Q.FieldByName('description').AsString;
  Result.InventoryCode := Q.FieldByName('inventory_code').AsString;
  Result.InventoryName := Q.FieldByName('inventory_name').AsString;
  Result.RawCount := Q.FieldByName('raw_count').AsString;
  Result.LabourCount := Q.FieldByName('labour_count').AsString;
end;

function TPrdBomRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TPrdBom) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TPrdBomRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TPrdBom>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TPrdBom>.Create(True);
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

function TPrdBomRepository.DoFindById(AId: TValue; ALock: Boolean): TPrdBom;
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

function TPrdBomRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TPrdBom;
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

procedure TPrdBomRepository.DoAdd(AModel: TPrdBom);
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
end;

procedure TPrdBomRepository.DoAddBatch(AModels: TArray<TPrdBom>);
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

procedure TPrdBomRepository.DoUpdate(AModel: TPrdBom);
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
end;

procedure TPrdBomRepository.DoUpdateBatch(AModels: TArray<TPrdBom>);
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

procedure TPrdBomRepository.DoDelete(AID: TValue);
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

procedure TPrdBomRepository.DoDelete(AModel: TPrdBom);
begin
  Delete(AModel.Id);
end;

procedure TPrdBomRepository.DoDeleteBatch(AModels: TArray<TPrdBom>);
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

procedure TPrdBomRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TPrdBomRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
