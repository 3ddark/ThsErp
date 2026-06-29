# THS ERP — Yapay Zeka Beyin Dosyası

**Son güncelleme:** 2026-06-29  
**DB durumu:** ✅ Şema migration tamamlandı (tablo/kon/idx/cnsq/fn)  
**Delphi durumu:** prs→emp rename %85 tamamlandı — Core Prs+Person Domain+Repo+Service+Forms bitmiş, kalan: DFM component rename + ufrmDashboard event handler + Ths.dpr/DCCReference sync

---

## 📊 Proje Genel Durumu

| Kategori | Durum |
|---|---|
| Toplam Delphi dosyası | ~773 (.pas + .dfm) |
| BackEnd modül sayısı | 10 (System, Person, Stock, Account, Order, Offer, Invoice, DataBank, Erp/Tek, Uretim) |
| Core framework | ✅ Entity/Repository/Service pattern (generic) |
| Core Prs → Emp table classes | ✅ 11 dosya bitmiş |
| Person Domain entityleri | ✅ 11 dosya emp_ prefix ile bitmiş |
| Person Repository | ✅ 11 dosya bitmiş |
| Person Service | ✅ 11 dosya bitmiş |
| Person Forms (Input) | 🔻 13/27 .pas bitmiş, 14 .dfm kaldı |
| Person Forms (Output/DbGrid) | 🔻 14/28 .pas bitmiş, 14 .dfm kaldı |
| Ths.dpr uses clause | 🔻 güncellenmeli |
| Ths.dproj DCCReference | 🔻 güncellenmeli |
| ufrmDashboard event handlers | 🔻 actset_prs_* → actsys_emp_* |
| Stock Domain/Repo/Service | ✅ 51 dosya TEntity pattern ile bitmiş |
| System SYS entities | 🔻 21 tablo entity mapping SQL'e eşleştirilmeli |
| acc_ prefix migration | ✅ ch_→acc_, set_ch_→acc_set_ tamamlandı |
| prs_set_ prefix migration | ✅ set_prs_*→prs_set_* tamamlandı |
| prod → prd migration | ✅ tamamlanmış |
| stk_inventory constraints | 🔻 23 eski isim temizliği (opsiyonel) |

---

## 🏗️ Proje Yapısı

```
ThsERP/
├── ERP/                          ← Ana Delphi projesi
│   ├── Ths.dpr                   ← Program entry point
│   ├── Ths.inc                   ← Derleme tanımları (THSERP, MIGRATE, CRUD_MODE_PURE_SQL)
│   ├── BackEnd/                  ← Business logic (~207 .pas)
│   │   ├── System/               ← SYS entities (Domain+Repo+Service, 45 dosya)
│   │   ├── Person/               ← EMP entities (Domain+Repo+Service, 33 dosya)
│   │   ├── Stock/                ← STK entities (Domain+Repo+Service, 57 dosya)
│   │   ├── Account/              ← Muhasebe modülü (13 dosya)
│   │   ├── Order/                ← Sipariş modülü (4 dosya)
│   │   ├── Offer/                ← Teklif modülü (6 dosya)
│   │   ├── Invoice/              ← Fatura modülü
│   │   ├── DataBank/             ← Veri bankası tabloları (5 dosya)
│   │   ├── Erp/Tek/              ← Alış teklif modülü
│   │   ├── Uretim/               ← Üretim modülü (4 dosya, prd_* tablo mapping)
│   │   ├── Core/
│   │   │   ├── Base/New/         ← Entity, Repository, Service, UnitOfWork (generic base)
│   │   │   └── Prs/              ← Core table classes (EMP patternine geçiş tamamlandı)
│   │   └── Tools/                ← SynPDF ve yardımcı sınıflar
│   ├── Forms/                    ← UI layer (~503 dosya .pas+.dfm)
│   │   ├── Core/                 ← Temel form sınıfları (ufrmBase, ufrmGrid, vb.)
│   │   ├── InputForms/
│   │   │   ├── Core/Prs/         ← Person input forms (13 .pas bitmiş, 14 .dfm kaldı)
│   │   │   ├── Stock/
│   │   │   ├── Account/
│   │   │   └── Uretim/
│   │   ├── OutputForms/
│   │   │   └── DbGrid/Core/Prs/  ← Person grid forms (14 .pas bitmiş, 14 .dfm kaldı)
│   │   └── System/
│   ├── Settings/
│   └── Tools/
├── ERPDevWizard/                 ← Geliştirici yardımcı aracı
├── ai.md                         ← Bu dosya
└── README.md
```

---

## 🏗️ Mimari Katmanlar (Her Module için)

```
ERP/BackEnd/{Module}/
├── Domain/           ← TEntity + [Table] + [Column] attribute mapping
├── Repository/       ← IRepository<T> generic CRUD + custom query'ler
└── Service/          ← ICrudService<T>, business logic + authorization
```

**Person modülü:**
- Domain: `BackEnd/Person/Domain/` — 11 entity (EmpPerson, EmpDriverLicence, EmpUnit, vb.)
- Repository: `BackEnd/Person/Repository/` — 11 repo
- Service: `BackEnd/Person/Service/` — 11 service

**Core Prs → Emp tablo sınıfları:**
- Location: `BackEnd/Core/Prs/` — 11 dosya ( tamamlandı)
- TableName: `emp_*` prefix ile eşleşiyor

---

## ✅ Tamamlanan Büyük İşler

### Person Domain/Repo/Service Refactor (commit 705744b, 96350ac, 98ad211)
- **Önce:** Person/ kökünde 12 dosya karışık (PrsPerson.pas, PrsDriverLicence.pas, vb.)
- **Sonra:**
  ```
  BackEnd/Person/
  ├── Domain/     ← EmpPerson.pas, EmpDriverLicence.pas, EmpUnit.pas, vb. (11 dosya)
  ├── Repository/ ← EmpPerson.Repository.pas, vb. (11 dosya)
  └── Service/    ← EmpPerson.Service.pas, vb. (11 dosya)
  ```
- Ths.dpr path'leri güncellenmeli (hala Prs* referansları var)

### Core Prs → Emp Table Classes (commit 98ad211)
- `BackEnd/Core/Prs/` içindeki tüm klas adları ve class isimleri TPrs*→TEmp*
- TableName stringleri `prs_*`→`emp_*`
- Cross-module refs: Order, Offer, ERP-Tek, Account güncellenmeli

### Stock Domain/Repo/Service Refactor
- 51 dosya TEntity pattern ile oluşturuldu, eski 15 TTable dosyası silindi
- Ths.dpr path'leri güncellendi (51 entry)

