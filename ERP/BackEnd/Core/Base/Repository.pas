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

    procedure Delete(AID: TValue); overload;
    procedure Delete(AModel: T); overload;
    procedure DeleteBatch(AModels: TArray<T>); overload;
    procedure DeleteBatch(AIDs: TArray<TValue>); overload;
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


    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; virtual; abstract;

    function DoFindById(AId: TValue; ALock: Boolean = False): T; virtual; abstract;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): T; virtual; abstract;
    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TList<T>; virtual; abstract;

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
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): T; virtual;
    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TList<T>; virtual;

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
      'INNER JOIN lock_rows l ON l.id = v.id ' +
      'WHERE 1=1 ' + LLocaleFilter +
      Limit1  // kilitli kayıtları oku
  else
    Result :=
      'SELECT v.* ' +
      'FROM ' + GetFullViewName(T) + ' v ' +
      'WHERE 1=1' + LFilterSql + Limit1;
end;

function TRepository<T>.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
begin
  GLogger.InfoFmt('FindAllGridQuery %s', [Self.ClassName]);
  Result := DoFindAllGridQuery(AFilter);
  GLogger.InfoFmt('FindAllGridQuery Done %s', [Self.ClassName]);
end;

function TRepository<T>.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<T>;
begin
  GLogger.InfoFmt('Find %s', [Self.ClassName]);
  Result := DoFind(AFilter, ALock);
  GLogger.InfoFmt('Find Done %s', [Self.ClassName]);
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
  GLogger.InfoFmt('DeleteBatch Filter ', [Self.ClassName]);
  DoDeleteBatch(AFilter);
  GLogger.InfoFmt('DeleteBatch Filter Done ', [Self.ClassName]);
end;

end.
