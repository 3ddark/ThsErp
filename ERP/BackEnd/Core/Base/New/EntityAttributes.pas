unit EntityAttributes;

interface

uses
  System.Classes, System.SysUtils, System.Variants, System.Generics.Collections,
  System.Rtti, System.TypInfo, LocalizationManager;

type
  TColumnProperty = (cpNotNull, cpUnique, cpPrimaryKey, cpAutoIncrement);
  TColumnProperties = set of TColumnProperty;

//  TColumnUseCriteria = (cucFind, cucAdd, cucUpdate, cucAll);
//  TColumnUseCriterias = set of TColumnUseCriteria;

//  TDataType = (dtString, dtInteger, dtBigInt, dtFloat, dtDouble, dtDecimal, dtDateTime,
//               dtDate, dtTime, dtBoolean, dtText, dtBlob, dtGUID, dtJSON, dtEnum,
//               //postgres special types
//               dtUUID, dtArray, dtJSONB, dtHStore, dtPoint, dtPolygon, dtInet, dtMacAddr,
//               dtTSVector, dtInterval, dtNumeric, dtSerial, dtBigSerial, dtBytea);

  TCascadeAction = (caNone, caRestrict, caCascade, caSetNull, caSetDefault);

  TValidationError = class
  private
    FFieldName: string;
    FMessage: string;
  public
    constructor Create(const AFieldName, AMessage: string);
    property FieldName: string read FFieldName;
    property Message: string read FMessage;
  end;

  TValidationResult = class
  private
    FIsValid: Boolean;
    FErrors: TObjectList<TValidationError>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddError(const AFieldName, AMessage: string);
    function GetErrors: TArray<TValidationError>;
    property IsValid: Boolean read FIsValid;
    property Errors: TArray<TValidationError> read GetErrors;
  end;

  TableAttribute = class(TCustomAttribute)
  private
    FName: string;
    FSchema: string;
    FEngine: string;
    FCharset: string;
  public
    constructor Create(const AName: string; const ASchema: string = '';
                      const AEngine: string = ''; const ACharset: string = 'utf8mb4');
    property Name: string read FName;
    property Schema: string read FSchema;
    property Engine: string read FEngine;
    property Charset: string read FCharset;
    function FullName: string;
  end;

  Column = class(TCustomAttribute)
  private
    FName: string;
    FProperties: TColumnProperties;
//    FSqlUseWhichCols: TColumnUseCriterias;
    FLength: Integer;
    FPrecision: Integer;
    FScale: Integer;
    FComment: string;
    FCollation: string;
  public
    constructor Create(const AName: string; AProperties: TColumnProperties = [];
                      //ASqlUseWhichCols: TColumnUseCriterias = [cucAll];
                      //ADataType: TDataType = dtString;
                      ALength: Integer = 0;
                      APrecision: Integer = 0; AScale: Integer = 0;
                      const AComment: string = '';
                      const ACollation: string = '');
    property Name: string read FName;
    property Properties: TColumnProperties read FProperties;
