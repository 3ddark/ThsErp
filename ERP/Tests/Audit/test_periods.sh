#!/bin/sh
# İşlem geçmişi (audit) dönem testi: iki dönem DB'si (…2026 / …2027) tek ortak audit DB'sine yazar.
# Canlı ths_erp'ye dokunmaz: geçici kopyalar + geçici audit DB oluşturur, sonunda siler.
#   ./test_periods.sh            -> PASS / FAIL satırları, sonda özet; çıkış kodu = başarısız sayısı
# Gerekli: ths_audit_writer rolü (ERP/audit_schema.sql'deki GRANT'lar), postgres/qwe.
cd "$(dirname "$0")"
. ../env.sh >/dev/null
ERP="$(cd ../.. && pwd)"
TMP="${TEMP:-/tmp}/ths_audit_test"
mkdir -p "$TMP"
AUD=ths_audit_ptest
D1=ths_audit_ptest_erp2026
D2=ths_audit_ptest_erp2027
FAMILY=ths_audit_ptest_erp
PASS=0; FAIL=0

q()  { "$PG/psql.exe" -h localhost -p "$THS_PG_PORT" -U postgres -X -q -At -v ON_ERROR_STOP=1 -d "$1" -c "$2" 2>&1; }
check() { # ad beklenen gerçek
  if [ "$2" = "$3" ]; then PASS=$((PASS+1)); echo "PASS|$1|$3"; else FAIL=$((FAIL+1)); echo "FAIL|$1|beklenen [$2] gerçek [$3]"; fi
}
cleanup() {
  for d in $D1 $D2 $AUD; do q postgres "DROP DATABASE IF EXISTS $d WITH (FORCE)" >/dev/null; done
}

cleanup
# 1) ortak audit DB (şema dosyasından) + iki dönem DB'si (canlı ths_erp kopyası)
q postgres "CREATE DATABASE $AUD TEMPLATE template0 ENCODING 'UTF8'" >/dev/null
q postgres "GRANT CONNECT ON DATABASE $AUD TO ths_audit_writer" >/dev/null
"$PG/psql.exe" -h localhost -p "$THS_PG_PORT" -U postgres -X -q -v ON_ERROR_STOP=1 -d $AUD -f "$ERP/audit_schema.sql" >/dev/null 2>&1 \
  || { echo "FAIL|audit şeması yüklenemedi"; cleanup; exit 1; }
q $AUD "TRUNCATE audit_database; DROP TABLE IF EXISTS audit_log_2026" >/dev/null
"$PG/pg_dump.exe" -h localhost -p "$THS_PG_PORT" -U postgres -Fc -f "$TMP/erp.dump" ths_erp || exit 1
for d in $D1 $D2; do
  q postgres "CREATE DATABASE $d TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'tr-TR' LC_CTYPE 'tr-TR'" >/dev/null
  "$PG/pg_restore.exe" -h localhost -p "$THS_PG_PORT" -U postgres -d $d --no-owner "$TMP/erp.dump" 2>/dev/null
  q $d "ALTER SERVER audit_server OPTIONS (SET dbname '$AUD')" >/dev/null
done
q $D1 "UPDATE sys_application_setting SET active_period = 2026; TRUNCATE audit_outbox" >/dev/null
q $D2 "UPDATE sys_application_setting SET active_period = 2027; TRUNCATE audit_outbox" >/dev/null

check "db family (dönem eki atılır)" "$FAMILY" "$(q $D1 "SELECT fn_db_family()")"
check "aktif dönem" "2027" "$(q $D2 "SELECT fn_active_period()")"
check "boş kuyruk: uzak bağlantı yok" "0|" "$(q $D1 "SELECT * FROM audit_flush()")"

