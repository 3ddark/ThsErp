---
paths:
  - "ERP/Forms/**/*.pas"
  - "ERP/Forms/**/*.dfm"
---

# Form Rules (VCL)

Reference implementations: `Forms/System/Output/ufrmSysCities.pas` + `Input/ufrmSysCity.pas` (FK helpers),
`ufrmSysPermissionTemplates` / `ufrmSysPermissionTemplateRights` (popup menu, fixed filter, bulk actions),
`Forms/Employee/Input/ufrmEmpEmployee` (all control types, two-column layout).

Never inherit from `TForm` directly. Input and Output forms of a module live in `Forms/{Module}/Input` and `Forms/{Module}/Output`.

| Kind | Unit / class | Base |
| --- | --- | --- |
| Output (list) | `ufrm{Entity}s` / `Tfrm{Entity}s` (plural, e.g. `TfrmSysCities`) | `TfrmGrid<T{Entity}, T{Entity}Service>` |
| Input (single) | `ufrm{Entity}` / `Tfrm{Entity}` | `TfrmInputSimpleDB<T{Entity}, T{Entity}Service>` |

Every unit has a matching `.dfm`; DFM object name = class name without `T` (`object frmSysCity: TfrmSysCity`).
Register both form units in `Ths.dpr` (`… in '…pas' {frmX}`) and `Ths.dproj` (`<DCCReference …><Form>frmX</Form>`).

---

## Output form (`TfrmGrid<>`)

- `TfrmGrid` builds itself with `CreateNew` — grid, datasource, panels, filter edit and buttons are created in code.
  The `.dfm` is a stub (form properties + `OnShow = FormShow`) and is **not** loaded at runtime; put nothing else in it.
- **Layering:** `ufrmGrid.TfrmGrid<TE, TS>` is only the Service / Table bridge (constructor, `SetSelectedItem`,
  `FillNotMappedFromDataSet`, `ShowInputForm`, hooks `CreateGridQuery` / `GetUoW` / `EntityClass` / `CurrentRecordId` /
  `IsAuthorizedFor`). Everything type-independent lives once in the non-generic `ufrmGridBase.TfrmGridBase` (layout,
  events, popup, filters, paging glue, status bar), which delegates to `Forms/Core/Base/Grid/`:
  `Grid.Types` (TFooterColumn, TQuickFilter, THackDBGrid, `DB_STATUS_*`, `GRID_PAGE_*`, record-history hooks
  `GRecordHistoryAvailable/Show`), `Grid.Sql` (pure SQL / filter builders: search, popup filter, ORDER BY split,
  sort toggle, view name), `Grid.Paging` (TGridPager: base SQL + params, quick / search / filter conditions, page SQL,
  totals, page of id; `GridPageSize`), `Grid.PagingBar`, `Grid.QuickFilter`, `Grid.Footer` (totals panel),
  `Grid.Columns` (sys_grid_column / sys_user_grid_column layout, sys_grid_filter + sort, column states),
  `Grid.Export` (Excel / CSV), `Grid.ColumnSelector`. New list behaviour goes into the matching `Grid.*` unit (or
  `TfrmGridBase` when it is UI glue), never back into the generic class — generic code is compiled once per list form.
- Constructor: `Create(AOwner, AService, ATable, ACreateNewBase = True, AUseHelper = False)`; the grid owns and frees
  service and table.
- Overrides used by every list form: `CreateInputForm`, `DefineColumnWidths`, `FormShow`, `ApplyLocalization`.
  Optional: `DefineFooterColumns`, `SetSelectedItem` (when nested display objects must be filled), `PreparePopupMenu`.
  Base `SetSelectedItem` also fills `[NotMapped]` string props from the same-named snake_case grid column
  (`UomName` ← `uom_name`) — the column must be fetched (`sys_grid_column` row for the view).
