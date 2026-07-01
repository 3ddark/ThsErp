# DB Şema Değerlendirme Raporu

**Tarih:** 2026-06-30  
**Veritabanı:** ths_erp (PostgreSQL 18.3)  
**Tablo Sayısı:** ~74 public tablo  
**Kritik Kurallar:** Türkçe isim yasak, Entity ↔ DB uyumlu olmalı

---

## 1. CRITICAL — Entity ↔ DB Tablo Adı Uyuşmazlığı (4 adet)

Delphi entity sınıflarındaki `[Table()]` attribute ile gerçekteki DB tablo adları arasında **4 eşleşmeme** var. Bunlar çalışma zamanında **INSERT/UPDATE/SELECT hatalarına** yol açar.

| # | Entity Class | [Table()] Attribute | Gerçek DB Tablo | Durum |
|---|---|---|---|---|
| 1 | `TSysCurrency` | `sys_currencies` (çoğul) | `sys_currency` (tekil) | ❌ MISMATCH |
| 2 | `TSysUser` | `sys_users` (çoğul) | `sys_user` (tekil) | ❌ MISMATCH |
| 3 | `TStkCardSummary` | `stk_card_summaries` | `stk_inventory_summary` | ❌ MISMATCH |
| 4 | `TSysCountry` | `sys_countries` (çoğul) | `sys_country` (tekil) | ❌ MISMATCH |

### Çözüm Önerisi:
- Tüm entity `[Table()]` attribute'larını tekil forma indirgenmeli: `sys_currency`, `sys_user`, `stk_inventory_summary`, `sys_country`
- VEYA tüm DB tabloları çoğul forma çevrilmeli (mevcut veri kaybı riski). **Birinci yaklaşım güvenli.**

---

## 2. CRITICAL — Kolon Adında Yazım Hatası

**Dosya:** `ERP/BackEnd/System/Domain/SysCurrency.pas:17`
```delphi
[Column('currnecy'), MaxLength(3), Required()]
property Currency: string read FCurrency write FCurrency;
```
- Kolon adı **`currnecy`** (typo) olmalı, doğru olan **`currency`**.
- DB tarafında kolon adı `currency` (doğru). Entity yanlış yazıldığı için mapping başarısız olur.

---

## 3. HIGH — Index Adlarında Türkçe Karakter (CLAUDE.md ihlali)

Kurallar: *"Türkçe karakter (ç, ğ, ı, ö, ş, ü) veya Türkçe kısaltma kullanılamaz."*

**Türkçe karakter içeren index'ler:**
| Index Adı | Tablo | Problematik Karakter |
|---|---|---|
| `einv_teslim_sekli_key` | einv_delivery_type | ş (şekli) |
| `einv_fatura_tipi_key` | einv_invoice_type | ş (fatura) |
| `einv_odeme_sekilleri_key` | einv_payment_method | ş, k, i |
| `evin_tasima_ucreti_key` | einv_transport_price | ş, ğ, ı, ö |
| `prd_rhmd_sih_key` | prd_bom_raw | ş (stok_kodu) |
| `prd_labour_cost_code_key` → `gider_kodu` | prd_labour | u (gider) — *aslında ASCII ama isim Türkçe* |

**Tablo adlarında TAMAMEN Türkçe index'ler:**
| Index Adı | Tablo | Açıklama |
|---|---|---|
| `mhs_fisler_pkey` | acc_voucher | "fişler" = vouchers |
| `mhs_fis_detaylari_pkey` | acc_voucher_detail | "fiş detayları" |
| `mhs_transfer_kodlari_pkey` | acc_transfer_code | "transfer kodları" |
| `sat_teklifler_*` | sls_offer, sls_offer_detail | "teklifler" = offers |
| `sat_irsaliyeler_*` | sls_dispatch | "irsaliyeler" = deliveries |
| `als_teklifler_*` | pur_offer, pur_offer_detail | "alımlar teklifleri" |

### Toplam Türkçe index sayısı: ~25+

---

## 4. HIGH — Tablo Adlarında Tamamen Türkçe (CLAUDE.md ihlali)

Aşağıdaki tabloların **ismi tamamen Türkçe** (prefix hariç):

| Tablo | Türkçe Karşılık |
|---|---|
| `stk_card_kind_info` | stok kart cins bilgileri |
| `stk_inventory` | stok_enventar |
| `stk_inventory_summary` | stok_envanter_toplayanı |
| `stk_kind_family` | stok_cins_ailesi |
| `stk_kind_property` | stok_cins_ozellikleri |
| `stk_transaction` | stok_hareketi |
| `acc_voucher` | muhasebe_fisi |
| `acc_voucher_detail` | muhasebe_fisi_detaylari |
| `acc_transfer_code` | tahsilat_kodlari / mhs_kodlari |
| `acc_account` | hesap |
| `acc_bank_branch` | banka_subesi |
| `einv_delivery_type` | fatura_teslim_sekilleri |
| `einv_invoice_type` | fatura_tipleri |
| `einv_packet_type` | paket_tipleri |
| `einv_payment_method` | odeme_sekilleri |
| `prd_bom_raw` | _rhmd (hammadde kısaltması) |
| `prd_bom_labour` | _isçi/gider_kodu |
| `prd_packet_raw` | paket_hammadde |
| `prd_packet_labour` | paket_isci |
| `prs_persons` | kişiler |
| `pur_offer` | al_s_teklifler |
| `sls_invoice` | sat_faturalar |
| `sls_dispatch` | sat_irsaliyeler |

**Tüm bu tabloların isimleri CLAUDE.md kuralını ihlal ediyor.** Tablo adlarının İngilizce olması gerekiyor.

---

## 5. MEDIUM — Foreign Key Constraint İsim Tutarlılığı

