unit Repository;

interface

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
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): T;
    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TList<T>;

    procedure Add(AModel: T); overload;
    procedure AddBatch(AModels: TArray<T>); overload;

    procedure Update(AModel: T);
    procedure UpdateBatch(AModels: TArray<T>); overload;

    procedure Delete(AID: Int64); overload;
    procedure Delete(AModel: T); overload;
    procedure DeleteBatch(AModels: TArray<T>); overload;
    procedure DeleteBatch(AIDs: TArray<Int64>); overload;
    procedure DeleteBatch(AFilter: TFilterCriteria); overload;
  end;

  TRepository<T: TEntity> = class(TInterfacedObject, IRepository<T>)
  private
    FConnection: TFDConnection;
  protected
    function PrepareSelectFromView(AFilter: TFilterCriteria; ALock: Boolean; AGetOnlyOneRecord: Boolean = False; AApplyLocaleFilter: Boolean = False): string;

    function Connection: TFDConnection;
    function GetTableName(AClass: TClass): string;
    function GetFullTableName(AClass: TClass): string;
    function GetFullViewName(AClass: TClass): string;
    function GetViewName(AClass: TClass): string;

    function MapFromQuery(Q: TFDQuery): T; virtual; abstract;
  public
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; virtual; abstract;

    function FindById(AId: TValue; ALock: Boolean = False): T; virtual; abstract;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): T; virtual; abstract;
    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TList<T>; virtual; abstract;

    procedure Add(AModel: T); virtual; abstract;
    procedure AddBatch(AModels: TArray<T>); virtual; abstract;

    procedure Update(AModel: T); virtual; abstract;
    procedure UpdateBatch(AModels: TArray<T>); virtual; abstract;

    procedure Delete(AID: Int64); overload; virtual; abstract;
    procedure Delete(AModel: T); overload; virtual; abstract;
    procedure DeleteBatch(AModels: TArray<T>); overload; virtual; abstract;
    procedure DeleteBatch(AIDs: TArray<Int64>); overload; virtual; abstract;
    procedure DeleteBatch(AFilter: TFilterCriteria); overload; virtual; abstract;

    constructor Create(AConnection: TFDConnection);
    destructor Destroy; override;
  end;

implementation

uses
  EntitySchemaCache, Logger, AppContext;

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
var
  LFilterSql, LLocaleFilter, Limit1: string;
  Criterion: TFilterCriterion;
begin
  LFilterSql := '';
  Limit1 := '';
  LLocaleFilter := '';

  if AGetOnlyOneRecord then
    Limit1 := ' LIMIT 1 ';

  if AApplyLocaleFilter then
    LLocaleFilter := ' AND locale = :locale ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
    for Criterion in AFilter do
      LFilterSql := LFilterSql + ' AND ' + Criterion.FieldName + ' ' + Criterion.Operator + ' :' + Criterion.ParamName;
  LFilterSql := LFilterSql + LLocaleFilter;

  if ALock then
    Result :=
      'WITH filtered AS (' +
      '  SELECT v.id' +
      '  FROM ' + GetFullViewName(T) + ' v' +
      '  WHERE 1=1' + LFilterSql + Limit1 +  // view üzerinde filtrele
      '), ' +
      'lock_rows AS (' +
      '  SELECT id FROM ' + GetFullTableName(T) +  // table'ı kilitle
      '  WHERE id IN (SELECT id FROM filtered)' +
      '  FOR UPDATE' +
      ') ' +
      'SELECT v.* ' +
      'FROM ' + GetFullViewName(T) + ' v ' +
      'INNER JOIN lock_rows l ON l.id = v.id' + Limit1  // kilitli kayıtları oku
  else
    Result :=
      'SELECT v.* ' +
      'FROM ' + GetFullViewName(T) + ' v ' +
      'WHERE 1=1' + LFilterSql + Limit1;
end;

end.
