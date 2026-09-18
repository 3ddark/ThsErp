unit SysGridColumn.Cache;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Generics.Defaults,
  System.SyncObjs, FireDAC.Comp.Client, FireDAC.Stan.Param,
  SysGridColumn, Logger;

type
  TGridColumnItem = record
    Id             : Int64;
    TableName      : string;
    ColumnName     : string;
    ColumnOrder    : Integer;
    ColumnWidth    : Integer;
    DataFormat     : string;
    IsShow         : Boolean;
    IsShowHelper   : Boolean;
    IsFetch        : Boolean;
    MinValue       : Double;
    MinValueColor  : Integer;
    MaxValue       : Double;
    MaxValueColor  : Integer;
    MaxValuePercent: Double;
    BarColor       : Integer;
    BarBgColor     : Integer;
    BarTextColor   : Integer;
    AggregateType  : Integer;

    function ToEntity: TSysGridColumn;
    class function FromEntity(AEntity: TSysGridColumn): TGridColumnItem; static;
  end;

  TUserGridColumnItem = record
    ColumnName : string;
    ColumnOrder: Integer;
    ColumnWidth: Integer;
    IsShow     : Boolean;
  end;

  TSysGridColumnCache = class
  strict private
    class var FLock           : TCriticalSection;
    class var FGlobalCols     : TDictionary<string, TArray<TGridColumnItem>>;
    class var FUserCols       : TDictionary<string, TArray<TUserGridColumnItem>>;
    class var FSelectColsCache: TDictionary<string, string>;
    class var FTableExists    : Boolean;
    class var FTableExistsChecked: Boolean;
    class var FGlobalLoaded   : Boolean;
    class var FLoadedUserId   : Int64;

    class function NormalizeTableName(const ATableName: string): string; static;
    class procedure GetTableVariants(const ATableName: string; out ACleanTbl, ABaseTbl, AViewTbl: string); static;
    class function InternalLoadColumns(const ATableName: string): TArray<TGridColumnItem>; static;
  public
    class constructor Create;
    class destructor  Destroy;

    class procedure LoadGlobal(AConnection: TFDConnection; AForce: Boolean = False); static;
    class procedure LoadUser(AConnection: TFDConnection; AUserId: Int64; AForce: Boolean = False); static;

    class function IsGlobalLoaded: Boolean; static;
    class function IsUserLoaded(AUserId: Int64): Boolean; static;

    class function CheckTableExists(AConnection: TFDConnection = nil): Boolean; static;
    class function HasTableColumns(AConnection: TFDConnection; const ATableName: string): Boolean; static;
    class function LoadColumns(AConnection: TFDConnection; const ATableName: string): TObjectList<TSysGridColumn>; static;
    class function LoadUserColumns(AConnection: TFDConnection; const ATableName: string; AUserId: Int64): TObjectList<TSysGridColumn>; static;

    class function BuildSelectColumns(AConnection: TFDConnection; const ATableName: string; const AAlwaysFetch: TArray<string>): string; static;

    class function IsUserColumnsChanged(const ATableName: string; AUserId: Int64; const AColumns: TObjectList<TSysGridColumn>): Boolean; static;

    class procedure UpdateGlobal(const ATableName: string; const AColumns: TObjectList<TSysGridColumn>); static;
    class procedure UpdateUser(const ATableName: string; AUserId: Int64; const AColumns: TObjectList<TSysGridColumn>); static;

    class procedure InvalidateTable(const ATableName: string); static;
    class procedure InvalidateUser(AUserId: Int64); static;
    class procedure InvalidateAll; static;
    class procedure Clear; static;
  end;

implementation

{ TGridColumnItem }