# 2) 2026: kayıt ekle + güncelle (aynı id yıl sonunda 2027'ye taşınmış gibi her iki DB'de de var)
RID=$(q $D1 "WITH s AS (SELECT set_config('ths_erp.user_name','U2026',false)) INSERT INTO sys_region (region_name) SELECT 'AUDIT PERIOD TEST' FROM s RETURNING id")
q $D2 "INSERT INTO sys_region (id, region_name) OVERRIDING SYSTEM VALUE VALUES ($RID, 'AUDIT PERIOD TEST');
  SELECT setval(pg_get_serial_sequence('public.sys_region', 'id'), (SELECT max(id) FROM sys_region))" >/dev/null
q $D2 "TRUNCATE audit_outbox" >/dev/null
q $D1 "SELECT set_config('ths_erp.user_name','U2026',false); UPDATE sys_region SET region_name = 'AUDIT PERIOD TEST 2026' WHERE id = $RID" >/dev/null
check "2026 kuyruk" "2" "$(q $D1 "SELECT count(*) FROM audit_outbox")"
check "2026 aktarım" "2|" "$(q $D1 "SELECT * FROM audit_flush()")"
check "2026 bölümü oluştu" "audit_log_2026" "$(q $AUD "SELECT relname FROM pg_class WHERE relname = 'audit_log_2026'")"

# 3) 2027: güncelle + sil
q $D2 "SELECT set_config('ths_erp.user_name','U2027',false); UPDATE sys_region SET region_name = 'AUDIT PERIOD TEST 2027' WHERE id = $RID; DELETE FROM sys_region WHERE id = $RID" >/dev/null
check "2027 aktarım" "2|" "$(q $D2 "SELECT * FROM audit_flush()")"
check "dönem bölümleri" "audit_log_2026,audit_log_2027" "$(q $AUD "SELECT string_agg(c.relname, ',' ORDER BY c.relname) FROM pg_inherits i JOIN pg_class c ON c.oid = i.inhrelid WHERE i.inhparent = 'audit_log'::regclass")"
check "kaynak DB kaydı" "$D1|$FAMILY|2026|2,$D2|$FAMILY|2027|2" \
  "$(q $AUD "SELECT string_agg(db_name || '|' || db_family || '|' || period_year || '|' || flushed_rows, ',' ORDER BY db_name) FROM audit_database")"
check "kayıt geçmişi (iki dönem, yerel görünüm)" "2026:$D1:I:U2026,2026:$D1:U:U2026,2027:$D2:U:U2027,2027:$D2:D:U2027" \
  "$(q $D2 "SELECT string_agg(period_year || ':' || db_name || ':' || action || ':' || app_user, ',' ORDER BY changed_at, id) FROM vw_sys_audit_log WHERE db_family = '$FAMILY' AND table_name = 'sys_region' AND record_no = $RID")"
check "güncellemede yalnız değişen alan" "region_name" "$(q $AUD "SELECT string_agg(k, ',') FROM audit_log a, jsonb_object_keys(a.new_data) k WHERE a.action = 'U' AND a.period_year = 2027")"
check "bölüm budama (yıl filtresi uzağa iner)" "1" "$(q $D2 "EXPLAIN (VERBOSE) SELECT * FROM vw_sys_audit_log WHERE period_year = 2027 AND db_family = '$FAMILY'" | grep -c 'Remote SQL:.*period_year = 2027')"

# 4) audit DB'ye ulaşılamıyor: işlem sürer, kuyruk korunur; düzelince aktarılır
q $D2 "ALTER SERVER audit_server OPTIONS (SET dbname 'ths_audit_yok')" >/dev/null
q $D2 "SELECT set_config('ths_erp.user_name','U2027',false); INSERT INTO sys_region (region_name) VALUES ('AUDIT DOWN')" >/dev/null
check "audit DB kapalı: kayıt yine de yazıldı" "1" "$(q $D2 "SELECT count(*) FROM sys_region WHERE region_name = 'AUDIT DOWN'")"
check "audit DB kapalı: aktarım hatası" "-1" "$(q $D2 "SELECT moved FROM audit_flush()")"
check "audit DB kapalı: kuyruk korunur" "1" "$(q $D2 "SELECT count(*) FROM audit_outbox")"
q $D2 "ALTER SERVER audit_server OPTIONS (SET dbname '$AUD')" >/dev/null
check "audit DB açıldı: aktarım" "1|" "$(q $D2 "SELECT * FROM audit_flush()")"

