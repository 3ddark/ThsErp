unit EntityMetaProvider;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Data.DB,
  System.Rtti, System.Variants, System.StrUtils,
  ZConnection, ZDbcIntfs, ZDbcMetadata, ZDbcResultSet;

type
  TFieldMeta = record
    FieldName: string;
    Required: Boolean;
    MaxLength: Integer;
    DataTypeInt: Integer; // SQL tipi kodu
    DataTypeName: string; // Tip adý string olarak
  end;

  TEntityMetaProvider = class
  private
    class var FFieldMetaCache: TDictionary<string, TArray<TFieldMeta>>;
    class var Conn: TZConnection;
    class constructor Create;
    class destructor Destroy;
  public
    class procedure SetConnection(AConnection: TZConnection);
    class function GetFieldMeta(const TableName: string): TArray<TFieldMeta>;
    class procedure ValidateEntity(AEntity: TObject; const MetaArray: TArray<TFieldMeta>);
  end;

implementation

class constructor TEntityMetaProvider.Create;
begin
  FFieldMetaCache := TDictionary<string, TArray<TFieldMeta>>.Create;
end;

class destructor TEntityMetaProvider.Destroy;
begin
  FFieldMetaCache.Free;
end;

class function TEntityMetaProvider.GetFieldMeta(const TableName: string): TArray<TFieldMeta>;
var
  Metadata: IZDatabaseMetadata;
  ResultSet: IZResultSet;
  FieldMetaList: TList<TFieldMeta>;
  FM: TFieldMeta;
  NullableInt: Integer;
begin
  if FFieldMetaCache.ContainsKey(TableName) then
    Exit(FFieldMetaCache[TableName]);

  if not Assigned(Conn) then
    raise Exception.Create('Veri tabaný baðlantýsý atanmadý! Önce SetConnection çaðrýlmalýdýr.');

  FieldMetaList := TList<TFieldMeta>.Create;
  try
    Metadata := Conn.DbcConnection.GetMetadata;
    ResultSet := Metadata.GetColumns('', '', UpperCase(TableName), '');
    while ResultSet.Next do
    begin
      FM.FieldName := ResultSet.GetStringByName('COLUMN_NAME');
      NullableInt := ResultSet.GetIntByName('NULLABLE'); // 0 = NOT NULL, 1 = NULL olabilir
      FM.Required := (NullableInt = 0);
      FM.MaxLength := ResultSet.GetIntByName('COLUMN_SIZE');
      FM.DataTypeInt := ResultSet.GetIntByName('DATA_TYPE');
      FM.DataTypeName := ResultSet.GetStringByName('DATA_TYPE');
      FieldMetaList.Add(FM);
    end;

    Result := FieldMetaList.ToArray;
    FFieldMetaCache.Add(TableName, Result);
  finally
    FieldMetaList.Free;
  end;
end;

class procedure TEntityMetaProvider.SetConnection(AConnection: TZConnection);
begin
  Conn := AConnection;
end;

class procedure TEntityMetaProvider.ValidateEntity(AEntity: TObject; const MetaArray: TArray<TFieldMeta>);
var
  ctx: TRttiContext;
  rType: TRttiType;
  prop: TRttiProperty;
  val: TValue;
  FM: TFieldMeta;
  propNameLower: string;

  function IsEmptyValue(const AVal: TValue): Boolean;
  begin
    if AVal.IsEmpty then
      Exit(True);

    case AVal.Kind of
      tkString, tkLString, tkWString, tkUString:
        Exit(Trim(AVal.AsString) = '');
      tkInteger, tkInt64:
        Exit(AVal.AsInteger = 0);
      tkFloat:
        Exit(AVal.AsExtended = 0);
      tkVariant:
        Exit(VarIsNull(AVal.AsVariant) or VarIsEmpty(AVal.AsVariant));
      else
        Exit(False);
    end;
  end;

  procedure RaiseError(const Msg: string);
  begin
    raise Exception.Create(Msg);
  end;

begin
  ctx := TRttiContext.Create;
  try
    rType := ctx.GetType(AEntity.ClassType);

    for FM in MetaArray do
    begin
      if FM.FieldName = 'id' then
        Continue;

      propNameLower := LowerCase(FM.FieldName);
      prop := rType.GetProperty(FM.FieldName);

      if (prop = nil) or not prop.IsReadable then
        Continue;

      val := prop.GetValue(AEntity);

      if FM.Required and IsEmptyValue(val) then
        RaiseError(Format('"%s" alaný zorunludur.', [FM.FieldName]));

      if  (FM.MaxLength > 0)
      and (val.Kind in [tkString, tkLString, tkWString, tkUString])
      and (Length(val.AsString) > FM.MaxLength)
      then
        RaiseError(Format('"%s" alaný en fazla %d karakter olabilir. ' + sLineBreak +
                          'Girilen deðer:' + sLineBreak + '%s', [FM.FieldName, FM.MaxLength, val.AsString]));

      if FM.DataTypeName <> '' then
      begin
        if (LowerCase(FM.DataTypeName) = 'int')
        or (LowerCase(FM.DataTypeName) = 'integer')
        or (LowerCase(FM.DataTypeName) = 'smallint')
        or (LowerCase(FM.DataTypeName) = 'bigint')
        then
        begin
          if not (val.Kind in [tkInteger, tkInt64]) then
            RaiseError(Format('"%s" alaný tamsayý olmalýdýr.', [FM.FieldName]));
        end
        else
        if (LowerCase(FM.DataTypeName) = 'varchar')
        or (LowerCase(FM.DataTypeName) = 'nvarchar')
        or (LowerCase(FM.DataTypeName) = 'char')
        or (LowerCase(FM.DataTypeName) = 'text')
        then
        begin
          if not (val.Kind in [tkString, tkLString, tkWString, tkUString]) then
            RaiseError(Format('"%s" alaný metin (string) olmalýdýr.', [FM.FieldName]));
        end
        else
        if (LowerCase(FM.DataTypeName) = 'date')
        or (LowerCase(FM.DataTypeName) = 'datetime')
        or (LowerCase(FM.DataTypeName) = 'timestamp')
        then
        begin
          if not (val.Kind = tkFloat) then
            RaiseError(Format('"%s" alaný tarih/saat olmalýdýr.', [FM.FieldName]));
        end;
      end;
    end;

  finally
    ctx.Free;
  end;
end;

end.