//    property SqlUseWhichCols: TColumnUseCriterias read FSqlUseWhichCols;
//    property DataType: TDataType read FDataType;
    property Length: Integer read FLength;
    property Precision: Integer read FPrecision;
    property Scale: Integer read FScale;
    property Comment: string read FComment;
    property Collation: string read FCollation;
    function IsPrimaryKey: Boolean;
    function IsNotNull: Boolean;
    function IsUnique: Boolean;
    function IsAutoIncrement: Boolean;
  end;

  Inherits = class(TCustomAttribute)
  private
    FParentTable: string;
  public
    constructor Create(const AParentTable: string);
    property ParentTable: string read FParentTable;
  end;

  IndexAttribute = class(TCustomAttribute)
  private
    FName: string;
    FColumn: string;
    FIsUnique: Boolean;
  public
    constructor Create(const AName: string; const AColumn: string; AIsUnique: Boolean = False);
    property Name: string read FName;
    property Column: string read FColumn;
    property IsUnique: Boolean read FIsUnique;
  end;

  UniqueIndex = class(IndexAttribute)
  public
    constructor Create(const AName: string; const AColumn: string; const AType: string = 'BTREE');
  end;

  CompositeKey = class(TCustomAttribute)
  private
    FColumn: string;
  public
    constructor Create(const AColumn: string);
    property Columns: string read FColumn;
  end;

  Required = class(TCustomAttribute)
  private
    FMessage: string;
    FMessageKey: string;
    FUseTranslation: Boolean;
  public
    constructor Create(const AMessage: string = ''); overload;
    constructor Create(const AMessageKey: string; const AUseTranslation: Boolean); overload;
    function Validate(const AValue: TValue; const AFieldName: string): TValidationResult;
    property Message: string read FMessage;
    property MessageKey: string read FMessageKey;
    property UseTranslation: Boolean read FUseTranslation;
  end;

  MinLength = class(TCustomAttribute)
  private
    FMinLength: Integer;
    FMessage: string;
    FMessageKey: string;
    FUseTranslation: Boolean;
  public
    constructor Create(AMinLength: Integer; const AMessage: string = ''); overload;
    constructor Create(AMinLength: Integer; const AMessageKey: string; const AUseTranslation: Boolean); overload;
    function Validate(const AValue: TValue; const AFieldName: string): TValidationResult;
    property MinLength: Integer read FMinLength;
    property UseTranslation: Boolean read FUseTranslation;
  end;

  MaxLength = class(TCustomAttribute)
  private
    FMaxLength: Integer;
    FMessage: string;
    FMessageKey: string;
    FUseTranslation: Boolean;
  public
    constructor Create(AMaxLength: Integer; const AMessage: string = ''); overload;
    constructor Create(AMaxLength: Integer; const AMessageKey: string; const AUseTranslation: Boolean); overload;
    function Validate(const AValue: TValue; const AFieldName: string): TValidationResult;
    property MaxLength: Integer read FMaxLength;
    property UseTranslation: Boolean read FUseTranslation;
  end;

  Range = class(TCustomAttribute)
  private
    FMinValue: TValue;
    FMaxValue: TValue;
    FMessage: string;
    FMessageKey: string;
    FUseTranslation: Boolean;
  public
    constructor Create(const AMinValue, AMaxValue: Integer; const AMessage: string = ''); overload;
    constructor Create(const AMinValue, AMaxValue: Integer; const AMessageKey: string; const AUseTranslation: Boolean); overload;
    constructor Create(const AMinValue, AMaxValue: Int64; const AMessage: string = ''); overload;
    constructor Create(const AMinValue, AMaxValue: Int64; const AMessageKey: string; const AUseTranslation: Boolean); overload;
    constructor Create(const AMinValue, AMaxValue: Double; const AMessage: string = ''); overload;
    constructor Create(const AMinValue, AMaxValue: Double; const AMessageKey: string; const AUseTranslation: Boolean); overload;
    function Validate(const AValue: TValue; const AFieldName: string): TValidationResult;
    property UseTranslation: Boolean read FUseTranslation;
  end;

  Email = class(TCustomAttribute)
  private
    FMessage: string;
    FMessageKey: string;
    FUseTranslation: Boolean;
  public
    constructor Create(const AMessage: string = 'Invalid email format'); overload;
    constructor Create(const AMessageKey: string; const AUseTranslation: Boolean); overload;
    function Validate(const AValue: TValue; const AFieldName: string): TValidationResult;
    property UseTranslation: Boolean read FUseTranslation;
  end;

  RegEx = class(TCustomAttribute)
  private
    FPattern: string;
    FMessage: string;
    FMessageKey: string;
    FUseTranslation: Boolean;
  public
    constructor Create(const APattern: string; const AMessage: string = 'Invalid format'); overload;
    constructor Create(const APattern: string; const AMessageKey: string; const AUseTranslation: Boolean); overload;
    function Validate(const AValue: TValue; const AFieldName: string): TValidationResult;
    property UseTranslation: Boolean read FUseTranslation;
  end;

  CreatedAt = class(TCustomAttribute)
  private
    FColumnName: string;
    FAutoUpdate: Boolean;
  public
    constructor Create(const AColumnName: string = 'created_at'; AAutoUpdate: Boolean = True);
    property ColumnName: string read FColumnName;
    property AutoUpdate: Boolean read FAutoUpdate;
  end;

  UpdatedAt = class(TCustomAttribute)
  private
    FColumnName: string;
    FAutoUpdate: Boolean;
  public
    constructor Create(const AColumnName: string = 'updated_at'; AAutoUpdate: Boolean = True);
    property ColumnName: string read FColumnName;
    property AutoUpdate: Boolean read FAutoUpdate;
  end;

  CreatedBy = class(TCustomAttribute)
  private
    FColumnName: string;
    FUserIdProvider: string;
  public
    constructor Create(const AColumnName: string = 'created_by'; const AUserIdProvider: string = '');
    property ColumnName: string read FColumnName;
    property UserIdProvider: string read FUserIdProvider;
  end;

  UpdatedBy = class(TCustomAttribute)
  private
    FColumnName: string;
    FUserIdProvider: string;
  public
    constructor Create(const AColumnName: string = 'updated_by'; const AUserIdProvider: string = '');
    property ColumnName: string read FColumnName;
    property UserIdProvider: string read FUserIdProvider;
  end;

  SoftDelete = class(TCustomAttribute)
  private
    FDeletedAtColumn: string;
    FDeletedByColumn: string;
  public
    constructor Create(const ADeletedAtColumn: string = 'deleted_at'; const ADeletedByColumn: string = '');
    property DeletedAtColumn: string read FDeletedAtColumn;
    property DeletedByColumn: string read FDeletedByColumn;
  end;

  ForeignKeyAttribute = class(TCustomAttribute)
  private
    FName: string;
    FReferencedTable: string;
    FReferencedColumn: string;
    FOnDelete: string; // CASCADE, SET NULL, RESTRICT, etc.
    FOnUpdate: string;
  public
    constructor Create(const AName, AReferencedTable, AReferencedColumn: string;
                      const AOnDelete: string = 'RESTRICT';
                      const AOnUpdate: string = 'RESTRICT');
    property Name: string read FName;
    property ReferencedTable: string read FReferencedTable;
    property ReferencedColumn: string read FReferencedColumn;
    property OnDelete: string read FOnDelete;
    property OnUpdate: string read FOnUpdate;
  end;

  CheckConstraintAttribute = class(TCustomAttribute)
  private
    FName: string;
    FExpression: string;
  public
    constructor Create(const AName, AExpression: string);
    property Name: string read FName;
    property Expression: string read FExpression;
  end;

  DefaultValueAttribute = class(TCustomAttribute)
  private
    FValue: string;
  public
    constructor Create(const AValue: string);
    property Value: string read FValue;
  end;

  HasManyAttribute = class(TCustomAttribute)
  private
    FForeignKeyProperty: string;
    FLocalKeyProperty: string;
    FRelatedClass: string;
    FOnDelete: TCascadeAction;
    FOnUpdate: TCascadeAction;
    FOrderBy: string;
    FWhere: string;
  public
    constructor Create(const AForeignKeyProperty: string = '';
                      const ALocalKeyProperty: string = 'Id';
                      const ARelatedClass: string = '';
                      AOnDelete: TCascadeAction = caNone;
                      AOnUpdate: TCascadeAction = caNone;
                      const AOrderBy: string = '';
                      const AWhere: string = '');

    property ForeignKeyProperty: string read FForeignKeyProperty;
    property LocalKeyProperty: string read FLocalKeyProperty;
    property RelatedClass: string read FRelatedClass;
    property OnDelete: TCascadeAction read FOnDelete;
    property OnUpdate: TCascadeAction read FOnUpdate;
    property OrderBy: string read FOrderBy;
    property Where: string read FWhere;
  end;

  HasOneAttribute = class(TCustomAttribute)
  private
    FForeignKeyProperty: string;
    FLocalKeyProperty: string;
    FRelatedClass: string;
    FOnDelete: TCascadeAction;
    FOnUpdate: TCascadeAction;
  public
    constructor Create(const AForeignKeyProperty: string = '';
                      const ALocalKeyProperty: string = 'Id';
                      const ARelatedClass: string = '';
                      AOnDelete: TCascadeAction = caNone;
                      AOnUpdate: TCascadeAction = caNone);

    property ForeignKeyProperty: string read FForeignKeyProperty;
    property LocalKeyProperty: string read FLocalKeyProperty;
    property RelatedClass: string read FRelatedClass;
    property OnDelete: TCascadeAction read FOnDelete;
    property OnUpdate: TCascadeAction read FOnUpdate;
  end;

  BelongsToAttribute = class(TCustomAttribute)
  private
    FLocalKeyProperty: string;
    FRemoteKeyProperty: string;
    FRelatedClass: string;
    FOnDelete: TCascadeAction;
    FOnUpdate: TCascadeAction;
  public
    constructor Create(const ALocalKeyProperty: string = '';
                      const ARemoteKeyProperty: string = 'Id';
                      const ARelatedClass: string = '';
                      AOnDelete: TCascadeAction = caNone;
                      AOnUpdate: TCascadeAction = caNone);

    property LocalKeyProperty: string read FLocalKeyProperty;
    property RemoteKeyProperty: string read FRemoteKeyProperty;
    property RelatedClass: string read FRelatedClass;
    property OnDelete: TCascadeAction read FOnDelete;
    property OnUpdate: TCascadeAction read FOnUpdate;
  end;

  ManyToManyAttribute = class(TCustomAttribute)
  private
    FPivotTable: string;
    FLocalKey: string;
    FRemoteKey: string;
    FTableName: string;
    FPivotLocalKey: string;
    FPivotRemoteKey: string;
    FOrderBy: string;
    FWhere: string;
  public
    constructor Create(const APivotTable: string;
                      const ALocalKey: string = '';
                      const ARemoteKey: string = '';
                      const ATableName: string = '';
                      const APivotLocalKey: string = '';
                      const APivotRemoteKey: string = '';
                      const AOrderBy: string = '';
                      const AWhere: string = '');

    property PivotTable: string read FPivotTable;
    property LocalKey: string read FLocalKey;
    property RemoteKey: string read FRemoteKey;
    property TableName: string read FTableName;
    property PivotLocalKey: string read FPivotLocalKey;
    property PivotRemoteKey: string read FPivotRemoteKey;
    property OrderBy: string read FOrderBy;
    property Where: string read FWhere;
  end;

  NotMapped = class(TCustomAttribute)
  public
    constructor Create;
  end;

  Transient = class(TCustomAttribute)
  public
    constructor Create;
  end;

  Version = class(TCustomAttribute)
  private
    FColumnName: string;
  public
    constructor Create(const AColumnName: string = 'version');
    property ColumnName: string read FColumnName;
  end;

  JsonColumn = class(TCustomAttribute)
  private
    FColumnName: string;
  public
    constructor Create(const AColumnName: string = '');
    property ColumnName: string read FColumnName;
  end;

  Enum = class(TCustomAttribute)
  private
    FValues: TArray<string>;
    FDefaultValue: string;
  public
    constructor Create(const AValues: array of string; const ADefaultValue: string = '');
    property Values: TArray<string> read FValues;
    property DefaultValue: string read FDefaultValue;
  end;

