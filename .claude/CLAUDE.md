# CLAUDE.md
Proje Adı: Ths Erp
Proje Veri Tabanı: Postgres
Proje Teknolojisi: Yeni Nesil Delphi ile Masaüstü uygulama
Hedef: Çalışan Erp + Crm + Muhasebe uygulama çıkartmak.
Sonraki Hedef: Mevcut code base + DB yapısı ile Web Erp katmanına taşımak.

Sonraki Hedef Platform: SAAS Go + React + Vite

Bu dosya, bu repo üzerinde çalışırken Claude Code için bağlayıcı kurallardır.
 
## Proje Klasör Yapısı
 
```
ThsERP/
├── ERP/                          ← Ana Delphi projesi
│   ├── Ths.dpr                   ← Program entry point
│   ├── Ths.inc                   ← Derleme tanımları (THSERP, MIGRATE, CRUD_MODE_PURE_SQL)
│   ├── BackEnd/                  ← Business logic
│   │   ├── System/               ← SYS entities (Domain+Repo+Service)
│   │   ├── Employee/             ← EMP entities (Domain+Repo+Service)
│   │   ├── Stock/                ← STK entities (Domain+Repo+Service)
│   │   ├── Account/               ← Muhasebe modülü (ACC)
│   │   ├── Order/                 ← Sipariş modülü
│   │   ├── Offer/                 ← Teklif modülü
│   │   ├── Invoice/                ← Fatura modülü
│   │   ├── Uretim/                  ← Üretim modülü (PRD)
│   │   ├── Core/
│   │   │   ├── Base/New/            ← Entity, Repository, Service, UnitOfWork (generic base)
│   │   │   └── Prs/                 ← Core tablo sınıfları
│   │   └── Tools/                   ← Yardımcı sınıflar
│   ├── Forms/                       ← UI layer
│   │   ├── Core/                    ← Temel form sınıfları (ufrmBase, ufrmGrid, vb.)
│   │   ├── System/                  ← System modülü formları (input + output birlikte)
│   │   ├── Account/                 ← Muhasebe modülü formları
│   │   ├── Stock/                 ← Stok modülü formları
│   │   ├── Employee/              ← Personel (Employee) modülü formları
│   │   ├── Order/                 ← Sipariş modülü formları
│   │   ├── Offer/                 ← Teklif modülü formları
│   │   ├── Invoice/               ← Fatura modülü formları
│   │   ├── Production/            ← Üretim modülü formları
│   │   ├── DetailedInputForms/    ← Detay / alt-alt form sınıfları
│   │   └── OtherForms/            ← Genel yardımcı formlar (calculator, viewer, login vb.)
│   ├── Settings/
│   └── Tools/
├── ERPDevWizard/                  ← Geliştirici yardımcı aracı
├── docs/                          ← Proje dokümantasyonu
├── CLAUDE.md                      ← Bu dosya
└── README.md
```
 
## Mimari Kural: Entity → Repository → Service
 
Her modül **zorunlu olarak** bu üç katmanlı yapıda olur. Yeni tablo/entity eklerken bu yapının dışına çıkılmaz, mevcut dosyalar bu yapıya taşınır.
 
```
ERP/BackEnd/{Module}/
├── Domain/           ← TEntity + [Table] + [Column] attribute ile DB mapping
├── Repository/       ← IRepository<T> generic CRUD + custom query'ler
└── Service/          ← ICrudService<T>, business logic + authorization
```
 
- Domain sınıfları sadece veri yapısını ve `[Table]`/`[Column]` mapping'ini tanımlar, iş kuralı içermez.
- Repository sadece veri erişimi (CRUD + custom query) içerir, iş kuralı içermez.
- Service business logic ve authorization içerir; Form/UI katmanı doğrudan Repository'ye değil Service'e bağımlı olur.
- Yeni dosya eklerken `Ths.dpr` / `Ths.dproj` içindeki path referansları (`SearchPath`, `uses`, `DCCReference`) güncellenmeli.
## PostgreSQL DB Bağlantısı
 