- Read-only list (no input form): `CreateInputForm` returns nil and `BtnAdd` hidden; base `ShowInputForm` skips nil.
- Record history: every `TfrmGrid` has a hidden popup item `mniRecordHistory` ("İşlem Geçmişi", Ctrl+H). `FormShow` shows
  it when the entity's table has the `audit` trigger and the user may read 1112 (hooks `GRecordHistoryAvailable` /
  `GRecordHistoryShow` in `Grid.Types`, assigned in `ufrmSysAuditLogs` initialization — the grid does not use that unit).
  Nothing to do per form; the row must have an `id` field.
- **Paging (server side, default on):** `FormShow` keeps the query body without `ORDER BY` (after `AddFixedFilter` +
  `sys_grid_filter` / `sys_grid_sort`) and every page is `body [+ AND search / popup filters] ORDER BY title sort, base
  sort, id LIMIT n OFFSET m`. Quick filter (350 ms debounce, `ILIKE` + Turkish upper/lower params `pg_s*`), popup
  Filter / Exclude (SQL literals; timestamps compared per second), title sort, footer totals (`count` + aggregates in
  one query), record count, Excel / CSV export and `CollectVisibleIds` all cover **every** filtered row, not the page.
  Footer bar: « ‹ [page] / n › » `from - to / total` + page size combo (50/100/250/500/1000/All); the size is one
  per-user setting (`sys_user_setting` `grid.page_size`, default 100). Ctrl+PgUp / Ctrl+PgDn change page.
  `RefreshParentGrid(True)` / `RefreshData` jump to the page of `Table.Id` (new record → last page) and keep the
  current column layout (`DefineColumnWidths` re-runs so field `OnGetText` hooks survive the reopen).
  Never rely on `Qry` holding all rows (iterate via a service / repository instead); a list that must stay client-side
  sets `PagingEnabled := False` before `inherited FormShow`. `Qry.IndexFieldNames` / `Qry.Filter` are not used in paged mode.
- **Quick filter (status groups etc.):** in `FormShow` *before* `inherited` (guard `if QuickFilterCount = 0`) call
  `AddQuickFilter('', 'status IN (:qc0, :qc1)', [A, B])` per option (first = selected, `''` SQL = all); radio buttons sit
  right of the filter edit; captions via `SetQuickFilterCaption(i, Translate(...))` in `ApplyLocalization`. The condition
  is ANDed to the base query (params `:qc0…`), so page, count, footer totals and exports follow it, in both paged and
  client modes. Low level: `SetQuickCondition(Sql, Params)`; code selection: `SelectQuickFilter(i)`. Example: `ufrmSlsOrders`.
- Footer totals in code: `DefineFooterColumns` → `AddFooterColumn('net_amount', atSum, '#,##0.00')`; `sys_grid_column.
  aggregate_type` rows are merged on top (same column → DB wins).
- Every visible column of `vw_*` needs a `sys_grid_column` row (only those are fetched); after adding view columns
  insert their rows, otherwise the list/helper silently lacks them.
- UI regression: `ERP/Tests/Ui/build.sh` (rebuilds `ths_erp_it` from live + seed, compiles) then
  `%TEMP%\ths_ui\bin\UiTest.exe [Module] [TfrmXxx]` drives every list + input form (dialogs auto-answered).
- `CreateInputForm` pattern: `ifmRewiev` / `ifmCopyNewRecord` → `Table.Clone`, `ifmNewRecord` → `T{Entity}.Create`,
  always pass `Self.RefreshParentGrid`.
- `DefineColumnWidths`: hide `id`, every FK id (`*_id`), `locale` with `SetColumnProperty('col', 0)`; show readable names.
- `ApplyLocalization`: `Self.Caption` + `SetColumnTitle` for every visible column via `TLangKeys`.
- Extra popup items: `PreparePopupMenu` → `AddPopupMenuSpliter; F := AddMenu(Translate(...), 'mniName', Handler);`
  and re-caption them in `ApplyLocalization`. Hide management items when `IsHelper`.
