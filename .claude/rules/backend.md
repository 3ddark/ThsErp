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

## Exception

```pascal
E{Entity}Exception = class(EAppException);
E{Entity}Exception{Reason} = class(E{Entity}Exception)
protected
  class function GetMessage: string; override;   // TLocalizationManager.Translate(TLangKeys.T{Entity}.{Key}, 'English default')
end;
```

Raise with `raise E{Entity}Exception{Reason}.Create;`. Messages with parameters: `Exception.Create(Format(Translate(...), [...]))`.
