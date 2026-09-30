---
paths:
  - "ERP/BackEnd/**/Service/*.pas"
  - "ERP/BackEnd/Core/UnitOfWork.pas"
  - "ERP/BackEnd/Core/Base/UnitOfWork.pas"
  - "ERP/BackEnd/Core/UserContext.pas"
  - "ERP/Database/**"
  - "ERP/Forms/System/**"
---

# Authorization Rules

## Model

- **One permission code per form / resource.** Code = `sys_permission.permission_code`, Delphi constant
  `PERMISSION_{MODULE}_{ENTITY}` in `BackEnd/System/Service/SysPermission.Service.pas`.
- **Templates:** `sys_permission_template` + `sys_permission_template_right` (read/add/update/delete/special per permission).
  Examples: manager, sales, production, purchasing. Inactive templates grant nothing.
- **User ↔ template:** `sys_user_permission_template` — a user may have several templates; their rights are OR-merged.
- **Overrides:** `sys_access_right` per user + permission:
  - `is_*` = extra grant on top of templates
  - `deny_*` = revoke even if a template grants it (deny always wins)
  - granting and denying the same flag is a validation error
- **Effective right** (`vw_sys_user_effective_permission`) = (any template OR `is_*`) AND NOT `deny_*`.
- `super_user` bypasses every check (`TUserContext.IsSuperUser`).
- Check path: `Service.Business*` → `UoW.EnsureAuthorized(code, type, APermissionControl)` →
  `TSysAccessRightService.IsAuthorized` → `TSysAccessRightRepository.GetEffectivePermission`.

## Code ranges

| Range | Area |
| --- | --- |
| 1, 2 | framework placeholders — **never assign to a service** |
| 1000–1008 | System definitions (city, country, region, currency, uom group, uom, language, decimal place, address) |
| 1020–1029 | Employee (1021 employee card + details: driver license, language, address; 1022 type, 1023 section, 1024 unit, 1025 task, 1026 shuttle, 1027 language, 1029 license type; 1028 free — language level is a fixed smallint option) |
| 1030–1039 | Account (1031 account card + addresses, 1032 bank + branches, 1033 group, 1034 region, 1035 account type, 1036 ownership type, 1037 company legal form; 1030 legacy "account-card-settings", unused) |
| 1040–1049 | Stock (1041 stock card + image + kind info, 1042 transaction, 1043 group, 1044 warehouse, 1045 product type, 1046 kind family, 1047 kind property, 1048 stock summary; 1040 free) |
| 1060–1069 | Production / BoM |
| 1100–1199 | System administration (1100 user … 1110 view table) |
| 3000+ | Accounting (3001 exchange rate, 3002 account plan, 3003 tax rate, 3004 transfer code, 3005 voucher + details) |
| 357000+ | Sales (offer / order) |

Detail entities share their master's code (e.g. template rights use `PERMISSION_SYS_PERMISSION_TEMPLATE`).

Read access: `TfrmDashboard.ApplyActionPermissions` maps every dashboard action to its code and disables it without
read right (one query: `TSysAccessRightService.GetReadablePermissionCodes`); `TfrmGrid.FormShow` refuses to open the
list without read right (menus, popups and FK helper lists alike). New screens: add a `SetAction(...)` line.
Consequence: picking an FK value needs read right on the referenced list (e.g. employee → type/unit/task).

## Adding a new protected resource

1. Pick a free code in the module range; add the constant to `SysPermission.Service.pas`.
2. DB: insert `sys_permission` (`permission_code`, `permission_key` kebab-case, `sys_permission_group_id`) and
   `sys_permission_translation` rows for tr-TR, en-US, de-DE (fr-FR when present in `sys_language`).
3. Service constructor: `Self.PermissionCode := PERMISSION_…;` (add `SysPermission.Service` to implementation uses).
4. Optionally add the new permission to the relevant seed templates in the same transaction; add the
   `sys_access_right` rows for all users (all flags false). Refresh `db_schema.sql` + `db.dump`.
5. Verify with `SELECT * FROM vw_sys_user_effective_permission WHERE sys_user_id = …` inside `BEGIN … ROLLBACK`.

Free codes: 1030 and 1040 (legacy "*-settings" permissions were deleted).
