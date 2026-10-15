unit SysAuditLog;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

const
  // audit_log.action
  AUDIT_ACTION_INSERT = 'I';
  AUDIT_ACTION_UPDATE = 'U';
  AUDIT_ACTION_DELETE = 'D';

type
  // Ortak işlem geçmişi (ths_audit.audit_log, postgres_fdw ile public.vw_sys_audit_log). Salt okunur:
  // satırları tetikleyici (public.audit -> audit_outbox) ve audit_flush() yazar.
  [Table('sys_audit_log')]
  TSysAuditLog = class(TEntity)
  private
    FPeriodYear: SmallInt;
    FDbName: string;
    FDbFamily: string;
    FSourceId: Int64;
    FTableSchema: string;
    FTableName: string;
    FRecordNo: Int64;
    FAction: string;
    FChangedAt: TDateTime;
    FTransactionId: Int64;
    FDbUser: string;
    FAppUser: string;
    FClientAddr: string;
    FApplicationName: string;
    FOldData: string;
    FNewData: string;
    FReceivedAt: TDateTime;
    FChangedColumns: string;
  public
    [Column('period_year')]
    property PeriodYear: SmallInt read FPeriodYear write FPeriodYear;

    [Column('db_name')]
    property DbName: string read FDbName write FDbName;

    [Column('db_family')]
    property DbFamily: string read FDbFamily write FDbFamily;

    [Column('source_id')]
    property SourceId: Int64 read FSourceId write FSourceId;

    [Column('table_schema')]
    property TableSchema: string read FTableSchema write FTableSchema;

    [Column('table_name')]
    property TableName: string read FTableName write FTableName;

    // değişen kaydın id'si (ths_audit'te row_id)
    [Column('record_no')]
    property RecordNo: Int64 read FRecordNo write FRecordNo;

    [Column('action')]
    property Action: string read FAction write FAction;

    [Column('changed_at')]
    property ChangedAt: TDateTime read FChangedAt write FChangedAt;

    [Column('transaction_id')]
    property TransactionId: Int64 read FTransactionId write FTransactionId;

    [Column('db_user')]
    property DbUser: string read FDbUser write FDbUser;

    [Column('app_user')]
    property AppUser: string read FAppUser write FAppUser;

    [Column('client_addr')]
    property ClientAddr: string read FClientAddr write FClientAddr;

    [Column('application_name')]
    property ApplicationName: string read FApplicationName write FApplicationName;

    // JSON: I = yeni satırın tamamı, D = silinen satırın tamamı, U = yalnız değişen kolonlar
    [Column('old_data')]
    property OldData: string read FOldData write FOldData;

    [Column('new_data')]
    property NewData: string read FNewData write FNewData;

    [Column('received_at')]
    property ReceivedAt: TDateTime read FReceivedAt write FReceivedAt;

    [NotMapped]
    property ChangedColumns: string read FChangedColumns write FChangedColumns;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSysAuditLog;

    // İşlem kodunun etkin dildeki adı (I / U / D)
    class function ActionText(const AAction: string): string; static;
  end;

  // audit_flush() sonucu: Moved = taşınan satır, -1 = hata (ErrorMessage); kuyruk bozulmaz
  TAuditFlushResult = record
    Moved: Integer;
    ErrorMessage: string;
  end;

implementation

constructor TSysAuditLog.Create;
begin
  inherited;
end;

destructor TSysAuditLog.Destroy;
begin
  inherited;
end;

function TSysAuditLog.Clone: TSysAuditLog;
begin
  Result := TSysAuditLog.Create;
  Result.Id := Self.Id;
  Result.PeriodYear := Self.PeriodYear;
  Result.DbName := Self.DbName;
  Result.DbFamily := Self.DbFamily;
  Result.SourceId := Self.SourceId;
  Result.TableSchema := Self.TableSchema;
  Result.TableName := Self.TableName;
  Result.RecordNo := Self.RecordNo;
  Result.Action := Self.Action;
  Result.ChangedAt := Self.ChangedAt;
  Result.TransactionId := Self.TransactionId;
  Result.DbUser := Self.DbUser;
  Result.AppUser := Self.AppUser;
  Result.ClientAddr := Self.ClientAddr;
  Result.ApplicationName := Self.ApplicationName;
  Result.OldData := Self.OldData;
  Result.NewData := Self.NewData;
  Result.ReceivedAt := Self.ReceivedAt;
  Result.ChangedColumns := Self.ChangedColumns;
end;

class function TSysAuditLog.ActionText(const AAction: string): string;
begin
  if AAction = AUDIT_ACTION_INSERT then
    Result := TLocalizationManager.Translate(TLangKeys.TSysAuditLog.ActionInsert, 'Insert')
  else if AAction = AUDIT_ACTION_UPDATE then
    Result := TLocalizationManager.Translate(TLangKeys.TSysAuditLog.ActionUpdate, 'Update')
  else if AAction = AUDIT_ACTION_DELETE then
    Result := TLocalizationManager.Translate(TLangKeys.TSysAuditLog.ActionDelete, 'Delete')
  else
    Result := AAction;
end;

end.
