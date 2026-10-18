#!/bin/sh
# Ths ERP servis katmanı entegrasyon testleri (System / Employee / Account / Stock / Finance / Purchasing).
# Her yazma işlemi transaction içinde yapılır ve ROLLBACK edilir; DB'de kalıcı değişiklik bırakmaz.
#   ./build.sh                 -> derle (dcc64, çıktı: $TEMP/ths_it)
#   $TEMP/ths_it/bin/IntegrationTest.exe [generic|perm|perm2|specific] [Modül] [TEntity]
# Rapor: exe yanında IntegrationTest-<mod>.txt (PASS/FAIL/WARN/INFO|modül|entity|adım|mesaj).
# Bağlantı: 127.0.0.1:$THS_PG_PORT ths_erp postgres/qwe (../env.sh bulur, gen.py şablona yazar).
cd "$(dirname "$0")"
. ../env.sh
python gen.py || exit 1
ERP="$(cd ../.. && pwd -W)"
O="${TEMP:-/tmp}/ths_it"
mkdir -p "$O/dcu" "$O/bin"
cp -r ../../lib "$O/bin/" 2>/dev/null
mkdir -p "$O/bin/Resource" && cp -r ../../Resource/Localization ../../Resource/EInvoice "$O/bin/Resource/"
E="$ERP/BackEnd"
U="$E/Core;$E/Core/Base;$E/Tools;$E/Tools/SynPDF;$ERP/Utils"
for m in System Employee Account Stock Finance Purchasing Sales EInvoice; do for s in Domain Exception Repository Service Cache Helper; do [ -d "$E/$m/$s" ] && U="$U;$E/$m/$s"; done; done
L="$BDS/lib/win64/release"
"$BDS/bin/dcc64.exe" -B -Q -W- -H- -DDEBUG \
  "-NSSystem;Winapi;Vcl;Vcl.Imaging;Data;Data.Win;System.Win;Xml;FireDAC" \
  "-U$U;$L" "-I$U;$ERP" "-R$L" "-N$O/dcu" "-E$O/bin" IntegrationTest.dpr 2>&1 | grep -iE "error|fatal|lines" | head -60
