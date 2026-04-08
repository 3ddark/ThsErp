unit Repository;

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

  IRepository<T: TEntity> = interface
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

  TRepository<T: TEntity> = class(TInterfacedObject, IRepository<T>)
  private
    FConnection: TFDConnection;
    ACtx: TRttiContext;

    function StringListToArray(AStringList: TStringList): TArray<string>;
    function GenerateSelectSql(AClass: TClass; const AWhereClause: string = ''): string;
    function GetSelectColumns(AClass: TClass): string;
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
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;

    function FindById(AId: TValue; ALock: Boolean = False; AInclude: TIncludeOptions = [ioIncludeNone]; ARelations: TRelationNames = nil): T;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AInclude: TIncludeOptions = [ioIncludeNone]; ARelations: TRelationNames = nil): T;
    function Find(AFilter: TFilterCriteria; ALock: Boolean = False; AInclude: TIncludeOptions = [ioIncludeNone]; ARelations: TRelationNames = nil): TList<T>;

    procedure Add(AModel: T; ACascade: TCascadeOperations = []);
    procedure AddBatch(AModels: TArray<T>; ACascade: TCascadeOperations = []);

    procedure Update(AModel: T; ACascade: TCascadeOperations = []);
    procedure UpdateBatch(AModels: TArray<T>; ACascade: TCascadeOperations = []);

    procedure Delete(AID: Int64; ACascade: TCascadeOperations = []); overload;
    procedure Delete(AModel: T; ACascade: TCascadeOperations = []); overload;
    procedure DeleteBatch(AModels: TArray<T>; ACascade: TCascadeOperations = []); reintroduce; overload;
    procedure DeleteBatch(AIDs: TArray<Int64>; ACascade: TCascadeOperations = []); reintroduce; overload;
    procedure DeleteBatch(AFilter: TFilterCriteria; ACascade: TCascadeOperations = []); reintroduce; overload;

    function Clone(ASource: T): T;

    constructor Create(AConnection: TFDConnection);
    destructor Destroy; override;
  end;

implementation

uses Logger;

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

constructor TRepository<T>.Create(AConnection: TFDConnection);
begin
  if AConnection = nil then
    raise Exception.Create('Connection Required');

  ACtx := TRttiContext.Create;
  FConnection := AConnection;
end;

destructor TRepository<T>.Destroy;
begin
  ACtx.Free;
  inherited;
end;

function TRepository<T>.Connection: TFDConnection;
begin
  Result := FConnection;
end;

function TRepository<T>.GetTableName(AClass: TClass): string;
var
  AType: TRttiType;
  AAttr : TCustomAttribute;
begin
  Result := AClass.ClassName;
  AType := ACtx.GetType(AClass);
  for AAttr in AType.GetAttributes do
    if AAttr is TableAttribute then
    begin
      Result := (AAttr as TableAttribute).Name;
      Break;
    end;
end;

procedure TRepository<T>.InsertNestedEntity(AEntity: TObject; AEntityClass: TClass);
var
  query: TFDQuery;
  insertSql: string;
  rType: TRttiType;
  prop: TRttiProperty;
  attr: TCustomAttribute;
  colAttr: Column;
  columns, values: TStringList;
  columnName: string;
  propValue: TValue;
  insertedId: Int64;
  pkColumn: string;
  pkProp: TRttiProperty;
begin
  if not Assigned(AEntity) then
    Exit;

  query := TFDQuery.Create(nil);
  columns := TStringList.Create;
  values := TStringList.Create;
  try
    query.Connection := FConnection;

    rType := ACtx.GetType(AEntityClass);

    for prop in rType.GetProperties do
    begin
      if not prop.IsReadable then
        Continue;

      colAttr := nil;
      for attr in prop.GetAttributes do
      begin
        if attr is NotMapped then
          Break;
        if attr is HasOneAttribute then
          Break;
        if attr is HasManyAttribute then
          Break;
        if attr is BelongsToAttribute then
          Break;
        if attr is Column then
        begin
          colAttr := attr as Column;
          Break;
        end;
      end;

      if not Assigned(colAttr) or colAttr.IsAutoIncrement then
        Continue;

//        if (colAttr.SqlUseWhichCols <> []) and not (cucAdd in colAttr.SqlUseWhichCols) then
//          Continue;

      columnName := GetColumnName(prop);
      propValue := prop.GetValue(AEntity);

      if propValue.IsEmpty and colAttr.IsNotNull then
        Continue;

      columns.Add(columnName);
      values.Add(':' + columnName);
    end;

    if columns.Count = 0 then
      Exit;

    insertSql := Format('INSERT INTO %s (%s) VALUES (%s)', [
      GetFullTableName(AEntityClass),
      columns.CommaText.Replace('"', ''),
      values.CommaText.Replace('"', '')
    ]);

    pkColumn := GetPrimaryKeyColumn(AEntityClass);
    insertSql := insertSql + ' RETURNING ' + pkColumn;

    query.SQL.Text := insertSql;

    for prop in rType.GetProperties do
    begin
      if not prop.IsReadable then
        Continue;

      colAttr := nil;
      for attr in prop.GetAttributes do
      begin
        if attr is Column then
        begin
          colAttr := attr as Column;
          Break;
        end;
      end;

      if not Assigned(colAttr) or colAttr.IsAutoIncrement then
        Continue;