implementation

uses
  System.RegularExpressions;

constructor TValidationError.Create(const AFieldName, AMessage: string);
begin
  inherited Create;
  FFieldName := AFieldName;
  FMessage := AMessage;
end;

constructor TValidationResult.Create;
begin
  inherited Create;
  FIsValid := True;
  FErrors := TObjectList<TValidationError>.Create();
end;

destructor TValidationResult.Destroy;
begin
  FErrors.Free;
  inherited;
end;

procedure TValidationResult.AddError(const AFieldName, AMessage: string);
begin
  FErrors.Add(TValidationError.Create(AFieldName, AMessage));
  FIsValid := False;
end;

function TValidationResult.GetErrors: TArray<TValidationError>;
begin
  Result := FErrors.ToArray;
end;

constructor TableAttribute.Create(const AName: string; const ASchema: string = ''; const AEngine: string = ''; const ACharset: string = 'utf8mb4');
begin
  inherited Create;
  FName := AName;
  FSchema := ASchema;
  FEngine := AEngine;
  FCharset := ACharset;
end;

function TableAttribute.FullName: string;
begin
  if FSchema <> '' then
    Result := FSchema + '.' + FName
  else
    Result := FName;
end;

constructor Column.Create(const AName: string; AProperties: TColumnProperties = [];
                         //ASqlUseWhichCols: TColumnUseCriterias = [cucAll];
                         //ADataType: TDataType = dtString;
                         ALength: Integer = 0;
                         APrecision: Integer = 0; AScale: Integer = 0;
                         const AComment: string = '';
                         const ACollation: string = '');
