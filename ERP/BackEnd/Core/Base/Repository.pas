unit Repository;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.StrUtils, System.Classes, System.Variants, Data.DB,
  System.TypInfo, System.Rtti, System.Generics.Collections, System.Types,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  Entity, EntityAttributes, FilterCriterion;

type
  IRepository<T: TEntity> = interface
    ['{808825C5-94CA-4B8F-BCEA-D351F4F6813E}']
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;

    function FindById(AId: TValue; ALock: Boolean = False): T;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): T; overload;
    function FindOne(AFilter: TFilterCriteria; ASort: TSortCriteria; ALock: Boolean = False): T; overload;
    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<T>; overload;
    function Find(AFilter: TFilterCriteria; ASort: TSortCriteria; ALock: Boolean = False): TObjectList<T>; overload;

    procedure Add(AModel: T); overload;
    procedure AddBatch(AModels: TArray<T>); overload;

    procedure Update(AModel: T);
    procedure UpdateBatch(AModels: TArray<T>); overload;

    procedure Delete(AID: TValue); overload;
    procedure Delete(AModel: T); overload;
    procedure DeleteBatch(AModels: TArray<T>); overload;
    procedure DeleteBatch(AIDs: TArray<TValue>); overload;
    procedure DeleteBatch(AFilter: TFilterCriteria); overload;
  end;

  TNullColumnKind = (nckOther, nckText, nckNumeric, nckDate);

  TNullColumn = record
    Nullable: Boolean;
    HasDefault: Boolean;
    Kind: TNullColumnKind;
  end;

  /// <summary>
  /// Yazma parametrelerine boş değer standardını uygular (tablonun kolon metadatasına göre, önbellekli):
  /// nullable metin '' -> NULL; nullable sayı 0 -> NULL (AKeepZero hariç); nullable tarih 0 -> NULL;
  /// NOT NULL + varsayılansız metin boşsa "alan zorunlu" hatası. NOT NULL sayılarda 0 geçerli değerdir.
  /// </summary>
  TNullPolicy = class
  private
    class var FCache: TObjectDictionary<string, TDictionary<string, TNullColumn>>;
    class var FLock: TObject;
    class function GetColumns(AConnection: TFDConnection; const ATableName: string): TDictionary<string, TNullColumn>;
  public
    class constructor Create;
    class destructor Destroy;
    class procedure Apply(AConnection: TFDConnection; Q: TFDQuery; const ATableName: string; const AKeepZero: TArray<string>);
  end;

  TRepository<T: TEntity> = class(TInterfacedObject, IRepository<T>)
  private
    FConnection: TFDConnection;
  protected
    function ExpandSQLWithParams(Q: TFDQuery): string;
    procedure LogQuery(Q: TFDQuery; const AOperation: string = '');

    function PrepareSelectFromView(AFilter: TFilterCriteria; ALock: Boolean; AGetOnlyOneRecord: Boolean = False; AApplyLocaleFilter: Boolean = False): string; overload;
    function PrepareSelectFromView(AFilter: TFilterCriteria; ASort: TSortCriteria; ALock: Boolean; AGetOnlyOneRecord: Boolean = False; AApplyLocaleFilter: Boolean = False): string; overload;
    function BuildSelectColumns(const AAlwaysFetch: TArray<string> = []): string; virtual;

    function Connection: TFDConnection;
    function GetTableName(AClass: TClass): string;
    function GetFullTableName(AClass: TClass): string;
    function GetFullViewName(AClass: TClass): string;
    function GetViewName(AClass: TClass): string;

    function MapFromQuery(Q: TFDQuery): T; virtual; abstract;

    // Insert/update öncesi (LogQuery'den hemen önce): boş değer standardı (TNullPolicy)
    procedure ApplyNullPolicy(Q: TFDQuery; const ATableName: string = '');
    // Nullable olduğu halde 0'ın anlamlı olduğu kolonlar (ör. stk_inventory.vat_rate: NULL = gruptan, 0 = %0)
    function NullPolicyKeepZero: TArray<string>; virtual;

    // Nullable FK/int kolonlar: AValue <= 0 ise NULL gönderir (0 FK ihlalini önler)
    procedure SetNullableParam(AParam: TFDParam; ADataType: TFieldType; AValue: Int64; AIndex: Integer = -1);

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; virtual; abstract;

    function DoFindById(AId: TValue; ALock: Boolean = False): T; virtual; abstract;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): T; overload; virtual; abstract;
    function DoFindOne(AFilter: TFilterCriteria; ASort: TSortCriteria; ALock: Boolean = False): T; overload; virtual;
    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<T>; overload; virtual; abstract;
    function DoFind(AFilter: TFilterCriteria; ASort: TSortCriteria; ALock: Boolean = False): TObjectList<T>; overload; virtual;

    procedure DoAdd(AModel: T); virtual; abstract;
    procedure DoAddBatch(AModels: TArray<T>); virtual; abstract;

    procedure DoUpdate(AModel: T); virtual; abstract;
    procedure DoUpdateBatch(AModels: TArray<T>); virtual; abstract;

    procedure DoDelete(AId: TValue); overload; virtual; abstract;
    procedure DoDelete(AModel: T); overload; virtual; abstract;
    procedure DoDeleteBatch(AModels: TArray<T>); overload; virtual; abstract;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); overload; virtual; abstract;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); overload; virtual; abstract;
  public
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; virtual;

    function FindById(AId: TValue; ALock: Boolean = False): T; virtual;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): T; overload; virtual;
    function FindOne(AFilter: TFilterCriteria; ASort: TSortCriteria; ALock: Boolean = False): T; overload; virtual;
    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<T>; overload; virtual;
    function Find(AFilter: TFilterCriteria; ASort: TSortCriteria; ALock: Boolean = False): TObjectList<T>; overload; virtual;

    procedure Add(AModel: T); virtual;
    procedure AddBatch(AModels: TArray<T>); virtual;

    procedure Update(AModel: T); virtual;
    procedure UpdateBatch(AModels: TArray<T>); virtual;

    procedure Delete(AId: TValue); overload; virtual;
    procedure Delete(AModel: T); overload; virtual;
    procedure DeleteBatch(AModels: TArray<T>); overload; virtual;
    procedure DeleteBatch(AIDs: TArray<TValue>); overload; virtual;
    procedure DeleteBatch(AFilter: TFilterCriteria); overload; virtual;

    constructor Create(AConnection: TFDConnection);
    destructor Destroy; override;
  end;