function TGridColumnItem.ToEntity: TSysGridColumn;
begin
  Result := TSysGridColumn.Create;
  Result.Id              := Self.Id;
  Result.TableName       := Self.TableName;
  Result.ColumnName      := Self.ColumnName;
  Result.ColumnOrder     := Self.ColumnOrder;
  Result.ColumnWidth     := Self.ColumnWidth;
  Result.DataFormat      := Self.DataFormat;
  Result.IsShow          := Self.IsShow;
  Result.IsShowHelper    := Self.IsShowHelper;
  Result.IsFetch         := Self.IsFetch;
  Result.MinValue        := Self.MinValue;
  Result.MinValueColor   := Self.MinValueColor;
  Result.MaxValue        := Self.MaxValue;
  Result.MaxValueColor   := Self.MaxValueColor;
  Result.MaxValuePercent := Self.MaxValuePercent;
  Result.BarColor        := Self.BarColor;
  Result.BarBgColor      := Self.BarBgColor;
  Result.BarTextColor    := Self.BarTextColor;
  Result.AggregateType   := Self.AggregateType;
end;

class function TGridColumnItem.FromEntity(AEntity: TSysGridColumn): TGridColumnItem;
begin
  Result.Id              := AEntity.Id;
  Result.TableName       := AEntity.TableName;
  Result.ColumnName      := AEntity.ColumnName;
  Result.ColumnOrder     := AEntity.ColumnOrder;
  Result.ColumnWidth     := AEntity.ColumnWidth;
  Result.DataFormat      := AEntity.DataFormat;
  Result.IsShow          := AEntity.IsShow;
  Result.IsShowHelper    := AEntity.IsShowHelper;
  Result.IsFetch         := AEntity.IsFetch;
  Result.MinValue        := AEntity.MinValue;
  Result.MinValueColor   := AEntity.MinValueColor;
  Result.MaxValue        := AEntity.MaxValue;
  Result.MaxValueColor   := AEntity.MaxValueColor;
  Result.MaxValuePercent := AEntity.MaxValuePercent;
  Result.BarColor        := AEntity.BarColor;
  Result.BarBgColor      := AEntity.BarBgColor;
  Result.BarTextColor    := AEntity.BarTextColor;
  Result.AggregateType   := AEntity.AggregateType;
end;

{ TSysGridColumnCache }

class constructor TSysGridColumnCache.Create;
begin
  FLock            := TCriticalSection.Create;
  FGlobalCols      := TDictionary<string, TArray<TGridColumnItem>>.Create;
  FUserCols        := TDictionary<string, TArray<TUserGridColumnItem>>.Create;
  FSelectColsCache := TDictionary<string, string>.Create;
  FTableExists     := False;
  FTableExistsChecked := False;
  FGlobalLoaded    := False;
  FLoadedUserId    := 0;
end;

class destructor TSysGridColumnCache.Destroy;
begin
  FSelectColsCache.Free;
  FUserCols.Free;
  FGlobalCols.Free;
  FLock.Free;
end;

class function TSysGridColumnCache.NormalizeTableName(const ATableName: string): string;
begin
  Result := LowerCase(Trim(ATableName));
  if Result.StartsWith('public.', True) then
    Result := Result.Substring(7);
end;

class procedure TSysGridColumnCache.GetTableVariants(
  const ATableName: string;
  out ACleanTbl, ABaseTbl, AViewTbl: string);
begin
  ACleanTbl := NormalizeTableName(ATableName);
  ABaseTbl  := ACleanTbl;
  if ABaseTbl.StartsWith('vw_', True) then
    ABaseTbl := ABaseTbl.Substring(3);
  AViewTbl  := 'vw_' + ABaseTbl;
end;

class function TSysGridColumnCache.CheckTableExists(AConnection: TFDConnection): Boolean;
var
  Q: TFDQuery;
begin
  FLock.Enter;
  try
    if FTableExistsChecked then
      Exit(FTableExists);
  finally
    FLock.Leave;
  end;

  if (AConnection = nil) or not AConnection.Connected then
    Exit(False);

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;
    Q.SQL.Text :=
      'SELECT EXISTS (' +
      '  SELECT FROM pg_tables ' +
      '  WHERE schemaname = ''public'' ' +
      '  AND tablename = ''sys_grid_column'')';
    try
      Q.Open;
      FLock.Enter;
      try
        FTableExists := Q.Fields[0].AsBoolean;
        FTableExistsChecked := True;
        Result := FTableExists;
      finally
        FLock.Leave;
      end;
    except
      on E: Exception do
      begin
        GLogger.ErrorFmt('TSysGridColumnCache.CheckTableExists error: %s', [E.Message]);
        Result := False;
      end;
    end;
  finally
    Q.Free;
  end;
