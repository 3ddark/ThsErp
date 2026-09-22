unit SysGridColumnHelper;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, Logger,
  SysGridColumn.Cache;

type
  TGridColumnHelper = class
  public
    class function BuildSelectColumns(
      AConnection: TFDConnection;
      const ATableName: string;
      const AAlwaysFetch: TArray<string>
    ): string;

    class function GetTableColumnNames(
      AConnection: TFDConnection;
      const ATableName: string
    ): TArray<string>;

    class function IsValidIdentifier(const AIdentifier: string): Boolean;
    class function ValidateSortClause(const ASortContent: string): Boolean;
    class function ValidateFilterClause(const AFilterContent: string): Boolean;
    class function FormatFilterCondition(
      const ACol, AOp, AVal: string;
      AIsNot: Boolean
    ): string;
  end;

implementation

uses
  System.Character, System.StrUtils;

class function TGridColumnHelper.BuildSelectColumns(
  AConnection: TFDConnection;
  const ATableName: string;
  const AAlwaysFetch: TArray<string>
): string;
begin
  Result := TSysGridColumnCache.BuildSelectColumns(AConnection, ATableName, AAlwaysFetch);
end;

class function TGridColumnHelper.GetTableColumnNames(
  AConnection: TFDConnection;
  const ATableName: string
): TArray<string>;
var
  Q: TFDQuery;
  LCleanTbl, LBaseTbl, LViewTbl, LSpacedTbl: string;
  LList: TList<string>;
  LCol: string;
begin
  SetLength(Result, 0);
  if (AConnection = nil) or not AConnection.Connected or (Trim(ATableName) = '') then
    Exit;

  LCleanTbl := LowerCase(Trim(ATableName));
  if LCleanTbl.StartsWith('public.') then
    LCleanTbl := LCleanTbl.Substring(7);
  LCleanTbl := StringReplace(LCleanTbl, ' ', '_', [rfReplaceAll]);

  LBaseTbl := LCleanTbl;
  if LBaseTbl.StartsWith('vw_') then
    LBaseTbl := LBaseTbl.Substring(3);
  LViewTbl := 'vw_' + LBaseTbl;
  LSpacedTbl := StringReplace(LBaseTbl, '_', ' ', [rfReplaceAll]);

  LList := TList<string>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;
    // 1. sys_view_columns view query
    try
      Q.SQL.Text :=
        'SELECT DISTINCT orj_column_name ' +
        'FROM public.sys_view_columns ' +
        'WHERE lower(orj_table_name) IN (:t1, :t2, :t3) ' +
        '   OR lower(replace(table_name, '' '', ''_'')) IN (:t1, :t2, :t3) ' +
        'ORDER BY orj_column_name';
      Q.ParamByName('t1').AsString := LCleanTbl;
      Q.ParamByName('t2').AsString := LBaseTbl;
      Q.ParamByName('t3').AsString := LViewTbl;
      Q.Open;
      while not Q.Eof do
      begin
        LCol := Q.FieldByName('orj_column_name').AsString;
        if (LCol <> '') and not LList.Contains(LCol) then
          LList.Add(LCol);
        Q.Next;
      end;
      Q.Close;
    except
      on E: Exception do
        GLogger.WarningFmt('TGridColumnHelper.GetTableColumnNames sys_view_columns error: %s', [E.Message]);
    end;

    // 2. information_schema.columns query (if not found in sys_view_columns)
    if LList.Count = 0 then
    begin
      try
        Q.SQL.Text :=
          'SELECT column_name ' +
          'FROM information_schema.columns ' +
          'WHERE table_schema = ''public'' ' +
          '  AND lower(table_name) IN (:t1, :t2, :t3, :t4) ' +
          'ORDER BY ordinal_position';
        Q.ParamByName('t1').AsString := LCleanTbl;
        Q.ParamByName('t2').AsString := LBaseTbl;
        Q.ParamByName('t3').AsString := LViewTbl;
        Q.ParamByName('t4').AsString := LSpacedTbl;

        Q.Open;
        while not Q.Eof do
        begin
          LCol := Q.FieldByName('column_name').AsString;
          if (LCol <> '') and not LList.Contains(LCol) then
            LList.Add(LCol);
          Q.Next;
        end;
        Q.Close;
      except
        on E: Exception do
          GLogger.WarningFmt('TGridColumnHelper.GetTableColumnNames info_schema error: %s', [E.Message]);
      end;
    end;

    // 3. sys_grid_column fallback
    if LList.Count = 0 then
    begin
      Q.SQL.Text :=
        'SELECT DISTINCT column_name ' +
        'FROM public.sys_grid_column ' +
        'WHERE lower(replace(table_name, '' '', ''_'')) IN (:t1, :t2, :t3, :t4) ' +
        'ORDER BY column_name';
      Q.ParamByName('t1').AsString := LCleanTbl;
      Q.ParamByName('t2').AsString := LBaseTbl;
      Q.ParamByName('t3').AsString := LViewTbl;
      Q.ParamByName('t4').AsString := LSpacedTbl;
      try
        Q.Open;
        while not Q.Eof do
        begin
          LCol := Q.FieldByName('column_name').AsString;
          if (LCol <> '') and not LList.Contains(LCol) then
            LList.Add(LCol);
          Q.Next;
        end;
      except
        on E: Exception do
          GLogger.WarningFmt('TGridColumnHelper.GetTableColumnNames sys_grid_column error: %s', [E.Message]);
      end;
    end;

    Result := LList.ToArray;
  finally
    Q.Free;
    LList.Free;
  end;
