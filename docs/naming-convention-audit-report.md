# İsimlendirme Kontrol Raporu — Tüm Modüller

**Tarih**: 2026-07-01  
**Kapsam**: System, Account, Personel, Stock, Production modülleri  
**Amaç**: Database tablo isimleri ile Domain/Repository/Service dosya ve class isimlerinin eşleşmesini doğrulama

---

## 1. System Modülü (`sys_*`) — ⚠️ SORUNLAR VAR

### Database'deki Tablolar (21 adet)
```
sys_access_right, sys_address, sys_application_setting, sys_city, sys_country,
sys_currency, sys_day, sys_decimal_place, sys_grid_column, sys_grid_column_title,
sys_grid_filter, sys_grid_sort, sys_gui_content, sys_language, sys_month,
sys_permission, sys_permission_group, sys_region, sys_uom, sys_uom_type, sys_user
```

### Mevcut Domain Dosyaları (25 adet)
| # | Dosya Adı | Database'de Var mı? | Durum |
|---|-----------|:-------------------:|:-----:|
| 1 | `SysAccessRight.pas` | ✅ `sys_access_right` | DOĞRU |
| 2 | `SysAddress.pas` | ✅ `sys_address` | DOĞRU |
| 3 | `SysApplicationSetting.pas` | ✅ `sys_application_setting` | DOĞRU |
| 4 | `SysCity.pas` | ✅ `sys_city` | DOĞRU |
| 5 | `SysCountry.pas` | ✅ `sys_country` | DOĞRU |
| 6 | `SysCurrency.pas` | ✅ `sys_currency` | DOĞRU |
| 7 | `SysDay.pas` | ✅ `sys_day` | DOĞRU |
| 8 | `SysDecimalPlace.pas` | ✅ `sys_decimal_place` | DOĞRU |
| 9 | `SysGridColumn.pas` | ✅ `sys_grid_column` | DOĞRU |
| 10 | `GridColumnTitle.pas` ⚠️ | ✅ `sys_grid_column_title` | KISMİ (prefix eksik) |
| 11 | `SysGridFilter.pas` | ✅ `sys_grid_filter` | DOĞRU |
| 12 | `SysGridSort.pas` | ✅ `sys_grid_sort` | DOĞRU |
| 13 | `SysGuiContent.pas` | ✅ `sys_gui_content` | DOĞRU |
| 14 | `SysLanguage.pas` | ✅ `sys_language` | DOĞRU |
| 15 | `SysMonth.pas` | ✅ `sys_month` | DOĞRU |
| 16 | `SysPermission.pas` | ✅ `sys_permission` | DOĞRU |
| 17 | `SysPermissionGroup.pas` | ✅ `sys_permission_group` | DOĞRU |
| 18 | `SysRegion.pas` | ✅ `sys_region` | DOĞRU |
| 19 | `SysUom.pas` | ✅ `sys_uom` | DOĞRU |
| 20 | `SysUomType.pas` | ✅ `sys_uom_type` | DOĞRU |
| 21 | `SysUser.pas` | ✅ `sys_user` | DOĞRU |
| 22 | **`SysParaBirimi.pas`** ❌ | ❌ **YOK** | **SORUN: Türkçe!** |
| 23 | **`SysResource.pas`** ⚠️ | ❌ **YOK** | SORUN: Tablo yok |
| 24 | **`SysResourceGroup.pas`** ⚠️ | ❌ **YOK** | SORUN: Tablo yok |
| 25 | `SysViewColumn.pas` | ⚠️ VIEW (tablo değil) | KISMİ |

### Tespit Edilen Sorunlar

#### ❌ KRİTİK: Türkçe İsim — `SysParaBirimi.pas`
- **Dosya**: `ERP/BackEnd/System/Domain/SysParaBirimi.pas`
- **Sorun**: "Para Birimi" Türkçe! CLAUDE.md kuralı ihlali
- **Database'de Var mı?**: HAYIR — `sys_currency` tablosu zaten var
- **Öneri**: Dosya silinmeli (veya `SysCurrency.pas` ile birleştirilmeli)

#### ⚠️ ORTA: Database'de Olmayan Tablolar
- `SysResource.pas` → `sys_resources` (tablo yok)
- `SysResourceGroup.pas` → `sys_resource_groups` (tablo yok)
- **Öneri**: Legacy olarak işaretlenmeli veya database'e eklenmeli

