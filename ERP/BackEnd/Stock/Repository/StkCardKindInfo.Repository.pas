unit StkCardKindInfo.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, StkCardKindInfo;

type
  TStkCardKindInfoRepository = class(TRepository<TStkCardKindInfo>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TStkCardKindInfo; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TStkCardKindInfo; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TStkCardKindInfo; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TStkCardKindInfo>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TStkCardKindInfo; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TStkCardKindInfo; override;

    procedure DoAdd(AModel: TStkCardKindInfo); override;
    procedure DoAddBatch(AModels: TArray<TStkCardKindInfo>); override;

    procedure DoUpdate(AModel: TStkCardKindInfo); override;
    procedure DoUpdateBatch(AModels: TArray<TStkCardKindInfo>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TStkCardKindInfo); override;
    procedure DoDeleteBatch(AModels: TArray<TStkCardKindInfo>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TStkCardKindInfoRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TStkCardKindInfoRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TStkCardKindInfo) +
            ' (stk_inventory_id, stk_kind_property_id, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, i1, i2, i3, i4, i5, d1, d2, d3, d4, d5) ' +
            ' VALUES (:stk_inventory_id, :stk_kind_property_id, :s1, :s2, :s3, :s4, :s5, :s6, :s7, :s8, :s9, :s10, :i1, :i2, :i3, :i4, :i5, :d1, :d2, :d3, :d4, :d5)';
end;

function TStkCardKindInfoRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TStkCardKindInfo) +
            ' SET stk_inventory_id = :stk_inventory_id, stk_kind_property_id = :stk_kind_property_id, s1 = :s1, s2 = :s2, s3 = :s3, s4 = :s4, s5 = :s5, s6 = :s6, s7 = :s7, s8 = :s8, s9 = :s9, s10 = :s10, i1 = :i1, i2 = :i2, i3 = :i3, i4 = :i4, i5 = :i5, d1 = :d1, d2 = :d2, d3 = :d3, d4 = :d4, d5 = :d5 ' +
            ' WHERE id = :id';
end;

function TStkCardKindInfoRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TStkCardKindInfo) + ' WHERE';
end;

procedure TStkCardKindInfoRepository.SetInsertParams(Q: TFDQuery; AModel: TStkCardKindInfo; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('s1').AsString := AModel.S1;
    Q.ParamByName('s2').AsString := AModel.S2;
    Q.ParamByName('s3').AsString := AModel.S3;
    Q.ParamByName('s4').AsString := AModel.S4;
    Q.ParamByName('s5').AsString := AModel.S5;
    Q.ParamByName('s6').AsString := AModel.S6;
    Q.ParamByName('s7').AsString := AModel.S7;
    Q.ParamByName('s8').AsString := AModel.S8;
    Q.ParamByName('s9').AsString := AModel.S9;
    Q.ParamByName('s10').AsString := AModel.S10;
    Q.ParamByName('i1').AsInteger := AModel.I1;
    Q.ParamByName('i2').AsInteger := AModel.I2;
    Q.ParamByName('i3').AsInteger := AModel.I3;
    Q.ParamByName('i4').AsInteger := AModel.I4;
    Q.ParamByName('i5').AsInteger := AModel.I5;
    Q.ParamByName('d1').AsFloat := AModel.D1;
    Q.ParamByName('d2').AsFloat := AModel.D2;
    Q.ParamByName('d3').AsFloat := AModel.D3;
    Q.ParamByName('d4').AsFloat := AModel.D4;
    Q.ParamByName('d5').AsFloat := AModel.D5;
  end
  else
  begin
    Q.ParamByName('s1').AsStrings[AIndex] := AModel.S1;
    Q.ParamByName('s2').AsStrings[AIndex] := AModel.S2;
    Q.ParamByName('s3').AsStrings[AIndex] := AModel.S3;
    Q.ParamByName('s4').AsStrings[AIndex] := AModel.S4;
    Q.ParamByName('s5').AsStrings[AIndex] := AModel.S5;
    Q.ParamByName('s6').AsStrings[AIndex] := AModel.S6;
    Q.ParamByName('s7').AsStrings[AIndex] := AModel.S7;
    Q.ParamByName('s8').AsStrings[AIndex] := AModel.S8;
    Q.ParamByName('s9').AsStrings[AIndex] := AModel.S9;
    Q.ParamByName('s10').AsStrings[AIndex] := AModel.S10;
    Q.ParamByName('i1').AsIntegers[AIndex] := AModel.I1;
    Q.ParamByName('i2').AsIntegers[AIndex] := AModel.I2;
    Q.ParamByName('i3').AsIntegers[AIndex] := AModel.I3;
    Q.ParamByName('i4').AsIntegers[AIndex] := AModel.I4;
    Q.ParamByName('i5').AsIntegers[AIndex] := AModel.I5;
    Q.ParamByName('d1').AsFloats[AIndex] := AModel.D1;
    Q.ParamByName('d2').AsFloats[AIndex] := AModel.D2;
    Q.ParamByName('d3').AsFloats[AIndex] := AModel.D3;
    Q.ParamByName('d4').AsFloats[AIndex] := AModel.D4;
    Q.ParamByName('d5').AsFloats[AIndex] := AModel.D5;
  end;

  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('stk_kind_property_id'), ftLargeint, AModel.StkKindPropertyId, AIndex);