end;

class function TGridColumnHelper.IsValidIdentifier(const AIdentifier: string): Boolean;
var
  LTrimmed: string;
  LParts: TArray<string>;
  LPart: string;
  i: Integer;
begin
  LTrimmed := Trim(AIdentifier);
  if LTrimmed = '' then Exit(False);

  // Allow qualified identifiers like alias.column or table.column
  LParts := LTrimmed.Split(['.']);
  if (Length(LParts) < 1) or (Length(LParts) > 2) then Exit(False);

  for LPart in LParts do
  begin
    if (LPart = '') or (Length(LPart) > 63) then Exit(False);
    if not (LPart[1].IsLetter or (LPart[1] = '_')) then Exit(False);
    for i := 2 to Length(LPart) do
    begin
      if not (LPart[i].IsLetterOrDigit or (LPart[i] = '_')) then
        Exit(False);
    end;
  end;

  Result := True;
end;

class function TGridColumnHelper.ValidateSortClause(const ASortContent: string): Boolean;
var
  LContent: string;
  LTokens: TArray<string>;
  LToken: string;
  LParts: TArray<string>;
  LColPart, LDirPart: string;
begin
  LContent := Trim(ASortContent);
  if LContent = '' then Exit(True);

  // Strip leading ORDER BY if present
  if StartsText('ORDER BY ', LContent) then
    LContent := Trim(Copy(LContent, 10, MaxInt));

  // SQL Injection dangerous characters
  if (Pos(';', LContent) > 0) or (Pos('--', LContent) > 0) or
     (Pos('/*', LContent) > 0) or (Pos('*/', LContent) > 0) or
     (Pos('''', LContent) > 0) or (Pos('"', LContent) > 0) or
     (Pos('\', LContent) > 0) then
    Exit(False);

  // Must not contain dangerous keywords
  if ContainsText(LContent, 'UNION') or
     ContainsText(LContent, 'DROP') or
     ContainsText(LContent, 'EXEC') or
     ContainsText(LContent, 'DELETE') or
     ContainsText(LContent, 'INSERT') or
     ContainsText(LContent, 'UPDATE') or
     ContainsText(LContent, 'TRUNCATE') or
     ContainsText(LContent, 'SELECT') or
     ContainsText(LContent, 'PG_') or
     ContainsText(LContent, 'SLEEP') then
    Exit(False);

  LTokens := LContent.Split([',']);
  for LToken in LTokens do
  begin
    LParts := Trim(LToken).Split([' '], TStringSplitOptions.ExcludeEmpty);
    if (Length(LParts) < 1) or (Length(LParts) > 4) then
      Exit(False);

    LColPart := Trim(LParts[0]);
    if not IsValidIdentifier(LColPart) then
      Exit(False);

    if Length(LParts) >= 2 then
    begin
      LDirPart := UpperCase(Trim(LParts[1]));
      if (LDirPart <> 'ASC') and (LDirPart <> 'DESC') then
        Exit(False);
    end;

    if Length(LParts) >= 4 then
    begin
      if (UpperCase(Trim(LParts[2])) <> 'NULLS') or
         ((UpperCase(Trim(LParts[3])) <> 'FIRST') and (UpperCase(Trim(LParts[3])) <> 'LAST')) then
        Exit(False);
    end
    else if Length(LParts) = 3 then
      Exit(False);
  end;

  Result := True;
end;

class function TGridColumnHelper.ValidateFilterClause(const AFilterContent: string): Boolean;
var
  LContent, LUpper: string;
  LInSingleQuote: Boolean;
  LParenCount: Integer;
  i: Integer;
begin
  LContent := Trim(AFilterContent);
  if LContent = '' then Exit(True);

  // Strip leading WHERE if present
  if StartsText('WHERE ', LContent) then
    LContent := Trim(Copy(LContent, 7, MaxInt));

  // Check dangerous characters outside quotes: semicolon and comments
  if (Pos(';', LContent) > 0) or (Pos('--', LContent) > 0) or
     (Pos('/*', LContent) > 0) or (Pos('*/', LContent) > 0) then
    Exit(False);

  LUpper := UpperCase(LContent);

  // Check dangerous SQL statements / functions
  if ContainsText(LUpper, 'DROP ') or
     ContainsText(LUpper, 'ALTER ') or
     ContainsText(LUpper, 'CREATE ') or
     ContainsText(LUpper, 'TRUNCATE ') or
     ContainsText(LUpper, 'EXEC ') or
     ContainsText(LUpper, 'EXECUTE ') or
     ContainsText(LUpper, 'UNION ') or
     ContainsText(LUpper, 'INSERT INTO') or
     ContainsText(LUpper, 'DELETE FROM') or
     ContainsText(LUpper, 'UPDATE ') or
     ContainsText(LUpper, 'PG_SLEEP') or
     ContainsText(LUpper, 'XP_CMDSHELL') or
     ContainsText(LUpper, 'SHUTDOWN') then
    Exit(False);

  // Validate balanced parentheses and quotes
  LInSingleQuote := False;
  LParenCount := 0;
  i := 1;
  while i <= Length(LContent) do
  begin
    if LContent[i] = '''' then
    begin
      if (i < Length(LContent)) and (LContent[i + 1] = '''') then
        Inc(i) // escaped quote ''
      else
        LInSingleQuote := not LInSingleQuote;
    end
    else if not LInSingleQuote then
    begin
      if LContent[i] = '(' then
        Inc(LParenCount)
      else if LContent[i] = ')' then
      begin
        Dec(LParenCount);
        if LParenCount < 0 then Exit(False);
      end;
    end;
    Inc(i);
  end;

  if LInSingleQuote then Exit(False); // unclosed quote
  if LParenCount <> 0 then Exit(False); // unbalanced parentheses

  Result := True;
end;

class function TGridColumnHelper.FormatFilterCondition(
  const ACol, AOp, AVal: string;
  AIsNot: Boolean
): string;
var
  LOpUpper, LSafeVal, LCond: string;
  LFloatVal: Double;
  LIntVal: Int64;
  LIsNumeric, LIsBool: Boolean;
begin
  if not IsValidIdentifier(ACol) then
    raise Exception.CreateFmt('Invalid column name: %s', [ACol]);

  LOpUpper := UpperCase(Trim(AOp));

  // Sanitize single quotes in value
  LSafeVal := StringReplace(Trim(AVal), '''', '''''', [rfReplaceAll]);

  if (LOpUpper = 'IS NULL') or (LOpUpper = 'IS NOT NULL') then
  begin
    LCond := Format('%s %s', [ACol, LOpUpper]);
  end
  else if (LOpUpper = 'LIKE') or (LOpUpper = 'CONTAINS') then
  begin
    LCond := Format('%s LIKE ''%%%s%%''', [ACol, LSafeVal]);
  end
  else if (LOpUpper = 'NOT LIKE') then
  begin
    LCond := Format('%s NOT LIKE ''%%%s%%''', [ACol, LSafeVal]);
  end
  else if (LOpUpper = 'STARTS WITH') then
  begin
    LCond := Format('%s LIKE ''%s%%''', [ACol, LSafeVal]);
  end
  else if (LOpUpper = 'ENDS WITH') then
  begin
    LCond := Format('%s LIKE ''%%%s''', [ACol, LSafeVal]);
  end
  else if (LOpUpper = 'IN') or (LOpUpper = 'NOT IN') then
  begin
    if StartsText('(', LSafeVal) and EndsText(')', LSafeVal) then
      LCond := Format('%s %s %s', [ACol, LOpUpper, LSafeVal])
    else
      LCond := Format('%s %s (%s)', [ACol, LOpUpper, LSafeVal]);
  end
  else
  begin
    // Standard comparison operators: =, <>, >, >=, <, <=
    LIsNumeric := TryStrToInt64(LSafeVal, LIntVal) or TryStrToFloat(LSafeVal, LFloatVal);
    LIsBool := SameText(LSafeVal, 'true') or SameText(LSafeVal, 'false') or SameText(LSafeVal, 'null');

    if LIsNumeric or LIsBool then
      LCond := Format('%s %s %s', [ACol, LOpUpper, LSafeVal])
    else
      LCond := Format('%s %s ''%s''', [ACol, LOpUpper, LSafeVal]);
  end;

  if AIsNot then
    Result := Format('NOT (%s)', [LCond])
  else
    Result := LCond;
end;

end.
