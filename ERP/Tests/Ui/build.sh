#!/bin/sh
# Ekran (UI) event-akışı testleri: System / Employee / Account / Stock / Production / Finance / Purchasing listeleri + giriş formları.
#   ./build.sh            -> ths_erp_it'i canlı ths_erp'ten yeniden kurar (+seed.sql) ve UiTest'i derler
#   $TEMP/ths_ui/bin/UiTest.exe [Modül] [TfrmXxx]   -> rapor: UiTest-report.txt
# Testler ths_erp_it üzerinde commit eder; canlı ths_erp'e yazmaz.
cd "$(dirname "$0")"
ERP="$(cd ../.. && pwd -W)"
O="${TEMP:-/tmp}/ths_ui"
PG="/c/Program Files/PostgreSQL/18/bin"
export PGPASSWORD=qwe
if [ "$1" != "--no-db" ]; then
  "$PG/pg_dump.exe" -h localhost -p 5432 -U postgres -Fc -f "$O.dump" ths_erp || exit 1
  "$PG/dropdb.exe" -h localhost -p 5432 -U postgres --if-exists ths_erp_it
  "$PG/createdb.exe" -h localhost -p 5432 -U postgres -T template0 ths_erp_it || exit 1
  "$PG/pg_restore.exe" -h localhost -p 5432 -U postgres -d ths_erp_it --no-owner "$O.dump" 2>/dev/null
  "$PG/psql.exe" -h localhost -p 5432 -U postgres -d ths_erp_it -q -v ON_ERROR_STOP=1 -f seed.sql || exit 1
  echo "ths_erp_it ready"
fi
python gen.py || exit 1
mkdir -p "$O/dcu" "$O/bin"
cp -r ../../lib "$O/bin/" 2>/dev/null
mkdir -p "$O/bin/Resource" && cp -r ../../Resource/Localization "$O/bin/Resource/"
BDS="C:/Program Files (x86)/Embarcadero/Studio/37.0"
L="$BDS/lib/win64/release"
U="$ERP;$ERP/Utils;$L"
"$BDS/bin/dcc64.exe" -B -Q -W- -H- -DDEBUG \
  "-NSSystem;Winapi;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell;Xml;Data;Datasnap;Web;Soap;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;FireDAC" \
  "-U$U" "-I$ERP" "-R$ERP;$L" "-N$O/dcu" "-E$O/bin" UiTest.dpr 2>&1 | grep -iE "error|fatal|lines" | head -60
