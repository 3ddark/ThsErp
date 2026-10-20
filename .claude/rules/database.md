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
  (becomes `app_user` of the audit rows; without it they are written with `app_user` NULL).
- Afterwards refresh both transport files (committed; the other machine restores `db.dump`):
  `pg_dump -s ths_erp > ERP/db_schema.sql` and `pg_dump -Fc -f ERP/db.dump ths_erp`.
- Scratch backup before structural/destructive changes: `pg_dump -Fc -f <scratchpad>/ths_erp_before_<change>.dump ths_erp`.
- Test application SQL against the live DB inside `BEGIN … ROLLBACK`.

## Tables

- `id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY`; `ALTER TABLE … OWNER TO ths_admin;`
- FK column name = `{referenced_table}_id` (e.g. `sys_country_id`, `emp_employee_id`); explicit constraint names;
  `ON UPDATE CASCADE` + deliberate `ON DELETE` (`CASCADE` for owned detail rows, `SET NULL` / `RESTRICT` otherwise).
- Index every FK column that is not the leading column of a unique constraint.
- Security/master tables get the audit trigger (table needs an `id` column):
  `CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON public.x FOR EACH ROW EXECUTE FUNCTION public.audit();`
  Every list of such a table automatically gets the "İşlem Geçmişi" popup (Ctrl+H). See "Audit log" below.
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
  `vw_sys_country`, `vw_sys_city`, `vw_sys_permission_group`, `vw_sys_uom`, `vw_sys_uom_group` (2026-10-18; every
  locale view now follows it — keep the fallback cast to the column's original type so `CREATE OR REPLACE` works),
  `vw_stk_inventory` (uom / country names via their translation tables; also exposes the card-specific accounting
  overrides and their `default_*` fallbacks).
- Stock card accounting overrides: `stk_inventory.vat_rate` + 7 account columns are NULL = inherit (group accounts from
  `stk_group`, VAT accounts from the `acc_set_tax_rate` row of the effective VAT rate). Voucher posting must read the
  resolved values from `vw_stk_inventory_account`, never `stk_group` directly.
  `stk_group.vat_rate` (NOT NULL, no default) and `stk_inventory.vat_rate` (NULL = group) are FKs to
  `acc_set_tax_rate(tax_rate)` (ON UPDATE CASCADE, ON DELETE RESTRICT): only defined rates; forms offer a combo.
- Country names (`sys_country_translation`) come from Unicode CLDR by ISO alpha-2 code (tr-TR / en-US / de-DE,
  normal case). A new language: generate its names the same way (Python Babel `Locale(...).territories[code]`).
- Views without translations have no `locale` column; their repositories must not add a locale filter.
- Changing view columns: `DROP VIEW` + `CREATE VIEW` (not `CREATE OR REPLACE` when names/types/order change), then check
  `sys_grid_column` / `sys_user_grid_column` for rows with old column names and delete/rename them.

## Module links

- Document addresses (pattern, first on `sls_offer`): the document owns its detailed addresses —
  `billing_sys_address_id` / `shipping_sys_address_id` (UNIQUE, FK `sys_address` RESTRICT; written / deleted with the
  document by its service) + source `billing_address_id` / `shipping_address_id` (FK `acc_account_address`, must belong to
  the document's account). Copied from the account address, editable on the document, empty shipping = billing.
- Account card addresses: the card edits one address per type (BILLING / SHIPPING / LEGAL / OTHER = primary or first
  `acc_account_address` row) and `TAccAccountService` saves them with the account in one transaction (unchanged = no SQL,
  emptied = link + own `sys_address` deleted, shared `sys_address` = copy-on-write). A new table with an FK to
  `sys_address` must be added to `TAccAccountAddressRepository.IsSysAddressShared`.
- Account codes (`acc_account.code`): 3-digit levels, at most three (`120` / `120-001` / `120-001-001`); the parent
  (code without the last level) must exist and must not be a detail account (type 3); an account with sub-accounts keeps
  its code (`TAccAccountService.CheckCode`). The card picks codes from lists (main -> intermediate -> free codes).
- Exchange rates: `acc_exchange_rate.rate` = TCMB forex buying (document default), plus `forex_selling`,
  `banknote_buying`, `banknote_selling`, `source` (MANUAL / TCMB; TCMB import never overwrites MANUAL). A Friday bulletin is
  also written for Saturday + Sunday. Lookups use `fn_exchange_rate(currency, date)` (latest rate on or before the date,
  relative to `fn_default_currency()`), never `rate_date = date`. Base currency code is ISO `TRY`.
- Goods receipt lines own their stock entry: `stk_transaction.pur_receipt_detail_id` (UNIQUE, ON DELETE CASCADE, type 1 only)
  is written by `TPurReceiptDetailRepository.UpsertStockTransaction`; the stock transaction service refuses to update / delete
  such rows. Purchase quantities are service-maintained: `pur_request_detail.ordered_quantity` (non-cancelled order lines),
  `pur_order_detail.received_quantity` (receipt lines); header totals = sum of line amounts; order / request status 3-4 automatic.
- Sales mirror purchasing (offer → order → delivery note → invoice, `SlsLookup`): stock goes out on the delivery note line
  (`stk_transaction.sls_dispatch_detail_id`, type 2, amount = net sales amount) or, for an invoice line without a delivery
  note ("irsaliyeli fatura"), on the invoice line (`stk_transaction.sls_invoice_detail_id`, from `sls_invoice.stk_warehouse_id`,
  required then). Both links are UNIQUE / CASCADE, written by `UpsertStockTransaction` of the line repositories; the stock
  transaction service refuses to change them (`IsSalesDocumentLinked`). An invoice line links either a delivery note line or an
  order line (CHECK). Service-maintained: `sls_offer_detail.ordered_quantity`, `sls_order_detail.delivered_quantity` (delivery
  note lines + invoice lines with an order link). Sales invoices are debits in `vw_acc_account_transaction` (source 6).
  `sls_dispatch.status` is service-maintained (1 waiting = not fully invoiced, partial included; 2 closed = every line
  fully invoiced; `TSlsDispatchRepository.RefreshInvoiceStatus`, called by dispatch and invoice saves / deletes);
  `sls_dispatch_detail.line_no` (UNIQUE per dispatch, deferrable).
- e-Document (UBL-TR 1.2.1, design `docs/einvoice_design.md`): code lists `einv_profile`, `einv_invoice_type`,
  `einv_tax_exemption` (group 1-7, `einv_invoice_type_id`, `requires_gtip` / `requires_diib`), `einv_tax_type`,
  `einv_withholding` (`rate`), `einv_delivery_term` (`is_incoterms`), `einv_transport_mode`,
  `einv_packaging_type`, `einv_payment_means`, `einv_gtip` (12 digits) and DIIB `einv_diib` (`holder_type` 1 own / 2
  customer + `acc_account_id`) + `einv_diib_line` (`line_code`, GTIP, product description, `sys_uom_id`). Rule flags live in these
  tables (editable on screens), never hard-coded. `stk_inventory.einv_gtip_id` (was `hs_no`). `sls_invoice`:
  `einv_profile_id` (NULL = paper invoice; CHECK: profile / type / status / uuid all NULL or all set), `einv_uuid`
  (ETTN, generated once), `einv_status` 1-7 (service-maintained; 2/3/4/5/7 lock the invoice), exemption / delivery
  term / transport mode / payment means, customs exit data, `withholding_amount`; lines: GTIP, withholding, seller /
  buyer DIIB line, package type / no / quantity / brand. Account debit of a sales invoice = total − withholding.
  `einv_series` (code 3 chars, scope 1 e-Fatura / 2 e-Arşiv / 3 e-İrsaliye; the series used is chosen per company in
  `einv_document_setting`, no default flag) + `einv_series_counter` (per year,
  service-maintained); `sls_invoice.einv_no` (UNIQUE, GİB format, set when sent); `einv_document` (UBL XML per invoice
  or delivery note: UNIQUE `sls_invoice_id` / `sls_dispatch_id`, CASCADE, exactly one set (CHECK), no audit).
  e-Despatch (2026-10-18, design §6): `sls_dispatch.einv_profile_id` (NULL = paper; profile / uuid / status all NULL or all
  set), `einv_uuid`, `einv_status`, `einv_no`, `despatch_time`, transport `carrier_acc_account_id` (account) or
  `einv_vehicle_id` + `trailer1/2_einv_vehicle_id` + `driver1/2_einv_driver_id` (definition cards `einv_vehicle` plate +
  `is_trailer`, `einv_driver` TCKN; second slot needs the first, CHECK); `acc_account.e_despatch_active`; series scope 3.
  `vw_sls_invoice.einv_uuid` is `::text` — FireDAC reads PG `uuid` as a GUID and swaps the byte order of the first
  three groups; read uuids as text, write them with `CAST(:x AS uuid)`.
- Integration (API) services — framework, design §7: `sys_api_service` (per company + `service_kind` free code, provider,
  environment 1 test / 2 live, URL, user, `password_enc` / `api_key_enc` AES-encrypted by the app, `options` jsonb object;
  view shows only `has_password` / `has_api_key`). Modules keep their own fields in an extension table referencing it
  (`einv_document_setting`: company + document type → series, sender alias, API service).
- Company bank accounts (`fin_company_bank_account`): flags `show_on_cheque` / `show_on_note` / `show_on_print`; printouts read
  `vw_fin_company_bank_account.print_text` via `TFinCompanyBankAccountService.GetPrintLines(FIN_BANK_USAGE_*)`. Own (given)
  cheques / notes may reference one (`fin_cheque_note.fin_company_bank_account_id`, CHECK direction = 2); bank, account no and
  currency then come from the account.
- When a list was already opened in the app, `sys_grid_column` / `sys_user_grid_column` hold its columns: new view columns
  must get rows there too, otherwise they are not fetched (e.g. the FK is lost on review → update).
- Account (cari) transactions are derived, never stored: `vw_acc_account_transaction` unions the money transactions,
  cheque / note transactions (opening, endorsement, bounce, return), POS, company card spending and purchase invoices with
  `source_type` (`ACC_TX_SRC_*` in `AccLookup`), `source_id` and `document_id` (the record "Show Details" opens).
  A new financial source document must be added there, to `TAccLookup` (alkTxSource) and to
  `TfrmAccAccountTransactions.OpenSourceDocument` (opens the source form via its service → read permission enforced).
- Read-only list entities may have no table (`FinMoneyLedger` → `vw_fin_money_ledger` only, window function: no `FOR UPDATE`;
  its repository ignores `ALock`).

## Menu tree (`sys_menu`)

- `sys_menu` (`menu_code` UNIQUE 100000-999999, generated `parent_code` FK → `sys_menu.menu_code`, `menu_key` UNIQUE,
  `action_name` UNIQUE = dashboard TAction name, `sys_permission_id` RESTRICT, `is_active`; CHECK: folders (`code % 100 = 0`)
  have no action / permission, screens have an action) + `sys_menu_translation` (`menu_name`, `keywords`) →
  `vw_sys_menu` (locale CROSS JOIN pattern, `permission_code`, `permission_name`, `parent_path` "Module > Group").
  `TSysMenuRepository` / `TSysMenuService` = CRUD of the maintenance screen (`TfrmSysMenus`, permission 1111) + tree read
  (`GetMenu`: effective `IsActive` — a passive folder hides its children — and `Allowed`). Service rules: code range,
  parent row exists, folder has no action / permission, screen has an action, code / key / action unique and immutable,
  **no delete** (make the row passive). Empty translated name deletes that language's translation row (view → key).
- `sys_user_setting` (per user `setting_key` / `setting_value`, UNIQUE) — UI settings; keys in `SysUserSetting.pas`
  (`nav.visible`, `nav.width`, `nav.expanded`); `TSysUserSettingService` (current user, no permission).
- `sys_user_menu` (per user + screen, UNIQUE; `is_favorite`, `open_count`, `last_opened_at`; both FKs CASCADE, no audit:
  high churn) — favorites / recently used of the left tree. Written with upserts by `TSysMenuRepository.SetFavorite` /
  `RegisterOpen` on the main connection (joins another screen's open transaction, like every other write).

## Audit log (işlem geçmişi) — separate DB `ths_audit` (2026-10-15)

Goal: the history must not bloat the ERP / period DBs, and all period / company DBs share one history.

```text
ERP DB (ths_erp, later ths_erp2026, ths_erp2027 …)                 ths_audit (one per server)
  trigger public.audit()  ──►  public.audit_outbox (local queue)      public.audit_database (registry)
  public.audit_flush()  ── postgres_fdw (audit_server) ──►            public.audit_log PARTITION BY LIST (period_year)
  public.vw_sys_audit_log  ◄── audit_remote.audit_log (foreign)         audit_log_2026, audit_log_2027 … (auto)
```

- Never write to the remote DB from the trigger (dblink / FDW per row = slow, couples every save to ths_audit
  availability, and rolled-back work would still be logged). The trigger only inserts into `audit_outbox`
  (SECURITY DEFINER, owner postgres): I = full new row, D = full old row, U = **only changed columns** (old / new),
  no-op updates are skipped; `app_user` = `ths_erp.user_name`, `db_user` = session_user, `client_addr`, `txid`.
- `audit_flush(batch, max_batches) -> (moved, error_message)` (SECURITY DEFINER): moves the queue in batches
  (`FOR UPDATE SKIP LOCKED`, `DELETE … RETURNING` → foreign insert) in one local transaction; postgres_fdw commits the
  remote side with it. Re-sent rows are ignored (`UNIQUE (period_year, db_name, source_id, changed_at)` +
  `ON CONFLICT DO NOTHING`). Remote errors never raise: `moved = -1`, rows stay queued. Registry inserts / counter
  updates run in savepoints (FDW remote transactions are REPEATABLE READ → concurrent flushes would get
  serialization failures). Empty queue = no remote connection. Port of a `localhost` server self-corrects
  (dump moved to a machine with another port); other host: `SELECT audit_configure(host, port, 'ths_audit')`.
- Who flushes: the app (`TSysAuditLogService.Flush`) — dashboard timer every 60 s, at login (`SetSession`), before
  opening the audit list, on close; skipped while the connection has an open transaction (would hold remote locks).
- Row identity in ths_audit: `period_year` (= `fn_active_period()` = `sys_application_setting.active_period`, else
  the current year), `db_name` (current_database()), `db_family` (`fn_db_family()`: DB name without a trailing
  `[_]YYYY` → `ths_erp2026` / `ths_erp2027` = family `ths_erp`, i.e. the company), `source_id` (outbox id).
- `ths_audit.audit_database` registers each source DB on its first flush; its BEFORE trigger creates the year
  partition (`audit_create_partition`, race-safe). Old years can be detached / archived per partition.
- Role `ths_audit_writer` (user mapping FOR PUBLIC): SELECT + INSERT on `audit_log`, no UPDATE / DELETE (history is
  append-only for the app); registry counters only.
- Reading: `vw_sys_audit_log` (foreign table; `row_id` is exposed as `record_no` — not an FK; old/new as text,
  `changed_columns` for U). Filters on `db_family`, `period_year`, `table_name`, `record_no` push down (parameters too);
  never filter with `current_database()` / local functions in the view (not shippable → full remote scan).
  App: `SysAuditLog` (read-only entity / repo / service, permission 1112), `TfrmSysAuditLogs` (Sistem > Raporlar >
  İşlem Geçmişi 100801: current period of this company; popup "Bu Kaydın Tüm Geçmişi", "Tüm Dönemler"),
  `TfrmSysAuditLogDetail` (field / old / new grid).
- Tests: integration `IntegrationTest.exe audit` (trigger → queue → flush → remote, rollback undoes the remote side,
  idempotent re-flush, read-only, permission); `ERP/Tests/Audit/test_periods.sh` (two temporary period DBs + a
  temporary audit DB: partitions, registry, cross-period record history, audit DB down, 3 concurrent flushes,
  period change, writer role cannot delete / update). UI harness restores `ths_erp_it` against its own `ths_audit_it`.

### Period (year) databases — plan

- One DB per company and year: `ths_erp2026`, `ths_erp2027` … (`[_]YYYY` suffix; the family = company). The
  current single `ths_erp` already works as a period DB (`active_period` = 2026).
- Year-end ("dönem açılışı"), when implemented: `audit_flush()` in the old DB until the queue is empty → create the
  new DB from the old one (`CREATE DATABASE ths_erp2027 TEMPLATE ths_erp2026`, no other connections) →
  `TRUNCATE audit_outbox`, set `active_period` = 2027, delete / carry over transactional data (opening balances,
  open documents) → the first flush registers `ths_erp2027` and opens partition 2027. Record ids persist, so a
  record's history spans years (`db_family` + `table_name` + `record_no`).
- Login must then choose the period DB (company + year list from the server, e.g. `pg_database` names of the family
  or a `ths_audit`-like shared catalog DB); `GlobalSettings.ini DatabaseName` stays the default.

## Grid metadata tables

`sys_grid_column` (global) and `sys_user_grid_column` (per user) store column order/width/visibility per view.
`TSysGridColumnCache.BuildSelectColumns` skips columns that no longer exist in the view, but stale rows should still be
cleaned up when a view changes.
