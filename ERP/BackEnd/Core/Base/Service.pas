
unit Service;

interface

uses
  System.Classes, System.SysUtils, System.Variants, System.Generics.Collections,
  System.Rtti, System.TypInfo, FireDAC.Comp.Client, FireDAC.Comp.DataSet, Data.DB,
  EntityAttributes,
  SharedFormTypes, FilterCriterion, UnitOfWork, Entity, Repository;

type
  TCrudOperation = (coInsert, coUpdate, coDelete);

  IService<T: TEntity> = interface
    ['{61C41E30-4D6E-4474-9529-6BE1133F16B2}']
    function GetUnitOfWork: TUnitOfWork;
    procedure FillEntityFromDataSet(ADataSet: TFDDataSet; AEntity: T);

    property UoW: TUnitOfWork read GetUnitOfWork;
  end;

  IViewService<T: TEntity> = interface(IService<T>)
    function IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean): Boolean; overload;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): T;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): T;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<T>;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): T;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<T>;
  end;

  ICrudService<T: TEntity> = interface(IViewService<T>)
    procedure Add(AEntity: T);
    procedure Update(AEntity: T);
    procedure Delete(AId: Int64);

    procedure BusinessInsert(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean);
    procedure BusinessUpdate(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean);
    procedure BusinessDelete(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean);

    function Clone(ASource: T): T;
  end;

  TService<T: TEntity, constructor> = class(TInterfacedObject, IService<T>)
  private
    function GetUnitOfWork: TUnitOfWork;
    procedure FillNestedEntityFromDataSet(ADataSet: TFDDataSet; AEntity: TObject; AClass: TClass);
    function HasAttribute(AProp: TRttiProperty; AAttrClass: TClass): Boolean;
    function GetColumnAttribute(AProp: TRttiProperty): Column;
    function PascalToSnake(const AStr: string): string;
    function CreateEntityInstanceByClass(AClass: TClass): TObject;
    procedure CloneEntityProperties(ASource, ATarget: TObject; AEntityClass: TClass; ADeepClone: Boolean);
    procedure SetBackReferenceProperty(AChildEntity, AParentEntity: TObject);
    function ExtractGenericTypeFromList(AListType: TRttiType): TClass;
  public
    Filter: TFilterCriteria;
    property UoW: TUnitOfWork read GetUnitOfWork;

    constructor Create();
    destructor Destroy; override;

    procedure FillEntityFromDataSet(ADataSet: TFDDataSet; AEntity: T);

    function Clone(ASource: T): T;
  end;

  TViewService<T: TEntity, constructor> = class(TService<T>)
  private
    FPermissionCode: integer;
    function GetUnitOfWork: TUnitOfWork;
  public
    property UoW: TUnitOfWork read GetUnitOfWork;
    property PermissionCode: Integer read FPermissionCode write FPermissionCode;

    constructor Create();
    destructor Destroy; override;

    function IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean): Boolean; overload;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; virtual; abstract;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): T; virtual; abstract;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): T; virtual; abstract;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<T>; virtual; abstract;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): T; virtual; abstract;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<T>; virtual; abstract;
  end;

  TCrudService<T: TEntity, constructor> = class(TViewService<T>)
  private
    function GetUnitOfWork: TUnitOfWork;
  public
    property UoW: TUnitOfWork read GetUnitOfWork;

    constructor Create();
    destructor Destroy; override;

    procedure Add(AEntity: T); virtual; abstract;
    procedure Update(AEntity: T); virtual; abstract;
    procedure Delete(AId: Int64); virtual; abstract;

    procedure ValidateEntity(AEntity: T); virtual;
    procedure ValidateBusinessRules(AEntity: T; AOperation: TCrudOperation); virtual;
    procedure ValidateAll(AEntity: T; AOperation: TCrudOperation); virtual;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): T; virtual; abstract;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<T>; virtual; abstract;
    procedure BusinessInsert(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean); virtual; abstract;
    procedure BusinessUpdate(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean); virtual; abstract;
    procedure BusinessDelete(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean); virtual; abstract;
  end;

implementation

uses
  EntitySchemaCache;

