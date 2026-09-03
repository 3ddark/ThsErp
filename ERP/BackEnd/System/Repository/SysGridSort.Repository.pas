unit SysGridSort.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, Service,
  FilterCriterion, UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysGridSort;

type
  TSysGridSortRepository = class(TRepository<TSysGridSort>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysGridSort; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysGridSort; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysGridSort; override;


    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TSysGridSort>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSysGridSort; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysGridSort; override;

    procedure DoAdd(AModel: TSysGridSort); override;
    procedure DoAddBatch(AModels: TArray<TSysGridSort>); override;

    procedure DoUpdate(AModel: TSysGridSort); override;
    procedure DoUpdateBatch(AModels: TArray<TSysGridSort>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSysGridSort); override;
    procedure DoDeleteBatch(AModels: TArray<TSysGridSort>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSysGridSortRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysGridSortRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysGridSort) +
            ' (table_name, sort_content) ' +
            ' VALUES (:table_name, :sort_content)';
end;

function TSysGridSortRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysGridSort) +
            ' SET table_name = :table_name, sort_content = :sort_content ' +
            ' WHERE id = :id';
end;

function TSysGridSortRepository.PrepareDeleteSql: string;
begin
  //WHERE kýsmý özellikle böyle yazýldý. Filtre vermeden iþlem yapýlmamasý için. Hatalý kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysGridSort) + ' WHERE';
end;

procedure TSysGridSortRepository.SetInsertParams(Q: TFDQuery; AModel: TSysGridSort; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('table_name').AsString := AModel.TableName;
    Q.ParamByName('sort_content').AsString := AModel.SortContent;
  end
  else
  begin
    Q.ParamByName('table_name').AsStrings[AIndex] := AModel.TableName;
    Q.ParamByName('sort_content').AsStrings[AIndex] := AModel.SortContent;
  end;
end;

procedure TSysGridSortRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysGridSort; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('table_name').AsString := AModel.TableName;
    Q.ParamByName('sort_content').AsString := AModel.SortContent;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('table_name').AsStrings[AIndex] := AModel.TableName;
    Q.ParamByName('sort_content').AsStrings[AIndex] := AModel.SortContent;
  end;
end;

function TSysGridSortRepository.MapFromQuery(Q: TFDQuery): TSysGridSort;
begin
  Result := TSysGridSort.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.TableName := Q.FieldByName('table_name').AsString;
  Result.SortContent := Q.FieldByName('sort_content').AsString;
end;

function TSysGridSortRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + Self.GetFullViewName(TSysGridSort) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSysGridSortRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysGridSort>;
var
  Q: TFDQuery;
  Item: TSysGridSort;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysGridSort>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, False);

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    end;

    Q.Open;
    while not Q.Eof do
    begin
      Item := MapFromQuery(Q);
      Result.Add(Item);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TSysGridSortRepository.DoFindById(AId: TValue; ALock: Boolean): TSysGridSort;
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
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TSysGridSortRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysGridSort;
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
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TSysGridSortRepository.DoAdd(AModel: TSysGridSort);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql + ' RETURNING id';
    SetInsertParams(Q, AModel);
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;
end;

procedure TSysGridSortRepository.DoAddBatch(AModels: TArray<TSysGridSort>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      SetInsertParams(Q, AModels[I], I);

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysGridSortRepository.DoUpdate(AModel: TSysGridSort);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    SetUpdateParams(Q, AModel);
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSysGridSortRepository.DoUpdateBatch(AModels: TArray<TSysGridSort>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      SetUpdateParams(Q, AModels[I], I);

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysGridSortRepository.DoDelete(AID: TValue);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.ParamByName('id').AsLargeInt := AID.AsInt64;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSysGridSortRepository.DoDelete(AModel: TSysGridSort);
begin
  Delete(AModel.Id);
end;

procedure TSysGridSortRepository.DoDeleteBatch(AModels: TArray<TSysGridSort>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AModels[I].Id;

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysGridSortRepository.DoDeleteBatch(AIDs: TArray<TValue>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AIDs);
  if Count = 0 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AIDs[I].AsInt64;

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysGridSortRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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

    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

end.
