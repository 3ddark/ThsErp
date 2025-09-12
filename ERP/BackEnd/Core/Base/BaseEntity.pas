unit BaseEntity;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Variants,
  System.StrUtils, System.DateUtils, Data.DB,
  System.Generics.Collections, System.Rtti, System.TypInfo;

type
  IEntity = interface;

  IEntityField = interface
    ['{2AD4AD6F-BCEA-4B74-BF33-02F894B63A6B}']
    function GetFieldName: string;
    procedure SetFieldName(const Value: string);
    procedure SetOwnerEntity(const Value: IEntity);
    function GetOwnerEntity: IEntity;
    procedure ValueFirstSet(const AValue: TValue);

    function FieldType: TFieldType;
    function AsString: string;
    function AsInteger: Integer;
    function AsInt64: Int64;
    function AsFloat: Double;
    function AsBoolean: Boolean;
    function AsDateTime: TDateTime;

    property FieldName: string read GetFieldName write SetFieldName;
    property OwnerEntity: IEntity read GetOwnerEntity write SetOwnerEntity;
  end;

  IEntity = interface
    ['{E7D242C9-BD12-48FB-8D12-883B52EA0347}']
    procedure SetField(Index: Integer; const Value: IEntityField);
    function GetField(Index: Integer): IEntityField;
    function GetFields: TList<IEntityField>;
    procedure SetFields(const Value: TList<IEntityField>);
    function GetFieldByName(AFieldName: string): IEntityField;
    function TableName: string;

    property Field[Index: Integer]: IEntityField read GetField write SetField; default;
    property Fields: TList<IEntityField> read GetFields write SetFields;
  end;

  TableNameAttribute = class(TCustomAttribute)
  private
    FName: string;
  public
    constructor Create(const AName: string);
    property Name: string read FName;
  end;

  TEntityField<T> = class(TInterfacedObject, IEntityField)
  private
    FValue: T;
    FOldValue: T;
    FFieldName: string;
    FOwnerEntity: IEntity;
    procedure SetOldValue(const AValue: T);
    procedure SetValue(const AValue: T);
    procedure SetFieldName(const Value: string);
    procedure SetOwnerEntity(const Value: IEntity);
    function GetFieldName: string;
    function GetOldValue: T;
    function GetOwnerEntity: IEntity;
    function GetValue: T;
  public
    property Value: T read GetValue write SetValue;
    property OldValue: T read GetOldValue write SetOldValue;
    property FieldName: string read GetFieldName write SetFieldName;
    property OwnerEntity: IEntity read GetOwnerEntity write SetOwnerEntity;

    constructor Create(AOwnerEntity: IEntity; AFieldName: string);

    procedure ValueFirstSet(const AValue: TValue);
    function ValueIsChanged: Boolean;

    function AsParamName: string;
    function AsQuotedStr: string;
    function QryName: string;

    function FieldType: TFieldType;
    function AsString: string;
    function AsInteger: Integer;
    function AsInt64: Int64;
    function AsFloat: Double;
    function AsBoolean: Boolean;
    function AsDateTime: TDateTime;
  end;

  TEntity = class(TInterfacedObject, IEntity)
  private
    FId: TEntityField<Integer>;
    FFields: TList<IEntityField>;
    procedure SetField(Index: Integer; const Value: IEntityField);
    function GetField(Index: Integer): IEntityField;
    function GetFields: TList<IEntityField>;
    procedure SetFields(const Value: TList<IEntityField>);
  public
    property Id: TEntityField<Integer> read FId write FId;
    property Field[Index: Integer]: IEntityField read GetField write SetField; default;
    property Fields: TList<IEntityField> read GetFields write SetFields;

    constructor Create; virtual;
    destructor Destroy; override;

    function CallCreateMethod<T>: T;

    function TableName: string;

    function GetFieldByName(AFieldName: string): IEntityField;

    procedure ClearEntity<T: class>(ASrc: T);
    function CloneEntity<T: TEntity, constructor>(ASrc: T): T;
  end;

implementation

uses SharedFormTypes, TableNameService;

constructor TEntityField<T>.Create(AOwnerEntity: IEntity; AFieldName: string);
begin
  OwnerEntity := AOwnerEntity;
  FFieldName := AFieldName;

  OwnerEntity.Fields.Add(Self);
end;

function TEntityField<T>.FieldType: TFieldType;
var
  TypeInfo: PTypeInfo;
  LTypeName: string;