end;

class procedure TSysGridColumnCache.LoadGlobal(AConnection: TFDConnection; AForce: Boolean);
var
  Q: TFDQuery;
  LItem: TGridColumnItem;
  LTempMap: TDictionary<string, TList<TGridColumnItem>>;
  LTbl: string;
  LPair: TPair<string, TList<TGridColumnItem>>;
  LCount: Integer;
begin
  if not AForce then
  begin
    FLock.Enter;
    try
      if FGlobalLoaded then Exit;
    finally
      FLock.Leave;
    end;
  end;

  if (AConnection = nil) or not AConnection.Connected then Exit;
  if not CheckTableExists(AConnection) then Exit;

  Q := TFDQuery.Create(nil);
  LTempMap := TDictionary<string, TList<TGridColumnItem>>.Create;
  try
    Q.Connection := AConnection;
    Q.SQL.Text :=
      'SELECT id, table_name, column_name, column_order, column_width, data_format, ' +
      '       is_show, is_show_helper, is_fetch, aggregate_type, ' +
      '       min_value, min_value_color, max_value, max_value_color, ' +
      '       max_value_percent, bar_color, bar_bg_color, bar_text_color ' +
      'FROM public.sys_grid_column ' +
      'ORDER BY table_name, column_order';
    try
      Q.Open;
      LCount := 0;
      while not Q.Eof do
      begin
        LTbl := NormalizeTableName(Q.FieldByName('table_name').AsString);
        if LTbl <> '' then
        begin
          LItem.Id              := Q.FieldByName('id').AsLargeInt;
          LItem.TableName       := Q.FieldByName('table_name').AsString;
          LItem.ColumnName      := Q.FieldByName('column_name').AsString;
          LItem.ColumnOrder     := Q.FieldByName('column_order').AsInteger;
          LItem.ColumnWidth     := Q.FieldByName('column_width').AsInteger;
          LItem.DataFormat      := Q.FieldByName('data_format').AsString;
          LItem.IsShow          := Q.FieldByName('is_show').AsBoolean;
          LItem.IsShowHelper    := Q.FieldByName('is_show_helper').AsBoolean;
          if Q.FindField('is_fetch') <> nil then
            LItem.IsFetch       := Q.FieldByName('is_fetch').AsBoolean
          else
            LItem.IsFetch       := True;
          if Q.FindField('aggregate_type') <> nil then
            LItem.AggregateType := Q.FieldByName('aggregate_type').AsInteger
          else
            LItem.AggregateType := 0;

          if Q.FindField('min_value') <> nil then
            LItem.MinValue      := Q.FieldByName('min_value').AsFloat
          else
            LItem.MinValue      := 0;
          if Q.FindField('min_value_color') <> nil then
            LItem.MinValueColor := Q.FieldByName('min_value_color').AsInteger
          else
            LItem.MinValueColor := 0;
          if Q.FindField('max_value') <> nil then
            LItem.MaxValue      := Q.FieldByName('max_value').AsFloat
          else
            LItem.MaxValue      := 0;
          if Q.FindField('max_value_color') <> nil then
            LItem.MaxValueColor := Q.FieldByName('max_value_color').AsInteger
          else
            LItem.MaxValueColor := 0;
          if Q.FindField('max_value_percent') <> nil then
            LItem.MaxValuePercent := Q.FieldByName('max_value_percent').AsFloat
          else
            LItem.MaxValuePercent := 0;
          if Q.FindField('bar_color') <> nil then
            LItem.BarColor      := Q.FieldByName('bar_color').AsInteger
          else
            LItem.BarColor      := 0;
          if Q.FindField('bar_bg_color') <> nil then
            LItem.BarBgColor    := Q.FieldByName('bar_bg_color').AsInteger
          else
            LItem.BarBgColor    := 0;
          if Q.FindField('bar_text_color') <> nil then
            LItem.BarTextColor := Q.FieldByName('bar_text_color').AsInteger
          else
            LItem.BarTextColor := 0;

          if not LTempMap.ContainsKey(LTbl) then
            LTempMap.Add(LTbl, TList<TGridColumnItem>.Create);
          LTempMap[LTbl].Add(LItem);
          Inc(LCount);
        end;
        Q.Next;
      end;

      FLock.Enter;
      try
        FGlobalCols.Clear;
        FSelectColsCache.Clear;
        for LPair in LTempMap do
          FGlobalCols.Add(LPair.Key, LPair.Value.ToArray);
        FGlobalLoaded := True;
        FTableExists  := True;
        FTableExistsChecked := True;
      finally
        FLock.Leave;
      end;

      GLogger.InfoFmt('TSysGridColumnCache: %d global kolon kaydı yüklendi (%d tablo)', [LCount, LTempMap.Count]);
    except
      on E: Exception do
        GLogger.ErrorFmt('TSysGridColumnCache.LoadGlobal error: %s', [E.Message]);
    end;
  finally
    for LPair in LTempMap do
      LPair.Value.Free;
    LTempMap.Free;
    Q.Free;
  end;
