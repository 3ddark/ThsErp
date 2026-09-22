unit SysGridColumn.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, Service,
  FilterCriterion, UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysGridColumn, SysGridColumn.Cache;

type
  ISysGridColumnRepository = interface(IRepository<TSysGridColumn>)
    ['{0DC72463-5EB7-4CE6-8F8C-D555F01338B9}']
    function HasTableColumns(const ATableName: string): Boolean;
    function LoadColumns(const ATableName: string): TObjectList<TSysGridColumn>;
    procedure SaveColumns(const ATableName: string; const AColumns: TObjectList<TSysGridColumn>);
    function LoadUserColumns(const ATableName: string; AUserId: Int64): TObjectList<TSysGridColumn>;
    procedure SaveUserColumns(const ATableName: string; AUserId: Int64; const AColumns: TObjectList<TSysGridColumn>);
  end;

  TSysGridColumnRepository = class(TRepository<TSysGridColumn>, ISysGridColumnRepository)
  private
    FTableExists       : Boolean;
    FTableExistsChecked: Boolean;
    function CheckTableExists: Boolean;
  protected
    function PrepareSelectSql  : string;
    function PrepareAddSql     : string;
    function PrepareUpdateSql  : string;
    function PrepareDeleteSql  : string;

    procedure SetModelParams(Q: TFDQuery; AModel: TSysGridColumn; AIndex: Integer = -1);
    function  MapFromQuery(Q: TFDQuery): TSysGridColumn; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSysGridColumn; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysGridColumn; override;
    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSysGridColumn>; override;

    procedure DoAdd(AModel: TSysGridColumn); override;
    procedure DoAddBatch(AModels: TArray<TSysGridColumn>); override;
    procedure DoUpdate(AModel: TSysGridColumn); override;
    procedure DoUpdateBatch(AModels: TArray<TSysGridColumn>); override;
    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSysGridColumn); override;
    procedure DoDeleteBatch(AModels: TArray<TSysGridColumn>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function  HasTableColumns(const ATableName: string): Boolean;
    procedure SaveColumns(const ATableName: string; const AColumns: TObjectList<TSysGridColumn>);
    function  LoadColumns(const ATableName: string): TObjectList<TSysGridColumn>;
    function  LoadUserColumns(const ATableName: string; AUserId: Int64): TObjectList<TSysGridColumn>;
    procedure SaveUserColumns(const ATableName: string; AUserId: Int64; const AColumns: TObjectList<TSysGridColumn>);
  end;

implementation

uses Logger;

constructor TSysGridColumnRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
  FTableExists        := False;
  FTableExistsChecked := False;
end;

function TSysGridColumnRepository.CheckTableExists: Boolean;
begin
  Result := TSysGridColumnCache.CheckTableExists(Connection);
end;

function TSysGridColumnRepository.PrepareSelectSql: string;
begin
  Result :=
    'SELECT id, table_name, column_name, column_order, column_width, ' +
    '       data_format, is_show, is_show_helper, is_fetch, ' +
    '       min_value, min_value_color, max_value, max_value_color, ' +
    '       max_value_percent, bar_color, bar_bg_color, bar_text_color, ' +
    '       aggregate_type ' +
    'FROM public.' + Self.GetTableName(TSysGridColumn);
end;

function TSysGridColumnRepository.PrepareAddSql: string;
begin
  Result :=
    'INSERT INTO public.' + Self.GetTableName(TSysGridColumn) +
    ' (table_name, column_name, column_order, column_width, data_format, ' +
    '  is_show, is_show_helper, is_fetch, min_value, min_value_color, max_value, ' +
    '  max_value_color, max_value_percent, bar_color, bar_bg_color, bar_text_color, aggregate_type) ' +
    'VALUES ' +
    ' (:table_name, :column_name, :column_order, :column_width, :data_format, ' +
    '  :is_show, :is_show_helper, :is_fetch, :min_value, :min_value_color, :max_value, ' +
    '  :max_value_color, :max_value_percent, :bar_color, :bar_bg_color, :bar_text_color, :aggregate_type)';
end;

function TSysGridColumnRepository.PrepareUpdateSql: string;
begin
  Result :=
    'UPDATE public.' + Self.GetTableName(TSysGridColumn) +
    ' SET table_name = :table_name, column_name = :column_name, ' +
    '     column_order = :column_order, column_width = :column_width, ' +
    '     data_format = :data_format, is_show = :is_show, ' +
    '     is_show_helper = :is_show_helper, is_fetch = :is_fetch, min_value = :min_value, ' +
    '     min_value_color = :min_value_color, max_value = :max_value, ' +
    '     max_value_color = :max_value_color, ' +
    '     max_value_percent = :max_value_percent, ' +
    '     bar_color = :bar_color, bar_bg_color = :bar_bg_color, ' +
    '     bar_text_color = :bar_text_color, ' +
    '     aggregate_type = :aggregate_type ' +
    'WHERE id = :id';
end;

function TSysGridColumnRepository.PrepareDeleteSql: string;
begin
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysGridColumn) +
            ' WHERE id = :id';