begin
  TypeInfo := System.TypeInfo(T);
  LTypeName := string(TypeInfo.Name);

  if SameText(LTypeName, 'string')
  or SameText(LTypeName, 'AnsiString')
  then  Exit(ftString);
  if SameText(LTypeName, 'WideString') then Exit(ftWideString);
  if SameText(LTypeName, 'Byte') then Exit(ftByte);
  if SameText(LTypeName, 'UInt8') then Exit(ftByte);
  if SameText(LTypeName, 'ShortInt') then Exit(ftShortint);
  if SameText(LTypeName, 'Word') then Exit(ftWord);
  if SameText(LTypeName, 'UInt16') then Exit(ftWord);
  if SameText(LTypeName, 'SmallInt') then Exit(ftSmallint);
  if SameText(LTypeName, 'Integer') then Exit(ftInteger);
  if SameText(LTypeName, 'Cardinal') then Exit(ftInteger);
  if SameText(LTypeName, 'UInt32') then Exit(ftInteger);
  if SameText(LTypeName, 'LongInt') then Exit(ftInteger);
  if SameText(LTypeName, 'LongWord') then Exit(ftLongWord);
  if SameText(LTypeName, 'Int64') then Exit(ftLargeint);
  if SameText(LTypeName, 'UInt64') then Exit(ftLargeint);
  if SameText(LTypeName, 'Boolean') then Exit(ftBoolean);
  if SameText(LTypeName, 'LongBool') then Exit(ftBoolean);
  if SameText(LTypeName, 'Double') then Exit(ftFloat);
  if SameText(LTypeName, 'Extended') then Exit(ftFloat);
  if SameText(LTypeName, 'Double') then Exit(ftFloat);
  if SameText(LTypeName, 'Single') then Exit(ftFloat);
  if SameText(LTypeName, 'Currency') then Exit(ftCurrency);
  Exit(ftUnknown);
{
  case TypeInfo.Kind of
    tkString, tkLString, tkWString, tkUString:
      Exit(ftString);
    tkChar, tkWChar:
      Exit(ftFixedChar);
    tkInteger:
      begin
        // Integer boyutlarına göre daha detaylı kontrol
        case SizeOf(T) of
          1: Exit(ftByte);      // Byte, ShortInt
          2: Exit(ftSmallInt);  // Word, SmallInt
          4: Exit(ftInteger);   // Integer, Cardinal
        else
          Exit(ftInteger);
        end;
      end;
    tkInt64:
      Exit(ftLargeInt);
    tkFloat:
      begin
        // Önce özel tarih tiplerini kontrol et
        if SameText(string(TypeInfo.Name), 'TDateTime') then
          Exit(ftDateTime);
        if SameText(string(TypeInfo.Name), 'TDate') then
          Exit(ftDate);
        if SameText(string(TypeInfo.Name), 'TTime') then
          Exit(ftTime);

        // Float alt tiplerini kontrol et
        case GetTypeData(TypeInfo)^.FloatType of
          System.TypInfo.ftSingle: Exit(ftFloat);
          System.TypInfo.ftDouble: Exit(ftFloat);
          System.TypInfo.ftExtended: Exit(ftFloat);
          System.TypInfo.ftCurr: Exit(ftCurrency);
          System.TypInfo.ftComp: Exit(ftFloat);
        else
          Exit(ftFloat);
        end;
      end;
    tkEnumeration:
      begin
        // Boolean özel kontrolü
        if SameText(string(TypeInfo.Name), 'Boolean') then
          Exit(ftBoolean);
        // Diğer enum'ları string olarak sakla
        Exit(ftString);
      end;
    tkVariant:
      Exit(ftVariant);
    tkArray:
      Exit(ftArray);
    tkDynArray:
      Exit(ftArray);
    tkRecord:
      begin
        // Record tiplerini kontrol et (GUID, TTimeStamp gibi)
        if SameText(string(TypeInfo.Name), 'TGUID') then
          Exit(ftGuid);
        if SameText(string(TypeInfo.Name), 'TTimeStamp') then
          Exit(ftTimeStamp);
        // Diğer record'ları blob olarak sakla
        Exit(ftBlob);
      end;
    tkClass:
      Exit(ftBlob);
    tkInterface:
      Exit(ftInterface);
    tkPointer:
      Exit(ftBlob);
    tkSet:
      Exit(ftString); // Set'leri string olarak sakla
  else
    Exit(ftUnknown);
  end;
}
end;