end;

class procedure TSysGridColumnCache.LoadUser(AConnection: TFDConnection; AUserId: Int64; AForce: Boolean);
var
  Q: TFDQuery;
  LItem: TUserGridColumnItem;
  LTempMap: TDictionary<string, TList<TUserGridColumnItem>>;
  LTbl: string;
  LKey: string;
  LPair: TPair<string, TList<TUserGridColumnItem>>;
  LCount: Integer;
begin
  if AUserId <= 0 then Exit;

  if not AForce then
  begin
    FLock.Enter;
    try
      if FLoadedUserId = AUserId then Exit;
    finally
      FLock.Leave;
    end;
  end;

  if (AConnection = nil) or not AConnection.Connected then Exit;

  Q := TFDQuery.Create(nil);
  LTempMap := TDictionary<string, TList<TUserGridColumnItem>>.Create;
  try
    Q.Connection := AConnection;
    Q.SQL.Text :=
      'SELECT table_name, column_name, column_order, column_width, is_show ' +
      'FROM public.sys_user_grid_column ' +
      'WHERE user_id = :uid ' +
      'ORDER BY table_name, column_order';
    Q.ParamByName('uid').AsLargeInt := AUserId;
    try
      Q.Open;
      LCount := 0;
      while not Q.Eof do
      begin
        LTbl := NormalizeTableName(Q.FieldByName('table_name').AsString);
        if LTbl <> '' then
        begin
          LKey := Format('%d:%s', [AUserId, LTbl]);
          LItem.ColumnName  := Q.FieldByName('column_name').AsString;
          LItem.ColumnOrder := Q.FieldByName('column_order').AsInteger;
          LItem.ColumnWidth := Q.FieldByName('column_width').AsInteger;
          LItem.IsShow      := Q.FieldByName('is_show').AsBoolean;

          if not LTempMap.ContainsKey(LKey) then
            LTempMap.Add(LKey, TList<TUserGridColumnItem>.Create);
          LTempMap[LKey].Add(LItem);
          Inc(LCount);
        end;
        Q.Next;
      end;

      FLock.Enter;
      try
        // Remove previous user entries
        var LKeysToRemove := TList<string>.Create;
        try
          for var K in FUserCols.Keys do
            if K.StartsWith(AUserId.ToString + ':') then
              LKeysToRemove.Add(K);
          for var K in LKeysToRemove do
            FUserCols.Remove(K);
        finally
          LKeysToRemove.Free;
        end;

        for LPair in LTempMap do
          FUserCols.Add(LPair.Key, LPair.Value.ToArray);
        FLoadedUserId := AUserId;
      finally
        FLock.Leave;
      end;

      GLogger.InfoFmt('TSysGridColumnCache: User %d için %d kolon ayarı yüklendi (%d tablo)',
        [AUserId, LCount, LTempMap.Count]);
    except
      on E: Exception do
        GLogger.ErrorFmt('TSysGridColumnCache.LoadUser error [User %d]: %s', [AUserId, E.Message]);
    end;
  finally
    for LPair in LTempMap do
      LPair.Value.Free;
    LTempMap.Free;
    Q.Free;
  end;