#### ⚠️ DÜŞÜK: Prefix Tutarsızlığı
- `GridColumnTitle.pas` → `sys_grid_column_title` olmalı ama prefix "Sys" yerine "Grid" kullanılmış
- **Öneri**: `SysGridColumnTitle.pas` olarak yeniden adlandırılmalı

---

## 2. Account Modülü (`acc_*`) — ✅ TEMİZ

### Database'deki Tablolar (14 adet)
```
acc_account, acc_account_plan, acc_bank, acc_bank_branch, acc_exchange_rate,
acc_group, acc_region, acc_set_account_type, acc_set_company_legal_form,
acc_set_ownership_type, acc_set_tax_rate, acc_transfer_code, acc_voucher, acc_voucher_detail
```

### Mevcut Domain Dosyaları (14 adet) — HEPİ UYUMLU ✅

| # | Dosya Adı | Database Tablosu | Durum |
|---|-----------|-----------------|:-----:|
| 1 | `AccAccount.pas` | `acc_account` | DOĞRU |
| 2 | `AccAccountPlan.pas` | `acc_account_plan` | DOĞRU |
| 3 | `AccBank.pas` | `acc_bank` | DOĞRU |
| 4 | `AccBankBranch.pas` | `acc_bank_branch` | DOĞRU |
| 5 | `AccExchangeRate.pas` | `acc_exchange_rate` | DOĞRU |
| 6 | `AccGroup.pas` | `acc_group` | DOĞRU |
| 7 | `AccRegion.pas` | `acc_region` | DOĞRU |
| 8 | `SetAccAccountType.pas` | `acc_set_account_type` | DOĞRU |
| 9 | `SetAccCompanyLegalForm.pas` | `acc_set_company_legal_form` | DOĞRU |
| 10 | `SetAccOwnershipType.pas` | `acc_set_ownership_type` | DOĞRU |
| 11 | `SetAccTaxRate.pas` | `acc_set_tax_rate` | DOĞRU |
| 12 | `AccTransferCode.pas` | `acc_transfer_code` | DOĞRU |
| 13 | `AccVoucher.pas` | `acc_voucher` | DOĞRU |
| 14 | `AccVoucherDetail.pas` | `acc_voucher_detail` | DOĞRU |

**Sonuç**: ✅ **HİÇ SORUN YOK** — Tüm isimlendirmeler eşleşiyor.

---

## 3. Personel Modülü (`prs_*`) — ⚠️ PREFIX TUTARSIZLIĞI

### Database'deki Tablolar (11 adet)
```
prs_driver_abilities, prs_language_abilities, prs_persons,
prs_set_driver_license_type, prs_set_language, prs_set_language_level,
prs_set_person_type, prs_set_section, prs_set_task,
prs_set_transportation, prs_set_unit
```

### Mevcut Domain Dosyaları (11 adet) — PREFIX FARKI VAR ⚠️

| # | Dosya Adı | Database Tablosu | Durum |
|---|-----------|-----------------|:-----:|
| 1 | `EmpDriverLicence.pas` ❌ | `prs_driver_abilities` | **PREFIX FARKI** |
| 2 | `EmpDriverLicenceType.pas` ❌ | `prs_set_driver_license_type` | **PREFIX FARKİ** |
| 3 | `EmpLanguage.pas` ❌ | `prs_set_language` | **PREFIX FARKI** |
| 4 | `EmpLanguageAbility.pas` ❌ | `prs_language_abilities` | **PREFIX FARKI** |
| 5 | `EmpLanguageLevel.pas` ❌ | `prs_set_language_level` | **PREFIX FARKI** |
| 6 | `EmpPerson.pas` ❌ | `prs_persons` | **PREFIX FARKI** |
| 7 | `EmpPersonType.pas` ❌ | `prs_set_person_type` | **PREFIX FARKI** |
| 8 | `EmpSection.pas` ❌ | `prs_set_section` | **PREFIX FARKI** |
| 9 | `EmpTask.pas` ❌ | `prs_set_task` | **PREFIX FARKI** |
| 10 | `EmpTransportation.pas` ❌ | `prs_set_transportation` | **PREFIX FARKI** |
| 11 | `EmpUnit.pas` ❌ | `prs_set_unit` | **PREFIX FARKI** |

### Sorun Analizi

