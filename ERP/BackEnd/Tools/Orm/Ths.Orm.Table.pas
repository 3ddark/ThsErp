unit Ths.Orm.Table;

interface

uses
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  System.DateUtils,
  System.Variants,
  Data.DB;

{$M+}

type
  TFieldIslemTipi = (fpSelect, fpInsert, fpUpdate);
  TFieldIslemTipleri = set of TFieldIslemTipi;

  TThsTable = class;

  TThsField = class
  private
    FFieldName: string;
    FDataType: TFieldType;
    FValue: Variant;
    FSize: Integer;
    FIsNullable: Boolean;
    FOtherFieldName: string;
    FOwnerTable: TThsTable;
    FFieldIslemTipleri: TFieldIslemTipleri;
    function GetValue: Variant;
    procedure SetValue(const Value: Variant);
    procedure SetFieldIslemTipleri(const Value: TFieldIslemTipleri);
  public
    property FieldName: string read FFieldName write FFieldName;
    property DataType: TFieldType read FDataType write FDataType;
    property Value: Variant read GetValue write SetValue;
    property Size: Integer read FSize write FSize;
    property IsNullable: Boolean read FIsNullable write FIsNullable;
    property OtherFieldName: string read FOtherFieldName write FOtherFieldName;
    property OwnerTable: TThsTable read FOwnerTable write FOwnerTable;
    property FieldIslemTipleri: TFieldIslemTipleri read FFieldIslemTipleri write SetFieldIslemTipleri;

    constructor Create(AFieldName: string;
                     AFieldType: TFieldType;
                     AValue: Variant;
                     AOwnerTable: TThsTable;
                     AFieldIslemTipleri: TFieldIslemTipleri;
                     AOtherFieldName: string = '';
                     AMaxLength: Integer=0;
                     AIsNullable: Boolean=True);

    procedure Clone(var AField: TThsField);

    function AsBoolean: Boolean;
    function AsString: string;
    function AsInteger: Integer;
    function AsInt64: Int64;
    function AsDate: TDate;
    function AsTime: TTime;
    function AsDateTime: TDateTime;
    function AsFloat: Double;

    function QryName: string;
  end;

  IThsTable = interface
  end;

  TThsTable = class(TInterfacedObject, IThsTable)
  private
    FSchemaName: string;
    FTableName: string;
    FTableSourceCode: string;
    FFields: TArray<TThsField>;

    function GetTableName: string;
    procedure SetTableName(ATableName: string);
  published
    constructor Create(); virtual;
    destructor Destroy; override;
  public
    Id: TThsField;

    property SchemaName: string read FSchemaName write FSchemaName;
    property TableName: string read GetTableName write SetTableName;
    property TableSourceCode: string read FTableSourceCode write FTableSourceCode;
    property Fields: TArray<TThsField> read FFields write FFields;

    procedure Clear; virtual;
    function Validate: Boolean; virtual;

    function SelectOne(AFilter: string; ALock, APermissionCheck: Boolean): Boolean; virtual;
    function Insert(APermissionCheck: Boolean): Boolean; virtual;
    function Update(APermissionCheck: Boolean): Boolean; virtual;
    function Delete(APermissionCheck: Boolean): Boolean; virtual;

    function BusinessSelect(AFilter: string; ALock, APermissionCheck: Boolean): Boolean; virtual;
    function BusinessInsert(APermissionCheck: Boolean): Boolean; virtual;
    function BusinessUpdate(APermissionCheck: Boolean): Boolean; virtual;
    function BusinessDelete(APermissionCheck: Boolean): Boolean; virtual;

    class function GetSelectSQL: string; virtual;
  end;

implementation

uses Ths.Orm.ManagerStack, Ths.Orm.Manager;

constructor  TThsField.Create(
  AFieldName: string;
  AFieldType: TFieldType;
  AValue: Variant;
  AOwnerTable: TThsTable;
  AFieldIslemTipleri: TFieldIslemTipleri;
  AOtherFieldName: string = '';
  AMaxLength: Integer=0;
  AIsNullable: Boolean=True);