begin
  inherited Create;
  FName := AName;
  FProperties := AProperties;
//  FSqlUseWhichCols := ASqlUseWhichCols;
//  FDataType := ADataType;
  FLength := ALength;
  FPrecision := APrecision;
  FScale := AScale;
  FComment := AComment;
  FCollation := ACollation;
end;

function Column.IsPrimaryKey: Boolean;
begin
  Result := cpPrimaryKey in FProperties;
end;

function Column.IsNotNull: Boolean;
begin
  Result := cpNotNull in FProperties;
end;

function Column.IsUnique: Boolean;
begin
  Result := cpUnique in FProperties;
end;

function Column.IsAutoIncrement: Boolean;
begin
  Result := cpAutoIncrement in FProperties;
end;

constructor IndexAttribute.Create(const AName: string; const AColumn: string; AIsUnique: Boolean = False);
begin
  inherited Create;
  FName := AName;
  FIsUnique := AIsUnique;
  FColumn := AColumn;
end;

constructor UniqueIndex.Create(const AName: string; const AColumn: string; const AType: string = 'BTREE');
begin
  inherited Create(AName, AColumn, True);
end;

constructor CompositeKey.Create(const AColumn: string);
begin
  inherited Create;
  FColumn := AColumn;
end;

constructor Required.Create(const AMessage: string = '');
begin
  inherited Create;
  FMessage := AMessage;
  FMessageKey := '';
  FUseTranslation := False;
  if FMessage = '' then
    FMessage := 'Field is required';