### DB Şema Migrations (Tamamlandı)
| Kategori | Detay |
|---|---|
| Tablo isimleri (stk_/sys_) | ✅ 30/30 tablo tekil form + İngilizce |
| Kolon isimleri (stk_/sys_) | ✅ Türkçe → İngilizce |
| Index/constraint/sequence | ✅ Tüm isimler güncellendi |
| Fonksiyon isimleri | ✅ 10 fonksiyon `sp*`→`fn_*` |
| acc_ prefix | ✅ ch_→acc_, set_ch_→acc_set_ (11 tablo) |
| prs_set_ prefix | ✅ set_prs_*→prs_set_* (8 tablo) |
| prod_* → prd_* | ✅ Üretim modülü migration |

---

## 🔜 Kalan İşler — Öncelik Sırasına Göre

### Öncelik 1: DFM Component Rename (~28 dosya)

**Input Forms DFM (14 dosya):**
```
Forms/InputForms/Core/Prs/ufrmPrsPersonel.dfm          → component rename gerekli
Forms/InputForms/Core/Prs/ufrmPrsEhliyet.dfm
Forms/InputForms/Core/Prs/ufrmPrsLisanBilgisi.dfm
Forms/InputForms/Core/Prs/ufrmSetPrsAyrilmaNedeni.dfm  → component: btnprs_→btnemp_
Forms/InputForms/Core/Prs/ufrmSetPrsAyrilmaTipi.dfm
Forms/InputForms/Core/Prs/ufrmSetPrsBirim.dfm
Forms/InputForms/Core/Prs/ufrmSetPrsBolum.dfm
Forms/InputForms/Core/Prs/ufrmSetPrsEhliyet.dfm
Forms/InputForms/Core/Prs/ufrmSetPrsGorev.dfm
Forms/InputForms/Core/Prs/ufrmSetPrsLisan.dfm
Forms/InputForms/Core/Prs/ufrmSetPrsLisanSeviyesi.dfm
Forms/InputForms/Core/Prs/ufrmSetPrsPersonelTipi.dfm
Forms/InputForms/Core/Prs/ufrmSetPrsTasimaServisi.dfm
Forms/InputForms/Core/Prs/ufrmSetEmpEducationLevel.dfm  → component: prs_→emp_
```

**Output Forms DFM (14 dosya):**
```
Forms/OutputForms/DbGrid/Core/Prs/ufrmPrsPersoneller.dfm
Forms/OutputForms/DbGrid/Core/Prs/ufrmPrsEhliyetler.dfm
Forms/OutputForms/DbGrid/Core/Prs/ufrmPrsLisanBilgileri.dfm
Forms/OutputForms/DbGrid/Core/Prs/ufrmSetPrsAyrilmaNedenleri.dfm
... (11 daha)
```

> **DFM değişiklikleri:** btnprs_*→btnemp_*, actset_prs_*→actsys_emp_*, mni/pri/prs_*→mnp/actprv*/emp_*

### Öncelik 2: ufrmDashboard Event Handler Update
```pas
Forms/InputForms/Core/ufrmDashboard.pas:
  actset_prs_birimlerExecute → actsys_emp_unitExecute
  TPrsPersonel → TEmpPersonnel
  (tüm method/event isimleri güncellenmeli)
```

### Öncelik 3: Ths.dpr + Ths.dproj Sync
- uses clause: `Prs* in '...'` → `Emp* in '...'` (path de değişecek)
- DCCReference path'leri yeni dosya isimleriyle eşleşmeli

### Öncelik 4: Cross-module References
```pas
BackEnd/Order/Ths.Database.Table.SatSiparis.pas     → uses EmpPersonnel
BackEnd/Offer/Ths.Database.Table.SatTeklif.pas       → uses EmpPersonnel
BackEnd/Erp/Tek/Ths.Database.Table.AlsTeklifler.pas  → uses EmpPersonnel
BackEnd/Account/Ths.Database.Table.ChHesapKarti.pas  → TPrsPersonel → TEmpPersonnel
```

