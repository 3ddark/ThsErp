unit RepositoryORM;

interface

uses
  System.SysUtils, System.StrUtils, System.Classes, System.Variants, Data.DB,
  System.TypInfo, System.Rtti, System.Generics.Collections, System.Types,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  Entity, EntityAttributes, FilterCriterion;

type
  TIncludeOption = (
    ioIncludeNone,          // Load only main entity
    ioIncludeChildren,      // Load child entities (HasMany relations)
    ioIncludeParent,        // Load parent entities (BelongsTo relations)
    ioIncludeGrandChildren, // Load children of children (2 levels deep)
    ioIncludeAll,           // Load all nested entities
    ioIncludeSpecific       // Load specific relations (use with relation names)
  );
  TIncludeOptions = set of TIncludeOption;

  TRelationNames = TArray<string>;


  TCascadeOperation = (coInsert, coUpdate, coDelete);
  TCascadeOperations = set of TCascadeOperation;

  IRepositoryORM<T: TEntity> = interface
    ['{808825C5-94CA-4B8F-BCEA-D351F4F6813E}']
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;

    function FindById(AId: TValue; ALock: Boolean = False; AInclude: TIncludeOptions = [ioIncludeNone]; ARelations: TRelationNames = nil): T;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AInclude: TIncludeOptions = [ioIncludeNone]; ARelations: TRelationNames = nil): T;
    function Find(AFilter: TFilterCriteria; ALock: Boolean = False; AInclude: TIncludeOptions = [ioIncludeNone]; ARelations: TRelationNames = nil): TList<T>;

    procedure Add(AModel: T; ACascade: TCascadeOperations = []); overload;
    procedure AddBatch(AModels: TArray<T>; ACascade: TCascadeOperations = []); overload;

    procedure Update(AModel: T; ACascade: TCascadeOperations = []);
    procedure UpdateBatch(AModels: TArray<T>; ACascade: TCascadeOperations = []); overload;

    procedure Delete(AID: Int64; ACascade: TCascadeOperations = []); overload;
    procedure Delete(AModel: T; ACascade: TCascadeOperations = []); overload;
    procedure DeleteBatch(AModels: TArray<T>; ACascade: TCascadeOperations = []); overload;
    procedure DeleteBatch(AIDs: TArray<Int64>; ACascade: TCascadeOperations = []); overload;
    procedure DeleteBatch(AFilter: TFilterCriteria; ACascade: TCascadeOperations = []); overload;

    function Clone(ASource: T): T;
  end;

  TRepositoryORM<T: TEntity> = class(TInterfacedObject, IRepositoryORM<T>)
  private
    FConnection: TFDConnection;
    ACtx: TRttiContext;

    function SnakeToPascal(const S: string): string;
    function GenerateSelectSql(AClass: TClass; const AWhereClause: string = ''): string;
    function GetColumnNameForProperty(const APropertyName: string): string; overload;
    function GetColumnNameForProperty(AClass: TClass; const APropertyName: string): string; overload;
    function GetPrimaryKeyColumn(AClass: TClass): string;
    function GetColumnName(AProp: TRttiProperty): string;
    function CreateEntityInstanceByClass(AClass: TClass): TObject;
    function ExtractGenericTypeFromList(AListType: TRttiType): TClass;
    procedure FillEntityFromDataSet(AEntity: TObject; ADataSet: TFDQuery);
    procedure FillNestedEntitiesWithInclude(AEntity: TObject; AInclude: TIncludeOptions; ARelations: TRelationNames = nil);
    procedure LoadChildEntitiesWithInclude(AEntity: TObject; AInclude: TIncludeOptions; ARelations: TRelationNames);
    procedure LoadParentEntitiesWithInclude(AEntity: TObject; AInclude: TIncludeOptions; ARelations: TRelationNames);
    procedure LoadChildProperty(AEntity: TObject; AProp: TRttiProperty; AHasManyAttr: HasManyAttribute);
    procedure LoadParentProperty(AEntity: TObject; AProp: TRttiProperty; ABelongsToAttr: BelongsToAttribute);
    procedure SetBackReferenceProperty(AChildEntity, AParentEntity: TObject);
    procedure LoadGrandChildEntitiesRecursive(AEntity: TObject);
    procedure LoadSpecificRelationsOnly(AEntity: TObject; ARelations: TRelationNames);
    function ShouldLoadThisRelation(const ARelationName: string; ARelations: TRelationNames; AInclude: TIncludeOptions): Boolean;
    function IsChildRelationProperty(AProp: TRttiProperty): Boolean;
    procedure AddToList(AList: TObject; AListType: TClass; AItem: TObject);
    function GetListCount(AList: TObject): Integer;
    function GetListItem(AList: TObject; AIndex: Integer): TObject;
    procedure ProcessHasManyInserts(AModel: T; AParentId: Int64);
    procedure InsertNestedEntity(AEntity: TObject; AEntityClass: TClass);
    procedure ProcessHasManyUpdates(AModel: T; AParentId: Int64);
    procedure UpdateNestedEntity(AEntity: TObject; AEntityClass: TClass);
    procedure ProcessCascadeDeletes(AModel: T; ACascade: TCascadeOperations);
    procedure CloneEntityProperties(ASource, ATarget: TObject; AEntityClass: TClass; ADeepClone: Boolean);
  protected
    function Connection: TFDConnection;
    function GetTableName(AClass: TClass): string;
    function GetFullTableName(AClass: TClass): string;
  public
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; virtual;

    function FindById(AId: TValue; ALock: Boolean = False; AInclude: TIncludeOptions = [ioIncludeNone]; ARelations: TRelationNames = nil): T; virtual;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AInclude: TIncludeOptions = [ioIncludeNone]; ARelations: TRelationNames = nil): T; virtual;
    function Find(AFilter: TFilterCriteria; ALock: Boolean = False; AInclude: TIncludeOptions = [ioIncludeNone]; ARelations: TRelationNames = nil): TList<T>; virtual;

    procedure Add(AModel: T; ACascade: TCascadeOperations = []); virtual;
    procedure AddBatch(AModels: TArray<T>; ACascade: TCascadeOperations = []); virtual;

    procedure Update(AModel: T; ACascade: TCascadeOperations = []); virtual;
    procedure UpdateBatch(AModels: TArray<T>; ACascade: TCascadeOperations = []); virtual;

    procedure Delete(AID: Int64; ACascade: TCascadeOperations = []); overload; virtual;
    procedure Delete(AModel: T; ACascade: TCascadeOperations = []); overload; virtual;
    procedure DeleteBatch(AModels: TArray<T>; ACascade: TCascadeOperations = []); reintroduce; overload; virtual;
    procedure DeleteBatch(AIDs: TArray<Int64>; ACascade: TCascadeOperations = []); reintroduce; overload; virtual;
    procedure DeleteBatch(AFilter: TFilterCriteria; ACascade: TCascadeOperations = []); reintroduce; overload; virtual;

    function Clone(ASource: T): T;

    constructor Create(AConnection: TFDConnection);
    destructor Destroy; override;
  end;

implementation

uses
  EntitySchemaCache, Logger;

function PropName(const APropExpr): string;
var
  PropName: string;
  i: Integer;
begin
  PropName := GetEnumName(TypeInfo(TValue), Integer(APropExpr));
  for i := Low(PropName) to High(PropName) do
    if PropName[i] = '.' then
      Exit(Copy(PropName, i + 1));

  Result := PropName;
end;

constructor TRepositoryORM<T>.Create(AConnection: TFDConnection);
begin
  if AConnection = nil then
    raise Exception.Create('Connection Required');

  ACtx := TRttiContext.Create;
  FConnection := AConnection;
end;

destructor TRepositoryORM<T>.Destroy;
begin
  ACtx.Free;
  inherited;
end;

function TRepositoryORM<T>.Connection: TFDConnection;
begin
  Result := FConnection;
end;

function TRepositoryORM<T>.GetTableName(AClass: TClass): string;
begin
  Result := TEntitySchemaCache.GetSchema(AClass).TableName;
end;

procedure TRepositoryORM<T>.InsertNestedEntity(AEntity: TObject; AEntityClass: TClass);
var
  query  : TFDQuery;
  schema : TEntitySchema;
  col    : TColumnSchema;
  pkCol  : TColumnSchema;
  propValue  : TValue;
  insertedId : Int64;
