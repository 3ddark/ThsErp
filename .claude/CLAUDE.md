# CLAUDE_MASTER.md

# 01 — MASTER EXECUTION RULES

## Instruction Priority

Claude must follow instructions in this order:

1. Safety Rules
2. CLAUDE_MASTER.md
3. Resume State (`docs/claude_resume.md`)
4. User Commands

Higher priority overrides lower priority.

---

# 02 — PROJECT CONTEXT

## Project Info

* Project Name: Ths ERP
* Database: PostgreSQL
* Tech Stack: Modern Delphi Desktop ERP
* Goal: ERP + CRM + Accounting Desktop Application

Long-term roadmap:

1. Stabilize desktop ERP
2. Migrate to Web ERP
3. SaaS architecture

Future stack:

* Backend: Go
* Frontend: React + Vite

## Core Philosophy

ERP architecture is **Database-First**.

Truth source priority:

1. Live PostgreSQL (MCP)
2. `ERP/db_schema.sql`
3. Delphi source code
4. User SQL scripts

If conflicts occur:

* MCP is source of truth.

---

# 03 — PROJECT STRUCTURE

```bash
ThsERP/
├── ERP/
│   ├── Ths.dpr
│   ├── Ths.inc
│   ├── BackEnd/
│   │   ├── System/
│   │   ├── Employee/
│   │   ├── Stock/
│   │   ├── Account/
│   │   ├── Order/
│   │   ├── Offer/
│   │   ├── Invoice/
│   │   ├── Production/
│   │   ├── Core/
│   │   └── Tools/
│   ├── Forms/
│   ├── Settings/
│   ├── Tools/
│   └── db_schema.sql
├── ERPDevWizard/
├── docs/
├── CLAUDE_MASTER.md
└── README.md
```

---

# 04 — ARCHITECTURE RULES

Mandatory architecture:

```text
Entity → Repository → Service → Forms
```

Folder structure:

```bash
ERP/BackEnd/{Module}/
├── Domain/
├── Repository/
└── Service/
```

Rules:

* Domain = schema only
* Repository = DB access only
* Service = business logic + authorization + transactions
* Forms = UI only

Forbidden:

* Repository business logic
* Form direct DB access
* Service bypass

---

# 05 — DATABASE RULES

## Database

* Host: localhost
* User: postgres
* Password: qwe
* Database: ths_erp
* Schema: public

---

## Naming Rules

All DB identifiers must:

* be English
* use snake_case
* keep module prefixes

Forbidden:

* Turkish identifiers
* Turkish characters

Examples:

❌ sehir_id
✅ city_id

---

## Module Prefix Rules

Prefixes must never be removed.

Examples:

* sys_
* acc_
* stk_
* emp_
* prd_
* sls_
* pur_
* einv_
* ord_
* inv_

---

## Schema Backup Rule

After every DDL operation:

* create table
* alter table
* add column
* rename column
* create index
* create view
* modify constraint

Mandatory schema dump:

```bash
pg_dump schema-only → ERP/db_schema.sql
```

This step cannot be skipped.

---

# 06 — MCP CONFIGURATION

Primary MCP Server:

```yaml
server_name: ths_erp
engine: postgres
host: localhost
database: ths_erp
user: postgres
schema: public
```

Query priority:

1. MCP
2. db_schema.sql
3. SQL scripts
4. Delphi code

---

# 07 — DYNAMIC MODULE DISCOVERY

Modules are discovered dynamically.

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema='public';
```

Extract prefixes dynamically.

Examples:

* sys
* stk
* acc
* emp
* prd

---

# 08 — FORMS RULES

Forms are module-based.

```bash
ERP/Forms/
├── System/
├── Account/
├── Stock/
├── Employee/
├── Production/
```

Input and output forms must stay in same module folder.

Forbidden:

* InputForms/
* OutputForms/

Form naming:

Single:

```text
ufrm{EntityName}
```

Plural:

```text
ufrm{EntityName}s
```

Examples:

* ufrmSysCity
* ufrmSysCities

---

# 09 — FULL CRUD CODE GENERATION ENGINE

Given a table name Claude generates:

### Backend

* Domain
* Repository
* Service

### Forms

* Input Form
* Output Form
* DFM

Optional:

* Detail Form
* SQL View

Generation order:

1. Domain
2. Repository
3. Service
4. Output Form
5. Input Form
6. DFM
7. SQL View

---

# 10 — DOMAIN RULES

Example:

```pascal
[Table('sys_city')]
TSysCity = class(TEntity)
```

Each column must map to property.

DB → Delphi mapping:

* bigint → Int64
* integer → Integer
* varchar → string
* text → string
* boolean → Boolean
* numeric → Currency
* timestamp → TDateTime
* date → TDate

---

# 11 — REPOSITORY RULES

Example:

```pascal
TSysCityRepository = class(TRepository<TSysCity>)
```

Required:

* constructor
* FindAllGridQuery override

Query:

```sql
SELECT * FROM vw_{table_name} WHERE 1=1
```

No business logic allowed.

---

# 12 — SERVICE RULES

Example:

```pascal
TSysCityService = class(TCrudService<TSysCity>)
```

Mandatory methods:

* Find
* FindById
* Add
* Update
* Delete
* BusinessFind
* BusinessFindById
* BusinessInsert
* BusinessUpdate
* BusinessDelete

Transaction pattern:

```pascal
try
  BeginTransaction;
  Repo.Operation;
  Commit;
