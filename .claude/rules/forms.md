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
- Constructor: `Create(AOwner, AService, ATable, ACreateNewBase = True, AUseHelper = False)`; the grid owns and frees
  service and table.
- Overrides used by every list form: `CreateInputForm`, `DefineColumnWidths`, `FormShow`, `ApplyLocalization`.
  Optional: `DefineFooterColumns`, `SetSelectedItem` (when nested display objects must be filled), `PreparePopupMenu`.
  Base `SetSelectedItem` also fills `[NotMapped]` string props from the same-named snake_case grid column
  (`UomName` ← `uom_name`) — the column must be fetched (`sys_grid_column` row for the view).
- Read-only list (no input form): `CreateInputForm` returns nil and `BtnAdd` hidden; base `ShowInputForm` skips nil.
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

## Master / detail

There is **no** `TfrmInputDetail` / `TfrmInput<T>` base in the code base (planned). Current pattern:
master list → popup item → detail list opened with `SetFixed{Master}` (see `ufrmSysPermissionTemplates` → rights / users).

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