begin
  if not Assigned(AEntity) then Exit;

  schema := TEntitySchemaCache.GetSchema(AEntityClass);
  if not Assigned(schema) or (schema.InsertSQL = '') then Exit;

  query := TFDQuery.Create(nil);
  try
    query.Connection := FConnection;
    query.SQL.Text   := schema.InsertSQL;

    for col in schema.InsertColumns do
    begin
      propValue := col.Prop.GetValue(AEntity);
      if not propValue.IsEmpty then
        query.ParamByName(col.ColumnName).Value := propValue.AsVariant
      else
        query.ParamByName(col.ColumnName).Value := Null;
    end;

    query.Open;

    if not query.IsEmpty then
    begin
      insertedId := query.Fields[0].AsLargeInt;
      if schema.ByProperty.TryGetValue(schema.PKProperty, pkCol) then
        pkCol.Prop.SetValue(AEntity, TValue.From<Int64>(insertedId));
    end;
  finally
    query.Free;
  end;
end;

procedure TRepositoryORM<T>.ProcessHasManyInserts(AModel: T; AParentId: Int64);
var
  rType: TRttiType;
  prop: TRttiProperty;
  attr: TCustomAttribute;
  hasManyAttr: HasManyAttribute;
  nestedList: TObject;
  nestedEntityClass: TClass;
  count, i: Integer;
  nestedEntity: TObject;
  foreignKeyProp: TRttiProperty;
  propValue: TValue;
begin
  rType := ACtx.GetType(T);

  for prop in rType.GetProperties do
  begin
    hasManyAttr := nil;
    for attr in prop.GetAttributes do
    begin
      if attr is HasManyAttribute then
      begin
        hasManyAttr := attr as HasManyAttribute;
        Break;
      end;
    end;

    if not Assigned(hasManyAttr) then
      Continue;

    propValue := prop.GetValue(TObject(AModel));
    nestedList := propValue.AsObject;
    if not Assigned(nestedList) then
      Continue;

    nestedEntityClass := ExtractGenericTypeFromList(prop.PropertyType);
    if not Assigned(nestedEntityClass) then
      Continue;

    count := GetListCount(nestedList);
    if count = 0 then
      Continue;

    for i := 0 to count - 1 do
    begin
      nestedEntity := GetListItem(nestedList, i);
      if not Assigned(nestedEntity) then
        Continue;

      foreignKeyProp := ACtx.GetType(nestedEntityClass).GetProperty(hasManyAttr.ForeignKeyProperty);
      if Assigned(foreignKeyProp) and foreignKeyProp.IsWritable then
      begin
        foreignKeyProp.SetValue(nestedEntity, TValue.From<Int64>(AParentId));
      end
      else
      begin
        Continue;
      end;

      InsertNestedEntity(nestedEntity, nestedEntityClass);
    end;
  end;
end;

function TRepositoryORM<T>.GetFullTableName(AClass: TClass): string;
begin
  Result := TEntitySchemaCache.GetSchema(AClass).FullTableName;
end;

function TRepositoryORM<T>.GetPrimaryKeyColumn(AClass: TClass): string;
var schema: TEntitySchema;
begin
  schema := TEntitySchemaCache.GetSchema(AClass);
  if Assigned(schema) and (schema.PKColumn <> '') then
    Result := schema.PKColumn
  else
    Result := 'id';
end;

function TRepositoryORM<T>.GetColumnName(AProp: TRttiProperty): string;
var
  attr: TCustomAttribute;
  colAttr: Column;
begin
  Result := LowerCase(AProp.Name);

  for attr in AProp.GetAttributes do
  begin
    if attr is Column then
    begin
      colAttr := attr as Column;
      if colAttr.Name <> '' then
      begin
        Result := colAttr.Name;
        Break;
      end;
    end;
  end;
end;

function TRepositoryORM<T>.GenerateSelectSql(AClass: TClass; const AWhereClause: string): string;
var schema: TEntitySchema;
begin
  schema := TEntitySchemaCache.GetSchema(AClass);
  if Assigned(schema) then
    Result := schema.SelectSQL
  else
    Result := 'SELECT * FROM ' + GetFullTableName(AClass);

  if AWhereClause <> '' then
    Result := Result + ' WHERE ' + AWhereClause;
end;

procedure TRepositoryORM<T>.FillEntityFromDataSet(AEntity: TObject; ADataSet: TFDQuery);
var
  schema    : TEntitySchema;
  col       : TColumnSchema;
  field     : TField;
  propValue : TValue;
begin
  if not Assigned(AEntity) or not Assigned(ADataSet) then Exit;

  schema := TEntitySchemaCache.GetSchema(AEntity.ClassType);
  if not Assigned(schema) then Exit;

  for col in schema.Columns do
  begin
    if not col.IsWritable then Continue;

    field := ADataSet.FindField(col.ColumnName);
    if not Assigned(field) then Continue;

    if field.IsNull then
    begin
      col.Prop.SetValue(AEntity, TValue.Empty);
      Continue;
    end;

    case col.TypeKind of
      tkInteger:
        if col.TypeName = 'SmallInt' then
          propValue := TValue.From<SmallInt>(field.AsInteger)
        else
          propValue := TValue.From<Integer>(field.AsInteger);
      tkInt64:
        propValue := TValue.From<Int64>(field.AsLargeInt);
      tkFloat:
        if col.TypeHandle = TypeInfo(TDateTime) then
          propValue := TValue.From<TDateTime>(field.AsDateTime)
        else if col.TypeHandle = TypeInfo(Single) then
          propValue := TValue.From<Single>(field.AsSingle)
        else
          propValue := TValue.From<Double>(field.AsFloat);
      tkString, tkLString, tkWString, tkUString:
        propValue := TValue.From<string>(field.AsString);
      tkEnumeration:
        if col.TypeHandle = TypeInfo(Boolean) then
          propValue := TValue.From<Boolean>(field.AsBoolean)
        else
          propValue := TValue.FromOrdinal(col.TypeHandle, field.AsInteger);
    else
      Continue;  // tkClass vs. gibi beklenmeyen tipler
    end;

    try
      col.Prop.SetValue(AEntity, propValue);
    except
      // Tip uyuşmazlığı — sustur, diğer kolonlara devam et
    end;
  end;
end;

procedure TRepositoryORM<T>.FillNestedEntitiesWithInclude(AEntity: TObject; AInclude: TIncludeOptions; ARelations: TRelationNames = nil);
begin
  if (AInclude = [ioIncludeNone]) or (AEntity = nil) then
    Exit;

  if ioIncludeAll in AInclude then
  begin
    LoadChildEntitiesWithInclude(AEntity, [ioIncludeAll], nil);
    LoadParentEntitiesWithInclude(AEntity, [ioIncludeAll], nil);
    if ioIncludeGrandChildren in AInclude then
      LoadGrandChildEntitiesRecursive(AEntity);
    Exit;
  end;

  if ioIncludeChildren in AInclude then
    LoadChildEntitiesWithInclude(AEntity, AInclude, ARelations);

  if ioIncludeParent in AInclude then
    LoadParentEntitiesWithInclude(AEntity, AInclude, ARelations);

  if ioIncludeGrandChildren in AInclude then
    LoadGrandChildEntitiesRecursive(AEntity);

  if ioIncludeSpecific in AInclude then
    LoadSpecificRelationsOnly(AEntity, ARelations);
end;

procedure TRepositoryORM<T>.LoadChildEntitiesWithInclude(AEntity: TObject; AInclude: TIncludeOptions; ARelations: TRelationNames);
var
  LType: TRttiType;
  LProp: TRttiProperty;
  LRelationName: string;
  LHasManyAttr: HasManyAttribute;
  LAttr: TCustomAttribute;
  LFound: Boolean;
begin
  LType := ACtx.GetType(AEntity.ClassInfo);

  for LProp in LType.GetProperties do
  begin
    LFound := False;
    LHasManyAttr := nil;

    for LAttr in LProp.GetAttributes do
    begin
      if LAttr is HasManyAttribute then
      begin
        LHasManyAttr := HasManyAttribute(LAttr);
        LFound := True;
        Break;
      end;
    end;

    if LFound then
    begin
      LRelationName := LProp.Name;

      if ShouldLoadThisRelation(LRelationName, ARelations, AInclude) then
      begin
        LoadChildProperty(AEntity, LProp, LHasManyAttr);
      end;
    end;
  end;
end;