except
  Rollback;
  raise;
end;
```

Rollback is mandatory.

---

# 13 — FORM RULES

## Output Form

Requirements:

* Grid columns
* Hidden id
* Hidden FK ids
* Show readable names

## Input Form

Requirements:

* FormCreate
* FormShow
* BtnAcceptClick
* InitializeInputCase
* RefreshData

Rules:

* writable fields only
* FK fields via helper forms using `OnHelperProcess` event binding (see FK Field Helper Process Rule below)
* readonly fields excluded

---

## FK Field Helper Process Rule

When an input form contains FK reference fields that require selection from another table, use the **`OnHelperProcess`** pattern. This allows TEdit controls to automatically open a helper selection modal when the user clicks into them.

### Pattern Overview

1. Define a `HelperProcess(Sender: TObject)` procedure on the form class.
2. In `FormCreate`, assign `OnHelperProcess := HelperProcess` for each FK TEdit control.
3. The `HelperProcess` handler identifies which TEdit triggered it by checking `Sender.Name`, then creates and shows the appropriate helper selection form.

### FormCreate Setup

```pascal
procedure TfrmSysCountry.FormCreate(Sender: TObject);
begin
  inherited;
  edtRegionId.OnHelperProcess := HelperProcess;
end;
```

### Helper Process Handler

The `HelperProcess` procedure must:

* Check if `Sender is TEdit`.
* Match the sender's `Name` to determine which FK field was triggered.
* Create the corresponding helper form (passing the sender, a service instance, and an entity class).
* Set `IsHelper := True` on the helper form before showing it modally.
* After modal close, transfer data from the helper form back to the parent:
  * If `CleanAndClose` returned True → clear the FK id in the table and clear the edit text (user cancelled/cleared).
  * Otherwise → set the FK id in the table (`Table.FkId := Helper.Table.Id`) and populate the edit text with a readable display field from the helper's table.

### Example Implementation

```pascal
procedure TfrmSysCountry.HelperProcess(Sender: TObject);
var
  LFrmRegion: TfrmSysRegions;
begin
  if Sender is TEdit then
  begin
    if (Sender as TEdit).Name = edtRegionId.Name then
    begin
      LFrmRegion := TfrmSysRegions.Create(
        (Sender as TEdit), TSysRegionService.Create, TSysRegion.Create);
      try
        LFrmRegion.IsHelper := True;
        LFrmRegion.ShowModal;
        if LFrmRegion.DataTransfer then
          if LFrmRegion.CleanAndClose then
          begin
            Table.RegionId := 0;
            (Sender as TEdit).Clear;
          end
          else
          begin
            Table.RegionId := LFrmRegion.Table.Id;
            (Sender as TEdit).Text := LFrmRegion.Table.RegionName;
          end;
      finally
        LFrmRegion.Free;
      end;
    end;
  end;
end;
```

### Rules

* Each FK field that needs helper selection must have its `OnHelperProcess` assigned in `FormCreate`.
* The helper form is always created with three arguments: the triggering TEdit, a service instance, and an entity class.
* The helper form sets `IsHelper := True` before showing modally.
* After modal close, data transfer logic checks `DataTransfer` to determine if the user confirmed selection or cancelled/cleared.
* CleanAndClose handling: when cleared, reset FK id to 0 in the table and clear the edit text.

### Implementation Uses Clause

Every helper output form unit used inside `HelperProcess` must be listed in the **implementation** section's `uses` clause of the input form's `.pas` file. This keeps the interface uses minimal and avoids circular dependency issues.

```pascal
implementation

{$R *.dfm}

