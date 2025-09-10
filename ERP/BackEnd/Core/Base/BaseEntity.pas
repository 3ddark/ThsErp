unit BaseEntity;

interface

uses
  SysUtils, Classes, Types, System.StrUtils, System.DateUtils,
  System.Generics.Collections, System.Rtti, System.TypInfo;

type
  IEntity = interface;

  IEntityField = interface
    ['{2AD4AD6F-BCEA-4B74-BF33-02F894B63A6B}']
    function GetFieldName: string;
    procedure SetFieldName(const Value: string);
    procedure SetOwnerEntity(const Value: IEntity);
    function GetOwnerEntity: IEntity;

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

    procedure ValueFirstSet(const AValue: T);
    function ValueIsChanged: Boolean;

    function AsParamName: string;
    function AsQuotedStr: string;
    function QryName: string;
  end;

  TEntity = class(TInterfacedObject, IEntity)
  private
    FId: TEntityField<Integer>;
    FFields: TList<IEntityField>;
    procedure SetField(Index: Integer; const Value: IEntityField);
    function GetField(Index: Integer): IEntityField;
    function GetFields: TList<IEntityField>;
    procedure SetFields(const Value: TList<IEntityField>);
    function CallCreateMethod<T>: T;
  public
    property Id: TEntityField<Integer> read FId write FId;
    property Field[Index: Integer]: IEntityField read GetField write SetField; default;
    property Fields: TList<IEntityField> read GetFields write SetFields;

    constructor Create; virtual;
    destructor Destroy; override;

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

procedure TEntityField<T>.ValueFirstSet(const AValue: T);
begin
  Self.FValue := AValue;
  Self.FOldValue := AValue;
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
    // 3. Hedef varlýkta (Result) eþleþen alaný, alan adýna göre bul.
    DestField := Result.GetFieldByName(SrcField.FieldName);

    if Assigned(DestField) then
    begin
      // 4. Kaynak alanýn (SrcField) somut tipini RTTI ile al.
      // SrcField bir IEntityField arayüzü olduðu için, AsObject ile TObject olarak eriþilir.
      RttiTypeSrcField := RttiContext.GetType((SrcField as tobject).ClassType);

      // 5. 'Value' ve 'OldValue' özelliklerinin RTTI tanýmlarýný al.
      // Bu özellikler TEntityField<T> sýnýfýnda tanýmlýdýr.
      RttiPropValue := RttiTypeSrcField.GetProperty('Value');
      RttiPropOldValue := RttiTypeSrcField.GetProperty('OldValue');

      if Assigned(RttiPropValue) and Assigned(RttiPropOldValue) then
      begin
        // 6. Kaynak alandan (SrcField) 'Value' ve 'OldValue' deðerlerini oku.
        ValueTValue := RttiPropValue.GetValue(SrcField As tObject);
        OldValueTValue := RttiPropOldValue.GetValue(SrcField as tObject);

        // 7. Hedef alana (DestField) 'Value' ve 'OldValue' deðerlerini yaz.
        // SetValue metodlarý da bir TObject örneði bekler.
        RttiPropValue.SetValue(DestField As tObject, ValueTValue);
        RttiPropOldValue.SetValue(DestField as tObject, OldValueTValue);
      end;
    end;
  end;
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

constructor TableNameAttribute.Create(const AName: string);
begin
  FName := AName;
end;

end.