- **Host:** localhost
- **Kullanıcı:** postgres
- **Şifre:** qwe
- **Database:** ths_erp
- **Schema:** public
```powershell
$env:PGPASSWORD = "qwe"
& psql -h localhost -U postgres -d ths_erp -c "SELECT version();"
```
 
## ZORUNLU KURAL: Her DB İşleminden Sonra Schema Yedeği
 
Veritabanı üzerinde **herhangi bir DDL işlemi** yapıldıktan sonra (tablo/kolon/index/constraint/sequence/fonksiyon/view oluşturma, yeniden adlandırma, silme, değiştirme) **mutlaka** aşağıdaki komutla schema-only yedek alınır. Bu adım atlanmaz.
 
```powershell
$env:PGPASSWORD = "qwe"
& pg_dump -h localhost -U postgres -d ths_erp --schema-only --no-owner --no-privileges | Set-Content -Encoding utf8 'D:\Projects\ThsErp\ERP\db_schema.sql'
```
 
Linux/macOS / WSL ortamında:
```bash
PGPASSWORD=qwe pg_dump -h localhost -U postgres -d ths_erp --schema-only --no-owner --no-privileges > D:/Projects/ThsErp/ERP/db_schema.sql
```
 
- Yedek dosyası: `ERP/db_schema.sql`
- Her yedekten sonra dosyanın tarihini ve hangi DB işleminden sonra alındığını `docs/` içindeki ilgili kayda not düş.
## ZORUNLU KURAL: DB Tanımlarında Türkçe İfade Yasak
 
Yeni oluşturulan veya yeniden adlandırılan **tüm** veritabanı nesnelerinde (tablo adı, kolon adı, index adı, constraint adı, sequence adı, fonksiyon/parametre adı, view ve alias adı) **Türkçe kelime, Türkçe karakter (ç, ğ, ı, ö, ş, ü) veya Türkçe kısaltma kullanılamaz.** Tüm isimlendirme İngilizce ve `snake_case` olmalıdır.
 
- ❌ `sehir_id`, `kdv_orani`, `tutar`, `aciklama`, `firma_tipi`
- ✅ `city_id`, `tax_rate`, `amount`, `description`, `company_type`
Mevcut Türkçe isimli kolon/sequence/constraint/view alias'ları tespit edilirse, ilgili migration planına eklenip İngilizceye çevrilir; yeni Türkçe isim eklenmesine izin verilmez.
 
## ZORUNLU KURAL: Modül Prefix'leri Korunur
 
Tablo adlarındaki modül prefix'leri (`sys_`, `stk_`, `acc_`, `emp_`/`prs_set_`, `prd_`, `sls_`, `pur_`, `mhs_`, `rct_`, `einv_` vb.) **silinmez, kaldırılmaz.** Bu prefix'ler modülü belirtir ve isimlendirme standardının bir parçasıdır. Yeniden adlandırma yalnızca prefix sonrası Türkçe kelimeleri İngilizceye çevirmek içindir, prefix'in kendisi değişmez.
 
- ❌ `sys_city` → `city` (prefix silinmiş)
- ✅ `sys_cities` → `sys_city` (sadece tekilleştirme + İngilizceleştirme, prefix korunmuş)

## ZORUNLU KURAL: Forms Klasör Yapısı ve İsimlendirme

Forms katmanı **zorunlu olarak** modül bazlı tek bir seviyede organize olur. Her modülün input (tekil) ve output (çoğul) formları **aynı klasörde** yan yana bulunur. `InputForms/`, `OutputForms/` gibi ayrı hiyerarşiler oluşturulmaz.