begin
  FFieldName := AFieldName;
  FDataType := AFieldType;
  FValue := AValue;
  FOwnerTable := AOwnerTable;
  FFieldIslemTipleri := AFieldIslemTipleri;
  FOtherFieldName := IfThen(AOtherFieldName = '', FFieldName, AOtherFieldName);
  FSize := AMaxLength;
  FIsNullable := AIsNullable;

  if FOwnerTable <> nil then
  begin
    SetLength(FOwnerTable.FFields, Length(FOwnerTable.FFields)+1);
    FOwnerTable.FFields[Length(FOwnerTable.FFields)-1] := Self;
  end;
end;

function TThsField.GetValue: Variant;
begin
  Result := FValue;
end;

procedure TThsField.SetFieldIslemTipleri(const Value: TFieldIslemTipleri);
begin
  FFieldIslemTipleri := Value;
end;

procedure TThsField.SetValue(const Value: Variant);
begin
  FValue := Value;

  if VarIsStr(FValue) and (FValue = '') then
    case FDataType of
      ftUnknown: ;
      ftString: ;
      ftSmallint: FValue := 0;
      ftInteger: FValue := 0;
      ftWord: FValue := 0;
      ftBoolean: ;
      ftFloat: FValue := 0;
      ftCurrency: FValue := 0;
      ftBCD: ;
      ftDate: FValue := 0;
      ftTime: FValue := 0;
      ftDateTime: FValue := 0;
      ftBytes: ;
      ftVarBytes: ;
      ftAutoInc: ;
      ftBlob: ;
      ftMemo: ;
      ftGraphic: ;
      ftFmtMemo: ;
      ftParadoxOle: ;
      ftDBaseOle: ;
      ftTypedBinary: ;
      ftCursor: ;
      ftFixedChar: ;
      ftWideString: ;
      ftLargeint: ;
      ftADT: ;
      ftArray: ;
      ftReference: ;
      ftDataSet: ;
      ftOraBlob: ;
      ftOraClob: ;
      ftVariant: ;
      ftInterface: ;
      ftIDispatch: ;
      ftGuid: ;
      ftTimeStamp: FValue := 0;
      ftFMTBcd: FValue := 0;
      ftFixedWideChar: ;
      ftWideMemo: ;
      ftOraTimeStamp: ;
      ftOraInterval: ;
      ftLongWord: FValue := 0;
      ftShortint: FValue := 0;
      ftByte: ;
      ftExtended: ;
      ftConnection: ;
      ftParams: ;
      ftStream: ;
      ftTimeStampOffset: ;
      ftObject: ;
      ftSingle: ;
    end;
end;

function TThsField.QryName: string;
begin
  Result := IfThen(FOwnerTable.SchemaName <> '', FOwnerTable.SchemaName + '.', '') + FOwnerTable.TableName + '.' + FieldName;
end;

function TThsField.AsBoolean: Boolean;
begin
  Result := False;
  if VarType(FValue) and varTypeMask = varBoolean then
    Result := FValue;
end;

function TThsField.AsDate: TDate;
begin
  if VarIsFloat(Value) or VarIsNumeric(Value) then
    Result := VarToDateTime(Value)
  else
    Result := StrToDateDef(AsString, 0);
end;

function TThsField.AsTime: TTime;
begin
  if VarIsFloat(Value) or VarIsNumeric(Value) then
    Result := TimeOf(VarToDateTime(Value))
  else
    Result := TimeOf(StrToDateTimeDef(AsString, 0));
end;

function TThsField.AsDateTime: TDateTime;
begin
  if VarIsFloat(Value) or VarIsNumeric(Value) then
    Result := VarToDateTime(Value)
  else
    Result := StrToDateTimeDef(AsString, 0);
end;

function TThsField.AsFloat: Double;
begin
  Result := StrToFloatDef(AsString, 0);
end;

function TThsField.AsInt64: Int64;
begin
  Result := StrToInt64Def(AsString, 0);
end;

function TThsField.AsInteger: Integer;
begin
  Result := StrToIntDef(AsString, 0);
