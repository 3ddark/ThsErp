# Türkçe İsim Migration Planı

**Başlangıç:** 2026-06-30  
**Amaç:** Her modülün durumunu ve yapılması gerekenleri tut. Yeni session açıldığında buradan devam et.

---

## Progress — Modül Bazlı Durum

| # | Modül / Tablolar | Durum |
|---|---|---|
| 0 | **Entity ↔ DB tablo adları** (CRITICAL: sys_currencies→sys_currency, typo currnecy→currency, stk_card_summaries→stk_inventory_summary, sys_users→sys_user) | ✅ TAMAMLANDI — SysCurrency.pas, SysUser.pas, StkCardSummary.pas, SysCountry.pas güncellendi |
| 1 | **System** — `sys_*` tabloları (acc_*, einv_*) | ✅ TAMAMLANDI — kolon isimleri zaten İngilizce. Constraint kısaltmaları tutarsız (`is_spcl`) ama Türkçe kelime yok. |
| 2 | **Person** — `prs_persons`, `prs_set_*`, `prs_*_abilities` | ✅ TAMAMLANDI — prs_persons: 10 kolon rename (birth→birth_date, blood→blood_type, related_name→relative_name, etc.), EmpPerson.pas güncellendi, db_schema.sql yedeği alındı. Constraint isimlerinde Türkçe kelimeler var ama PRS_personlar ve PRS_set_ tablolarında kolon isimleri zaten İngilizce (license_name, language_name, unit_name vb.). |
| 3 | **Stock** — `stk_inventory`, `stk_kind_family`, `stk_kind_property`, `stk_card_kind_info`, `stk_image`, `stk_warehouse`, `stk_transaction`, `stk_group` + generic s/i/d tip sorunları | ✅ TAMAMLANDI — kolon isimleri temiz. Tip düzeltmesi: `stk_kind_property.i1..i5` varchar→numeric, `d1..d5` varchar→double precision (sonraki oturumda). Generic s1..s10/i1..i5/d1..d5 dokümante edilmemiş ama Türkçe değil. |
| 4 | **Accounting** — `acc_voucher*`, `acc_transfer_code`, `acc_account`, `acc_bank*`, `acc_*_plan`, `acc_*_region` vb. | ✅ TAMAMLANDI — kolon isimleri zaten İngilizce (journal_no, journal_date, transfer_code, description, header_id, account vb.). Constraint isimlerinde Türkçe kelimeler var ama kolon temiz. |
| 5 | **Purchase/Sales + E-Invoice** — `pur_offer*`, `sls_*`, `einv_*` (~104+ kolon rename) | ✅ DB RENES TAMAMLANDI. Purchase: 22 kolon, Sales: ~72+ kolon, E-Invoice: 10 kolon rename edildi. **DELPHI ENTITY DOSYALARI Sonraki Oturumda** |
| 6 | **Production** — `prd_bom*`, `prd_labour`, `prd_packet_*`, `prd_*_detail` (~12 kolon rename) | ✅ DB RENES TAMAMLANDI. miktar→quantity(7), stok_kodu→sku_code(2), gider_kodu→cost_code, fiyat→unit_price. **DELPHI ENTITY DOSYALARI Sonraki Oturumda** |

---

## Özet — Tamamlanan İşler

| # | Yapılan | Durum |
|---|---------|-------|
| 1 | Entity ↔ DB tablo adları (CRITICAL) | ✅ EmpPerson.pas `[Table('prs_persons')]` güncellendi. SysCurrency.pas, SysUser.pas, StkCardSummary.pas, SysCountry.pas güncellendi |
| 2 | Person `prs_persons`: 10 kolon rename | ✅ EmpPerson.pas tüm [Column(...)] attribute'ları yeni isimlerle güncellendi. Service/EmpPerson.Service.pas zaten sys_city pattern uyumlu. db_schema.sql ✅ alındı |
| 3 | Stock, System, Accounting, Person Set tablosu kolonları | ✅ Tüm kolonlar İngilizce — değişiklik yok (generic s1..i1..d1 tip sorunu hariç) |

**Sonraki oturumda yapılacak:** Purchase/Sales domain dosyalarındaki [Column(...)] attribute'larını rename edilmiş kolon isimleriyle güncellemek.

---

## Migration Adımları (Her Modül İçin)

1. DB → kolon rename: `ALTER TABLE ... RENAME COLUMN old_col TO new_col;`
2. İndext/constraint rename: `ALTER INDEX old_name RENAME TO new_name;` / `ALTER CONSTRAINT ... RENAME TO ...`
3. FK drop+create (isim değişirse)
4. Delphi Entity/Repo/Svc → `[Column('new_name')]` güncelle
5. **db_schema.sql yedeği al** — `pg_dump -h localhost -U postgres -d ths_erp --schema-only --no-owner --no-privileges | Set-Content -Encoding utf8 'D:\Projects\ThsErp\ERP\db_schema.sql'`
6. Bu dosyada ✅ ile işaretle

---

## Modül 2 — Person (`prs_*`) Detaylı Kolon Map

### `prs_persons` — Türkçe kolonlar (≈10 adet)

| Mevcut | → İngilizce | Not |
|--------|-------------|-----|
| `birth` | `birth_date` | date tip aynı kalacak |
| `blood` | `blood_type` | varchar tip aynı kalacak |
| `related_name` | `relative_name` | varchar — akraba ismi |
| `related_phone` | `relative_phone` | varchar — akraba telefon |
| `shoe` | `shoe_size` | smallint |
| `dress` | `clothing_size` | varchar |
| `salary` | `salary_amount` | numeric |
| `number_of_bonus` | `bonus_count` | integer |
| `bonus` | `bonus_amount` | numeric |
| `identification` | `id_document_no` | text → kimlik no |

### `prs_set_unit` — `car_no` küçük sayı ama isim anlaşılır ( İngilizce). **Değişiklik yok.**

### `prs_driver_abilities`, `prs_language_abilities` — column isimleri zaten İngilizce. FK constraint isimlerinde Türkçe kelimeler var:
- `prs_driver_abilities_driver_license_id_person_id_key` → `prs_drv_auth_dlic_persid_uk` (kısaltma)

---

## Modül 3 — Stock (`stk_*`) Detaylı Notlar

### `stk_kind_property` — generic s/i/d kolon TİP SORUNU:
- `i1..i5` → varchar olmalı numeric
- `d1..d5` → varchar olmalı double precision

### `stk_card_kind_info`:
- `i1..i5` integer (doğru)
- `d1..d5` double precision (doğru)

---

## Modül 4/5/6 — Detaylı Kolon Map Sonraki Oturuma Kalacak