procedure TRepositoryORM<T>.LoadParentEntitiesWithInclude(AEntity: TObject; AInclude: TIncludeOptions; ARelations: TRelationNames);
var
  LType: TRttiType;
  LProp: TRttiProperty;
  LRelationName: string;
  LBelongsToAttr: BelongsToAttribute;
  LAttr: TCustomAttribute;
  LFound: Boolean;
begin
  LType := ACtx.GetType(AEntity.ClassInfo);

  for LProp in LType.GetProperties do
  begin
    LFound := False;
    LBelongsToAttr := nil;

    for LAttr in LProp.GetAttributes do
    begin
      if LAttr is BelongsToAttribute then
      begin
        LBelongsToAttr := BelongsToAttribute(LAttr);
        LFound := True;
        Break;
      end;
    end;

    if LFound then
    begin
      LRelationName := LProp.Name;

      if ShouldLoadThisRelation(LRelationName, ARelations, AInclude) then
      begin
        LoadParentProperty(AEntity, LProp, LBelongsToAttr);
      end;
    end;
  end;
end;

procedure TRepositoryORM<T>.LoadChildProperty(AEntity: TObject; AProp: TRttiProperty; AHasManyAttr: HasManyAttribute);
var
  LQuery: TFDQuery;
  LChildClass: TClass;
  LChildEntity: TObject;
  LListValue: TValue;
  LList: TObject;
  LForeignKey: string;
  LParentId: TValue;
  LParentIdProp, LChildIdProp: TRttiProperty;
  LParentType: TRttiType;
  LMethod: TRttiMethod;
  LSql: string;
  LWhereClause: string;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    LChildClass := ExtractGenericTypeFromList(AProp.PropertyType);
    if LChildClass = nil then
      Exit;

    LParentType := ACtx.GetType(AEntity.ClassInfo);
    if AHasManyAttr.LocalKeyProperty <> ''
    then  LParentIdProp := LParentType.GetProperty(AHasManyAttr.LocalKeyProperty)
    else  LParentIdProp := LParentType.GetProperty('Id');
    if LParentIdProp = nil then
      Exit;

    LParentId := LParentIdProp.GetValue(AEntity);
    if LParentId.IsEmpty then
      Exit;

    if AHasManyAttr.ForeignKeyProperty <> '' then
    begin
      LForeignKey := AHasManyAttr.ForeignKeyProperty;

      LParentType := ACtx.GetType(LChildClass);
      LChildIdProp := LParentType.GetProperty(LForeignKey);
      LForeignKey := GetColumnNameForProperty(LChildClass, LChildIdProp.Name);
    end
    else
      LForeignKey := Format('%s_id', [GetTableName(AEntity.ClassInfo).ToLower]);

    LWhereClause := Format('%s = %s', [LForeignKey, QuotedStr(LParentId.ToString)]);

    LSql := GenerateSelectSql(LChildClass, LWhereClause);
    LQuery.SQL.Text := LSql;
    LQuery.Open;

    GLogger.InfoFmt('SQL: %s', [LSql]);

    LListValue := AProp.GetValue(AEntity);
    LList := LListValue.AsObject;
    if LList = nil then
      Exit;

    LMethod := ACtx.GetType(LList.ClassType).GetMethod('Clear');
    LMethod.Invoke(LList, []);

    LQuery.First;
    while not LQuery.Eof do
    begin
      LChildEntity := CreateEntityInstanceByClass(LChildClass);
      FillEntityFromDataSet(LChildEntity, LQuery);

      SetBackReferenceProperty(LChildEntity, AEntity);

      AddToList(LList, LChildClass, LChildEntity);

      LQuery.Next;
    end;

    LListValue := TValue.From<TObject>(LList);
    AProp.SetValue(AEntity, LListValue);
  finally
    LQuery.Free;
  end;
end;

procedure TRepositoryORM<T>.SetBackReferenceProperty(AChildEntity, AParentEntity: TObject);
var
  LChildType: TRttiType;
  LProp: TRttiProperty;
  LAttr: TCustomAttribute;
begin
  if (AChildEntity = nil) or (AParentEntity = nil) then Exit;

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
end;

procedure TRepositoryORM<T>.LoadParentProperty(AEntity: TObject; AProp: TRttiProperty; ABelongsToAttr: BelongsToAttribute);
var
  LQuery: TFDQuery;
  LParentClass: TClass;
  LParentEntity: TObject;
  LForeignKey: string;
  LForeignIdValue: TValue;
  LForeignIdProp: TRttiProperty;
  LEntityType: TRttiType;
  LSql: string;
  LWhereClause: string;
  LParentValue: TValue;
  LExistingValue: TValue;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    LParentClass := AProp.PropertyType.AsInstance.MetaclassType;
    if LParentClass = nil then
      Exit;

    LEntityType := ACtx.GetType(AEntity.ClassInfo);

    // LocalKeyProperty zaten Pascal property adı (örn: 'CountryId').
    // SnakeToPascal çağırmak 'CountryId' → 'Countryid' yaparak property'yi bulamaz.
    // LocalKeyProperty boşsa, property adından otomatik türet (snake_case → PascalCase).
    if ABelongsToAttr.LocalKeyProperty <> '' then
      LForeignIdProp := LEntityType.GetProperty(ABelongsToAttr.LocalKeyProperty)
    else
    begin
      LForeignKey    := Format('%s_id', [AProp.Name.ToLower]);
      LForeignIdProp := LEntityType.GetProperty(SnakeToPascal(LForeignKey));
    end;

    if LForeignIdProp = nil then
      Exit;

    LForeignIdValue := LForeignIdProp.GetValue(AEntity);
    if LForeignIdValue.IsEmpty then
      Exit;

    LWhereClause := Format('%s = %s', [GetPrimaryKeyColumn(LParentClass), QuotedStr(LForeignIdValue.ToString)]);
    LSql := GenerateSelectSql(LParentClass, LWhereClause);
    LQuery.SQL.Text := LSql;
    LQuery.Open;

    GLogger.InfoFmt('SQL: %s', [LSql]);

    if not LQuery.IsEmpty then
    begin
      LExistingValue := AProp.GetValue(AEntity);
      LParentEntity := LExistingValue.AsObject;
      if not Assigned(LParentEntity) then
      begin
        LParentEntity := CreateEntityInstanceByClass(LParentClass);
        LParentValue := TValue.From<TObject>(LParentEntity);
        AProp.SetValue(AEntity, LParentValue);
      end;
      FillEntityFromDataSet(LParentEntity, LQuery);
    end;

  finally
    LQuery.Free;
  end;
end;

procedure TRepositoryORM<T>.LoadGrandChildEntitiesRecursive(AEntity: TObject);
var
  LType: TRttiType;
  LProp: TRttiProperty;
  LList: TObject;
  LListValue: TValue;
  LChildEntity: TObject;
  LIndex: Integer;
begin
  LType := ACtx.GetType(AEntity.ClassInfo);

  for LProp in LType.GetProperties do
  begin
    if IsChildRelationProperty(LProp) then
    begin
      LListValue := LProp.GetValue(AEntity);
      if not LListValue.IsEmpty then
      begin
        LList := LListValue.AsObject;
        if LList <> nil then
        begin
          for LIndex := 0 to GetListCount(LList) - 1 do
          begin
            LChildEntity := GetListItem(LList, LIndex);
            if LChildEntity <> nil then
            begin
              FillNestedEntitiesWithInclude(LChildEntity, [ioIncludeAll], nil);
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TRepositoryORM<T>.LoadSpecificRelationsOnly(AEntity: TObject; ARelations: TRelationNames);
begin
  if ARelations = nil then
    Exit;

  LoadChildEntitiesWithInclude(AEntity, [ioIncludeSpecific], ARelations);
  LoadParentEntitiesWithInclude(AEntity, [ioIncludeSpecific], ARelations);
end;

function TRepositoryORM<T>.ShouldLoadThisRelation(const ARelationName: string; ARelations: TRelationNames; AInclude: TIncludeOptions): Boolean;
var
  LRelation: string;
begin
  if ioIncludeAll in AInclude then
  begin
    Result := True;
    Exit;
  end;

  if ioIncludeSpecific in AInclude then
  begin
    Result := False;
    if ARelations <> nil then
    begin
      for LRelation in ARelations do
      begin
        if SameText(LRelation, ARelationName) then
        begin
          Result := True;
          Break;
        end;
      end;
    end;
    Exit;
  end;

  Result := True;