# 5) eşzamanlı aktarım: 3 oturum aynı kuyruğu boşaltır (SKIP LOCKED), çift / kayıp yok
q $D2 "SELECT set_config('ths_erp.user_name','BULK',false); INSERT INTO sys_region (region_name) SELECT 'BULK ' || g FROM generate_series(1, 3000) g" >/dev/null
for i in 1 2 3; do q $D2 "SELECT moved FROM audit_flush(200, 50)" > "$TMP/flush$i.txt" & done
wait
MOVED=$(( $(cat "$TMP/flush1.txt") + $(cat "$TMP/flush2.txt") + $(cat "$TMP/flush3.txt") ))
check "eşzamanlı aktarım toplamı" "3000" "$MOVED"
check "eşzamanlı: kuyruk boş" "0" "$(q $D2 "SELECT count(*) FROM audit_outbox")"
check "eşzamanlı: uzakta tekil" "3000|3000" "$(q $AUD "SELECT count(*) || '|' || count(DISTINCT source_id) FROM audit_log WHERE db_name = '$D2' AND app_user = 'BULK'")"

# 6) tekrar aktarım (yerel commit uzaktan sonra düşerse): aynı kaynak satır atlanır
q $D2 "INSERT INTO audit_outbox (id, table_schema, table_name, row_id, action, changed_at, app_user, new_data) OVERRIDING SYSTEM VALUE
  SELECT source_id, table_schema, table_name, row_id, action, changed_at, app_user, new_data FROM audit_remote.audit_log
  WHERE db_name = '$D2' AND app_user = 'BULK' LIMIT 10" >/dev/null
check "tekrar aktarım atlanır" "0|10" "$(q $D2 "SELECT (SELECT moved FROM audit_flush()) || '|' || (SELECT count(*) FROM audit_remote.audit_log WHERE db_name = '$D2' AND app_user = 'BULK') - 2990")"

# 7) dönem değişimi: aktif dönem 2028 -> kayıt güncellenir, yeni bölüm açılır
q $D2 "UPDATE sys_application_setting SET active_period = 2028; SELECT set_config('ths_erp.user_name','U2028',false); UPDATE sys_region SET region_name = 'AUDIT 2028' WHERE region_name = 'AUDIT DOWN'" >/dev/null
check "yeni dönem aktarımı" "1|" "$(q $D2 "SELECT * FROM audit_flush()")"
check "yeni dönem bölümü + kayıt" "audit_log_2028|2028" "$(q $AUD "SELECT (SELECT relname FROM pg_class WHERE relname = 'audit_log_2028') || '|' || (SELECT period_year FROM audit_database WHERE db_name = '$D2')")"

# 8) yazıcı rol geçmişi değiştiremez / silemez
check "yazıcı rol: silme reddedilir" "ERROR" "$(PGPASSWORD=qwe "$PG/psql.exe" -h localhost -p "$THS_PG_PORT" -U ths_audit_writer -X -At -d $AUD -c "DELETE FROM audit_log" 2>&1 | grep -o 'ERROR\|HATA' | head -1 | sed 's/HATA/ERROR/')"
check "yazıcı rol: güncelleme reddedilir" "ERROR" "$(PGPASSWORD=qwe "$PG/psql.exe" -h localhost -p "$THS_PG_PORT" -U ths_audit_writer -X -At -d $AUD -c "UPDATE audit_log SET app_user = 'x'" 2>&1 | grep -o 'ERROR\|HATA' | head -1 | sed 's/HATA/ERROR/')"

cleanup
rm -f "$TMP"/flush*.txt "$TMP/erp.dump"
echo "SUM|pass=$PASS fail=$FAIL"
exit $FAIL