end;

class function TSysGridColumnCache.IsGlobalLoaded: Boolean;
begin
  FLock.Enter;
  try
    Result := FGlobalLoaded;
  finally
    FLock.Leave;
  end;
end;

class function TSysGridColumnCache.IsUserLoaded(AUserId: Int64): Boolean;
begin
  FLock.Enter;
  try
    Result := (FLoadedUserId = AUserId) and (AUserId > 0);
  finally
    FLock.Leave;
  end;
end;

class function TSysGridColumnCache.InternalLoadColumns(const ATableName: string): TArray<TGridColumnItem>;
var
  LCleanTbl, LBaseTbl, LViewTbl: string;
  LExactCols, LOtherCols: TArray<TGridColumnItem>;
  LOtherTbl: string;
  LList: TList<TGridColumnItem>;
  LSeen: TDictionary<string, Boolean>;
  LColLower: string;
  Item: TGridColumnItem;
begin
  GetTableVariants(ATableName, LCleanTbl, LBaseTbl, LViewTbl);
  if LCleanTbl = LViewTbl then
    LOtherTbl := LBaseTbl
  else
    LOtherTbl := LViewTbl;

  LList := TList<TGridColumnItem>.Create;
  LSeen := TDictionary<string, Boolean>.Create;
  try
    FLock.Enter;
    try
      FGlobalCols.TryGetValue(LCleanTbl, LExactCols);
      FGlobalCols.TryGetValue(LOtherTbl, LOtherCols);
    finally
      FLock.Leave;
    end;

    for Item in LExactCols do
    begin
      LColLower := LowerCase(Item.ColumnName);
      if not LSeen.ContainsKey(LColLower) then
      begin
        LSeen.Add(LColLower, True);
        LList.Add(Item);
      end;
    end;

    for Item in LOtherCols do
    begin
      LColLower := LowerCase(Item.ColumnName);
      if not LSeen.ContainsKey(LColLower) then
      begin
        LSeen.Add(LColLower, True);
        LList.Add(Item);
      end;
    end;

    LList.Sort(TComparer<TGridColumnItem>.Construct(
      function(const Left, Right: TGridColumnItem): Integer
      begin
        Result := Left.ColumnOrder - Right.ColumnOrder;
      end));

    Result := LList.ToArray;
  finally
    LSeen.Free;
    LList.Free;
  end;
end;

class function TSysGridColumnCache.HasTableColumns(AConnection: TFDConnection; const ATableName: string): Boolean;
var
  LCleanTbl, LBaseTbl, LViewTbl: string;
begin
  if not IsGlobalLoaded and (AConnection <> nil) then
    LoadGlobal(AConnection);

  GetTableVariants(ATableName, LCleanTbl, LBaseTbl, LViewTbl);

  FLock.Enter;
  try
    Result := FGlobalCols.ContainsKey(LCleanTbl) or
              FGlobalCols.ContainsKey(LBaseTbl) or
              FGlobalCols.ContainsKey(LViewTbl);
  finally
    FLock.Leave;
  end;
end;

class function TSysGridColumnCache.LoadColumns(AConnection: TFDConnection; const ATableName: string): TObjectList<TSysGridColumn>;
var
  LItems: TArray<TGridColumnItem>;
  Item: TGridColumnItem;
begin
  Result := TObjectList<TSysGridColumn>.Create(True);

  if not IsGlobalLoaded and (AConnection <> nil) then
    LoadGlobal(AConnection);

  LItems := InternalLoadColumns(ATableName);
  for Item in LItems do
    Result.Add(Item.ToEntity);
end;

class function TSysGridColumnCache.LoadUserColumns(
  AConnection: TFDConnection;
  const ATableName: string;
  AUserId: Int64): TObjectList<TSysGridColumn>;
var
  LCleanTbl, LBaseTbl, LViewTbl: string;
  LUserCols: TArray<TUserGridColumnItem>;
  LUserKey: string;
  LUserMap: TDictionary<string, TUserGridColumnItem>;
  LItem: TSysGridColumn;
  UserCol: TUserGridColumnItem;
  HasGlobal: Boolean;