end;

function TRepositoryORM<T>.SnakeToPascal(const S: string): string;
var
  i: Integer;
  UpperNext: Boolean;
begin
  Result := '';
  UpperNext := True;

  for i := 1 to Length(S) do
  begin
    if S[i] = '_' then
      UpperNext := True
    else
    begin
      if UpperNext then
      begin
        Result := Result + UpCase(S[i]);
        UpperNext := False;
      end
      else
        Result := Result + LowerCase(S[i]);
    end;
  end;
end;

function TRepositoryORM<T>.IsChildRelationProperty(AProp: TRttiProperty): Boolean;
var
  LAttr: TCustomAttribute;
begin
  Result := False;
  for LAttr in AProp.GetAttributes do
  begin
    if LAttr is HasManyAttribute then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure TRepositoryORM<T>.AddToList(AList: TObject; AListType: TClass; AItem: TObject);
var
  rType: TRttiType;
  addMethod: TRttiMethod;
  LResult: TValue;
  LItemValue: TValue;
begin
  rType := ACtx.GetType(AList.ClassType);
  addMethod := rType.GetMethod('Add');

  if Assigned(addMethod) then
  begin
    // TValue.From<TObject>(AItem) statik tip kontrolünde başarısız olabilir:
    // RTTI, TValue'nun TypeInfo'suna (TObject) bakarak TObjectList<TConcreteType>.Add
    // parametresine geçemeyeceğini düşünür → "Invalid class typecast".
    // TValue.Make ile nesnenin gerçek runtime ClassInfo'su kullanılır → güvenli cast.
    TValue.Make(@AItem, AItem.ClassInfo, LItemValue);
    LResult := addMethod.Invoke(AList, [LItemValue]);

    if LResult.IsType<Integer> then
      GLogger.Debug('Item added at index: ' + IntToStr(LResult.AsInteger));
  end
  else
    raise Exception.Create('Add method not found on: ' + AList.ClassName);
end;

function TRepositoryORM<T>.GetListCount(AList: TObject): Integer;
var
  LType: TRttiType;
  LProp: TRttiProperty;
begin
  Result := 0;

  LType := ACtx.GetType(AList.ClassInfo);
  LProp := LType.GetProperty('Count');
  if LProp <> nil then
    Result := LProp.GetValue(AList).AsInteger;
end;

function TRepositoryORM<T>.GetListItem(AList: TObject; AIndex: Integer): TObject;
var
  LType: TRttiType;
  LMethod: TRttiMethod;
  LIndexedProp: TRttiIndexedProperty;
begin
  Result := nil;
  LType := ACtx.GetType(AList.ClassInfo);

  LMethod := LType.GetMethod('GetItem');
  if LMethod <> nil then
  begin
    Result := LMethod.Invoke(AList, [AIndex]).AsObject;
  end
  else
  begin
    for LIndexedProp in LType.GetIndexedProperties do
    begin
      if LIndexedProp.Name = 'Items' then
      begin
        Result := LIndexedProp.GetValue(AList, [AIndex]).AsObject;
        Break;
      end;
    end;
  end;
end;

function TRepositoryORM<T>.CreateEntityInstanceByClass(AClass: TClass): TObject;
var
  rType: TRttiType;
  method: TRttiMethod;
  rMetod: TRttiMethod;
begin
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
end;

function TRepositoryORM<T>.ExtractGenericTypeFromList(AListType: TRttiType): TClass;
var
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
  end;
end;

procedure TRepositoryORM<T>.ProcessHasManyUpdates(AModel: T; AParentId: Int64);
var
  rType: TRttiType;
  prop, prop2: TRttiProperty;
  attr: TCustomAttribute;
  hasManyAttr: HasManyAttribute;
  nestedList: TObject;
  nestedEntityClass: TClass;
  listType: TRttiType;
  countProp: TRttiProperty;
  getItemMethod: TRttiMethod;
  count, i: Integer;
  nestedEntity: TObject;
  filterProp: TRttiProperty;
  propValue: TValue;
  method: TRttiMethod;
  nestedEntityId: TValue;
  nestedEntityIdProp: TRttiProperty;
begin
  rType := ACtx.GetType(T);

  for prop in rType.GetProperties do
  begin
    hasManyAttr := nil;

    for attr in prop.GetAttributes do
    begin
      if attr is HasManyAttribute then
      begin
        hasManyAttr := attr as HasManyAttribute;
        Break;
      end;
    end;

    if not Assigned(hasManyAttr) then
      Continue;

    propValue := prop.GetValue(TObject(AModel));
    nestedList := propValue.AsObject;
    if not Assigned(nestedList) then
      Continue;

    nestedEntityClass := ExtractGenericTypeFromList(prop.PropertyType);
    if not Assigned(nestedEntityClass) then
      Continue;

    listType := ACtx.GetType(nestedList.ClassType);
    countProp := listType.GetProperty('Count');
    if not Assigned(countProp) then
      Continue;

    count := countProp.GetValue(nestedList).AsInteger;
    if count = 0 then
      Continue;

    getItemMethod := nil;
    for method in listType.GetMethods do
    begin
      if (method.Name = 'GetItem') and (Length(method.GetParameters) = 1) then
      begin
        getItemMethod := method;
        Break;
      end;
    end;

    if not Assigned(getItemMethod) then
      Continue;

    for i := 0 to count - 1 do
    begin
      nestedEntity := getItemMethod.Invoke(nestedList, [i]).AsObject;
      if not Assigned(nestedEntity) then
        Continue;

      filterProp := ACtx.GetType(nestedEntityClass).GetProperty(hasManyAttr.LocalKeyProperty);
      if Assigned(filterProp) and filterProp.IsWritable then
        filterProp.SetValue(nestedEntity, TValue.From<Int64>(AParentId));

      nestedEntityIdProp := nil;
      for prop2 in ACtx.GetType(nestedEntityClass).GetProperties do
      begin
        for attr in prop2.GetAttributes do
        begin
          if attr is Column then
          begin
            if (attr as Column).IsPrimaryKey then
            begin
              nestedEntityIdProp := prop2;
              Break;
            end;
          end;
        end;
        if Assigned(nestedEntityIdProp) then
          Break;
      end;

      if Assigned(nestedEntityIdProp) then
      begin
        nestedEntityId := nestedEntityIdProp.GetValue(nestedEntity);

        if nestedEntityId.IsEmpty or (nestedEntityId.AsInt64 <= 0) then
        begin
          InsertNestedEntity(nestedEntity, nestedEntityClass);
        end
        else
        begin
          UpdateNestedEntity(nestedEntity, nestedEntityClass);
        end;
      end;
    end;
  end;
end;

procedure TRepositoryORM<T>.UpdateNestedEntity(AEntity: TObject; AEntityClass: TClass);
var
  query      : TFDQuery;
  schema     : TEntitySchema;
  col, pkCol : TColumnSchema;
  propValue  : TValue;
  pkValue    : TValue;
begin
  if not Assigned(AEntity) then Exit;

  schema := TEntitySchemaCache.GetSchema(AEntityClass);
  if not Assigned(schema) or (schema.UpdateSQL = '') then Exit;

  if not schema.ByProperty.TryGetValue(schema.PKProperty, pkCol) then Exit;

  pkValue := pkCol.Prop.GetValue(AEntity);
  if pkValue.IsEmpty or (pkValue.AsInt64 <= 0) then Exit;

  query := TFDQuery.Create(nil);
  try
    query.Connection := FConnection;
    query.SQL.Text   := schema.UpdateSQL;

    query.ParamByName('pk_value').Value := pkValue.AsVariant;

    for col in schema.UpdateColumns do
    begin
      propValue := col.Prop.GetValue(AEntity);
      if not propValue.IsEmpty then
        query.ParamByName(col.ColumnName).Value := propValue.AsVariant
      else
        query.ParamByName(col.ColumnName).Value := Null;
    end;

    query.ExecSQL;
  finally
    query.Free;
  end;
end;

procedure TRepositoryORM<T>.CloneEntityProperties(ASource, ATarget: TObject; AEntityClass: TClass; ADeepClone: Boolean);
var
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
end;