- Pre-filtered list (detail of a master): call `AddFixedFilter('fk_column', Id)` **before** `Show`; expose it as
  `SetFixed{Master}(AId, AName)`, append the name to the caption and pre-fill the FK in `CreateInputForm(ifmNewRecord)`.
- Opening from the dashboard: `Tfrm{Entity}s.Create(Self, T{Entity}Service.Create, T{Entity}.Create).Show;`
  `TfrmGridBase.Show` (reintroduced) asks `FormHost.GFormHost`: in tabbed mode (user setting `nav.tabbed`, dashboard
  toolbar checkbox) the dashboard docks the list as a tab instead of a window. Call `Show` through the grid type (not a
  `TForm` variable) or the form always opens as a window. Dialogs opened from a docked form use
  `OwnerCenterPosition(Owner)` instead of `poOwnerFormCenter` (a docked form's Left/Top are tab-relative).
  A docked form must not assign `ActiveControl` (VCL raises "Cannot focus a disabled or invisible window": the real
  parent form is the dashboard) — focus with `if X.CanFocus then X.SetFocus` (`FocusGrid`); the dashboard activates the
  tab before `Show` and copies the caption after it. UI test: `TestTabbed` in `Tests/Ui/UiTest.tpl` (account cards list).

## Master / detail (header + lines in one screen)

Reference: Sales offer — `ufrmSlsOffers` (list, `sls_offer`) → `ufrmSlsOfferDetail` (`TfrmSlsOfferDetail`, header +
lines) → `ufrmSlsOfferLine` (`TfrmSlsOfferLine`, one `sls_offer_detail` line, modal). Same for sales order,
dispatch and invoice (`ufrmSls{Orders|Dispatches|Invoices}` → `ufrmSls{X}Detail` → `ufrmSls{X}Line`) and purchasing
(`ufrmPur{Requests|Orders|Receipts|Invoices}` → `ufrmPur{X}Detail` → `ufrmPur{X}Line`), production packets
(`ufrmPrdPacket{Raw|Labour}Detail` → `…Line`), DIIB (`ufrmEInvDiibDetail` → `ufrmEInvDiibLine`; `ufrmEInvDiibLines` stays as
read-only helper list) and the BoM (`ufrmPrdBomDetail`: five tabs, line forms `ufrmPrdBom{Raw|Labour|ByProduct|PacketRaw|PacketLabour}`); conversions
(Siparişe / İrsaliyeye / Faturaya Dönüştür) open the created document in review. The separate "lines" list + popup + menu row of a migrated
document is removed (`sys_menu` row made passive).

| Kind | Unit / class | Base |
| --- | --- | --- |
| Detailed form (header + lines) | `ufrm{Master}Detail` / `Tfrm{Master}Detail` | `TfrmInputDetailedDB<TMaster, TMasterService>` (`ufrmInputDetailedDB`) |
| Line form | `ufrm{Master}Line` / `Tfrm{Master}Line` | `TfrmInputLineDB<TLine, TLineService>` (`ufrmInputLineDB`) |

- **Model:** `Table` is a **document** (header + `Lines`, see `rules/backend.md` "Documents"); the service loads the lines
  with the header (`BusinessFindById` / `FindById(…, True)` — list open, review → Güncelle, PgUp / PgDn). Lines are
  added / changed / removed **in memory** through the document service; F5 Onayla calls
  `Service.BusinessSaveWithDetails(Table, True, True)` — one transaction, then the service reloads `Table`. On error:
  rollback, temp ids restored, the form stays open. Review → Güncelle locks the header and reloads the document editable;
  Kapat rolls back. Copy mode: the base calls `Service.PrepareCopy(Table)` (list passes `Table.Clone`, a deep copy).
- **Screen part:** `Detail.Lines.TDetailSet<TLine>` (no data of its own): grid rows = non-deleted items of the list,
  colouring new (`Id < 0`) / changed on this screen; opening a line edits a copy and writes the values back into the
  same object (`DetailList.CopyEntityValues`).
- **Detailed form (`TfrmInputDetailedDB`):** DFM holds the header (`pnlContent`, **`Align = alTop`**, fixed height); the
  base adds `PanelDetails` (alClient) + `PgcDetails`. In `FormCreate` (after `inherited` + `pnlContent.Parent := PanelMain`):
  `Page := AddDetailPage(caption)`; `Lines := AddDetail<TLine>(Page, 'vw_{line}', function: Table.Lines,
  function: Service.CreateLine(Table), procedure(L): Service.AddLine(Table, L), procedure(L): Service.RemoveLine(Table, L),
  LineFormFactory)` (read `Table` inside the closures — the base replaces it);
  `Lines.Grid.AddFooterColumn(...)` **then** `Lines.Grid.BuildData`, then `Lines.Grid.SetColumnProperty(...)` (hide ids).
  Several `AddDetail` on one page = grids side by side (debit / credit); several pages = tabs (BoM raw / labour /
  by-product). Override `DetailsChanged` for header totals (`Service.Recalculate(Table)`, then show `Table` totals).
  Keys: F5 accept, F6 close, F7 add line (active page / focused grid), Enter / double click open line, Ctrl+Del delete
  line, PgUp / PgDn (review) navigate the list records (not when a detail grid has focus).
- **Line form (`TfrmInputLineDB`):** written like a `TfrmInputSimpleDB` form (`BtnAcceptClick`: controls → `Table`, then
  `inherited`); never writes to the DB, never touches the master's transaction. Override `PrepareLine` to fill derived
  values (amounts) for the grid / header totals. Factory: `TfrmXLine.Create(Self, TXLineService.Create, ALine, AMode, nil)`
  (owns its service; modes: `ifmNewRecord`, `ifmUpdate` (Delete button → line marked deleted), `ifmReadOnly` in review).
- **Computed values are never edits** (user decision 2026-10-16): amounts / quantities the user does not type (gross,
  discount, net, VAT, total, delivered / ordered quantity, linked document no) go into a `pnlTotals: TPanel` filled by
  `Detail.Totals.TTotalsPanel` (`AddRow` in `FormCreate`, `SetCaption` in `ApplyLocalization`, `SetValue(key, value,
  currency / unit)`); header forms use the same panel for document totals. Line forms: unit of measure next to quantity,
  currency next to unit price, VAT as `csDropDownList` combo of the defined rates, discount capped at 100 while typing,
  amounts recalculated live on quantity / price / discount / VAT change (`OnChange`), `PrepareLine` calls the line
  service's shared `CheckLine` (same rules as the document save).
- **Detail grid (`Detail.Grid.TDetailGrid`):** `TFDMemTable` built by RTTI from the line entity (`[Column]` name /
  `[NotMapped]` snake_case = view column names, so `sys_grid_column` layout of `vw_{line}` applies and is saved per user).
  Row state colouring (new = light blue, modified = light orange). Cell API: `OnCellStyle(Grid, Row, State, Field, var
  Style)` — back / font colour, font style, alignment, text, `ProgressPercent` bar, `ImageIndex` (dm.il16);
  `OnCustomDraw(..., var Handled)` for full custom drawing. Popup: add / open / delete / CSV.
- Older screens still use master list → popup → detail list with `SetFixed{Master}` (`ufrmSysPermissionTemplates`);
  migrate document screens to the detailed form when touched.

---

## Input form (`TfrmInputSimpleDB<>`)

Constructor: `Create(AOwner, AService, ATable, AFormMode, ARefreshGridEvent, AFormViewMode = ivmNormal, AOwnsService = False)`.
Single-record screens opened directly (e.g. application setting, decimal place) pass `AOwnsService = True`.

Methods:

| Method | Content |
| --- | --- |
| `FormCreate` | `inherited; pnlContent.Parent := PanelMain;` + `OnHelperProcess` bindings + `thsInputDataType` + `CharCase` |
| `FormShow` | `inherited;` then focus first editable control (`if X.CanFocus then X.SetFocus`) |
| `BtnAcceptClick` | copy controls → `Table` (FK ids are already set by HelperProcess), then `inherited` |
| `RefreshData` | `inherited;` copy `Table` → controls (never dereference nested objects without `Assigned`) |
| `ApplyLocalization` | `inherited;` form caption + every label/checkbox caption via `TLangKeys` |
| `InitializeInputCase` | optional (base is empty) |

The base class handles review → update (row lock + transaction), save, delete, close/rollback and permission checks.
Do not re-implement them in forms.

Permission UI (both bases, `ApplyPermissionState`): grid `BtnAdd` / `mniDuplicate` disabled without add right and
`ShowInputForm` refuses new/copy before opening; input form disables Confirm (add/update), Update (review → needs
update or delete right, so no row lock without rights) and Delete. Click handlers re-check (`EnsureAuthorized`) and
services check again in `Business*` — never rely on the UI state alone.

### Layout / DFM

- Root content panel `pnlContent: TPanel`, `Align = alClient`; labels right-aligned (`AutoSize = False`, `Alignment = taRightJustify`),
  editors beside them. `TextHeight = 14`, font Tahoma −12.
- **Height rule:** the base adds a 36 px footer (`PanelFooter`) and a ~20 px status bar under the content.
  `ClientHeight` (and `pnlContent.Height`) = lowest control bottom + 12 + 36 + 20. Otherwise the footer covers controls.
- Forms whose content panel is not `alClient` (e.g. `ufrmSysApplicationSetting.pnlMain`) need the same margin.

### Controls

Naming: `{prefix}{PascalCase DB column name}` — no separators, no Turkish:

| Control | Prefix | Example |
| --- | --- | --- |
| TEdit | `edt` | `edtCityName`, `edtSysCountryId` (FK edit) |
| TComboBox | `cbb` | `cbbGender` |
| TCheckBox | `chk` | `chkActive`, `chkIsRead` |
| TMemo | `mmo` | `mmoNotes` |
| TLabel | `lbl` | `lblCityName` (same suffix as its editor) |
| TListBox | `lbx` | `lbxItems` |
| TScrollBox | `scrlbx` | `scrlbxTranslations` (translation editors) |
| TPanel / TPageControl / TTabSheet | `pnl` / `pgc` / `ts` | `pnlContent`, `pgcMain`, `tsGeneral` |

❌ `edticerik_tipi`, `edt_ip_address`, `edtipAddress` — ✅ `edtContentType`, `edtIpAddress`

- Use the interposed `TEdit` (`Ths.Helper.Edit` in uses) for all scalar types with `thsInputDataType`:
  `itString`, `itInteger`, `itFloat`, `itDate`, `itTime`. Dates: `StrToDateDef` / `DateToStr` (global format `dd.mm.yyyy`).
- Enumerated smallint columns → `TComboBox` (`csDropDownList`), stored 1-based (`ItemIndex + 1`).
- Legacy `TSpinEdit` / `TDateTimePicker` in old forms: convert to `TEdit` + `thsInputDataType` when the form is touched.
- Read-only / FK edits: `ReadOnly = True` in the DFM.

### FK fields — `OnHelperProcess` pattern

1. `procedure HelperProcess(Sender: TObject);` on the form; in `FormCreate`: `edtXxxId.OnHelperProcess := HelperProcess;`
2. In the handler: check `Sender is TEdit`, match `(Sender as TEdit).Name`, create the helper **output** form
   `Tfrm{Entity}s.Create(LEdit, T{Entity}Service.Create, T{Entity}.Create)`, set `IsHelper := True`, `ShowModal`.
3. After close: `if DataTransfer then` → `CleanAndClose` ? (FK := 0, display := '', `Clear`) : (FK := `Helper.Table.Id`,
   display name := readable field, edit text := display name). Free the helper in `finally`.
4. Keep the display text in a `[NotMapped]` entity property (e.g. `Table.PermissionName`) so `RefreshData` shows it.
5. Helper output form units go into the **implementation** `uses`, one line each, commented `// Tfrm…s helper output form`.

```pascal
implementation
{$R *.dfm}
uses
  ufrmSysRegions;   // TfrmSysRegions helper output form
```

---

## Dashboard registration (`Forms/Core/Input/ufrmDashboard`)

- DFM: `TAction` in `actlstMain` (`Category = 'System'`, `OnExecute = act{name}Execute`) + `TMenuItem` with `Action = …`
  in the proper menu. PAS: published fields, handler, uses entry, caption in `ApplyLocalization` via `TLangKeys.TDashboard`.
- DFM components must have matching PAS fields (and vice versa).
- **Menu tree + screen code (mandatory for every new screen):** insert a `sys_menu` row (`menu_code`, `menu_key`,
  `action_name` = the TAction name, `sys_permission_id` = read permission or NULL) + `sys_menu_translation` for every
  `sys_language` (`menu_name`, search `keywords`). Without it the screen is missing from the left tree, its action stays in
  its DFM state (no permission check) and its caption gets no code.
  - Code `MMGGSS`: module `MM0000` (10 System, 20 Accounting, 30 Finance, 40 Stock, 50 Purchasing, 60 Sales, 70 Production,
    80 Employee), group `MMGG00` (01 cards, 02 transactions, 03 documents, 04 document lines, 05 list settings, 08 reports,
    09 settings), screen `SS` 01-99. `parent_code` is generated; the parent row must exist. **Codes are permanent** — never
    renumber or reuse a deleted screen's code (manuals / support refer to them).
  - Every dashboard action runs through `actlstMain.OnExecute` → `TScreenCodes.RunWithCode` (`Forms/Core/Base/ScreenCode.pas`):
    the opened form's caption ends with ` [300301]`; non-modal forms opened from it (input form, popup detail list)
    inherit the code, modal helpers / dialogs do not. Captions may be reassigned freely (language change, fixed filter):
    a `WM_SETTEXT` hook keeps the code at the end.
  - Left tree: `Forms/Core/Base/NavigationTree.pas` (`TNavMenuPanel`; search by name / keywords / parent names / code
    prefix, Turkish letters folded; Ctrl+K / Ctrl+F focuses search, Esc clears, code + Enter opens). Module icons /
    colours: `ModuleIcon` / `ModuleColor` there (add one when a new module `MM` appears).
  - **Ctrl+K anywhere** (`TApplicationEvents.OnShortCut` in the dashboard): on the dashboard it focuses the tree search,
    elsewhere it opens `TNavCommandPalette` (modal; same search via `TNavMenuPanel.Search`; skipped while a modal is open).
  - Panel width / visibility / expanded folders are per user (`sys_user_setting`): loaded once in `SetSession`, saved in
    `TfrmDashboard.DoClose` (the connection is gone by the time forms are destroyed).
  - Menu rows are maintained in Sistem > Ayarlar > Menü Ekranları (`TfrmSysMenus`, 100910): names / keywords per language,
    active flag, read permission. Code / key / action are entered only for new rows.
  - With an empty search the tree starts with shortcut folders **Favorites** and **Recently Used** (last 7 opened screens);
    their nodes have negative `Data` (`IsShortcutNode`). Right click / Ctrl+D toggles a favorite (`OnToggleFavorite` →
    `TSysMenuService.SetFavorite`); every dashboard action registers the open (`RegisterOpen` + `MarkOpened`).
