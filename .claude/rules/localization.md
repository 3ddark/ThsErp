---
paths:
  - "ERP/BackEnd/Core/Base/LocalizationManager.pas"
  - "ERP/Resource/Localization/*.json"
  - "ERP/Forms/**/*.pas"
  - "ERP/BackEnd/**/Exception/*.pas"
---

# Localization Rules

- All user-visible text goes through `TLocalizationManager.Translate(TLangKeys.T{Area}.{Key}, 'English default')`.
  Formatted: `Translate(Key, [args], 'Default %s')` or `Format(Translate(Key, 'Default %s'), [args])`.
- Keys are constants in the `TLangKeys` record inside `BackEnd/Core/Base/LocalizationManager.pas`, one nested record per
  entity/area (`TSysCity`, `TEmpEmployee`, `TDashboard`, `TGeneral`, `TMessage`, …). No string-literal keys in new code
  (legacy forms still use literals like `'emp_person.lbl_name'` — replace when touched).
- Key format: `{table_or_area}.{kind}_{name}` — `title_singular`, `title_plural`, `col_{column}`, `lbl_…`,
  `popup.{action}`, `msg.{message}`, `{rule}_unique`. Column captions reuse `col_{db_column}`.
- Every new key must be added to **all** files in `Resource/Localization/` (tr-TR, en-US, de-DE, fr-FR) in the same change.
  Add only missing keys; never reorder or rewrite existing entries.
- Forms re-apply captions in `ApplyLocalization` (language can change at runtime from the dashboard menu).
- DB-side names (permissions, groups, units, countries …) are translated through `*_translation` tables, not JSON
  (see `rules/database.md` — locale strategy).
- `GlobalSettings.ini [SupportedLanguages]` is written from `sys_language` at login; a language listed there needs both a
  JSON file and DB translations (currently de-DE / fr-FR DB translations are incomplete).