procedure TRepositoryORM<T>.ProcessCascadeDeletes(AModel: T; ACascade: TCascadeOperations);
var
  rType: TRttiType;
  prop: TRttiProperty;
  attr: TCustomAttribute;
  hasManyAttr: HasManyAttribute;
  nestedEntityClass: TClass;
  deleteQuery: TFDQuery;
  deleteSql: string;
  filterProp: TRttiProperty;
  filterValue: TValue;
  valueColumnName: string;
  valueProp: TRttiProperty;
begin
  if not (coDelete in ACascade) then
    Exit;

  rType := ACtx.GetType(T);

  for prop in rType.GetProperties do
  begin
    hasManyAttr := nil;

    for attr in prop.GetAttributes do
    begin
      if attr is HasManyAttribute then
      begin
        hasManyAttr := attr as HasManyAttribute;
        Break;
      end;
    end;

    if not Assigned(hasManyAttr) then
      Continue;

    filterProp := rType.GetProperty(hasManyAttr.LocalKeyProperty);
    if not Assigned(filterProp) then
      Continue;

    filterValue := filterProp.GetValue(TObject(AModel));
    if filterValue.IsEmpty then
      Continue;

    nestedEntityClass := ExtractGenericTypeFromList(prop.PropertyType);
    if not Assigned(nestedEntityClass) then
      Continue;

    valueColumnName := hasManyAttr.ForeignKeyProperty;
    valueProp := ACtx.GetType(nestedEntityClass).GetProperty(hasManyAttr.ForeignKeyProperty);
    if Assigned(valueProp) then
      valueColumnName := GetColumnName(valueProp);

    deleteQuery := TFDQuery.Create(nil);
    try
      deleteQuery.Connection := FConnection;
      deleteSql := Format('DELETE FROM %s WHERE %s = :parent_id', [
        GetFullTableName(nestedEntityClass),
        valueColumnName
      ]);
      deleteQuery.SQL.Text := deleteSql;
      deleteQuery.ParamByName('parent_id').Value := filterValue.AsVariant;
      deleteQuery.ExecSQL;
    finally
      deleteQuery.Free;
    end;
  end;
end;

function TRepositoryORM<T>.GetColumnNameForProperty(const APropertyName: string): string;
var
  schema : TEntitySchema;
  col    : TColumnSchema;
begin
  Result := LowerCase(APropertyName);
  schema := TEntitySchemaCache.GetSchema(T);
  if Assigned(schema) and schema.ByProperty.TryGetValue(APropertyName, col) then
    Result := col.ColumnName;
end;

function TRepositoryORM<T>.GetColumnNameForProperty(AClass: TClass; const APropertyName: string): string;
var
  schema : TEntitySchema;
  col    : TColumnSchema;
begin
  Result := LowerCase(APropertyName);
  schema := TEntitySchemaCache.GetSchema(AClass);
  if Assigned(schema) and schema.ByProperty.TryGetValue(APropertyName, col) then
    Result := col.ColumnName;
end;

function TRepositoryORM<T>.FindById(AId: TValue; ALock: Boolean = False; AInclude: TIncludeOptions = [ioIncludeNone]; ARelations: TRelationNames = nil): T;
var
  LQuery  : TFDQuery;
  schema  : TEntitySchema;
  sql     : string;
  lockSQL : string;
begin
  Result := nil;
  schema := TEntitySchemaCache.GetSchema(T);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    lockSQL := '';
    if ALock then
      lockSQL := Format(' FOR UPDATE OF %s NOWAIT', [schema.TableName]);

    sql := schema.SelectSQL
         + ' WHERE ' + schema.PKColumn + ' = :pk_id'
         + lockSQL;

    LQuery.SQL.Text := sql;
    LQuery.ParamByName('pk_id').Value := AId.AsVariant;
    LQuery.Open;

    if not LQuery.IsEmpty then
    begin
      Result := T(CreateEntityInstanceByClass(T));
      FillEntityFromDataSet(Result, LQuery);

      if (AInclude <> [ioIncludeNone]) or (ARelations <> nil) then
        FillNestedEntitiesWithInclude(Result, AInclude, ARelations);
    end;
  finally
    LQuery.Free;
  end;
end;

function TRepositoryORM<T>.FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AInclude: TIncludeOptions = [ioIncludeNone]; ARelations: TRelationNames = nil): T;
var
  LQuery   : TFDQuery;
  schema   : TEntitySchema;
  where    : TStringBuilder;
  filter   : TFilterCriterion;
  paramName: string;
  i        : Integer;
  sql      : string;
begin
  Result := nil;

  if not Assigned(AFilter) or (AFilter.Count = 0) then
    raise Exception.Create('FindOne: en az bir filtre kriteri gereklidir');

  schema := TEntitySchemaCache.GetSchema(T);
  where  := TStringBuilder.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    for i := 0 to AFilter.Count - 1 do
    begin
      filter    := AFilter[i];
      paramName := Format('p_%s_%d',
        [filter.PropertyNamePath.Replace('.', '_'), i]);

      if i > 0 then where.Append(' AND ');
      where
        .Append(GetColumnNameForProperty(filter.PropertyNamePath))
        .Append(' ').Append(filter.Operator)
        .Append(' :').Append(paramName);

      LQuery.Params.Add(paramName, filter.Value.AsVariant);
    end;

    sql := schema.SelectSQL
         + ' WHERE ' + where.ToString
         + IfThen(ALock, ' FOR UPDATE', '')
         + ' LIMIT 1';

    LQuery.SQL.Text := sql;
    LQuery.Open;

    if not LQuery.IsEmpty then
    begin
      Result := T(CreateEntityInstanceByClass(T));
      FillEntityFromDataSet(Result, LQuery);
      if (AInclude <> [ioIncludeNone]) or (ARelations <> nil) then
        FillNestedEntitiesWithInclude(Result, AInclude, ARelations);
    end;
  finally
    LQuery.Free;
    where.Free;
  end;
end;

function TRepositoryORM<T>.Find(AFilter: TFilterCriteria; ALock: Boolean = False; AInclude: TIncludeOptions = [ioIncludeNone]; ARelations: TRelationNames = nil): TList<T>;
var
  LQuery   : TFDQuery;
  schema   : TEntitySchema;
  where    : TStringBuilder;
  filter   : TFilterCriterion;
  paramName: string;
  entity   : T;
  i        : Integer;
  sql      : string;
begin
  Result := TObjectList<T>.Create(True);
  schema := TEntitySchemaCache.GetSchema(T);
  where  := TStringBuilder.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for i := 0 to AFilter.Count - 1 do
      begin
        filter    := AFilter[i];
        paramName := Format('p_%s_%d',
          [filter.PropertyNamePath.Replace('.', '_'), i]);

        if i > 0 then where.Append(' AND ');
        where
          .Append(GetColumnNameForProperty(filter.PropertyNamePath))
          .Append(' ').Append(filter.Operator)
          .Append(' :').Append(paramName);

        LQuery.Params.Add(paramName, filter.Value.AsVariant);
      end;
    end;

    sql := schema.SelectSQL;
    if where.Length > 0 then
      sql := sql + ' WHERE ' + where.ToString;
    if ALock then
      sql := sql + ' FOR UPDATE';

    LQuery.SQL.Text := sql;
    LQuery.Open;

    while not LQuery.Eof do
    begin
      entity := T(CreateEntityInstanceByClass(T));
      FillEntityFromDataSet(entity, LQuery);
      if (AInclude <> [ioIncludeNone]) or (ARelations <> nil) then
        FillNestedEntitiesWithInclude(entity, AInclude, ARelations);
      Result.Add(entity);
      LQuery.Next;
    end;
  finally
    LQuery.Free;
    where.Free;
  end;
end;

function TRepositoryORM<T>.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var schema: TEntitySchema;
begin
  schema := TEntitySchemaCache.GetSchema(T);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text   := 'SELECT * FROM ' + schema.TableName + ' WHERE 1=1';
end;

procedure TRepositoryORM<T>.Add(AModel: T; ACascade: TCascadeOperations = []);
var
  query      : TFDQuery;
  schema     : TEntitySchema;
  col, pkCol : TColumnSchema;
  propValue  : TValue;
  insertedId : Int64;
  rType      : TRttiType;
  prop       : TRttiProperty;
  attr       : TCustomAttribute;
  caAttr     : CreatedAt;
  uaAttr     : UpdatedAt;