end;

constructor Required.Create(const AMessageKey: string; const AUseTranslation: Boolean);
begin
  inherited Create;
  FMessageKey := AMessageKey;
  FUseTranslation := AUseTranslation;
  if AUseTranslation then
    FMessage := ''
  else
    FMessage := AMessageKey;
end;

function Required.Validate(const AValue: TValue; const AFieldName: string): TValidationResult;
var
  ErrorMessage: string;
  IsEmpty: Boolean;
begin
  Result := TValidationResult.Create;

  IsEmpty := AValue.IsEmpty;

  if not IsEmpty then
  begin
    case AValue.TypeInfo.Kind of
      tkString, tkLString, tkWString, tkUString:
        IsEmpty := Trim(AValue.AsString) = '';
      tkInteger:
        IsEmpty := False; // Integer değerler için boş kontrolü gerekmiyor
      tkInt64:
        IsEmpty := False;
      tkFloat:
        IsEmpty := False;
    end;
  end;

  if IsEmpty then
  begin
    if FUseTranslation and (FMessageKey <> '') then
      ErrorMessage := TLocalizationManager.Translate(FMessageKey, FMessage)
    else
      ErrorMessage := FMessage;

    Result.AddError(AFieldName, ErrorMessage);
  end;
end;

constructor MinLength.Create(AMinLength: Integer; const AMessage: string = '');
begin
  inherited Create;
  FMinLength := AMinLength;
  FMessage := AMessage;
  FMessageKey := '';
  FUseTranslation := False;
  if FMessage = '' then
    FMessage := Format('Field must be at least %d characters long', [AMinLength]);
end;

constructor MinLength.Create(AMinLength: Integer; const AMessageKey: string; const AUseTranslation: Boolean);
begin
  inherited Create;
  FMinLength := AMinLength;
  FMessageKey := AMessageKey;
  FUseTranslation := AUseTranslation;
  if AUseTranslation then
    FMessage := ''
  else
    FMessage := AMessageKey;
end;

function MinLength.Validate(const AValue: TValue; const AFieldName: string): TValidationResult;
var
  StrValue: string;
  ErrorMessage: string;
begin
  Result := TValidationResult.Create;

  if not AValue.IsEmpty then
  begin
    // FIX: TValue'dan direkt string al, Variant kullanma
    case AValue.TypeInfo.Kind of
      tkString, tkLString, tkWString, tkUString:
        StrValue := AValue.AsString;
    else
      Exit; // String olmayan değerler için length kontrolü yapma
    end;

    if Length(StrValue) < FMinLength then
    begin
      if FUseTranslation and (FMessageKey <> '') then
        ErrorMessage := TLocalizationManager.Translate(FMessageKey, [FMinLength], FMessage)
      else
        ErrorMessage := Format(FMessage, [FMinLength]);

      Result.AddError(AFieldName, ErrorMessage);
    end;
  end;
end;

constructor MaxLength.Create(AMaxLength: Integer; const AMessage: string = '');
begin
  inherited Create;
  FMaxLength := AMaxLength;
  FMessage := AMessage;
  FMessageKey := '';
  FUseTranslation := False;
  if AMessage = '' then
    FMessage := Format('Field must not exceed %d characters', [AMaxLength]);
end;

constructor MaxLength.Create(AMaxLength: Integer; const AMessageKey: string; const AUseTranslation: Boolean);
begin
  inherited Create;
  FMaxLength := AMaxLength;
  FMessageKey := AMessageKey;
  FUseTranslation := AUseTranslation;
  if AUseTranslation then
    FMessage := ''
  else
    FMessage := AMessageKey;