begin
  Result := LoadColumns(AConnection, ATableName);
  if AUserId <= 0 then Exit;

  if not IsUserLoaded(AUserId) and (AConnection <> nil) then
    LoadUser(AConnection, AUserId);

  GetTableVariants(ATableName, LCleanTbl, LBaseTbl, LViewTbl);

  LUserCols := nil;
  FLock.Enter;
  try
    LUserKey := Format('%d:%s', [AUserId, LCleanTbl]);
    if not FUserCols.TryGetValue(LUserKey, LUserCols) then
    begin
      LUserKey := Format('%d:%s', [AUserId, LViewTbl]);
      if not FUserCols.TryGetValue(LUserKey, LUserCols) then
      begin
        LUserKey := Format('%d:%s', [AUserId, LBaseTbl]);
        FUserCols.TryGetValue(LUserKey, LUserCols);
      end;
    end;
  finally
    FLock.Leave;
  end;

  if Length(LUserCols) = 0 then Exit;

  HasGlobal := Result.Count > 0;
  LUserMap := TDictionary<string, TUserGridColumnItem>.Create;
  try
    for UserCol in LUserCols do
      LUserMap.AddOrSetValue(LowerCase(UserCol.ColumnName), UserCol);

    for LItem in Result do
    begin
      if LUserMap.TryGetValue(LowerCase(LItem.ColumnName), UserCol) then
      begin
        LItem.ColumnOrder := UserCol.ColumnOrder;
        LItem.ColumnWidth := UserCol.ColumnWidth;
        LItem.IsShow      := UserCol.IsShow;
      end;
    end;

    if not HasGlobal then
    begin
      for UserCol in LUserCols do
      begin
        LItem             := TSysGridColumn.Create;
        LItem.TableName   := ATableName;
        LItem.ColumnName  := UserCol.ColumnName;
        LItem.ColumnOrder := UserCol.ColumnOrder;
        LItem.ColumnWidth := UserCol.ColumnWidth;
        LItem.IsShow      := UserCol.IsShow;
        LItem.IsFetch     := True;
        Result.Add(LItem);
      end;
    end;

    Result.Sort(TComparer<TSysGridColumn>.Construct(
      function(const Left, Right: TSysGridColumn): Integer
      begin
        Result := Left.ColumnOrder - Right.ColumnOrder;
      end));
  finally
    LUserMap.Free;
  end;
end;

class function TSysGridColumnCache.BuildSelectColumns(
  AConnection: TFDConnection;
  const ATableName: string;
  const AAlwaysFetch: TArray<string>): string;
var
  LCleanTbl, LBaseTbl, LViewTbl: string;
  LKey: string;
  LItems: TArray<TGridColumnItem>;
  ColList: TStringList;
  Col: string;
  Item: TGridColumnItem;
  HasOtherCols: Boolean;

  function IsAlwaysFetch(const AColName: string): Boolean;
  var
    S: string;
  begin
    for S in AAlwaysFetch do
      if SameText(S, AColName) then
        Exit(True);
    Result := False;
  end;

begin
  GetTableVariants(ATableName, LCleanTbl, LBaseTbl, LViewTbl);
  LKey := Format('%s|%s', [LCleanTbl, string.Join(',', AAlwaysFetch)]);

  FLock.Enter;
  try
    if FSelectColsCache.TryGetValue(LKey, Result) then
      Exit;
  finally
    FLock.Leave;
  end;

  if not IsGlobalLoaded and (AConnection <> nil) then
    LoadGlobal(AConnection);

  LItems := InternalLoadColumns(ATableName);

  ColList := TStringList.Create;
  try
    ColList.CaseSensitive := False;

    for Col in AAlwaysFetch do
      if (Col <> '') and (ColList.IndexOf(Col) < 0) then
        ColList.Add(Col);

    HasOtherCols := False;
    for Item in LItems do
    begin
      if Item.IsFetch and (Item.ColumnName <> '') then
      begin
        if ColList.IndexOf(Item.ColumnName) < 0 then
          ColList.Add(Item.ColumnName);
        if not HasOtherCols and not IsAlwaysFetch(Item.ColumnName) then
          HasOtherCols := True;
      end;
    end;

    if not HasOtherCols then
      Result := '*'
    else
      Result := string.Join(', ', ColList.ToStringArray);

    FLock.Enter;
    try
      FSelectColsCache.AddOrSetValue(LKey, Result);
    finally
      FLock.Leave;
    end;
  finally
    ColList.Free;
  end;