begin
  GLogger.InfoFmt('Ekleme başladı: %s', [AModel.ClassName]);

  if not Assigned(AModel)      then raise Exception.Create('Model nil olamaz');
  if not Assigned(FConnection) then raise Exception.Create('Bağlantı yok');

  schema := TEntitySchemaCache.GetSchema(T);
  if not Assigned(schema) or (schema.InsertSQL = '') then
    raise Exception.CreateFmt('Insert SQL oluşturulamadı: %s', [T.ClassName]);

  // ── 1. Timestamp otomatik set (ACtx hâlâ burada kullanılır) ─────────────
  rType := ACtx.GetType(T);
  for prop in rType.GetProperties do
    for attr in prop.GetAttributes do
    begin
      if attr is CreatedAt then
      begin
        caAttr := CreatedAt(attr);
        if caAttr.AutoUpdate then
        begin
          propValue := prop.GetValue(TObject(AModel));
          if propValue.IsEmpty or (propValue.AsType<TDateTime> <= 0) then
            prop.SetValue(TObject(AModel), TValue.From<TDateTime>(Now));
        end;
        Break;
      end
      else if attr is UpdatedAt then
      begin
        uaAttr := UpdatedAt(attr);
        if uaAttr.AutoUpdate then
          prop.SetValue(TObject(AModel), TValue.From<TDateTime>(Now));
        Break;
      end;
    end;

  // ── 2. INSERT çalıştır ───────────────────────────────────────────────────
  query := TFDQuery.Create(nil);
  try
    query.Connection := FConnection;
    query.SQL.Text   := schema.InsertSQL;  // önceden hazır SQL

    // ── 3. Param bind — schema.InsertColumns (AutoIncrement hariç) ─────────
    for col in schema.InsertColumns do
    begin
      propValue := col.Prop.GetValue(TObject(AModel));
      if not propValue.IsEmpty then
        query.ParamByName(col.ColumnName).Value := propValue.AsVariant
      else
      begin
        if col.IsNotNull then
          raise Exception.CreateFmt('Zorunlu alan boş olamaz: %s.%s',
            [T.ClassName, col.PropertyName]);
        query.ParamByName(col.ColumnName).Value := Null;
      end;
    end;

    try
      query.Open;
    except
      on E: Exception do
        raise Exception.CreateFmt('Insert başarısız [%s]: %s', [T.ClassName, E.Message]);
    end;

    // ── 4. RETURNING pk → entity'ye yaz ────────────────────────────────────
    if (schema.PKColumn <> '') and not query.IsEmpty then
    begin
      insertedId := query.Fields[0].AsLargeInt;
      GLogger.InfoFmt('Kayıt eklendi: %s (ID: %d)', [AModel.ClassName, insertedId]);

      if schema.ByProperty.TryGetValue(schema.PKProperty, pkCol) then
        pkCol.Prop.SetValue(TObject(AModel), TValue.From<Int64>(insertedId));

      // ── 5. Cascade insert ──────────────────────────────────────────────
      if coInsert in ACascade then
      begin
        GLogger.DebugFmt('Cascade insert: %s (ID: %d)', [AModel.ClassName, insertedId]);
        ProcessHasManyInserts(AModel, insertedId);
      end;
    end;
  finally
    query.Free;
  end;

  GLogger.InfoFmt('Ekleme tamamlandı: %s', [AModel.ClassName]);
end;

procedure TRepositoryORM<T>.AddBatch(AModels: TArray<T>; ACascade: TCascadeOperations = []);
var
  i: Integer;
  transaction: TFDTransaction;
  wasInTransaction: Boolean;
begin
  if Length(AModels) = 0 then
    Exit;

  if not Assigned(FConnection) then
    raise Exception.Create('Database connection is not available');

  for i := 0 to High(AModels) do
  begin
    if not Assigned(AModels[i]) then
      raise Exception.CreateFmt('Model at index %d cannot be nil', [i]);
  end;

  wasInTransaction := FConnection.InTransaction;

  if wasInTransaction then
  begin
    for i := 0 to High(AModels) do
    begin
      try
          Add(AModels[i], ACascade);
      except
        on E: Exception do
          raise Exception.CreateFmt('Batch insert failed at index %d: %s', [i, E.Message]);
      end;
    end;
  end
  else
  begin
    transaction := TFDTransaction.Create(nil);
    try
      transaction.Connection := FConnection;
      try
        transaction.StartTransaction;
        try
          for i := 0 to High(AModels) do
            Add(AModels[i], ACascade);

          transaction.Commit;
        except
          on E: Exception do
          begin
            if transaction.Active then
              transaction.Rollback;
            raise Exception.CreateFmt('Batch insert failed %s', [E.Message]);
          end;
        end;
      except
        on E: Exception do
          raise Exception.CreateFmt('Transaction error during batch insert: %s', [E.Message]);
      end;
    finally
      transaction.Free;
    end;
  end;
end;

procedure TRepositoryORM<T>.Update(AModel: T; ACascade: TCascadeOperations = []);
var
  query       : TFDQuery;
  schema      : TEntitySchema;
  col, pkCol  : TColumnSchema;
  propValue   : TValue;
  pkValue     : TValue;
  rType       : TRttiType;
  prop        : TRttiProperty;
  attr        : TCustomAttribute;
  versionProp : TRttiProperty;
  versionVal  : TValue;
  versionColName: string;
  updateSQL   : string;
begin
  GLogger.InfoFmt('Güncelleme başladı: %s', [AModel.ClassName]);

  if not Assigned(AModel)      then raise Exception.Create('Model nil olamaz');
  if not Assigned(FConnection) then raise Exception.Create('Bağlantı yok');

  schema := TEntitySchemaCache.GetSchema(T);
  if not Assigned(schema) or (schema.UpdateSQL = '') then
    raise Exception.CreateFmt('Update SQL oluşturulamadı: %s', [T.ClassName]);

  // ── 1. PK değerini oku ────────────────────────────────────────────────────
  if not schema.ByProperty.TryGetValue(schema.PKProperty, pkCol) then
    raise Exception.CreateFmt('PK property bulunamadı: %s', [T.ClassName]);

  pkValue := pkCol.Prop.GetValue(TObject(AModel));
  if pkValue.IsEmpty or (pkValue.AsInt64 <= 0) then
    raise Exception.Create('Update için PK değeri gereklidir');

  // ── 2. Timestamp + Version taraması (tek geçiş, ACtx ile) ───────────────
  rType       := ACtx.GetType(T);
  versionProp := nil;
  versionColName := '';
  for prop in rType.GetProperties do
    for attr in prop.GetAttributes do
    begin
      if (attr is UpdatedAt) and UpdatedAt(attr).AutoUpdate then
      begin
        prop.SetValue(TObject(AModel), TValue.From<TDateTime>(Now));
        Break;
      end
      else if attr is Version then
      begin
        versionProp    := prop;
        versionColName := Version(attr).ColumnName;
        versionVal     := prop.GetValue(TObject(AModel));
        Break;
      end;
    end;

  // ── 3. Version varsa WHERE koşuluna ekle ─────────────────────────────────
  updateSQL := schema.UpdateSQL;  // "UPDATE ... SET ... WHERE pk = :pk_value"
  if Assigned(versionProp) then
    updateSQL := updateSQL + Format(' AND %s = :version_value', [versionColName]);

  // ── 4. Sorguyu çalıştır ───────────────────────────────────────────────────
  query := TFDQuery.Create(nil);
  try
    query.Connection := FConnection;
    query.SQL.Text   := updateSQL;

    GLogger.Debug('SQL: ' + updateSQL);

    query.ParamByName('pk_value').Value := pkValue.AsVariant;

    if Assigned(versionProp) then
    begin
      if versionVal.IsEmpty then
        raise Exception.Create('Version değeri gereklidir (optimistic locking)');
      query.ParamByName('version_value').Value := versionVal.AsVariant;
    end;

    // ── 5. Param bind — schema.UpdateColumns (PK hariç) ──────────────────
    for col in schema.UpdateColumns do
    begin
      propValue := col.Prop.GetValue(TObject(AModel));
      if not propValue.IsEmpty then
        query.ParamByName(col.ColumnName).Value := propValue.AsVariant
      else
        query.ParamByName(col.ColumnName).Value := Null;
    end;

    try
      query.ExecSQL;
    except
      on E: Exception do
        raise Exception.CreateFmt('Update başarısız [%s]: %s', [T.ClassName, E.Message]);
    end;

    if query.RowsAffected < 1 then
    begin
      if Assigned(versionProp) then
        raise Exception.Create('Eşzamanlılık hatası: kayıt başka kullanıcı tarafından değiştirilmiş')
      else
        raise Exception.CreateFmt('Kayıt bulunamadı (ID: %d)', [pkValue.AsInt64]);
    end;

    GLogger.InfoFmt('Güncelleme başarılı: %s (PK: %s)', [AModel.ClassName, pkValue.ToString]);

    // ── 6. Version sayacını artır ─────────────────────────────────────────
    if Assigned(versionProp) and versionProp.IsWritable then
      versionProp.SetValue(TObject(AModel),
        TValue.From<Integer>(versionVal.AsInteger + 1));

    // ── 7. Cascade update ─────────────────────────────────────────────────
    if coUpdate in ACascade then
      ProcessHasManyUpdates(AModel, pkValue.AsInt64);

  finally
    query.Free;
    GLogger.InfoFmt('Güncelleme tamamlandı: %s', [AModel.ClassName]);
  end;