```
ERP/Forms/
├── Core/                        ← Temel/Base form sınıfları (ufrmBase, ufrmGrid, vb.)
│   ├── ufrmBase.pas             ← Ana base form sınıfı
│   ├── ufrmGrid.pas             ← Base grid form sınıfı
│   └── ...                      ← Diğer base formlar
├── System/                      ← System modülü formları (input + output birlikte)
│   ├── ufrmSysCity.pas          ← Tekil: Şehir kaydı (INPUT)
│   ├── ufrmSysCities.pas        ← Çoğul: Şehirler listesi (OUTPUT)
│   ├── ufrmSysCountry.pas       ← Tekil: Ülke kaydı
│   ├── ufrmSysCountries.pas     ← Çoğul: Ülkeler listesi
│   └── ...                      ← Tüm System formları burada
├── Account/                     ← Muhasebe modülü formları (input + output birlikte)
│   ├── ufrmChBanka.pas          ← Tekil: Banka kaydı
│   ├── ufrmChBankalar.pas       ← Çoğul: Banka listesi
│   ├── ufrmChHesapKarti.pas     ← Tekil: Hesap kartı
│   └── ufrmChHesapKartlari.pas  ← Çoğul: Hesap kartları listesi
├── Stock/                       ← Stok modülü formları (input + output birlikte)
│   ├── ufrmStkKart.pas          ← Tekil: Stok kartı
│   └── ufrmStkKartlar.pas       ← Çoğul: Stok kartları listesi
├── Employee/                    ← Personel (Employee) modülü formları (input + output birlikte)
├── Order/                       ← Sipariş modülü formları (input + output birlikte)
├── Offer/                       ← Teklif modülü formları (input + output birlikte)
├── Invoice/                     ← Fatura modülü formları (input + output birlikte)
├── DataBank/                    ← Veri bankası formları (input + output birlikte)
├── Production/                  ← Üretim modülü formları (input + output birlikte)
├── Erp/Tek/                     ← Alış teklif modülü formları (input + output birlikte)
├── DetailedInputForms/          ← Detay / alt-alt form sınıfları (main-detail ilişkisi)
│   ├── Factory/                 ← Base detay form şablonları
│   ├── Account/                 ← Muhasebe detay formları
│   ├── Erp/Tek/                 ← Alış teklif detay formları
│   ├── Offer/                   ← Teklif detay formları
│   ├── Order/                   ← Sipariş detay formları
│   └── Production/              ← Üretim detay formları
└── OtherForms/                  ← Genel yardımcı formlar (calculator, viewer, confirmation, vb.)
```

### İsimlendirme Kuralları

| Tip | Format | Örnek | Açıklama |
|-----|--------|-------|----------|
| Tekil input form | `ufrm{EntityName}.pas` | `ufrmSysCity.pas` | Tek bir entity'nin giriş/duzenleme dialog formu |
| Çoğul output form | `ufrm{EntityName}ler.pas` | `ufrmSysCities.pas` | Entity listesini grid'de gösteren form |

- Input (tekil) ve Output (çoğul) formlar **aynı modül klasöründe** yan yana bulunur.
- Her form, ait olduğu modülün klasörüne yerleşir (`System/`, `Account/`, `Stock/`, vb.).
- Kök seviyede modülsüz orphan dosya bırakılmaz — yeni form eklenirken uygun modül klasörü seçilir.

### Göç Kuralları (eski → yeni)

| Eski Konum | Yeni Konum | Durum |
|-----------|-----------|-------|
| `InputForms/{Modul}/` altındaki dosyalar | `Forms/{Modul}/` | System tamamlandı, diğerleri sırayla |
| `OutputForms/{Modul}/` altındaki dosyalar | `Forms/{Modul}/` | System tamamlandı, diğerleri sırayla |

## 🚀 Yol Haritası: Web ERP Katmanı (SAAS — Go + React + Vite)

### Aşama 1 — Mevcut Delphi Uygulamasını Stabilize Et
1. Tüm modüllerin DB şemasını finalize et ve `db_schema.sql` yedeğini al
2. Eksik entity / repository / service katmanlarını tamamla
3. Temel CRUD iş akışlarını test et (System, Employee, Stock modülleri)
4. Mevcut kod tabanının dokümantasyonunu güncelle