end;

class function TSysGridColumnCache.IsUserColumnsChanged(
  const ATableName: string;
  AUserId: Int64;
  const AColumns: TObjectList<TSysGridColumn>): Boolean;
var
  LCleanTbl, LBaseTbl, LViewTbl: string;
  LUserCols: TArray<TUserGridColumnItem>;
  LUserKey: string;
  LMap: TDictionary<string, TUserGridColumnItem>;
  LItem: TSysGridColumn;
  UserCol: TUserGridColumnItem;
  I: Integer;
begin
  if (AColumns = nil) or (AColumns.Count = 0) or (AUserId <= 0) then
    Exit(False);

  GetTableVariants(ATableName, LCleanTbl, LBaseTbl, LViewTbl);

  LUserCols := nil;
  FLock.Enter;
  try
    LUserKey := Format('%d:%s', [AUserId, LCleanTbl]);
    if not FUserCols.TryGetValue(LUserKey, LUserCols) then
    begin
      LUserKey := Format('%d:%s', [AUserId, LViewTbl]);
      if not FUserCols.TryGetValue(LUserKey, LUserCols) then
      begin
        LUserKey := Format('%d:%s', [AUserId, LBaseTbl]);
        FUserCols.TryGetValue(LUserKey, LUserCols);
      end;
    end;
  finally
    FLock.Leave;
  end;

  if Length(LUserCols) = 0 then
  begin
    // Check against global columns default
    var LGlobal := InternalLoadColumns(ATableName);
    if Length(LGlobal) = 0 then
      Exit(True); // Brand new columns to persist

    if Length(LGlobal) <> AColumns.Count then
      Exit(True);

    for I := 0 to AColumns.Count - 1 do
    begin
      if not SameText(AColumns[I].ColumnName, LGlobal[I].ColumnName) or
         (AColumns[I].ColumnOrder <> LGlobal[I].ColumnOrder) or
         (AColumns[I].ColumnWidth <> LGlobal[I].ColumnWidth) or
         (AColumns[I].IsShow <> LGlobal[I].IsShow) then
        Exit(True);
    end;
    Exit(False);
  end;

  if Length(LUserCols) <> AColumns.Count then
    Exit(True);

  LMap := TDictionary<string, TUserGridColumnItem>.Create;
  try
    for UserCol in LUserCols do
      LMap.AddOrSetValue(LowerCase(UserCol.ColumnName), UserCol);

    for I := 0 to AColumns.Count - 1 do
    begin
      LItem := AColumns[I];
      if not LMap.TryGetValue(LowerCase(LItem.ColumnName), UserCol) then
        Exit(True);
      if (UserCol.ColumnOrder <> LItem.ColumnOrder) or
         (UserCol.ColumnWidth <> LItem.ColumnWidth) or
         (UserCol.IsShow <> LItem.IsShow) then
        Exit(True);
    end;

    Result := False;
  finally
    LMap.Free;
  end;
end;

class procedure TSysGridColumnCache.UpdateGlobal(
  const ATableName: string;
  const AColumns: TObjectList<TSysGridColumn>);
var
  LCleanTbl, LBaseTbl, LViewTbl: string;
  LArr: TArray<TGridColumnItem>;
  I: Integer;
begin
  if AColumns = nil then Exit;

  GetTableVariants(ATableName, LCleanTbl, LBaseTbl, LViewTbl);
  SetLength(LArr, AColumns.Count);
  for I := 0 to AColumns.Count - 1 do
    LArr[I] := TGridColumnItem.FromEntity(AColumns[I]);

  FLock.Enter;
  try
    FGlobalCols.AddOrSetValue(LCleanTbl, LArr);
    InvalidateTable(LCleanTbl);
    FGlobalCols.AddOrSetValue(LCleanTbl, LArr);
  finally
    FLock.Leave;
  end;