implementation

uses
  System.Generics.Defaults,
  EntitySchemaCache, Logger, AppContext, SysGridColumnHelper, LocalizationManager;

{ TNullPolicy }

class constructor TNullPolicy.Create;
begin
  FLock := TObject.Create;
  FCache := TObjectDictionary<string, TDictionary<string, TNullColumn>>.Create([doOwnsValues]);
end;

class destructor TNullPolicy.Destroy;
begin
  FreeAndNil(FCache);
  FreeAndNil(FLock);
end;

class function TNullPolicy.GetColumns(AConnection: TFDConnection; const ATableName: string): TDictionary<string, TNullColumn>;
var
  Q: TFDQuery;
  LCols: TDictionary<string, TNullColumn>;
  LCol: TNullColumn;
  LType: string;
begin
  TMonitor.Enter(FLock);
  try
    if FCache.TryGetValue(LowerCase(ATableName), Result) then
      Exit;

    LCols := TDictionary<string, TNullColumn>.Create;
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := AConnection;
      Q.SQL.Text :=
        'SELECT column_name, is_nullable = ''YES'', ' +
        '       (column_default IS NOT NULL OR is_identity = ''YES'' OR is_generated <> ''NEVER''), data_type ' +
        '  FROM information_schema.columns WHERE table_schema = ''public'' AND table_name = :t';
      Q.ParamByName('t').AsWideString := LowerCase(ATableName);
      Q.Open;
      while not Q.Eof do
      begin
        LCol.Nullable := Q.Fields[1].AsBoolean;
        LCol.HasDefault := Q.Fields[2].AsBoolean;
        LType := Q.Fields[3].AsString;
        if MatchText(LType, ['character varying', 'text', 'character']) then
          LCol.Kind := nckText
        else if MatchText(LType, ['numeric', 'integer', 'smallint', 'bigint', 'double precision', 'real']) then
          LCol.Kind := nckNumeric
        else if MatchText(LType, ['date', 'timestamp without time zone', 'timestamp with time zone']) then
          LCol.Kind := nckDate
        else
          LCol.Kind := nckOther;
        LCols.AddOrSetValue(LowerCase(Q.Fields[0].AsString), LCol);
        Q.Next;
      end;
    finally
      Q.Free;
    end;
    FCache.AddOrSetValue(LowerCase(ATableName), LCols);
    Result := LCols;
  finally
    TMonitor.Exit(FLock);
  end;
end;

class procedure TNullPolicy.Apply(AConnection: TFDConnection; Q: TFDQuery; const ATableName: string; const AKeepZero: TArray<string>);
var
  LCols: TDictionary<string, TNullColumn>;
  LCol: TNullColumn;
  P: TFDParam;
  i, j, LCount: Integer;
  V: Variant;
  LKeepZero: Boolean;
