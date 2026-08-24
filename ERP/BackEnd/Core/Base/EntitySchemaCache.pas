unit EntitySchemaCache;

(*
  EntitySchemaCache.pas
  ─────────────────────────────────────────────────────────────────────────────
  Repository'nin Add / Update / Find operasyonlarında her çağrıda tekrar eden
  RTTI taramalarını ortadan kaldıran önbellek katmanı.

  Önbelleklenen bilgiler (TEntitySchema)
  ──────────────────────────────────────
  • Tablo ve şema adı  (TableAttribute)
  • Primary key kolon ve property adı
  • Sütun listesi: TColumnSchema — TRttiProperty referansı dahil
  • Insert / Update / Select için önceden oluşturulmuş SQL metinleri

  Thread güvenliği
  ────────────────
  TCriticalSection + double-checked locking.
  TRttiContext class var olarak tutulur → app ömrü boyunca geçerli property ref.

  Kullanım (Repository içinde)
  ────────────────────────────
    schema := TEntitySchemaCache.GetSchema(T);

    // SQL doğrudan kullanılır — her çağrıda yeniden üretilmez
    query.SQL.Text := schema.InsertSQL;

    // Property erişimi: col.Prop.GetValue(entity)
    for col in schema.InsertColumns do
      query.ParamByName(col.ColumnName).Value :=
        col.Prop.GetValue(TObject(AModel)).AsVariant;
*)

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  System.Rtti, System.TypInfo, System.SyncObjs,
  EntityAttributes;

type
  TColumnSchema = class
  public
    PropertyName    : string;
    ColumnName      : string;

    // Tip bilgisi (TValue dönüşümü için)
    TypeKind        : TTypeKind;
    TypeName        : string;      // 'Boolean', 'TDateTime', vb. için
    TypeHandle      : PTypeInfo;   // TValue.FromOrdinal ve TValue.From<T> için

    // Kısıtlamalar
    IsPrimaryKey    : Boolean;
    IsAutoIncrement : Boolean;
    IsNotNull       : Boolean;
    IsWritable      : Boolean;
    IsReadable      : Boolean;

    // SQL öbekleri için filtreler
    IncludeInInsert : Boolean;     // not AutoIncrement
    IncludeInUpdate : Boolean;     // not PK, not AutoIncrement

    Prop            : TRttiProperty;
  end;

  TEntitySchema = class
  private
    FCachedInsertCols : TArray<TColumnSchema>;
    FCachedUpdateCols : TArray<TColumnSchema>;
  public
    EntityClass   : TClass;
    TableName     : string;       // şema olmadan: 'sys_city'
    FullTableName : string;       // şema ile: 'public.sys_city'
    PKColumn      : string;       // 'id'
    PKProperty    : string;       // 'Id'

    Columns       : TObjectList<TColumnSchema>;
    ByProperty    : TDictionary<string, TColumnSchema>;
    ByColumn      : TDictionary<string, TColumnSchema>;

    SelectSQL     : string;
    InsertSQL     : string;
    UpdateSQL     : string;

    constructor Create;
    destructor  Destroy; override;

    function InsertColumns : TArray<TColumnSchema>;
    function UpdateColumns : TArray<TColumnSchema>;
  end;

  TEntitySchemaCache = class
  strict private
    class var FLock  : TCriticalSection;
    class var FCache : TObjectDictionary<string, TEntitySchema>;
    class var FCtx   : TRttiContext;

    class function CacheKey(AClass: TClass): string; static; inline;
    class function Build(AClass: TClass): TEntitySchema; static;
    class procedure BuildSQLs(S: TEntitySchema); static;
  public
    class constructor Create;
    class destructor  Destroy;

    class function GetSchema(AClass: TClass): TEntitySchema; overload;

    class procedure Invalidate; static;
  end;

implementation

constructor TEntitySchema.Create;
begin
  inherited;
  Columns    := TObjectList<TColumnSchema>.Create(True);
  ByProperty := TDictionary<string, TColumnSchema>.Create;
  ByColumn   := TDictionary<string, TColumnSchema>.Create;
end;

destructor TEntitySchema.Destroy;
begin
  ByColumn.Free;
  ByProperty.Free;
  Columns.Free;
  inherited;
end;

function TEntitySchema.InsertColumns: TArray<TColumnSchema>;
var col: TColumnSchema; lst: TList<TColumnSchema>;
begin
  if Length(FCachedInsertCols) > 0 then
    Exit(FCachedInsertCols);

  lst := TList<TColumnSchema>.Create;
  try
    for col in Columns do
      if col.IncludeInInsert then lst.Add(col);
    FCachedInsertCols := lst.ToArray;
  finally
    lst.Free;
  end;
  Result := FCachedInsertCols;
end;

function TEntitySchema.UpdateColumns: TArray<TColumnSchema>;
var col: TColumnSchema; lst: TList<TColumnSchema>;
begin
  if Length(FCachedUpdateCols) > 0 then
    Exit(FCachedUpdateCols);

  lst := TList<TColumnSchema>.Create;
  try
    for col in Columns do
      if col.IncludeInUpdate then lst.Add(col);
    FCachedUpdateCols := lst.ToArray;
  finally
    lst.Free;
  end;
  Result := FCachedUpdateCols;
end;

class constructor TEntitySchemaCache.Create;
begin
  FLock  := TCriticalSection.Create;
  FCache := TObjectDictionary<string, TEntitySchema>.Create([doOwnsValues]);
  FCtx   := TRttiContext.Create;
end;

class destructor TEntitySchemaCache.Destroy;
begin
  FCache.Free;
  FLock.Free;
  FCtx.Free;
end;

