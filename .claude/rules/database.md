---
paths:
  - "ERP/Database/**"
  - "ERP/db_schema.sql"
  - "**/*.sql"
  - "ERP/BackEnd/**/Repository/*.pas"
---

# Database Rules (PostgreSQL)

Connection and non-negotiables are in `.claude/CLAUDE.md` §5. This file covers conventions.

## Schema / data changes

- No migration files (single developer). Run changes directly with
  `psql -h localhost -p {port} -U postgres -d ths_erp -v ON_ERROR_STOP=1`, inside `BEGIN; … COMMIT;`.
  Dry-run first with `ROLLBACK` instead of `COMMIT`.
- First statement in any change touching audited tables:
  `SELECT set_config('ths_erp.user_name', '<who_or_change_name>', true);`
  (`audit()` calls `current_setting('ths_erp.user_name')` without `missing_ok` and fails otherwise).
- Afterwards refresh both transport files (committed; the other machine restores `db.dump`):
  `pg_dump -s ths_erp > ERP/db_schema.sql` and `pg_dump -Fc -f ERP/db.dump ths_erp`.
- Scratch backup before structural/destructive changes: `pg_dump -Fc -f <scratchpad>/ths_erp_before_<change>.dump ths_erp`.
- Test application SQL against the live DB inside `BEGIN … ROLLBACK`.

## Tables

- `id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY`; `ALTER TABLE … OWNER TO ths_admin;`
- FK column name = `{referenced_table}_id` (e.g. `sys_country_id`, `emp_employee_id`); explicit constraint names;
  `ON UPDATE CASCADE` + deliberate `ON DELETE` (`CASCADE` for owned detail rows, `SET NULL` / `RESTRICT` otherwise).
- Index every FK column that is not the leading column of a unique constraint.
- Security/master tables get the audit trigger:
  `CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.x FOR EACH ROW EXECUTE FUNCTION public.audit();`
- Data inserted with explicit ids leaves the identity sequence behind → resync after such loads:
  `SELECT setval(pg_get_serial_sequence('public.x', 'id'), COALESCE(max(id), 1)) FROM public.x;`
- Translatable names live in `{table}_translation (…_id, sys_language_id, name)` with PK (`…_id`, `sys_language_id`).

## Views (`vw_{table}`)

- Every entity is read through `public.vw_{table}` (repositories read views, write tables). Owner `ths_admin`.
- Expose all table columns with their original names + readable joined names (`country_name`, `unit_name`, …).
  Never rename an FK column in a view (`country_id` ❌ → `sys_country_id` ✅).
- **Locale strategy** for views with translations: one row per record **per language**, never derive `locale` from a
  translation row (records without a translation would disappear and login/find would fail):

```sql
FROM public.sys_x x
CROSS JOIN public.sys_language l
LEFT JOIN public.sys_x_translation t ON t.sys_x_id = x.id AND t.sys_language_id = l.id
-- name: COALESCE(t.name, x.key)
```

  Views already migrated to this pattern: `vw_emp_employee`, `vw_sys_user`, `vw_sys_permission`, `vw_sys_access_right`,
  `vw_sys_permission_template_right`, `vw_sys_address`, `vw_emp_person_type`, `vw_emp_section`, `vw_emp_unit`, `vw_emp_task`,
  `vw_acc_account`, `vw_acc_set_account_type`, `vw_acc_set_ownership_type`, `vw_acc_set_company_legal_form`,
  `vw_stk_inventory` (uom / country names via their translation tables).
  Others (`vw_sys_city`, `vw_sys_country`, `vw_sys_uom*` …)
  still derive locale from translations — migrate when touched.
- Views without translations have no `locale` column; their repositories must not add a locale filter.
- Changing view columns: `DROP VIEW` + `CREATE VIEW` (not `CREATE OR REPLACE` when names/types/order change), then check
  `sys_grid_column` / `sys_user_grid_column` for rows with old column names and delete/rename them.

## Grid metadata tables

`sys_grid_column` (global) and `sys_user_grid_column` (per user) store column order/width/visibility per view.
`TSysGridColumnCache.BuildSelectColumns` skips columns that no longer exist in the view, but stale rows should still be
cleaned up when a view changes.
