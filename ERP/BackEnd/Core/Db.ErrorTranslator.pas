unit Db.ErrorTranslator;

interface

uses
  System.SysUtils, Data.DB, FireDAC.Stan.Error, FireDAC.Stan.Param, FireDAC.Phys.PGWrapper, FireDAC.Comp.Client;

type
  // PostgreSQL constraint hatalarını (23001 / 23503 / 23505 / 23502 / 23514) kullanıcı mesajına çevirir
  TDbErrorTranslator = class
  private
    class function TableTitle(const ATableName: string): string; static;
    class function FkRefTable(const AConstraintName, AChildTable: string): string; static;
  public
    // Bilinen DB hatası değilse '' döner
    class function Translate(E: Exception): string; static;
    // Bilinen DB hatasıysa çeviri, değilse E.Message
    class function FriendlyMessage(E: Exception): string; static;
  end;

implementation

uses
  LocalizationManager, AppContext;

const
  PG_RESTRICT_VIOLATION = '23001';
  PG_FK_VIOLATION = '23503';
  PG_UNIQUE_VIOLATION = '23505';
  PG_NOT_NULL_VIOLATION = '23502';
  PG_CHECK_VIOLATION = '23514';

class function TDbErrorTranslator.TableTitle(const ATableName: string): string;
begin
  // Liste başlığı anahtarı tablo adından türetilir ({table}.title_plural); yoksa tablo adı
  Result := TLocalizationManager.Translate(ATableName + '.title_plural', ATableName);
end;

class function TDbErrorTranslator.FkRefTable(const AConstraintName, AChildTable: string): string;
var
  LConn: TFDConnection;
  Q: TFDQuery;
begin
  // FK'nin gösterdiği (ana) tablo; bulunamazsa ''
  Result := '';
  if (AConstraintName = '') or not TAppContext.IsInitialized then
    Exit;
  LConn := TAppContext.Instance.DBConnection;
  if (LConn = nil) or not LConn.Connected then
    Exit;
  Q := TFDQuery.Create(nil);
  try
    try
      Q.Connection := LConn;
      Q.SQL.Text :=
        'SELECT c.confrelid::regclass::text AS ref_table FROM pg_constraint c ' +
        'WHERE c.contype = ''f'' AND c.conname = :c AND c.conrelid::regclass::text = :t LIMIT 1';
      Q.ParamByName('c').AsWideString := AConstraintName;
      Q.ParamByName('t').AsWideString := AChildTable;
      Q.Open;
      if not Q.IsEmpty then
        Result := Q.FieldByName('ref_table').AsString;
    except
      // bağlantı iptal edilmiş bir transaction'da olabilir: genel mesaja düşülür
      Result := '';
    end;
  finally
    Q.Free;
  end;
end;

class function TDbErrorTranslator.Translate(E: Exception): string;
var
  LErr: TFDPgError;
  LDetailTable, LDetail, LRefTable: string;
begin
  Result := '';
  if not (E is EPgNativeException) or (EPgNativeException(E).ErrorCount = 0) then
    Exit;
  LErr := EPgNativeException(E).Errors[0];
  LDetailTable := LErr.TableName;

  // PG her iki FK hatasında bağlı (FK sahibi) tabloyu bildirir
  if LErr.ErrorCode = PG_RESTRICT_VIOLATION then
    // ON DELETE / UPDATE RESTRICT: ana kayıt başka tabloda kullanılıyor
    Result := TLocalizationManager.Translate(TLangKeys.TDbError.FkInUse,
      'This record is used by other records, so it cannot be deleted or changed.')
  else if LErr.ErrorCode = PG_FK_VIOLATION then
  begin
    // NO ACTION silme / güncelleme mesajı ana tabloyu da adlandırır ("update or delete on table "x" ..."),
    // bağlı kayıt ekleme / güncelleme mesajı yalnız bağlı tabloyu (dilden bağımsız: adlar tırnak içinde);
    // ana tablo bulunamazsa en sık durum olan "kullanımda" varsayılır
    LRefTable := FkRefTable(LErr.ConstraintName, LErr.TableName);
    if (LRefTable <> '') and not SameText(LRefTable, LErr.TableName)
      and not LErr.Message.Contains('"' + LRefTable + '"') then
    begin
      Result := TLocalizationManager.Translate(TLangKeys.TDbError.FkMissing,
        'The linked record could not be found. Another user may have deleted it.');
      LDetailTable := LRefTable;
    end
    else
      Result := TLocalizationManager.Translate(TLangKeys.TDbError.FkInUse,
        'This record is used by other records, so it cannot be deleted or changed.');
  end
  else if LErr.ErrorCode = PG_UNIQUE_VIOLATION then
    Result := TLocalizationManager.Translate(TLangKeys.TDbError.Unique,
      'This value already exists and cannot be added again.')
  else if LErr.ErrorCode = PG_NOT_NULL_VIOLATION then
    Result := TLocalizationManager.Translate(TLangKeys.TDbError.NotNull,
      'A required field is empty.')
  else if LErr.ErrorCode = PG_CHECK_VIOLATION then
    Result := TLocalizationManager.Translate(TLangKeys.TDbError.Check,
      'The entered values do not satisfy a data rule.')
  else
    Exit;

  LDetail := TableTitle(LDetailTable);
  if LErr.ColumnName <> '' then
    LDetail := LDetail + ' / ' + LErr.ColumnName;
  if LErr.ConstraintName <> '' then
    LDetail := LDetail + ' (' + LErr.ConstraintName + ')';
  Result := Result + sLineBreak + sLineBreak +
    TLocalizationManager.Translate(TLangKeys.TDbError.TechnicalDetail, 'Detail') + ': ' + LDetail;
end;

class function TDbErrorTranslator.FriendlyMessage(E: Exception): string;
begin
  Result := Translate(E);
  if Result = '' then
    Result := E.Message;
end;

end.