FK constraint'lerde Türkçe isimler ve tutarsız prefix kullanımı:

| Constraint | Tablo | Problem |
|---|---|---|
| `mhs_transfer_kodlari_hesap_kodu_fkey` | acc_transfer_code | Türkçe kelime içeriyor |
| `mhs_fis_detaylari_header_id_fkey` | acc_voucher_detail | Türkçe "fiş detayları" |
| `sat_irsaliye_detaylari_header_id_fkey` | sls_dispatch_detail | Türkçe "irsaliye" |
| `als_teklifler_musteri_kodu_fkey` | pur_offer | Türkçe "teklif, müşteri kodu" |
| `sat_siparisler_ulke_id_fkey` | sls_order | Türkçe "siparişler, ülke" |

### Çözüm: `{table}_{column}_fk` formatına geçilmeli (ör: `sls_ord_country_id_fk`)

---

## 6. MEDIUM — Nullable Core Kolonlar

| Tablo | Kolon | Tip | Not Null Olmalı mı? |
|---|---|---|---|
| `stk_inventory.code` | code | varchar | ✅ evet (PRIMARY KEY olmalı) |
| `stk_inventory.name` | name | varchar | ✅ evet |
| `stk_inventory.group_id` | group_id | bigint | ✅ evet (NOT NULL) |
| `stk_inventory.measurement_id` | measurement_id | bigint | ✅ evet (NOT NULL) |
| `stk_inventory_summary.inventory_id` | inventory_id | bigint | ✅ evet (FK + NOT NULL) |

**stk_inventory tablosunda PRIMARY KEY tanımlı gibi görünüyor ama `code`/`name` kolonlarında NOT NULL kısıtı DB'de yok.** Bu, yanlışlıkla boş kayıt alınmasına izin verir.

---

## 7. MEDIUM — Generic Extensibility Kolonları (s1-s10, i1-i5, d1-d5)

3 tablo aynı generic pattern'i kullanıyor:
- **stk_kind_property**: `s1-s10` (varchar), `i1-i5` (varchar → numeric olmalı), `d1-d5` (varchar → double precision olmalı)
- **stk_card_kind_info**: `s1-s10`, `i1-i5` (integer), `d1-d5` (double precision)

**Problem:** `stk_kind_property.i1..i5` ve `d1..d5` **varchar** olarak tanımlı — numeric/double precision olmalı.
Bu kolonlar neyi temsil ediyor? Hiçbir yerde dokümante edilmemiş. Developer'lar bunu bilmiyor ve yanlış tip veri yazabiliyor.

---

## 8. LOW — acc_account Tablosunda Authorized Person Kolonları

`authorized_person_1/2/3`, `authorized_phone_1/2/3` kolonları — en az 6 kolon hardcoded. Bu dinamik olmalı:
- Öneri: `sys_authorized_person` ayrı tablo, FK ile ilişkilendir.

---

## 9. LOW — sys_grid_column_title Tablosu Gereksiz mi?

`s1-s10` pattern'deki gibi, grid title mapping'inin özel bir tabloya ihtiyacı var mı? Bu, UI tarafında config olarak saklanabilir. Ama zaten var ve sorun değil.

---

## 10. LOW — sys_uom Entity'sinde _Unit Property İsmi

```delphi
[Column('unit'), MaxLength(16), Required()]
property _Unit: string read FUnit write FUnit;
```
- Delphi naming convention'de property `Unit` veya `UnitCode` olmalı, `_Unit` değil (private prefix).

---

## 11. LOW — Index İsim Standartları

Bazı index'ler PostgreSQL otomatik isimlendirme kullanıyor:
```sql
acc_prs_pkey     -- "pr" nedir?
acc_acc_code_key -- "_key" suffix standart değil, "_pkey"/"_idx" olmalı
```

Önerilen: `{table}_{unique_column}_pk`, `{table}_{column}_uk` (unique), `{table}_{column}_ix` (non-unique)

---

## 12. DÜŞÜNMEYE DEĞER — Stok Kart Tablosu Eksikliği?

**stk_inventory** = stok kartı (ana tablo)  
**stk_card_kind_info** = stok kartın cins/biçim bilgileri  

Ama eski sistemde **"stk_cards"** adlı ayrı bir tablo vardı:
- `StkCardSummary.pas` → `[Table('stk_card_summaries')]` → aslında bu **stk_inventory_summary** ile eşleşmeli
- Eski DB'de `stk_cards` var mıydı? Yoksa `stk_inventory` zaten stok kartı mı?

**stk_inventory** hem "stok kartı" (code, name, group) hem de "envanter" (current_quantity, average_cost) verilerini tek tabloda tutuyor. Bu SRP (Single Responsibility Principle) ihlali. İki tablo olmalı:
1. `stk_card` — code, name, brand, group_id, measurements
2. `stk_inventory` — inventory_id, current_quantity, avg_cost

---

## Özet: Sorun Kategorisi

| Kategori | Adet | Durum |
|---|---|---|
| CRITICAL (çalışma zamanı hatası) | 5 | ✅ Hemen düzeltilmeli |
| HIGH (kural ihlali) | 2 | ✅ Ertelememeli |
| MEDIUM (tasarım zayıflığı) | 4 | ⏱ Planlanmalı |
| LOW (iyileştirme önerisi) | 4 | 📋 Sonraya bırakılabilir |

### Hemen düzeltilmesi gerekenler:
1. `TSysCurrency` → `[Table('sys_currency')]`, Column `currency` (typo fix)
2. `TSysUser` → `[Table('sys_user')]`
3. `TStkCardSummary` → `[Table('stk_inventory_summary')]`
4. `TSysCountry` → `[Table('sys_country')]`
5. Tüm Türkçe index/tablo isimlerini İngilizceye çevir
