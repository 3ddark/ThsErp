unit SysGridColumn.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections, System.Rtti,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  Entity, Repository, FilterCriterion, AppContext, SysGridColumn;

type
  TSysGridColumnRepository = class(TRepository<TSysGridColumn>)
  protected
    function PrepareSelectSql: string; virtual;
    function PrepareAddSql: string; virtual;
    function PrepareUpdateSql: string; virtual;
    function PrepareDeleteSql: string; virtual;

    procedure SetModelParams(Q: TFDQuery; AModel: TSysGridColumn; AIndex: Integer = -1);
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function FindById(AId: TValue; ALock: Boolean = False): TSysGridColumn; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysGridColumn; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TSysGridColumn>; override;

    procedure Add(AModel: TSysGridColumn); override;
    procedure AddBatch(AModels: TArray<TSysGridColumn>); override;

    procedure Update(AModel: TSysGridColumn); override;
    procedure UpdateBatch(AModels: TArray<TSysGridColumn>); override;

    procedure Delete(AID: Int64); override;
    procedure DeleteBatch(AModels: TArray<TSysGridColumn>); override;

    procedure SaveColumns(const ATableName: string; const AColumns: TList<TSysGridColumn>);
    function LoadColumns(const ATableName: string): TList<TSysGridColumn>;
  end;

implementation

constructor TSysGridColumnRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysGridColumnRepository.PrepareSelectSql: string;
begin
  Result := 'SELECT id, table_name, column_name, column_order, column_width, data_format, is_show, is_show_helper, ' +
            '       min_value, min_value_color, max_value, max_value_color, max_value_percent, bar_color, bar_bg_color, bar_text_color ' +
            ' FROM public.' + Self.GetTableName(TSysGridColumn);
end;

function TSysGridColumnRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysGridColumn) +
            ' (table_name, column_name, column_order, column_width, data_format, is_show, is_show_helper, ' +
            '  min_value, min_value_color, max_value, max_value_color, max_value_percent, bar_color, bar_bg_color, bar_text_color) ' +
            ' VALUES (:table_name, :column_name, :column_order, :column_width, :data_format, :is_show, :is_show_helper, ' +
            '  :min_value, :min_value_color, :max_value, :max_value_color, :max_value_percent, :bar_color, :bar_bg_color, :bar_text_color)';
end;

function TSysGridColumnRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysGridColumn) +
            ' SET table_name = :table_name, column_name = :column_name, column_order = :column_order, ' +
            '     column_width = :column_width, data_format = :data_format, is_show = :is_show, ' +
            '     is_show_helper = :is_show_helper, min_value = :min_value, min_value_color = :min_value_color, ' +
            '     max_value = :max_value, max_value_color = :max_value_color, max_value_percent = :max_value_percent, ' +
            '     bar_color = :bar_color, bar_bg_color = :bar_bg_color, bar_text_color = :bar_text_color ' +
            ' WHERE id = :id';
end;

function TSysGridColumnRepository.PrepareDeleteSql: string;
begin
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysGridColumn) + ' WHERE id = :id';
end;