end;

function TSysGridColumnRepository.MapFromQuery(Q: TFDQuery): TSysGridColumn;
begin
  Result                  := TSysGridColumn.Create;
  Result.Id               := Q.FieldByName('id').AsLargeInt;
  Result.TableName        := Q.FieldByName('table_name').AsString;
  Result.ColumnName       := Q.FieldByName('column_name').AsString;
  Result.ColumnOrder      := Q.FieldByName('column_order').AsInteger;
  Result.ColumnWidth      := Q.FieldByName('column_width').AsInteger;
  Result.DataFormat       := Q.FieldByName('data_format').AsString;
  Result.IsShow           := Q.FieldByName('is_show').AsBoolean;
  Result.IsShowHelper     := Q.FieldByName('is_show_helper').AsBoolean;
  if Q.FindField('is_fetch') <> nil then
    Result.IsFetch        := Q.FieldByName('is_fetch').AsBoolean
  else
    Result.IsFetch        := True;
  Result.MinValue         := Q.FieldByName('min_value').AsFloat;
  Result.MinValueColor    := Q.FieldByName('min_value_color').AsInteger;
  Result.MaxValue         := Q.FieldByName('max_value').AsFloat;
  Result.MaxValueColor    := Q.FieldByName('max_value_color').AsInteger;
  Result.MaxValuePercent  := Q.FieldByName('max_value_percent').AsFloat;
  Result.BarColor         := Q.FieldByName('bar_color').AsInteger;
  Result.BarBgColor       := Q.FieldByName('bar_bg_color').AsInteger;
  Result.BarTextColor     := Q.FieldByName('bar_text_color').AsInteger;
  if Q.FindField('aggregate_type') <> nil then
    Result.AggregateType  := Q.FieldByName('aggregate_type').AsInteger
  else
    Result.AggregateType  := 0;
end;

