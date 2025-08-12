unit EntityMetaProvider;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Data.DB,
  System.Rtti, System.Variants, System.StrUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFieldMeta = record
    FieldName: string;
    Required: Boolean;
    MaxLength: Integer;
    DataTypeInt: Integer; // SQL tipi kodu
    DataTypeName: string; // Tip adı string olarak
  end;

  TEntityMetaProvider = class
  private
    class var FFieldMetaCache: TDictionary<string, TArray<TFieldMeta>>;
    class var Conn: TFDConnection;
    class constructor Create;
    class destructor Destroy;
  public
    class procedure SetConnection(AConnection: TFDConnection);
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
  MIQuery: TFDMetaInfoQuery;
  FieldMetaList: TList<TFieldMeta>;
  FM: TFieldMeta;
begin
  FieldMetaList := TList<TFieldMeta>.Create;
  try
    MIQuery := TFDMetaInfoQuery.Create(nil);
    try
      MIQuery.Connection := Conn;
      MIQuery.MetaInfoKind := mkTableFields;
      MIQuery.ObjectName := TableName;
      MIQuery.Open;
      while not MIQuery.Eof do
      begin
        FM.FieldName   := MIQuery.FieldByName('COLUMN_NAME').AsString;
        FM.Required    := MIQuery.FieldByName('NULLABLE').AsInteger = 0;
        FM.MaxLength   := MIQuery.FieldByName('COLUMN_SIZE').AsInteger;
        FM.DataTypeName := MIQuery.FieldByName('COLUMN_TYPENAME').AsString;
        FM.DataTypeInt := MIQuery.FieldByName('COLUMN_DATATYPE').AsInteger;

        FieldMetaList.Add(FM);
        MIQuery.Next;
      end;
    finally
      MIQuery.Free;
    end;

    Result := FieldMetaList.ToArray;
  finally
    FieldMetaList.Free;
  end;
end;

class procedure TEntityMetaProvider.SetConnection(AConnection: TFDConnection);
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
        RaiseError(Format('"%s" alanı zorunludur.', [FM.FieldName]));

      if  (FM.MaxLength > 0)
      and (val.Kind in [tkString, tkLString, tkWString, tkUString])
      and (Length(val.AsString) > FM.MaxLength)
      then
        RaiseError(Format('"%s" alanı en fazla %d karakter olabilir. ' + sLineBreak +
                          'Girilen değer:' + sLineBreak + '%s', [FM.FieldName, FM.MaxLength, val.AsString]));

      if FM.DataTypeName <> '' then
      begin
        if (LowerCase(FM.DataTypeName) = 'int')
        or (LowerCase(FM.DataTypeName) = 'integer')
        or (LowerCase(FM.DataTypeName) = 'smallint')
        or (LowerCase(FM.DataTypeName) = 'bigint')
        then
        begin
          if not (val.Kind in [tkInteger, tkInt64]) then
            RaiseError(Format('"%s" alanı tamsayı olmalıdır.', [FM.FieldName]));
        end
        else
        if (LowerCase(FM.DataTypeName) = 'varchar')
        or (LowerCase(FM.DataTypeName) = 'nvarchar')
        or (LowerCase(FM.DataTypeName) = 'char')
        or (LowerCase(FM.DataTypeName) = 'text')
        then
        begin
          if not (val.Kind in [tkString, tkLString, tkWString, tkUString]) then
            RaiseError(Format('"%s" alanı metin (string) olmalıdır.', [FM.FieldName]));
        end
        else
        if (LowerCase(FM.DataTypeName) = 'date')
        or (LowerCase(FM.DataTypeName) = 'datetime')
        or (LowerCase(FM.DataTypeName) = 'timestamp')
        then
        begin
          if not (val.Kind = tkFloat) then
            RaiseError(Format('"%s" alanı tarih/saat olmalıdır.', [FM.FieldName]));
        end;
      end;
    end;

  finally
    ctx.Free;
  end;
end;

end.
