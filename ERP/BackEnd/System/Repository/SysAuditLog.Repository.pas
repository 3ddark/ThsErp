unit SysAuditLog.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, SysAuditLog, SysAuditLog.Exception;

type
  // vw_sys_audit_log (postgres_fdw -> ths_audit.audit_log) yalnız okunur; yazma metotları reddeder.
  TSysAuditLogRepository = class(TRepository<TSysAuditLog>)
  protected
    function MapFromQuery(Q: TFDQuery): TSysAuditLog; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSysAuditLog>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSysAuditLog; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysAuditLog; override;

    procedure DoAdd(AModel: TSysAuditLog); override;
    procedure DoAddBatch(AModels: TArray<TSysAuditLog>); override;

    procedure DoUpdate(AModel: TSysAuditLog); override;
    procedure DoUpdateBatch(AModels: TArray<TSysAuditLog>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSysAuditLog); override;
    procedure DoDeleteBatch(AModels: TArray<TSysAuditLog>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);

    // Yerel kuyruğu (audit_outbox) ths_audit'e taşır: public.audit_flush()
    function Flush(ABatchSize, AMaxBatches: Integer): TAuditFlushResult;
    // Kuyrukta bekleyen satır sayısı
    function PendingCount: Int64;
    // public.audit() tetikleyicisi bağlı tablolar
    function GetAuditedTables: TArray<string>;
    // Firma (DB ailesi, dönem eki atılmış veritabanı adı) ve aktif dönem yılı
    function GetDbFamily: string;
    function GetActivePeriod: SmallInt;
  end;

implementation

constructor TSysAuditLogRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysAuditLogRepository.MapFromQuery(Q: TFDQuery): TSysAuditLog;

  function DateOf(const AName: string): TDateTime;
  begin
    if Q.FieldByName(AName).IsNull then
      Result := 0
    else
      Result := Q.FieldByName(AName).AsDateTime;
  end;

begin
  Result := TSysAuditLog.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.PeriodYear := Q.FieldByName('period_year').AsInteger;
  Result.DbName := Q.FieldByName('db_name').AsWideString;
  Result.DbFamily := Q.FieldByName('db_family').AsWideString;
  Result.SourceId := Q.FieldByName('source_id').AsLargeInt;
  Result.TableSchema := Q.FieldByName('table_schema').AsWideString;
  Result.TableName := Q.FieldByName('table_name').AsWideString;
  Result.RecordNo := Q.FieldByName('record_no').AsLargeInt;
  Result.Action := Q.FieldByName('action').AsWideString;
  Result.ChangedAt := DateOf('changed_at');
  Result.TransactionId := Q.FieldByName('transaction_id').AsLargeInt;
  Result.DbUser := Q.FieldByName('db_user').AsWideString;
  Result.AppUser := Q.FieldByName('app_user').AsWideString;
  Result.ClientAddr := Q.FieldByName('client_addr').AsWideString;
  Result.ApplicationName := Q.FieldByName('application_name').AsWideString;
  Result.OldData := Q.FieldByName('old_data').AsWideString;
  Result.NewData := Q.FieldByName('new_data').AsWideString;
  Result.ReceivedAt := DateOf('received_at');
  Result.ChangedColumns := Q.FieldByName('changed_columns').AsWideString;
end;

function TSysAuditLogRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TSysAuditLog) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSysAuditLogRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSysAuditLog>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysAuditLog>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    // yabancı tablo: satır kilidi yok
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, False, False, False) + ' ORDER BY v.id';

    if Assigned(AFilter) and (AFilter.Count > 0) then
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;

    LogQuery(Q, 'DoFind');
    Q.Open;
    while not Q.Eof do
    begin
      Result.Add(MapFromQuery(Q));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TSysAuditLogRepository.DoFindById(AId: TValue; ALock: Boolean): TSysAuditLog;
var
  Q: TFDQuery;
  Criteria: TFilterCriteria;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  Criteria := TFilterCriteria.Create;
  try
    Q.Connection := Connection;

    Criteria.Add(TFilterCriterion.New('id', '=', AId));
    Q.SQL.Text := Self.PrepareSelectFromView(Criteria, False, True, False);

    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    LogQuery(Q, 'DoFindById');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TSysAuditLogRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysAuditLog;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := nil;
  if not Assigned(AFilter) or (AFilter.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, False, True, False);

    for Criteria in AFilter do
      Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    LogQuery(Q, 'DoFindOne');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TSysAuditLogRepository.DoAdd(AModel: TSysAuditLog);
