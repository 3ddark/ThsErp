unit MetaProvider;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.RTTI,
  System.TypInfo, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  FireDAC.Stan.Param, EntityAttributes, Entity;

type
  TPropertyMeta = class
  public
    Name: string;
    ColumnName: string;
    DisplayLabel: string;
    Required: Boolean;
    MaxLength: Integer;
    DataType: TRttiType;
    PropertyType: TRttiType;
    IsEnum: Boolean;
    IsBoolean: Boolean;
    IsLookup: Boolean;
  end;

  TEntityMeta = class
  public
    Properties: TDictionary<string, TPropertyMeta>;
    constructor Create;
    destructor Destroy; override;
  end;

  TMetaProviderManager = class
  private
    class var FCache: TDictionary<string, TEntityMeta>;  // TObject yerine string key
    class var FConnection: TFDConnection;
    class var FCtx: TRttiContext;  // class var olmalı
  public
    class constructor Create;
    class destructor Destroy;
    class procedure SetConnection(AConnection: TFDConnection);
    class function GetMeta(AClass: TClass): TEntityMeta; overload;  // TClass parametresi
    class function GetMetaFromInstance(AInstance: TObject): TEntityMeta; overload;  // Instance için
  end;

implementation

constructor TEntityMeta.Create;
begin
  inherited Create;
  Properties := TDictionary<string, TPropertyMeta>.Create;
end;

destructor TEntityMeta.Destroy;
var
  pMeta: TPropertyMeta;
begin
  for pMeta in Properties.Values do
    pMeta.Free;
  Properties.Free;
  inherited;
end;

class constructor TMetaProviderManager.Create;
begin
  FCache := TDictionary<string, TEntityMeta>.Create;
  FCtx := TRttiContext.Create;
end;

class destructor TMetaProviderManager.Destroy;
var
  meta: TEntityMeta;
begin
  for meta in FCache.Values do
    meta.Free;
  FCache.Free;
  FCtx.Free;
end;

class procedure TMetaProviderManager.SetConnection(AConnection: TFDConnection);
begin
  FConnection := AConnection;
end;

class function TMetaProviderManager.GetMetaFromInstance(AInstance: TObject): TEntityMeta;
begin
  if AInstance = nil then
    Exit(nil);
  Result := GetMeta(AInstance.ClassType);
end;

class function TMetaProviderManager.GetMeta(AClass: TClass): TEntityMeta;
var
  meta: TEntityMeta;
  rType: TRttiType;
  prop: TRttiProperty;
  pMeta: TPropertyMeta;
  colAttr: Column;
  maxAttr: MaxLength;
  reqAttr: Required;
  tableAttr: TableAttribute;
  tableName, columnName, cacheKey: string;
  qry: TFDQuery;
begin
  if AClass = nil then
    Exit(nil);

  // Cache key olarak sınıf adını kullan
  cacheKey := AClass.ClassName;

  if FCache.TryGetValue(cacheKey, meta) then
    Exit(meta);

  meta := TEntityMeta.Create;
  FCache.Add(cacheKey, meta);

  // TClass'tan TRttiType al
  rType := FCtx.GetType(AClass);

  if rType = nil then
  begin
    FCache.Remove(cacheKey);
    meta.Free;
    Exit(nil);
  end;

  // Table attribute'dan tablo adını al
  tableAttr := rType.GetAttribute<TableAttribute>;
  if Assigned(tableAttr) then
    tableName := tableAttr.Name
  else
    tableName := AClass.ClassName.ToLower;

  for prop in rType.GetProperties do
  begin
    pMeta := TPropertyMeta.Create;
    pMeta.Name := prop.Name;
    pMeta.PropertyType := prop.PropertyType;
    pMeta.DataType := prop.PropertyType;
    pMeta.IsEnum := prop.PropertyType.TypeKind = TTypeKind.tkEnumeration;
    pMeta.IsBoolean := SameText(prop.PropertyType.Name, 'Boolean');
    pMeta.ColumnName := prop.Name; // Varsayılan değer

    // Column Attribute
    colAttr := prop.GetAttribute<Column>;
    if Assigned(colAttr) then
    begin
      pMeta.ColumnName := colAttr.Name;
      columnName := colAttr.Name;

      // DisplayLabel DB'den çek
      if Assigned(FConnection) then
      begin
        qry := TFDQuery.Create(nil);
        try
          qry.Connection := FConnection;
          qry.SQL.Text :=
            'SELECT column_label FROM sys_grid_column_titles ' +
            'WHERE table_name = :tableName AND column_name = :colName AND lng_code=:lng_code';
          qry.ParamByName('tableName').AsString := tableName;
          qry.ParamByName('colName').AsString := columnName;
          qry.ParamByName('lng_code').AsString := 'tr';
          qry.Open;

          if not qry.IsEmpty then
            pMeta.DisplayLabel := qry.FieldByName('column_label').AsString
          else
            pMeta.DisplayLabel := prop.Name; // Fallback
        finally
          qry.Free;
        end;
      end
      else
        pMeta.DisplayLabel := prop.Name;
    end
    else
      pMeta.DisplayLabel := prop.Name;

    // MaxLength Attribute
    maxAttr := prop.GetAttribute<MaxLength>;
    if Assigned(maxAttr) then
      pMeta.MaxLength := maxAttr.MaxLength;

    // Required Attribute
    reqAttr := prop.GetAttribute<Required>;
    pMeta.Required := Assigned(reqAttr);

    meta.Properties.Add(pMeta.Name, pMeta);
  end;

  Result := meta;
end;

end.
