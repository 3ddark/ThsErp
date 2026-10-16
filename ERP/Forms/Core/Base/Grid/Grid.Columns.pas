unit Grid.Columns;

// Liste kolon düzeni: sys_grid_column (sistem) / sys_user_grid_column (kullanıcı) okuma-yazma,
// sys_grid_filter + sys_grid_sort ile taban sorgu, sayfa değişiminde ekrandaki düzenin korunması

interface

uses
  System.SysUtils, System.Generics.Collections, Vcl.DBGrids, UnitOfWork, Grid.Types;

type
  TGridColumns = class
  public
    class procedure SetColumnProperty(AGrid: TDBGrid; const AFieldName: string; AWidth: Integer; const AColumnTitle: string = '');
    class procedure SetColumnTitle(AGrid: TDBGrid; const AFieldName, AColumnTitle: string);
    // Görünen kolonlar + çizgiler + gösterge sütunu
    class function VisibleWidth(AGrid: TDBGrid): Integer;

    // View için hiç sys_grid_column satırı yoksa ekrandaki kolonlarla oluşturulur
    class procedure AutoPopulate(AUoW: TUnitOfWork; const AViewName: string; AGrid: TDBGrid);
    // Kullanıcının (yoksa sistemin) kolon görünürlüğü / genişliği / sırası; tanımsız kolonlar gizlenir
    class procedure LoadLayout(AUoW: TUnitOfWork; const AViewName: string; AGrid: TDBGrid);
    // Yalnız oturum açmış kullanıcının kişiselleştirmesi (sys_user_grid_column); açık işlem varken yazılmaz
    class procedure SaveUserLayout(AUoW: TUnitOfWork; const AViewName: string; AGrid: TDBGrid);
    // sys_grid_filter koşulu + sys_grid_sort sıralaması eklenmiş SQL; sıralama yoksa ORDER BY id
    class function ApplyFilterAndSort(AUoW: TUnitOfWork; const AViewName, ASql: string): string;

    class function SaveStates(AGrid: TDBGrid): TArray<TGridColumnState>;
    class procedure RestoreStates(AGrid: TDBGrid; const AStates: TArray<TGridColumnState>);
    class procedure SetTitleStyle(AGrid: TDBGrid);
  end;

implementation

uses
  Vcl.Graphics, System.Classes, Logger, AppContext,
  SysGridColumn, SysGridColumn.Repository, SysGridFilter, SysGridFilter.Repository, SysGridSort, SysGridSort.Repository;

function IsConnected(AUoW: TUnitOfWork): Boolean;
begin
  Result := Assigned(AUoW) and (AUoW.Connection <> nil) and AUoW.Connection.Connected;
end;

function CurrentUserId: Int64;
begin
  Result := 0;
  if TAppContext.Instance.CurrentUser <> nil then
    Result := TAppContext.Instance.CurrentUser.GetUserId;
end;

class procedure TGridColumns.SetColumnProperty(AGrid: TDBGrid; const AFieldName: string; AWidth: Integer; const AColumnTitle: string);
var
  i: Integer;
begin
  for i := 0 to AGrid.Columns.Count - 1 do
    if SameText(AGrid.Columns[i].FieldName, AFieldName) then
    begin
      if AWidth <= 0 then
        AGrid.Columns[i].Visible := False
      else
        AGrid.Columns[i].Width := AWidth;
      if AColumnTitle <> '' then
        AGrid.Columns[i].Title.Caption := AColumnTitle;
      Break;
    end;
end;

class procedure TGridColumns.SetColumnTitle(AGrid: TDBGrid; const AFieldName, AColumnTitle: string);
var
  i: Integer;
begin
  for i := 0 to AGrid.Columns.Count - 1 do
    if SameText(AGrid.Columns[i].FieldName, AFieldName) then
    begin
      AGrid.Columns[i].Title.Caption := AColumnTitle;
      Break;
    end;
end;

class function TGridColumns.VisibleWidth(AGrid: TDBGrid): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to AGrid.Columns.Count - 1 do
    if AGrid.Columns[i].Visible then
    begin
      Inc(Result, AGrid.Columns[i].Width);
      if dgColLines in AGrid.Options then
        Inc(Result);
    end;
  if dgIndicator in AGrid.Options then
    Inc(Result, IndicatorWidth);
end;

class procedure TGridColumns.AutoPopulate(AUoW: TUnitOfWork; const AViewName: string; AGrid: TDBGrid);
var
  LRepo: ISysGridColumnRepository;
  LCols: TObjectList<TSysGridColumn>;
  LCol: TSysGridColumn;
  i: Integer;
