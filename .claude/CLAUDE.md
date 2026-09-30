# CLAUDE.md — Ths ERP (core, always loaded)

Detailed rules are split and load automatically when matching files are touched:

| File                                 | Loaded when working on                                                   |
| ------------------------------------ | ------------------------------------------------------------------------ |
| `.claude/rules/backend.md`           | `ERP/BackEnd/**` (Domain / Repository / Service / Exception)             |
| `.claude/rules/forms.md`             | `ERP/Forms/**` (.pas + .dfm)                                             |
| `.claude/rules/database.md`          | SQL, schema changes, views, `db_schema.sql` / `db.dump`, repositories    |
| `.claude/rules/permissions.md`       | services, permission tables                                              |
| `.claude/rules/localization.md`      | `LocalizationManager.pas`, `Resource/Localization/*.json`, forms         |
| `.claude/skills/erp-module/SKILL.md` | on demand: "create / fix / analyze module {table}", `/goal ...` commands |

---

## 1. Instruction Priority

1. Safety rules
2. This file + `.claude/rules/*`
3. Resume state (`docs/claude_resume.md`)
4. User commands

Higher priority overrides lower priority.

---

## 2. Project

- **Name:** Ths ERP — ERP + CRM + Accounting desktop application
- **Stack:** Delphi 12 Athens (RAD Studio 23.0), VCL, FireDAC, PostgreSQL 18
- **Philosophy:** Database-first
- **Roadmap:** Stabilize desktop ERP → Go/.NET Core backend → React + Vite frontend → module migration → SaaS

### Source of truth (conflict order)

1. Live PostgreSQL (query with `psql`; there is **no** MCP server configured for this project)
2. `ERP/db_schema.sql`
3. Delphi source code
4. User SQL scripts

---

## 3. Project Structure (actual)

```text
ERP/
├── Ths.dpr / Ths.dproj          # every unit must be registered in BOTH
├── BackEnd/
│   ├── Core/                    # AppContext, UserContext, Auth.Service, Logger, Ths.Globals ...
│   │   └── Base/                # Entity, EntityAttributes, Repository, Service, UnitOfWork, LocalizationManager ...
│   ├── {Module}/                # System, Employee, Account, Stock, Production, Order, Invoice ...
│   │   ├── Domain/  Repository/  Service/  Exception/
│   │   └── (System only) Cache/  Helper/
│   └── Tools/                   # Ths.Helper.* (TEdit/TMemo/TComboBox interposers), export, SynPDF
├── Forms/
│   ├── Core/Base/               # ufrmBase, ufrmGrid (TfrmGrid<>), ufrmInputSimpleDB (TfrmInputSimpleDB<>)
│   ├── Core/Input/              # ufrmLogin, ufrmDashboard, ufrmAbout ...
│   └── {Module}/Input/ + {Module}/Output/
├── Resource/Localization/       # tr-TR, en-US, de-DE, fr-FR .json
├── Settings/GlobalSettings.ini  # connection reference (host/port/db)
├── db_schema.sql                # schema-only dump, refreshed after every DDL
└── db.dump                      # full dump (pg_dump -Fc), refreshed after every DB change
docs/claude_resume.md            # resume state
```

**Legacy (do not copy as a pattern; migrate when touched):** `Forms/DetailedInputForms/`, `Forms/InputForms/` (empty),
`Forms/Other/`, `Forms/Erp/`, flat `Forms/Production/*.pas`,
`BackEnd/**/Ths.Database.Table.*.pas`, unused `BackEnd/Core/Base/{BaseEntity,BaseRepository,RepositoryORM,QueryBuilder}.pas`.

---

## 4. Architecture (mandatory)

```text
Domain (Entity) → Repository → Service → Forms
```

- Domain = schema mapping only
- Repository = DB access only (no business logic)
- Service = business logic + authorization + transactions
- Forms = UI only — no direct DB / repository access (known legacy violation: `ufrmLogin`)

---

## 5. Database

Test environment (credentials are intentionally plain):

- Host `localhost`, user `postgres`, password `qwe`, database `ths_erp`, schema `public`
- Port **5432 or 5433** (two machines) — the authoritative value is `ERP/Settings/GlobalSettings.ini` (`DBPortNo`)
- Tools: `C:\Program Files\PostgreSQL\18\bin\` (`psql.exe`, `pg_dump.exe`)

Non-negotiable:

- English, `snake_case` identifiers, module prefixes never removed (`sys_`, `emp_`, `acc_`, `stk_`, `prd_`, `sls_`, `pur_`, `einv_`, `ord_`, `inv_`)
- **No migration files.** Single developer; the DB moves between the two machines via git: `ERP/db.dump` (full,
  schema + data) and `ERP/db_schema.sql` (schema, reviewable diff). Apply DDL/data fixes directly with `psql`, then
  refresh both (cannot be skipped):
  `pg_dump -h localhost -p {port} -U postgres -s ths_erp > ERP/db_schema.sql`
  `pg_dump -h localhost -p {port} -U postgres -Fc -f ERP/db.dump ths_erp`
  Other machine: `pg_restore -h localhost -p {port} -U postgres -d ths_erp --clean --if-exists ERP/db.dump`
- Take a scratch backup (`pg_dump -Fc -f <scratchpad>/ths_erp_before_<change>.dump ths_erp`) before destructive/structural changes

Details (views, locale, identity, audit trigger): `.claude/rules/database.md`.

---

## 6. Build & Validation

Compile from `ERP/` (Ths.exe is often locked by a running instance → use a temp output dir):

```bat
call "C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\rsvars.bat"
msbuild Ths.dproj /t:Build /p:Config=Debug /p:Platform=Win32 /p:DCC_ExeOutput=%TEMP%\ths_build_out /v:minimal
```

- Never call bare `dcc32` (Delphi 7 is first on PATH).
- A change is "done" only when the project compiles with **0 errors** and no new warnings in touched units.
- Validate new SQL against the live DB inside `BEGIN … ROLLBACK`.
- UI flows cannot be run by Claude — say explicitly what was not runtime-tested.

---

## 7. File Encoding

| File                     | Encoding                                               |
| ------------------------ | ------------------------------------------------------ |
| `.pas`, `.dpr`, `.dproj` | UTF-8 **with BOM**, CRLF                               |
| `.dfm`                   | ASCII, CRLF; non-ASCII as `#nnn` (e.g. `'Kad'#305'n'`) |
| `.json` (localization)   | UTF-8, keep existing line endings                      |

Preserve BOM/CRLF when editing with scripts.

---

## 8. Execution Mode

Full authority: analyze, generate, patch, move, delete obsolete files, change the DB (then refresh dumps), run SQL, fix build errors.
No unnecessary questions. Ask only for: destructive operations, ambiguous business rules, missing critical schema.

Flow: Analyze → Plan → Execute → Validate (compile + SQL) → Fix → Finalize.
Priority: Working → Compile-safe → Architecture-safe → Clean code.

Existing files: analyze first, patch only broken parts, never regenerate working forms/units.
Fix priority: compile errors → missing methods → invalid transactions/authorization → naming violations → UI issues.

---

## 9. Resume State

`docs/claude_resume.md` tracks goal, design decisions, completed, remaining, failures/blockers.
Update it at the end of every multi-step task and before long work may overflow context.
Commands: `resume goal`, `resume migration`, `clear resume state`.

---

## 10. Output Contract

No raw chain-of-thought. For task results use:

```yaml
## Analysis Summary   # goal / module / table
## Execution Plan     # create / patch / skip
## Execution Result   # completed / failed / warnings
## Remaining Issues   # issues
```