//        if (colAttr.SqlUseWhichCols <> []) and not (cucAdd in colAttr.SqlUseWhichCols) then
//          Continue;

      columnName := GetColumnName(prop);
      if query.ParamByName(columnName) <> nil then
      begin
        propValue := prop.GetValue(AEntity);
        if not propValue.IsEmpty then
          query.ParamByName(columnName).Value := propValue.AsVariant
        else
          query.ParamByName(columnName).Value := Null;
      end;
    end;

    query.Open;

    if not query.IsEmpty then
    begin
      insertedId := query.Fields[0].AsLargeInt;

      pkProp := nil;
      for prop in rType.GetProperties do
      begin
        if not prop.IsWritable then
          Continue;

        for attr in prop.GetAttributes do
        begin
          if attr is Column then
          begin
            colAttr := attr as Column;
            if colAttr.IsPrimaryKey then
            begin
              pkProp := prop;
              Break;
            end;
          end;
        end;
        if Assigned(pkProp) then
          Break;
      end;

      if Assigned(pkProp) then
        pkProp.SetValue(AEntity, TValue.From<Int64>(insertedId));
    end;
  finally
    query.Free;
    columns.Free;
    values.Free;
  end;
end;

procedure TRepository<T>.ProcessHasManyInserts(AModel: T; AParentId: Int64);
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

function TRepository<T>.GetFullTableName(AClass: TClass): string;
var
  AType: TRttiType;
  AAttr : TCustomAttribute;
  TableAttr: TableAttribute;
begin
  AType := ACtx.GetType(AClass);
  for AAttr in AType.GetAttributes do
    if AAttr is TableAttribute then
    begin
      TableAttr := AAttr as TableAttribute;
      Result := TableAttr.FullName;
      Break;
    end;
end;

function TRepository<T>.GetPrimaryKeyColumn(AClass: TClass): string;
var
  rType: TRttiType;
  prop: TRttiProperty;
  attr: TCustomAttribute;
  colAttr: Column;
begin
  Result := 'id';

  if not Assigned(AClass) then
    Exit;

  rType := ACtx.GetType(AClass);
  if not Assigned(rType) then
    Exit;

  for prop in rType.GetProperties do
  begin
    if not prop.IsReadable then
      Continue;

    try
      begin
        if not prop.HasAttribute(Column) then Continue;
        attr := prop.GetAttribute(Column);
        if attr = nil then Continue;

        colAttr := Column(attr);
        if colAttr.IsPrimaryKey then
        begin
          if colAttr.Name <> '' then
            Result := colAttr.Name
          else
            Result := LowerCase(prop.Name);
          Exit;
        end;
      end;
    except
      Continue;
    end;
  end;
end;

function TRepository<T>.GetColumnName(AProp: TRttiProperty): string;
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

function TRepository<T>.StringListToArray(AStringList: TStringList): TArray<string>;
var
  i: Integer;
begin
  SetLength(Result, AStringList.Count);
  for i := 0 to AStringList.Count - 1 do
    Result[i] := AStringList[i];
end;

function TRepository<T>.GetSelectColumns(AClass: TClass): string;
var
  rType: TRttiType;
  prop: TRttiProperty;
  columns: TStringList;
begin
  columns := TStringList.Create;
  try
    rType := ACtx.GetType(AClass);
    for prop in rType.GetProperties do
    begin
      if prop.HasAttribute(NotMapped) or not prop.HasAttribute(Column) then
        Continue;
      columns.Add(GetColumnName(prop));
    end;

    if columns.Count = 0 then
      Result := '*'
    else
      Result := columns.CommaText.Replace('"', '');
  finally
    columns.Free;
  end;
end;

function TRepository<T>.GenerateSelectSql(AClass: TClass; const AWhereClause: string): string;
var
  tableName, columns: string;
begin
  tableName := GetFullTableName(AClass);
  columns := GetSelectColumns(AClass);

  Result := Format('SELECT %s FROM %s', [columns, tableName]);

  if AWhereClause <> '' then
    Result := Result + ' WHERE ' + AWhereClause;
end;

procedure TRepository<T>.FillEntityFromDataSet(AEntity: TObject; ADataSet: TFDQuery);
var
  rType: TRttiType;
  prop: TRttiProperty;
  field: TField;
  columnName: string;
  propValue: TValue;
begin
  if not Assigned(AEntity) or not Assigned(ADataSet) then
    Exit;

  rType := ACtx.GetType(AEntity.ClassType);

  for prop in rType.GetProperties do
  begin
    if not prop.IsWritable then
      Continue;

    columnName := GetColumnName(prop);
    field := ADataSet.FindField(columnName);

    if Assigned(field) and not field.IsNull then
    begin
      case prop.PropertyType.TypeKind of
        tkInteger:
          begin
            if prop.PropertyType.Name = 'SmallInt' then
              propValue := TValue.From<SmallInt>(field.AsInteger)
            else
              propValue := TValue.From<Integer>(field.AsInteger);
          end;
        tkInt64:
          propValue := TValue.From<Int64>(field.AsLargeInt);
        tkFloat:
          begin
            if prop.PropertyType.Handle = TypeInfo(TDateTime) then
              propValue := TValue.From<TDateTime>(field.AsDateTime)
            else if prop.PropertyType.Handle = TypeInfo(Double) then
              propValue := TValue.From<Double>(field.AsFloat)
            else if prop.PropertyType.Handle = TypeInfo(Single) then
              propValue := TValue.From<Single>(field.AsSingle)
            else
              propValue := TValue.From<Extended>(field.AsFloat);
          end;
        tkString, tkLString, tkWString, tkUString:
          propValue := TValue.From<string>(field.AsString);
        tkEnumeration:
          begin
            if prop.PropertyType.Handle = TypeInfo(Boolean) then
              propValue := TValue.From<Boolean>(field.AsBoolean);
          end;
      end;

      try
        prop.SetValue(AEntity, propValue);
      except
        on E: Exception do
          Continue;
      end;
    end;
  end;
end;

procedure TRepository<T>.FillNestedEntitiesWithInclude(AEntity: TObject; AInclude: TIncludeOptions; ARelations: TRelationNames = nil);
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

