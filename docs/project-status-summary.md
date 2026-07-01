# Ths ERP — Proje Son Durum Raporu

**Tarih**: 2026-07-01  
**Durum**: Aktif Geliştirme (Web ERP Göç Hazırlık Aşamasında)

---

## 1. Genel Bakış

| Alan | Detay |
|------|-------|
| **Proje** | Ths ERP + CRM + Muhasebe Masaüstü Uygulaması |
| **Teknoloji** | Delphi (Object Pascal) + FireDAC + PostgreSQL |
| **Hedef Platform** | SAAS Web ERP: Go API + React/Vite Frontend |
| **Toplam Kod** | ~450-500 BackEnd .pas, ~132 Forms .pas |
| **Database** | 84 tablo, 156 index, 18 fonksiyon, 5 view |

---

## 2. Mimari Yapı

### Katmanlı Mimari (Entity → Repository → Service)

Her modül zorunlu olarak üç katmanda organize:

```
ERP/BackEnd/{Module}/
├── Domain/       → TEntity + [Table]/[Column] attribute mapping
├── Repository/   → IRepository<T> generic CRUD
└── Service/      → ICrudService<T>, business logic, authorization
```

**Örnek**: Order modülü  
`Order/Domain/SatSiparis.pas` → `Order/Repository/SatSiparis.Repository.pas` → `Order/Service/SatSiparis.Service.pas`

### ORM İki Katman (Aktif Göç)