end;

function MaxLength.Validate(const AValue: TValue; const AFieldName: string): TValidationResult;
var
  StrValue: string;
  ErrorMessage: string;
begin
  Result := TValidationResult.Create;

  if not AValue.IsEmpty then
  begin
    // FIX: TValue'dan direkt string al
    case AValue.TypeInfo.Kind of
      tkString, tkLString, tkWString, tkUString:
        StrValue := AValue.AsString;
    else
      Exit; // String olmayan değerler için length kontrolü yapma
    end;

    if Length(StrValue) > FMaxLength then
    begin
      if FUseTranslation and (FMessageKey <> '') then
        ErrorMessage := TLocalizationManager.Translate(FMessageKey, [FMaxLength], FMessage)
      else
        ErrorMessage := Format(FMessage, [FMaxLength]);

      Result.AddError(AFieldName, ErrorMessage);
    end;
  end;
end;

constructor Range.Create(const AMinValue, AMaxValue: Integer; const AMessage: string = '');
begin
  inherited Create;
  FMinValue := AMinValue;
  FMaxValue := AMaxValue;
  FMessage := AMessage;
  FMessageKey := '';
  FUseTranslation := False;
  if AMessage = '' then
    FMessage := Format('Field must be between %s and %s', [AMinValue.ToString, AMaxValue.ToString]);
end;

constructor Range.Create(const AMinValue, AMaxValue: Integer; const AMessageKey: string; const AUseTranslation: Boolean);
begin
  inherited Create;
  FMinValue := AMinValue;
  FMaxValue := AMaxValue;
  FMessageKey := AMessageKey;
  FUseTranslation := AUseTranslation;
  if AUseTranslation then
    FMessage := ''
  else
    FMessage := AMessageKey;
end;

constructor Range.Create(const AMinValue, AMaxValue: Int64; const AMessage: string = '');
begin
  inherited Create;
  FMinValue := AMinValue;
  FMaxValue := AMaxValue;
  FMessage := AMessage;
  FMessageKey := '';
  FUseTranslation := False;
  if AMessage = '' then
    FMessage := Format('Field must be between %s and %s', [AMinValue.ToString, AMaxValue.ToString]);
end;

constructor Range.Create(const AMinValue, AMaxValue: Int64; const AMessageKey: string; const AUseTranslation: Boolean);
begin
  inherited Create;
  FMinValue := AMinValue;
  FMaxValue := AMaxValue;
  FMessageKey := AMessageKey;
  FUseTranslation := AUseTranslation;
  if AUseTranslation then
    FMessage := ''
  else
    FMessage := AMessageKey;
end;

constructor Range.Create(const AMinValue, AMaxValue: Double; const AMessage: string = '');
begin
  inherited Create;
  FMinValue := AMinValue;
  FMaxValue := AMaxValue;
  FMessage := AMessage;
  FMessageKey := '';
  FUseTranslation := False;
  if AMessage = '' then
    FMessage := Format('Field must be between %s and %s', [AMinValue.ToString, AMaxValue.ToString]);
end;

constructor Range.Create(const AMinValue, AMaxValue: Double; const AMessageKey: string; const AUseTranslation: Boolean);
begin
  inherited Create;
  FMinValue := AMinValue;
  FMaxValue := AMaxValue;
  FMessageKey := AMessageKey;
  FUseTranslation := AUseTranslation;
  if AUseTranslation then
    FMessage := ''
  else
    FMessage := AMessageKey;
end;

function Range.Validate(const AValue: TValue; const AFieldName: string): TValidationResult;
var
  ErrorMessage: string;
  NumericValue: Double;
  IsInRange: Boolean;
begin
  Result := TValidationResult.Create;

  if not AValue.IsEmpty then
  begin
    case AValue.TypeInfo.Kind of
      tkInteger:
        begin
          NumericValue := AValue.AsInteger;
          IsInRange := (NumericValue >= FMinValue.AsInteger) and (NumericValue <= FMaxValue.AsInteger);
        end;
      tkInt64:
        begin
          NumericValue := AValue.AsInt64;
          IsInRange := (NumericValue >= FMinValue.AsInt64) and (NumericValue <= FMaxValue.AsInt64);
        end;
      tkFloat:
        begin
          NumericValue := AValue.AsExtended;
          IsInRange := (NumericValue >= FMinValue.AsExtended) and (NumericValue <= FMaxValue.AsExtended);
        end;
    else
      Exit;
    end;

    if not IsInRange then
    begin
      if FUseTranslation and (FMessageKey <> '') then
        ErrorMessage := TLocalizationManager.Translate(FMessageKey,
          [FMinValue.ToString, FMaxValue.ToString], FMessage)
      else
        ErrorMessage := Format(FMessage, [FMinValue.ToString, FMaxValue.ToString]);

      Result.AddError(AFieldName, ErrorMessage);
    end;
  end;