procedure TRepository<T>.LoadChildEntitiesWithInclude(AEntity: TObject; AInclude: TIncludeOptions; ARelations: TRelationNames);
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

procedure TRepository<T>.LoadParentEntitiesWithInclude(AEntity: TObject; AInclude: TIncludeOptions; ARelations: TRelationNames);
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

procedure TRepository<T>.LoadChildProperty(AEntity: TObject; AProp: TRttiProperty; AHasManyAttr: HasManyAttribute);
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

      AddToList(LList, LChildClass, LChildEntity);

      LQuery.Next;
    end;

    LListValue := TValue.From<TObject>(LList);
    AProp.SetValue(AEntity, LListValue);
  finally
    LQuery.Free;
  end;
end;

procedure TRepository<T>.LoadParentProperty(AEntity: TObject; AProp: TRttiProperty; ABelongsToAttr: BelongsToAttribute);
var
  LQuery: TFDQuery;
  LParentClass: TClass;
  LParentEntity: TObject;
  LExistingEntity: TObject;   // <-- Ekle
  LForeignKey: string;
  LForeignIdValue: TValue;
  LForeignIdProp: TRttiProperty;
  LEntityType: TRttiType;
  LSql: string;
  LWhereClause: string;
  LParentValue: TValue;
  LExistingValue: TValue;     // <-- Ekle
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    LParentClass := AProp.PropertyType.AsInstance.MetaclassType;
    if LParentClass = nil then
      Exit;

    if ABelongsToAttr.RemoteKeyProperty <> '' then
      LForeignKey := ABelongsToAttr.LocalKeyProperty
    else
      LForeignKey := Format('%s_id', [AProp.Name.ToLower]);

    LEntityType := ACtx.GetType(AEntity.ClassInfo);
    LForeignIdProp := LEntityType.GetProperty(LForeignKey.Replace('_id', 'Id'));
    if LForeignIdProp = nil then
      Exit;

    LForeignIdValue := LForeignIdProp.GetValue(AEntity);
    if LForeignIdValue.IsEmpty then
      Exit;

    LWhereClause := Format('%s = %s', [GetPrimaryKeyColumn(LParentClass), QuotedStr(LForeignIdValue.ToString)]);
    LSql := GenerateSelectSql(LParentClass, LWhereClause);
    LQuery.SQL.Text := LSql;
    LQuery.Open;

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

procedure TRepository<T>.LoadGrandChildEntitiesRecursive(AEntity: TObject);
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
              FillNestedEntitiesWithInclude(LChildEntity, [ioIncludeChildren], nil);
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TRepository<T>.LoadSpecificRelationsOnly(AEntity: TObject; ARelations: TRelationNames);
begin
  if ARelations = nil then
    Exit;

  LoadChildEntitiesWithInclude(AEntity, [ioIncludeSpecific], ARelations);
  LoadParentEntitiesWithInclude(AEntity, [ioIncludeSpecific], ARelations);
end;

function TRepository<T>.ShouldLoadThisRelation(const ARelationName: string; ARelations: TRelationNames; AInclude: TIncludeOptions): Boolean;
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

function TRepository<T>.IsChildRelationProperty(AProp: TRttiProperty): Boolean;
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

procedure TRepository<T>.AddToList(AList: TObject; AListType: TClass; AItem: TObject);
var
  rType: TRttiType;
  addMethod: TRttiMethod;
  result: TValue;
begin
  rType := ACtx.GetType(AList.ClassType);
  addMethod := rType.GetMethod('Add');

  if Assigned(addMethod) then
  begin
    result := addMethod.Invoke(AList, [TValue.From<TObject>(AItem)]);

    if result.IsType<Integer> then
      GLogger.Debug('Item added at index: ' + result.AsString)
  end
  else
    raise Exception.Create('Add method not found');
end;

function TRepository<T>.GetListCount(AList: TObject): Integer;
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

function TRepository<T>.GetListItem(AList: TObject; AIndex: Integer): TObject;
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

function TRepository<T>.CreateEntityInstanceByClass(AClass: TClass): TObject;
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

function TRepository<T>.ExtractGenericTypeFromList(AListType: TRttiType): TClass;
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

procedure TRepository<T>.ProcessHasManyUpdates(AModel: T; AParentId: Int64);
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

procedure TRepository<T>.UpdateNestedEntity(AEntity: TObject; AEntityClass: TClass);
var
  query: TFDQuery;
  updateSql: string;
  rType: TRttiType;
  prop: TRttiProperty;
  attr: TCustomAttribute;
  colAttr: Column;
  setParts: TStringList;
  whereClause: string;
  columnName: string;
  propValue: TValue;
  pkColumn: string;
  pkValue: TValue;
begin
  if not Assigned(AEntity) then
    Exit;

  query := TFDQuery.Create(nil);
  setParts := TStringList.Create;
  try
    query.Connection := FConnection;

    rType := ACtx.GetType(AEntityClass);

    pkColumn := GetPrimaryKeyColumn(AEntityClass);
    pkValue := TValue.Empty;

    for prop in rType.GetProperties do
    begin
      for attr in prop.GetAttributes do
      begin
        if attr is Column then
        begin
          colAttr := attr as Column;
          if colAttr.IsPrimaryKey then
          begin
            pkValue := prop.GetValue(AEntity);
            Break;
          end;
        end;
      end;
      if not pkValue.IsEmpty then
        Break;
    end;

    if pkValue.IsEmpty or (pkValue.AsInt64 <= 0) then
      Exit;

    for prop in rType.GetProperties do
    begin
      if not prop.IsReadable then
        Continue;

      colAttr := nil;
      for attr in prop.GetAttributes do
      begin
        if attr is NotMapped then
          Break;
        if attr is HasOneAttribute then
          Break;
        if attr is HasManyAttribute then
          Break;
        if attr is BelongsToAttribute then
          Break;
        if attr is Column then
        begin
          colAttr := attr as Column;
          Break;
        end;
      end;

      if not Assigned(colAttr) then
        Continue;

      if colAttr.IsPrimaryKey or colAttr.IsAutoIncrement then
        Continue;