procedure TCrudService<T>.ValidateEntity(AEntity: T);
var
  ValResult: TValidationResult;
  ErrStr: string;
  Error: TValidationError;
begin
  if not Assigned(AEntity) then Exit;

  ValResult := AEntity.Validate;
  try
    if not ValResult.IsValid then
    begin
      ErrStr := '';
      for Error in ValResult.Errors do
      begin
        if ErrStr <> '' then ErrStr := ErrStr + sLineBreak;
        ErrStr := ErrStr + Error.FieldName + ': ' + Error.Message;
      end;
      raise Exception.Create('Validation Error:' + sLineBreak + ErrStr);
    end;
  finally
    ValResult.Free;
  end;
end;

procedure TCrudService<T>.ValidateBusinessRules(AEntity: T; AOperation: TCrudOperation);
begin
  // Base implementation - override in entity-specific service classes
end;

procedure TCrudService<T>.ValidateAll(AEntity: T; AOperation: TCrudOperation);
begin
  ValidateEntity(AEntity);
  ValidateBusinessRules(AEntity, AOperation);
end;

constructor TCrudService<T>.Create();
begin
  inherited;
end;

destructor TCrudService<T>.Destroy;
begin
  inherited;
end;

function TCrudService<T>.GetUnitOfWork: TUnitOfWork;
begin
  Result := TUnitOfWork.Instance;
end;

function TService<T>.CreateEntityInstanceByClass(AClass: TClass): TObject;
var
  ACtx: TRttiContext;
  rType: TRttiType;
  method: TRttiMethod;
  rMetod: TRttiMethod;
begin
  ACtx := TRttiContext.Create;
  try
    rType := ACtx.GetType(AClass);
    rMetod := nil;

    for method in rType.GetMethods do
    begin
      if method.IsConstructor and (Length(method.GetParameters) = 0) then
      begin
        rMetod := method;
        Break;
      end;
    end;

    if Assigned(rMetod) then
      Result := rMetod.Invoke(rType.AsInstance.MetaclassType, []).AsObject
    else
      raise Exception.CreateFmt('No default constructor found for %s', [AClass.ClassName]);
  finally
    ACtx.Free;
  end;
end;

procedure TService<T>.CloneEntityProperties(ASource, ATarget: TObject; AEntityClass: TClass; ADeepClone: Boolean);
var
  ACtx: TRttiContext;
  schema: TEntitySchema;
  col: TColumnSchema;
  val: TValue;
  LType: TRttiType;
  LProp: TRttiProperty;
  LAttr: TCustomAttribute;
  LSourceNested: TObject;
  LTargetNested: TObject;
  LNestedClass: TClass;
begin
  if not Assigned(ASource) or not Assigned(ATarget) then Exit;

  schema := TEntitySchemaCache.GetSchema(AEntityClass);
  if not Assigned(schema) then Exit;

  for col in schema.Columns do
  begin
    if not col.IsReadable or not col.IsWritable then Continue;

    val := col.Prop.GetValue(ASource);

    // PK + AutoIncrement: hedefte sıfırla (yeni kayıt olacak)
    if col.IsPrimaryKey and col.IsAutoIncrement and not val.IsEmpty then
    begin
      case col.TypeKind of
        tkInteger: col.Prop.SetValue(ATarget, TValue.From<Integer>(0));
        tkInt64:   col.Prop.SetValue(ATarget, TValue.From<Int64>(0));
      end;
    end
    else if not val.IsEmpty then
      col.Prop.SetValue(ATarget, val);
  end;

  // Deep clone: ilişkisel property'ler (BelongsTo)
  ACtx := TRttiContext.Create;
  try
    LType := ACtx.GetType(AEntityClass);
    for LProp in LType.GetProperties do
    begin
      for LAttr in LProp.GetAttributes do
      begin
        if LAttr is BelongsToAttribute then
        begin
          LSourceNested := LProp.GetValue(ASource).AsObject;
          if Assigned(LSourceNested) then
          begin
            LNestedClass := LProp.PropertyType.AsInstance.MetaclassType;
            LTargetNested := LProp.GetValue(ATarget).AsObject;
            if not Assigned(LTargetNested) then
            begin
              LTargetNested := CreateEntityInstanceByClass(LNestedClass);
              LProp.SetValue(ATarget, LTargetNested);
            end;
            CloneEntityProperties(LSourceNested, LTargetNested, LNestedClass, False);
          end;
          Break;
        end;
      end;
    end;
  finally
    ACtx.Free;
  end;