### Aşama 2 — Go API Backend Oluştur
1. Proje yapısını kur: `WebERP/api-go/` altında modüler Go projesi
   ```
   WebERP/
   └── api-go/
       ├── cmd/server/          ← Entry point
       ├── internal/
       │   ├── config/           ← DB, auth config
       │   ├── pkg/              ← Ortak yardımcı sınıflar
       │   ├── modules/
       │   │   ├── sys/          ← System modülü (kullanıcı, yetki)
       │   │   ├── person/       ← Person modülü
       │   │   ├── stock/        ← Stock modülü
       │   │   └── account/      ← Muhasebe modülü
       │   └── middleware/       ← Auth, logging, error handler
       ├── migrations/            ← DB migration dosyaları
       ├── go.mod
       └── Dockerfile
   ```
2. REST API route'ları tasarla (Delphi Service katmanı ile aynı sorumlulukta)
3. PostgreSQL bağlantısı ve ORM (GORM veya sqlx) kurulumu
4. JWT tabanlı kimlik doğrulama ekle
5. Swagger dokümantasyonu entegre et

### Aşama 3 — React + Vite Frontend Oluştur
1. Proje yapısını kur: `WebERP/frontend/` altında Vite + React + TypeScript
   ```
   WebERP/
   └── frontend/
       ├── public/
       ├── src/
       │   ├── components/       ← Tekrar kullanılabilir UI bileşenleri
       │   ├── pages/            ← Sayfa komponentleri (modül bazlı)
       │   ├── services/         ← API çağrı katmanı
       │   ├── store/            ← State management (Zustand veya Redux)
       │   ├── hooks/            ← Custom React hooks
       │   ├── utils/            ← Yardımcı fonksiyonlar
       │   └── App.tsx
       ├── package.json
       ├── vite.config.ts
       └── Dockerfile
   ```
2. Layout bileşenleri (sidebar, header, breadcrumb) oluştur
3. Veri grid bileşeni (AG-Grid veya benzeri) entegre et
4. Form yönetim kalıpları (React Hook Form + Zod validasyon)
5. API servis katmanını Go backend'e bağla

### Aşama 4 — Modül Taşıma (Delphi → Web)
1. **System modülü** (kullanıcı yönetimi, yetkilendirme) — öncelikli
2. **Employee modülü** (çalışan/kişi kayıtları)
3. **Stock modülü** (stok/kalem yönetimi)
4. **Account modülü** (muhasebe kayıtları)
5. Diğer modüller (Order, Offer, Invoice) sırayla

Her modül için:
- Go API endpoint'lerini yaz
- React sayfa ve bileşenlerini oluştur
- CRUD iş akışlarını test et
- Yetkilendirme kontrollerini ekle

### Aşama 5 — SAAS Altyapısı
1. **Multi-tenancy** tasarımı — her firma için verisize izole şema veya tenant_id kolonu
2. **Tenant provisioning** — yeni firma açma akışı
3. **Docker Compose** ile local deployment (`api-go`, `frontend`, `postgres`)
4. **CI/CD pipeline** (GitHub Actions) — test, build, deploy
5. **Monitoring ve logging** yapılandırması
6. **Production deployment** hedefi: cloud provider (AWS / GCP / DigitalOcean)

### 📌 Önemli Notlar
- Web ERP, Delphi masaüstü uygulamasının **yerine** geçecek, yanında değil
- Mevcut Delphi kodundaki business logic'i Go Service katmanına taşı (kopyala değil, yeniden implemente et)
- DB şeması ortak kalacak — iki sistem aynı Postgres veritabanını kullanacak
- Geçiş sürecinde Delphi uygulaması kullanımda kalabilir; Web ERP kademeli devreye alınacak