class function TEntitySchemaCache.CacheKey(AClass: TClass): string;
begin
  Result := AClass.UnitName + '.' + AClass.ClassName;
end;

class function TEntitySchemaCache.GetSchema(AClass: TClass): TEntitySchema;
var
  key : string;
  s   : TEntitySchema;
begin
  if AClass = nil then Exit(nil);
  key := CacheKey(AClass);

  if FCache.TryGetValue(key, s) then Exit(s);

  FLock.Enter;
  try
    if FCache.TryGetValue(key, s) then Exit(s);

    s := Build(AClass);
    FCache.Add(key, s);
    Result := s;
  finally
    FLock.Leave;
  end;
end;

class procedure TEntitySchemaCache.Invalidate;
begin
  FLock.Enter;
  try
    FCache.Clear;
  finally
    FLock.Leave;
  end;
end;

class function TEntitySchemaCache.Build(AClass: TClass): TEntitySchema;
var
  rType     : TRttiType;
  prop      : TRttiProperty;
  attr      : TCustomAttribute;
  colAttr   : Column;
  tableAttr : TableAttribute;
  col       : TColumnSchema;
  skipProp  : Boolean;
  schName   : string;
begin
  Result := TEntitySchema.Create;
  Result.EntityClass := AClass;

  rType := FCtx.GetType(AClass);
  if not Assigned(rType) then Exit;

  Result.TableName  := AClass.ClassName.ToLower;
  schName := '';
  for attr in rType.GetAttributes do
    if attr is TableAttribute then
    begin
      tableAttr := TableAttribute(attr);
      if tableAttr.Name   <> '' then Result.TableName := tableAttr.Name;
      if tableAttr.Schema <> '' then schName          := tableAttr.Schema;
      Break;
    end;

  if schName <> '' then
    Result.FullTableName := schName + '.' + Result.TableName
  else
    Result.FullTableName := Result.TableName;

  for prop in rType.GetProperties do
  begin
    if prop.PropertyType.TypeKind = tkClass then Continue;

    colAttr  := nil;
    skipProp := False;

    for attr in prop.GetAttributes do
    begin
      if (attr is NotMapped)       or
         (attr is HasManyAttribute) or
         (attr is BelongsToAttribute) or
         (attr is HasOneAttribute)
      then begin skipProp := True; Break; end;

      if attr is Column then
        colAttr := Column(attr);
    end;

    if skipProp or (colAttr = nil) then Continue;

    col := TColumnSchema.Create;
    col.PropertyName    := prop.Name;
    col.ColumnName      := colAttr.Name;
    col.TypeKind        := prop.PropertyType.TypeKind;
    col.TypeName        := prop.PropertyType.Name;
    col.TypeHandle      := prop.PropertyType.Handle;
    col.IsPrimaryKey    := colAttr.IsPrimaryKey;
    col.IsAutoIncrement := colAttr.IsAutoIncrement;
    col.IsNotNull       := colAttr.IsNotNull;
    col.IsWritable      := prop.IsWritable;
    col.IsReadable      := prop.IsReadable;
    col.Prop            := prop;

    col.IncludeInInsert := prop.IsReadable and not colAttr.IsAutoIncrement;

    col.IncludeInUpdate := prop.IsReadable
                           and not colAttr.IsPrimaryKey
                           and not colAttr.IsAutoIncrement;

    if colAttr.IsPrimaryKey then
    begin
      Result.PKColumn   := colAttr.Name;
      Result.PKProperty := prop.Name;
    end;

    Result.Columns.Add(col);
    Result.ByProperty.AddOrSetValue(prop.Name,      col);
    Result.ByColumn.AddOrSetValue  (colAttr.Name,   col);
  end;

  BuildSQLs(Result);
end;

class procedure TEntitySchemaCache.BuildSQLs(S: TEntitySchema);
var
  col            : TColumnSchema;
  selCols        : TStringBuilder;
  insCols, insVals, setSql: TStringBuilder;
  firstSel       : Boolean;
begin
  selCols  := TStringBuilder.Create;
  insCols  := TStringBuilder.Create;
  insVals  := TStringBuilder.Create;
  setSql   := TStringBuilder.Create;
  firstSel := True;
  try
    for col in S.Columns do
    begin
      if not firstSel then selCols.Append(', ');
      selCols.Append(col.ColumnName);
      firstSel := False;

      if col.IncludeInInsert then
      begin
        if insCols.Length > 0 then
        begin
          insCols.Append(', ');
          insVals.Append(', ');
        end;
        insCols.Append(col.ColumnName);
        insVals.Append(':').Append(col.ColumnName);
      end;

      if col.IncludeInUpdate then
      begin
        if setSql.Length > 0 then setSql.Append(', ');
        setSql.Append(col.ColumnName).Append(' = :').Append(col.ColumnName);
      end;
    end;

    if selCols.Length = 0 then
      S.SelectSQL := 'SELECT * FROM ' + S.FullTableName
    else
      S.SelectSQL := 'SELECT ' + selCols.ToString + ' FROM ' + S.FullTableName;

    if (insCols.Length > 0) and (S.PKColumn <> '') then
      S.InsertSQL := Format('INSERT INTO %s (%s) VALUES (%s) RETURNING %s',
        [S.FullTableName, insCols.ToString, insVals.ToString, S.PKColumn]);

    if (setSql.Length > 0) and (S.PKColumn <> '') then
      S.UpdateSQL := Format('UPDATE %s SET %s WHERE %s = :pk_value',
        [S.FullTableName, setSql.ToString, S.PKColumn]);

  finally
    selCols.Free;
    insCols.Free;
    insVals.Free;
    setSql.Free;
  end;
end;

end.