### Öncelik 5: SYS Entity SQL Mapping
21 SYS entity'nin TableName + Column mapping'i güncellenmeli (ai.md'deki tablo referanslı):
- `TSysCity` → `[Table('sys_city')]`, city_name→name, car_plate_code→plate_code
- `TSysCountry` → `[Table('sys_country')]`, country_name→name, country_code→code
- `TSysDay` → `[Table('sys_day')]`, day_name→name
- `TSysMonth` → `[Table('sys_month')]`, month_name→name
- `TSysPermissionGroup` → `[Table('sys_permission_group')]`
- `TSysPermission` → `[Table('sys_permission')]`
- `TSysRegion` → `[Table('sys_region')]`
- vb.

### Öncelik 6: STK Entity SQL Mapping
```
TStkGroup.group_name → name
TStkImage.stk_card_id → card_id
TStkKartCinsBilgileri → StkCardKindInfo (dosya+class rename)
TStkCardSummary → StkInventorySummary (dosya+class rename)
```

---

## 💡 DB Bağlantı Bilgileri

- **Host:** localhost
- **Kullanıcı:** postgres
- **Şifre:** qwe
- **Database:** ths_erp
- **Toplam tablo:** (pg_dump ile 157 KB schema)
- **Schema:** public

### Komutlar

```powershell
# Schema dump
$env:PGPASSWORD = "qwe"
& pg_dump -h localhost -U postgres -s ths_erp > 'D:\Projects\ThsErp\ERP\db_schema.sql'

# Fonksiyon test
PGPASSWORD=qwe psql -h localhost -U postgres -d ths_erp -t -c "SELECT * FROM fn_default_product_type_id();"

# Tablo kontrolü
PGPASSWORD=qwe psql -h localhost -U postgres -d ths_erp -t -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;"
```

---

## 📋 Özet — Durum Yüzdesi

| Alan | İlerleme |
|---|---|
| DB schema migrations | ✅ 100% |
| Core Prs→Emp table classes | ✅ 100% |
| Person Domain/Repo/Service | ✅ 100% |
| Stock Domain/Repo/Service | ✅ 100% |
| prs_* → emp_* (Delphi kod) | 🔻 ~85% |
| DFM component rename | 🔻 ~0% (28 dosya)


---

## 🏗️ Proje Mimari Standartları

Her entity için **Entity → Repository → Service** katmanlı mimari uygulanır:
```
ERP/BackEnd/{Module}/
├── Domain/           ← TEntity + [Table] + [Column] attribute ile DB mapping
├── Repository/       ← IRepository<T> generic, CRUD ve custom query'ler
└── Service/          ← ICrudService<T>, business logic + authorization
```

Ths.dpr içinde `{$I Ths.inc}` → `SearchPath` güncellenmeli:
- `ERP/BackEnd/{Module}/Domain/`
- `ERP/BackEnd/{Module}/Repository/`
- `ERP/BackEnd/{Module}/Service/`

---

## ✅ Tamamlananlar — Delphi Kod

### Person/ Klasörü Yeniden Yapılandırıldı (commit: `705744b`, `96350ac`)
- **Önce:** Person/ kökünde 12 dosya karışık
- **Sonra:**
  ```
  ERP/BackEnd/Person/
  ├── Domain/          ← 10 entity
  ├── Repository/      ← 11 repo
  └── Service/         ← 11 service
  ```
- Ths.dpr path'leri güncellendi (37 entry)

### Stock/ Klasörü Yeniden Yapılandırıldı (Bu session'da yapıldı)
- **Önce:** Stock/ kökünde 15 dosya TTable pattern ile karışık
- **Sonra:**
  ```
  ERP/BackEnd/Stock/
  ├── Domain/              ← 17 entity (TEntity pattern)
  ├── Repository/          ← 17 repo
  └── Service/             ← 17 service
  ```
- 51 dosya oluşturuldu, eski 15 TTable dosyası silindi, Ths.dpr güncellendi
- **Entity listesi:** SetStkBarkodHazirlikDosyaTuru, SetStkBarkodSeriNoTuru, SetStkBarkodTezgah, SetStkBarkodUrunTuru, SetStkHareketTipi, SetStkStokTipi, SetStkUrunTipleri, StkAmbarlar, StkCinsAilesi, StkCinsOzellikleri, StkGruplar, StkKartCinsBilgileri, StkKartlar, StkStokGrubuTuru, StkStokHareketi, SetChFirmaTuru, SetChFirmaTipleri
- **Önemli:** StkKartCinsBilgileri ve StkKart arasında FK ilişkisi var (StkKartCinsBilgileri.StkKartID → StkKartlar.Id)

---

## ✅ Tamamlananlar — SQL Entity Doğrulamaları

| Tablo | Entity | Durum |
|---|---|---|
| `sys_access_rights` | TSysAccessRight | ✅ FK (Permission, User) |
| `sys_addresses` | TSysAddress | ✅ neighborhood typo düzeltildi |
| `sys_application_settings` | TSysApplicationSetting | ✅ app_currency → TSysCurrency FK |
| `sys_countries` | TSysCountry | ✅ Constructor default FIsEuMember:=False |
| `sys_currencies` | TSysCurrency | ✅ currnecy typo + Required() |
| `sys_days` | TSysDay | ✅ MaxLength(16) + Required() |
| `sys_decimal_places` | TSysDecimalPlace | ✅ Word→SmallInt + default değerler |
| `sys_grid_columns` | TSysGridColumns | ✅ table_name/column_name 64→128, bar_text_coolor SQL typo eşleştirildi |
| `sys_grid_filters` | TSysGridFilters | ✅ MaxLength(32) eklendi |
| `sys_grid_sorts` | TSysGridSorts | ✅ TableName→Table attribute, class adı düzeltildi |
| `sys_gui_contents` | TSysGuiContent | ✅ Required/MaxLength + constructor defaults |
| `sys_languages` | TSysLanguage | ✅ TSysCurrency→TSysLanguage class adı düzeltildi |
| `sys_months` | TSysMonth | ✅ Column attribute + MaxLength(16) + Required |
| `sys_permission_groups` | TSysPermissionGroup | ✅ MaxLength(64) + Required |
| `sys_permissions` | TSysPermission | ✅ permission_code Required eklendi |
| `sys_regions` | TSysRegion | ✅ Constructor eklendi |
| `sys_uom` | TSysUom | ✅ Constructor defaults (FDecimal:=False, FMultiplier:=1) |
| `sys_uom_types` | TSysUomType | ✅ Constructor eklendi |
| `sys_users` | TSysUser | ✅ Tüm NOT NULL Required + constructor defaults |
| `set_prs_person_types` | TSetPrsPersonType | ✅ Repository/Service oluşturuldu |

---

## ✅ Tamamlananlar — PostgreSQL DB Değişiklikleri

### stk_ Tabloları (9 tablo)

| Eski SQL Adı | Yeni SQL Adı | Kolon Değişiklikleri |
|---|---|---|
| `stk_groups` | → `stk_group` | `group_name` → `name` |
| `stk_images` | → `stk_image` | `stk_card_id` → `card_id` |
| `stk_kind_families` | → `stk_kind_family` | *(değişiklik yok)* |
| `stk_kind_properties` | → `stk_kind_property` | `desciption` → `description` |
| `stk_kart_cins_bilgileri` | → `stk_card_kind_info` | `stk_kart_id`→`card_id`, `cins_id`→`kind_id`, `deger`→`value` |
| `stk_transactions` | → `stk_transaction` | `stock_code`→`sku`, `from_warehouse_id`→`from_warehouse`, `to_warehouse_id`→`to_warehouse`, `opening_stock`→`is_opening` |
| `stk_warehouses` | → `stk_warehouse` | *(değişiklik yok)* |

### sys_ Tabloları (21 tablo)

| Eski SQL Adı | Yeni SQL Adı | Kolon Değişiklikleri |
|---|---|---|
| `sys_access_rights` | → `sys_access_right` | *(değişiklik yok)* |
| `sys_addresses` | → `sys_address` | *(değişiklik yok)* |
| `sys_application_settings` | → `sys_application_setting` | *(değişiklik yok)* |
| **`sys_cities`** | → **`sys_city`** | `city_name` → `name`, `car_plate_code` → `plate_code` |
| **`sys_countries`** | → **`sys_country`** | `country_name` → `name`, `country_code` → `code` |
| `sys_currencies` | → `sys_currency` | *(değişiklik yok)* |
| **`sys_days`** | → **`sys_day`** | `day_name` → `name` |
| `sys_decimal_places` | → `sys_decimal_place` | *(değişiklik yok)* |
| `sys_grid_column_titles` | → `sys_grid_column_title` | *(değişiklik yok)* |
| `sys_grid_columns` | → `sys_grid_column` | *(değişiklik yok)* |
| `sys_grid_filters` | → `sys_grid_filter` | *(değişiklik yok)* |
| `sys_grid_sorts` | → `sys_grid_sort` | *(değişiklik yok)* |
| `sys_gui_contents` | → `sys_gui_content` | *(değişiklik yok)* |
| `sys_languages` | → `sys_language` | *(değişiklik yok)* |
| **`sys_months`** | → **`sys_month`** | `month_name` → `name` |
| **`sys_permission_groups`** | → **`sys_permission_group`** | `group_name` → `name` |
| **`sys_permissions`** | → **`sys_permission`** | `permission_name`→`name`, `permission_code`→`code`, `permission_group_id`→`group_id` |
| **`sys_regions`** | → **`sys_region`** | `region_name` → `name` |
| `sys_uom_types` | → `sys_uom_type` | *(değişiklik yok)* |
| `sys_users` | → `sys_user` | *(değişiklik yok)* |


### acc_/set_ch_ Tabloları (11 tablo — prefix ch_→acc_, set_ch_→acc_set_)

| Eski SQL Adı | Yeni SQL Adı | Kolon Değişiklikleri |
|---|---|---|
| `ch_bank` | → `acc_bank` | `banka_adi`→`name` |
| `ch_bank_branch` | → `acc_bank_branch` | `banka_id`→`bank_id`, `sube_kodu`→`branch_code`, `sube_adi`→`branch_name`, `sehir_id`→`city_id` |
| `ch_region` | → `acc_region` | `bolge`→`name` |
| `ch_group` | → `acc_group` | `grup`→`name` |
| `ch_exchange_rate` | → `acc_exchange_rate` | `kur_tarihi`→`rate_date`, `kur`→`rate`, `para`→`currency_code` |
| `ch_account_plan` | → `acc_account_plan` | `plan_kodu`→`code`, `plan_adi`→`name`, `seviye`→`level` |
| `ch_account` | → `acc_account` | `hesap_kodu`→`code`, `hesap_ismi`→`name`, `hesap_tipi_id`→`type_id`, `bolge_id`→`region_id`, `mukellef_tipi`→`taxpayer_type`, `mukellef_adi`→`taxpayer_name`, `mukellef_soyadi`→`taxpayer_surname`, `vergi_dairesi`→`tax_office`, `vergi_no`→`tax_no`, `iban_para`→`iban_currency`, `nace`→`nace_code`, `yetkili1/2/3`→`authorized_person_1/2/3`, `yetkili*_tel`→`authorized_phone_1/2/3`, `muhabbe_telefon`→`accountant_phone`, `muhabbe_email`→`accountant_email`, `muhabbe_yetkili`→`accountant_authorized`, `ozel_not`→`notes`, `kok_kod`→`root_code`, `ara_kod`→`sub_code`, `iskonto`→`discount_rate`, `faks`→`fax`, `efatura_kullaniyor`→`e_invoice_active`, `efatura_pb_name`→`e_invoice_package_name`, `adres_id`→`address_id`, `pasif`→`is_passive` |
| `set_ch_firma_tipleri` | → `acc_set_company_type` | `firma_turu_id`→`type_id`, `firma_tipi`→`name` |
| `set_ch_firma_turleri` | → `acc_set_company_types` | `firma_turu`→`name` |
| `set_ch_hesap_tipleri` | → `acc_set_account_type` | `hesap_tipi`→`type_name` |
| `set_ch_vergi_oranlari` | → `acc_set_tax_rate` | `vergi_orani`→`tax_rate_value`, `satis_hesap_kodu`→`sale_account_code`, `satis_iade_hesap_kodu`→`sale_return_account_code`, `alis_hesap_kodu`→`purchase_account_code`, `alis_iade_hesap_kodu`→`purchase_return_account_code` |
### prs_set_ Tabloları (8 tablo — prefix set_prs_*→prs_set_*)

| Eski SQL Adı | Yeni SQL Adı | Kolon Değişiklikleri |
|---|---|---|
| `set_prs_driver_licence_types` | → `prs_set_driver_license_type` | *(değişiklik yok)* |
| `set_prs_language_levels` | → `prs_set_language_level` | *(değişiklik yok)* |
| `set_prs_languages` | → `prs_set_language` | *(değişiklik yok)* |
| `set_prs_person_types` | → `prs_set_person_type` | *(değişiklik yok)* |
| `set_prs_sections` | → `prs_set_section` | *(değişiklik yok)* |
| `set_prs_tasks` | → `prs_set_task` | *(değişiklik yok)* |
| `set_prs_transportation` | → `prs_set_transportation` | *(değişiklik yok)* |
| `set_prs_units` | → `prs_set_unit` | *(değişiklik yok)* |

### Index, Constraint & Sequence İsimleri (Tümü güncellendi)
- **16 index** → yeni tablo isimlerine göre güncellendi
- **~100+ constraint** (CHECK, FK, PK, UK) → yeni isimlere göre güncellendi
- **3 sequence** → `stk_kind_family_id_seq`, `stk_card_kind_info_id_seq`
- **10 fonksiyon** → `sp*` → `fn_*` prefix

### Fonksiyon İsimleri (sp → fn)

| Eski | Yeni |
|---|---|
| `spget_lang_text` | → `fn_get_lang_text` |
| `spget_rct_hammadde_maliyet` | → `fn_get_rct_hammadde_maliyet` |
| `spget_rct_iscilik_maliyet` | → `fn_get_rct_iscilik_maliyet` |
| `spget_rct_toplam` | → `fn_get_rct_toplam` |
| `spget_rct_yan_urun_maliyet` | → `fn_get_rct_yan_urun_maliyet` |
| `spget_sys_kalite_form_no` | → `fn_get_sys_kalite_form_no` |
| `spget_sys_lang_id` | → `fn_get_sys_lang_id` |
| `spget_sys_quality_form_type_id` | → `fn_get_sys_quality_form_type_id` |
| `spvarsayilan_para_birimi` | → `fn_default_currency` |
| `spvarsayilan_urun_tipi_id` | → `fn_default_product_type_id` |

---

## 🔜 Kalan DB İşleri

### [DB-01] `stk_inventory` tablosu constraint isimleri (opsiyonel - düşük öncelik)

`stk_inventory` tablosunda 23 adet eski `stk_kartlar_*` isimli constraint var. İşlevsel sorun yok ama naming consistency için güncellenebilir.

```bash
PGPASSWORD=qwe psql -h localhost -U postgres -d ths_erp \
  -c "ALTER TABLE stk_inventory RENAME CONSTRAINT stk_kartlar_id_not_null TO stk_inventory_id_not_null;"
```
**Kalan:** 23 constraint (CHECK, FK, PK, UNIQUE)

### [DB-02] `sys_address` kolonları — İngilizce ama uzun

Mevcut: `district`, `neighborhood`, `quarter`, `road`, `street`, `building_name`, `door_number`  
Önerilen isimler:
- `district` → `suburb` (veya `area`)
- `neighborhood` → `ward`
- `quarter` → `sector`
- `road` → `thoroughfare`
- `street` → `street`
- `building_name` → `building`
- `door_number` → `number`

> ⚠️ Bu kolonlar Türkçe değil — İngilizce isimler ancak proje gereksinimine göre değiştirilebilir.

### [DB-03] Diğer tabloların kolon isimleri (Türkçe kalmış FK kolonları)

Aşağıdaki tabloların FK kolon isimleri hala Türkçe:
- `als_teklifler.sehir_id` → `city_id` (sys_city'ye bakan FK)
- `als_teklifler.ulke_id` → `country_id` (sys_country'a bakan FK)
- `sat_siparisler.sehir_id`, `.ulke_id`, `.para_birimi` → `city_id`, `.country_id`, `.currency`
- `sat_siparis_detaylari.stok_kodu` → `stock_code` (stk_inventory'e bakan FK, **NOT VALID**)

Eğer bu kolon isimlerini de İngilizce yapmak istersen ayrıca güncellemek gerekir.

### [DB-04] Eski `set_stk_*` tabloları kontrolü

Veritabanında artık `set_stk_*` tablosu yok — silinmiş, migration gerekli değil.

---

## 🔜 Delphi Kod Değişiklikleri

### Öncelik 1: SYS Tabloları (21 tablo)

Her sys_ entity'sinin **TableName**, **Column** mapping ve class adı güncellenmeli:

| Mevcut Entity | Yeni [Table] | Yeni Class Adı | Kolon Değişiklikleri |
|---|---|---|---|
| `sys_access_rights` → `[Table('sys_access_right')]` | TSysAccessRight *(değişmez)* | *(değişiklik yok)* |
| `sys_addresses` → `[Table('sys_address')]` | TSysAddress *(değişmez)* | *(değişiklik yok)* |
| `sys_application_settings` → `[Table('sys_application_setting')]` | TSysApplicationSetting *(değişmez)* | *(değişiklik yok)* |
| **`sys_cities`** → **`[Table('sys_city')]`** | **TSysCity** *(değişmez)* | `city_name`→`name`, `car_plate_code`→`plate_code` |
| **`sys_countries`** → **`[Table('sys_country')]`** | **TSysCountry** *(değişmez)* | `country_name`→`name`, `country_code`→`code` |
| `sys_currencies` → `[Table('sys_currency')]` | TSysCurrency *(değişmez)* | *(değişiklik yok)* |
| **`sys_days`** → **`[Table('sys_day')]`** | **TSysDay** *(değişmez)* | `day_name`→`name` |
| `sys_decimal_places` → `[Table('sys_decimal_place')]` | TSysDecimalPlace *(değişmez)* | *(değişiklik yok)* |
| `sys_grid_column_titles` → `[Table('sys_grid_column_title')]` | TSysGridColumnTitle *(değişmez)* | *(değişiklik yok)* |
| `sys_grid_columns` → `[Table('sys_grid_column')]` | TSysGridColumn *(değişmez)* | *(değişiklik yok)* |
| `sys_grid_filters` → `[Table('sys_grid_filter')]` | TSysGridFilter *(değişmez)* | *(değişiklik yok)* |
| `sys_grid_sorts` → `[Table('sys_grid_sort')]` | TSysGridSort *(değişmez)* | *(değişiklik yok)* |
| `sys_gui_contents` → `[Table('sys_gui_content')]` | TSysGuiContent *(değişmez)* | *(değişiklik yok)* |
| `sys_languages` → `[Table('sys_language')]` | TSysLanguage *(değişmez)* | *(değişiklik yok)* |
| **`sys_months`** → **`[Table('sys_month')]`** | **TSysMonth** *(değişmez)* | `month_name`→`name` |
| **`sys_permission_groups`** → **`[Table('sys_permission_group')]`** | **TSysPermissionGroup** *(değişmez)* | `group_name`→`name` |
| **`sys_permissions`** → **`[Table('sys_permission')]`** | **TSysPermission** *(değişmez)* | `permission_name`→`name`, `permission_code`→`code`, `permission_group_id`→`group_id` |
| **`sys_regions`** → **`[Table('sys_region')]`** | **TSysRegion** *(değişmez)* | `region_name`→`name` |
| `sys_uom_types` → `[Table('sys_uom_type')]` | TSysUomType *(değişmez)* | *(değişiklik yok)* |
| `sys_users` → `[Table('sys_user')]` | TSysUser *(değişmez)* | *(değişiklik yok)* |

### Öncelik 2: STK Tabloları (9 tablo)

Her Stock entity'sinin **TableName**, **Column** mapping ve dosya/ad güncellenmeli:

| Mevcut Dosya | Yeni Dosya Adı | Yeni [Table] | Kolon Değişiklikleri |
|---|---|---|---|
| `StkGroup.pas` | `StkGroup.pas` | `[Table('stk_group')]` *(değişmez)* | `group_name`→`name` |
| `StkImage.pas` | `StkImage.pas` | `[Table('stk_image')]` | `stk_card_id`→`card_id` |
| `StkKartCinsBilgileri.pas` | **`StkCardKindInfo.pas`** | `[Table('stk_card_kind_info')]` | `stk_kart_id`→`card_id`, `cins_id`→`kind_id`, `deger`→`value` |
| `StkKindFamily.pas` | `StkKindFamily.pas` | `[Table('stk_kind_family')]` *(değişmez)* | *(değişiklik yok)* |
| `StkKindProperty.pas` | `StkKindProperty.pas` | `[Table('stk_kind_property')]` | `desciption`→`description` |
| `StkCardSummary.pas` | **`StkInventorySummary.pas`** | `[Table('stk_inventory_summary')]` | `stk_card_id`→`inventory_id` |

### Öncelik 3: Repository & Service Dosyaları (27+ dosya)

Her Repository/Service'de:
- `uses` listesindeki unit referansları güncellensin
- Generic type parametreleri yeni class isimleriyle eşleşsin

**Delphi'de `unit` direktifi ile dosya adı eşleşmeli** — unit rename ederken dosya adını da değiştirin.

### Öncelik 4: Form Dosyaları Tarayımı

```
ERP/Forms/InputForms/Stock/ufrm*.pas
ERP/Forms/OutputForms/DbGrid/Stock/ufrm*.pas
```

Unit reference'ları ve class usage'ları güncellensin.

### Öncelik 5: Referans Tarayıcı İşlemi

Tüm proje içinde şu class/table isimlerinin referanslarını tarayın:
- `TStkGroup`, `TStkImage`, `TStkKartCinsBilgileri`, `TStkCardSummary`
- `stk_groups`, `stk_images`, `stk_kart_cins_bilgileri`, `stk_card_summaries`
- `sys_access_rights`, `sys_addresses`, `sys_cities`, `sys_countries`, vb.

---

## 💡 Komut Referansları

### DB Şema Yedeği Çıkarma (pg_dump -s)

Kullanıcı **"DB şema çıkart"** dediğinde çalıştır:

```powershell
$env:PGPASSWORD = "qwe"
& pg_dump -h localhost -U postgres -d ths_erp --schema-only --no-owner --no-privileges | Set-Content -Encoding utf8 'D:\Projects\ThsErp\ERP\db_schema.sql'
```

**Son çıkarma:** 2026-06-28 — `D:\Projects\ThsErp\ERP\db_schema.sql` (157 KB, schema-only)

> ⚠️ **Not:** Eğer kullanıcı tam dump (`pg_dump -d ths_erp` → ~70 MB) çalıştırdıysa ve sonuç `db_schema.sql` içine yazıldıysa, bunu doğrula ve gerekirse schema-only ile tekrar çalıştır.

### DB Şema Yedği Kopyalama

Eğer kullanıcı başka makinaya yedeği taşımak istiyorsa:
```powershell
copy 'D:\Projects\ThsErp\ERP\db_schema.sql' 'D:\backup_db\'
```

### Fonksiyon Çağrı Örneği
```powershell
$env:PGPASSWORD = "qwe"
& pg_dump -h localhost -U postgres -d ths_erp --schema-only --no-owner --no-privileges | Set-Content -Encoding utf8 'D:\Projects\ThsErp\ERP\db_schema.sql'
```

**Son çıkarma:** 2026-06-28 — `D:\Projects\ThsErp\ERP\db_schema.sql` (157 KB, schema-only)

> ⚠️ **Not:** Eğer kullanıcı tam dump (`pg_dump -d ths_erp` → ~70 MB) çalıştırdıysa ve sonuç `db_schema.sql` içine yazıldıysa, bunu doğrula ve gerekirse schema-only ile tekrar çalıştır.

### DB şema bilgileri
- **Host:** localhost  
- **Kullanıcı:** postgres  
- **Şifre:** qwe

### Fonksiyon Çağrı Örneği
```bash
PGPASSWORD=qwe psql -h localhost -U postgres -d ths_erp \
  -c "SELECT * FROM fn_default_product_type_id();"
```

### Tablo Kontrolü
```bash
PGPASSWORD=qwe psql -h localhost -U postgres -d ths_erp \
  -c "SELECT table_name, column_name FROM information_schema.columns WHERE table_name = 'stk_group' ORDER BY ordinal_position;"
```

### DB Bağlantı Testi
```powershell
$env:PGPASSWORD = "qwe"
& psql -h localhost -U postgres -d ths_erp -c "SELECT version();"
```

---

## 📋 Özet — Kalan İşler

| Kategori | Durum | Not |
|---|---|---|
| DB tablo isimleri (stk_/sys_) | ✅ 30/30 tamamlandı | Tekil form + İngilizce |
| DB kolon isimleri (stk_/sys_) | ✅ 12/12 tamamlandı | Türkçe → İngilizce |
| DB index/constraint/sequence | ✅ Tamamlandı | Tüm isimler güncellendi |
| DB fonksiyon isimleri | ✅ 10/10 tamamlandı | `sp` → `fn` prefix |
| acc_acc_ prefix (ch_/set_ch_) tablo isimleri | ✅ 11/11 tamamlandı | ch_→acc_, set_ch_→acc_set_ |
| acc_prs_set_ prefix (set_prs_*→prs_set_) tablo isimleri | ✅ 8/8 tamamlandı | set_prs_*→prs_set_* |
| Delphi entity tablo mapping | 🔜 ~35 dosya kalıyor | SYS öncelikli, sonra STK ve ACC |

| Kolon name mapping (Delphi) | 🔜 ~20 kolon kalıyor | SQL'e eşleştirmeli |
| FK constraint isimleri | ✅ Tamamlandı | Düzgün çalışıyor |
| stk_inventory constraint isimleri | 🔻 Opsiyonel (23 eski ismin temizliği) | İşlevsel sorun yok |
| Eski set_stk_* tabloları | ✅ Silinmiş | Migration gerekmiyor. set_stk_ → stk_set_ için de planlanabilir |
---

**Not:** Bu dosya projenin yapay zeka beyin dosyasıdır. Her yeni değişiklik ve karar burada kayıt altına alınır.

---

## Turkish DB Migration Plan

### 1. COLUMN RENAME — Turkish Column Names

#### als_teklifler (pur_offer) — 4 columns
| Old | New | Description |
|---|---|---|
| sehir_id | city_id | sys_city FK |
| ulke_id | country_id | sys_country FK |
| para_birimi | currency_code | currency reference |
| muhattap_telefon | contact_phone | contact phone |

#### als_teklif_detaylari (pur_offer_detail) — 13 columns  
| Old | New | Description |
|---|---|---|
| olcu_birimi | uom_code | sys_uom FK code |
| kdv_orani | tax_rate | VAT rate (%) |
| kdv_tutar | tax_amount | VAT amount |
| tutar | amount | line amount |
| net_tutar | net_amount | net line total |
| toplam_tutar | total_amount | gross line total |
| iskonto_orani | discount_rate | discount percentage |
| iskonto_tutar | discount_amount | discount value |
| stok_aciklama | stock_description | description |
| kullanici_aciklama | user_description | user note |
| mensei_ulke_adi | country_of_origin | origin country name |
| siparis_detay_id | order_detail_id | FK reference |
| fatura_detay_id | invoice_detail_id | FK reference |

#### sat_siparisler (sls_order) — 7 columns
| Old | New | Description |
|---|---|---|
| sehir_id | city_id | sys_city FK |
| ulke_id | country_id | sys_country FK |
| para_birimi | currency_code | currency code |
| siparis_no | order_number | order identifier |
| teslim_tarihi | delivery_date | delivery date |
| muhattap_telefon | contact_phone | contact phone |
| siparis_durum_id | status_id | order status FK |

#### sat_siparis_detaylari (sls_order_detail) — 12 columns
| Old | New | Description |
|---|---|---|
| olcu_birimi | uom_code | sys_uom FK code |
| kdv_orani | tax_rate | VAT rate (%) |
| kdv_tutar | tax_amount | VAT amount |
| tutar | amount | line amount |
| net_tutar | net_amount | net line total |
| toplam_tutar | total_amount | gross line total |
| iskonto_orani | discount_rate | discount percentage |
| iskonto_tutar | discount_amount | discount value |
| stok_aciklama | stock_description | description |
| kullanici_aciklama | user_description | user note |
| siparis_detay_id | order_detail_id | FK reference |
| fatura_detay_id | invoice_detail_id | FK reference |

#### sat_teklifler (sls_offer) — 6 columns
| Old | New | Description |
|---|---|---|
| sehir_id | city_id | sys_city FK |
| ulke_id | country_id | sys_country FK |
| para_birimi | currency_code | currency code |
| siparis_durum_id | status_id | status FK |
| muhattap_telefon | contact_phone | contact phone |
| teslim_tarihi | delivery_date | delivery date |

#### sat_teklif_detaylari (sls_offer_detail) — 12 columns
| Old | New | Description |
|---|---|---|
| olcu_birimi | uom_code | sys_uom FK code |
| kdv_orani | tax_rate | VAT rate (%) |
| kdv_tutar | tax_amount | VAT amount |
| tutar | amount | line amount |
| net_tutar | net_amount | net line total |
| toplam_tutar | total_amount | gross line total |
| iskonto_orani | discount_rate | discount percentage |
| iskonto_tutar | discount_amount | discount value |
| stok_aciklama | stock_description | description |
| kullanici_aciklama | user_description | user note |

#### pur_offer (als_teklif) — 3 columns
| Old | New | Description |
|---|---|---|
| siparis_durum_id | status_id | status FK |
| teslim_tarihi | delivery_date | delivery date |
| muhattap_telefon | contact_phone | contact phone |

### 2. SEQUENCE RENAME — Snake_case + English Names

| Old Name | New Name |
|---|---|
| sys_erisim_hakki_id_seq | sys_access_right_id_seq |
| set_ch_firma_tipi_id_seq | acc_set_company_type_id_seq |
| set_ch_firma_turu_id_seq | acc_set_company_legal_form_id_seq |
| set_ch_hesap_tipi_id_seq | acc_set_account_type_id_seq |
| set_ch_vergi_orani_id_seq | acc_set_tax_rate_id_seq |
| set_einv_fatura_tipi_id_seq | einv_invoice_type_id_seq |
| set_einv_paket_tipi_id_seq | einv_packet_type_id_seq |
| set_prs_birim_id_seq | prs_set_unit_id_seq |
| set_prs_personel_tipi_id_seq | prs_set_person_type_id_seq |
| sys_olcu_birimi_id_seq | sys_uom_id_seq |
| sys_olcu_birimi_tipi_id_seq | sys_uom_type_id_seq |
| sys_para_birimi_id_seq | sys_currency_id_seq |

### 3. VIEW COLUMN RENAME — English Aliases

#### sat_siparis_rapor view (line ~1810)
| Old Alias | New Alias |
|---|---|
| sehir_adi | city_name |
| stok_grubu | stock_group_name |
| stok_aciklama | stock_description |
| siparis_no | order_number |
| siparis_tarihi | order_date |
| teslim_tarihi | delivery_date |
| siparis_durum | status_name |
| aciklama (s) | notes |
| referans | reference |
| referans_satir | line_reference |

#### sys_view_databases view (line ~3187)
| Old Alias | New Alias |
|---|---|
| aciklama | description |

#### fn_get_sys_kalite_form_no function (line ~283)
- Rename: n_get_sys_quality_form_no (already correct, just verify)
- Parameter: ptablo_adi → p_table_name, pform_tipi_id → p_form_type_id
- SQL body: sys_kalite_form_no table ref → sys_quality_form_no

### 4. TRIGGER UPDATE — Old Table Names

Triggers referencing prs_persons, prs_driver_abilities, prs_language_abilities tables need updates after table renames (prs_* → emp_* migration from the earlier plan).

### 5. CONSTRAINT NAME RENAMES

Check constraint names that reference old column names:
- ls_teklifler_kdv_oran1_not_null → ls_teklifler_tax_rate_1_not_null
- sat_siparisler_kdv_oran1_not_null → sls_order_tax_rate_1_not_null
- etc. (all kdv_oran/kdv_tutar related constraints need renaming)

### Migration Order:
1. COLUMN RENAME (ALTER TABLE ... RENAME COLUMN)
2. CONSTRAINT RENAME (ALTER TABLE ... RENAME CONSTRAINT)
3. SEQUENCE RENAME (ALTER SEQUENCE ... RENAME TO)
4. VIEW RECREATE (DROP + CREATE with new aliases)
5. FUNCTION PARAMETER/SQL updates

---

## PostgreSQL Türkçe - English Migration Plan (db_schema.sql 2026-06-29T23:01)

### GENEL KURAL: Table name, column name, sequence name = snake_case. All content must be in English.

---

### ALREADY CORRECT (NO CHANGE NEEDED)
- Table names: acc_*, sys_*, stk_*, prd_* prefixes are already English + snake_case
- Index names: idx_* format, no Turkish characters
- Constraint names: acc_acc_pkey, sys_access_right_pkey etc. (snake_case + English)

---

### NEED CHANGE

#### 1. COLUMN NAMES - Turkish Content Tables

als_teklifler (pur_offer) - 4 columns:
| Old | New | Description |
| sehir_id | city_id | sys_city FK |
| ulke_id | country_id | sys_country FK |
| para_birimi | currency_code | Currency code |
| muhattap_telefon | contact_phone | Contact phone |

als_teklif_detaylari (pur_offer_detail) - 13 columns:
| Old | New | Description |
| olcu_birimi | uom_code | UoM FK code |
| kdv_orani | tax_rate | VAT rate (%) |
| kdv_tutar | tax_amount | VAT amount |
| tutar | amount | Amount |
| net_tutar | net_amount | Net amount |
| toplam_tutar | total_amount | Total amount |
| iskonto_orani | discount_rate | Discount rate |
| iskonto_tutar | discount_amount | Discount amount |
| siparis_detay_id | order_detail_id | Order detail FK |
| irsaliye_detay_id | delivery_note_detail_id | Delivery note FK |
| fatura_detay_id | invoice_detail_id | Invoice detail FK |
| stok_aciklama | stock_description | Stock description |
| kullanici_aciklama | user_description | User description |
| mensei_ulke_adi | country_of_origin | Country of origin |

sat_siparisler (sls_order) - 7 columns:
| Old | New | Description |
| sehir_id | city_id | sys_city FK |
| ulke_id | country_id | sys_country FK |
| para_birimi | currency_code | Currency code |
| siparis_no | order_number | Order number |
| siparis_tarihi | order_date | Order date |
| teslim_tarihi | delivery_date | Delivery date |
| muhattap_telefon | contact_phone | Contact phone |

sat_siparis_detaylari (sls_order_detail) - 12 columns:
| Old | New | Description |
| olcu_birimi | uom_code | UoM FK code |
| kdv_orani | tax_rate | VAT rate (%) |
| kdv_tutar | tax_amount | VAT amount |
| tutar | amount | Amount |
| net_tutar | net_amount | Net amount |
| toplam_tutar | total_amount | Total amount |
| iskonto_orani | discount_rate | Discount rate |
| iskonto_tutar | discount_amount | Discount amount |
| siparis_detay_id | order_detail_id | Order detail FK |
| irsaliye_detay_id | delivery_note_detail_id | Delivery note FK |
| fatura_detay_id | invoice_detail_id | Invoice detail FK |
| stok_aciklama | stock_description | Stock description |
| kullanici_aciklama | user_description | User description |

sat_teklifler (sls_offer) - 6 columns:
| Old | New | Description |
| sehir_id | city_id | sys_city FK |
| ulke_id | country_id | sys_country FK |
| para_birimi | currency_code | Currency code |
| siparis_durum_id | status_id | Status FK |
| muhattap_telefon | contact_phone | Contact phone |
| teslim_tarihi | delivery_date | Delivery date |

sat_teklif_detaylari (sls_offer_detail) - 12 columns:
| Old | New | Description |
| olcu_birimi | uom_code | UoM FK code |
| kdv_orani | tax_rate | VAT rate (%) |
| kdv_tutar | tax_amount | VAT amount |
| tutar | amount | Amount |
| net_tutar | net_amount | Net amount |
| toplam_tutar | total_amount | Total amount |
| iskonto_orani | discount_rate | Discount rate |
| iskonto_tutar | discount_amount | Discount amount |
| stok_aciklama | stock_description | Stock description |
| kullanici_aciklama | user_description | User description |

prd_bom_raw - fire_orani:
| Old | New | Description |
| fire_orani | scrap_rate | Scrap rate |

---

#### 2. SEQUENCE RENAME - English Names (38 sequences)

| Old Sequence Name | New Sequence Name |
| ch_banka_id_seq | acc_bank_id_seq |
| ch_banka_subesi_id_seq | acc_bank_branch_id_seq |
| ch_bolge_id_seq | acc_region_id_seq |
| ch_hesap_karti_id_seq | acc_account_id_seq |
| als_teklifler_id_seq | pur_offer_id_seq |
| als_teklif_detaylari_id_seq | pur_offer_detail_id_seq |
| mhs_doviz_kuru_id_seq | mhs_exchange_rate_id_seq |
| mhs_fis_detaylari_id_seq | mhs_voucher_detail_id_seq |
| mhs_fisler_id_seq | mhs_voucher_id_seq |
| mhs_transfer_kodlari_id_seq | mhs_transfer_code_id_seq |
| rct_iscilik_gideri_id_seq | rct_labor_cost_id_seq |
| rct_paket_hammadde_detay_id | rct_pkg_rawmat_detail_id |
| rct_paket_hammadde_id | rct_pkg_rawmat_id |
| rct_paket_iscilik_detay_id | rct_pkg_labor_detail_id |
| rct_paket_iscilik_id | rct_pkg_labor_id |
| rct_recete_hammadde_id | rct_bom_rawmat_id |
| rct_recete_id | rct_recipe_id |
| rct_recete_iscilik_id | rct_recipe_labor_id |
| rct_recete_paket_hammadde_id | rct_recipe_pkg_rawmat_id |
| rct_recete_paket_iscilik_id | rct_recipe_pkg_labor_id |
| sat_fatura_detay_id_seq | sls_invoice_detail_id_seq |
| sat_fatura_id_seq | sls_invoice_id_seq |
| sat_irsaliye_detay_id_seq | sls_delivery_note_detail_id_seq |
| sat_irsaliye_id_seq | sls_delivery_note_id_seq |
| sat_siparis_detay_id_seq | sls_order_detail_id_seq |
| sat_siparis_id_seq | sls_order_id_seq |
| sat_teklif_detay_id_seq | sls_offer_detail_id_seq |
| sat_teklif_id_seq | sls_offer_id_seq |
| set_ch_firma_tipi_id_seq | acc_set_company_type_id_seq |
| set_ch_firma_turu_id_seq | acc_set_legal_form_id_seq |
| set_ch_grup_id_seq | acc_group_id_seq |
| set_ch_hesap_plani_id_seq | acc_account_plan_id_seq |
| set_ch_hesap_tipi_id_seq | acc_set_account_type_id_seq |
| set_ch_vergi_orani_id_seq | acc_set_tax_rate_id_seq |
| set_einv_fatura_tipi_id_seq | einv_invoice_type_id_seq |
| set_einv_odeme_sekli_id_seq | einv_payment_method_id_seq |
| set_einv_paket_tipi_id_seq | einv_packet_type_id_seq |
| set_einv_tasima_ucreti_id_seq | einv_transport_price_id_seq |
| set_einv_teslim_sekli_id_seq | einv_delivery_type_id_seq |
| sys_erisim_hakki_id_seq | sys_access_right_id_seq |
| set_prs_birim_id_seq | prs_set_unit_id_seq |
| set_prs_bolum_id_seq | prs_set_section_id_seq |
| set_prs_ehliyet_id_seq | prs_set_license_type_id_seq |
| set_prs_gorev_id_seq | prs_set_task_id_seq |
| set_prs_lisan_id_seq | prs_set_language_id_seq |
| set_prs_lisan_seviyesi_id_seq | prs_set_lang_level_id_seq |
| set_prs_personel_tipi_id_seq | prs_set_person_type_id_seq |
| set_prs_servis_araci_id_seq | prs_set_transport_id_seq |
| sys_olcu_birimi_id_seq | sys_uom_id_seq |
| sys_olcu_birimi_tipi_id_seq | sys_uom_type_id_seq |
| sys_para_birimi_id_seq | sys_currency_id_seq |

---

#### 3. VIEW COLUMN RENAME - English Aliases

sat_siparis_rapor (line ~1810):
| Old Alias | New Alias |
| sehir_adi | city_name |
| stok_grubu | stock_group_name |
| stok_aciklama | stock_description |
| siparis_no | order_number |
| siparis_tarihi | order_date |
| teslim_tarihi | delivery_date |
| siparis_durum | status_name |
| s.aciklama | notes |
| referans | reference |
| referans_satir | line_reference |

sys_view_databases (line ~3187):
| Old Alias | New Alias |
| aciklama | description |

---

#### 4. FUNCTION SQL REF - Turkish Table Name in Body

fn_get_sys_kalite_form_no (line ~283):
OLD: FROM sys_kalite_form_no WHERE tablo_adi = ptablo_adi
NEW: FROM sys_quality_form_no WHERE table_name = p_table_name

---

#### 5. CONSTRAINT NAMES - Column Ref Renames (~50+)

ALL kdv_/tutar_/oran_* constraint names need renaming:
als_teklifler_kdv_oran1_not_null -> pur_offer_tax_rate_1_nn
sat_siparisler_kdv_oran1_not_null -> sls_order_tax_rate_1_nn
sat_teklifler_kdv_oran1_not_null -> sls_offer_tax_rate_1_nn
-- plus all kdv_tutar, tutar, net_tutar, toplam_tutar, iskonto related constraints

---

### Migration Order:
1. ALTER TABLE ... RENAME COLUMN (each table)
2. ALTER TABLE ... RENAME CONSTRAINT (~50+ constraint renames)
3. ALTER SEQUENCE ... RENAME TO (38 sequences)
4. DROP VIEW + CREATE VIEW (aliases updated)
5. FUNCTION SQL content updates