begin
  if (Q = nil) or (ATableName = '') then
    Exit;
  LCols := GetColumns(AConnection, ATableName);
  LCount := Q.Params.ArraySize;
  if LCount < 1 then
    LCount := 1;

  for i := 0 to Q.Params.Count - 1 do
  begin
    P := Q.Params[i];
    if not (P.ParamType in [ptUnknown, ptInput, ptInputOutput]) then
      Continue;
    if not LCols.TryGetValue(LowerCase(P.Name), LCol) then
      Continue;
    LKeepZero := MatchText(P.Name, AKeepZero);

    for j := 0 to LCount - 1 do
    begin
      if P.IsNulls[j] then
        Continue;
      V := P.Values[j];
      case LCol.Kind of
        nckText:
          if Trim(VarToStr(V)) = '' then
          begin
            if LCol.Nullable then
              P.Clear(j)
            else if not LCol.HasDefault then
              raise Exception.Create(
                TLocalizationManager.Translate(LowerCase(ATableName) + '.col_' + LowerCase(P.Name), P.Name) + ': ' +
                TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
          end;
        nckNumeric:
          if LCol.Nullable and not LKeepZero and VarIsNumeric(V) and (V = 0) then
            P.Clear(j);
        nckDate:
          if LCol.Nullable and (VarIsNumeric(V) or (VarType(V) = varDate)) and (Double(V) = 0) then
            P.Clear(j);
      end;
    end;
  end;
end;

function TRepository<T>.BuildSelectColumns(const AAlwaysFetch: TArray<string>): string;
var
  Always: TArray<string>;
begin
  Always := AAlwaysFetch;
  if Length(Always) = 0 then
    Always := ['id', 'locale'];
  Result := TGridColumnHelper.BuildSelectColumns(FConnection, GetViewName(T), Always);
end;

procedure TRepository<T>.ApplyNullPolicy(Q: TFDQuery; const ATableName: string);
begin
  if ATableName <> '' then
    TNullPolicy.Apply(FConnection, Q, ATableName, NullPolicyKeepZero)
  else
    TNullPolicy.Apply(FConnection, Q, GetTableName(T), NullPolicyKeepZero);
end;

function TRepository<T>.NullPolicyKeepZero: TArray<string>;
begin
  Result := [];
end;

procedure TRepository<T>.SetNullableParam(AParam: TFDParam; ADataType: TFieldType; AValue: Int64; AIndex: Integer);
begin
  AParam.DataType := ADataType;
  if AValue > 0 then
  begin
    if ADataType = ftInteger then
    begin
      if AIndex < 0 then
        AParam.AsInteger := Integer(AValue)
      else
        AParam.AsIntegers[AIndex] := Integer(AValue);
    end
    else
    begin
      if AIndex < 0 then
        AParam.AsLargeInt := AValue
      else
        AParam.AsLargeInts[AIndex] := AValue;
    end;
  end
  else
  begin
    if AIndex < 0 then
      AParam.Clear
    else
      AParam.Clear(AIndex);
  end;
end;

constructor TRepository<T>.Create(AConnection: TFDConnection);
begin
  if AConnection = nil then
    raise Exception.Create('Connection Required');

  FConnection := AConnection;
end;

destructor TRepository<T>.Destroy;
begin
  inherited;
end;

function TRepository<T>.Connection: TFDConnection;
begin
  Result := FConnection;
end;

function TRepository<T>.GetTableName(AClass: TClass): string;
begin
  Result := TEntitySchemaCache.GetSchema(AClass).TableName;
end;

function TRepository<T>.GetFullTableName(AClass: TClass): string;
begin
  Result := TEntitySchemaCache.GetSchema(AClass).FullTableName;
end;

function TRepository<T>.GetViewName(AClass: TClass): string;
begin
  Result := 'vw_' + GetTableName(AClass);
end;

function TRepository<T>.GetFullViewName(AClass: TClass): string;
begin
  Result := 'public.vw_' + GetTableName(AClass);
end;

function TRepository<T>.PrepareSelectFromView(AFilter: TFilterCriteria; ALock: Boolean; AGetOnlyOneRecord: Boolean; AApplyLocaleFilter: Boolean): string;
begin
  Result := PrepareSelectFromView(AFilter, nil, ALock, AGetOnlyOneRecord, AApplyLocaleFilter);
end;

function TRepository<T>.PrepareSelectFromView(AFilter: TFilterCriteria; ASort: TSortCriteria; ALock: Boolean; AGetOnlyOneRecord: Boolean; AApplyLocaleFilter: Boolean): string;
var
  LFilterSql, LLocaleFilter, Limit1, LOrderBySql: string;
  Criterion: TFilterCriterion;
begin
  LFilterSql := '';
  Limit1 := '';
  LLocaleFilter := '';
  LOrderBySql := BuildOrderByClause(ASort);

  if AGetOnlyOneRecord then
    Limit1 := ' LIMIT 1 ';

  if AApplyLocaleFilter then
    LLocaleFilter := ' AND locale = :locale ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
    for Criterion in AFilter do
      LFilterSql := LFilterSql + ' AND ' + Criterion.FieldName + ' ' + Criterion.Operator + ' :' + Criterion.ParamName;
  LFilterSql := LFilterSql + LLocaleFilter;

  if ALock and (FConnection <> nil) and FConnection.InTransaction then
    Result :=
      'WITH filtered AS (' +
      '  SELECT v.id' +
      '  FROM ' + GetFullViewName(T) + ' v' +
      '  WHERE 1=1' + LFilterSql + LOrderBySql + Limit1 +  // view üzerinde filtrele
      '), ' +
      'lock_rows AS (' +
      '  SELECT id FROM ' + GetFullTableName(T) +  // table'ı kilitle
      '  WHERE id IN (SELECT id FROM filtered)' +
      '  FOR UPDATE' +
      ') ' +
      'SELECT v.* ' +
      'FROM ' + GetFullViewName(T) + ' v ' +
      'INNER JOIN lock_rows l ON l.id = v.id ' +
      'WHERE 1=1 ' + LLocaleFilter +
      LOrderBySql +
      Limit1  // kilitli kayıtları oku
  else
    Result :=
      'SELECT v.* ' +
      'FROM ' + GetFullViewName(T) + ' v ' +
      'WHERE 1=1' + LFilterSql + LOrderBySql + Limit1;
end;

function TRepository<T>.ExpandSQLWithParams(Q: TFDQuery): string;
var
  SQLText: string;
  Param: TFDParam;
  ParamValue: string;
  I: Integer;
  LParams: TList<TFDParam>;
begin
  if Q = nil then Exit('');
  SQLText := Q.SQL.Text;

  // Uzun adlar önce: ":cn1" değeri ":cn10" içine yazılmasın
  LParams := TList<TFDParam>.Create;
  try
    for I := 0 to Q.Params.Count - 1 do
      LParams.Add(Q.Params[I]);
    LParams.Sort(TComparer<TFDParam>.Construct(
      function(const A, B: TFDParam): Integer
      begin
        Result := Length(B.Name) - Length(A.Name);
      end));

  for I := 0 to LParams.Count - 1 do
  begin
    Param := LParams[I];

    if Param.IsNull then
      ParamValue := 'NULL'
    else if Param.DataType in [ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftLargeInt, ftShortint, ftByte, ftLongWord] then
      ParamValue := Param.AsString
    else if Param.DataType = ftBoolean then
    begin
      if Param.AsBoolean then
        ParamValue := 'TRUE'
      else
        ParamValue := 'FALSE';
    end
    else if Param.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] then
      ParamValue := QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Param.AsDateTime))
    else
      ParamValue := QuotedStr(Param.AsString);

    SQLText := StringReplace(SQLText, ':' + Param.Name, ParamValue, [rfReplaceAll, rfIgnoreCase]);
  end;
  finally
    LParams.Free;
  end;

  if Q.Params.ArraySize > 1 then
    SQLText := Format('%s /* [ArraySize: %d] */', [SQLText, Q.Params.ArraySize]);

  Result := Trim(SQLText);
