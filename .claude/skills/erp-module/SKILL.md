---
name: erp-module
description: Ths ERP module workflow — create, fix, analyze or regenerate a full CRUD module (Domain, Repository, Service, Exception, Output/Input forms, DFM, view, permission, localization) for a PostgreSQL table, and the /goal migration commands (migrate table/module/all, fix broken modules, stabilize desktop ERP). Use when the user says "create module {table}", "fix module {table}", "analyze module {table}", "regenerate … {table}" or "/goal …".
---

# ERP Module Workflow

Follow `.claude/CLAUDE.md` and the rules in `.claude/rules/` (backend, forms, database, permissions, localization).
Track progress in `docs/claude_resume.md`.

## Commands

```text
create module {table}            analyze module {table}         fix module {table}
regenerate domain {table}        regenerate repository {table}  regenerate service {table}
regenerate forms {table}         regenerate all forms module {prefix}

/goal migrate table {table}      /goal migrate module {prefix}  /goal migrate all modules
/goal fix all broken modules     /goal stabilize desktop erp    /goal migrate to web
```

`regenerate …` replaces only the named layer and only after reading the existing file (keep custom logic).

## 1. Analyze (always first)

1. Schema from the live DB (`psql`): columns, types, nullability, defaults, FKs (both directions), unique constraints,
   triggers, `vw_{table}` definition and whether it has `locale`, `*_translation` table.
2. Code: existing units in `BackEnd/{Module}/…` and `Forms/{Module}/…`, registration in `Ths.dpr` / `Ths.dproj`,
   dashboard entry, permission constant + `sys_permission` row, `TLangKeys` record, JSON keys.
3. Diff DB columns vs `[Column]` attributes; list missing / broken / legacy parts.

Module discovery: `SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';` → prefixes.
Dependency order is FK-driven: parents before children (e.g. `sys_country → sys_region → sys_city`).

## 2. Generation order (create module)

1. DB: view `vw_{table}` (locale strategy), permission row + translations, grid metadata cleanup — applied with psql; refresh `db_schema.sql` + `db.dump`.
2. Domain
3. Exception (if the service raises entity errors)
4. Repository
5. Service (+ `PERMISSION_*` constant)
6. `TLangKeys` record + all JSON files
7. Output form (+ stub DFM)
8. Input form (+ DFM, height rule, FK helpers)
9. Register units in `Ths.dpr` and `Ths.dproj`; dashboard action/menu when the entity is a top-level screen
10. Compile (0 errors), run SQL smoke test in `BEGIN … ROLLBACK`, update resume state

Use the reference implementations listed at the top of each rules file as templates; keep file encoding rules.

## 3. Migration pipeline (/goal)

Discover modules → discover tables → analyze schema → scan code → detect missing files → detect broken modules
(abstract methods / W1020 warnings, `PERMISSION_TEMPLATE`, legacy `Ths.Database.Table.*` units, stale grid metadata)
→ generate/patch → validate (compile + SQL) → finalize (resume state, `db_schema.sql` + `db.dump`).

Context continuation: when the queue is long (>20 tasks or >50 files), write the state to `docs/claude_resume.md`
after each module so work can resume in a new session.

## 4. Web roadmap (/goal migrate to web)

Phase 1 stabilize Delphi ERP → Phase 2 Go backend → Phase 3 React + Vite frontend → Phase 4 module migration →
Phase 5 SaaS. The PostgreSQL schema, views and permission model are the shared contract; keep business rules in
services so they can be ported.