procedure TSysGridColumnRepository.SetModelParams(Q: TFDQuery;
  AModel: TSysGridColumn; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('table_name').AsString      := AModel.TableName;
    Q.ParamByName('column_name').AsString     := AModel.ColumnName;
    Q.ParamByName('column_order').AsInteger   := AModel.ColumnOrder;
    Q.ParamByName('column_width').AsInteger   := AModel.ColumnWidth;
    Q.ParamByName('data_format').AsString     := AModel.DataFormat;
    Q.ParamByName('is_show').AsBoolean        := AModel.IsShow;
    Q.ParamByName('is_show_helper').AsBoolean := AModel.IsShowHelper;
    if Q.FindParam('is_fetch') <> nil then
      Q.ParamByName('is_fetch').AsBoolean     := AModel.IsFetch;
    Q.ParamByName('min_value').AsFloat        := AModel.MinValue;
    Q.ParamByName('min_value_color').AsInteger:= AModel.MinValueColor;
    Q.ParamByName('max_value').AsFloat        := AModel.MaxValue;
    Q.ParamByName('max_value_color').AsInteger:= AModel.MaxValueColor;
    Q.ParamByName('max_value_percent').AsFloat:= AModel.MaxValuePercent;
    Q.ParamByName('bar_color').AsInteger      := AModel.BarColor;
    Q.ParamByName('bar_bg_color').AsInteger   := AModel.BarBgColor;
    Q.ParamByName('bar_text_color').AsInteger := AModel.BarTextColor;
    if Q.FindParam('aggregate_type') <> nil then
      Q.ParamByName('aggregate_type').AsInteger := AModel.AggregateType;
    if (AModel.Id > 0) and (Q.FindParam('id') <> nil) then
      Q.ParamByName('id').AsLargeInt := AModel.Id;
  end
  else
  begin
    Q.ParamByName('table_name').AsStrings[AIndex]       := AModel.TableName;
    Q.ParamByName('column_name').AsStrings[AIndex]      := AModel.ColumnName;
    Q.ParamByName('column_order').AsIntegers[AIndex]    := AModel.ColumnOrder;
    Q.ParamByName('column_width').AsIntegers[AIndex]    := AModel.ColumnWidth;
    Q.ParamByName('data_format').AsStrings[AIndex]      := AModel.DataFormat;
    Q.ParamByName('is_show').AsBooleans[AIndex]         := AModel.IsShow;
    Q.ParamByName('is_show_helper').AsBooleans[AIndex]  := AModel.IsShowHelper;
    if Q.FindParam('is_fetch') <> nil then
      Q.ParamByName('is_fetch').AsBooleans[AIndex]      := AModel.IsFetch;
    Q.ParamByName('min_value').AsFloats[AIndex]         := AModel.MinValue;
    Q.ParamByName('min_value_color').AsIntegers[AIndex] := AModel.MinValueColor;
    Q.ParamByName('max_value').AsFloats[AIndex]         := AModel.MaxValue;
    Q.ParamByName('max_value_color').AsIntegers[AIndex] := AModel.MaxValueColor;
    Q.ParamByName('max_value_percent').AsFloats[AIndex] := AModel.MaxValuePercent;
    Q.ParamByName('bar_color').AsIntegers[AIndex]       := AModel.BarColor;
    Q.ParamByName('bar_bg_color').AsIntegers[AIndex]    := AModel.BarBgColor;
    Q.ParamByName('bar_text_color').AsIntegers[AIndex]  := AModel.BarTextColor;
    if Q.FindParam('aggregate_type') <> nil then
      Q.ParamByName('aggregate_type').AsIntegers[AIndex]:= AModel.AggregateType;
    if (AModel.Id > 0) and (Q.FindParam('id') <> nil) then
      Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
  end;
end;

function TSysGridColumnRepository.DoFindAllGridQuery(
  AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result            := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text   :=
    'SELECT ' + SelectCols + ' FROM public.' + Self.GetTableName(TSysGridColumn) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
  LogQuery(Result, 'DoFindAllGridQuery');
end;

function TSysGridColumnRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSysGridColumn>;
var
  Q        : TFDQuery;
  Criterion: TFilterCriterion;
begin
  Result := TObjectList<TSysGridColumn>.Create(True);
  Q      := TFDQuery.Create(nil);
  try
    Q.Connection  := Connection;
    Q.SQL.Text    := PrepareSelectSql + ' WHERE 1=1';

    if Assigned(AFilter) and (AFilter.Count > 0) then
      for Criterion in AFilter do
        Q.SQL.Text := Q.SQL.Text + ' AND ' +
          Criterion.FieldName + ' ' + Criterion.Operator +
          ' :' + Criterion.ParamName; // FIX: ParamName, FieldName değil

    if ALock and (Connection <> nil) and Connection.InTransaction then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE';

    if Assigned(AFilter) and (AFilter.Count > 0) then
      for Criterion in AFilter do
        Q.ParamByName(Criterion.ParamName).Value := // FIX: ParamName
          Criterion.Value.AsVariant;

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

function TSysGridColumnRepository.DoFindById(AId: TValue;
  ALock: Boolean): TSysGridColumn;
var
  Q: TFDQuery;
begin
  Result := nil;
  Q      := TFDQuery.Create(nil);
  try
    Q.Connection  := Connection;
    Q.SQL.Text    := PrepareSelectSql + ' WHERE id = :id';
    if ALock and (Connection <> nil) and Connection.InTransaction then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE';
    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    LogQuery(Q, 'DoFindById');
    Q.Open;
    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

function TSysGridColumnRepository.DoFindOne(AFilter: TFilterCriteria;
  ALock: Boolean): TSysGridColumn;
var
  Q        : TFDQuery;
  Criterion: TFilterCriterion;
begin
  Result := nil;
  if not Assigned(AFilter) or (AFilter.Count = 0) then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text   := PrepareSelectSql + ' WHERE 1=1';

    for Criterion in AFilter do
      Q.SQL.Text := Q.SQL.Text + ' AND ' +
        Criterion.FieldName + ' ' + Criterion.Operator +
        ' :' + Criterion.ParamName; // FIX: ParamName

    if ALock and (Connection <> nil) and Connection.InTransaction then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE';
    Q.SQL.Text := Q.SQL.Text + ' LIMIT 1';

    for Criterion in AFilter do
      Q.ParamByName(Criterion.ParamName).Value := // FIX: ParamName
        Criterion.Value.AsVariant;

    LogQuery(Q, 'DoFindOne');
    Q.Open;
    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TSysGridColumnRepository.DoAdd(AModel: TSysGridColumn);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection  := Connection;
    Q.SQL.Text    := PrepareAddSql + ' RETURNING id';
    SetModelParams(Q, AModel);
    LogQuery(Q, 'DoAdd');
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
    TSysGridColumnCache.InvalidateTable(AModel.TableName);
  finally
    Q.Free;
  end;
end;

procedure TSysGridColumnRepository.DoAddBatch(
  AModels: TArray<TSysGridColumn>);
var
  Q    : TFDQuery;
  I, N : Integer;
begin
  N := Length(AModels);
  if N = 0 then Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection       := Connection;
    Q.SQL.Text         := PrepareAddSql;
    Q.Params.ArraySize := N;
    for I := 0 to N - 1 do
      SetModelParams(Q, AModels[I], I);
    LogQuery(Q, 'DoAddBatch');
    Q.Execute(N, 0);
    TSysGridColumnCache.InvalidateAll;
  finally
    Q.Free;
  end;
end;

procedure TSysGridColumnRepository.DoUpdate(AModel: TSysGridColumn);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text   := PrepareUpdateSql;
    SetModelParams(Q, AModel);
    LogQuery(Q, 'DoUpdate');
    Q.ExecSQL;
    TSysGridColumnCache.InvalidateTable(AModel.TableName);
  finally
    Q.Free;
  end;
end;

procedure TSysGridColumnRepository.DoUpdateBatch(
  AModels: TArray<TSysGridColumn>);
var
  Q    : TFDQuery;
  I, N : Integer;
begin
  N := Length(AModels);
  if N = 0 then Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection       := Connection;
    Q.SQL.Text         := PrepareUpdateSql;
    Q.Params.ArraySize := N;
    for I := 0 to N - 1 do
      SetModelParams(Q, AModels[I], I);
    LogQuery(Q, 'DoUpdateBatch');
    Q.Execute(N, 0);
    TSysGridColumnCache.InvalidateAll;
  finally
    Q.Free;
  end;
end;

procedure TSysGridColumnRepository.DoDelete(AID: TValue);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text   := PrepareDeleteSql;
    Q.ParamByName('id').AsLargeInt := AID.AsInt64;
    LogQuery(Q, 'DoDelete');
    Q.ExecSQL;
    TSysGridColumnCache.InvalidateAll;
  finally
    Q.Free;
  end;
end;

procedure TSysGridColumnRepository.DoDelete(AModel: TSysGridColumn);
begin
  Delete(TValue.From<Int64>(AModel.Id));
end;

procedure TSysGridColumnRepository.DoDeleteBatch(
  AModels: TArray<TSysGridColumn>);
var
  Q    : TFDQuery;
  I, N : Integer;
begin
  N := Length(AModels);
  if N = 0 then Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection       := Connection;
    Q.SQL.Text         := PrepareDeleteSql;
    Q.Params.ArraySize := N;
    for I := 0 to N - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AModels[I].Id;
    LogQuery(Q, 'DoDeleteBatch');
    Q.Execute(N, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysGridColumnRepository.DoDeleteBatch(AIDs: TArray<TValue>);
var
  Q    : TFDQuery;
  I, N : Integer;
begin
  N := Length(AIDs);
  if N = 0 then Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection       := Connection;
    Q.SQL.Text         := PrepareDeleteSql;
    Q.Params.ArraySize := N;
    for I := 0 to N - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AIDs[I].AsInt64;
    LogQuery(Q, 'DoDeleteBatch');
    Q.Execute(N, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysGridColumnRepository.DoDeleteBatch(AFilter: TFilterCriteria);
var
  Q       : TFDQuery;
  Criteria: TFilterCriterion;
begin
  if not Assigned(AFilter) or (AFilter.Count = 0) then Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text   :=
      'DELETE FROM public.' + Self.GetTableName(TSysGridColumn) +
      ' WHERE 1=1';
    for Criteria in AFilter do
      Q.SQL.Text := Q.SQL.Text + ' AND ' +
        Criteria.FieldName + ' ' + Criteria.Operator +
        ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    LogQuery(Q, 'DoDeleteBatch');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TSysGridColumnRepository.LoadColumns(const ATableName: string): TObjectList<TSysGridColumn>;
begin
  Result := TSysGridColumnCache.LoadColumns(Connection, ATableName);
end;

function TSysGridColumnRepository.HasTableColumns(const ATableName: string): Boolean;
begin
  Result := TSysGridColumnCache.HasTableColumns(Connection, ATableName);
end;

procedure TSysGridColumnRepository.SaveColumns(const ATableName: string; const AColumns: TObjectList<TSysGridColumn>);
type
  TColType = record
    Order: Integer;
    Width: Integer;
    Show: Boolean
  end;

var
  Q       : TFDQuery;
  I       : Integer;
  SQLText : string;
  CleanTbl: string;

  LExisting: TDictionary<string, TColType>;
  LKey    : string;
  LRec    : TColType;
  LChanged: Boolean;
begin
  if AColumns.Count = 0 then Exit;

  if not CheckTableExists then Exit;

  CleanTbl := ATableName;
  if CleanTbl.StartsWith('public.', True) then
    CleanTbl := CleanTbl.Substring(7);

  LExisting := TDictionary<string, TColType>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text   :=
      'SELECT column_name, column_order, column_width, is_show ' +
      'FROM public.sys_grid_column WHERE table_name = :t';
    Q.ParamByName('t').AsString := CleanTbl;
    try
      LogQuery(Q, 'SaveColumns');
      Q.Open;
    except
      on E: Exception do
      begin
        GLogger.ErrorFmt('SaveColumns read error [%s]: %s',
          [CleanTbl, E.Message]);
        Exit;
      end;
    end;

    while not Q.Eof do
    begin
      LRec.Order := Q.FieldByName('column_order').AsInteger;
      LRec.Width := Q.FieldByName('column_width').AsInteger;
      LRec.Show  := Q.FieldByName('is_show').AsBoolean;
      LExisting.AddOrSetValue(LowerCase(Q.FieldByName('column_name').AsString), LRec);
      Q.Next;
    end;
    Q.Close;

    LChanged := LExisting.Count <> AColumns.Count;
    if not LChanged then
      for I := 0 to AColumns.Count - 1 do
      begin
        LKey := LowerCase(AColumns[I].ColumnName);
        if not LExisting.TryGetValue(LKey, LRec) or
           (LRec.Order <> AColumns[I].ColumnOrder) or
           (LRec.Width <> AColumns[I].ColumnWidth) or
           (LRec.Show  <> AColumns[I].IsShow)
        then
        begin
          LChanged := True;
          Break;
        end;
      end;

    if not LChanged then Exit;

    SQLText :=
      'INSERT INTO public.sys_grid_column ' +
      '(table_name, column_name, column_order, column_width, is_show, is_fetch) VALUES ';

    for I := 0 to AColumns.Count - 1 do
    begin
      if I > 0 then
        SQLText := SQLText + ', ';
      SQLText := SQLText + Format('(:t, :cn%d, :co%d, :cw%d, :cs%d, :cf%d)', [I, I, I, I, I]);
    end;

    SQLText := SQLText +
      ' ON CONFLICT (table_name, column_name) DO UPDATE SET ' +
      '  column_order = EXCLUDED.column_order, ' +
      '  column_width = EXCLUDED.column_width, ' +
      '  is_show      = EXCLUDED.is_show';

    Q.SQL.Text := SQLText;
    Q.ParamByName('t').AsString := CleanTbl;
    for I := 0 to AColumns.Count - 1 do
    begin
      Q.ParamByName('cn' + I.ToString).AsString  := AColumns[I].ColumnName;
      Q.ParamByName('co' + I.ToString).AsInteger := AColumns[I].ColumnOrder;
      Q.ParamByName('cw' + I.ToString).AsInteger := AColumns[I].ColumnWidth;
      Q.ParamByName('cs' + I.ToString).AsBoolean := AColumns[I].IsShow;
      Q.ParamByName('cf' + I.ToString).AsBoolean := AColumns[I].IsFetch;
    end;

    try
      LogQuery(Q, 'SaveColumns');
      Q.ExecSQL;
      TSysGridColumnCache.UpdateGlobal(CleanTbl, AColumns);
    except
      on E: Exception do
        GLogger.ErrorFmt('SaveColumns save error [%s]: %s',
          [CleanTbl, E.Message]);
    end;

  finally
    Q.Free;
    LExisting.Free;
  end;
end;

function TSysGridColumnRepository.LoadUserColumns(const ATableName: string; AUserId: Int64): TObjectList<TSysGridColumn>;
begin
  Result := TSysGridColumnCache.LoadUserColumns(Connection, ATableName, AUserId);
end;

procedure TSysGridColumnRepository.SaveUserColumns(const ATableName: string; AUserId: Int64; const AColumns: TObjectList<TSysGridColumn>);
var
  Q: TFDQuery;
  i: Integer;
  SQLText: string;
  CleanTbl: string;
begin
  if (AColumns = nil) or (AColumns.Count = 0) or (AUserId <= 0) then Exit;

  CleanTbl := ATableName;
  if CleanTbl.StartsWith('public.', True) then
    CleanTbl := CleanTbl.Substring(7);

  // Değişiklik yoksa gereksiz DB sorgusu çalıştırma
  if not TSysGridColumnCache.IsUserColumnsChanged(CleanTbl, AUserId, AColumns) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    SQLText :=
      'INSERT INTO public.sys_user_grid_column ' +
      '(user_id, table_name, column_name, column_order, column_width, is_show) VALUES ';

    for i := 0 to AColumns.Count - 1 do
    begin
      if i > 0 then SQLText := SQLText + ', ';
      SQLText := SQLText + Format('(:u, :t, :cn%d, :co%d, :cw%d, :cs%d)', [i, i, i, i]);
    end;

    SQLText := SQLText +
      ' ON CONFLICT (user_id, table_name, column_name) DO UPDATE SET ' +
      '  column_order = EXCLUDED.column_order, ' +
      '  column_width = EXCLUDED.column_width, ' +
      '  is_show      = EXCLUDED.is_show';

    Q.SQL.Text := SQLText;
    Q.ParamByName('u').AsLargeInt := AUserId;
    Q.ParamByName('t').AsString := CleanTbl;
    for i := 0 to AColumns.Count - 1 do
    begin
      Q.ParamByName('cn' + i.ToString).AsString  := AColumns[i].ColumnName;
      Q.ParamByName('co' + i.ToString).AsInteger := AColumns[i].ColumnOrder;
      Q.ParamByName('cw' + i.ToString).AsInteger := AColumns[i].ColumnWidth;
      Q.ParamByName('cs' + i.ToString).AsBoolean := AColumns[i].IsShow;
    end;

    try
      LogQuery(Q, 'SaveUserColumns');
      Q.ExecSQL;
      TSysGridColumnCache.UpdateUser(CleanTbl, AUserId, AColumns);
    except
      on E: Exception do
        GLogger.ErrorFmt('SaveUserColumns save error [%s, User %d]: %s', [CleanTbl, AUserId, E.Message]);
    end;
  finally
    Q.Free;
  end;
end;

end.
