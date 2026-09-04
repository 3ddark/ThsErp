unit Entity;

interface

uses
  SysUtils, StrUtils, Classes, Generics.Collections, System.TypInfo, Rtti,
  FireDAC.Comp.Client, Data.DB, EntityAttributes;

type
  IEntityBase = interface
    ['{1A234C2E-2843-47F0-A997-2434940EFF92}']
    function Validate: TValidationResult;
    function ValidateProperty(const APropertyName: string; const AValue: TValue): TValidationResult;
  end;

  IEntity = interface(IEntityBase)
    ['{03DA6AFF-C934-443B-976E-3D400662465C}']
  end;

  TEntityBase = class(TInterfacedObject, IEntityBase)
  protected
    function ValidateProperty(const APropertyName: string; const AValue: TValue): TValidationResult;
  public
    constructor Create; virtual;
    function Validate: TValidationResult; virtual;
  end;

  TEntity = class(TEntityBase, IEntity)
  private
    FId: Int64;
  protected
    // protected: türemiş sınıflar üzerinden RTTI (TRttiMethod.Invoke) erişebilir.
    // private olduğunda SetValue, TRttiMethod.Invoke ile çağrılamaz →
    // türemiş entity'lerde Id = 0 kalır (exception sessizce yutulur).
    function GetId: Int64;
    procedure SetId(const Value: Int64);
  public
    [Column('id', [cpPrimaryKey, cpAutoIncrement])]
    property Id: Int64 read GetId write SetId;
  end;

  // Composite primary key tabloları için temel sınıf.
  // TEntity'deki auto-increment 'id' kolonu YOKTUR.
  // Alt sınıflar kendi [Column('...', [cpPrimaryKey])] property'lerini tanımlar.
  // Örnek: sys_permission_translation (permission_id + language_id composite PK)
  TCompositeKeyEntity = class(TEntityBase)
  end;

implementation

uses
  LocalizationManager, EntitySchemaCache;

constructor TEntityBase.Create;
begin
  inherited Create;
end;

function TEntity.GetId: Int64;
begin
  Result := FId;
end;

procedure TEntity.SetId(const Value: Int64);
begin
  FId := Value;
end;

function TEntityBase.Validate: TValidationResult;
var
  Schema   : TEntitySchema;
  Col      : TColumnSchema;
  PropVal  : TValue;
  PropRes  : TValidationResult;
  Error    : TValidationError;
  Attr     : TCustomAttribute;
  ValResult: TValidationResult;
begin
  Result := TValidationResult.Create;

  // FIX: TEntitySchemaCache üzerinden schema al — RTTI context açılmıyor
  Schema := TEntitySchemaCache.GetSchema(Self.ClassType);
  if not Assigned(Schema) then
    Exit;

  for Col in Schema.Columns do
  begin
    if not Col.IsReadable then
      Continue;

    try
      PropVal := Col.Prop.GetValue(Self);
      PropRes := TValidationResult.Create;
      try
        for Attr in Col.Prop.GetAttributes do
        begin
          ValResult := nil;

          if Attr is Required then
            ValResult := Required(Attr).Validate(PropVal, Col.PropertyName)
          else if Attr is MinLength then
            ValResult := MinLength(Attr).Validate(PropVal, Col.PropertyName)
          else if Attr is MaxLength then
            ValResult := MaxLength(Attr).Validate(PropVal, Col.PropertyName)
          else if Attr is Range then
            ValResult := Range(Attr).Validate(PropVal, Col.PropertyName)
          else if Attr is Email then
            ValResult := Email(Attr).Validate(PropVal, Col.PropertyName)
          else if Attr is RegEx then
            ValResult := RegEx(Attr).Validate(PropVal, Col.PropertyName);

          if Assigned(ValResult) then
          try
            if not ValResult.IsValid then
              for Error in ValResult.Errors do
                PropRes.AddError(Error.FieldName, Error.Message);
          finally
            ValResult.Free;
          end;
        end;

        if not PropRes.IsValid then
          for Error in PropRes.Errors do
            Result.AddError(Error.FieldName, Error.Message);
      finally
        PropRes.Free;
      end;
    except
      on E: Exception do
        Result.AddError(Col.PropertyName, 'Property validation error: ' + E.Message);
    end;
  end;
end;

function TEntityBase.ValidateProperty(const APropertyName: string; const AValue: TValue): TValidationResult;
var
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  RttiProperty: TRttiProperty;
  Attribute: TCustomAttribute;
  ValidationResult: TValidationResult;
  Error: TValidationError;
begin
  Result := TValidationResult.Create;

  try
    RttiContext := TRttiContext.Create;
    try
      RttiType := RttiContext.GetType(Self.ClassType);
      if not Assigned(RttiType) then
        Exit;

      RttiProperty := RttiType.GetProperty(APropertyName);
      if not Assigned(RttiProperty) then
        Exit;

      // Check all validation attributes
      for Attribute in RttiProperty.GetAttributes do
      begin
        ValidationResult := nil;

        // Required validation
        if Attribute is Required then
          ValidationResult := Required(Attribute).Validate(AValue, APropertyName)
        // MinLength validation
        else if Attribute is MinLength then
          ValidationResult := MinLength(Attribute).Validate(AValue, APropertyName)
        // MaxLength validation
        else if Attribute is MaxLength then
          ValidationResult := MaxLength(Attribute).Validate(AValue, APropertyName)
        // Range validation
        else if Attribute is Range then
          ValidationResult := Range(Attribute).Validate(AValue, APropertyName)
        // Email validation
        else if Attribute is Email then
          ValidationResult := Email(Attribute).Validate(AValue, APropertyName)
        // RegEx validation
        else if Attribute is RegEx then
          ValidationResult := RegEx(Attribute).Validate(AValue, APropertyName);

        // Process validation result
        if Assigned(ValidationResult) then
        try
          if not ValidationResult.IsValid then
          begin
            for Error in ValidationResult.Errors do
              Result.AddError(Error.FieldName, Error.Message);
          end;
        finally
          ValidationResult.Free;
        end;
      end;
    finally
      RttiContext.Free;
    end;
  except
    on E: Exception do
    begin
      Result.AddError(APropertyName, TLocalizationManager.Translate(TLangKeys.TMessage.ValidationErrorTitle, 'Validation error') + ': ' + E.Message);
    end;
  end;
end;

end.
