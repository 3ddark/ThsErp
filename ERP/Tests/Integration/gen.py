import os, sys
here = os.path.dirname(os.path.abspath(__file__))
rows = [l.strip().split('|') for l in open(os.path.join(here, 'services.txt'), encoding='utf-8') if l.strip()]

units = []
for m, u, s, e, d in rows:
    for x in (d, u):
        if x not in units and x not in ('SysUser', 'SysUser.Repository'):
            units.append(x)

calls = []
for m, u, s, e, d in rows:
    calls.append(f"  if Want('{m}', '{e}') then TTester<{e}>.Run('{m}', '{e}', {s}.Create);")

perm = [f"  if Want('{m}', '{e}') then TTester<{e}>.Perm('{m}', '{e}', {s}.Create, GPermMap);" for m,u,s,e,d in rows]
tpl = open(os.path.join(here, 'IntegrationTest.tpl'), encoding='utf-8').read()
out = tpl.replace('{{UNITS}}', ',\n  '.join(units)).replace('{{CALLS}}', '\n'.join(calls)).replace('{{PERMCALLS}}', '\n'.join(perm))
open(os.path.join(here, 'IntegrationTest.dpr'), 'w', encoding='utf-8-sig', newline='\r\n').write(out)
print(len(rows), 'services')
