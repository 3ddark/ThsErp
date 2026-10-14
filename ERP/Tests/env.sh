# Ortak test ortamı (iki makine): Delphi sürümü (Studio 37.0 yoksa 23.0) + güncel ths_erp portu.
# Port: THS_PG_PORT verilmemişse 5432 / 5433 içinde PostgreSQL 18 + güncel şemayı (fin_money_transaction) taşıyan ths_erp seçilir
# (bir makinede 5432 eski bir PostgreSQL 14 kopyasıdır).
for v in 37.0 23.0; do
  if [ -x "C:/Program Files (x86)/Embarcadero/Studio/$v/bin/dcc64.exe" ]; then BDS="C:/Program Files (x86)/Embarcadero/Studio/$v"; break; fi
done
PG="/c/Program Files/PostgreSQL/18/bin"
export PGPASSWORD=qwe
if [ -z "$THS_PG_PORT" ]; then
  for p in 5432 5433; do
    if [ "$("$PG/psql.exe" -h localhost -p $p -U postgres -d ths_erp -Atc "SELECT current_setting('server_version_num')::int >= 180000 AND to_regclass('public.fin_money_transaction') IS NOT NULL" 2>/dev/null)" = "t" ]; then THS_PG_PORT=$p; break; fi
  done
fi
[ -n "$THS_PG_PORT" ] || { echo "ths_erp (güncel şema) bulunamadı: 5432 / 5433"; exit 1; }
[ -n "$BDS" ] || { echo "Delphi (dcc64) bulunamadı"; exit 1; }
export BDS THS_PG_PORT PG
echo "Delphi: $BDS  /  ths_erp port: $THS_PG_PORT"