function TEntityField<T>.GetFieldName: string;
begin
  Result := FFieldName;
end;

function TEntityField<T>.GetOldValue: T;
begin
  Result := FOldValue;
end;

function TEntityField<T>.GetOwnerEntity: IEntity;
begin
  Result := FOwnerEntity;
end;

function TEntityField<T>.GetValue: T;
begin
  Result := FValue;
end;

function TEntityField<T>.QryName: string;
begin
  Result := Self.OwnerEntity.TableName + '.' + Self.FFieldName;
end;

function TEntityField<T>.AsParamName: string;
begin
  Result := 'p_' + Self.FieldName;
end;

function TEntityField<T>.AsQuotedStr: string;
begin
  if TypeInfo(T) = TypeInfo(string) then
    Result := QuotedStr(TValue.From<T>(Value).ToString)
  else
    Result := TValue.From<T>(FValue).ToString;
end;

function TEntityField<T>.AsString: string;
var
  ValueVariant: Variant;
  TypeInfo: PTypeInfo;
begin
  TypeInfo := System.TypeInfo(T);

  case TypeInfo.Kind of
    tkInteger, tkInt64:
      Result := IntToStr(PInteger(@FValue)^);
    tkFloat:
      Result := FloatToStr(PDouble(@FValue)^);
    tkString, tkLString, tkWString, tkUString:
      Result := PString(@FValue)^;
    tkEnumeration:
      if TypeInfo = System.TypeInfo(Boolean) then
        Result := BoolToStr(PBoolean(@FValue)^, True)
      else
        Result := GetEnumName(TypeInfo, PInteger(@FValue)^);
    tkVariant:
      begin
        ValueVariant := PVariant(@FValue)^;
        Result := VarToStr(ValueVariant);
      end;
  else
    // Genel durumda TValue kullan
    Result := TValue.From<T>(FValue).ToString;
  end;
end;

function TEntityField<T>.AsInteger: Integer;
var
  TypeInfo: PTypeInfo;
  StrValue: string;
begin
  TypeInfo := System.TypeInfo(T);

  case TypeInfo.Kind of
    tkInteger:
      Result := PInteger(@FValue)^;
    tkInt64:
      Result := PInt64(@FValue)^;
    tkFloat:
      Result := Trunc(PDouble(@FValue)^);
    tkString, tkLString, tkWString, tkUString:
      begin
        StrValue := PString(@FValue)^;
        Result := StrToIntDef(StrValue, 0);
      end;
    tkEnumeration:
      if TypeInfo = System.TypeInfo(Boolean) then
        Result := Ord(PBoolean(@FValue)^)
      else
        Result := PInteger(@FValue)^;
    tkVariant:
      Result := VarAsType(PVariant(@FValue)^, varInteger);
  else
    Result := 0;
  end;
end;

function TEntityField<T>.AsInt64: Int64;
var
  TypeInfo: PTypeInfo;
  StrValue: string;
begin
  TypeInfo := System.TypeInfo(T);

  case TypeInfo.Kind of
    tkInteger:
      Result := PInteger(@FValue)^;
    tkInt64:
      Result := PInt64(@FValue)^;
    tkFloat:
      Result := Trunc(PDouble(@FValue)^);
    tkString, tkLString, tkWString, tkUString:
      begin
        StrValue := PString(@FValue)^;
        Result := StrToInt64Def(StrValue, 0);
      end;
    tkEnumeration:
      if TypeInfo = System.TypeInfo(Boolean) then
        Result := Ord(PBoolean(@FValue)^)
      else
        Result := PInteger(@FValue)^;
    tkVariant:
      Result := VarAsType(PVariant(@FValue)^, varInt64);
  else
    Result := 0;
  end;
end;

function TEntityField<T>.AsFloat: Double;
var
  TypeInfo: PTypeInfo;
  StrValue: string;
begin
  TypeInfo := System.TypeInfo(T);

  case TypeInfo.Kind of
    tkInteger:
      Result := PInteger(@FValue)^;
    tkInt64:
      Result := PInt64(@FValue)^;
    tkFloat:
      Result := PDouble(@FValue)^;
    tkString, tkLString, tkWString, tkUString:
      begin
        StrValue := PString(@FValue)^;
        Result := StrToFloatDef(StrValue, 0);
      end;
    tkEnumeration:
      if TypeInfo = System.TypeInfo(Boolean) then
        Result := Ord(PBoolean(@FValue)^)
      else
        Result := PInteger(@FValue)^;
    tkVariant:
      Result := VarAsType(PVariant(@FValue)^, varDouble);
  else
    Result := 0;
  end;
