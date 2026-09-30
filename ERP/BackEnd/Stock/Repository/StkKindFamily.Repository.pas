unit StkKindFamily.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, StkKindFamily;

type
  TStkKindFamilyRepository = class(TRepository<TStkKindFamily>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TStkKindFamily; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TStkKindFamily; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TStkKindFamily; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TStkKindFamily>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TStkKindFamily; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TStkKindFamily; override;

    procedure DoAdd(AModel: TStkKindFamily); override;
    procedure DoAddBatch(AModels: TArray<TStkKindFamily>); override;

    procedure DoUpdate(AModel: TStkKindFamily); override;
    procedure DoUpdateBatch(AModels: TArray<TStkKindFamily>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TStkKindFamily); override;
    procedure DoDeleteBatch(AModels: TArray<TStkKindFamily>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TStkKindFamilyRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TStkKindFamilyRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TStkKindFamily) +
            ' (family, description, active) ' +
            ' VALUES (:family, :description, :active)';
end;

function TStkKindFamilyRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TStkKindFamily) +
            ' SET family = :family, description = :description, active = :active ' +
            ' WHERE id = :id';
end;

function TStkKindFamilyRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TStkKindFamily) + ' WHERE';
end;

procedure TStkKindFamilyRepository.SetInsertParams(Q: TFDQuery; AModel: TStkKindFamily; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('family').AsString := AModel.Family;
    Q.ParamByName('description').AsString := AModel.Description;
    Q.ParamByName('active').AsBoolean := AModel.Active;
  end
  else
  begin
    Q.ParamByName('family').AsStrings[AIndex] := AModel.Family;
    Q.ParamByName('description').AsStrings[AIndex] := AModel.Description;
    Q.ParamByName('active').AsBooleans[AIndex] := AModel.Active;
  end;
end;

procedure TStkKindFamilyRepository.SetUpdateParams(Q: TFDQuery; AModel: TStkKindFamily; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('family').AsString := AModel.Family;
    Q.ParamByName('description').AsString := AModel.Description;
    Q.ParamByName('active').AsBoolean := AModel.Active;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('family').AsStrings[AIndex] := AModel.Family;
    Q.ParamByName('description').AsStrings[AIndex] := AModel.Description;
    Q.ParamByName('active').AsBooleans[AIndex] := AModel.Active;
  end;
end;

function TStkKindFamilyRepository.MapFromQuery(Q: TFDQuery): TStkKindFamily;
begin
  Result := TStkKindFamily.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.Family := Q.FieldByName('family').AsString;
  Result.Description := Q.FieldByName('description').AsString;
  Result.Active := Q.FieldByName('active').AsBoolean;
end;

function TStkKindFamilyRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TStkKindFamily) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TStkKindFamilyRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TStkKindFamily>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TStkKindFamily>.Create(True);
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

function TStkKindFamilyRepository.DoFindById(AId: TValue; ALock: Boolean): TStkKindFamily;
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

function TStkKindFamilyRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TStkKindFamily;
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

procedure TStkKindFamilyRepository.DoAdd(AModel: TStkKindFamily);
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

procedure TStkKindFamilyRepository.DoAddBatch(AModels: TArray<TStkKindFamily>);
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

procedure TStkKindFamilyRepository.DoUpdate(AModel: TStkKindFamily);
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

procedure TStkKindFamilyRepository.DoUpdateBatch(AModels: TArray<TStkKindFamily>);
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

procedure TStkKindFamilyRepository.DoDelete(AID: TValue);
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

procedure TStkKindFamilyRepository.DoDelete(AModel: TStkKindFamily);
begin
  Delete(AModel.Id);
end;

procedure TStkKindFamilyRepository.DoDeleteBatch(AModels: TArray<TStkKindFamily>);
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

procedure TStkKindFamilyRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TStkKindFamilyRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
