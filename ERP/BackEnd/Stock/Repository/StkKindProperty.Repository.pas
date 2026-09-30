unit StkKindProperty.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, StkKindProperty;

type
  TStkKindPropertyRepository = class(TRepository<TStkKindProperty>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TStkKindProperty; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TStkKindProperty; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TStkKindProperty; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TStkKindProperty>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TStkKindProperty; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TStkKindProperty; override;

    procedure DoAdd(AModel: TStkKindProperty); override;
    procedure DoAddBatch(AModels: TArray<TStkKindProperty>); override;

    procedure DoUpdate(AModel: TStkKindProperty); override;
    procedure DoUpdateBatch(AModels: TArray<TStkKindProperty>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TStkKindProperty); override;
    procedure DoDeleteBatch(AModels: TArray<TStkKindProperty>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TStkKindPropertyRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TStkKindPropertyRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TStkKindProperty) +
            ' (kind, description, stk_kind_family_id, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, i1, i2, i3, i4, i5, d1, d2, d3, d4, d5) ' +
            ' VALUES (:kind, :description, :stk_kind_family_id, :s1, :s2, :s3, :s4, :s5, :s6, :s7, :s8, :s9, :s10, :i1, :i2, :i3, :i4, :i5, :d1, :d2, :d3, :d4, :d5)';
end;

function TStkKindPropertyRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TStkKindProperty) +
            ' SET kind = :kind, description = :description, stk_kind_family_id = :stk_kind_family_id, s1 = :s1, s2 = :s2, s3 = :s3, s4 = :s4, s5 = :s5, s6 = :s6, s7 = :s7, s8 = :s8, s9 = :s9, s10 = :s10, i1 = :i1, i2 = :i2, i3 = :i3, i4 = :i4, i5 = :i5, d1 = :d1, d2 = :d2, d3 = :d3, d4 = :d4, d5 = :d5 ' +
            ' WHERE id = :id';
end;

function TStkKindPropertyRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TStkKindProperty) + ' WHERE';
end;