end;

constructor Email.Create(const AMessage: string = 'Invalid email format');
begin
  inherited Create;
  FMessage := AMessage;
  FMessageKey := '';
  FUseTranslation := False;
end;

constructor Email.Create(const AMessageKey: string; const AUseTranslation: Boolean);
begin
  inherited Create;
  FMessageKey := AMessageKey;
  FUseTranslation := AUseTranslation;
  if AUseTranslation then
    FMessage := ''
  else
    FMessage := AMessageKey;
end;

function Email.Validate(const AValue: TValue; const AFieldName: string): TValidationResult;
var
  EmailRegex: string;
  StrValue: string;
  ErrorMessage: string;
begin
  Result := TValidationResult.Create;

  if not AValue.IsEmpty then
  begin
    // FIX: TValue'dan direkt string al, VarToStr kullanma
    case AValue.TypeInfo.Kind of
      tkString, tkLString, tkWString, tkUString:
        StrValue := AValue.AsString;
    else
      Exit; // String olmayan değerler için email kontrolü yapma
    end;

    if Trim(StrValue) = '' then
      Exit;

    EmailRegex := '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}';

    if not TRegEx.IsMatch(StrValue, EmailRegex) then
    begin
      if FUseTranslation and (FMessageKey <> '') then
        ErrorMessage := TLocalizationManager.Translate(FMessageKey, FMessage)
      else
        ErrorMessage := FMessage;

      Result.AddError(AFieldName, ErrorMessage);
    end;
  end;
end;

constructor RegEx.Create(const APattern: string; const AMessage: string = 'Invalid format');
begin
  inherited Create;
  FPattern := APattern;
  FMessage := AMessage;
  FMessageKey := '';
  FUseTranslation := False;
end;

constructor RegEx.Create(const APattern: string; const AMessageKey: string; const AUseTranslation: Boolean);
begin
  inherited Create;
  FPattern := APattern;
  FMessageKey := AMessageKey;
  FUseTranslation := AUseTranslation;
  if AUseTranslation then
    FMessage := ''
  else
    FMessage := AMessageKey;
end;

function RegEx.Validate(const AValue: TValue; const AFieldName: string): TValidationResult;
var
  StrValue: string;
  ErrorMessage: string;
begin
  Result := TValidationResult.Create;

  if not AValue.IsEmpty then
  begin
    // FIX: TValue'dan direkt string al, VarToStr kullanma
    case AValue.TypeInfo.Kind of
      tkString, tkLString, tkWString, tkUString:
        StrValue := AValue.AsString;
    else
      Exit; // String olmayan değerler için regex kontrolü yapma
    end;

    // Skip empty strings if pattern allows it
    if Trim(StrValue) = '' then
      Exit;

    try
      if not TRegEx.IsMatch(StrValue, FPattern) then
      begin
        if FUseTranslation and (FMessageKey <> '') then
          ErrorMessage := TLocalizationManager.Translate(FMessageKey, FMessage)
        else
          ErrorMessage := FMessage;

        Result.AddError(AFieldName, ErrorMessage);
      end;
    except
      on E: Exception do
      begin
        // Invalid regex pattern
        ErrorMessage := Format('Invalid regex pattern "%s": %s', [FPattern, E.Message]);
        Result.AddError(AFieldName, ErrorMessage);
      end;
    end;
  end;
end;

constructor Inherits.Create(const AParentTable: string);
begin
  inherited Create;
  FParentTable := AParentTable;
end;

constructor CreatedAt.Create(const AColumnName: string = 'created_at'; AAutoUpdate: Boolean = True);
begin
  inherited Create;
  FColumnName := AColumnName;
  FAutoUpdate := AAutoUpdate;
end;

constructor UpdatedAt.Create(const AColumnName: string = 'updated_at'; AAutoUpdate: Boolean = True);
begin
  inherited Create;
  FColumnName := AColumnName;
  FAutoUpdate := AAutoUpdate;
end;