end;

class procedure TSysGridColumnCache.UpdateUser(
  const ATableName: string;
  AUserId: Int64;
  const AColumns: TObjectList<TSysGridColumn>);
var
  LCleanTbl, LBaseTbl, LViewTbl: string;
  LArr: TArray<TUserGridColumnItem>;
  LKey: string;
  I: Integer;
begin
  if (AColumns = nil) or (AUserId <= 0) then Exit;

  GetTableVariants(ATableName, LCleanTbl, LBaseTbl, LViewTbl);
  SetLength(LArr, AColumns.Count);
  for I := 0 to AColumns.Count - 1 do
  begin
    LArr[I].ColumnName  := AColumns[I].ColumnName;
    LArr[I].ColumnOrder := AColumns[I].ColumnOrder;
    LArr[I].ColumnWidth := AColumns[I].ColumnWidth;
    LArr[I].IsShow      := AColumns[I].IsShow;
  end;

  LKey := Format('%d:%s', [AUserId, LCleanTbl]);

  FLock.Enter;
  try
    FUserCols.AddOrSetValue(LKey, LArr);
  finally
    FLock.Leave;
  end;
end;

class procedure TSysGridColumnCache.InvalidateTable(const ATableName: string);
var
  LCleanTbl, LBaseTbl, LViewTbl: string;
  LKeysToRemove: TList<string>;
begin
  GetTableVariants(ATableName, LCleanTbl, LBaseTbl, LViewTbl);

  FLock.Enter;
  try
    FGlobalCols.Remove(LCleanTbl);
    FGlobalCols.Remove(LBaseTbl);
    FGlobalCols.Remove(LViewTbl);

    // Remove user columns matching this table
    LKeysToRemove := TList<string>.Create;
    try
      for var K in FUserCols.Keys do
      begin
        if K.EndsWith(':' + LCleanTbl) or
           K.EndsWith(':' + LBaseTbl) or
           K.EndsWith(':' + LViewTbl) then
          LKeysToRemove.Add(K);
      end;
      for var K in LKeysToRemove do
        FUserCols.Remove(K);

      // Invalidate SelectCols cache for this table
      LKeysToRemove.Clear;
      for var K in FSelectColsCache.Keys do
      begin
        if K.StartsWith(LCleanTbl + '|') or
           K.StartsWith(LBaseTbl + '|') or
           K.StartsWith(LViewTbl + '|') then
          LKeysToRemove.Add(K);
      end;
      for var K in LKeysToRemove do
        FSelectColsCache.Remove(K);
    finally
      LKeysToRemove.Free;
    end;
  finally
    FLock.Leave;
  end;

  GLogger.DebugFmt('TSysGridColumnCache: [%s] tablosu önbellekten silindi', [ATableName]);
end;

class procedure TSysGridColumnCache.InvalidateUser(AUserId: Int64);
var
  LKeysToRemove: TList<string>;
begin
  if AUserId <= 0 then Exit;

  FLock.Enter;
  try
    if FLoadedUserId = AUserId then
      FLoadedUserId := 0;

    LKeysToRemove := TList<string>.Create;
    try
      for var K in FUserCols.Keys do
        if K.StartsWith(AUserId.ToString + ':') then
          LKeysToRemove.Add(K);
      for var K in LKeysToRemove do
        FUserCols.Remove(K);
    finally
      LKeysToRemove.Free;
    end;
  finally
    FLock.Leave;
  end;
end;

class procedure TSysGridColumnCache.InvalidateAll;
begin
  Clear;
  GLogger.Info('TSysGridColumnCache: Tüm önbellek temizlendi');
end;

class procedure TSysGridColumnCache.Clear;
begin
  FLock.Enter;
  try
    FSelectColsCache.Clear;
    FUserCols.Clear;
    FGlobalCols.Clear;
    FTableExistsChecked := False;
    FTableExists        := False;
    FGlobalLoaded       := False;
    FLoadedUserId       := 0;
  finally
    FLock.Leave;
  end;
end;

end.