begin
  raise ESysAuditLogExceptionReadOnly.Create;
end;

procedure TSysAuditLogRepository.DoAddBatch(AModels: TArray<TSysAuditLog>);
begin
  raise ESysAuditLogExceptionReadOnly.Create;
end;

procedure TSysAuditLogRepository.DoUpdate(AModel: TSysAuditLog);
begin
  raise ESysAuditLogExceptionReadOnly.Create;
end;

procedure TSysAuditLogRepository.DoUpdateBatch(AModels: TArray<TSysAuditLog>);
begin
  raise ESysAuditLogExceptionReadOnly.Create;
end;

procedure TSysAuditLogRepository.DoDelete(AID: TValue);
begin
  raise ESysAuditLogExceptionReadOnly.Create;
end;

procedure TSysAuditLogRepository.DoDelete(AModel: TSysAuditLog);
begin
  raise ESysAuditLogExceptionReadOnly.Create;
end;

procedure TSysAuditLogRepository.DoDeleteBatch(AModels: TArray<TSysAuditLog>);
begin
  raise ESysAuditLogExceptionReadOnly.Create;
end;

procedure TSysAuditLogRepository.DoDeleteBatch(AIDs: TArray<TValue>);
begin
  raise ESysAuditLogExceptionReadOnly.Create;
end;

procedure TSysAuditLogRepository.DoDeleteBatch(AFilter: TFilterCriteria);
begin
  raise ESysAuditLogExceptionReadOnly.Create;
end;

function TSysAuditLogRepository.Flush(ABatchSize, AMaxBatches: Integer): TAuditFlushResult;
var
  Q: TFDQuery;
begin
  Result.Moved := 0;
  Result.ErrorMessage := '';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT moved, error_message FROM public.audit_flush(:batch_size, :max_batches)';
    Q.ParamByName('batch_size').AsInteger := ABatchSize;
    Q.ParamByName('max_batches').AsInteger := AMaxBatches;
    LogQuery(Q, 'Flush');
    Q.Open;
    Result.Moved := Q.Fields[0].AsInteger;
    Result.ErrorMessage := Q.Fields[1].AsWideString;
  finally
    Q.Free;
  end;
end;

function TSysAuditLogRepository.PendingCount: Int64;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) FROM public.audit_outbox';
    LogQuery(Q, 'PendingCount');
    Q.Open;
    Result := Q.Fields[0].AsLargeInt;
  finally
    Q.Free;
  end;
end;

function TSysAuditLogRepository.GetAuditedTables: TArray<string>;
var
  Q: TFDQuery;
  LList: TList<string>;
begin
  LList := TList<string>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT DISTINCT c.relname::text FROM pg_trigger t ' +
                  'JOIN pg_class c ON c.oid = t.tgrelid ' +
                  'JOIN pg_namespace n ON n.oid = c.relnamespace ' +
                  'WHERE t.tgfoid = ''public.audit()''::regprocedure AND NOT t.tgisinternal AND n.nspname = ''public'' ' +
                  'ORDER BY 1';
    LogQuery(Q, 'GetAuditedTables');
    Q.Open;
    while not Q.Eof do
    begin
      LList.Add(Q.Fields[0].AsWideString);
      Q.Next;
    end;
    Result := LList.ToArray;
  finally
    Q.Free;
    LList.Free;
  end;
end;

function TSysAuditLogRepository.GetDbFamily: string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT public.fn_db_family()::text';
    LogQuery(Q, 'GetDbFamily');
    Q.Open;
    Result := Q.Fields[0].AsWideString;
  finally
    Q.Free;
  end;
end;

function TSysAuditLogRepository.GetActivePeriod: SmallInt;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT public.fn_active_period()';
    LogQuery(Q, 'GetActivePeriod');
    Q.Open;
    Result := Q.Fields[0].AsInteger;
  finally
    Q.Free;
  end;
end;

end.