end;

procedure TRepositoryORM<T>.UpdateBatch(AModels: TArray<T>; ACascade: TCascadeOperations = []);
var
  i: Integer;
  transaction: TFDTransaction;
  wasInTransaction: Boolean;
begin
  if Length(AModels) = 0 then
    Exit;

  if not Assigned(FConnection) then
    raise Exception.Create('Database connection is not available');

  for i := 0 to High(AModels) do
  begin
    if not Assigned(AModels[i]) then
      raise Exception.CreateFmt('Model at index %d cannot be nil', [i]);
  end;

  wasInTransaction := FConnection.InTransaction;

  if wasInTransaction then
  begin
    try
      for i := 0 to High(AModels) do
        Update(AModels[i], ACascade);
    except
      on E: Exception do
        raise Exception.CreateFmt('Batch update failed %s', [E.Message]);
    end;
  end
  else
  begin
    transaction := TFDTransaction.Create(nil);
    try
      transaction.Connection := FConnection;

      try
        transaction.StartTransaction;

        try
          for i := 0 to High(AModels) do
            Update(AModels[i], ACascade);

          transaction.Commit;
        except
          on E: Exception do
          begin
            if transaction.Active then
              transaction.Rollback;
            raise Exception.CreateFmt('Batch update failed %s', [E.Message]);
          end;
        end;
      except
        on E: Exception do
          raise Exception.CreateFmt('Transaction error during batch update: %s', [E.Message]);
      end;
    finally
      transaction.Free;
    end;
  end;
end;

procedure TRepositoryORM<T>.Delete(AID: Int64; ACascade: TCascadeOperations = []);
var
  schema        : TEntitySchema;
  model         : T;
  query         : TFDQuery;
  sql           : string;
  softAttr      : SoftDelete;
  rType         : TRttiType;
  attr          : TCustomAttribute;
begin
  if AID <= 0 then
    raise Exception.Create('Geçersiz ID: 0''dan büyük olmalıdır');
  if not Assigned(FConnection) then
    raise Exception.Create('Bağlantı yok');

  schema   := TEntitySchemaCache.GetSchema(T);
  softAttr := nil;

  // SoftDelete attribute kontrolü (class level)
  rType := ACtx.GetType(T);
  for attr in rType.GetAttributes do
    if attr is SoftDelete then
    begin
      softAttr := SoftDelete(attr);
      Break;
    end;

  // Cascade delete: önce çocuk kayıtları sil
  model := nil;
  if coDelete in ACascade then
  begin
    model := FindById(AID);
    if not Assigned(model) then
      raise Exception.CreateFmt('Cascade delete: ID=%d bulunamadı', [AID]);
    try
      ProcessCascadeDeletes(model, ACascade);
    except
      model.Free;
      raise;
    end;
  end;

  query := TFDQuery.Create(nil);
  try
    query.Connection := FConnection;

    if Assigned(softAttr) then
    begin
      // Soft delete: deleted_at set et
      sql := Format('UPDATE %s SET %s = :deleted_at',
        [schema.FullTableName, softAttr.DeletedAtColumn]);

      if softAttr.DeletedByColumn <> '' then
        sql := sql + Format(', %s = :deleted_by', [softAttr.DeletedByColumn]);

      sql := sql
        + Format(' WHERE %s = :pk_id', [schema.PKColumn])
        + Format(' AND %s IS NULL',   [softAttr.DeletedAtColumn]);

      query.SQL.Text := sql;
      query.ParamByName('deleted_at').AsDateTime := Now;
      if softAttr.DeletedByColumn <> '' then
        query.ParamByName('deleted_by').AsLargeInt := 0;  // TODO: current user
      query.ParamByName('pk_id').AsLargeInt := AID;
    end
    else
    begin
      // Hard delete
      sql := Format('DELETE FROM %s WHERE %s = :pk_id',
        [schema.FullTableName, schema.PKColumn]);
      query.SQL.Text := sql;
      query.ParamByName('pk_id').AsLargeInt := AID;
    end;

    query.ExecSQL;

    if query.RowsAffected < 1 then
    begin
      if Assigned(softAttr) then
        raise Exception.CreateFmt('Soft delete başarısız: ID=%d bulunamadı veya zaten silinmiş', [AID])
      else
        raise Exception.CreateFmt('Delete başarısız: ID=%d bulunamadı', [AID]);
    end;
  finally
    query.Free;
    if Assigned(model) then model.Free;
  end;
end;

procedure TRepositoryORM<T>.Delete(AModel: T; ACascade: TCascadeOperations = []);
var
  rType: TRttiType;
  prop: TRttiProperty;
  attr: TCustomAttribute;
  colAttr: Column;
  idValue: TValue;
  pkFound: Boolean;
begin
  if not Assigned(AModel) then
    raise Exception.Create('Model cannot be nil');

  pkFound := False;
  rType := ACtx.GetType(T);
  for prop in rType.GetProperties do
  begin
    if not prop.IsReadable then
      Continue;

    for attr in prop.GetAttributes do
    begin
      if attr is Column then
      begin
        colAttr := attr as Column;
        if colAttr.IsPrimaryKey then
        begin
          idValue := prop.GetValue(TObject(AModel));
          if not idValue.IsEmpty and (idValue.AsType<Int64> > 0) then
          begin
            Delete(idValue.AsType<Int64>, ACascade);
            pkFound := True;
          end
          else
          begin
            raise Exception.Create('Primary key value is invalid or not set');
          end;
          Break;
        end;
      end;
    end;
    if pkFound then
      Break;
  end;

  if not pkFound then
    raise Exception.Create('Primary key property not found in entity ' + T.ClassName);
end;

procedure TRepositoryORM<T>.DeleteBatch(AModels: TArray<T>; ACascade: TCascadeOperations = []);
var
  i: Integer;
  transaction: TFDTransaction;
  wasInTransaction: Boolean;
begin
  if Length(AModels) = 0 then
    Exit;

  if not Assigned(FConnection) then
    raise Exception.Create('Database connection is not available');

  for i := 0 to High(AModels) do
  begin
    if not Assigned(AModels[i]) then
      raise Exception.CreateFmt('Model at index %d cannot be nil', [i]);
  end;

  wasInTransaction := FConnection.InTransaction;

  if wasInTransaction then
  begin
    try
      for i := 0 to High(AModels) do
        Delete(AModels[i], ACascade);
    except
      on E: Exception do
        raise Exception.CreateFmt('Batch delete failed %s', [E.Message]);
    end;
  end
  else
  begin
    transaction := TFDTransaction.Create(nil);
    try
      transaction.Connection := FConnection;

      try
        transaction.StartTransaction;

        try
          for i := 0 to High(AModels) do
            Delete(AModels[i], ACascade);

          transaction.Commit;
        except
          on E: Exception do
          begin
            if transaction.Active then
              transaction.Rollback;
            raise Exception.CreateFmt('Batch delete failed %s', [E.Message]);
          end;
        end;
      except
        on E: Exception do
          raise Exception.CreateFmt('Transaction error during batch delete: %s', [E.Message]);
      end;
    finally
      transaction.Free;
    end;
  end;
end;

procedure TRepositoryORM<T>.DeleteBatch(AIDs: TArray<Int64>; ACascade: TCascadeOperations = []);
var
  i: Integer;
  transaction: TFDTransaction;
  query: TFDQuery;
  sql, pkColumn: string;
  ctx: TRttiContext;
  rType: TRttiType;
  attr: TCustomAttribute;
  softDeleteAttr: SoftDelete;
  idList: string;
  wasInTransaction: Boolean;