begin
  if (AViewName = '') or (AGrid.Columns.Count = 0) or not IsConnected(AUoW) then
    Exit;

  LRepo := AUoW.GetRepository<TSysGridColumn, TSysGridColumnRepository> as ISysGridColumnRepository;
  if LRepo = nil then
    Exit;
  // Tabloda kayıt varsa otomatik ekleme asla yapılmaz
  if LRepo.HasTableColumns(AViewName) then
    Exit;

  LCols := TObjectList<TSysGridColumn>.Create(True);
  try
    for i := 0 to AGrid.Columns.Count - 1 do
    begin
      if AGrid.Columns[i].FieldName = '' then
        Continue;
      LCol := TSysGridColumn.Create;
      LCol.TableName := AViewName;
      LCol.ColumnName := AGrid.Columns[i].FieldName;
      LCol.ColumnOrder := AGrid.Columns[i].Index + 1;
      LCol.ColumnWidth := AGrid.Columns[i].Width;
      LCol.IsShow := AGrid.Columns[i].Visible;
      LCol.IsShowHelper := False;
      LCol.IsFetch := True;
      LCols.Add(LCol);
    end;

    if LCols.Count > 0 then
    begin
      LRepo.SaveColumns(AViewName, LCols);
      GLogger.InfoFmt('sys_grid_column: [%s] tablosu için %d kolon otomatik eklendi.', [AViewName, LCols.Count]);
    end;
  finally
    LCols.Free;
  end;
end;

class procedure TGridColumns.LoadLayout(AUoW: TUnitOfWork; const AViewName: string; AGrid: TDBGrid);
var
  LRepo: ISysGridColumnRepository;
  LColumns: TList<TSysGridColumn>;
  LCol: TSysGridColumn;
  LColMap: TDictionary<string, TColumn>;
  LDefined: TDictionary<string, Boolean>;
  LGridCol: TColumn;
  i, j: Integer;
  LUserId: Int64;
begin
  if (AViewName = '') or not IsConnected(AUoW) then
    Exit;

  LRepo := AUoW.GetRepository<TSysGridColumn, TSysGridColumnRepository> as ISysGridColumnRepository;
  if LRepo = nil then
    Exit;

  if not LRepo.HasTableColumns(AViewName) then
    AutoPopulate(AUoW, AViewName, AGrid);

  LUserId := CurrentUserId;
  if LUserId > 0 then
    LColumns := LRepo.LoadUserColumns(AViewName, LUserId)
  else
    LColumns := LRepo.LoadColumns(AViewName);

  try
    if LColumns.Count = 0 then
      Exit;

    LColMap := TDictionary<string, TColumn>.Create(AGrid.Columns.Count);
    LDefined := TDictionary<string, Boolean>.Create;
    try
      for i := 0 to AGrid.Columns.Count - 1 do
        LColMap.AddOrSetValue(LowerCase(AGrid.Columns[i].FieldName), AGrid.Columns[i]);
      for LCol in LColumns do
        LDefined.AddOrSetValue(LowerCase(LCol.ColumnName), True);

      // sys_grid_column'da tanımlı olmayan kolonlar gizlenir
      for i := 0 to AGrid.Columns.Count - 1 do
        if not LDefined.ContainsKey(LowerCase(AGrid.Columns[i].FieldName)) then
          AGrid.Columns[i].Visible := False;

      for LCol in LColumns do
      begin
        if not LColMap.TryGetValue(LowerCase(LCol.ColumnName), LGridCol) then
          Continue;
        LGridCol.Visible := LCol.IsShow;
        if LCol.IsShow and (LCol.ColumnWidth > 0) then
          LGridCol.Width := LCol.ColumnWidth;
      end;

      // Kolon nesneleri: sıra değiştikçe Columns[] indeksleri kayar, nesne üzerinden ilerlenir
      j := 0;
      for LCol in LColumns do
      begin
        if not LCol.IsShow or not LColMap.TryGetValue(LowerCase(LCol.ColumnName), LGridCol) then
          Continue;
        if not LGridCol.Visible then
          Continue;
        if LGridCol.Index <> j then
          LGridCol.Index := j;
        Inc(j);
      end;
    finally
      LDefined.Free;
      LColMap.Free;
    end;
  finally
    LColumns.Free;
  end;
end;

class procedure TGridColumns.SaveUserLayout(AUoW: TUnitOfWork; const AViewName: string; AGrid: TDBGrid);
var
  LRepo: ISysGridColumnRepository;
  LColumns: TObjectList<TSysGridColumn>;
  LCol: TSysGridColumn;
  i: Integer;
  LUserId: Int64;