//        if (colAttr.SqlUseWhichCols <> []) and not (cucUpdate in colAttr.SqlUseWhichCols) then
//          Continue;

      columnName := GetColumnName(prop);
      setParts.Add(columnName + ' = :' + columnName);
    end;

    if setParts.Count = 0 then
      Exit;

    whereClause := pkColumn + ' = :' + pkColumn;
    updateSql := Format('UPDATE %s SET %s WHERE %s', [
      GetFullTableName(AEntityClass),
      setParts.CommaText.Replace('"', ''),
      whereClause
    ]);

    query.SQL.Text := updateSql;
    query.ParamByName(pkColumn).Value := pkValue.AsVariant;

    for prop in rType.GetProperties do
    begin
      if not prop.IsReadable then
        Continue;

      colAttr := nil;
      for attr in prop.GetAttributes do
      begin
        if attr is Column then
        begin
          colAttr := attr as Column;
          Break;
        end;
      end;

      if not Assigned(colAttr) or colAttr.IsPrimaryKey or colAttr.IsAutoIncrement then
        Continue;

//        if (colAttr.SqlUseWhichCols <> []) and not (cucUpdate in colAttr.SqlUseWhichCols) then
//          Continue;

      columnName := GetColumnName(prop);
      if query.ParamByName(columnName) <> nil then
      begin
        propValue := prop.GetValue(AEntity);
        if not propValue.IsEmpty then
          query.ParamByName(columnName).Value := propValue.AsVariant
        else
          query.ParamByName(columnName).Value := Null;
      end;
    end;

    query.ExecSQL;
  finally
    query.Free;
    setParts.Free;
  end;
end;

procedure TRepository<T>.CloneEntityProperties(ASource, ATarget: TObject; AEntityClass: TClass; ADeepClone: Boolean);
var
  rType: TRttiType;
  prop: TRttiProperty;
  attr: TCustomAttribute;
  colAttr: Column;
  propValue: TValue;
begin
  if not Assigned(ASource) or not Assigned(ATarget) then
    Exit;

  rType := ACtx.GetType(AEntityClass);

  for prop in rType.GetProperties do
  begin
    if not prop.IsReadable or not prop.IsWritable then
      Continue;

    colAttr := nil;
    for attr in prop.GetAttributes do
    begin
      if attr is Column then
      begin
        colAttr := attr as Column;
        Break;
      end
      else if attr is NotMapped then
      begin
        Break;
      end
      else if (attr is HasOneAttribute) or (attr is HasManyAttribute) or (attr is BelongsToAttribute) then
      begin
        if not ADeepClone then
          Break;
      end;
    end;

    if not Assigned(colAttr) then
      Continue;

    propValue := prop.GetValue(ASource);

    if colAttr.IsPrimaryKey and colAttr.IsAutoIncrement and not propValue.IsEmpty then
    begin
      case prop.PropertyType.TypeKind of
        tkInteger: prop.SetValue(ATarget, TValue.From<Integer>(0));
        tkInt64: prop.SetValue(ATarget, TValue.From<Int64>(0));
      end;
    end
    else
    begin
      if not propValue.IsEmpty then
        prop.SetValue(ATarget, propValue);
    end;
  end;
end;

procedure TRepository<T>.ProcessCascadeDeletes(AModel: T; ACascade: TCascadeOperations);
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

function TRepository<T>.GetColumnNameForProperty(const APropertyName: string): string;
var
  rType: TRttiType;
  prop: TRttiProperty;
begin
  Result := LowerCase(APropertyName);

  rType := ACtx.GetType(T);
  prop := rType.GetProperty(APropertyName);

  if Assigned(prop) then
    Result := GetColumnName(prop);
end;

function TRepository<T>.GetColumnNameForProperty(AClass: TClass; const APropertyName: string): string;
var
  rType: TRttiType;
  prop: TRttiProperty;
begin
  Result := LowerCase(APropertyName);

  rType := ACtx.GetType(AClass);
  prop := rType.GetProperty(APropertyName);

  if Assigned(prop) then
    Result := GetColumnName(prop);
end;

function TRepository<T>.FindById(AId: TValue; ALock: Boolean = False; AInclude: TIncludeOptions = [ioIncludeNone]; ARelations: TRelationNames = nil): T;
var
  LQuery: TFDQuery;
  LWhereClause: string;
  LLockClause: string;
  LSql: string;
  LPrimaryKeyColumn: string;
  LTableName: string;
begin
  Result := nil;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    LPrimaryKeyColumn := GetPrimaryKeyColumn(T);
    LWhereClause := Format('%s = :pk_id', [LPrimaryKeyColumn]);
    LTableName := GetTableName(T);

    LLockClause := '';
    if ALock then
      LLockClause := Format(' FOR UPDATE OF %s NOWAIT', [LTableName]);

    LSql := GenerateSelectSql(T, LWhereClause) + LLockClause;
    LQuery.SQL.Text := LSql;
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

function TRepository<T>.FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AInclude: TIncludeOptions = [ioIncludeNone]; ARelations: TRelationNames = nil): T;
var
  LQuery: TFDQuery;
  LWhereClause: TStringBuilder;
  LSql: string;
  LLockClause: string;
  i: Integer;
  LFilter: TFilterCriterion;
  LColumnName: string;
  LParamName: string;