| Katman | Konum | Durum |
|--------|-------|-------|
| **Yeni ORM** (`Core\Base\New\`) | Attribute-driven RTTI-based | ✅ Aktif (önerilen) |
| **Eski ORM** (`Ths.Database.Table.*`) | `TFieldDB` field-description | ⚠️ Deprecated (kullanılmamalı) |

---

## 3. Modül Kapsam Analizi

### Tamamlanmış Modüller (Input + Output + Detail)

| Modül | Domain | Repository | Service | InputForms | OutputForms | DetailForms | Durum |
|-------|:------:|:----------:|:-------:|:----------:|:-----------:|:-----------:|:-----:|
| **Account** (Muhasebe) | 14 | 13 | 13 | 22 | 19 | — | 🟢 Tam |
| **Personnel** (İnsan Kaynakları) | 22 | 21 | 20 | 14 | 14 | — | 🟢 Tam |
| **System** (Sistem) | 47 | 30 | 34 | 14 | 13 | — | 🟢 Tam |

### Kısmi Tamamlanmış Modüller

| Modül | Domain | Repository | Service | InputForms | OutputForms | DetailForms | Durum |
|-------|:------:|:----------:|:-------:|:----------:|:-----------:|:-----------:|:-----:|
| **Stock** (Stok) | 37 | 35 | 34 | 18 | 10 | — | 🟡 Kısmi |
| **Order** (Sipariş) | 3 | 3 | 3 | 1 | 3 | 2 | 🟡 Kısmi |
| **Offer** (Teklif) | — | — | — | 2 | 4 | 2 | 🟡 Kısmi |
| **Invoice** (Fatura) | 5 | 5 | 5 | 7 | 6 | — | 🟢 Tam |
| **Production** (Üretim) | 9 | 9 | 9 | 2 | 4 | 6 | 🟡 Kısmi |

### Eksik Modül

| Modül | Durum | Açıklama |
|-------|-------|----------|
| **DataBank** | ❌ Yok | CLAUDE.md'de referans var ama implementasyon yok |

---

## 4. Database Schema Özeti

### İstatistikler

| Metrik | Değer |
|--------|-------|
| Toplam Tablo | 84 |
| Toplam Sütun | ~1,200+ |
| Toplam Index | 156 |
| Toplam Foreign Key | 107 |
| Toplam Sequence | 84 |
| Toplam Function | 18 |
| Toplam View | 5 |

### Modül Bazlı Tablo Dağılımı

| Prefix | Modül | Tablo Sayısı | Örnek Tablolar |
|--------|-------|:------------:|----------------|
| `sys_` | System | 18 | sys_user, sys_city, sys_currency, sys_permission |
| `acc_` | Account/Muhasebe | 14 | acc_account, acc_voucher, acc_bank |
| `prs_*` | Personnel/İnsan Kaynakları | 10 | prs_persons, prs_set_unit, prs_language_abilities |
| `stk_*` | Stock/Stok | 9 | stk_inventory, stk_transaction, stk_warehouse |
| `sls_*` | Sales/Satış | 7+2 | sls_order, sls_offer, sls_invoice |
| `prd_*` | Production/Üretim | 10 | prd_bom, prd_bom_raw, prd_labour |
| `einv_*` | E-Invoice/E-Fatura | 5 | einv_invoice_type, einv_payment_method |
| `pur_*` | Purchase/Satın Alma | 2 | pur_offer, pur_offer_detail |

### En Karmaşık Tablolar (Sütun Sayısına Göre)

1. **pur_offer** — 51 sütun (Satın alma teklifi header)
2. **sls_offer** — 49 sütun (Satış teklifi header)
3. **sls_order** — 48 sütun (Satış siparişi header)
4. **acc_account** — 33 sütun (Muhasebe hesap kartı)
5. **sls_order_detail** — 31 sütun (Sipariş detay satırları)

### Foreign Key İlişkileri (Önemli)

- `sys_city → sys_region`, `sys_country` (Coğrafi hiyerarşi)
- `sls_order/pur_offer → sys_currency` (Çoklu para birimi)
- `prd_bom → stk_inventory` (BOM ürün referansı)
- `sys_user → prs_persons` (Kullanıcı-çalışan bağlantısı)
- `acc_account → acc_group`, `acc_region` (Hesap hiyerarşisi)

### Views (Web İçin Kullanıma Hazır)

| View | Purpose |
|------|---------|
| `vw_sys_cities` | Şehir + ülke + bölge join (dropdown için ideal) |
| `sys_view_columns` | Tablo sütun metadata (dinamik form oluşturma) |
| `sys_db_status` | Aktif bağlantı izleme (admin panel) |

---

## 5. Forms Katmanı Özeti

### Toplam Form Sayısı: ~132

| Klasör | Dosya Sayısı | Açıklama |
|--------|:------------:|----------|
| **InputForms/** | 61 | Tekil entity giriş/düzenleme formları |
| **OutputForms/** | 55 | Grid/liste gösterim formları |
| **DetailedInputForms/** | 16 | Alt-alt (main-detail) formlar |
| **Core/** | 8 | Base form sınıfları |

### Base Form Sınıfları

| Class | Purpose |
|-------|---------|
| `TfrmBase` | Temel input form (modlar: New, Edit, Review, ReadOnly) |
| `TfrmBaseInput` | DB entegrasyonlu input form (`SetControlDBProperty`) |
| `TfrmGrid<TE,TS>` | Generic grid output form (otomatik filtreleme, CSV export) |
| `TfrmBaseDetaylar` | Main-detail form (çoklu StringGrid desteği) |

### Form Desenleri

**Input Form Örnek**: `ufrmChHesapKarti.pas`  
- 3 tab sheet (Ana bilgi, Adres, İletişim)
- Hiyerarşik hesap kodu (Root → Ara → Final)
- Helper formlar (Gruplar, Bölgeler, Dövizler seçimi)

**Output Form Örnek**: `ufrmSatSiparisler.pas`  
- Radyo grup filtresi (Beklemede/Hazir/Gitti/Tümü)
- Özel menü öğeleri (durum güncelle, paket listesi yazdır)
- Servis katmanı ile entegrasyon

---

## 6. Teknik Borç ve Riskler

### Önemli Teknik Borçlar

| Sorun | Etki | Öncelik |
|-------|------|---------|
| **İki ORM katmanı** | Bakım yükü, kafa karışıklığı | 🟠 Yüksek |
| **Türkçe isimlendirme** | Web göçünde uyumsuzluk | 🟡 Orta |
| **DataBank eksikliği** | CLAUDE.md ile tutarsızlık | 🔵 Düşük |
| **Singleton UnitOfWork** | Test zorluğu, web'de thread safety | 🟠 Yüksek |

### Web Göç Hazırlık Durumu

| Modül | Hazır mı? | Sebep |
|-------|:---------:|-------|
| **System** | ✅ Evet | En temiz entity modeli; kullanıcılar, yetkiler, referans veriler |
| **Account (Banka)** | ✅ Kısmi | Temel muhasebe master data; nispeten basit schema |
| **Stock** | ⚠️ Hazırlanmalı | 37 domain entity; bazıları eski/boş tablo olabilir |
| **Order/Offer/Invoice** | ⚠️ Hazırlanmalı | Karmaşık alt-alt ilişkiler; dikkatli API tasarımı gerekli |
| **Production (BOM)** | ❌ Hayır | Recete yapısı (hammadde + işçilik + yan ürün); nested endpoint'ler gerekli |

---

## 7. Web Göç Yol Haritası (Önerilen)

### Aşama 1: Delphi Şemasını Finalize Et (1-2 Hafta)
- [ ] Türkçe isimlendirmeyi İngilizceye çevir (`db_schema.sql` kaynak)
- [ ] Eksik entity/repository/service katmanlarını tamamla
- [ ] Mevcut kod dokümantasyonunu güncelle

### Aşama 2: Go API Backend — System Modülü (3-4 Hafta)
```go
WebERP/api-go/
├── cmd/server/main.go
├── internal/
│   ├── config/db.go
│   ├── modules/sys/        ← Kullanıcı, yetki, referans veriler
│   └── middleware/auth.go  ← JWT authentication
├── migrations/             ← DB migration dosyaları
└── go.mod
```

**Öncelikli Endpoint'ler**:
- `GET /api/v1/users` — sys_user + prs_persons join
- `POST /api/v1/auth/login` — JWT authentication
- `GET /api/v1/reference/cities` — vw_sys_cities view
- `GET /api/v1/reference/currencies` — sys_currency

### Aşama 3: React Frontend Temeli (5-6 Hafta)
```tsx
WebERP/frontend/
├── src/components/Layout.tsx      ← Sidebar + Header + Breadcrumb
├── src/pages/System/Cities.tsx    ← AG-Grid tabanlı liste
├── src/services/api.ts            ← TanStack Query wrapper
└── package.json
```

**Temel Bileşenler**:
- Grid: AG-Grid (server-side filtering)
- Formlar: React Hook Form + Zod validation
- State: Zustand (global), TanStack Query (API data)

### Aşama 4: Modül Taşıma Sırası
1. **Account** (Banka, HesapKarti) — Temel muhasebe master data
2. **Personnel** (Çalışanlar) — HR foundation
3. **Stock** (Stok Kartları) — Ürün kataloğu
4. **Order/Offer/Invoice** (Sipariş/Teklif/Fatura) — Karmaşık multi-detail
5. **Production** (Üretim/BOM) — Son aşama (en karmaşık)

### Aşama 5: SAAS Altyapısı (7-8 Hafta)
- Multi-tenancy tasarımı (tenant_id kolonu veya izole schema)
- Tenant provisioning akışı
- Docker Compose deployment (`api-go`, `frontend`, `postgres`)
- CI/CD pipeline (GitHub Actions)

---

## 8. Kararlar ve Standartlar

### İsimlendirme Kuralları (ZORUNLU)

| Kural | Format | Örnek |
|-------|--------|-------|
| **Tablo prefix** | Modül kodu + `_` | `sys_user`, `acc_account`, `prs_persons` |
| **Sütun adı** | İngilizce snake_case | `first_name`, `tax_rate`, `currency_code` |
| **Form dosyası (Input)** | `ufrm{EntityName}.pas` | `ufrmSysCity.pas`, `ufrmChBanka.pas` |
| **Form dosyası (Output)** | `ufrm{CogulIsim}.pas` | `ufrmSysCities.pas`, `ufrmChBankalar.pas` |

### Mimari Kurallar (ZORUNLU)

1. **Entity → Repository → Service** katmanları ayrılmaz
2. **Formlar** sadece `InputForms/` veya `OutputForms/` altında modül klasörlerinde
3. **DB DDL değişiklikleri** sonrası mutlaka `db_schema.sql` yedeği al
4. **Türkçe DB isimleri** yasak — İngilizce snake_case zorunlu

---

## 9. Sonraki Adımlar (Bekleniyor)

Kullanıcıdan gelecek talimatlar:
- [ ] Web ERP göçüne başlanacak mı?
- [ ] Hangi modül öncelikli?
- [ ] Go API mi yoksa React Frontend mi önce?
- [ ] Mevcut Delphi uygulamasında eksiklikler tamamlanacak mı?

---

**Rapor Tarihi**: 2026-07-01  
**Son Güncelleme**: DB Schema analizi tamamlandı (5,530 satır schema dump incelendi)  
**Durum**: Web ERP Göç Hazırlık Aşamasında — Sistem Modülü için Go API geliştirilmeye hazır