end;

function TEntityField<T>.AsBoolean: Boolean;
var
  TypeInfo: PTypeInfo;
  StrValue: string;
  IntValue: Integer;
begin
  TypeInfo := System.TypeInfo(T);

  case TypeInfo.Kind of
    tkInteger:
      Result := PInteger(@FValue)^ <> 0;
    tkInt64:
      Result := PInt64(@FValue)^ <> 0;
    tkFloat:
      Result := PDouble(@FValue)^ <> 0;
    tkString, tkLString, tkWString, tkUString:
      begin
        StrValue := PString(@FValue)^;
        Result := StrToBoolDef(StrValue, False);
      end;
    tkEnumeration:
      if TypeInfo = System.TypeInfo(Boolean) then
        Result := PBoolean(@FValue)^
      else
      begin
        IntValue := PInteger(@FValue)^;
        Result := IntValue <> 0;
      end;
    tkVariant:
      Result := VarAsType(PVariant(@FValue)^, varBoolean);
  else
    Result := False;
  end;
end;

function TEntityField<T>.AsDateTime: TDateTime;
var
  TypeInfo: PTypeInfo;
  StrValue: string;
begin
  TypeInfo := System.TypeInfo(T);

  case TypeInfo.Kind of
    tkFloat:
      if TypeInfo = System.TypeInfo(TDateTime) then
        Result := PDateTime(@FValue)^
      else
        Result := PDouble(@FValue)^;
    tkString, tkLString, tkWString, tkUString:
      begin
        StrValue := PString(@FValue)^;
        Result := StrToDateTimeDef(StrValue, 0);
      end;
    tkVariant:
      Result := VarAsType(PVariant(@FValue)^, varDate);
  else
    Result := 0;
  end;
end;

procedure TEntityField<T>.SetFieldName(const Value: string);
begin
  FFieldName := Value;
end;

procedure TEntityField<T>.SetOldValue(const AValue: T);
begin
  FOldValue := AValue;
end;

procedure TEntityField<T>.SetOwnerEntity(const Value: IEntity);
begin
  FOwnerEntity := Value;
end;

procedure TEntityField<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
end;

procedure TEntityField<T>.ValueFirstSet(const AValue: TValue);
begin
  Self.FValue := AValue.AsType<T>;
  Self.FOldValue := AValue.AsType<T>;
end;

function TEntityField<T>.ValueIsChanged: Boolean;
begin
  Result := OldValue <> Value;
end;

constructor TEntity.Create;
begin
  FFields := TList<IEntityField>.Create;

  FId := TEntityField<Integer>.Create(Self, 'id');
end;

destructor TEntity.Destroy;
var
  n1: Integer;
begin
  for n1 := 0 to Self.Fields.Count-1 do
  begin
    if Self.Fields[n1].OwnerEntity <> nil then
      Self.Fields[n1].OwnerEntity := nil;
  end;

  FreeAndNil(FFields);
//  FId := nil;
  inherited;
end;

function TEntity.GetFields: TList<IEntityField>;
begin
  Result := FFields;
end;

function TEntity.TableName: string;
//var
//  ctx: TRttiContext;
//  rType: TRttiType;
//  attr: TCustomAttribute;
begin
  Result := TTableNameService.TableName(Self.ClassType);
//  Result := '';
//  rType := ctx.GetType(Self.ClassType);
//  for attr in rType.GetAttributes do
//    if attr is TableNameAttribute then
//      Exit(TableNameAttribute(attr).Name);
end;

function TEntity.GetField(Index: Integer): IEntityField;
begin
  Result := FFields[Index];
end;

function TEntity.GetFieldByName(AFieldName: string): IEntityField;
var
  n1: Integer;
begin
  Result := nil;
  for n1 := 0 to FFields.Count-1 do
  begin
    if FFields.Items[n1].FieldName = AFieldName then
    begin
      Result := FFields.Items[n1];
      Break;
    end;
  end;
end;

procedure TEntity.SetField(Index: Integer; const Value: IEntityField);
begin
  FFields[Index] := Value;
end;

procedure TEntity.SetFields(const Value: TList<IEntityField>);
begin
  FFields := Value;