end;

function TThsField.AsString: string;
begin
  Result := System.Variants.VarToStr(Value);
end;

procedure TThsField.Clone(var AField: TThsField);
begin
  AField.FOwnerTable := FOwnerTable;
  AField.FFieldName := FFieldName;
  AField.FDataType := FDataType;
  AField.FValue := FValue;
  AField.FSize := FSize;
  AField.FIsNullable := FIsNullable;
  AField.FOtherFieldName := FOtherFieldName;
end;

constructor TThsTable.Create;
begin
  if Trim(FTableName) = '' then
    raise Exception.Create('Table sınıfları Inherited Create işleminden önce Tablo adı tanımlanmak zorunda!!!');

  SetLength(FFields, 0);

  Id := TThsField.Create('id', ftInteger, 0, Self, [fpSelect, fpUpdate]);
  Id.Value := AppDbContext.GetNewRecordId
end;

class function TThsTable.GetSelectSQL: string;
begin
  Result := '';
end;

function TThsTable.GetTableName: string;
begin
  Result := FTableName;
end;

procedure TThsTable.SetTableName(ATableName: string);
begin
  FTableName := ATableName;
end;

function TThsTable.Insert(APermissionCheck: Boolean): Boolean;
begin
  Result := AppDbContext.Insert(Self, APermissionCheck);
end;

function TThsTable.SelectOne(AFilter: string; ALock, APermissionCheck: Boolean): Boolean;
begin
  Result := AppDbContext.GetOne(Self, AFilter, ALock, APermissionCheck);
end;

function TThsTable.Delete(APermissionCheck: Boolean): Boolean;
begin
  Result := AppDbContext.Delete(Self, APermissionCheck);
end;

function TThsTable.Update(APermissionCheck: Boolean): Boolean;
begin
  Result := AppDbContext.Update(Self, APermissionCheck);
end;

destructor TThsTable.Destroy;
var
  AField: TThsField;
begin
  for AField in Fields do
    AField.Free;
  SetLength(FFields, 0);
  inherited;
end;

function TThsTable.BusinessSelect(AFilter: string; ALock, APermissionCheck: Boolean): Boolean;
begin
  Result := Self.SelectOne(AFilter, ALock, APermissionCheck);
end;

function TThsTable.BusinessInsert(APermissionCheck: Boolean): Boolean;
begin
  Result := Self.Insert(APermissionCheck);
end;

function TThsTable.BusinessUpdate(APermissionCheck: Boolean): Boolean;
begin
  Result := Self.Update(APermissionCheck);
end;

function TThsTable.BusinessDelete(APermissionCheck: Boolean): Boolean;
begin
  Result := Self.Delete(APermissionCheck);
end;

procedure TThsTable.Clear;
var
  AField: TThsField;
begin
  for AField in FFields do
  begin
    with AField do
    begin
      if (DataType = ftString)
      or (DataType = ftWideString)
      or (DataType = ftMemo)
      or (DataType = ftWideMemo)
      or (DataType = ftBytes)
      or (DataType = ftFmtMemo)
      or (DataType = ftFixedChar)
      or (DataType = ftFixedWideChar)
      then
        Value := ''
      else
      if (DataType = ftSmallint)
      or (DataType = ftInteger)
      or (DataType = ftWord)
      or (DataType = ftFloat)
      or (DataType = ftCurrency)
      or (DataType = ftBCD)
      or (DataType = ftDate)
      or (DataType = ftTime)
      or (DataType = ftDateTime)
      or (DataType = ftBytes)
      or (DataType = ftVarBytes)
      or (DataType = ftAutoInc)
      or (DataType = ftLargeint)
      or (DataType = ftTimeStamp)
      or (DataType = ftShortint)
      or (DataType = ftByte)
      then
        Value := 0
      else if (DataType = ftBoolean) then
        Value := False
      else if (DataType = ftBlob) then
        Value := Null;
    end;
  end;
end;

function TThsTable.Validate: Boolean;
begin
  Result := True;
end;

end.