uses
  ufrmSysRegions;   // TfrmSysRegions helper output form
  ufrmSysCountries; // TfrmSysCountries helper output form (if used)
```

The rule is: for each FK field that uses the `OnHelperProcess` pattern, add a line in the implementation uses listing the corresponding helper output form unit. One line per helper form. Comment with the class name and role (`helper output form`) for clarity.

### Naming Convention for Helper Forms

Helper forms follow the same naming rules as regular forms:

| Parent FK Field | Helper Form Class | Helper Form Unit |
|---|---|---|
| `edtCountryId` | `TfrmSysCountries` | `ufrmSysCountries.pas` |
| `edtRegionId` | `TfrmSysRegions` | `ufrmSysRegions.pas` |

The helper form name matches the output form for that entity (pluralized).

---

### Input Control Naming Rule

Input controls (TEdit, TComboBox, TCheckBox, TMemo, etc.) must use database field names instead of Turkish or descriptive names.

Rule:

```text
edt{field_name}  →  edt{database_field_name}
```

Example:

❌ `edticerik_tipi`
✅ `edtcontent_type`

### Input Control Type Rule

Use generic TEdit for all data types with customization via `thsInputDataType` property.

Supported types:

* String → `itString`
* Integer → `itInteger`
* Float → `itFloat`
* Date → `itDate`
* Time → `itTime`

Example:

```pascal
edticerik_tipi.thsInputDataType := itString;
edtcontent_type.thsInputDataType := itString;
edtsayi.thsInputDataType := itInteger;
edtfiyat.thsInputDataType := itFloat;
edttarih.thsInputDataType := itDate;
edtsaat.thsInputDataType := itTime;
```

Customization is enabled through this property — no separate control types needed.

### Input Control Prefix Rule

Each Delphi component type must use a specific prefix:

| Component Type | Prefix | Example |
|---|---|---|
| TEdit | `edt` | `edtCode`, `edtContentType` |
| TComboBox | `cbb` | `cbbTableName` |
| TCheckBox | `chk` | `chkIsFactory` |
| TMemo | `mmo` | `mmoDescription` |
| TLabel | `lbl` | `lblCode` |
| TListBox | `lbx` | `lbxItems` |

Rule: `{prefix}{database_field_name}`  (PascalCase direct concatenation, NO separator)

Example:

❌ `edt_ip_address`
❌ `edtipAddress`
✅ `edtIpAddress`

❌ `cbbtablo_adi`
✅ `cbbTableName`

❌ `edtIcerikTipi`
✅ `edtContentType`


# 13A — FORM INHERITANCE & DFM CONTRACT

This section is mandatory for all generated Delphi Forms.

---

## Base Form Hierarchy

Forms must inherit from existing ERP base forms.

Forbidden:

* TForm direct inheritance
* standalone forms without ERP base classes

---

## Output Form Base Class

All output/list forms must inherit from:

```pascal
Tfrm{EntityName}s = class(TfrmGrid<T{Entity}, T{Entity}Service>)
```

Example:

```pascal
TfrmSysCities = class(TfrmGrid<TSysCity, TSysCityService>)
```

Mandatory inherited methods:

* CreateInputForm
* DefineFooterColumns
* DefineColumnWidths
* FormShow

Required behavior:

* grid datasource bind to Service
* id column hidden
* FK id columns hidden
* readable lookup columns visible

---

## Input Form Base Class

Single entity forms must inherit from:

```pascal
Tfrm{EntityName} = class(TfrmInputSimpleDB<T{Entity}, T{Entity}Service>)
```

Example:

```pascal
TfrmSysCity = class(TfrmInputSimpleDB<TSysCity, TSysCityService>)
```

Mandatory methods:

* FormCreate
* FormShow
* BtnAcceptClick
* InitializeInputCase
* RefreshData

Required behavior:

* bind UI controls to entity fields
* writable fields editable
* readonly fields hidden or readonly
* FK fields via helper lookup forms

---

## Master Detail Forms

Master/detail forms must inherit from ERP detail base forms.

```pascal
Tfrm{EntityName}Detail = class(TfrmInputDetail<T{Entity}, T{Entity}Service>)
Tfrm{EntityName}s = class(TfrmGrid<T{Entity}, T{Entity}Service>)
Tfrm{SlaveEntityName} = class(TfrmInput<T{Entity}>)
```

Example:

```pascal
TfrmPrdBomDetail = class(TfrmInputDetail<TPrdBom, TPrdBomService>)
TfrmPrdBoms = class(TfrmGrid<TPrdBom, TPrdBomService>)
TfrmPrdRaw = class(TfrmInput<TPrdRaw>)
TfrmPrdLabour = class(TfrmInput<TPrdLabour>)
TfrmPrdByProduct = class(TfrmInput<TPrdByProduct>)
```

Rules:

* master entity on parent form
* detail entities on sub grids/pages
* all child forms linked to master entity id

---

## DFM Contract

Every form unit must have matching DFM file.

Required files:

```bash
ufrm{EntityName}s.pas
ufrm{EntityName}s.dfm
ufrm{EntityName}Detail.pas
ufrm{EntityName}Detail.dfm
{Each Slave Type}
ufrm{EntityName}{SlaveType}.pas
ufrm{EntityName}{SlaveType}.dfm
{Each Slave Type}
```

Forbidden:

* PAS without DFM
* DFM without PAS

---

## DFM Naming Rule

Form class and DFM object name must match.

Example:

```pascal
object frmSysCity: TfrmSysCity
```

Mismatch is forbidden.

---

## Component Contract

Output forms must include:

* grid
* datasource
* toolbar/buttons

Input forms must include:

* labels
* editors
* accept button
* cancel button

---

## Existing Form Refactor Rule

If form exists:

1. analyze inheritance
2. analyze DFM binding
3. detect missing inherited methods
4. patch only broken parts

Never regenerate working forms.

---

# 14 — AUTO FIX ENGINE

Fix priority:

1. Compile errors
2. Missing methods
3. Invalid transactions
4. Naming violations
5. UI issues

Existing file rule:

* analyze first
* patch if needed
* do not regenerate unnecessarily

---

# 15 — DEPENDENCY ENGINE

Migration order is FK-driven.

Rule:

* Parent first
* Child later

Example:

```text
sys_country
→ sys_region
→ sys_city
```

Never violate FK dependency order.

---

# 16 — GOAL ENGINE

Supported commands:

```bash
create module {table}
fix module {table}
analyze module {table}
regenerate domain {table}
regenerate repository {table}
regenerate service {table}
regenerate forms {table}
regenerate all forms module {table}
```

Goal commands:

```bash
/goal migrate table {table}
/goal migrate module {prefix}
/goal migrate all modules
/goal fix all broken modules
/goal stabilize desktop erp
/goal migrate to web
```

---

# 17 — MIGRATION ENGINE

Pipeline:

1. Discover modules
2. Discover tables
3. Analyze schema
4. Scan codebase
5. Detect missing files
6. Detect broken modules
7. Generate/Patch
8. Validate
9. Finalize

---

# 18 — AUTONOMOUS EXECUTION MODE

Claude runs in FULL AUTHORITY mode.

Allowed:

* analyze
* generate code
* patch files
* move files
* delete obsolete files
* create migrations
* run SQL
* fix build errors

No unnecessary questions.

Exception cases:

1. Destructive operation
2. Ambiguous business rule
3. Missing critical schema

---

# 19 — EXECUTION POLICY

Execution flow:

1. Analyze
2. Plan
3. Execute
4. Validate
5. Fix
6. Finalize

Priority:

1. Working
2. Compile-safe
3. Architecture-safe
4. Clean code

---

# 20 — VALIDATION ENGINE

Validation pipeline:

* compile Delphi project
* validate schema
* validate transactions
* validate form bindings
* validate repository queries

---

# 21 — CONTEXT CONTINUATION ENGINE

Trigger continuation if:

* Context > 85%
* Remaining tasks > 20
* Generated files > 50
* Large migration queue

Critical threshold:
95%

State dump required before overflow.

---

# 22 — RESUME ENGINE

Continuation file:

```bash
docs/claude_resume.md
```

Tracks:

* goal
* completed tasks
* remaining tasks
* failures
* blockers

Commands:

```bash
resume goal
resume migration
clear resume state
```

---

# 23 — OUTPUT CONTRACT

Claude never outputs raw chain-of-thought.

Response format:

## Analysis Summary

```yaml
goal:
module:
table:
```

## Execution Plan

```yaml
create:
patch:
skip:
```

## Execution Result

```yaml
completed:
failed:
warnings:
```

## Remaining Issues

```yaml
issues:
```

---

# 24 — WEB ERP ROADMAP

Phase 1:

* stabilize Delphi ERP

Phase 2:

* Go backend

Phase 3:

* React + Vite frontend

Phase 4:

* module migration

Phase 5:

* SaaS infrastructure

Target:
Desktop ERP → Web ERP → SaaS