**Database prefix'i**: `prs_*` (Personnel/Settlement)  
**Entity prefix'i**: `Emp*` (Employee)

Her iki prefix de mantıklı:
- `prs_` — Database convention'u
- `Emp` — Entity naming'de "Personel" modülünü belirtmek için

**Ama CLAUDE.md kuralına göre**: Entity isimleri database tablo isimleriyle **aynı olmalı**.

### Öneriler

| Seçenek | Açıklama | Önerilen |
|---------|----------|:--------:|
| **A) Database ile Eşleştir** | `Emp*` → `Prs*` (veya `PrsSet*`) | 🟡 Orta öncelik |
| **B) Mevcut Haliyle Bırak** | `Emp*` convention'u legacy olarak kabul et | 🔵 Düşük öncelik |

**Önerim**: Seçenek B — Refactoring çok fazla dosya etkiler (Forms dahil). Ama yeni modüllerde `prs_*` convention'u kullanılmalı.

---

## 4. Stock Modülü (`stk_*`) — ❌ KRİTİK SORUNLAR VAR

### Database'deki Tablolar (9 adet)
```
stk_card_kind_info, stk_group, stk_image, stk_inventory, stk_inventory_summary,
stk_kind_family, stk_kind_property, stk_transaction, stk_warehouse
```

### Mevcut Domain Dosyaları (19 adet) — 10 TANESİ SORUNLU ❌

| # | Dosya Adı | Database Tablosu | Durum |
|---|-----------|-----------------|:-----:|
| 1 | `SetChFirmaTipleri.pas` ❌ | YOK | **SORUN: Database'de yok** |
| 2 | `SetChFirmaTuru.pas` ❌ | YOK | **SORUN: Database'de yok** |
| 3 | `SetStkBarkodHazirlikDosyaTuru.pas` ❌ | YOK | **SORUN: Database'de yok** |
| 4 | `SetStkBarkodSeriNoTuru.pas` ❌ | YOK | **SORUN: Database'de yok** |
| 5 | `SetStkBarkodTezgah.pas` ❌ | YOK | **SORUN: Database'de yok** |
| 6 | `SetStkBarkodUrunTuru.pas` ❌ | YOK | **SORUN: Database'de yok** |
| 7 | `SetStkHareketTipi.pas` ❌ | YOK | **SORUN: Database'de yok** |
| 8 | `SetStkStokTipi.pas` ❌ | YOK | **SORUN: Database'de yok** |
| 9 | `SetStkUrunTipleri.pas` ❌ | YOK | **SORUN: Database'de yok** |
| 10 | `StkCardSummary.pas` ✅ | `stk_inventory_summary` | DOĞRU |
| 11 | `StkGroup.pas` ✅ | `stk_group` | DOĞRU |
| 12 | `StkImage.pas` ✅ | `stk_image` | DOĞRU |
| 13 | `StkKartlar.pas` ❌ | `stk_inventory` | **TÜRKÇE!** |
| 14 | `StkKindFamily.pas` ✅ | `stk_kind_family` | DOĞRU |
| 15 | `StkKindProperty.pas` ✅ | `stk_kind_property` | DOĞRU |
| 16 | `StkStokGrubuTuru.pas` ❌ | YOK | **SORUN: Database'de yok** |
| 17 | `StkStokHareketi.pas` ❌ | `stk_transaction` | **TÜRKÇE!** |
| 18 | `StkWarehouse.pas` ✅ | `stk_warehouse` | DOĞRU |

### Tespit Edilen Sorunlar

#### ❌ KRİTİK: Türkçe İsimler
1. **`StkKartlar.pas`** → "Kartlar" Türkçe! → `StkInventory.pas` olmalı
2. **`StkStokHareketi.pas`** → "Stok Hareketi" Türkçe! → `StkTransaction.pas` olmalı

#### ❌ KRİTİK: Database'de Olmayan 10 Tablo
- `set_ch_firma_tipleri`, `set_ch_firma_turleri`
- `set_stk_barkod_*` (4 adet)
- `set_stk_hareket_tipi`, `set_stk_stok_tipi`, `set_stk_urun_tipleri`
- `stk_stok_grubu_turu`

**Öneri**: Bu entity'ler için Database DDL migration'ları oluşturulmalı veya legacy olarak işaretlenmeli.

---

## 5. Production Modülü (`prd_*`) — ✅ TEMİZ

