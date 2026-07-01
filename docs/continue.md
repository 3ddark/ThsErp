# Ths ERP — Devam Edilecek İşler

**Son Güncelleme**: 2026-07-01  
**Context Durumu**: Temizlenmiş, sonraki adıma hazır

---

## 📋 Tamamlanan Modüller

| Modül | Tablo | Domain | Repository | Service | Mapping Düzeltme | Durum |
|-------|:-----:|:------:|:----------:|:-------:|:----------------:|:-----:|
| **System** (`sys_*`) | 21 | ✅ 21/21 | ✅ 21/21 | ✅ 21/21 | 13 düzeltildi | ⚠️ Kısmi |
| **Account** (`acc_*`) | 14 | ✅ 14/14 | ✅ 14/14 | ✅ 14/14 | 0 (zaten doğru) | ✅ Tamam |
| **Personel** (`emp_*`) | 11 | ✅ 11/11 | ✅ 11/11 | ✅ 11/11 | DB + entity güncellendi | ✅ Tamam |
| **Stock** (`stk_*`) | 9+10 | ✅ 19/19 | ✅ 19/19 | ✅ 19/19 | 9 düzeltildi, 9 DEPRECATED | ⚠️ Kısmi |
| **Production** (`prd_*`) | 11 | ✅ 11/11 | ✅ 11/11 | ✅ 11/11 | 0 (zaten doğru) | ✅ Tamam |

---

## ✅ Yapılan Kritik Düzeltmeler

### Stock Modülü
- `StkKartlar.pas` → `StkInventory.pas` (class TStkKart → TStkInventory)
- `StkKartCinsBilgileri.pas` → `StkCardKindInfo.pas` (class TStkKartCinsBilgileri → TStkCardKindInfo)
- Repository + Service dosyaları güncellendi
- Form referansları güncellendi (18+ dosya)

### Database Eksik Tablolar
- 9 entity DEPRECATED ve silindi (set_stk_barkod_*, set_ch_firma_*, set_stk_hareket_tipi, vs.)
- `stk_product_type` tablosu eklendi (seed data: HAMMADDE=1, YARIM MAMUL=2, MAMUL=3)

### Person Modülü Prefix + Singular
- DB'de `prs_*` → `emp_*` rename yapıldı
- Tablo isimleri singular formuna çevrildi (`emp_persons` → `emp_person`, vs.)
- Entity mapping'leri güncellendi (11 dosya)

---

## 🚨 DEVAM EDİLECEK İŞLER

### 4. System Modülü — Kalan Düzeltmeler ✅ TAMAMLANDI

**Mevcut Durum**: Tüm entity mapping'leri DB ile eşleştirildi.

**Yapılanlar**:
- [x] SysViewColumn → DEPRECATED (tablo yok)
- [x] SysResourceGroup → `sys_kaynak_gruplari` + kolon ismi düzeltildi (`group_name` → `ad`)
- [x] SysResource → `sys_kaynaklar` + kolon isimleri düzeltildi (`resource_code/ad/ust_id/sira_no`)
- [x] SysLanguage → `sys_diller` + kolon isimleri düzeltildi (`kod/aciklama`)
- [x] Form referansları güncellendi (ufrmSysResourceGroup.pas, ufrmSysResource.pas)
- [x] `db_schema.sql` yedeği alındı

---

### 5. Web ERP Göçü — Hazırlık (UZUN VADE)

**Öncelikli Modüller**:
1. ✅ Account modülü — Muhasebe master data
2. ✅ Person modülü — HR foundation  
3. ⏳ Stock modülü — Ürün kataloğu
4. ⏳ System modülü — Kullanıcı, yetki, referans veriler
5. ⏳ Order/Offer/Invoice — Sipariş ve teklif süreçleri

**Yol Haritası**:
1. Go API backend (`WebERP/api-go/`)
2. React + Vite frontend (`WebERP/frontend/`)
3. Modül taşıma (Delphi → Web)
4. SAAS altyapısı (multi-tenancy, Docker, CI/CD)

---

## 📁 Önemli Dosyalar

### Raporlar
- `docs/project-status-summary.md` — Genel proje durumu
- `docs/db-schema-analysis.md` — Database schema analizi
- `docs/system-module-completion-report.md` — System modülü raporu
- `docs/account-person-stock-module-completion-report.md` — Account/Personel/Stock raporu
- `docs/production-module-completion-report.md` — Production modülü raporu

### Referans Entity'ler (Doğru Convention)
- `ERP/BackEnd/Production/Domain/PrdBom.pas` ✅ — Mükemmel örnek
- `ERP/BackEnd/Account/Domain/AccAccountPlan.pas` ✅ — Yeni eklenen

---

## 🎯 SONRAKİ ADIM

**Sırayla yapılacaklar**:

1. **System Modülü Kalan Düzeltmeler** (1-2 saat)
   - Eksik tablo entity'lerini değerlendirmek
   - Form referanslarını güncellemek
   
2. **Web ERP Göçü Başlangıcı** (kullanıcı istediğinde)
   - Go API projesi kurulumu
   - React + Vite frontend kurulumu

---

**Hazırlayan**: Claude Code  
**Tarih**: 2026-07-01  
**Amaç**: Context temizlendikten sonra hızlı devam
