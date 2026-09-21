unit SysViewTable.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, Service,
  FilterCriterion, UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysViewTable;

type
  ISysViewTableRepository = interface(IRepository<TSysViewTable>)
    ['{8A9C1D2E-3F4B-5A6C-7D8E-9F0A1B2C3D4E}']
  end;

  TSysViewTableRepository = class(TRepository<TSysViewTable>, ISysViewTableRepository)
  protected
    function MapFromQuery(Q: TFDQuery): TSysViewTable; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSysViewTable>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSysViewTable; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysViewTable; override;

    procedure DoAdd(AModel: TSysViewTable); override;
    procedure DoAddBatch(AModels: TArray<TSysViewTable>); override;

    procedure DoUpdate(AModel: TSysViewTable); override;
    procedure DoUpdateBatch(AModels: TArray<TSysViewTable>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSysViewTable); override;
    procedure DoDeleteBatch(AModels: TArray<TSysViewTable>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSysViewTableRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysViewTableRepository.MapFromQuery(Q: TFDQuery): TSysViewTable;
begin
  Result := TSysViewTable.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.TableName := Q.FieldByName('table_name').AsString;
  Result.TableType := Q.FieldByName('table_type').AsString;
end;

function TSysViewTableRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := 'id, table_name::varchar(128) AS table_name, table_type::varchar(64) AS table_type';
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM public.' + Self.GetTableName(TSysViewTable) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSysViewTableRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSysViewTable>;
var
  Q: TFDQuery;
  Item: TSysViewTable;
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  Result := TObjectList<TSysViewTable>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    SelectCols := 'id, table_name::varchar(128) AS table_name, table_type::varchar(64) AS table_type';
    Q.SQL.Text := 'SELECT ' + SelectCols + ' FROM public.' + Self.GetTableName(TSysViewTable) + ' WHERE 1=1 ';

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for Criteria in AFilter do
        Q.SQL.Text := Q.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    end;

    LogQuery(Q, 'DoFind');
    Q.Open;
    while not Q.Eof do
    begin
      Item := MapFromQuery(Q);
      Result.Add(Item);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TSysViewTableRepository.DoFindById(AId: TValue; ALock: Boolean): TSysViewTable;
var
  Q: TFDQuery;
  SelectCols: string;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    SelectCols := 'id, table_name::varchar(128) AS table_name, table_type::varchar(64) AS table_type';
    Q.SQL.Text := 'SELECT ' + SelectCols + ' FROM public.' + Self.GetTableName(TSysViewTable) + ' WHERE id = :id LIMIT 1';
    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    LogQuery(Q, 'DoFindById');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

function TSysViewTableRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysViewTable;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  Result := nil;
  if not Assigned(AFilter) or (AFilter.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    SelectCols := 'id, table_name::varchar(128) AS table_name, table_type::varchar(64) AS table_type';
    Q.SQL.Text := 'SELECT ' + SelectCols + ' FROM public.' + Self.GetTableName(TSysViewTable) + ' WHERE 1=1 ';

    for Criteria in AFilter do
      Q.SQL.Text := Q.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;

    Q.SQL.Text := Q.SQL.Text + ' LIMIT 1';
    LogQuery(Q, 'DoFindOne');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TSysViewTableRepository.DoAdd(AModel: TSysViewTable);
begin
  raise ENotSupportedException.Create('sys_view_tables is a read-only view');
end;

procedure TSysViewTableRepository.DoAddBatch(AModels: TArray<TSysViewTable>);
begin
  raise ENotSupportedException.Create('sys_view_tables is a read-only view');
end;

procedure TSysViewTableRepository.DoUpdate(AModel: TSysViewTable);
begin
  raise ENotSupportedException.Create('sys_view_tables is a read-only view');
end;

procedure TSysViewTableRepository.DoUpdateBatch(AModels: TArray<TSysViewTable>);
begin
  raise ENotSupportedException.Create('sys_view_tables is a read-only view');
end;

procedure TSysViewTableRepository.DoDelete(AID: TValue);
begin
  raise ENotSupportedException.Create('sys_view_tables is a read-only view');
end;

procedure TSysViewTableRepository.DoDelete(AModel: TSysViewTable);
begin
  raise ENotSupportedException.Create('sys_view_tables is a read-only view');
end;

procedure TSysViewTableRepository.DoDeleteBatch(AModels: TArray<TSysViewTable>);
begin
  raise ENotSupportedException.Create('sys_view_tables is a read-only view');
end;

procedure TSysViewTableRepository.DoDeleteBatch(AIDs: TArray<TValue>);
begin
  raise ENotSupportedException.Create('sys_view_tables is a read-only view');
end;

procedure TSysViewTableRepository.DoDeleteBatch(AFilter: TFilterCriteria);
begin
  raise ENotSupportedException.Create('sys_view_tables is a read-only view');
end;

end.