end;

procedure TService<T>.SetBackReferenceProperty(AChildEntity, AParentEntity: TObject);
var
  ACtx: TRttiContext;
  LChildType: TRttiType;
  LProp: TRttiProperty;
  LAttr: TCustomAttribute;
begin
  if (AChildEntity = nil) or (AParentEntity = nil) then Exit;

  ACtx := TRttiContext.Create;
  try
    LChildType := ACtx.GetType(AChildEntity.ClassInfo);
    for LProp in LChildType.GetProperties do
    begin
      if LProp.PropertyType.IsInstance and (LProp.PropertyType.AsInstance.MetaclassType = AParentEntity.ClassType) then
      begin
        for LAttr in LProp.GetAttributes do
        begin
          if LAttr is BelongsToAttribute then
          begin
            LProp.SetValue(AChildEntity, AParentEntity);
            Break;
          end;
        end;
      end;
    end;
  finally
    ACtx.Free;
  end;
end;

function TService<T>.ExtractGenericTypeFromList(AListType: TRttiType): TClass;
var
  ACtx: TRttiContext;
  typeName: string;
  startPos, endPos: Integer;
  genericTypeName: string;
  genericType: TRttiType;
begin
  Result := nil;

  if not Assigned(AListType) then
    Exit;

  typeName := AListType.Name;

  if not typeName.StartsWith('TObjectList<') then
    Exit;

  startPos := Pos('<', typeName);
  endPos := Pos('>', typeName);

  if (startPos > 0) and (endPos > startPos) then
  begin
    ACtx := TRttiContext.Create;
    try
      genericTypeName := Copy(typeName, startPos + 1, endPos - startPos - 1);

      genericType := ACtx.FindType(genericTypeName);

      if not Assigned(genericType) then
      begin
        genericType := ACtx.FindType('System.Generics.Collections.' + genericTypeName);
        if not Assigned(genericType) then
          genericType := ACtx.FindType('Generics.Collections.' + genericTypeName);
      end;

      if Assigned(genericType) and genericType.IsInstance then
        Result := genericType.AsInstance.MetaclassType;
    finally
      ACtx.Free;
    end;
  end;
end;

function TService<T>.Clone(ASource: T): T;
var
  ctx: TRttiContext;
  rType: TRttiType;
  prop: TRttiProperty;
  attr: TCustomAttribute;
  colAttr: Column;
  hasOneAttr: HasOneAttribute;
  hasManyAttr: HasManyAttribute;
  belongsToAttr: BelongsToAttribute;
  propValue: TValue;
  sourceList: TObject;
  targetList: TObject;
  listType: TRttiType;
  countProp: TRttiProperty;
  getItemMethod: TRttiMethod;
  addMethod: TRttiMethod;
  clearMethod: TRttiMethod;
  count, i: Integer;
  sourceItem: TObject;
  clonedItem: TObject;
  sourceNestedEntity: TObject;
  clonedNestedEntity: TObject;
  nestedEntityClass: TClass;
  method: TRttiMethod;
