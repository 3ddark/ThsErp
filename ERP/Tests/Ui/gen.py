# Ths.dpr uses listesinden UiTest.dpr üretir; Forms/{modül}/Output listelerini test çağrısına çevirir.
import os, re, glob
here = os.path.dirname(os.path.abspath(__file__))
erp = os.path.abspath(os.path.join(here, '..', '..'))
dpr = open(os.path.join(erp, 'Ths.dpr'), encoding='utf-8-sig').read()
m = re.search(r'\nuses\n(.*?);\n', dpr, re.S)
uses = []
for line in m.group(1).split('\n'):
    line = line.strip().rstrip(',')
    if not line:
        continue
    line = re.sub(r"\s*\{[^}]*\}", '', line)
    mm = re.match(r"([\w.]+) in '([^']+)'", line)
    if mm:
        uses.append("%s in '%s'" % (mm.group(1), os.path.join(erp, mm.group(2))))
    else:
        uses.append(line)
calls = []
for mod in ['System', 'Employee', 'Account', 'Stock', 'Production', 'Finance', 'Purchasing', 'Sales']:
    for f in sorted(glob.glob(os.path.join(erp, 'Forms', mod, 'Output', '*.pas'))):
        s = open(f, encoding='utf-8-sig', errors='replace').read()
        c = re.search(r'(Tfrm\w+)\s*=\s*class\(TfrmGrid<\s*(T\w+)\s*,\s*(T\w+)\s*>', s)
        if not c:
            continue
        frm, ent, svc = c.groups()
        calls.append("  if TUi.Want('%s', '%s') then\n    TUiTester<%s, %s>.Run('%s', %s.Create(Application, %s.Create, %s.Create));"
                     % (mod, frm, ent, svc, mod, frm, svc, ent))
tpl = open(os.path.join(here, 'UiTest.tpl'), encoding='utf-8').read()
out = tpl.replace('{{USES}}', ',\n  '.join(uses + ['FireDAC.Comp.Client', 'System.Rtti', 'Vcl.Dialogs', 'System.Generics.Collections', 'System.Variants', 'Vcl.Controls', 'Vcl.StdCtrls', 'Vcl.ExtCtrls', 'Vcl.Graphics', 'Vcl.Imaging.pngimage', 'System.JSON', 'System.StrUtils', 'Vcl.ComCtrls', 'Vcl.ActnList', "UiDriver in '%s'" % os.path.join(here, 'UiDriver.pas')])).replace('{{CALLS}}', '\n'.join(calls))
out = out.replace('{{PORT}}', os.environ.get('THS_PG_PORT', '5432'))  # build.sh -> ../env.sh
open(os.path.join(here, 'UiTest.dpr'), 'w', encoding='utf-8-sig', newline='\r\n').write(out)
print(len(uses), 'units,', len(calls), 'list forms')
