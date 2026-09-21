unit SysGridFilter.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, Service,
  FilterCriterion, UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysGridFilter;

type
  ISysGridFilterRepository = interface(IRepository<TSysGridFilter>)
    ['{74F9B4D5-8A1C-4B6D-9F0A-0C3B7E6F9D1E}']
    function HasFilter(const ATableName: string): Boolean;
    function LoadFilter(const ATableName: string): TSysGridFilter;
    procedure SaveFilter(const ATableName: string; const AFilterContent: string);
  end;

  TSysGridFilterRepository = class(TRepository<TSysGridFilter>, ISysGridFilterRepository)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysGridFilter; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysGridFilter; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysGridFilter; override;


    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSysGridFilter>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSysGridFilter; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysGridFilter; override;

    procedure DoAdd(AModel: TSysGridFilter); override;
    procedure DoAddBatch(AModels: TArray<TSysGridFilter>); override;

    procedure DoUpdate(AModel: TSysGridFilter); override;
    procedure DoUpdateBatch(AModels: TArray<TSysGridFilter>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSysGridFilter); override;
    procedure DoDeleteBatch(AModels: TArray<TSysGridFilter>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function HasFilter(const ATableName: string): Boolean;
    function LoadFilter(const ATableName: string): TSysGridFilter;
    procedure SaveFilter(const ATableName: string; const AFilterContent: string);
  end;

implementation

constructor TSysGridFilterRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysGridFilterRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysGridFilter) +
            ' (table_name, filter_content) ' +
            ' VALUES (:table_name, :filter_content)';
end;

function TSysGridFilterRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysGridFilter) +
            ' SET table_name = :table_name, filter_content = :filter_content ' +
            ' WHERE id = :id';
end;

function TSysGridFilterRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysGridFilter) + ' WHERE';
end;

procedure TSysGridFilterRepository.SetInsertParams(Q: TFDQuery; AModel: TSysGridFilter; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('table_name').AsString := AModel.TableName;
    Q.ParamByName('filter_content').AsString := AModel.FilterContent;
  end
  else
  begin
    Q.ParamByName('table_name').AsStrings[AIndex] := AModel.TableName;
    Q.ParamByName('filter_content').AsStrings[AIndex] := AModel.FilterContent;
  end;
end;

procedure TSysGridFilterRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysGridFilter; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('table_name').AsString := AModel.TableName;
    Q.ParamByName('filter_content').AsString := AModel.FilterContent;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('table_name').AsStrings[AIndex] := AModel.TableName;
    Q.ParamByName('filter_content').AsStrings[AIndex] := AModel.FilterContent;
  end;
end;

function TSysGridFilterRepository.MapFromQuery(Q: TFDQuery): TSysGridFilter;
begin
  Result := TSysGridFilter.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.TableName := Q.FieldByName('table_name').AsString;
  Result.FilterContent := Q.FieldByName('filter_content').AsString;
end;

function TSysGridFilterRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TSysGridFilter) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSysGridFilterRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSysGridFilter>;
var
  Q: TFDQuery;
  Item: TSysGridFilter;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysGridFilter>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, False);

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    end;

    LogQuery(Q, 'DoFind');
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

function TSysGridFilterRepository.DoFindById(AId: TValue; ALock: Boolean): TSysGridFilter;
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

function TSysGridFilterRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysGridFilter;
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

procedure TSysGridFilterRepository.DoAdd(AModel: TSysGridFilter);
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

procedure TSysGridFilterRepository.DoAddBatch(AModels: TArray<TSysGridFilter>);
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

    LogQuery(Q, 'DoAddBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysGridFilterRepository.DoUpdate(AModel: TSysGridFilter);
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

procedure TSysGridFilterRepository.DoUpdateBatch(AModels: TArray<TSysGridFilter>);
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

    LogQuery(Q, 'DoUpdateBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysGridFilterRepository.DoDelete(AID: TValue);
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

procedure TSysGridFilterRepository.DoDelete(AModel: TSysGridFilter);
begin
  Delete(AModel.Id);
end;

procedure TSysGridFilterRepository.DoDeleteBatch(AModels: TArray<TSysGridFilter>);
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

    LogQuery(Q, 'DoDeleteBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysGridFilterRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

    LogQuery(Q, 'DoDeleteBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysGridFilterRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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

function TSysGridFilterRepository.HasFilter(const ATableName: string): Boolean;
var
  LCriteria: TFilterCriteria;
  LModel: TSysGridFilter;
begin
  LCriteria := TFilterCriteria.Create;
  try
    LCriteria.Add(TFilterCriterion.New('table_name', '=', TValue.From<string>(ATableName)));
    LModel := DoFindOne(LCriteria, False);
    try
      Result := Assigned(LModel);
    finally
      LModel.Free;
    end;
  finally
    LCriteria.Free;
  end;
end;

function TSysGridFilterRepository.LoadFilter(const ATableName: string): TSysGridFilter;
var
  LCriteria: TFilterCriteria;
begin
  LCriteria := TFilterCriteria.Create;
  try
    LCriteria.Add(TFilterCriterion.New('table_name', '=', TValue.From<string>(ATableName)));
    Result := DoFindOne(LCriteria, False);
  finally
    LCriteria.Free;
  end;
end;

procedure TSysGridFilterRepository.SaveFilter(const ATableName: string; const AFilterContent: string);
var
  LFilter: TSysGridFilter;
begin
  LFilter := LoadFilter(ATableName);
  if Assigned(LFilter) then
  begin
    try
      LFilter.FilterContent := AFilterContent;
      DoUpdate(LFilter);
    finally
      LFilter.Free;
    end;
  end
  else
  begin
    LFilter := TSysGridFilter.Create;
    try
      LFilter.TableName := ATableName;
      LFilter.FilterContent := AFilterContent;
      DoAdd(LFilter);
    finally
      LFilter.Free;
    end;
  end;
end;

end.