begin
  Result := nil;

  if not Assigned(ASource) then
    Exit;

  ctx := TRttiContext.Create;
  try
    rType := ctx.GetType(T);

    Result := CreateEntityInstanceByClass(T) as T;

    for prop in rType.GetProperties do
    begin
      if not prop.IsReadable or not prop.IsWritable then
        Continue;

      colAttr       := nil;
      hasOneAttr    := nil;
      hasManyAttr   := nil;
      belongsToAttr := nil;

      for attr in prop.GetAttributes do
      begin
        if attr is NotMapped then
        begin
          Break;
        end
        else if attr is Column then
          colAttr := attr as Column
        else if attr is HasOneAttribute then
          hasOneAttr := attr as HasOneAttribute
        else if attr is HasManyAttribute then
          hasManyAttr := attr as HasManyAttribute
        else if attr is BelongsToAttribute then
          belongsToAttr := attr as BelongsToAttribute;
      end;

      if (colAttr = nil) and (hasOneAttr = nil) and (hasManyAttr = nil) and (belongsToAttr = nil) then
        Continue;

      propValue := prop.GetValue(TObject(ASource));

      if Assigned(colAttr) then
      begin
        if colAttr.IsPrimaryKey and colAttr.IsAutoIncrement and not propValue.IsEmpty then
        begin
          case prop.PropertyType.TypeKind of
            tkInteger: prop.SetValue(TObject(Result), propValue);
            tkInt64:   prop.SetValue(TObject(Result), propValue);
          end;
        end
        else
        begin
          if not propValue.IsEmpty then
            prop.SetValue(TObject(Result), propValue);
        end;
      end
      else if Assigned(belongsToAttr) then
      begin
        sourceNestedEntity := propValue.AsObject;
        if Assigned(sourceNestedEntity) then
        begin
          nestedEntityClass := prop.PropertyType.AsInstance.MetaclassType;

          clonedNestedEntity := prop.GetValue(TObject(Result)).AsObject;

          if not Assigned(clonedNestedEntity) then
          begin
            clonedNestedEntity := CreateEntityInstanceByClass(nestedEntityClass);
            prop.SetValue(TObject(Result), clonedNestedEntity);
          end;
          CloneEntityProperties(sourceNestedEntity, clonedNestedEntity, nestedEntityClass, False);
        end;
      end
      else if Assigned(hasOneAttr) then
      begin
        sourceNestedEntity := propValue.AsObject;
        if Assigned(sourceNestedEntity) then
        begin
          nestedEntityClass := prop.PropertyType.AsInstance.MetaclassType;

          clonedNestedEntity := prop.GetValue(TObject(Result)).AsObject;

          if not Assigned(clonedNestedEntity) then
          begin
            clonedNestedEntity := CreateEntityInstanceByClass(nestedEntityClass);
            prop.SetValue(TObject(Result), clonedNestedEntity);
          end;
          CloneEntityProperties(sourceNestedEntity, clonedNestedEntity,
                                nestedEntityClass, False);
        end;
      end
      else if Assigned(hasManyAttr) then
      begin
        sourceList := propValue.AsObject;
        targetList := prop.GetValue(TObject(Result)).AsObject;

        if Assigned(sourceList) and Assigned(targetList) then
        begin
          nestedEntityClass := ExtractGenericTypeFromList(prop.PropertyType);
          if not Assigned(nestedEntityClass) then
            Continue;

          listType := ctx.GetType(sourceList.ClassType);

          countProp := listType.GetProperty('Count');
          if not Assigned(countProp) then
            Continue;

          count := countProp.GetValue(sourceList).AsInteger;
          if count = 0 then
            Continue;

          getItemMethod := nil;
          addMethod     := nil;
          clearMethod   := nil;

          for method in listType.GetMethods do
          begin
            if (method.Name = 'GetItem') and (Length(method.GetParameters) = 1) then
              getItemMethod := method
            else if (method.Name = 'Add') and (Length(method.GetParameters) = 1) then
              addMethod := method
            else if (method.Name = 'Clear') and (Length(method.GetParameters) = 0) then
              clearMethod := method;
          end;

          if not Assigned(getItemMethod) or not Assigned(addMethod) then
            Continue;

          if Assigned(clearMethod) then
            clearMethod.Invoke(targetList, []);

          for i := 0 to count - 1 do
          begin
            sourceItem := getItemMethod.Invoke(sourceList, [i]).AsObject;
            if Assigned(sourceItem) then
            begin
              clonedItem := CreateEntityInstanceByClass(nestedEntityClass);
              SetBackReferenceProperty(clonedItem, TObject(Result));
              CloneEntityProperties(sourceItem, clonedItem, nestedEntityClass, False);
              var LCloneValue: TValue;
              TValue.Make(@clonedItem, clonedItem.ClassInfo, LCloneValue);
              addMethod.Invoke(targetList, [LCloneValue]);
            end;
          end;
        end;
      end;

    end;

  finally
    ctx.Free;
  end;
end;

constructor TService<T>.Create;
begin
  inherited;
  Filter := TFilterCriteria.Create;
end;

