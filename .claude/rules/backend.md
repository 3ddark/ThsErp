---
paths:
  - "ERP/BackEnd/**/*.pas"
---

# Backend Rules (Domain / Repository / Service / Exception)

Reference implementations: `BackEnd/System/{Domain,Repository,Service}/SysCity.*`, `SysCurrency.*`,
`SysPermissionTemplate.*` (no locale), `EmpEmployee.*` (many column types, nullable FKs).

Units per entity (all registered in `Ths.dpr` **and** `Ths.dproj`):

```text
BackEnd/{Module}/Domain/{Entity}.pas
BackEnd/{Module}/Exception/{Entity}.Exception.pas      # when the service raises entity-specific errors
BackEnd/{Module}/Repository/{Entity}.Repository.pas
BackEnd/{Module}/Service/{Entity}.Service.pas
```

---

## Domain

```pascal
[Table('sys_city')]
TSysCity = class(TEntity)          // TEntity provides Id: Int64
```

- Every table column → one property with `[Column('column_name')]` (column `id` comes from `TEntity`).
- Validation attributes: `Required(TLangKeys.TValidation.Required, True)`, `MaxLength(n)`, `Range(...)`.
  Mark every NOT NULL column (except `id` / columns with defaults) as `Required` so errors are caught before the DB.
- View-only display values (e.g. `country_name` from `vw_*`) → `[NotMapped]` string properties.
- Nested objects via `[BelongsTo('FkProp')]` / `[HasMany('FkProp','Id')]` must be created (or nil-checked) consistently;
  prefer flat `[NotMapped]` display fields for new entities.
- `constructor Create; override;`, `destructor Destroy; override;`, `function Clone: T{Entity};`
  — `Clone` must copy **every** property (mapped + NotMapped) and must never modify `Self`.
- Never name a property like a `TObject` member (`UnitName`, `ClassName`, …) → W1009.

Type mapping:

| PostgreSQL | Delphi |
| --- | --- |
| bigint (id / FK) | Int64 (FK 0 = NULL) |
| integer | Integer |
| smallint | SmallInt |
| varchar / text / jsonb | string |
| boolean | Boolean |
| numeric | Currency |
| double precision | Double |
| date | TDate (0 = NULL) |
| timestamp | TDateTime |
| bytea | TArray<Byte> |

---

## Repository

```pascal
T{Entity}Repository = class(TRepository<T{Entity}>)
```

Required overrides (all are abstract in `TRepository<T>`):

- `MapFromQuery`, `DoFindAllGridQuery`
- `DoFind`, `DoFindById`, `DoFindOne`
- `DoAdd` (`INSERT … RETURNING id`), `DoAddBatch`
- `DoUpdate`, `DoUpdateBatch`
- `DoDelete(AID)`, `DoDelete(AModel)`, `DoDeleteBatch` ×3
- helpers: `PrepareAddSql`, `PrepareUpdateSql`, `PrepareDeleteSql` (ends with `' WHERE'` on purpose), `SetInsertParams`, `SetUpdateParams`

Queries:

- Reads always go through the view `vw_{table}`:
  - grid: `'SELECT ' + BuildSelectColumns([...]) + ' FROM ' + GetFullViewName(T) + ' WHERE …'`
  - find: `PrepareSelectFromView(AFilter, ALock, AOnlyOne, AApplyLocaleFilter)`
- Translated/locale views (view has a `locale` column): grid uses `WHERE locale = :locale`, finds pass
  `AApplyLocaleFilter = True`, and set `ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage`.
  Grid and find must use the **same** locale behaviour (otherwise duplicate rows / "record deleted" errors).
- Writes go to the table (`public.{table}`), never to the view.
- Param types (FireDAC PG): text → `.AsWideString` / `.AsWideStrings[i]` (and `DataType := ftWideString`), numeric →
  `.AsBCD` / `.AsBCDs[i]` (`ftBCD`). Never `.AsString` (ftString = ANSI: `₺`, `₽`, Cyrillic … become `?`) or
  `.AsCurrency` (ftCurrency = PG `money`: rounds to 2 decimals, `numeric = money` errors). Filter values: no
  `TValue.From<Currency>` (variant → money) — use `Double`.
- Empty-value standard (user decision 2026-10-10): every write calls `ApplyNullPolicy(Q)` right before
  `LogQuery(Q, 'DoAdd'|'DoUpdate'|'DoAddBatch'|'DoUpdateBatch')` (detail tables: `ApplyNullPolicy(Q, 'table')`).
  From live column metadata: nullable text '' → NULL, nullable number 0 → NULL, nullable date 0 → NULL;
  NOT NULL text without default empty → "field required" error. Numbers where 0 is meaningful are
  `NOT NULL DEFAULT 0` in the DB (prices, discounts, quantities, summaries, grid colors, decimal places …).
  Nullable column where 0 is meaningful: override `NullPolicyKeepZero` (`stk_inventory.vat_rate`: NULL = from group).