begin
  Result := nil;

  if not Assigned(AFilter) or (AFilter.Count = 0) then
    raise Exception.Create('FindOne requires at least one filter criterion.');

  LQuery := TFDQuery.Create(nil);
  LWhereClause := TStringBuilder.Create;
  try
    LQuery.Connection := Connection;

    for i := 0 to AFilter.Count - 1 do
    begin
      LFilter := AFilter[i];
      if i > 0 then
        LWhereClause.Append(' AND ');

      LColumnName := GetColumnNameForProperty(LFilter.PropertyNamePath);

      LParamName := Format('p_%s_%d', [LFilter.PropertyNamePath.Replace('.', '_'), i]);

      LWhereClause.Append(LColumnName).Append(' ').Append(LFilter.Operator).Append(' :').Append(LParamName);

      LQuery.Params.Add(LParamName, LFilter.Value.AsVariant);
    end;

    LLockClause := '';
    if ALock then
      LLockClause := ' FOR UPDATE';

    LSql := GenerateSelectSql(T, LWhereClause.ToString) + LLockClause + ' LIMIT 1';
    LQuery.SQL.Text := LSql;

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
    LWhereClause.Free;
  end;
end;

function TRepository<T>.Find(AFilter: TFilterCriteria; ALock: Boolean = False; AInclude: TIncludeOptions = [ioIncludeNone]; ARelations: TRelationNames = nil): TList<T>;
var
  LQuery: TFDQuery;
  LWhereClause: TStringBuilder;
  LSql: string;
  LLockClause: string;
  i: Integer;
  LFilter: TFilterCriterion;
  LColumnName: string;
  LParamName: string;
  LEntity: T;
begin
  Result := TObjectList<T>.Create(True);
  LQuery := TFDQuery.Create(nil);
  LWhereClause := TStringBuilder.Create;
  try
    LQuery.Connection := Connection;

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for i := 0 to AFilter.Count - 1 do
      begin
        LFilter := AFilter[i];
        if i > 0 then
          LWhereClause.Append(' AND ');

        LColumnName := GetColumnNameForProperty(LFilter.PropertyNamePath);

        LParamName := Format('p_%s_%d', [LFilter.PropertyNamePath.Replace('.', '_'), i]);

        LWhereClause.Append(LColumnName).Append(' ').Append(LFilter.Operator).Append(' :').Append(LParamName);

        LQuery.Params.Add(LParamName, LFilter.Value.AsVariant);
      end;
    end;

    LLockClause := '';
    if ALock then
      LLockClause := ' FOR UPDATE';

    LSql := GenerateSelectSql(T, LWhereClause.ToString) + LLockClause;
    LQuery.SQL.Text := LSql;
    LQuery.Open;

    while not LQuery.Eof do
    begin
      LEntity := T(CreateEntityInstanceByClass(T));
      FillEntityFromDataSet(LEntity, LQuery);

      if (AInclude <> [ioIncludeNone]) or (ARelations <> nil) then
        FillNestedEntitiesWithInclude(LEntity, AInclude, ARelations);

      Result.Add(LEntity);
      LQuery.Next;
    end;
  finally
    LQuery.Free;
    LWhereClause.Free;
  end;
end;

function TRepository<T>.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var LTableName: string;
begin
  LTableName := GetTableName(T);

  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + LTableName + ' WHERE 1=1 ';
end;

procedure TRepository<T>.Add(AModel: T; ACascade: TCascadeOperations = []);
var
  query: TFDQuery;
  insertSql: string;
  rType: TRttiType;
  prop: TRttiProperty;
  attr: TCustomAttribute;
  colAttr: Column;
  createdAtAttr: CreatedAt;
  updatedAtAttr: UpdatedAt;
  columns, values: TStringList;
  columnName: string;
  propValue: TValue;
  insertedId: Int64;
  pkColumn: string;
  pkProp: TRttiProperty;
  isAttributeProcessed: Boolean;