begin
  if Length(AIDs) = 0 then
    Exit;

  if not Assigned(FConnection) then
    raise Exception.Create('Database connection is not available');

  for i := 0 to High(AIDs) do
  begin
    if AIDs[i] <= 0 then
      raise Exception.CreateFmt('Invalid ID at index %d: ID must be greater than 0', [i]);
  end;

  if coDelete in ACascade then
  begin
    wasInTransaction := FConnection.InTransaction;

    if wasInTransaction then
    begin
      try
        for i := 0 to High(AIDs) do
          Delete(AIDs[i], ACascade);
      except
        on E: Exception do
          raise Exception.CreateFmt('Cascade delete failed %s', [E.Message]);
      end;
    end
    else
    begin
      transaction := TFDTransaction.Create(nil);
      try
        transaction.Connection := FConnection;

        try
          transaction.StartTransaction;

          try
            for i := 0 to High(AIDs) do
              Delete(AIDs[i], ACascade);

            transaction.Commit;
          except
            on E: Exception do
            begin
              if transaction.Active then
                transaction.Rollback;
              raise Exception.CreateFmt('Cascade delete failed %s', [E.Message]);
            end;
          end;
        except
          on E: Exception do
            raise Exception.CreateFmt('Transaction error during cascade delete: %s', [E.Message]);
        end;
      finally
        transaction.Free;
      end;
    end;
    Exit;
  end;

  ctx := TRttiContext.Create;
  softDeleteAttr := nil;
  try
    rType := ctx.GetType(T);
    for attr in rType.GetAttributes do
    begin
      if attr is SoftDelete then
      begin
        softDeleteAttr := attr as SoftDelete;
        Break;
      end;
    end;
  finally
    ctx.Free;
  end;

  idList := '';
  for i := 0 to High(AIDs) do
  begin
    if i > 0 then
      idList := idList + ',';
    idList := idList + IntToStr(AIDs[i]);
  end;

  query := TFDQuery.Create(nil);
  try
    query.Connection := FConnection;
    pkColumn := GetPrimaryKeyColumn(T);

    if Assigned(softDeleteAttr) then
    begin
      sql := Format('UPDATE %s SET %s = :deleted_at', [
        GetFullTableName(T),
        softDeleteAttr.DeletedAtColumn
      ]);

      if softDeleteAttr.DeletedByColumn <> '' then
        sql := sql + Format(', %s = :deleted_by', [softDeleteAttr.DeletedByColumn]);

      sql := sql + Format(' WHERE %s IN (%s)', [pkColumn, idList]);

      sql := sql + Format(' AND %s IS NULL', [softDeleteAttr.DeletedAtColumn]);

      query.SQL.Text := sql;

      try
        query.ParamByName('deleted_at').AsDateTime := Now;
        if softDeleteAttr.DeletedByColumn <> '' then
          query.ParamByName('deleted_by').AsLargeInt := 0;
      except
        on E: Exception do
          raise Exception.CreateFmt('Error setting bulk soft delete parameters: %s', [E.Message]);
      end;
    end
    else
    begin
      sql := Format('DELETE FROM %s WHERE %s IN (%s)', [
        GetFullTableName(T),
        pkColumn,
        idList
      ]);
      query.SQL.Text := sql;
    end;

    try
      query.ExecSQL;

      if query.RowsAffected < 1 then
      begin
        if Assigned(softDeleteAttr) then
          raise Exception.Create('Bulk soft delete failed: No records found or all records already deleted')
        else
          raise Exception.Create('Bulk delete failed: No records found');
      end;
    except
      on E: Exception do
        raise Exception.CreateFmt('Failed to execute bulk delete: %s', [E.Message]);
    end;

  finally
    query.Free;
  end;
end;

procedure TRepositoryORM<T>.DeleteBatch(AFilter: TFilterCriteria; ACascade: TCascadeOperations = []);
var
  query: TFDQuery;
  sql, whereClause: string;
  fc: TFilterCriterion;
  i: Integer;
  models: TList<T>;
  transaction: TFDTransaction;
  ctx: TRttiContext;
  rType: TRttiType;
  attr: TCustomAttribute;
  softDeleteAttr: SoftDelete;
  wasInTransaction: Boolean;
  paramName: string;
begin
  if not Assigned(AFilter) or (AFilter.Count = 0) then
    raise Exception.Create('Filter criteria cannot be empty');

  if not Assigned(FConnection) then
    raise Exception.Create('Database connection is not available');

  if coDelete in ACascade then
  begin
    models := nil;
    try
      models := Find(AFilter);
      if Assigned(models) and (models.Count > 0) then
      begin
        wasInTransaction := FConnection.InTransaction;

        if wasInTransaction then
        begin
          try
            for i := 0 to models.Count - 1 do
              Delete(models[i], ACascade);
          except
            on E: Exception do
              raise Exception.CreateFmt('Cascade delete failed %s', [E.Message]);
          end;
        end
        else
        begin
          transaction := TFDTransaction.Create(nil);
          try
            transaction.Connection := FConnection;

            try
              transaction.StartTransaction;

              try
                for i := 0 to models.Count - 1 do
                  Delete(models[i], ACascade);

                transaction.Commit;
              except
                on E: Exception do
                begin
                  if transaction.Active then
                    transaction.Rollback;
                  raise Exception.CreateFmt('Cascade delete failed %s', [E.Message]);
                end;
              end;
            except
              on E: Exception do
                raise Exception.CreateFmt('Transaction error during cascade delete: %s', [E.Message]);
            end;
          finally
            transaction.Free;
          end;
        end;
      end;
    finally
      if Assigned(models) then
        models.Free;
    end;
    Exit;
  end;

  ctx := TRttiContext.Create;
  softDeleteAttr := nil;
  try
    rType := ctx.GetType(T);
    for attr in rType.GetAttributes do
    begin
      if attr is SoftDelete then
      begin
        softDeleteAttr := attr as SoftDelete;
        Break;
      end;
    end;
  finally
    ctx.Free;
  end;

  whereClause := '';
  for i := 0 to AFilter.Count - 1 do
  begin
    fc := AFilter[i];
    if i > 0 then
      whereClause := whereClause + ' AND ';

    paramName := Format('filter_param_%d', [i]);
    whereClause := whereClause + GetColumnNameForProperty(fc.PropertyNamePath) + ' ' + fc.Operator + ' :' + paramName;
  end;

  query := TFDQuery.Create(nil);
  try
    query.Connection := FConnection;

    if Assigned(softDeleteAttr) then
    begin
      sql := Format('UPDATE %s SET %s = :deleted_at', [
        GetFullTableName(T),
        softDeleteAttr.DeletedAtColumn
      ]);

      if softDeleteAttr.DeletedByColumn <> '' then
        sql := sql + Format(', %s = :deleted_by', [softDeleteAttr.DeletedByColumn]);

      sql := sql + ' WHERE ' + whereClause;

      sql := sql + Format(' AND %s IS NULL', [softDeleteAttr.DeletedAtColumn]);

      query.SQL.Text := sql;

      try
        query.ParamByName('deleted_at').AsDateTime := Now;
        if softDeleteAttr.DeletedByColumn <> '' then
          query.ParamByName('deleted_by').AsLargeInt := 0;
      except
        on E: Exception do
          raise Exception.CreateFmt('Error setting soft delete parameters: %s', [E.Message]);
      end;
    end
    else
    begin
      sql := 'DELETE FROM ' + GetFullTableName(T) + ' WHERE ' + whereClause;
      query.SQL.Text := sql;
    end;

    try
      for i := 0 to AFilter.Count - 1 do
      begin
        paramName := Format('filter_param_%d', [i]);
        query.ParamByName(paramName).Value := AFilter[i].Value.AsVariant;
      end;
    except
      on E: Exception do
        raise Exception.CreateFmt('Error setting filter parameters: %s', [E.Message]);
    end;

    try
      query.ExecSQL;

      if query.RowsAffected < 1 then
      begin

      end;
    except
      on E: Exception do
        raise Exception.CreateFmt('Failed to delete records with filter: %s', [E.Message]);
    end;

  finally
    query.Free;
  end;
end;

function TRepositoryORM<T>.Clone(ASource: T): T;
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

end.