- Domain `Required` on every NOT NULL FK / option (combo) / date column without default (UI marks helper edits and
  `cbb`/`mmo` controls red; save jumps to the field's tab). Not on NOT NULL numbers (empty = 0) or service-derived fields.
- Nullable FK / integer params: `SetNullableParam(Q.ParamByName('x_id'), ftLargeint, AModel.XId, AIndex)` (0 → NULL).
  Nullable dates: `DataType := ftDate` and `Clear` when value is 0.
- Every executed query is logged with `LogQuery(Q, 'Operation')`.
- No business logic, no authorization, no transactions in repositories.

---

## Service

```pascal
T{Entity}Service = class(TCrudService<T{Entity}>)
```

Constructor:

```pascal
FRepo := Self.UoW.GetRepository<T{Entity}, T{Entity}Repository>;
Self.PermissionCode := PERMISSION_{MODULE}_{ENTITY};   // see rules/permissions.md — never PERMISSION_TEMPLATE / 1
```

Required methods (actual signatures):

- `CreateQueryForUI(AFilter)`, `Find`, `FindById(AId: Int64; ALock; AIncludeNestedEntities)`, `FindOne`
- `Add`, `Update`, `Delete(AId: Int64)` (→ private `DoAdd/DoUpdate/DoDelete`, which call `ValidateAll`)
- `BusinessFind`, `BusinessFindById(AId, AWithBegin, ALock, APermissionControl)`
- `BusinessInsert / BusinessUpdate / BusinessDelete(AEntity, AWithBegin, AWithCommit, APermissionControl)`
- `ValidateBusinessRules(AEntity; AOperation: TCrudOperation)` — uniqueness, cross-field rules, derived fields
  (e.g. `full_name := name + ' ' + surname` belongs here, not in the form)

Transaction + authorization pattern (rollback is mandatory):

```pascal
try
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;
  DoAdd(AEntity);
  if AWithCommit and Self.UoW.InTransaction then
    Self.UoW.Commit;
except
  if Self.UoW.InTransaction then
    Self.UoW.Rollback;
  raise;
end;
```

- Read methods: `EnsureAuthorized(…, ptRead, …)`; bulk/special operations (copy, add-all, grant-all) must also call
  `EnsureAuthorized` with `APermissionControl = True`.
- Forms call business methods with `APermissionControl = True` (insert, update, delete, review).
- Services may use other repositories through `Self.UoW.GetRepository<…>` for orchestration (e.g. copying user rights + templates).
- Casting the interface to the concrete repository for extra methods is accepted: `T{Entity}Repository(FRepo).ExtraMethod`.

---

## Documents (header + lines aggregate)

Reference: `SlsOffer`, `SlsOrder`, `SlsDispatch`, `SlsInvoice` (`T{Header}.Lines`, `T{Header}Service = class(TDocumentService<T{Header}, T{Line}>)`,
`{Line}.Repository.FindBy{Header}Ids`). User
decisions 2026-10-16 (`docs/claude_resume.md`); tests `TestSalesOfferDocument`, `TestSalesOrderDocument`,
`TestSalesDispatchInvoiceDocument`. Migrate other documents (purchasing, voucher, production packets) to the same pattern.
Limits that span lines (open order quantity, not yet invoiced dispatch quantity) are checked per document in `CheckLines`:
sum of the document's active lines per linked line vs. linked quantity minus other documents (DB total minus this
document's old lines).

- **Base class `DocumentService.TDocumentService<TH, TL>`** (Core/Base) owns the document flow (CreateLine / AddLine /
  NewLine / RemoveLine / ActiveLines / Recalculate / PrepareCopy / LoadLines / Reload / BusinessSaveWithDetails). The
  document service sets `FHeaderRepo` / `FLineRepo` in its constructor and overrides only the document-specific parts:
  `GetLines`, `FindLinesByHeaderIds`, `Get/SetLineHeaderId`, `Get/SetLineNo`, `RaiseDuplicateLineNo`,
  `RecalculateLine`, `RecalculateTotals`, and optionally `InitLine` (view fields of a new line), `CheckLines(AHeader,
  ALines, AOldLines)` (line rules + amounts; `AOldLines` = DB state before the save: status locks, DB-maintained values
  such as delivered quantity), `AfterLineSaved` (line hook), `AfterDocumentSaved(AHeader, AOldLines)` (document hook,
  old + new links), `PrepareCopyHeader` / `PrepareCopyLine`. Its own `BusinessFindById` / `FindById(…, True)` /
  `Find(…, True)` call `LoadLines`. Conversions (`CreateFromOffer` …) build the target document in memory with
  `NewLine` and save it with `BusinessSaveWithDetails` (one code path).
- Status locks: header editable in more states than lines (sales order: header in draft / approved / partial, lines
  only in draft) → `CheckLines` rejects new / deleted / changed lines outside the editable state; the detailed form
  overrides `DetailsEditable` the same way.

- **Domain = data only.** Header: `property Lines: TObjectList<T{Line}>` (owned, created in constructor, freed in
  destructor, **no attribute**). Line: `class(TDetailEntity)` (`Entity.pas`: `Deleted`, `HeaderEntity` weak reference).
  Typed back reference via a class helper in the **header** unit (`T{Line}Helper = class helper for T{Line}` →
  `property Header: T{Header}`), because header and line units cannot reference each other in the interface.
  `Clone` of the header is deep (lines cloned, their `HeaderEntity` = the clone); line `Clone` copies `Deleted`, not the
  header reference. No logic in domain units.
- **State in one list** (`DetailList.pas`): `Id > 0` update, `Id > 0 + Deleted` delete, `Id < 0` (temporary id
  -1, -2 … from `TDetailList.NextTempId`) insert, `Id < 0 + Deleted` never reaches the DB (`TDetailList.Remove` drops
  it). Deletion only through `Deleted` — never diff against the DB (a partially loaded document must not lose lines).
  Every loop over lines skips `Deleted` (`TDetailList.Active`).
- **Service (all logic):** `BusinessFindById` loads the lines (one query `FindBy{Header}Ids`, ordered by line no);
  `FindById / Find(…, AIncludeNestedEntities = True)` too; plain `BusinessFind` (lists) does not. In-memory methods:
  `CreateLine` (not in list: next line no, header ref, view fields used by the line form), `AddLine` (`TDetailList.Attach`),
  `NewLine` (= both), `RemoveLine`, `RecalculateLine`, `RecalculateTotals`, `Recalculate`, `PrepareCopy` (override:
  header id / number / status, `TDetailList.MarkAllNew`).
- **`BusinessSaveWithDetails(AEntity, AWithCommit, APermissionControl)`** (override of `TCrudService`): authorize
  (add / update) → begin if no transaction → lock header (`FindById(…, True)`) → line checks + amounts (shared class
  method of the line service, e.g. `TSlsOfferDetailService.CheckLine`), empty line numbers, line no uniqueness in
  memory → `ValidateAll(header)` → totals from lines → header insert / update → `TDetailList.Save` (deletes batch,
  updates batch, inserts one by one with `RETURNING id`, optional line hook with the real id) → document hook (once per
  affected record: ordered / delivered quantities, stock summary …) → commit if `AWithCommit` → `Reload` (same object:
  real ids, view fields, DB-derived values). On error: rollback, `TDetailSaveLog.Revert` (temp ids back), new header
  id 0, `Deleted` flags kept, re-raise.
- **Line service stays public** (exceptional single-line code paths). Side effects live in one place and both paths call
  them (line hook per line, document hook per affected record). Account (cari) transactions are derived by
  `vw_acc_account_transaction` — never a hook. Totals are not a hook: recalculated in memory before writing.
- Unchanged existing lines are updated too (one batch; the audit trigger skips no-op updates) — no `Modified` flag.
- Unique keys that lines may swap (`(header_id, line_no)`) are `DEFERRABLE INITIALLY DEFERRED`
  (`sls_offer_detail_line_key`, `sls_order_detail_line_key`); the service still rejects duplicates in memory before
  writing.
- Defined VAT rates: `TAccSetTaxRateRepository.GetTaxRates` + `TAccSetTaxRateService.CheckDefinedRate` (stock group /
  card, purchase order / invoice lines; purchase invoice also allows 0). Line forms show the stock card's unit
  (`GetUomCode`) and fill VAT from the card (else group) when a stock card is picked.
- Sales line VAT rate must be one of `acc_set_tax_rate` (`TSlsOfferDetailService.CheckVatRate`; line forms offer a
  combo of the defined rates); discount 0-100. Invoice exception: 0 % VAT only when the invoice has a tax exemption code.
- Sales invoice e-document rules: `TSlsInvoiceService.CheckEInvoice` (class method; document save calls it from
  `CheckLines` with the in-memory lines, the line service and header-only saves with the DB lines). Rules read the flags of
  the selected code-list rows (`TSlsInvoiceRepository.ReadEInvRules`); a passive code is rejected only when newly chosen.
  Field applicability: `TSlsInvoiceService.GetEInvScope` → `TSlsEInvScope` (`SlsInvoice.Repository`); invoice header / line
  forms show / hide (visible rows restacked, empty line section hidden) + mark required by it, `CheckEInvoice` clears not applicable fields with the same scope
  (`ClearNotApplicableHeader` / `ClearNotApplicableLine`) — table in `docs/einvoice_design.md` §3.
- UBL XML: `AfterDocumentSaved` calls `TEInvDocumentService.GenerateForInvoice` (builder `EInvUbl.Builder` is pure, validator
  `EInvUbl.Validator` = MSXML6 XSD + general.xslt from `Resource/EInvoice`); never blocks the save; one `einv_document` row per
  invoice. GİB number (`sls_invoice.einv_no`) is assigned at send time (`TEInvSeriesRepository.NextNumber`) — §4 of the design doc.
- Documents with several line lists (BoM raw / labour) call `TDetailList.Save` once per list.

---

## Exception

```pascal
E{Entity}Exception = class(EAppException);
E{Entity}Exception{Reason} = class(E{Entity}Exception)
protected
  class function GetMessage: string; override;   // TLocalizationManager.Translate(TLangKeys.T{Entity}.{Key}, 'English default')
end;
```

Raise with `raise E{Entity}Exception{Reason}.Create;`. Messages with parameters: `Exception.Create(Format(Translate(...), [...]))`.