begin
  GLogger.InfoFmt('Ekleme işlemi başladı: %s', [AModel.ClassName]);
  insertedId := -1;
  try
    if not Assigned(AModel) then
      raise Exception.Create('Model cannot be nil');

    if not Assigned(FConnection) then
      raise Exception.Create('Database connection is not available');

    query := TFDQuery.Create(nil);
    columns := TStringList.Create;
    values := TStringList.Create;
    try
      query.Connection := FConnection;

      rType := ACtx.GetType(T);

      for prop in rType.GetProperties do
      begin
        if not prop.IsWritable then
          Continue;

        for attr in prop.GetAttributes do
        begin
          if attr is CreatedAt then
          begin
            createdAtAttr := attr as CreatedAt;
            if createdAtAttr.AutoUpdate then
            begin
              propValue := prop.GetValue(TObject(AModel));
              if propValue.IsEmpty or (propValue.AsType<TDateTime> <= 0) then
                prop.SetValue(TObject(AModel), TValue.From<TDateTime>(Now));
            end;
            Break;
          end
          else if attr is UpdatedAt then
          begin
            updatedAtAttr := attr as UpdatedAt;
            if updatedAtAttr.AutoUpdate then
            begin
              prop.SetValue(TObject(AModel), TValue.From<TDateTime>(Now));
            end;
            Break;
          end
          else if attr is CreatedBy then
          begin
            propValue := prop.GetValue(TObject(AModel));
            if propValue.IsEmpty then
            begin
              // TODO: Implement user ID provider mechanism
            end;
            Break;
          end
          else if attr is UpdatedBy then
          begin
            propValue := prop.GetValue(TObject(AModel));
            if propValue.IsEmpty then
            begin
              // TODO: Implement user ID provider mechanism
            end;
            Break;
          end;
        end;
      end;

      for prop in rType.GetProperties do
      begin
        if not prop.IsReadable then
          Continue;

        colAttr := nil;
        isAttributeProcessed := False;

        for attr in prop.GetAttributes do
        begin
          if (attr is NotMapped) or (attr is HasOneAttribute) or
             (attr is HasManyAttribute) or (attr is BelongsToAttribute)
          then
          begin
            isAttributeProcessed := True;
            Break;
          end;
          if attr is Column then
          begin
            colAttr := attr as Column;
          end;
        end;

        if isAttributeProcessed then
          Continue;

        if not Assigned(colAttr) or colAttr.IsAutoIncrement then
          Continue;

        columnName := GetColumnName(prop);
        propValue := prop.GetValue(TObject(AModel));

        if propValue.IsEmpty then
        begin
          if colAttr.IsNotNull then
            raise Exception.CreateFmt('Required field %s cannot be null', [prop.Name])
          else
            Continue;
        end;

        columns.Add(columnName);
        values.Add(':' + columnName);
      end;

      if columns.Count = 0 then
        raise Exception.Create('No columns to insert for entity ' + T.ClassName);

      insertSql := Format('INSERT INTO %s (%s) VALUES (%s)', [
        GetFullTableName(T),
        string.Join(',', columns.ToStringArray),
        string.Join(',', values.ToStringArray)
      ]);

      pkColumn := GetPrimaryKeyColumn(T);
      if pkColumn <> '' then
        insertSql := insertSql + ' RETURNING ' + pkColumn;

      query.SQL.Text := insertSql;

      for prop in rType.GetProperties do
      begin
        if not prop.IsReadable then
          Continue;

        colAttr := nil;
        for attr in prop.GetAttributes do
        begin
          if attr is Column then
          begin
            colAttr := attr as Column;
            Break;
          end;
        end;

        if not Assigned(colAttr) or colAttr.IsAutoIncrement then
          Continue;

        columnName := GetColumnName(prop);
        if query.Params.FindParam(columnName) <> nil then
        begin
          propValue := prop.GetValue(TObject(AModel));
          if not propValue.IsEmpty then
            query.ParamByName(columnName).Value := propValue.AsVariant
          else
            query.ParamByName(columnName).Value := Null;
        end;
      end;

      try
        query.Open;
      except
        on E: Exception do
          raise Exception.CreateFmt('Failed to insert entity %s: %s', [T.ClassName, E.Message]);
      end;

      if (pkColumn <> '') and (not query.IsEmpty) then
      begin
        insertedId := query.Fields[0].AsLargeInt;

        GLogger.InfoFmt('Kayıt eklendi: %s (ID: %d)', [AModel.ClassName, insertedId]);

        pkProp := nil;
        for prop in rType.GetProperties do
        begin
          if not prop.IsWritable then
            Continue;

          for attr in prop.GetAttributes do
          begin
            if attr is Column then
            begin
              colAttr := attr as Column;
              if colAttr.IsPrimaryKey then
              begin
                pkProp := prop;
                Break;
              end;
            end;
          end;
          if Assigned(pkProp) then Break;
        end;

        if Assigned(pkProp) then
          pkProp.SetValue(TObject(AModel), TValue.From<Int64>(insertedId));

        if coInsert in ACascade then
        begin
          try
            GLogger.DebugFmt('Cascade insert başlıyor: %s (ID: %d)', [AModel.ClassName, insertedId]);
            ProcessHasManyInserts(AModel, insertedId);
            GLogger.DebugFmt('Cascade insert tamamlandı: %s (ID: %d)', [AModel.ClassName, insertedId]);
          except
            on E: Exception do
              raise Exception.CreateFmt('Failed to process cascade inserts: %s', [E.Message]);
          end;
        end;
      end;

    finally
      query.Free;
      columns.Free;
      values.Free;
    end;

    GLogger.InfoFmt('Ekleme işlemi tamamlandı: %s (ID: %d)', [AModel.ClassName, insertedId]);
  except
    on E: Exception do
    begin
      GLogger.ErrorLog(E, Format('Ekleme işlemi başarısız: %s', [AModel.ClassName]));
      raise;
    end;
  end;
end;

procedure TRepository<T>.AddBatch(AModels: TArray<T>; ACascade: TCascadeOperations = []);
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

procedure TRepository<T>.Update(AModel: T; ACascade: TCascadeOperations = []);
var
  query: TFDQuery;
  updateSql: string;
  rType: TRttiType;
  prop: TRttiProperty;
  attr: TCustomAttribute;
  colAttr: Column;
  updatedAtAttr: UpdatedAt;
  versionProp: TRttiProperty;
  setParts: TStringList;
  whereClause: string;
  columnName: string;
  propValue: TValue;
  pkColumn: string;
  pkValue: TValue;
  pkProp: TRttiProperty;
  versionValue: TValue;
  isAttributeProcessed: Boolean;