end;

procedure TRepository<T>.LogQuery(Q: TFDQuery; const AOperation: string);
begin
  {$IF Defined(DEBUG) or Defined(FULL_LOG_SQL)}
  if Assigned(Q) then
  begin
    if AOperation <> '' then
      GLogger.LogSQL(ExpandSQLWithParams(Q), Self.ClassName + '.' + AOperation)
    else
      GLogger.LogSQL(ExpandSQLWithParams(Q), Self.ClassName);
  end;
  {$IFEND}
end;

function TRepository<T>.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
begin
  GLogger.InfoFmt('FindAllGridQuery %s', [Self.ClassName]);
  Result := DoFindAllGridQuery(AFilter);
  LogQuery(Result, 'FindAllGridQuery');
  GLogger.InfoFmt('FindAllGridQuery Done %s', [Self.ClassName]);
end;

function TRepository<T>.DoFind(AFilter: TFilterCriteria; ASort: TSortCriteria; ALock: Boolean): TObjectList<T>;
begin
  Result := DoFind(AFilter, ALock);
end;

function TRepository<T>.DoFindOne(AFilter: TFilterCriteria; ASort: TSortCriteria; ALock: Boolean): T;
begin
  Result := DoFindOne(AFilter, ALock);
end;

function TRepository<T>.Find(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<T>;
begin
  GLogger.InfoFmt('Find %s', [Self.ClassName]);
  Result := DoFind(AFilter, ALock);
  GLogger.InfoFmt('Find Done %s', [Self.ClassName]);
end;

function TRepository<T>.Find(AFilter: TFilterCriteria; ASort: TSortCriteria; ALock: Boolean): TObjectList<T>;
begin
  GLogger.InfoFmt('Find (Sort) %s', [Self.ClassName]);
  Result := DoFind(AFilter, ASort, ALock);
  GLogger.InfoFmt('Find (Sort) Done %s', [Self.ClassName]);
end;

function TRepository<T>.FindById(AId: TValue; ALock: Boolean): T;
begin
  GLogger.InfoFmt('FindById %s  ID:%s', [Self.ClassName, AId.AsInt64.ToString]);
  Result := DoFindById(AId, ALock);
  GLogger.InfoFmt('FindById Done %s  ID:%s', [Self.ClassName, AId.AsInt64.ToString]);
end;

function TRepository<T>.FindOne(AFilter: TFilterCriteria; ALock: Boolean): T;
begin
  GLogger.InfoFmt('FindOne %s', [Self.ClassName]);
  Result := DoFindOne(AFilter, ALock);
  GLogger.InfoFmt('FindOne Done %s', [Self.ClassName]);
end;

function TRepository<T>.FindOne(AFilter: TFilterCriteria; ASort: TSortCriteria; ALock: Boolean): T;
begin
  GLogger.InfoFmt('FindOne (Sort) %s', [Self.ClassName]);
  Result := DoFindOne(AFilter, ASort, ALock);
  GLogger.InfoFmt('FindOne (Sort) Done %s', [Self.ClassName]);
end;

procedure TRepository<T>.Add(AModel: T);
begin
  GLogger.InfoFmt('Add %s', [Self.ClassName]);
  DoAdd(AModel);
  GLogger.InfoFmt('Add Done %s', [Self.ClassName]);
end;

procedure TRepository<T>.AddBatch(AModels: TArray<T>);
begin
  GLogger.InfoFmt('AddBatch %s', [Self.ClassName]);
  DoAddBatch(AModels);
  GLogger.InfoFmt('AddBatch Done %s', [Self.ClassName]);
end;

procedure TRepository<T>.Update(AModel: T);
begin
  GLogger.InfoFmt('Update %s', [Self.ClassName]);
  DoUpdate(AModel);
  GLogger.InfoFmt('Update Done %s', [Self.ClassName]);
end;

procedure TRepository<T>.UpdateBatch(AModels: TArray<T>);
begin
  GLogger.InfoFmt('UpdateBatch %s', [Self.ClassName]);
  DoUpdateBatch(AModels);
  GLogger.InfoFmt('UpdateBatch Done %s', [Self.ClassName]);
end;

procedure TRepository<T>.Delete(AModel: T);
begin
  GLogger.InfoFmt('Delete %s', [Self.ClassName]);
  DoDelete(AModel);
  GLogger.InfoFmt('Delete Done %s', [Self.ClassName]);
end;

procedure TRepository<T>.Delete(AId: TValue);
begin
  GLogger.InfoFmt('Delete %s', [Self.ClassName]);
  DoDelete(AID);
  GLogger.InfoFmt('Delete Done %s', [Self.ClassName]);
end;

procedure TRepository<T>.DeleteBatch(AModels: TArray<T>);
begin
  GLogger.InfoFmt('DeleteBatch %s', [Self.ClassName]);
  DoDeleteBatch(AModels);
  GLogger.InfoFmt('DeleteBatch Done %s', [Self.ClassName]);
end;

procedure TRepository<T>.DeleteBatch(AIDs: TArray<TValue>);
begin
  GLogger.InfoFmt('DeleteBatch %s', [Self.ClassName]);
  DoDeleteBatch(AIDs);
  GLogger.InfoFmt('DeleteBatch Done %s', [Self.ClassName]);
end;

procedure TRepository<T>.DeleteBatch(AFilter: TFilterCriteria);
begin
  GLogger.InfoFmt('DeleteBatch Filter [%s]', [Self.ClassName]);
  DoDeleteBatch(AFilter);
  GLogger.InfoFmt('DeleteBatch Filter Done [%s]', [Self.ClassName]);
end;

end.
