unit PrdBomPacketRaw.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, PrdBomPacketRaw;

type
  TPrdBomPacketRawRepository = class(TRepository<TPrdBomPacketRaw>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TPrdBomPacketRaw; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TPrdBomPacketRaw; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TPrdBomPacketRaw; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TPrdBomPacketRaw>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TPrdBomPacketRaw; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TPrdBomPacketRaw; override;

    procedure DoAdd(AModel: TPrdBomPacketRaw); override;
    procedure DoAddBatch(AModels: TArray<TPrdBomPacketRaw>); override;

    procedure DoUpdate(AModel: TPrdBomPacketRaw); override;
    procedure DoUpdateBatch(AModels: TArray<TPrdBomPacketRaw>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TPrdBomPacketRaw); override;
    procedure DoDeleteBatch(AModels: TArray<TPrdBomPacketRaw>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TPrdBomPacketRawRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TPrdBomPacketRawRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TPrdBomPacketRaw) +
            ' (prd_bom_id, prd_packet_raw_id, quantity) ' +
            ' VALUES (:prd_bom_id, :prd_packet_raw_id, :quantity)';
end;

function TPrdBomPacketRawRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TPrdBomPacketRaw) +
            ' SET prd_bom_id = :prd_bom_id, prd_packet_raw_id = :prd_packet_raw_id, quantity = :quantity ' +
            ' WHERE id = :id';
end;

function TPrdBomPacketRawRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TPrdBomPacketRaw) + ' WHERE';
end;

procedure TPrdBomPacketRawRepository.SetInsertParams(Q: TFDQuery; AModel: TPrdBomPacketRaw; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('quantity').AsBCD := AModel.Quantity;
  end
  else
  begin
    Q.ParamByName('quantity').AsBCDs[AIndex] := AModel.Quantity;
  end;

  SetNullableParam(Q.ParamByName('prd_bom_id'), ftLargeint, AModel.PrdBomId, AIndex);
  SetNullableParam(Q.ParamByName('prd_packet_raw_id'), ftLargeint, AModel.PrdPacketRawId, AIndex);
end;

procedure TPrdBomPacketRawRepository.SetUpdateParams(Q: TFDQuery; AModel: TPrdBomPacketRaw; AIndex: Integer);
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

  SetNullableParam(Q.ParamByName('prd_bom_id'), ftLargeint, AModel.PrdBomId, AIndex);
  SetNullableParam(Q.ParamByName('prd_packet_raw_id'), ftLargeint, AModel.PrdPacketRawId, AIndex);
end;

function TPrdBomPacketRawRepository.MapFromQuery(Q: TFDQuery): TPrdBomPacketRaw;
begin
  Result := TPrdBomPacketRaw.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.PrdBomId := Q.FieldByName('prd_bom_id').AsLargeInt;
  Result.PrdPacketRawId := Q.FieldByName('prd_packet_raw_id').AsLargeInt;
  Result.Quantity := Q.FieldByName('quantity').AsCurrency;
  Result.BomName := Q.FieldByName('bom_name').AsString;
  Result.PacketName := Q.FieldByName('packet_name').AsString;
end;

function TPrdBomPacketRawRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TPrdBomPacketRaw) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TPrdBomPacketRawRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TPrdBomPacketRaw>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TPrdBomPacketRaw>.Create(True);
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

function TPrdBomPacketRawRepository.DoFindById(AId: TValue; ALock: Boolean): TPrdBomPacketRaw;
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

function TPrdBomPacketRawRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TPrdBomPacketRaw;
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

procedure TPrdBomPacketRawRepository.DoAdd(AModel: TPrdBomPacketRaw);
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

procedure TPrdBomPacketRawRepository.DoAddBatch(AModels: TArray<TPrdBomPacketRaw>);
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

procedure TPrdBomPacketRawRepository.DoUpdate(AModel: TPrdBomPacketRaw);
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

procedure TPrdBomPacketRawRepository.DoUpdateBatch(AModels: TArray<TPrdBomPacketRaw>);
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

procedure TPrdBomPacketRawRepository.DoDelete(AID: TValue);
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

procedure TPrdBomPacketRawRepository.DoDelete(AModel: TPrdBomPacketRaw);
begin
  Delete(AModel.Id);
end;

procedure TPrdBomPacketRawRepository.DoDeleteBatch(AModels: TArray<TPrdBomPacketRaw>);
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

procedure TPrdBomPacketRawRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TPrdBomPacketRawRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