begin
  GLogger.InfoFmt('Güncelleme işlemi başladı: %s', [AModel.ClassName]);

  if not Assigned(AModel) then
    raise Exception.Create('Model cannot be nil');

  if not Assigned(FConnection) then
    raise Exception.Create('Database connection is not available');

  query := TFDQuery.Create(nil);
  setParts := TStringList.Create;
  versionProp := nil;
  pkProp := nil;
  try
    query.Connection := FConnection;
    rType := ACtx.GetType(T);

    pkColumn := GetPrimaryKeyColumn(T);
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
            pkProp := prop;
            Break;
          end;
        end;
      end;
      if Assigned(pkProp) then
        Break;
    end;

    if not Assigned(pkProp) then
      raise Exception.Create('Primary key property not found for entity ' + T.ClassName);

    pkValue := pkProp.GetValue(TObject(AModel));
    if pkValue.IsEmpty or (pkValue.AsInt64 <= 0) then
      raise Exception.Create('Primary key value is required for update operation');

    GLogger.DebugFmt('PK bulundu: %s = %s', [pkColumn, pkValue.ToString]);

    for prop in rType.GetProperties do
    begin
      if not prop.IsWritable then
        Continue;

      for attr in prop.GetAttributes do
      begin
        if attr is UpdatedAt then
        begin
          updatedAtAttr := attr as UpdatedAt;
          if updatedAtAttr.AutoUpdate then
            prop.SetValue(TObject(AModel), TValue.From<TDateTime>(Now));
          Break;
        end
        else if attr is UpdatedBy then
        begin
          propValue := prop.GetValue(TObject(AModel));
          // TODO: Implement user provider mechanism
          // if propValue.IsEmpty then
          //   prop.SetValue(TObject(AModel), TValue.From<Int64>(GetCurrentUserId));
          Break;
        end
        else if attr is Version then
        begin
          versionProp := prop;
          Break;
        end;
      end;
    end;

    for prop in rType.GetProperties do
    begin
      if not prop.IsReadable then
        Continue;

      colAttr := nil;
      isAttributeProcessed := False;

      for attr in prop.GetAttributes do
      begin
        if (attr is NotMapped) or (attr is HasManyAttribute) or
           (attr is BelongsToAttribute) or (attr is HasOneAttribute) then
        begin
          isAttributeProcessed := True;
          Break;
        end;
        if attr is Column then
          colAttr := attr as Column;
      end;

      if isAttributeProcessed then
        Continue;

      if not Assigned(colAttr) or colAttr.IsPrimaryKey or colAttr.IsAutoIncrement then
        Continue;

//        if (colAttr.SqlUseWhichCols <> []) and not (cucUpdate in colAttr.SqlUseWhichCols) then
//          Continue;

      columnName := GetColumnName(prop);

      if prop = versionProp then
      begin
        versionValue := prop.GetValue(TObject(AModel));
        setParts.Add(Format('%s = %s + 1', [columnName, columnName]));
      end
      else
      begin
        setParts.Add(columnName + ' = :' + columnName);
      end;
    end;

    if setParts.Count = 0 then
      Exit;

    GLogger.DebugFmt('Güncellenecek kolonlar: %s', [setParts.CommaText]);

    whereClause := pkColumn + ' = :pk_value';

    if Assigned(versionProp) then
    begin
      if versionValue.IsEmpty then
        raise Exception.Create('Version value is required for optimistic locking');
      columnName := GetColumnName(versionProp);
      whereClause := whereClause + ' AND ' + columnName + ' = :version_value';
    end;

    updateSql := Format('UPDATE %s SET %s WHERE %s', [
      GetFullTableName(T),
      string.Join(',', StringListToArray(setParts)),
      whereClause
    ]);

    query.SQL.Text := updateSql;
    GLogger.Debug('SQL: ' + updateSql);
    try
      query.ParamByName('pk_value').Value := pkValue.AsVariant;

      if Assigned(versionProp) then
        query.ParamByName('version_value').Value := versionValue.AsVariant;

      for prop in rType.GetProperties do
      begin
        if not prop.IsReadable then
          Continue;

        colAttr := nil;
        isAttributeProcessed := False;

        for attr in prop.GetAttributes do
        begin
          if (attr is NotMapped) or (attr is HasManyAttribute) or
             (attr is BelongsToAttribute) or (attr is HasOneAttribute) then
          begin
            isAttributeProcessed := True;
            Break;
          end;
          if attr is Column then
            colAttr := attr as Column;
        end;

        if isAttributeProcessed then
          Continue;

        if not Assigned(colAttr) or colAttr.IsPrimaryKey or
           colAttr.IsAutoIncrement or (prop = versionProp) then
          Continue;

//          if (colAttr.SqlUseWhichCols <> []) and not (cucUpdate in colAttr.SqlUseWhichCols) then
//            Continue;

        columnName := GetColumnName(prop);
        if query.Params.FindParam(columnName) <> nil then
        begin
          propValue := prop.GetValue(TObject(AModel));
          if not propValue.IsEmpty then
            query.ParamByName(columnName).Value := propValue.AsVariant
          else
            query.ParamByName(columnName).Value := Null;
        end;
      end;

    except
      on E: Exception do
        raise Exception.CreateFmt('Error setting update parameters: %s', [E.Message]);
    end;

    try
      query.ExecSQL;

      if query.RowsAffected < 1 then
      begin
        if Assigned(versionProp) then
        begin
          GLogger.Warning('Concurrency conflict detected!');
          raise Exception.Create('Concurrency error: The record was modified by another user or does not exist')
        end;
      end;

      GLogger.InfoFmt('Güncelleme başarılı: %s (PK: %s)', [AModel.ClassName, pkValue.ToString]);

      if Assigned(versionProp) and versionProp.IsWritable then
      begin
        try
          versionProp.SetValue(TObject(AModel), TValue.From<Integer>(versionValue.AsInteger + 1));
          GLogger.DebugFmt('Yeni versiyon: %d', [versionValue.AsInteger + 1]);
        except

        end;
      end;

    except
      on E: Exception do
        raise Exception.CreateFmt('Failed to update entity %s: %s', [T.ClassName, E.Message]);
    end;

    if coUpdate in ACascade then
    begin
      try
        GLogger.Debug('Cascade update başlıyor...');
        ProcessHasManyUpdates(AModel, pkValue.AsInt64);
        GLogger.Debug('Cascade update tamamlandı.');
      except
        on E: Exception do
          raise Exception.CreateFmt('Failed to process cascade updates: %s', [E.Message]);
      end;
    end;
  finally
    query.Free;
    setParts.Free;
    GLogger.InfoFmt('Güncelleme işlemi tamamlandı: %s', [AModel.ClassName]);
  end;
end;

procedure TRepository<T>.UpdateBatch(AModels: TArray<T>; ACascade: TCascadeOperations = []);
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