### Database'deki Tablolar (11 adet)
```
prd_bom, prd_bom_by_product, prd_bom_labour, prd_bom_packet_labour,
prd_bom_packet_raw, prd_bom_raw, prd_labour, prd_packet_labour,
prd_packet_labour_detail, prd_packet_raw, prd_packet_raw_detail
```

### Mevcut Domain Dosyaları (11 adet) — HEPİ UYUMLU ✅

| # | Dosya Adı | Database Tablosu | Durum |
|---|-----------|-----------------|:-----:|
| 1 | `PrdBom.pas` | `prd_bom` | DOĞRU |
| 2 | `PrdBomByProduct.pas` | `prd_bom_by_product` | DOĞRU |
| 3 | `PrdBomLabour.pas` | `prd_bom_labour` | DOĞRU |
| 4 | `PrdBomPacketLabour.pas` | `prd_bom_packet_labour` | DOĞRU |
| 5 | `PrdBomPacketRaw.pas` | `prd_bom_packet_raw` | DOĞRU |
| 6 | `PrdBomRaw.pas` | `prd_bom_raw` | DOĞRU |
| 7 | `PrdLabour.pas` | `prd_labour` | DOĞRU |
| 8 | `PrdPacketLabour.pas` | `prd_packet_labour` | DOĞRU |
| 9 | `PrdPacketLabourDetail.pas` | `prd_packet_labour_detail` | DOĞRU |
| 10 | `PrdPacketRaw.pas` | `prd_packet_raw` | DOĞRU |
| 11 | `PrdPacketRawDetail.pas` | `prd_packet_raw_detail` | DOĞRU |

**Sonuç**: ✅ **HİÇ SORUN YOK** — Tüm isimlendirmeler eşleşiyor. Production modülü referans alınmalı!

---

## 6. Özet Tablo

| Modül | Toplam Tablo | Uygun Dosya | Sorunlu Dosya | Durum |
|-------|:------------:|:-----------:|:-------------:|:-----:|
| **System** | 21 | 20 | **3** (1 Türkçe, 2 yok) | ⚠️ |
| **Account** | 14 | 14 | 0 | ✅ TEMİZ |
| **Personel** | 11 | 0 | **11** (prefix farkı) | ⚠️ |
| **Stock** | 9+10 | 6 | **10** (2 Türkçe, 8 yok) | ❌ KRİTİK |
| **Production** | 11 | 11 | 0 | ✅ TEMİZ |

### Sorun Türlerine Göre Dağılım

| Sorun Türü | Sayı | Modüller |
|------------|:----:|----------|
| ❌ Türkçe isim | 3 | System (1), Stock (2) |
| ❌ Database'de olmayan tablo | 15 | System (2), Stock (10+), Personel (0) |
| ⚠️ Prefix tutarsızlığı | 11 | Personel (11) |

---

## 7. Öncelikli Aksiyon Listesi

### Acil (Bu Hafta) — KRİTİK
1. 🔴 **Stock Modülü Türkçe İsimler Düzelt**:
   - `StkKartlar.pas` → `StkInventory.pas`
   - `StkStokHareketi.pas` → `StkTransaction.pas`

2. 🔴 **System Modülü Türkçe Dosya Sil/Birleştir**:
   - `SysParaBirimi.pas` — Database'de yok, `SysCurrency.pas` ile çakışıyor

3. 🔴 **Stock Modülü Eksik Tablolar Kararlaştır**:
   - 10 entity için DDL migration veya DEPRECATED kararı

### Kısa Vade (Gelecek Hafta) — ORTA
4. 🟡 **Personel Modülü Prefix Kararı**:
   - `Emp*` mi yoksa `Prs*` mi? Karar verilmeli
   - Eğer `Prs*` seçilirse refactoring gerekli

5. 🟡 **System Modülü Eksik Tablolar Kararlaştır**:
   - `SysResource`, `SysResourceGroup` için DDL migration veya DEPRECATED

### Uzun Vade — DÜŞÜK ÖNCELİK
6. 🔵 Mevcut kodda eski referanslar güncellenmeli (Forms, diğer modüller)
7. 🔵 Ths.dpr dosyasındaki path referansları güncellenmeli

---

**Rapor Tarihi**: 2026-07-01  
**Durum**: ✅ Audit tamamlandı — Sorunlar tespit edildi ve önceliklendirildi