procedure TStkKindPropertyRepository.SetInsertParams(Q: TFDQuery; AModel: TStkKindProperty; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('kind').AsString := AModel.Kind;
    Q.ParamByName('description').AsString := AModel.Description;
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
    Q.ParamByName('i1').AsString := AModel.I1;
    Q.ParamByName('i2').AsString := AModel.I2;
    Q.ParamByName('i3').AsString := AModel.I3;
    Q.ParamByName('i4').AsString := AModel.I4;
    Q.ParamByName('i5').AsString := AModel.I5;
    Q.ParamByName('d1').AsString := AModel.D1;
    Q.ParamByName('d2').AsString := AModel.D2;
    Q.ParamByName('d3').AsString := AModel.D3;
    Q.ParamByName('d4').AsString := AModel.D4;
    Q.ParamByName('d5').AsString := AModel.D5;
  end
  else
  begin
    Q.ParamByName('kind').AsStrings[AIndex] := AModel.Kind;
    Q.ParamByName('description').AsStrings[AIndex] := AModel.Description;
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
    Q.ParamByName('i1').AsStrings[AIndex] := AModel.I1;
    Q.ParamByName('i2').AsStrings[AIndex] := AModel.I2;
    Q.ParamByName('i3').AsStrings[AIndex] := AModel.I3;
    Q.ParamByName('i4').AsStrings[AIndex] := AModel.I4;
    Q.ParamByName('i5').AsStrings[AIndex] := AModel.I5;
    Q.ParamByName('d1').AsStrings[AIndex] := AModel.D1;
    Q.ParamByName('d2').AsStrings[AIndex] := AModel.D2;
    Q.ParamByName('d3').AsStrings[AIndex] := AModel.D3;
    Q.ParamByName('d4').AsStrings[AIndex] := AModel.D4;
    Q.ParamByName('d5').AsStrings[AIndex] := AModel.D5;
  end;

  SetNullableParam(Q.ParamByName('stk_kind_family_id'), ftLargeint, AModel.StkKindFamilyId, AIndex);
end;

procedure TStkKindPropertyRepository.SetUpdateParams(Q: TFDQuery; AModel: TStkKindProperty; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('kind').AsString := AModel.Kind;
    Q.ParamByName('description').AsString := AModel.Description;
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
    Q.ParamByName('i1').AsString := AModel.I1;
    Q.ParamByName('i2').AsString := AModel.I2;
    Q.ParamByName('i3').AsString := AModel.I3;
    Q.ParamByName('i4').AsString := AModel.I4;
    Q.ParamByName('i5').AsString := AModel.I5;
    Q.ParamByName('d1').AsString := AModel.D1;
    Q.ParamByName('d2').AsString := AModel.D2;
    Q.ParamByName('d3').AsString := AModel.D3;
    Q.ParamByName('d4').AsString := AModel.D4;
    Q.ParamByName('d5').AsString := AModel.D5;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('kind').AsStrings[AIndex] := AModel.Kind;
    Q.ParamByName('description').AsStrings[AIndex] := AModel.Description;
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
    Q.ParamByName('i1').AsStrings[AIndex] := AModel.I1;
    Q.ParamByName('i2').AsStrings[AIndex] := AModel.I2;
    Q.ParamByName('i3').AsStrings[AIndex] := AModel.I3;
    Q.ParamByName('i4').AsStrings[AIndex] := AModel.I4;
    Q.ParamByName('i5').AsStrings[AIndex] := AModel.I5;
    Q.ParamByName('d1').AsStrings[AIndex] := AModel.D1;
    Q.ParamByName('d2').AsStrings[AIndex] := AModel.D2;
    Q.ParamByName('d3').AsStrings[AIndex] := AModel.D3;
    Q.ParamByName('d4').AsStrings[AIndex] := AModel.D4;
    Q.ParamByName('d5').AsStrings[AIndex] := AModel.D5;
  end;

  SetNullableParam(Q.ParamByName('stk_kind_family_id'), ftLargeint, AModel.StkKindFamilyId, AIndex);
end;

function TStkKindPropertyRepository.MapFromQuery(Q: TFDQuery): TStkKindProperty;
begin
  Result := TStkKindProperty.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.Kind := Q.FieldByName('kind').AsString;
  Result.Description := Q.FieldByName('description').AsString;
  Result.StkKindFamilyId := Q.FieldByName('stk_kind_family_id').AsLargeInt;
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
  Result.I1 := Q.FieldByName('i1').AsString;
  Result.I2 := Q.FieldByName('i2').AsString;
  Result.I3 := Q.FieldByName('i3').AsString;
  Result.I4 := Q.FieldByName('i4').AsString;
  Result.I5 := Q.FieldByName('i5').AsString;
  Result.D1 := Q.FieldByName('d1').AsString;
  Result.D2 := Q.FieldByName('d2').AsString;
  Result.D3 := Q.FieldByName('d3').AsString;
  Result.D4 := Q.FieldByName('d4').AsString;
  Result.D5 := Q.FieldByName('d5').AsString;
  Result.FamilyName := Q.FieldByName('family_name').AsString;
end;

function TStkKindPropertyRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TStkKindProperty) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TStkKindPropertyRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TStkKindProperty>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TStkKindProperty>.Create(True);
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

function TStkKindPropertyRepository.DoFindById(AId: TValue; ALock: Boolean): TStkKindProperty;
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

function TStkKindPropertyRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TStkKindProperty;
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

procedure TStkKindPropertyRepository.DoAdd(AModel: TStkKindProperty);
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

procedure TStkKindPropertyRepository.DoAddBatch(AModels: TArray<TStkKindProperty>);
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

procedure TStkKindPropertyRepository.DoUpdate(AModel: TStkKindProperty);
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

procedure TStkKindPropertyRepository.DoUpdateBatch(AModels: TArray<TStkKindProperty>);
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

procedure TStkKindPropertyRepository.DoDelete(AID: TValue);
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

procedure TStkKindPropertyRepository.DoDelete(AModel: TStkKindProperty);
begin
  Delete(AModel.Id);
end;

procedure TStkKindPropertyRepository.DoDeleteBatch(AModels: TArray<TStkKindProperty>);
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

procedure TStkKindPropertyRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TStkKindPropertyRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