procedure TRepository<T>.Delete(AID: Int64; ACascade: TCascadeOperations = []);
var
  model: T;
  query: TFDQuery;
  sql, pkColumn: string;
  rType: TRttiType;
  attr: TCustomAttribute;
  softDeleteAttr: SoftDelete;
begin
  if AID <= 0 then
    raise Exception.Create('Invalid ID: ID must be greater than 0');

  if not Assigned(FConnection) then
    raise Exception.Create('Database connection is not available');

  softDeleteAttr := nil;

  rType := ACtx.GetType(T);
  for attr in rType.GetAttributes do
  begin
    if attr is SoftDelete then
    begin
      softDeleteAttr := attr as SoftDelete;
      Break;
    end;
  end;

  model := nil;
  if coDelete in ACascade then
  begin
    try
      model := FindById(AID);
      if Assigned(model) then
      begin
        try
          ProcessCascadeDeletes(model, ACascade);
        except
          on E: Exception do
          begin
            if Assigned(model) then
              model.Free;
            raise Exception.CreateFmt('Failed to process cascade deletes: %s', [E.Message]);
          end;
        end;
      end
      else
        raise Exception.CreateFmt('Record with ID %d not found for cascade delete', [AID]);
    except
      on E: Exception do
        raise Exception.CreateFmt('Failed to load model for cascade delete: %s', [E.Message]);
    end;
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

      sql := sql + Format(' WHERE %s = :pk_id', [pkColumn]);

      sql := sql + Format(' AND %s IS NULL', [softDeleteAttr.DeletedAtColumn]);

      query.SQL.Text := sql;
      try
        query.ParamByName('deleted_at').AsDateTime := Now;
        if softDeleteAttr.DeletedByColumn <> '' then
        begin
          query.ParamByName('deleted_by').AsLargeInt := 0;
        end;
        query.ParamByName('pk_id').AsLargeInt := AID;
      except
        on E: Exception do
          raise Exception.CreateFmt('Error setting soft delete parameters: %s', [E.Message]);
      end;
    end
    else
    begin
      sql := Format('DELETE FROM %s WHERE %s = :pk_id', [
        GetFullTableName(T),
        pkColumn
      ]);
      query.SQL.Text := sql;

      try
        query.ParamByName('pk_id').AsLargeInt := AID;
      except
        on E: Exception do
          raise Exception.CreateFmt('Error setting delete parameters: %s', [E.Message]);
      end;
    end;

    try
      query.ExecSQL;

      if query.RowsAffected < 1 then
      begin
        if Assigned(softDeleteAttr) then
          raise Exception.CreateFmt('Soft delete failed: Record with ID %d not found or already deleted', [AID])
        else
          raise Exception.CreateFmt('Delete failed: Record with ID %d not found', [AID]);
      end;
    except
      on E: Exception do
        raise Exception.CreateFmt('Failed to delete record with ID %d: %s', [AID, E.Message]);
    end;

  finally
    query.Free;
    if Assigned(model) then
      model.Free;
  end;
end;

procedure TRepository<T>.Delete(AModel: T; ACascade: TCascadeOperations = []);
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

procedure TRepository<T>.DeleteBatch(AModels: TArray<T>; ACascade: TCascadeOperations = []);
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

procedure TRepository<T>.DeleteBatch(AIDs: TArray<Int64>; ACascade: TCascadeOperations = []);
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

procedure TRepository<T>.DeleteBatch(AFilter: TFilterCriteria; ACascade: TCascadeOperations = []);
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

function TRepository<T>.Clone(ASource: T): T;
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

      if (colAttr = nil) and (hasOneAttr = nil) and
         (hasManyAttr = nil) and (belongsToAttr = nil) then
        Continue;

      propValue := prop.GetValue(TObject(ASource));

      // -------------------------------------------------------
      // Column
      // -------------------------------------------------------
      if Assigned(colAttr) then
      begin
        if colAttr.IsPrimaryKey and colAttr.IsAutoIncrement
           and not propValue.IsEmpty then
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

      // -------------------------------------------------------
      // BelongsTo  — constructor zaten instance oluşturmuş olabilir
      // -------------------------------------------------------
      else if Assigned(belongsToAttr) then
      begin
        sourceNestedEntity := propValue.AsObject;
        if Assigned(sourceNestedEntity) then
        begin
          nestedEntityClass := prop.PropertyType.AsInstance.MetaclassType;

          // *** DÜZELTME: Result'taki mevcut instance'ı al ***
          clonedNestedEntity := prop.GetValue(TObject(Result)).AsObject;

          if not Assigned(clonedNestedEntity) then
          begin
            // Constructor oluşturmamışsa yeni oluştur ve ata
            clonedNestedEntity := CreateEntityInstanceByClass(nestedEntityClass);
            prop.SetValue(TObject(Result), clonedNestedEntity);
          end;
          // Artık sadece değerleri kopyala, yeni instance yok
          CloneEntityProperties(sourceNestedEntity, clonedNestedEntity,
                                nestedEntityClass, False);
        end;
      end

      // -------------------------------------------------------
      // HasOne  — aynı yaklaşım
      // -------------------------------------------------------
      else if Assigned(hasOneAttr) then
      begin
        sourceNestedEntity := propValue.AsObject;
        if Assigned(sourceNestedEntity) then
        begin
          nestedEntityClass := prop.PropertyType.AsInstance.MetaclassType;

          // *** DÜZELTME: Result'taki mevcut instance'ı al ***
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

      // -------------------------------------------------------
      // HasMany  — liste elemanları hâlâ yeni clone, değişmez
      // -------------------------------------------------------
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
              CloneEntityProperties(sourceItem, clonedItem,
                                    nestedEntityClass, False);
              addMethod.Invoke(targetList, [clonedItem]);
            end;
          end;
        end;
      end;

    end; // for prop

  finally
    ctx.Free;
  end;
end;

end.
