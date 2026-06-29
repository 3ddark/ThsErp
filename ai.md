# THS ERP — Yapay Zeka Beyin Dosyası

**Son güncelleme:** 2026-06-28  
**DB durumu:** ✅ Temel değişiklikler tamamlandı (tablo + kolon + constraint + sequence + fonksiyon)  
**Delphi durumu:** Entity layer refactor devam ediyor — Person ve Stock klasörleri organize edildi, SYS/STK DB şema doğrulamaları yapıldı  
**Kalan:** Sys/Stk tablo & kolon İngilizce isimlerine çevirme (Delphi tarafında)

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