end;

procedure TEntity.ClearEntity<T>(ASrc: T);
var
  ctx: TRttiContext;
  rtti: TRttiType;
  prop: TRttiProperty;
  val: TValue;
  fld: TObject;
  fieldProp: TRttiProperty;
begin
  ctx := TRttiContext.Create;
  try
    rtti := ctx.GetType(ASrc.ClassType);
    for prop in rtti.GetProperties do
    begin
      if prop.PropertyType.TypeKind = tkClass then
      begin
        val := prop.GetValue(@ASrc);
        fld := val.AsObject;

        if (fld <> nil) and (fld.ClassName.StartsWith('TEntityField<')) then
        begin
          fieldProp := ctx.GetType(fld.ClassType).GetProperty('Value');
          if Assigned(fieldProp) then
            fieldProp.SetValue(fld, TValue.From<T>(Default(T)));////TValue.Empty); // Default(T)
        end;
      end;
    end;
  finally
    ctx.Free;
  end;

end;

function TEntity.CloneEntity<T>(ASrc: T): T;
var
  SrcField: IEntityField;
  DestField: IEntityField;
  RttiContext: TRttiContext;
  RttiTypeSrcField: TRttiType;
  RttiPropValue: TRttiProperty;
  RttiPropOldValue: TRttiProperty;
  ValueTValue: TValue;
  OldValueTValue: TValue;
begin
  Result := CallCreateMethod<T>;

  for SrcField in ASrc.Fields do
  begin
    // 3. Hedef varl�kta (Result) e�le�en alan�, alan ad�na g�re bul.
    DestField := Result.GetFieldByName(SrcField.FieldName);

    if Assigned(DestField) then
    begin
      // 4. Kaynak alan�n (SrcField) somut tipini RTTI ile al.
      // SrcField bir IEntityField aray�z� oldu�u i�in, AsObject ile TObject olarak eri�ilir.
      RttiTypeSrcField := RttiContext.GetType((SrcField as tobject).ClassType);

      // 5. 'Value' ve 'OldValue' �zelliklerinin RTTI tan�mlar�n� al.
      // Bu �zellikler TEntityField<T> s�n�f�nda tan�ml�d�r.
      RttiPropValue := RttiTypeSrcField.GetProperty('Value');
      RttiPropOldValue := RttiTypeSrcField.GetProperty('OldValue');

      if Assigned(RttiPropValue) and Assigned(RttiPropOldValue) then
      begin
        // 6. Kaynak alandan (SrcField) 'Value' ve 'OldValue' de�erlerini oku.
        ValueTValue := RttiPropValue.GetValue(SrcField As tObject);
        OldValueTValue := RttiPropOldValue.GetValue(SrcField as tObject);

        // 7. Hedef alana (DestField) 'Value' ve 'OldValue' de�erlerini yaz.
        // SetValue metodlar� da bir TObject �rne�i bekler.
        RttiPropValue.SetValue(DestField As tObject, ValueTValue);
        RttiPropOldValue.SetValue(DestField as tObject, OldValueTValue);
      end;
    end;
  end;
end;

constructor TableNameAttribute.Create(const AName: string);
begin
  FName := AName;
end;

function TEntity.CallCreateMethod<T>: T;
var
  rC: TRttiContext;
  rT: TRttiType;
  rM: TRttiMethod;
  n1: Integer;
  rPrms: TArray<TRttiParameter>;
  rParams: TArray<TValue>;
begin
  rT := rC.GetType(TypeInfo(T));
  rM := rT.GetMethod('Create');
  rPrms := rM.GetParameters;
  SetLength(rParams, Length(rPrms));
  for n1 := 0 to Length(rPrms) - 1 do
  begin
    case rPrms[n1].ParamType.TypeKind of
      tkClass:
        rParams[n1] := TValue.From<TObject>(nil);
      tkString, tkLString:
        rParams[n1] := TValue.From<string>('');
      tkUString:
        rParams[n1] := TValue.From<UnicodeString>('');
      tkWideString:
        rParams[n1] := TValue.From<UnicodeString>('');
      tkInteger, tkInt64:
        rParams[n1] := TValue.From<Integer>(0);
      tkFloat:
        rParams[n1] := TValue.From<Double>(0);
    end;
  end;

//  if rM.IsConstructor then
    Result := rM.Invoke(rT.AsInstance.MetaclassType, rParams).AsType<T>;
end;

end.