end;

procedure TStkCardKindInfoRepository.SetUpdateParams(Q: TFDQuery; AModel: TStkCardKindInfo; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('s1').AsString := AModel.S1;
    Q.ParamByName('s2').AsString := AModel.S2;
    Q.ParamByName('s3').AsString := AModel.S3;
    Q.ParamByName('s4').AsString := AModel.S4;
    Q.ParamByName('s5').AsString := AModel.S5;
    Q.ParamByName('s6').AsString := AModel.S6;
    Q.ParamByName('s7').AsString := AModel.S7;
    Q.ParamByName('s8').AsString := AModel.S8;
    Q.ParamByName('s9').AsString := AModel.S9;
    Q.ParamByName('s10').AsString := AModel.S10;
    Q.ParamByName('i1').AsInteger := AModel.I1;
    Q.ParamByName('i2').AsInteger := AModel.I2;
    Q.ParamByName('i3').AsInteger := AModel.I3;
    Q.ParamByName('i4').AsInteger := AModel.I4;
    Q.ParamByName('i5').AsInteger := AModel.I5;
    Q.ParamByName('d1').AsFloat := AModel.D1;
    Q.ParamByName('d2').AsFloat := AModel.D2;
    Q.ParamByName('d3').AsFloat := AModel.D3;
    Q.ParamByName('d4').AsFloat := AModel.D4;
    Q.ParamByName('d5').AsFloat := AModel.D5;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('s1').AsStrings[AIndex] := AModel.S1;
    Q.ParamByName('s2').AsStrings[AIndex] := AModel.S2;
    Q.ParamByName('s3').AsStrings[AIndex] := AModel.S3;
    Q.ParamByName('s4').AsStrings[AIndex] := AModel.S4;
    Q.ParamByName('s5').AsStrings[AIndex] := AModel.S5;
    Q.ParamByName('s6').AsStrings[AIndex] := AModel.S6;
    Q.ParamByName('s7').AsStrings[AIndex] := AModel.S7;
    Q.ParamByName('s8').AsStrings[AIndex] := AModel.S8;
    Q.ParamByName('s9').AsStrings[AIndex] := AModel.S9;
    Q.ParamByName('s10').AsStrings[AIndex] := AModel.S10;
    Q.ParamByName('i1').AsIntegers[AIndex] := AModel.I1;
    Q.ParamByName('i2').AsIntegers[AIndex] := AModel.I2;
    Q.ParamByName('i3').AsIntegers[AIndex] := AModel.I3;
    Q.ParamByName('i4').AsIntegers[AIndex] := AModel.I4;
    Q.ParamByName('i5').AsIntegers[AIndex] := AModel.I5;
    Q.ParamByName('d1').AsFloats[AIndex] := AModel.D1;
    Q.ParamByName('d2').AsFloats[AIndex] := AModel.D2;
    Q.ParamByName('d3').AsFloats[AIndex] := AModel.D3;
    Q.ParamByName('d4').AsFloats[AIndex] := AModel.D4;
    Q.ParamByName('d5').AsFloats[AIndex] := AModel.D5;
  end;

  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('stk_kind_property_id'), ftLargeint, AModel.StkKindPropertyId, AIndex);
