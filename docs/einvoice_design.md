# e-Fatura (UBL-TR 1.2.1) Tasarımı

Kaynak: GİB UBL-TR 1.2.1 paketi (`docs/UBL-TR1.2.1_Paketi`: XSD, örnek XML, `general.xslt`) ve kılavuzlar
(`docs/UBLTR_1.2.1_Kilavuzlar`: Fatura V1.0, Ortak Elemanlar V0.7, Kod Listeleri **V1.43 / Temmuz 2026**, senaryolar).
Durum (2026-10-16): veri modeli, tanım tabloları + ekranları, satış faturası alanları ve iş kuralları hazır.
UBL XML üretimi, imza ve entegratör gönderimi **sonraki adım** (aşağıda).

## 1. Tanım tabloları (`einv_*`, kullanıcı ekranlardan değiştirir)

Hepsi `code` (UNIQUE) + `name` + `is_active`. Kodlar silinmez: kullanılıyorsa servis reddeder, pasif yapılır
(pasif kod yeni seçimde reddedilir, kayıtlı belgede değişmedikçe kalır). Yardımcı listeler yalnız aktif kayıtları gösterir.

| Tablo | UBL elemanı | Ek alanlar (kurallar bunlardan okunur) | Tohum | Yetki | Menü |
| --- | --- | --- | --- | --- | --- |
| `einv_profile` | `ProfileID` (senaryo) | `document_kind` 1 fatura / 2 irsaliye, `requires_export_info` | 16 | 1050 | 600901 |
| `einv_invoice_type` | `InvoiceTypeCode` | `requires_exemption`, `requires_withholding`, `is_return` | 18 | 1051 | 600902 |
| `einv_tax_exemption` | `TaxExemptionReasonCode` | `exemption_group` 1-7, `einv_invoice_type_id` (kullanılabildiği tip, boş = tümü), `requires_gtip`, `requires_diib`, `requires_zero_vat` (KDV istisnası: %0 KDV'li kalem ister) | 112 | 1052 | 600903 |
| `einv_tax_type` | `TaxTypeCode` | `short_name` | 29 | 1053 | 600904 |
| `einv_withholding` | `WithholdingTaxTotal/TaxTypeCode` | `rate` (KDV'nin tevkif yüzdesi, 9/10 = 90) | 52 | 1054 | 600905 |
| `einv_delivery_term` | `DeliveryTerms/ID[@schemeID=INCOTERMS]` | `is_incoterms` (firma içi teslim şekilleri de burada, e-belgeye yazılmaz) | 15 + 4 | 1056 | 600907 |
| `einv_transport_mode` | `ShipmentStage/TransportModeCode` | — | 8 | 1057 | 600908 |
| `einv_packaging_type` | `ActualPackage/PackagingTypeCode` | — | 27 | 1058 | 600909 |
| `einv_payment_means` | `PaymentMeans/PaymentMeansCode` (UN/EDIFACT 4461) | — | 10 | 1059 | 600910 |
| `einv_gtip` | `GoodsItem/RequiredCustomsID` | 12 hane (noktalı giriş kabul, `0206.22.00.00.00`) | — | 1049 | 400906 |
| `einv_diib` + `einv_diib_line` | `CustomsDeclaration/IssuerParty/PartyIdentification/ID[@schemeID=SATICIDIBSATIRKOD / ALICIDIBSATIRKOD]` | belge: `holder_type` 1 firmamız / 2 müşteri (+cari), geçerlilik; satır: `line_code`, `line_kind` ihraç / ithal, GTİP, **DİİB ürün tanımı**, stok kartı, miktar, birim (`sys_uom_id`) | — | 1094 | 600101 / 600102 |

İstisna grupları (`exemption_group`): 1 KDV kısmi (2xx, ISTISNA), 2 KDV tam (3xx, ISTISNA; **351 → SATIS**: istisna olmayan
%0 KDV), 3 diğer işlem türü (555, SATIS), 4 ÖTV (1xx, ISTISNA), 5 konaklama vergisi (001), 6 özel matrah (8xx, OZELMATRAH),
7 ihraç kayıtlı / DİİB / geçici kabul (70x, IHRACKAYITLI; **702 `requires_gtip` + `requires_diib`**).

Yeni bir kod listesi sürümü geldiğinde: ilgili ekranda kod eklenir / adı düzeltilir / pasif yapılır; kural bayrakları
(zorunlu istisna, tevkifat, GTİP, DİİB, ihracat bilgisi) de ekrandan değişir — kod değişikliği gerekmez.

## 2. Satış faturası alanları

Başlık (`sls_invoice`, ekranda **e-Belge / İhracat** sekmesi):

| Kolon | UBL | Not |
| --- | --- | --- |
| `einv_profile_id` | `ProfileID` | boş = kağıt fatura. Cari seçilince öneri: e-Fatura mükellefi → TEMELFATURA, değilse EARSIVFATURA; tip SATIS |
| `einv_invoice_type_id` | `InvoiceTypeCode` | senaryo varsa zorunlu |
| `einv_uuid` | `UUID` (ETTN) | senaryo seçilince servis üretir, bir daha değişmez; kopyada boşalır |
| `einv_status` | — | 1 taslak, 2 kuyrukta, 3 gönderildi, 4 kabul, 5 red, 6 hata, 7 iptal (`EInvLookup`). Servis tutar; 2/3/4/5/7 → fatura ve kalemleri kilitli |
| `einv_tax_exemption_id` | `TaxTotal/TaxSubtotal/TaxCategory/TaxExemptionReasonCode` | %0 KDV'li kalem yalnız istisna koduyla |
| `einv_delivery_term_id`, `einv_transport_mode_id` | `Delivery/DeliveryTerms/ID`, `ShipmentStage/TransportModeCode` | IHRACAT senaryosunda zorunlu (INCOTERMS) |
| `einv_payment_means_id` | `PaymentMeans/PaymentMeansCode` | |
| `customs_declaration_no`, `gtb_ref_no`, `actual_export_date` | GTB yanıtı (`GCB_TESCILNO`, `GTB_REFNO`, `GTB_FIILI_IHRACAT_TARIHI`) | ihracat kapanışı |
| `withholding_amount` | `WithholdingTaxTotal/TaxAmount` | kalemlerden; ödenecek = toplam − tevkifat (`vw_sls_invoice.payable_amount`, cari borç da bu) |

Kalem (`sls_invoice_detail`, satır formunda **e-Belge / İhracat** bölümü):

| Kolon | UBL | Not |
| --- | --- | --- |
| `einv_gtip_id` | `Delivery/Shipment/GoodsItem/RequiredCustomsID` | gerektiğinde boşsa stok kartından / DİİB satırından |
| `einv_withholding_id`, `withholding_amount` | `WithholdingTaxTotal` (kalem) | tutar = KDV × oran |
| `seller_einv_diib_line_id` | `…/PartyIdentification/ID[@schemeID=SATICIDIBSATIRKOD]` | firmamızın DİİB satırı |
| `buyer_einv_diib_line_id` | `…[@schemeID=ALICIDIBSATIRKOD]` | faturadaki müşterinin DİİB satırı (702'de zorunlu) |
| `einv_packaging_type_id`, `package_no`, `package_quantity`, `package_brand` | `TransportHandlingUnit/ActualPackage` (cins / ID / Quantity), `InvoiceLine/Note` (marka) | IHRACAT'ta cins + adet zorunlu |
| (görünüm) `diib_product_description` | — | alıcı DİİB satırı → satıcı satırı → stok kartı |
| (görünüm) `uom_einv_code` | `InvoicedQuantity/@unitCode` | `sys_uom.unit_einv` (ayrı e-belge birim tablosu yok; GİB / UN/ECE Rec 20 kodu ölçü birimi kartında tutulur) |

Stok kartı: `stk_inventory.hs_no` (serbest metin) → `einv_gtip_id` (GTİP tanımı; mevcut değer aktarıldı) ve
`diib_product_description` 512 karakter.

## 3. Kurallar (`TSlsInvoiceService.CheckEInvoice`; belge kaydı ve tek kalem yolu ortak)

1. Senaryo fatura türünde olmalı (`document_kind` = 1); tip zorunlu; yeni seçilen kodlar aktif olmalı.
2. Tip `requires_exemption` → istisna kodu zorunlu. İstisna kodunun tipi doluysa faturanın tipiyle aynı olmalı.
3. %0 KDV'li kalem ancak istisna kodu varsa (GİB: KDV'siz kalem istisna / muafiyet kodu ister).
4. Senaryo `requires_export_info` (IHRACAT) → teslim şartı (INCOTERMS) + taşıma şekli; her kalemde GTİP + kap cinsi + kap adedi.
5. İstisna `requires_gtip` → her kalemde GTİP; `requires_diib` (702) → her kalemde alıcı DİİB satırı.
6. DİİB satırı: satıcı satırı firmamızın belgesinden, alıcı satırı faturadaki müşterinin belgesinden; belge / satır aktif,
   süresi dolmamış (yeni seçimde); kalem GTİP'i DİİB satırının GTİP'iyle aynı (boşsa oradan alınır).
7. Tevkifat: tip `requires_withholding` → en az bir kalemde kod; tevkifat tipi olmayan e-belgede kod yok; KDV'siz kalemde yok.
8. Gönderilmiş e-belge (durum 2/3/4/5/7) değiştirilemez / silinemez (başlık, belge kaydı, tek kalem yolu).
9. `requires_zero_vat` kodu (2xx, 3xx — 351 dahil —, 701 / 702 / 704) faturada en az bir %0 KDV'li kalem ister; ÖTV (1xx, 703),
   konaklama (001), özel matrah (8xx) ve 555 KDV'li kalemle kullanılır. UBL'de istisna kodu yalnız %0 KDV'nin `TaxSubtotal`'ına yazılır.

### Alan kapsamı (`TSlsInvoiceService.GetEInvScope` → `TSlsEInvScope`)

Formlar (fatura başlığı ve kalem) yalnız kapsamdaki alanları **gösterir** (gizlenen satırların yerine alttakiler kayar; kalem
formunda e-Belge bölümü boşsa gizlenir ve form kısalır; tevkifat KDV %0 iken görünür ama pasif) ve zorunlu işaretler; `CheckEInvoice` aynı kapsamla
uygulanamayan alanları kayıtta **temizler** (`ClearNotApplicable*`), kural ihlallerini reddeder. Hepsi kod listesi bayraklarından.

| Alan | Görünür olduğu durum | Zorunlu |
| --- | --- | --- |
| Fatura tipi, ödeme şekli, ETTN, e-belge durumu | senaryo var (kağıt faturada gizli) | tip: senaryo varsa |
| Teslim şartı, taşıma şekli, gümrük çıkış no, GTB ref no, fiili ihracat tarihi | `requires_export_info` (IHRACAT) | teslim + taşıma |
| İstisna kodu | tip istisna ister / %0 KDV'li kalem var / tipte `requires_zero_vat` olmayan kod var (555, ÖTV …) | tip istisna ister ya da %0 KDV'li kalem var |
| Kalem GTİP + kap cinsi / no / adet / marka | IHRACAT ya da istisna `requires_gtip` (702) | GTİP: aynı; kap cinsi + adet: IHRACAT |
| Satıcı / alıcı DİİB satır kodu | istisna `requires_diib` (GİB: yalnız IHRACKAYITLI + 702) | alıcı |
| Tevkifat kodu | kağıt fatura ya da tip `requires_withholding`, kalem KDV > 0 | en az bir kalemde (tevkifat tipi) |

Ek davranışlar: tip değişince başka tipe ait istisna kodu kalkar; istisna seçim listesi %0 KDV'li kalem yoksa (ve tip istisna
istemiyorsa) yalnız `requires_zero_vat` olmayan kodları gösterir; senaryo seçilip tip boşsa öneri (IHRACAT → ISTISNA, diğerleri
→ SATIS); kalemde KDV %0 olunca tevkifat kalkar; stok kartının GTİP'i yalnız gümrüklü kalemde alınır.

## 4. UBL XML (2026-10-17, hazır)

Akış: fatura kaydı (`TSlsInvoiceService.AfterDocumentSaved`, aynı transaction) → `TEInvDocumentService.GenerateForInvoice` →
`TEInvDocumentRepository.LoadSalesInvoice` (DTO `EInvUbl.Model`) → `TEInvUblBuilder` (saf, XSD sırası) →
`TEInvUblValidator` (MSXML6 XSD) → `einv_document` (fatura başına tek satır: xml, `is_valid`, `validation_message`).
Kağıt faturada kayıt silinir; gönderilmiş (kilitli) belgenin XML'i değişmez; veri / şema sorunları kaydı engellemez.

- Belge no (`cbc:ID`): `sls_invoice.einv_no` (GİB biçimi seri + yıl + 9 hane, **gönderimde** verilir — taslakta numara
  harcanmaz, boşluk olmaz). Taslak XML'de önizleme numarası: kapsamın varsayılan serisi + yıl + `000000000`.
  Seriler `einv_series` (ekran Satış > e-Belge Ayarları > e-Belge Serileri 600911, yetki 1055; kapsam 1 e-Fatura / 2
  e-Arşiv / 3 e-İrsaliye; kullanılacak seri firma ayarından, §7), sayaç `einv_series_counter` (`TEInvSeriesRepository.NextNumber`, kilitli artış).
- Taraflar: satıcı `sys_application_setting` (unvan, VKN/TCKN — `taxpayer_type` 'TCKN' = gerçek kişi —, vergi dairesi,
  adres `sys_address_id`); alıcı cari + `acc_account_taxpayer` (1 tüzel / 2 gerçek kişi) + fatura adresi (BILLING, yoksa
  birincil / yasal). e-Arşiv'de kimliksiz alıcı 11111111111. IHRACAT: AccountingCustomerParty = GTB (1460415308),
  BuyerCustomerParty = cari (PARTYTYPE EXPORT, PartyLegalEntity), kalemde teslim adresi / INCOTERMS / GTİP / taşıma / kap.
  702: kalemde GTİP + `CustomsDeclaration/IssuerParty` SATICIDIBSATIRKOD / ALICIDIBSATIRKOD (ID = DİİB belge no).
- Tutarlar: kalem LineExtension = net, AllowanceCharge = kalem iskontosu; belge LineExtension = brüt, AllowanceTotal =
  iskonto, TaxExclusive = net, TaxInclusive = net + KDV, Payable = TaxInclusive − tevkifat; KDV alt toplamı orana göre,
  istisna kodu yalnız %0 alt toplamında; tevkifat kalemde + belgede. `sys_currency` 'TL' → 'TRY'; dövizde PricingExchangeRate.
- İmza: `ext:UBLExtensions/ExtensionContent` boş (özel entegratör mali mührüyle imzalar); doğrulama kopyasına yer tutucu.
- Şema / görsel: `ERP/Resource/EInvoice` (README: GİB paketinden iki MSXML düzeltmesi). UI: satış faturası listesi popup
  Önizle (general.xslt → tarayıcı), Doğrulama Sonucu, XML Kaydet, Yeniden Oluştur; liste kolonları e-Belge No / XML Geçerli.
- Testler: TestEInvoice (e-Arşiv SATIS, TEVKIFAT, IHRACAT, 702 şemaya uygun; eksik satıcı VKN; kağıt fatura; sayaç).

## 5. Sonraki adımlar

- **Entegratör katmanı**: `IEInvIntegrator` (gönder, durum sorgula, PDF / XML indir, gelen faturalar, mükellef sorgula) +
  entegratör başına sınıf (QNB eFinans, Logo eLogo …), ayarda aktif entegratör / kullanıcı / test-canlı ortam.
  Test hesabı (WSDL / API adresi, kullanıcı / şifre) gelince eklenecek.
- **"e-Fatura Gönder" komutu** (kullanıcı kararı: kayıtta otomatik değil): transaction içinde `einv_no` = varsayılan seri +
  yıl + `NextNumber`, XML yeniden üretilir, şemaya uygun değilse gönderilmez, entegratöre iletilir, `einv_status`
  2 kuyrukta → 3 gönderildi / 6 hata (durum yazma iş kuralı kilidinden bağımsız ayrı repository metodu).
- AdditionalDocumentReference (XSLT eki, e-Arşiv gönderim şekli ELEKTRONIK / KAGIT) entegratör gereksinimine göre.
- Uygulama yanıtı (TICARIFATURA KABUL / RED), iade faturası (`BillingReference`). e-İrsaliye: §6.
- Alış tarafı: gelen e-faturaların alınması (satın alma faturası).

## 6. e-İrsaliye (DespatchAdvice, 2026-10-18 — giden irsaliye + XML; gönderim / gelen irsaliye / yanıt yok)

Kaynak: GİB UBL-TR İrsaliye kılavuzu V1.2 ve Temel İrsaliye Senaryosu V0.3 (`docs/UBLTR_1.2.1_Kilavuzlar`), şema
`xsdrt/maindoc/UBL-DespatchAdvice-2.1.xsd`, görsel `irsaliye.xslt`. Kullanıcı kararları: ilk aşama yalnız giden e-İrsaliye
(e-Fatura ile aynı düzey: üret / doğrula / önizle); araç ve şoför **tanım kartları**, taşıyıcı firma = cari kart;
XML'e **fiyat / tutar yazılmaz**.

| Yer | Alan | Not |
| --- | --- | --- |
| `acc_account.e_despatch_active` | e-İrsaliye mükellefi | e-Fatura mükellefiyetinden ayrı; cari kartında e-Fatura işaretinin yanında |
| `einv_vehicle` (yetki 1095, menü 600912) | `plate_no` (UNIQUE, boşluk / tire atılır, 4-16 harf / rakam), `is_trailer`, `is_active` | kullanılan kayıt silinmez (pasif yapılır) |
| `einv_driver` (yetki 1096, menü 600913) | `first_name`, `family_name`, `national_id` (TCKN, kontrol haneleri; UNIQUE), `phone` | aynı |
| `sls_dispatch` | `einv_profile_id` (boş = kağıt irsaliye), `einv_uuid`, `einv_status` 1-7, `einv_no` (gönderimde), `despatch_time` | CHECK: senaryo / ETTN / durum birlikte |
| `sls_dispatch` | `carrier_acc_account_id`, `einv_vehicle_id`, `trailer1/2_einv_vehicle_id`, `driver1/2_einv_driver_id` | ikinci dorse / şoför birinci olmadan olmaz (CHECK) |
| `einv_series.series_scope` | 3 = e-İrsaliye | kullanılan seri firma ayarından (§7) |
| `einv_document.sls_dispatch_id` | irsaliye XML'i (UNIQUE, CASCADE) | belge fatura ya da irsaliye (tam olarak biri; CHECK) |

Kurallar (`TSlsDispatchService.CheckEDespatch`; başlık, belge kaydı ve tek kalem yolu ortak):

1. Senaryo irsaliye türünde olmalı (`document_kind` = 2); yeni seçilen senaryo / araç / dorse / şoför aktif olmalı.
2. Senaryo seçilince durum 1 (taslak), ETTN bir kez üretilir, fiili sevk saati boşsa şimdiki saat.
3. Taşıma (GİB): taşıyıcı firma **ya da** araç plakası + en az bir şoför (yalnız e-İrsaliyede zorunlu). Araç dorse olamaz,
   dorse alanındaki kart dorse olmalı, aynı dorse / şoför iki kez seçilemez (kağıt irsaliyede de).
4. Gönderilmiş e-İrsaliye (durum 2/3/4/5/7) değiştirilemez / silinemez; kalemi eklenemez / değişemez / silinemez.
5. Kopyada ETTN / durum / GİB no / saat kopyalanmaz (taşıma kalır). e-İrsaliye mükellefi cari seçilince senaryo
   TEMELIRSALIYE önerilir (`SuggestEDespatch`).

XML (`TEInvDocumentService.GenerateForDispatch` ← `TSlsDispatchService.AfterDocumentSaved`; kaydı engellemez): sıra XSD'ye göre
`ProfileID`, `ID` (seri + yıl + sıra; taslakta firma ayarındaki e-İrsaliye serisi + yıl + 000000000), `UUID`, `IssueDate` /
`IssueTime` (irsaliye tarihi / fiili sevk saati), `DespatchAdviceTypeCode` SEVK, `OrderReference` (siparişli irsaliye),
`Signature`, `DespatchSupplierParty` (uygulama ayarları), `DeliveryCustomerParty` (cari; **SHIPPING** adresi, yoksa birincil /
yasal), `Shipment` (ShipmentStage: `LicensePlateID schemeID=PLAKA` + `DriverPerson` ad / soyad / Şoför / TCKN; Delivery:
`CarrierParty` + `Despatch/ActualDespatchDate|Time`; TransportHandlingUnit: `TransportEquipment ID schemeID=DORSEPLAKA`),
`DespatchLine` (`DeliveredQuantity unitCode` = `sys_uom.unit_einv`, `OrderLineReference/LineID` = sipariş kalem no,
`Item` açıklama / ad / stok kodu). Taraf / adres okuma fatura ile ortak (`ReadSupplier`, `ReadAccountParty`, `ReadAddress`).
Validator belge türünü kök elemandan seçer (şema + XSLT ayrı önbellek).

UI: irsaliye detayında **e-İrsaliye / Taşıma** sekmesi (senaryo, ETTN, durum, fiili sevk saati, taşıyıcı, araç, dorse 1-2,
şoför 1-2; seçim listeleri yalnız aktif kayıtlar, araç / dorse ayrı); irsaliye listesinde popup e-Belge Önizle / Doğrulama
Sonucu / XML Kaydet / Yeniden Oluştur + kolonlar (senaryo, ETTN, durum, e-Belge No, plaka, şoför, taşıyıcı, XML Geçerli).
Test: `TestEDespatch` (25 adım).

Sonraki: e-İrsaliye gönderimi entegratörle (e-Fatura ile aynı katman), gelen e-İrsaliye → satın alma mal kabulü, İrsaliye
Yanıtı (ReceiptAdvice: kabul / kısmi / eksik-fazla), MATBUDAN tipi (kağıt irsaliyenin sonradan e-İrsaliyesi).

## 7. Entegrasyon servisleri (framework) ve e-Belge ayarları (2026-10-18)

Kullanıcı kararları: genel tablo + modül eki (gevşek bağ; yapı ileride tek başına framework olarak paylaşılacak),
varsayılan seri **yalnız firma ayarlarından** (`einv_series.is_default` kaldırıldı), ayrı ekranlar.

| Katman | Birim / tablo | Not |
| --- | --- | --- |
| Çekirdek (bağımlılıksız) | `BackEnd/Core/ApiService.Config.pas` | `TApiServiceConfig` (sağlayıcı, ortam test / canlı, URL, kullanıcı, çözülmüş parola / API anahtarı, zaman aşımı, `Option(ad)`), `IApiServiceConfigSource`, `TApiServiceConfigs.Get(kind)` |
| Uygulama kaynağı | `SysApiService.ConfigSource` | `sys_api_service` + şifre çözme (AES-SHA256, `Ths.Globals.DecryptStr`); `initialization`'da kendini kaydeder |
| Genel tablo | `sys_api_service` (yetki 1113, Sistem > Ayarlar > Entegrasyon Servisleri 100911) | firma ayarına bağlı (CASCADE), servis türü başına tek kayıt (`service_kind` serbest kod: `einvoice` / `earchive` / `edespatch` / ileride `sms` …), `options` jsonb (sağlayıcıya özel), `password_enc` / `api_key_enc` şifreli; view yalnız `has_password` / `has_api_key` |
| e-Belge eki | `einv_document_setting` (yetki 1097, Satış > e-Belge Ayarları 600914) | firma ayarı + belge türü (`series_scope` 1 e-Fatura / 2 e-Arşiv / 3 e-İrsaliye, UNIQUE) → seri (aynı türden olmalı), gönderici etiketi (GB), kullanılacak API servisi (SET NULL) |

- Modüller servis ayarını yalnız `TApiServiceConfigs.Get('<kind>')` ile okur; `sys_api_service`'i bilmez. Genel tablo modülleri
  bilmez; modüle özel alanlar (seri, etiket) modülün kendi ek tablosundadır.
- Gizli bilgiler formda gösterilmez: boş bırakılırsa değişmez, "kayıtlı parola / anahtarı sil" ile silinir.
- Taslak / önizleme numarası: `TEInvSeriesRepository.DefaultSeries(scope)` = firma ayarındaki belge türü satırının aktif serisi.
- Uygulama ayarları formunda Entegrasyon Servisleri / e-Belge Ayarları butonları ana ekran action'larını adıyla çalıştırır
  (derleme bağımlılığı yok).
- Test: `TestApiServices` (şifreli saklama, `TApiServiceConfigs` ile çözülmüş okuma, boş = değişmez, silme, tür / JSON
  doğrulaması, seri türü uyumu, varsayılan seri ayardan).