begin
  if (AViewName = '') or not Assigned(AUoW) or AUoW.InTransaction then
    Exit;
  // Form kapanırken sys_grid_column sistem tablosu ezilmez
  LUserId := CurrentUserId;
  if LUserId <= 0 then
    Exit;

  LColumns := TObjectList<TSysGridColumn>.Create(True);
  try
    for i := 0 to AGrid.Columns.Count - 1 do
    begin
      LCol := TSysGridColumn.Create;
      LCol.TableName := AViewName;
      LCol.ColumnName := AGrid.Columns[i].FieldName;
      LCol.ColumnOrder := AGrid.Columns[i].Index;
      LCol.ColumnWidth := AGrid.Columns[i].Width;
      LCol.IsShow := AGrid.Columns[i].Visible;
      LColumns.Add(LCol);
    end;

    LRepo := AUoW.GetRepository<TSysGridColumn, TSysGridColumnRepository> as ISysGridColumnRepository;
    LRepo.SaveUserColumns(AViewName, LUserId, LColumns);
  finally
    LColumns.Free;
  end;
end;

class function TGridColumns.ApplyFilterAndSort(AUoW: TUnitOfWork; const AViewName, ASql: string): string;
var
  LFilterRepo: ISysGridFilterRepository;
  LSortRepo: ISysGridSortRepository;
  LFilter: TSysGridFilter;
  LSort: TSysGridSort;
  LContent: string;
begin
  Result := ASql;
  if (AViewName = '') or not IsConnected(AUoW) then
    Exit;

  try
    LFilterRepo := AUoW.GetRepository<TSysGridFilter, TSysGridFilterRepository> as ISysGridFilterRepository;
    if LFilterRepo <> nil then
    begin
      LFilter := LFilterRepo.LoadFilter(AViewName);
      if LFilter <> nil then
      try
        LContent := Trim(LFilter.FilterContent);
        if LContent <> '' then
        begin
          if Pos('WHERE', UpperCase(Result)) > 0 then
            Result := Result + ' AND (' + LContent + ')'
          else
            Result := Result + ' WHERE (' + LContent + ')';
        end;
      finally
        LFilter.Free;
      end;
    end;
  except
    on E: Exception do
      GLogger.WarningFmt('ApplyDynamicFilterAndSort (Filter) hatası [%s]: %s', [AViewName, E.Message]);
  end;

  try
    LSortRepo := AUoW.GetRepository<TSysGridSort, TSysGridSortRepository> as ISysGridSortRepository;
    if LSortRepo <> nil then
    begin
      LSort := LSortRepo.LoadSort(AViewName);
      if LSort <> nil then
      try
        LContent := Trim(LSort.SortContent);
        if (LContent <> '') and (Pos('ORDER BY', UpperCase(Result)) = 0) then
        begin
          if UpperCase(Copy(LContent, 1, 8)) = 'ORDER BY' then
            Result := Result + ' ' + LContent
          else
            Result := Result + ' ORDER BY ' + LContent;
        end;
      finally
        LSort.Free;
      end;
    end;
  except
    on E: Exception do
      GLogger.WarningFmt('ApplyDynamicFilterAndSort (Sort) hatası [%s]: %s', [AViewName, E.Message]);
  end;

  // Tanımlı sıralama yoksa satır sırası sabit kalsın (güncellenen kayıt yenilemede sona kaymasın)
  if Pos('ORDER BY', UpperCase(Result)) = 0 then
    Result := Result + ' ORDER BY id';
end;

class function TGridColumns.SaveStates(AGrid: TDBGrid): TArray<TGridColumnState>;
var
  i: Integer;
begin
  SetLength(Result, AGrid.Columns.Count);
  for i := 0 to AGrid.Columns.Count - 1 do
  begin
    Result[i].FieldName := AGrid.Columns[i].FieldName;
    Result[i].Width := AGrid.Columns[i].Width;
    Result[i].Visible := AGrid.Columns[i].Visible;
    Result[i].Caption := AGrid.Columns[i].Title.Caption;
  end;
end;

class procedure TGridColumns.RestoreStates(AGrid: TDBGrid; const AStates: TArray<TGridColumnState>);
var
  i, j, LIndex: Integer;
  LCol: TColumn;
begin
  AGrid.Columns.BeginUpdate;
  try
    LIndex := 0;
    for i := 0 to High(AStates) do
      for j := 0 to AGrid.Columns.Count - 1 do
        if SameText(AGrid.Columns[j].FieldName, AStates[i].FieldName) then
        begin
          LCol := AGrid.Columns[j];
          LCol.Visible := AStates[i].Visible;
          LCol.Width := AStates[i].Width;
          LCol.Title.Caption := AStates[i].Caption;
          if LCol.Index <> LIndex then
            LCol.Index := LIndex;
          Inc(LIndex);
          Break;
        end;
  finally
    AGrid.Columns.EndUpdate;
  end;
end;

class procedure TGridColumns.SetTitleStyle(AGrid: TDBGrid);
var
  i: Integer;
begin
  for i := 0 to AGrid.Columns.Count - 1 do
  begin
    AGrid.Columns[i].Title.Font.Style := [fsBold];
    AGrid.Columns[i].Title.Alignment := taCenter;
  end;
end;

end.