end;

function TStkCardKindInfoRepository.MapFromQuery(Q: TFDQuery): TStkCardKindInfo;
begin
  Result := TStkCardKindInfo.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.StkInventoryId := Q.FieldByName('stk_inventory_id').AsLargeInt;
  Result.StkKindPropertyId := Q.FieldByName('stk_kind_property_id').AsLargeInt;
  Result.S1 := Q.FieldByName('s1').AsString;
  Result.S2 := Q.FieldByName('s2').AsString;
  Result.S3 := Q.FieldByName('s3').AsString;
  Result.S4 := Q.FieldByName('s4').AsString;
  Result.S5 := Q.FieldByName('s5').AsString;
  Result.S6 := Q.FieldByName('s6').AsString;
  Result.S7 := Q.FieldByName('s7').AsString;
  Result.S8 := Q.FieldByName('s8').AsString;
  Result.S9 := Q.FieldByName('s9').AsString;
  Result.S10 := Q.FieldByName('s10').AsString;
  Result.I1 := Q.FieldByName('i1').AsInteger;
  Result.I2 := Q.FieldByName('i2').AsInteger;
  Result.I3 := Q.FieldByName('i3').AsInteger;
  Result.I4 := Q.FieldByName('i4').AsInteger;
  Result.I5 := Q.FieldByName('i5').AsInteger;
  Result.D1 := Q.FieldByName('d1').AsFloat;
  Result.D2 := Q.FieldByName('d2').AsFloat;
  Result.D3 := Q.FieldByName('d3').AsFloat;
  Result.D4 := Q.FieldByName('d4').AsFloat;
  Result.D5 := Q.FieldByName('d5').AsFloat;
  Result.InventoryName := Q.FieldByName('inventory_name').AsString;
  Result.KindName := Q.FieldByName('kind_name').AsString;
  Result.InventoryCode := Q.FieldByName('inventory_code').AsString;
end;

function TStkCardKindInfoRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TStkCardKindInfo) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TStkCardKindInfoRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TStkCardKindInfo>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TStkCardKindInfo>.Create(True);
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

function TStkCardKindInfoRepository.DoFindById(AId: TValue; ALock: Boolean): TStkCardKindInfo;
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

function TStkCardKindInfoRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TStkCardKindInfo;
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

procedure TStkCardKindInfoRepository.DoAdd(AModel: TStkCardKindInfo);
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

procedure TStkCardKindInfoRepository.DoAddBatch(AModels: TArray<TStkCardKindInfo>);
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

procedure TStkCardKindInfoRepository.DoUpdate(AModel: TStkCardKindInfo);
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

procedure TStkCardKindInfoRepository.DoUpdateBatch(AModels: TArray<TStkCardKindInfo>);
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

procedure TStkCardKindInfoRepository.DoDelete(AID: TValue);
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

procedure TStkCardKindInfoRepository.DoDelete(AModel: TStkCardKindInfo);
begin
  Delete(AModel.Id);
end;

procedure TStkCardKindInfoRepository.DoDeleteBatch(AModels: TArray<TStkCardKindInfo>);
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

procedure TStkCardKindInfoRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TStkCardKindInfoRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
