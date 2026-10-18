unit EInvVehicle.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, EInvVehicle;

type
  TEInvVehicleRepository = class(TRepository<TEInvVehicle>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TEInvVehicle; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TEInvVehicle; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TEInvVehicle; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TEInvVehicle>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TEInvVehicle; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TEInvVehicle; override;

    procedure DoAdd(AModel: TEInvVehicle); override;
    procedure DoAddBatch(AModels: TArray<TEInvVehicle>); override;

    procedure DoUpdate(AModel: TEInvVehicle); override;
    procedure DoUpdateBatch(AModels: TArray<TEInvVehicle>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TEInvVehicle); override;
    procedure DoDeleteBatch(AModels: TArray<TEInvVehicle>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function PlateExists(const AValue: string; AExcludeId: Int64): Boolean;
    function UsageCount(AId: Int64): Integer;
  end;

implementation

constructor TEInvVehicleRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TEInvVehicleRepository.PlateExists(const AValue: string; AExcludeId: Int64): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT 1 FROM public.einv_vehicle WHERE plate_no = :v AND id <> :id';
    Q.ParamByName('v').AsWideString := AValue;
    Q.ParamByName('id').AsLargeInt := AExcludeId;
    LogQuery(Q, 'PlateExists');
    Q.Open;
    Result := not Q.IsEmpty;
  finally
    Q.Free;
  end;
end;

// Kaydı kullanan irsaliye sayısı (silmek yerine pasif yapılmalı)
function TEInvVehicleRepository.UsageCount(AId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) AS cnt FROM public.sls_dispatch WHERE :id IN (einv_vehicle_id, trailer1_einv_vehicle_id, trailer2_einv_vehicle_id)';
    Q.ParamByName('id').AsLargeInt := AId;
    LogQuery(Q, 'UsageCount');
    Q.Open;
    Result := Q.FieldByName('cnt').AsInteger;
  finally
    Q.Free;
  end;
end;

function TEInvVehicleRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TEInvVehicle) +
            ' (plate_no, is_trailer, description, is_active) ' +
            ' VALUES (:plate_no, :is_trailer, :description, :is_active)';
end;

function TEInvVehicleRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TEInvVehicle) +
            ' SET plate_no = :plate_no, is_trailer = :is_trailer, description = :description, is_active = :is_active ' +
            ' WHERE id = :id';
end;

function TEInvVehicleRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TEInvVehicle) + ' WHERE';
end;

procedure TEInvVehicleRepository.SetInsertParams(Q: TFDQuery; AModel: TEInvVehicle; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('plate_no').AsWideString := AModel.PlateNo;
    Q.ParamByName('is_trailer').AsBoolean := AModel.IsTrailer;
    Q.ParamByName('description').AsWideString := AModel.Description;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
  end
  else
  begin
    Q.ParamByName('plate_no').AsWideStrings[AIndex] := AModel.PlateNo;
    Q.ParamByName('is_trailer').AsBooleans[AIndex] := AModel.IsTrailer;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
  end;


end;

procedure TEInvVehicleRepository.SetUpdateParams(Q: TFDQuery; AModel: TEInvVehicle; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('plate_no').AsWideString := AModel.PlateNo;
    Q.ParamByName('is_trailer').AsBoolean := AModel.IsTrailer;
    Q.ParamByName('description').AsWideString := AModel.Description;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('plate_no').AsWideStrings[AIndex] := AModel.PlateNo;
    Q.ParamByName('is_trailer').AsBooleans[AIndex] := AModel.IsTrailer;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
  end;


end;

function TEInvVehicleRepository.MapFromQuery(Q: TFDQuery): TEInvVehicle;
begin
  Result := TEInvVehicle.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.PlateNo := Q.FieldByName('plate_no').AsString;
  Result.IsTrailer := Q.FieldByName('is_trailer').AsBoolean;
  Result.Description := Q.FieldByName('description').AsString;
  Result.IsActive := Q.FieldByName('is_active').AsBoolean;
end;

function TEInvVehicleRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TEInvVehicle) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TEInvVehicleRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TEInvVehicle>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TEInvVehicle>.Create(True);
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

function TEInvVehicleRepository.DoFindById(AId: TValue; ALock: Boolean): TEInvVehicle;
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

function TEInvVehicleRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TEInvVehicle;
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

procedure TEInvVehicleRepository.DoAdd(AModel: TEInvVehicle);
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

procedure TEInvVehicleRepository.DoAddBatch(AModels: TArray<TEInvVehicle>);
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

procedure TEInvVehicleRepository.DoUpdate(AModel: TEInvVehicle);
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

procedure TEInvVehicleRepository.DoUpdateBatch(AModels: TArray<TEInvVehicle>);
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

procedure TEInvVehicleRepository.DoDelete(AID: TValue);
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

procedure TEInvVehicleRepository.DoDelete(AModel: TEInvVehicle);
begin
  Delete(AModel.Id);
end;

procedure TEInvVehicleRepository.DoDeleteBatch(AModels: TArray<TEInvVehicle>);
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

procedure TEInvVehicleRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TEInvVehicleRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