procedure TSysGridColumnRepository.SetModelParams(Q: TFDQuery; AModel: TSysGridColumn; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('table_name').AsString := AModel.TableName;
    Q.ParamByName('column_name').AsString := AModel.ColumnName;
    Q.ParamByName('column_order').AsInteger := AModel.ColumnOrder;
    Q.ParamByName('column_width').AsInteger := AModel.ColumnWidth;
    Q.ParamByName('data_format').AsString := AModel.DataFormat;
    Q.ParamByName('is_show').AsBoolean := AModel.IsShow;
    Q.ParamByName('is_show_helper').AsBoolean := AModel.IsShowHelper;
    Q.ParamByName('min_value').AsFloat := AModel.MinValue;
    Q.ParamByName('min_value_color').AsInteger := AModel.MinValueColor;
    Q.ParamByName('max_value').AsFloat := AModel.MaxValue;
    Q.ParamByName('max_value_color').AsInteger := AModel.MaxValueColor;
    Q.ParamByName('max_value_percent').AsFloat := AModel.MaxValuePercent;
    Q.ParamByName('bar_color').AsInteger := AModel.BarColor;
    Q.ParamByName('bar_bg_color').AsInteger := AModel.BarBgColor;
    Q.ParamByName('bar_text_color').AsInteger := AModel.BarTextColor;
    if (AModel.Id > 0) and (Q.FindParam('id') <> nil) then
      Q.ParamByName('id').AsLargeInt := AModel.Id;
  end
  else
  begin
    Q.ParamByName('table_name').AsStrings[AIndex] := AModel.TableName;
    Q.ParamByName('column_name').AsStrings[AIndex] := AModel.ColumnName;
    Q.ParamByName('column_order').AsIntegers[AIndex] := AModel.ColumnOrder;
    Q.ParamByName('column_width').AsIntegers[AIndex] := AModel.ColumnWidth;
    Q.ParamByName('data_format').AsStrings[AIndex] := AModel.DataFormat;
    Q.ParamByName('is_show').AsBooleans[AIndex] := AModel.IsShow;
    Q.ParamByName('is_show_helper').AsBooleans[AIndex] := AModel.IsShowHelper;
    Q.ParamByName('min_value').AsFloats[AIndex] := AModel.MinValue;
    Q.ParamByName('min_value_color').AsIntegers[AIndex] := AModel.MinValueColor;
    Q.ParamByName('max_value').AsFloats[AIndex] := AModel.MaxValue;
    Q.ParamByName('max_value_color').AsIntegers[AIndex] := AModel.MaxValueColor;
    Q.ParamByName('max_value_percent').AsFloats[AIndex] := AModel.MaxValuePercent;
    Q.ParamByName('bar_color').AsIntegers[AIndex] := AModel.BarColor;
    Q.ParamByName('bar_bg_color').AsIntegers[AIndex] := AModel.BarBgColor;
    Q.ParamByName('bar_text_color').AsIntegers[AIndex] := AModel.BarTextColor;
    if (AModel.Id > 0) and (Q.FindParam('id') <> nil) then
      Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
  end;
end;

function TSysGridColumnRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM public.' + Self.GetTableName(TSysGridColumn);
end;

procedure TSysGridColumnRepository.Add(AModel: TSysGridColumn);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql + ' RETURNING id';
    SetModelParams(Q, AModel);
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;
end;

procedure TSysGridColumnRepository.AddBatch(AModels: TArray<TSysGridColumn>);
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
      SetModelParams(Q, AModels[I], I);

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysGridColumnRepository.Update(AModel: TSysGridColumn);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    SetModelParams(Q, AModel);
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSysGridColumnRepository.UpdateBatch(AModels: TArray<TSysGridColumn>);
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
      SetModelParams(Q, AModels[I], I);

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysGridColumnRepository.Delete(AID: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql;
    Q.ParamByName('id').AsLargeInt := AID;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSysGridColumnRepository.DeleteBatch(AModels: TArray<TSysGridColumn>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AModels[I].Id;

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

function TSysGridColumnRepository.FindById(AId: TValue; ALock: Boolean): TSysGridColumn;
var
  Q: TFDQuery;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSelectSql + ' WHERE id = :id';
    if ALock then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE';

    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    Q.Open;

    if not Q.IsEmpty then
    begin
      Result := TSysGridColumn.Create;
      Result.Id := Q.FieldByName('id').AsLargeInt;
      Result.TableName := Q.FieldByName('table_name').AsString;
      Result.ColumnName := Q.FieldByName('column_name').AsString;
      Result.ColumnOrder := Q.FieldByName('column_order').AsInteger;
      Result.ColumnWidth := Q.FieldByName('column_width').AsInteger;
      Result.DataFormat := Q.FieldByName('data_format').AsString;
      Result.IsShow := Q.FieldByName('is_show').AsBoolean;
      Result.IsShowHelper := Q.FieldByName('is_show_helper').AsBoolean;
      Result.MinValue := Q.FieldByName('min_value').AsFloat;
      Result.MinValueColor := Q.FieldByName('min_value_color').AsInteger;
      Result.MaxValue := Q.FieldByName('max_value').AsFloat;
      Result.MaxValueColor := Q.FieldByName('max_value_color').AsInteger;
      Result.MaxValuePercent := Q.FieldByName('max_value_percent').AsFloat;
      Result.BarColor := Q.FieldByName('bar_color').AsInteger;
      Result.BarBgColor := Q.FieldByName('bar_bg_color').AsInteger;
      Result.BarTextColor := Q.FieldByName('bar_text_color').AsInteger;
    end;
  finally
    Q.Free;
  end;
end;

function TSysGridColumnRepository.FindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysGridColumn;
var
  Q: TFDQuery;
  Criterion: TFilterCriterion;
begin
  Result := nil;
  if not Assigned(AFilter) or (AFilter.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSelectSql + ' WHERE 1=1';

    for Criterion in AFilter do
      Q.SQL.Text := Q.SQL.Text + ' AND ' + Criterion.FieldName + ' ' + Criterion.Operator + ' :' + Criterion.FieldName;

    if ALock then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE';

    Q.SQL.Text := Q.SQL.Text + ' LIMIT 1';

    for Criterion in AFilter do
      Q.ParamByName(Criterion.FieldName).Value := Criterion.Value.AsVariant;

    Q.Open;

    if not Q.IsEmpty then
    begin
      Result := TSysGridColumn.Create;
      Result.Id := Q.FieldByName('id').AsLargeInt;
      Result.TableName := Q.FieldByName('table_name').AsString;
      Result.ColumnName := Q.FieldByName('column_name').AsString;
      Result.ColumnOrder := Q.FieldByName('column_order').AsInteger;
      Result.ColumnWidth := Q.FieldByName('column_width').AsInteger;
      Result.DataFormat := Q.FieldByName('data_format').AsString;
      Result.IsShow := Q.FieldByName('is_show').AsBoolean;
      Result.IsShowHelper := Q.FieldByName('is_show_helper').AsBoolean;
      Result.MinValue := Q.FieldByName('min_value').AsFloat;
      Result.MinValueColor := Q.FieldByName('min_value_color').AsInteger;
      Result.MaxValue := Q.FieldByName('max_value').AsFloat;
      Result.MaxValueColor := Q.FieldByName('max_value_color').AsInteger;
      Result.MaxValuePercent := Q.FieldByName('max_value_percent').AsFloat;
      Result.BarColor := Q.FieldByName('bar_color').AsInteger;
      Result.BarBgColor := Q.FieldByName('bar_bg_color').AsInteger;
      Result.BarTextColor := Q.FieldByName('bar_text_color').AsInteger;
    end;
  finally
    Q.Free;
  end;
end;

function TSysGridColumnRepository.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysGridColumn>;
var
  Q: TFDQuery;
  Item: TSysGridColumn;
  Criterion: TFilterCriterion;
begin
  Result := TObjectList<TSysGridColumn>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSelectSql + ' WHERE 1=1';

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for Criterion in AFilter do
        Q.SQL.Text := Q.SQL.Text + ' AND ' + Criterion.FieldName + ' ' + Criterion.Operator + ' :' + Criterion.FieldName;
    end;

    if ALock then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE';

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for Criterion in AFilter do
        Q.ParamByName(Criterion.FieldName).Value := Criterion.Value.AsVariant;
    end;

    Q.Open;
    while not Q.Eof do
    begin
      Item := TSysGridColumn.Create;
      Item.Id := Q.FieldByName('id').AsLargeInt;
      Item.TableName := Q.FieldByName('table_name').AsString;
      Item.ColumnName := Q.FieldByName('column_name').AsString;
      Item.ColumnOrder := Q.FieldByName('column_order').AsInteger;
      Item.ColumnWidth := Q.FieldByName('column_width').AsInteger;
      Item.DataFormat := Q.FieldByName('data_format').AsString;
      Item.IsShow := Q.FieldByName('is_show').AsBoolean;
      Item.IsShowHelper := Q.FieldByName('is_show_helper').AsBoolean;
      Item.MinValue := Q.FieldByName('min_value').AsFloat;
      Item.MinValueColor := Q.FieldByName('min_value_color').AsInteger;
      Item.MaxValue := Q.FieldByName('max_value').AsFloat;
      Item.MaxValueColor := Q.FieldByName('max_value_color').AsInteger;
      Item.MaxValuePercent := Q.FieldByName('max_value_percent').AsFloat;
      Item.BarColor := Q.FieldByName('bar_color').AsInteger;
      Item.BarBgColor := Q.FieldByName('bar_bg_color').AsInteger;
      Item.BarTextColor := Q.FieldByName('bar_text_color').AsInteger;
      Result.Add(Item);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TSysGridColumnRepository.SaveColumns(const ATableName: string; const AColumns: TList<TSysGridColumn>);
var
  Q: TFDQuery;
  I: Integer;
  LChanged: Boolean;
  SQLText: string;
  colName: string;
  colWidth: Integer;
  colOrder: Integer;
  isShow: Boolean;
  colFound: Boolean;
begin
  if AColumns.Count = 0 then Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;

    Q.SQL.Text := 'SELECT EXISTS (SELECT FROM pg_tables WHERE schemaname = ''public'' AND tablename = ''sys_grid_column'')';
    try
      Q.Open;
      if not Q.Fields[0].AsBoolean then
        Exit;
    except
      Exit;
    end;
    Q.Close;

    Q.SQL.Text := 'SELECT column_name, column_order, column_width, is_show ' +
                  'FROM public.sys_grid_column WHERE table_name = :t';
    Q.ParamByName('t').AsString := ATableName;
    try
      Q.Open;
    except
      Exit;
    end;

    LChanged := False;
    if Q.RecordCount <> AColumns.Count then
    begin
      LChanged := True;
    end
    else
    begin
      while not Q.Eof do
      begin
        colName  := Q.FieldByName('column_name').AsString;
        colOrder := Q.FieldByName('column_order').AsInteger;
        colWidth := Q.FieldByName('column_width').AsInteger;
        isShow   := Q.FieldByName('is_show').AsBoolean;
        colFound := False;
        for I := 0 to AColumns.Count - 1 do
        begin
          if SameText(AColumns[I].ColumnName, colName) then
          begin
            colFound := True;
            if (AColumns[I].ColumnOrder <> colOrder) or
               (AColumns[I].ColumnWidth <> colWidth) or
               (AColumns[I].IsShow <> isShow) then
            begin
              LChanged := True;
              Break;
            end;
            Break;
          end;
        end;
        if LChanged or not colFound then
        begin
          LChanged := True;
          Break;
        end;
        Q.Next;
      end;
    end;
    Q.Close;

    if not LChanged then
      Exit;

    Q.SQL.Text := 'UPDATE public.sys_grid_column ' +
                  'SET column_order = -1000+column_order ' +
                  'WHERE table_name = :t';
    Q.ParamByName('t').AsString := ATableName;
    try
      Q.ExecSQL;
    except
      Q.SQL.Text := 'DELETE FROM public.sys_grid_column WHERE table_name = :t';
      Q.ParamByName('t').AsString := ATableName;
      try
        Q.ExecSQL;
      except
        Exit;
      end;
    end;

    SQLText := 'INSERT INTO public.sys_grid_column (table_name, column_name, column_order, column_width, is_show) VALUES ';
    for I := 0 to AColumns.Count - 1 do
    begin
      if I > 0 then
        SQLText := SQLText + ', ';
      SQLText := SQLText + Format('(:t, :cn%d, :co%d, :cw%d, :cs%d)', [I, I, I, I]);
    end;
    SQLText := SQLText + ' ON CONFLICT (table_name, column_name) DO UPDATE SET ' +
                         '  column_order = EXCLUDED.column_order, ' +
                         '  column_width = EXCLUDED.column_width, ' +
                         '  is_show      = EXCLUDED.is_show';

    Q.SQL.Text := SQLText;
    Q.ParamByName('t').AsString := ATableName;
    for I := 0 to AColumns.Count - 1 do
    begin
      Q.ParamByName('cn' + IntToStr(I)).AsString  := AColumns[I].ColumnName;
      Q.ParamByName('co' + IntToStr(I)).AsInteger := AColumns[I].ColumnOrder;
      Q.ParamByName('cw' + IntToStr(I)).AsInteger := AColumns[I].ColumnWidth;
      Q.ParamByName('cs' + IntToStr(I)).AsBoolean := AColumns[I].IsShow;
    end;
    try
      Q.ExecSQL;
    except
      // Kayıt hatası sessizce yutulur — kritik yol değil
    end;

  finally
    Q.Free;
  end;
end;

function TSysGridColumnRepository.LoadColumns(const ATableName: string): TList<TSysGridColumn>;
var
  Q: TFDQuery;
  Item: TSysGridColumn;
begin
  Result := TObjectList<TSysGridColumn>.Create(True);
  
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    
    // Check if sys_grid_column table exists to prevent debugger exception breaks in dev environment
    Q.SQL.Text := 'SELECT EXISTS (SELECT FROM pg_tables WHERE schemaname = ''public'' AND tablename = ''sys_grid_column'')';
    try
      Q.Open;
      if not Q.Fields[0].AsBoolean then
        Exit;
    except
      Exit;
    end;
    Q.Close;

    Q.SQL.Text := 'SELECT id, table_name, column_name, column_order, column_width, is_show ' +
                  'FROM public.sys_grid_column ' +
                  'WHERE table_name = :t ' +
                  'ORDER BY column_order';
    Q.ParamByName('t').AsString := ATableName;
    try
      Q.Open;
    except
      Exit;
    end;
    
    while not Q.Eof do
    begin
      Item := TSysGridColumn.Create;
      Item.Id := Q.FieldByName('id').AsLargeInt;
      Item.TableName := Q.FieldByName('table_name').AsString;
      Item.ColumnName := Q.FieldByName('column_name').AsString;
      Item.ColumnOrder := Q.FieldByName('column_order').AsInteger;
      Item.ColumnWidth := Q.FieldByName('column_width').AsInteger;
      Item.IsShow := Q.FieldByName('is_show').AsBoolean;
      Result.Add(Item);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

end.