constructor CreatedBy.Create(const AColumnName: string = 'created_by'; const AUserIdProvider: string = '');
begin
  inherited Create;
  FColumnName := AColumnName;
  FUserIdProvider := AUserIdProvider;
end;

constructor UpdatedBy.Create(const AColumnName: string = 'updated_by'; const AUserIdProvider: string = '');
begin
  inherited Create;
  FColumnName := AColumnName;
  FUserIdProvider := AUserIdProvider;
end;

constructor SoftDelete.Create(const ADeletedAtColumn: string = 'deleted_at';
                             const ADeletedByColumn: string = '');
begin
  inherited Create;
  FDeletedAtColumn := ADeletedAtColumn;
  FDeletedByColumn := ADeletedByColumn;
end;

constructor HasManyAttribute.Create(const AForeignKeyProperty: string = '';
                                   const ALocalKeyProperty: string = 'Id';
                                   const ARelatedClass: string = '';
                                   AOnDelete: TCascadeAction = caNone;
                                   AOnUpdate: TCascadeAction = caNone;
                                   const AOrderBy: string = '';
                                   const AWhere: string = '');
begin
  inherited Create;
  FForeignKeyProperty := AForeignKeyProperty;
  FLocalKeyProperty := ALocalKeyProperty;
  FRelatedClass := ARelatedClass;
  FOnDelete := AOnDelete;
  FOnUpdate := AOnUpdate;
  FOrderBy := AOrderBy;
  FWhere := AWhere;
end;

constructor HasOneAttribute.Create(const AForeignKeyProperty: string = '';
                                  const ALocalKeyProperty: string = 'Id';
                                  const ARelatedClass: string = '';
                                  AOnDelete: TCascadeAction = caNone;
                                  AOnUpdate: TCascadeAction = caNone);
begin
  inherited Create;
  FForeignKeyProperty := AForeignKeyProperty;
  FLocalKeyProperty := ALocalKeyProperty;
  FRelatedClass := ARelatedClass;
  FOnDelete := AOnDelete;
  FOnUpdate := AOnUpdate;
end;

constructor BelongsToAttribute.Create(const ALocalKeyProperty: string = '';
                                     const ARemoteKeyProperty: string = 'Id';
                                     const ARelatedClass: string = '';
                                     AOnDelete: TCascadeAction = caNone;
                                     AOnUpdate: TCascadeAction = caNone);
begin
  inherited Create;
  FLocalKeyProperty := ALocalKeyProperty;
  FRemoteKeyProperty := ARemoteKeyProperty;
  FRelatedClass := ARelatedClass;
  FOnDelete := AOnDelete;
  FOnUpdate := AOnUpdate;
end;

constructor ManyToManyAttribute.Create(const APivotTable: string;
                                      const ALocalKey: string = '';
                                      const ARemoteKey: string = '';
                                      const ATableName: string = '';
                                      const APivotLocalKey: string = '';
                                      const APivotRemoteKey: string = '';
                                      const AOrderBy: string = '';
                                      const AWhere: string = '');
begin
  inherited Create;
  FPivotTable := APivotTable;
  FLocalKey := ALocalKey;
  FRemoteKey := ARemoteKey;
  FTableName := ATableName;
  FPivotLocalKey := APivotLocalKey;
  FPivotRemoteKey := APivotRemoteKey;
  FOrderBy := AOrderBy;
  FWhere := AWhere;
end;

constructor NotMapped.Create;
begin
  inherited Create;
end;

constructor Transient.Create;
begin
  inherited Create;
end;

constructor Version.Create(const AColumnName: string = 'version');
begin
  inherited Create;
  FColumnName := AColumnName;
end;

constructor JsonColumn.Create(const AColumnName: string = '');
begin
  inherited Create;
  FColumnName := AColumnName;
end;

constructor Enum.Create(const AValues: array of string; const ADefaultValue: string = '');
var
 n1: Integer;
begin
  inherited Create;
  FDefaultValue := ADefaultValue;

  SetLength(FValues, Length(AValues));
  for n1 := 0 to Length(AValues)-1 do
    FValues[n1] := AValues[n1];
end;

constructor ForeignKeyAttribute.Create(const AName, AReferencedTable, AReferencedColumn, AOnDelete, AOnUpdate: string);
begin
//
end;

constructor CheckConstraintAttribute.Create(const AName, AExpression: string);
begin
//
end;

constructor DefaultValueAttribute.Create(const AValue: string);
begin
//
end;

end.