destructor TService<T>.Destroy;
begin
  Filter.Free;
  inherited;
end;

// Unit'in private/protected bölümüne ekle
function TService<T>.HasAttribute(AProp: TRttiProperty; AAttrClass: TClass): Boolean;
var
  attr: TCustomAttribute;
begin
  Result := False;
  for attr in AProp.GetAttributes do
    if attr.ClassType = AAttrClass then
      Exit(True);
end;

function TService<T>.GetColumnAttribute(AProp: TRttiProperty): Column;
var
  attr: TCustomAttribute;
begin
  Result := nil;
  for attr in AProp.GetAttributes do
    if attr is Column then
      Exit(attr as Column);
end;

function TService<T>.PascalToSnake(const AStr: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(AStr) do
  begin
    if (i > 1) and CharInSet(AStr[i], ['A'..'Z']) then
      Result := Result + '_';
    Result := Result + LowerCase(AStr[i]);
  end;
end;

procedure TService<T>.FillEntityFromDataSet(ADataSet: TFDDataSet; AEntity: T);
var
  ctx: TRttiContext;
  rType: TRttiType;
  prop: TRttiProperty;
  colAttr: Column;
  field: TField;
  val: TValue;
  ordValue: Integer;
  nestedEntity: TObject;  // inline var yerine burada tanımla
begin
  if not Assigned(AEntity) or not Assigned(ADataSet) then
    Exit;

  ctx := TRttiContext.Create;
  try
    rType := ctx.GetType(AEntity.ClassType);
    for prop in rType.GetProperties do
    begin
      if not prop.IsWritable then
        Continue;

      if HasAttribute(prop, NotMapped) then
        Continue;

      // ✅ Generic GetAttribute<> yerine yardımcı fonksiyon
      colAttr := GetColumnAttribute(prop);

      // -------------------------------------------------------
      // tkClass — BelongsTo / HasOne nested entity doldurma
      // -------------------------------------------------------
      if prop.PropertyType.TypeKind = tkClass then
      begin
        if not HasAttribute(prop, BelongsToAttribute) and
           not HasAttribute(prop, HasOneAttribute) then
          Continue;

        nestedEntity := prop.GetValue(TObject(AEntity)).AsObject;
        if not Assigned(nestedEntity) then
          Continue;

        FillNestedEntityFromDataSet(ADataSet, nestedEntity,
                                    prop.PropertyType.AsInstance.MetaclassType);
        Continue;
      end;

      // -------------------------------------------------------
      // Normal Column mapping with View fallback
      // -------------------------------------------------------
      if Assigned(colAttr) then
        field := ADataSet.FindField(colAttr.Name)
      else
        field := ADataSet.FindField(prop.Name);

      if not Assigned(field) then
        field := ADataSet.FindField(prop.Name);

      if not Assigned(field) then
        field := ADataSet.FindField(PascalToSnake(prop.Name));

      if not Assigned(field) then
        Continue;

      if field.IsNull then
      begin
        prop.SetValue(TObject(AEntity), TValue.Empty);
        Continue;
      end;

      case prop.PropertyType.TypeKind of
        tkUString, tkString, tkLString, tkWString:
          val := field.AsString;

        tkInteger:
          begin
            if prop.PropertyType.IsOrdinal
               and (prop.PropertyType.Handle <> nil)
               and (GetTypeData(prop.PropertyType.Handle)^.OrdType <> otSByte)
            then
              val := TValue.FromOrdinal(prop.PropertyType.Handle, field.AsInteger)
            else
              val := field.AsInteger;
          end;

        tkInt64:
          val := TValue.From<Int64>(field.AsLargeInt);

        tkFloat:
          begin
            case field.DataType of
              ftDate, ftTime, ftDateTime, ftTimeStamp:
                val := TValue.From<TDateTime>(field.AsDateTime);
            else
              val := TValue.From<Double>(field.AsFloat);
            end;
          end;

        tkEnumeration:
          begin
            if SameText(prop.PropertyType.Name, 'Boolean') then
              val := TValue.From<Boolean>(field.AsBoolean)
            else
            begin
              if field.DataType in [ftInteger, ftSmallint, ftWord, ftAutoInc] then
                ordValue := field.AsInteger
              else
                ordValue := GetEnumValue(prop.PropertyType.Handle, field.AsString);
              val := TValue.FromOrdinal(prop.PropertyType.Handle, ordValue);
            end;
          end;
      else
        Continue;
      end;

      prop.SetValue(TObject(AEntity), val);
    end;
  finally
    ctx.Free;
  end;
end;

procedure TService<T>.FillNestedEntityFromDataSet(
  ADataSet: TFDDataSet;
  AEntity: TObject;
  AClass: TClass);
var
  ctx: TRttiContext;
  rType: TRttiType;
  prop: TRttiProperty;
  colAttr: Column;
  field: TField;
  val: TValue;
  ordValue: Integer;
  fieldName: string;
  deepNested: TObject;  // ✅ inline var yerine burada
begin
  if not Assigned(AEntity) or not Assigned(ADataSet) then
    Exit;

  ctx := TRttiContext.Create;
  try
    rType := ctx.GetType(AClass);
    for prop in rType.GetProperties do
    begin
      if not prop.IsWritable then
        Continue;

      if HasAttribute(prop, NotMapped) then
        Continue;

      // Nested içindeki nested entity'leri recursive doldur
      if prop.PropertyType.TypeKind = tkClass then
      begin
        if not HasAttribute(prop, BelongsToAttribute) and
           not HasAttribute(prop, HasOneAttribute) then
          Continue;

        deepNested := prop.GetValue(AEntity).AsObject;
        if Assigned(deepNested) then
          FillNestedEntityFromDataSet(ADataSet, deepNested,
                                      prop.PropertyType.AsInstance.MetaclassType);
        Continue;
      end;

      // ✅ Generic GetAttribute<> yerine yardımcı fonksiyon
      colAttr := GetColumnAttribute(prop);
      if not Assigned(colAttr) then
        Continue;

      fieldName := colAttr.Name;
      field := ADataSet.FindField(fieldName);

      if not Assigned(field) then
        Continue;

      if field.IsNull then
      begin
        prop.SetValue(AEntity, TValue.Empty);
        Continue;
      end;

      case prop.PropertyType.TypeKind of
        tkUString, tkString, tkLString, tkWString:
          val := field.AsString;

        tkInteger:
          begin
            if prop.PropertyType.IsOrdinal
               and (prop.PropertyType.Handle <> nil)
               and (GetTypeData(prop.PropertyType.Handle)^.OrdType <> otSByte)
            then
              val := TValue.FromOrdinal(prop.PropertyType.Handle, field.AsInteger)
            else
              val := field.AsInteger;
          end;

        tkInt64:
          val := TValue.From<Int64>(field.AsLargeInt);

        tkFloat:
          begin
            case field.DataType of
              ftDate, ftTime, ftDateTime, ftTimeStamp:
                val := TValue.From<TDateTime>(field.AsDateTime);
            else
              val := TValue.From<Double>(field.AsFloat);
            end;
          end;

        tkEnumeration:
          begin
            if SameText(prop.PropertyType.Name, 'Boolean') then
              val := TValue.From<Boolean>(field.AsBoolean)
            else
            begin
              if field.DataType in [ftInteger, ftSmallint, ftWord, ftAutoInc] then
                ordValue := field.AsInteger
              else
                ordValue := GetEnumValue(prop.PropertyType.Handle, field.AsString);
              val := TValue.FromOrdinal(prop.PropertyType.Handle, ordValue);
            end;
          end;
      else
        Continue;
      end;

      prop.SetValue(AEntity, val);
    end;
  finally
    ctx.Free;
  end;
end;

function TService<T>.GetUnitOfWork: TUnitOfWork;
begin
  Result := TUnitOfWork.Instance;
end;

constructor TViewService<T>.Create;
begin
  inherited;
end;

destructor TViewService<T>.Destroy;
begin
  inherited;
end;

function TViewService<T>.GetUnitOfWork: TUnitOfWork;
begin
  Result := TUnitOfWork.Instance;
end;

function TViewService<T>.IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean): Boolean;
begin
  Result := Self.UoW.IsAuthorized(Self.PermissionCode, APermissionType, APermissionControl);
end;

end.

