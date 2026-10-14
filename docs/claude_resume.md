# Claude Resume State

## Goal
Modül modül stabilizasyon: System + yetki mimarisi, Employee, Account, Stock, Production (prd_) tamamlandı.
Şu anki öncelik (2026-10-10): uygulamanın UI'ını baştan sona test edip hataları düzeltmek; sls_ (satış) sonra.

## Tasarım Kararları
- Her form/kaynak için ayrı `sys_permission` satırı ve `PERMISSION_*` sabiti (`SysPermission.Service.pas`).
  - 1000-1008: System tanımları (şehir, ülke, bölge, para birimi, ölçü birimi grubu, ölçü birimi, dil, ondalık hane, adres)
  - 1100-1110: System yönetimi (kullanıcı, erişim hakkı, yetki, yetki grubu, yetki şablonu, kullanıcı şablonu, uygulama ayarı, grid kolon/filtre/sıralama, view tablo)
  - 1021: personel kartı (EmpEmployee), 1032: banka
- Yetki şablonu: `sys_permission_template` + `sys_permission_template_right`.
- Kullanıcı ↔ şablon: `sys_user_permission_template` (çoklu şablon; haklar OR ile birleşir; pasif şablon etkisiz).
- Override: `sys_access_right.is_*` = ek izin, `deny_*` = engelleme (deny kazanır; aynı hakta ikisi birden validasyon hatası).
  Etkin yetki = (şablonlar OR is_*) AND NOT deny_*  → `vw_sys_user_effective_permission`.
- Super user tüm yetki kontrollerini atlar (`TUserContext.IsSuperUser`).
- View locale stratejisi (yeni/düzeltilen view'larda): `sys_language` CROSS JOIN + çeviri LEFT JOIN, çeviri yoksa key'e düşer.
- `TEmpPerson` → `TEmpEmployee` (`emp_employee`, `vw_emp_employee`); `TSysUser.EmpPerson` → `EmpEmployee`.

## Tamamlanan (2026-09-29)
- DB migration'ları `ERP/Database/Migrations/`:
  - 00 identity sequence senkronu (14 tabloda sequence max(id) gerisindeydi)
  - 01 vw_emp_employee + vw_sys_user locale düzeltmesi (de-DE login sorunu)
  - 02 yetki kodları, system grubu, deny_* kolonları, şablon tabloları/view'ları, 4 başlangıç şablonu, audit trigger'lar
  - 03 vw_sys_address (locale + sys_country_id adı)
  - db_schema.sql güncellendi
- Faz 1: IsAuthorized (LAccess nil, super user, etkin yetki), unique kontrolü (kayıt kullanıcısı), SysAddress grid locale,
  review→update açık transaction'da Exit, insert/delete yetki kontrolü açık, update hatasında kontroller yeniden açılıyor,
  SysAccessRight MapFromQuery username/permission_name, UserContext.GetUserId Int64.
- Faz 2: EmpEmployee domain/repo/service/formlar; eski EmpPerson dosyaları silindi; referanslar güncellendi; TSysUser.Clone düzeltildi.
- Faz 3: 3 yeni entity (backend + input/output form + DFM), TfrmGrid.AddFixedFilter, erişim hakkı formunda Ek İzin/Engelle,
  kullanıcı listesinde "Yetki Şablonları"/"Özel Yetkiler" popup, şablon listesinde "Şablon Yetkileri"/"Kullanıcılar" popup,
  şablon yetkilerinde "Eksik yetkileri ekle / Tümünü ver / Tümünü kaldır", Dashboard menüsü, 4 dilde çeviri anahtarları.
- Derleme: 0 hata. SQL smoke test (rollback) başarılı.
- Kullanıcı testi geri bildirimi (2026-09-29):
  - Uom/UomGroup grid "column group_id does not exist": sys_grid_column/sys_user_grid_column'da eski kolon adları.
    Migration 04 ile temizlendi; TSysGridColumnCache.BuildSelectColumns artık view'da olmayan kolonları atlıyor (log uyarısı).
  - Input formlarda footer (36) + status bar (~20) içeriğin üzerine biniyordu: yeni/değişen 5 form + ufrmSysUomGroup,
    ufrmEmpPersonAddress, ufrmSysApplicationSetting yeniden boyutlandı. ufrmSysUomGroup DFM adı frmSysUomGroup yapıldı.
  - Kaydetme/güncelleme (btnAccept) akışları kullanıcı tarafından henüz test edilmedi.

## Employee modülü (2026-09-29, ikinci oturum)
- Migration 05 (`20260929_05_employee_module.sql`, öncesinde pg_dump -Fc yedeği alındı):
  - Kolon adları: `*_key` (person_type/section/task/unit), `emp_unit.emp_section_id`, detaylarda `emp_employee_id`,
    `emp_driver_license_type_id`, `emp_language_id`, `read/write/speak_level_id`, `sys_address_id`; FK indeksleri.
  - `emp_person_type_translation.person_type` → `name`; eksik tr/en/de çeviriler (tip, görev, de-DE) eklendi.
  - View'lar: 4 çevirili view CROSS JOIN locale; yeni `vw_emp_driver_license_type`, `vw_emp_language`,
    `vw_emp_language_level`, `vw_emp_transportation` (route hariç), `vw_emp_driver_ability`,
    `vw_emp_person_language_ability`, `vw_emp_person_address`. vw_emp_employee artık alt view'lara bağlı değil.
  - Yetkiler 1022-1029 (+de-DE çevirileri), manager şablonuna tam yetki. Detaylar 1021 kullanır.
- Kod: 11 entity Domain/Exception/Repository/Service/Output/Input+DFM yeniden üretildi (üreteç: scratchpad gen_emp.py).
  Personel listesinde popup: Ehliyetler / Dil Bilgileri / Adresler (SetFixedEmployee). Dashboard personel action'ları bağlandı.
  EmpEmployee servisine zorunlu FK kontrolü (tip/birim/görev) eklendi.
- Derleme 0 hata; SQL smoke test (rollback) başarılı. UI akışları çalıştırılarak test edilmedi.

## Sabit seçenekler (2026-09-29, migration 06)
- `emp_language_level` tablosu + EmpLanguageLevel kodu + yetki 1028 kaldırıldı; dil seviyeleri smallint 1-4 (CHECK).
- gender (1-2), marital_status (1-2), military_status (1-3 / NULL) CHECK kısıtları; test verisinde gender 0 -> 1.
- Metinler `BackEnd/Employee/Domain/EmpLookup.pas` (TEmpLookup) + JSON `emp_option.*`; combo'lar ve grid (OnGetText) aktif dile göre.

## Kan grubu / beden / sayılar (2026-09-29, migration 07)
- blood_type / clothing_size: 07'de smallint yapılmıştı, 08 ile tekrar varchar(8) (metin aynen: 'A Rh+'…'0 Rh-', 'XXS'…'5XL');
  NULL = seçilmemiş, CHECK ile liste sınırlı; formda metin combo (EmpLookup listesi, çevrilmez).
- child (0-30) ve bonus_count (0-30) NOT NULL + CHECK; formda 0-30 combo (ItemIndex = değer).
- vw_emp_employee ve ona bağlı vw_sys_user aynı tanımla yeniden oluşturuldu.

## Şifre yönetimi (2026-09-29)
- Şifre kuralı esnek: `TPasswordHelper` MIN_PASSWORD_LENGTH = 3, REQUIRE_COMPLEXITY = False (canlıda 8 / True yapılacak).
- `TSysUserService.ResetPassword` (1100 + güncelleme hakkı) ve `ChangeOwnPassword` (eski şifre doğrulanır, yetki yok);
  repository `GetPasswordHash` / `UpdatePasswordHash` (tablodan).
- UI: `Forms/System/Input/ufrmSysUserPassword` (TfrmBase diyalog); kullanıcı listesi popup "Şifre Sıfırla",
  Dashboard "Şifre Değiştir" (actsys_update_password).
- Auth.Service: sys_users -> public.sys_user (ChangePassword, ResetPassword, SetUserActive).
- Eski `Forms/Core/Input/ufrmSysPasswordChange` projede değil (TSysKullanici legacy), dokunulmadı.

## Kullanıcı adı standardı (2026-09-29, migration 09)
- Kullanıcı formu CharCase ecUpperCase; TSysUserService.ValidateBusinessRules AnsiUpperCase(Trim) (unique kontrolünden önce).
- Mevcut veri tr-TR ICU upper ile büyük harfe çevrildi ('Test' -> 'TEST').

## Yetkiye göre UI (2026-09-29)
- TfrmGrid.ApplyPermissionState: ekleme yetkisi yoksa BtnAdd + Çoğalt pasif; ShowInputForm yeni/kopya için form açmadan EnsureAuthorized.
- TfrmInputSimpleDB: FormShow'da ekle/güncelle/sil yetkileri okunur; Onayla/Güncelle/Sil butonları pasif;
  tıklama anında yeniden kontrol (review->update kilitlenmeden önce); backend Business* kontrolü aynen duruyor.

## Okuma yetkisi (2026-09-29)
- Dashboard ApplyActionPermissions (SetSession içinde): action -> yetki kodu, okuma yoksa pasif; super user hepsi açık.
- TfrmGrid.FormShow: okuma yoksa sorgu açılmaz, mesaj + WM_CLOSE (helper listeler dahil).
- AccBankBranch servisine PERMISSION_ACC_BANK (önceden kod yoktu).

## Kullanıcı x yetki satırları (2026-09-29, migration 10)
- Yeni kullanıcı: TSysUserService.BusinessInsert aynı transaction'da AddAllPermissionsToUser (tüm haklar false).
- Yeni yetki: AddPermissionToAllUser artık pasif kullanıcılara da satır açar (WHERE active kaldırıldı).
- Migration 10 mevcut kullanıcıları tamamladı (43 x 2); etkin yetki değişmez.

## Yetki yenileme (2026-09-29)
- Dashboard: actsys_refresh_permissions (Sistem menüsü en üst; kısayol YOK — F5 uygulamada Onayla/Giriş) + About dönüşü -> RefreshUserPermissions (oturum yoksa atlanır, TAppContext.IsInitialized):
  kullanıcı kaydı yeniden okunur (super_user/active/manager yerinde güncellenir), pasif/silinmişse uygulama kapanır,
  sonra SetSession (ResetSession + ApplyActionPermissions).

## Account (acc_) modülü (2026-09-29, /goal migrate module acc)
- Migration 11 (`20260929_11_account_module.sql`, öncesinde pg_dump -Fc yedeği; rename'ler koşullu/idempotent):
  - acc_bank.bank_name, acc_bank_branch.acc_bank_id/branch_code/branch_name/sys_city_id (27.09 commit'indeki adlar;
    bu makinede DB'ye hiç uygulanmamıştı, db_schema.sql 29.09 dump'ında geri dönmüştü).
  - acc_account.acc_set_account_type_id / acc_group_id / acc_region_id; region FK'si acc_account_plan'dan acc_region'a düzeltildi.
  - acc_account_taxpayer/contact.acc_account_id; acc_account_address.acc_account_id/sys_address_id (+CHECK address_type);
    taxpayer_type CHECK 1 tüzel / 2 gerçek kişi; acc_voucher_detail.acc_voucher_id.
  - Set tabloları `*_key` (account_type_key, ownership_type_key, legal_form_key) + tr/en/de çeviriler; locale view'ları CROSS JOIN.
  - 11 yeni view (bank, bank_branch, group, region, account_plan, exchange_rate, account_address, set_tax_rate,
    transfer_code, voucher, voucher_detail); vw_acc_account artık locale'li (tip adı çevrili).
  - Yetkiler 1033-1037, 3002-3005 (+çeviri, manager tam, sales/purchasing 1033-1037 r/a/u, access_right backfill).
- Kod (üreteç: scratchpad gen_acc.py + acc_config.py; gen_emp.py'nin genişletilmiş hali):
  15 entity Domain/Exception/Repository/Service; 13'ü Output+Input form (Voucher/VoucherDetail yalnız backend).
  `SetAcc*` birimleri `AccSet*` olarak yeniden adlandırıldı; ufrmAccAccountLookup(s) silindi; Forms/Account kökündeki
  ufrmAccRegions / ufrmAccSetAccountTypes Output'a taşındı. AccLookup.pas (taxpayer tipi + hesap tipi id sabitleri).
  AccAccount: 3 tabloya yazar (SaveDetails upsert), root_code/sub_code serviste koddan türetilir, 2 kolon form.
  Popup: Bankalar -> Şubeler, Hesap kartları -> Adresler. Dashboard: 9 yeni TAction + Muhasebe menüsü, sekme butonları action'a bağlandı,
  "Ara Hesap" = hesap listesi SetFixedAccountType(ACC_ACCOUNT_TYPE_INTERMEDIATE).
- Derleme 0 hata / dokunulan birimlerde uyarı yok; SQL smoke test (rollback) başarılı. UI akışları çalıştırılarak test edilmedi.
- Takip (2026-09-29, kullanıcı kararları): acc_account_plan.code UNIQUE (+ servis kontrolü, AccAccountPlan.Exception);
  yetki 1030 (account-card-settings) DB'den silindi; Forms/Account altındaki legacy Türkçe formlar (46 dosya) silindi;
  iban_currency serbest metin kalır; muhasebe fişi (voucher) proje sonuna ertelendi (yalnız backend).
- Migration dosyaları KULLANILMIYOR (ERP/Database silindi). DB değişikliği psql ile doğrudan; ardından
  ERP/db_schema.sql + ERP/db.dump yenilenir, diğer PC'ye git ile taşınır (pg_restore --clean --if-exists).

## Stock (stk_) modülü (2026-09-30, /goal "Stock modülünü tamamla")
- DB (psql ile doğrudan; öncesinde scratch pg_dump -Fc yedeği):
  - FK kolonları: stk_inventory.stk_group_id / sys_uom_id / sys_country_id (menşe) / stk_product_type_id (smallint -> bigint FK;
    eski 0 değeri ilk ürün tipine), stk_image / stk_card_kind_info / stk_inventory_summary.stk_inventory_id (ON DELETE CASCADE),
    stk_card_kind_info.stk_kind_property_id (NOT NULL; boş 2 test satırı silindi), stk_kind_property.stk_kind_family_id (yeni, opsiyonel).
  - stk_transaction (boştu) yeniden yapılandı: stk_inventory_id, transaction_type smallint (1 giriş / 2 çıkış / 3 transfer),
    from/to_stk_warehouse_id nullable + tipe göre CHECK, açılış yalnız giriş, quantity > 0, transaction_date date; sku/direction kaldırıldı.
  - stk_group.vat_rate numeric(5,2) 0-100, hesap kodları acc_account(code) FK; stk_warehouse her varsayılan tipte tek ambar
    (partial unique index); stk_product_type.product_type_name UNIQUE; iskonto CHECK 0-100.
  - fn_default_currency() bozuktu (olmayan sys_para_birimi) -> sys_application_setting.app_currency, yoksa ilk sys_currency.
  - 9 view: vw_stk_group/warehouse/product_type/kind_family/kind_property/inventory (locale, current_quantity/average_cost)/
    inventory_summary/card_kind_info/transaction.
  - Yetkiler 1042-1048 (+tr/en/de; 1041'e de-DE), manager tam, production r/a/u/d, purchasing r/a/u, sales 1041+1048 okuma.
- Kod (üreteç: scratchpad gen_stk.py + stk_config.py; gen_acc.py'ye float/memo/ref tipleri, msgs, readonly_list eklendi):
  9 entity Domain/Repository/Service (+7 Exception); 8 input + 9 output form. StkLookup (hareket tipi). Silinen: StkImage (stok kartına
  birleşti), StkCardSummary, SetStkUrunTipleri, StkStokHareketi, özet giriş formu.
  - Stok kartı: resim (stk_image) yalnız FindById'de yüklenir, değiştiyse aynı transaction'da upsert/silinir (maks. 2 MB, TWICImage);
    boş para birimleri fn_default_currency(); popup: Cins Bilgisi / Stok Hareketleri.
  - Stok hareketi servisi: tipe göre ambar kuralları + her ekle/güncelle/silde stk_inventory_summary yeniden hesaplanır
    (TStkInventorySummaryRepository.Recalculate: mevcut = açılış + giriş - çıkış, ort. maliyet, son alış).
  - Stok özeti salt okunur liste (ekle/çoğalt gizli, giriş formu yok). Ambar servisi varsayılan ambar tekilliği.
  - Cins bilgisi formu: seçilen cinsin s1..d5 etiketleri gösterilir, etiketi boş alanlar gizlenir.
  - Dashboard Stoklar menüsü: kartlar / hareketler / özetler + Ayarlar (ambar, grup, ürün tipi, cins ailesi, cins özelliği); SetAction.
- Derleme 0 hata, dokunulan birimlerde uyarı yok; SQL smoke test (rollback) başarılı. UI akışları çalıştırılarak test edilmedi.
- Karar (kullanıcı, 2026-09-30): dispatch_id / production_id irsaliye / üretim modüllerince doldurulacak; ileride stok hareket
  rapor ekranında gösterilecek (şimdilik yalnız backend). Yetki 1040 (stock-card-settings) DB'den silindi (şablon/erişim
  hakkı/çeviri satırları cascade). Forms/DetailedInputForms'u kullanıcı elle silecek (dokunma). Core/Base StkKindFamily* +
  ServiceContainer + EntityMetaProvider silindi. Forms/Stock kökündeki eski Türkçe formlar tasarım karşılaştırması için
  şimdilik kalıyor (kayıtsız, derlenmez; ufrmStkCinsAileleri silinen StkKindFamilyService'e başvurur), sonra silinecek.
  Negatif stok engellenmiyor.

## Stok kartı sekmeli tasarım + karta özel hesaplar (2026-10-09, commit 4371ce2)
- Git geçmişi tarandı: sekmeli stok kartı `f8df7b3^:ERP/Forms/Stock/ufrmStkKart.dfm` (2026-07) ve
  `11bda36^:ERP/Forms/InputForms/Stock/ufrmStkStokKarti.dfm` (2023): Genel / Parasal / Cins Özelliği / Grup Özellikleri / Özetler (+ ambar).
  Hesap kodu override'ı hiçbir commit'te yoktu (Grup Özellikleri sekmesi grubun hesaplarını salt okunur gösteriyordu); kullanıcının
  tarifine göre yeniden kuruldu.
- DB: `stk_inventory` + `vat_rate` (0-100) ve 7 hesap kolonu (raw_material_stock/usage, semi_product, sales, sales_return,
  purchase, purchase_return; acc_account(code) FK, indeksli). NULL = gruptan gelir; KDV hesapları geçerli KDV oranının
  (`COALESCE(kart, grup)`) `acc_set_tax_rate` satırından. `vw_stk_inventory` + override ve `default_*` kolonları;
  yeni `vw_stk_inventory_account` (fiş kesimi için çözümlenmiş hesaplar + adlar + is_vat_rate_overridden / overridden_account_count);
  yeni `vw_stk_inventory_warehouse` (ambar bazında miktar).
- Kod: `TStkInventory` override + Default* alanları (HasVatRate = NULL ayrımı); repository FillDefaults / AccountExists /
  GetWarehouseStocks / GetKindValues; service ValidateAccountOverrides (hesap planında olmalı), FillDefaults, GetSummary.
  `ufrmStkInventory` TPageControl: Genel / Parasal Bilgi / Cins Özelliği (salt okunur + "Cins Bilgisini Düzenle" yalnız inceleme
  modunda; UoW tek bağlantı, güncelleme modunda açık transaction var) / Grup Özellikleri-Muhasebe (karta özel | gruptan gelen) /
  Özetler (stk_inventory_summary + ambar stokları). Üreteç: scratchpad gen_stk_inventory_dfm.py.
- Not: acc_set_tax_rate test verisinde %10 ve %20 satırlarının satış/alış hesapları ters girilmiş görünüyor (dokunulmadı).

## Production (prd_) modülü (2026-10-09, commit 4371ce2)
- DB: 11 tablo id tabanlı yeniden kuruldu (eski: kod tabanlı FK, header_id/recete_id/stok_kodu/paket_id, prd_bom_labour.labor_code
  tek başına UNIQUE hatası). Test verisi (2 reçete, 3 hammadde, 1 işçilik, 1 paket + 2 kalem) id'leri korunarak taşındı.
  prd_labour: code / name / cost_type (1 işçilik, 2 makine, 3 genel üretim gideri) / sys_uom_id / unit_price / currency /
  acc_account_code (eski cost_code hesap koduydu). prd_bom: stk_inventory_id + bom_name (unique), base_quantity > 0, is_default
  (ürün başına tek, partial unique), is_active. Detaylar: prd_bom_raw (sub_prd_bom_id, scrap_rate 0-<100), prd_bom_by_product,
  prd_bom_labour, prd_packet_raw(+_detail), prd_packet_labour(+_detail), prd_bom_packet_raw/labour. 11 view (vw_prd_*;
  gross_quantity, total_amount, raw/labour/item count). notify trigger'ları.
- Yetkiler: 1061 reçete (+tüm detaylar), 1062 işçilik/gider, 1063 hammadde paketi, 1064 işçilik paketi (+tr/en/de; 1061 de-DE);
  yönetici + üretim tam, satın alma okuma; sys_access_right backfill. 1060 (bom-settings) eski, kullanılmıyor (silinmedi).
- Kod (üreteç: scratchpad gen_prd.py + prd_config.py): 11 entity Domain/Exception/Repository/Service + Output/Input form + DFM,
  PrdLookup, TLangKeys (TPrdOption, TPrd*), TValidation.MustBePositive, TDashboard.MenuProduction, 4 dilde JSON.
  Servis kuralları: zorunlu FK, miktar > 0, composite unique, varsayılan reçete tekilliği, alt reçete kendisi olamaz,
  reçete ürünü kendi hammaddesi olamaz. Popup: Reçeteler -> Hammaddeler / Yan Ürünler / İşçilikler / Hammadde Paketleri /
  İşçilik Paketleri; paketler -> Paket İçeriği. Dashboard: Üretim menüsü + Reçeteler sekmesi düğmeleri action'a bağlandı
  (actprd_bom / labour / packet_raw / packet_labour), boş actrct_* handler'ları silindi.
- Derleme (tam rebuild) 0 hata / 0 hint; dokunulan birimlerde uyarı yok. SQL dry-run (rollback) + repository kolon/view
  eşleşme kontrolü başarılı. UI akışları çalıştırılarak test edilmedi.

## UI test oturumu (2026-10-10)
- Kullanıcı Computer use'u açtı ama o oturuma araçlar gelmedi (ayar oturum başladıktan sonra açıldı) -> yeni oturumda devam.
- Kullanıcı Delphi IDE'de Clean + Build yaptı (aşağıdaki düzeltmeler dahil). Test yalnız uygulamayı debug ile açıp UI'da gezinerek
  yapılacak; Claude derleme yapmayacak (kullanıcı isteği). Her adımda ERP/Ths-YYYYMMDD.log da okunur.
- SONRAKİ ADIM: Ths.exe'yi debug ile aç, giriş yap, Dashboard'daki tüm menüleri modül modül gez (System, Employee, Account,
  Stock, Production): her liste -> filtre/sıralama/kolon, yeni kayıt, inceleme -> güncelle, kaydet, sil, popup'lar, helper (FK) seçimleri.
  Özellikle: sekmeli stok kartı (KDV alanı boş bırakılınca gruptan gelmeli, 0 olmamalı), karta özel hesaplar, reçete ekranları.
  Bulunan hataları listele, düzelt, kullanıcıya yeniden build ettirip tekrar test et.
- Kullanıcının daha önce gördüğü hatalar henüz bildirilmedi; yeni oturumda sorulabilir.
- 2026-10-10 ikinci oturum: Computer use yine gelmedi (araç listesinde yok). Yerine statik tarama yapıldı (scratchpad scan.py / dfmscan.py):
  repository SQL/MapFromQuery/BuildSelectColumns <-> DB kolonları, Domain [Column] <-> tablo, tüm view'lar çalıştırıldı (hatasız),
  locale view'larında çift/eksik satır yok, sys_grid_column / sys_user_grid_column'da eski kolon yok, 135 formda DFM<->PAS uyumlu.
  Düzeltilen: Dashboard'da bağlantısız 'Test Grid' düğmesi (btn1) ve işleyicisiz actsys_application_setting_other kaldırıldı.
  Uyarı (taşınmamış modüller, dokunulmadı): einv_* / sls_* / pur_* domain'lerinde view yok veya kolon adları DB'den farklı.
- 2026-10-10 üçüncü oturum: Computer use ile IDE'den (Delphi 13 64-bit, Win64 Debug) F9 debug testi yapıldı.
  Test edilen ve çalışan: giriş, Kullanıcılar / Erişim Hakları (inceleme->güncelle->onayla), Bölgeler (ekle+sil), Şehirler (ülke helper,
  zorunlu alan uyarısı), Stok kartı (sekmeler, KDV boş -> NULL kalıyor), Stok hareketi (ekle/sil + özet/ambar yeniden hesap),
  Reçete -> Hammaddeler popup + güncelle, Hesap kartı güncelle, Personel güncelle + Adresler (ekle/sil), dil değiştirme (en-US).
  Düzeltilen (Build 0 hata):
  - TfrmGrid.RefreshParentGrid: DisableControls içindeki AfterOpen ayarları EnableControls'ta eziliyordu -> güncellemeden sonra
    kolon başlıkları ham ad, genişlikler varsayılan. Artık EnableControls sonrası AfterDatasetOpen + ApplyLocalization.
  - TfrmGrid.ApplyDynamicFilterAndSort: tanımlı sıralama yoksa ORDER BY id (güncellenen kayıt listenin sonuna kayıyordu).
  - Dashboard F6: listede F6 (KeyDown'da kapanır) bırakılınca ana ekran KeyUp'ta 'uygulama sonlandırılacak' soruyordu ->
    FF6Pressed bayrağı (yalnız ana ekranda basılan F6).
  - Dashboard sekmeleri: Personel / Hesaplar / Stoklar FormShow'da gizleniyordu (eski yetki kodu yorumda) -> açık; btnTest gizli.
  Not edilen (işlevsel değil / kullanıcı kararı): float alanda baştaki 0 silinmiyor ('010,00' -> 10 okunur); stok hareketinde para
  birimi boş kalıyor; etiket kesilmeleri (kullanıcı: konum önemsiz); acc_set_tax_rate iade hesapları ters görünüyor.
  Dikkat: msbuild Win32 derlemesi .dcu'ları kaynak klasörüne yazıyor, IDE Win64'te F2048 verir -> IDE'de Build (Shift+F9).
  Generic TfrmGrid<> değişikliği F9 (make) ile kullanan birimlere geçmiyor -> Shift+F9 Build gerekli.
  Test edilmeyen: Muhasebe ayarları alt menüleri, yetki şablonları ekranları, kullanıcı şifre sıfırlama, cins bilgisi düzenleme,
  işçilik/paket ekranlarında ekle/sil, Excel/CSV dışa aktarma.
- Log'dan bulunan/düzeltilen:
  - Ths.Helper.Edit itFloat: boş alan çıkışta ',00' oluyordu -> 0 okunuyordu (stok kartı KDV override'ı boşken 0 kaydedilirdi).
    DoExit + Repaint artık boş float alanı boş bırakır. DB'de vat_rate = 0 kart yoktu.
  - TRepository.ExpandSQLWithParams (yalnız log): ':cn1' değeri ':cn10' içine yazılıyordu; uzun parametre adları önce değiştiriliyor.
- Derleme 0 hata (bu makinede RAD Studio 37.0: C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat).

## Servis entegrasyon testi (2026-10-10, dördüncü oturum; /goal System/Employee/Stock/Account ayrıntılı test)
- Computer use yine yok -> UI yerine servis katmanı gerçek DB'ye karşı test edildi. Paket: `ERP/Tests/Integration`
  (`./build.sh` dcc64 ile derler, çıktı `%TEMP%\ths_it`; `IntegrationTest.exe [generic|perm|perm2|specific]`).
  Her yazma transaction içinde + ROLLBACK; tam koşu öncesi/sonrası tüm tablo satır sayıları aynı (DB'ye iz bırakmıyor).
  - generic: 56 servis x (grid + find 3 dilde, çift id, FindById = Find, Clone tamlığı, kilitli inceleme -> aynı
    değerle güncelle -> yeniden oku, duplicate insert, insert -> oku -> güncelle -> sil).
  - perm / perm2: TEST kullanıcısı için 56 servisin IsAuthorized sonucu = vw_sys_user_effective_permission
    (şablon sales+production + is_/deny_ override senaryosu dahil); yetkisiz okuma her serviste reddediliyor.
  - specific: stok hareketi akışı (açılış/giriş/çıkış/transfer, özet + ambar stoğu, ondalık, taşıma, silme, 8 kural ihlali),
    stok kartı (KDV NULL/0/8.5, hesap override, resim cascade), cins bilgisi, hesap kartı (root/sub code, adres),
    aktarım kodu, personel (+servis, adres), kullanıcı (büyük harf, bcrypt, erişim hakkı satırları, şifre sıfırlama),
    erişim hakkı / şablon / deny / pasif şablon, grid filtre.
  - Sonuç: 1036 pass / 0 fail / 10 warn (boş tablolar; voucher hariç hepsi specific ile kapsandı).
- Bulunan ve düzeltilen hatalar (derleme Win64 Debug 0 hata, dokunulan birimlerde uyarı yok):
  - Unicode kaybı: repository parametreleri `.AsString` (ftString/ANSI) -> CP1254 dışı karakterler `?` oluyordu
    (sys_currency ₺/₽ sembolü kaydedilince bozuluyordu). 56 dosyada `.AsWideString(s)` / `ftWideString`.
  - Ondalık kaybı: `.AsCurrency` PG `money` olarak gidiyordu -> 2 haneye yuvarlama (kur 27.0137 -> 27.01; stok/üretim
    numeric(…,6) miktar/fiyatlar) ve AccSetTaxRate güncellemesinde `numeric = money` hatası. 17 dosyada `.AsBCD(s)`,
    StkInventory vat_rate `ftBCD`, AccSetTaxRate unique filtresi Double.
  - SysUser: personel boşken ham FK hatası -> servis "Personel: Alan zorunludur"; ResetPassword / ChangeOwnPassword
    çağıranın açık transaction'ını commit ediyordu -> yalnız kendi açtığını commit eder.
  - Türkçe büyük harf: servislerde AnsiUpperCase (sistem locale'i) 'hesabı' -> 'HESABı' yapıyordu. Ths.Helper.BaseTypes
    `UpperCaseTr`; ad alanlarında (kullanıcı adı, hesap/plan/grup/bölge adı, banka/şube adı, ehliyet adı) kullanılıyor;
    key/kod/IBAN/SWIFT AnsiUpperCase'te kaldı. UpCaseTr/LowCaseTr (Edit/ComboBox/Memo) ASCII dışı harfleri
    (ö, ä, é …) çevirmiyordu -> Unicode ToUpper/ToLower.
  - AccAccountAddress: adres tipi seçilmezse ham CHECK hatası -> servis doğrulaması.
  - Kural: `.claude/rules/backend.md` param tipleri (AsWideString / AsBCD) eklendi.
- Not (dokunulmadı): Required attribute mesajında alan adı property adı ('Name: Alan zorunludur'); kullanıcı formunda
  etiket 'Personel Id'. Mevcut verideki adlar (ör. 'DIĞER TICARI') eski non-tr büyük harfle girilmiş.
- UI akışları hâlâ çalıştırılarak test edilmedi (kullanıcı IDE'de Build + elle deneme yapmalı: para birimi ₺ kaydı,
  kur 4 hane, KDV oranı güncelleme, kullanıcı ekleme).

## UI event-akışı testi (2026-10-10, beşinci oturum)
- Test DB `ths_erp_it` (canlıdan pg_dump/restore + `ERP/Tests/Ui/seed.sql`; boş tablolara örnek satır). Harness
  `ERP/Tests/Ui` (`gen.py` Ths.dpr uses listesinden `UiTest.dpr` üretir; `UiDriver.pas`): 64 liste formu (System,
  Employee, Account, Stock, Production) gerçek sınıflarıyla açılır; modal diyaloglar/helper listeleri timer ile
  otomatik cevaplanır. Adımlar: liste açılışı + görünür kolon + başlık, 3 dil, boş yeni kayıt (red beklenir), yerleşim
  (footer çakışması), inceleme kilidi, inceleme -> güncelle -> onayla (DB satırı değişmemeli), kopyala -> değiştir ->
  kaydet (yeni satır = kaynak), helper seçimleri, sil / kapat + rollback, popup özel menüleri.
  Sonuç: 812 pass / 0 fail / 8 warn (NULL normalizasyonu). Servis paketi 1036/0.
- Bulunan ve düzeltilen:
  - Ölçü Birimi Grupları listesi hiç kolon göstermiyordu; Ölçü Birimi listesi birim adını çekmiyordu (helper seçince
    stok kartında birim boş kalıyordu); erişim hakları listesinde deny_* yoktu -> sys_grid_column satırları eklendi
    (canlı DB, dump'lar yenilendi). vw_sys_uom locale + sys_view_tables id gizlendi, eski kullanıcı tercihleri düzeltildi.
  - TfrmGrid.SetSelectedItem: [NotMapped] metin alanları snake_case grid kolonundan dolar (override unutulan helper'lar).
  - TfrmGrid.ShowInputForm: giriş formu olmayan listede (Sistem Tabloları) çift tık / Enter access violation veriyordu.
  - TfrmInputSimpleDB.SetControlsDisabledOrEnabled: ClassType eşitliği yerine `is` -> interposer kullanmayan formlarda
    (Grid Kolon/Filtre/Sıralama combo, stok kartı memo) inceleme modunda kontroller düzenlenebilir kalıyordu.
    Grid Kolonu formunda chkIsFetch inceleme modunda açılıyordu.
  - Grid Filtre / Sıralama: boş form kaydediliyordu -> table_name Required.
  - Başlıklar: adres listesi ülke/şehir, grid kolon listesi 10 kolon, ölçü birimi grup kolonu.
- Karar bekleyen: güncellemede boş alanlar NULL yerine '' / 0 yazılıyor (adres, cins özelliği/bilgisi, açıklamalar,
  stok iskonto). İşlevsel hata değil; "boş = NULL" standardı istenirse repository'lerde merkezi düzeltme yapılabilir.

## Boş değer standardı + sekme testleri (2026-10-10, altıncı oturum)
- Kullanıcı kararı: nullable kolonda '' / 0 -> NULL; NOT NULL metin zorunlu; NOT NULL sayıda 0 geçerli.
  Sayısal sınıflandırma (onaylı): A) 0 anlamlı -> NOT NULL DEFAULT 0 (stk_inventory fiyat/iskonto/min stok/tedarik
  süresi, acc_account.discount_rate, emp_employee maaş/prim, stk_inventory_summary tümü, sys_grid_column sayısalları,
  sys_decimal_place, sys_uom.multiplier; 63 NULL -> 0). B) 0 = girilmemiş -> nullable, 0 -> NULL (plaka kodu, iso_year,
  smtp port, askerlik, ayakkabı no, mükellef tipi, stok boyut/ağırlık, cins bilgisi i/d). C) stk_inventory.vat_rate özel.
- Kod: TRepository.ApplyNullPolicy / TNullPolicy (information_schema önbellekli) 66 repository'de 261 yazma noktasında;
  AccAccount taxpayer/contact; StkInventory NullPolicyKeepZero = vat_rate. Mevcut veride 34 kolon '' / 0 -> NULL.
- Domain Required: 43 NOT NULL FK / seçenek / tarih alanı. BindEntityToControls artık cbb/mmo kontrollerini de
  zorunlu işaretler. TSysUom: düz UomGroupKey (inceleme ekranında grup boş görünüyordu; Clone paylaşılan nesne hatası da gitti).
- UI harness yeni adımlar: sekme geçişi (her sekme, hata/diyalog yok), alan = DB satırı (gizli sekmeler dahil),
  zorunlu alan boşalt -> başka sekmedeyken kaydet -> hata + doğru sekme + odak, NOT NULL alan zorunlu işaretli mi.
  Sonuç 989 pass / 0 fail / 0 warn (107 zorunlu alan testi); servis paketi 1036/0; derleme 0 hata.
- Dump'lar yenilendi (yedekler scratchpad: ths_erp_before_not_null_zero.dump, ths_erp_before_empty_to_null.dump).

## Finans (fin_) modülü: çek / senet / kredi kartı / POS (2026-10-12, /goal "çek, senet kredi kartı modülünü oluştur")
- Bu makine (DESKTOP-JF3LUBB): güncel DB 5432'de, RAD Studio 37.0. Öncesinde scratch yedek: ths_erp_before_finance.dump.
- DB (psql, doğrudan): 6 tablo + 6 view, yetki grubu `finance` (tr/en/de), yetkiler 1070 çek/senet (+hareketler),
  1071 firma kredi kartı (+hareketler), 1072 POS (+tahsilatlar); yönetici tam, satış 1070+1072 r/a/u, satın alma 1070+1071 r/a/u;
  tüm kullanıcılara sys_access_right satırı. Para birimi kolonları DEFAULT fn_default_currency().
  - `fin_cheque_note`: doc_kind (1 çek / 2 senet), direction (1 alınan / 2 verilen), portfolio_no (UNIQUE; boşsa servis
    MC/KC/MS/BS + 6 hane üretir), serial_no (aynı tür+yön+banka içinde tekil, partial index), keşide/vade (vade >= keşide),
    amount > 0, cari zorunlu, çekte banka zorunlu (CHECK), şube seçilen bankaya ait olmalı, status (servis yönetir).
  - `fin_cheque_note_transaction`: transaction_type = belgenin yeni durumu (1 portföyde, 2 ciro, 3 tahsile, 4 teminata,
    5 tahsil edildi, 6 karşılıksız/protestolu, 7 iade, 8 ödendi, 9 verildi). Açılış hareketi (alınan 1 / verilen 9) belgeyle
    aynı transaction'da yazılır, yalnız açılış varken belgeyle senkron tutulur; durum = son hareket (RefreshNoteStatus).
    Geçişler `TFinLookup.CanTransit`; tarih önceki hareketten önce olamaz; yalnız son hareket güncellenir/silinir; açılış
    silinemez (belge silinir, cascade); hareket görmüş belgede tür/yön/cari değişmez; ciro/verildi cari, tahsile/teminata banka ister.
  - `fin_credit_card` (ad UNIQUE, banka, son 4 hane, limit (0 = limitsiz), kesim/ödeme günü 1-31 ya da NULL, muhasebe hesabı, aktif)
    + `fin_credit_card_transaction` (1 harcama / 2 ödeme / 3 iade, taksit 1-36 yalnız harcamada, limit kontrolü, pasif kartta harcama yok);
    view'da bakiye / kullanılabilir limit / taksit tutarı.
  - `fin_pos_terminal` (ad UNIQUE, banka, komisyon % 0-100, bloke gün 0-365) + `fin_pos_transaction` (1 tahsilat / 2 iade,
    cari zorunlu; komisyon = round(tutar x oran / 100, 2), net = tutar - komisyon, valör boşsa tarih + bloke gün; form POS
    seçilince oranı önerir). Hareketi olan kart/POS silinemez.
- Kod (üreteç: scratchpad gen_fin.py + fin_config.py + gen_fin_lang.py + register_fin.py + dash_fin.py):
  `BackEnd/Finance/{Domain,Exception,Repository,Service}` 6 entity + `FinLookup` (sabitler, durum geçişleri, portföy öneki);
  `Forms/Finance/{Input,Output}` 12 form + DFM. Popup: çek/senet -> Hareketler, kart -> Hareketler, POS -> Tahsilatlar
  (SetFixed*). Dashboard: yeni "Finans" ana menüsü (Müşteri Çekleri / Kendi Çeklerimiz / Müşteri Senetleri / Borç Senetlerimiz
  = SetFixedKind, Tüm Çek/Senetler, Çek/Senet Hareketleri, Kredi Kartları + Hareketleri, POS Tanımları + Tahsilatları), SetAction.
  168 dil anahtarı x 4 JSON, TLangKeys TFinOption + 6 kayıt, TDashboard.MenuFinance.
- Doğrulama: msbuild Win64 Debug (DCU/EXE %TEMP%'e) 0 hata, dokunulan birimlerde uyarı/ipucu yok. Entegrasyon testi
  (services.txt + ItModules TestFinance*): 1154 pass / 0 fail, DB satır sayıları öncesi = sonrası. UI harness (seed.sql'e finans
  satırları + şube; Finance modülü): tam koşu 1104 pass / 0 fail / 0 warn. db_schema.sql + db.dump yenilendi.
- UI elle denenmedi (kullanıcı IDE'de Shift+F9 Build + Finans menüsü). Muhasebe fişi / cari bakiye entegrasyonu YOK (voucher
  modülüyle birlikte ileride: çek tahsili, kart ödemesi, POS valör hesap hareketleri).

## Kasa / banka + para hareketleri (2026-10-12, /goal "havale gibi para girişleri için eksik sistemi tasarla")
- DB: `fin_money_account` (1 kasa / 2 banka hesabı; kod + ad UNIQUE, banka/şube/hesap no/IBAN yalnız bankada (CHECK),
  IBAN formatı CHECK + partial UNIQUE, para birimi DEFAULT fn_default_currency(), muhasebe hesabı) ve `fin_money_transaction`
  (1 tahsilat (cariden; nakit / gelen havale-EFT), 2 ödeme (cariye), 3 virman (tek satır: kaynaktan çıkış, hedefe giriş),
  4 masraf/komisyon, 5 faiz, 6/7 diğer giriş/çıkış; transfer_method 1 nakit 2 havale 3 EFT 4 FAST 5 SWIFT (opsiyonel);
  belge/dekont no, gönderen/alıcı ad + IBAN). View'lar: `vw_fin_money_ledger` (ekstre: virman iki satır, id = hareket*2(+1),
  giriş/çıkış + yürüyen bakiye, window fonksiyonu → FOR UPDATE yok), `vw_fin_money_account` (toplam giriş/çıkış/bakiye),
  `vw_fin_money_transaction`. Yetkiler 1073 hesaplar + ekstre, 1074 hareketler (yönetici tam; satış + satın alma: hesap
  okuma, hareket r/a/u).
- Kurallar (servis): tahsilat/ödemede cari zorunlu; virmanda hedef zorunlu, kaynaktan farklı, aynı para birimi, aktif;
  pasif hesaba yeni hareket yok; IBAN mod-97 (`TFinLookup.IsValidIban`, TR 26 hane, boşluklar atılır); kasa eksiye düşemez
  (yazma sonrası aynı transaction'da kontrol; ekle/güncelle/sil, eski ve yeni hesaplar), banka hesabı eksiye düşebilir (KMH);
  hareket görmüş hesabın para birimi değişmez, hareketi olan hesap silinmez; kasa türünde banka alanları temizlenir.
- Kod: FinMoneyAccount / FinMoneyTransaction / FinMoneyLedger (salt okunur: tablo yok, giriş formu yok, repository kilidi
  yok sayar, servis her yazmayı reddeder). Popup: hesap → Hesap Ekstresi / Hareketler. Finans menüsü + 3 action.
- Üreteç genelleşti: scratchpad `gen_erp.py <config> [Entity...]`, `gen_lang.py <config>`, `register.py <config> <anchor>`,
  `dash.py <config>` (config: fin_config / money_config / pur_config).

## Satın alma (pur_) modülü (2026-10-12, aynı /goal)
- Eski `pur_offer` / `pur_offer_detail` (boş, kodu yok, Türkçe kolonlar) DOKUNULMADI — silinmesi için kullanıcı onayı gerekli.
  Dashboard "Alımlar" menüsündeki 4 işlevsiz öğe + boş `actals_teklifler` action'ı kaldırıldı, yerine yeni ekranlar.
- DB: talep `pur_request` (+`_detail`: stok, miktar, ordered_quantity), sipariş `pur_order` (+`_detail`: sıra no, stok, miktar,
  fiyat, iskonto %, KDV %, brüt/iskonto/net/KDV/toplam, received_quantity, talep kalemi bağlantısı), mal kabul `pur_receipt`
  (+`_detail`: miktar, birim maliyet, sipariş kalemi bağlantısı), alış faturası `pur_invoice` (+`_detail`, mal kabul kalemi
  bağlantısı; fatura no tedarikçi içinde UNIQUE). `stk_transaction.pur_receipt_detail_id` (UNIQUE, CASCADE, yalnız giriş).
  8 view. Yetki grubu `purchasing`, kodlar 1080 talep / 1081 sipariş / 1082 mal kabul / 1083 fatura (yönetici tam, satın alma
  r/a/u/d, üretim: talep r/a/u + sipariş/mal kabul okuma).
- Akış ve kurallar (servis; `PurLookup`): numaralar boşsa PT/PS/MK + 6 hane. Talep/sipariş kalemleri yalnız TASLAK belgede
  değişir. Durum popup'ları (`ChangeStatus`, geçiş tablosu `CanChange*Status`): talep taslak→onay/red, onay→taslak/red/kapat
  (siparişe aktarılmamışsa), red→taslak, siparişe dönüştü→kapat; sipariş taslak→onay(kalem şart)/iptal, onay→taslak/iptal
  (mal kabul yoksa), iptal→taslak. Otomatik: talep 4 (tamamı sipariş), sipariş 3 kısmi / 4 tamamı teslim.
  Dönüşümler: `TPurOrderService.CreateFromRequest` (tedarikçi seçilir; kalan miktar, fiyat yalnız aynı para biriminde stok
  alış fiyatı, alış iskontosu, KDV = kart ya da grup), `TPurReceiptService.CreateFromOrder` (onaylı/kısmi; ambar = siparişin
  teslim ambarı ya da seçilen; birim maliyet = iskontolu net fiyat), `TPurInvoiceService.CreateFromReceipt` (faturalanmamış
  miktar; fiyat/iskonto/KDV sipariş kaleminden; fatura no = irsaliye no ya da mal kabul no; vade = sipariş vadesi).
  Satır tutarları `TPurLookup.CalculateLine` (2 hane, yarım değer sıfırdan uzağa), başlık toplamları SQL ile kalemlerden.
  Mal kabul kalemi stok giriş hareketini yazar/günceller (UpsertStockTransaction) + stok özeti + sipariş teslim miktarı;
  mal kabul tarihi/ambarı değişince hareketler senkron; açık sipariş miktarı aşılamaz; faturalanmış kalem azaltılamaz/silinemez;
  fatura kalemi teslim alınıp faturalanmamış miktarı aşamaz, aynı tedarikçi + aynı stok. Stok hareketi servisi mal kabulden
  gelen hareketin güncellenmesini/silinmesini reddeder (`IsPurchaseReceiptLinked`, dil anahtarı stk_transaction.receipt_linked).
  Kalem formlarında stok seçilince fiyat/iskonto/KDV servisten önerilir (`GetInventoryDefaults`).
- Popup'lar: talep → Kalemler / Onayla / Taslağa Al / Reddet / Kapat / Siparişe Dönüştür...; sipariş → Kalemler / Mal Kabuller /
  Onayla / Taslağa Al / İptal Et / Mal Kabul Oluştur; mal kabul → Kalemler / Faturaya Dönüştür; fatura → Kalemler.
- Doğrulama (para + satın alma): Win64 Debug 0 hata, dokunulan birimlerde uyarı/ipucu yok. Entegrasyon 1314 pass / 0 fail
  (TestFinanceMoney, TestPurchasing: tam akış + 30 kural ihlali; DB satır sayısı öncesi = sonrası). UI tam koşu 1297 pass /
  0 fail / 1 warn (boş talep kaydedilebiliyor: talepte zorunlu kullanıcı girdisi yok — bilinçli). Harness: tablosu olmayan
  salt okunur listede view'a düşer; popup'ta iş kuralı reddi INFO; kopyada türetilen alanlar/kaynak bağlantıları karşılaştırılmaz.
  db_schema.sql + db.dump yenilendi (yedekler scratchpad: ths_erp_before_money.dump, ths_erp_before_purchasing.dump).
- Kalan / sonraki: cari hesap ekstresi (fatura + tahsilat/ödeme + çek/POS birleşik bakiye), alış faturasının muhasebe fişi ve
  e-fatura alımı, satın alma iadesi (iade irsaliyesi / iade faturası), kur farkı, sipariş/teklif karşılaştırma; eski
  pur_offer tablolarının silinmesi (onay). UI akışları elle denenmedi.

## Firma banka hesapları (2026-10-12, /goal; öncesinde eaf5f06 commit)
- DB: `fin_company_bank_account` (banka zorunlu, şube kodu / adı / şehri (sys_city), hesap no, IBAN zorunlu + UNIQUE + format
  CHECK, para birimi, hesap sahibi / unvan, show_on_cheque / show_on_note / show_on_print, sıra 0-999, aktif, açıklama).
  `vw_fin_company_bank_account.print_text` = "Banka - Şube (kod) - Şehir - PB - No: … - IBAN: TR33 0006 …" (4'lü gruplu).
  `fin_cheque_note.fin_company_bank_account_id` (yalnız verilen belgede, CHECK direction = 2) + vw_fin_cheque_note'a
  fin_company_bank_account_id / company_bank_iban (sys_grid_column + sys_user_grid_column satırları eklendi). Yetki 1075
  (yönetici tam, satış + satın alma okuma).
- Kurallar: IBAN normalize + mod-97; kullanılan hesap silinemez / para birimi değişmez; kendi çek / senedimizde seçilen hesap
  aktif olmalı ve ilgili bayrak (çek / senet) açık olmalı, belge para birimi hesabınkiyle aynı; banka, hesap no (boşsa) ve
  para birimi hesaptan gelir; alınan belgede bağlantı temizlenir. Formda hesap seçilince banka / hesap no / PB doldurulur.
- Çıktılar için: `TFinCompanyBankAccountService.GetPrintLines(FIN_BANK_USAGE_CHEQUE | _NOTE | _PRINT)` (aktif + bayrak + sıra).
  Henüz rapor/çıktı tasarımı (fatura, teklif, çek/senet baskısı) yok — çıktılar yazıldığında bu metod kullanılmalı.
- Doğrulama: derleme 0 hata / dokunulan birimlerde uyarı yok; entegrasyon 1337 pass / 0 fail (TestCompanyBankAccounts);
  UI Finance 178 pass / 0 fail / 0 warn. Dump'lar yenilendi (yedek: ths_erp_before_company_bank.dump). gen_lang.py artık
  mevcut TLangKeys kaydına eksik sabitleri de ekliyor.

## Cari hesap hareketleri + "Detay Göster" (2026-10-12, /goal)
- `vw_acc_account_transaction` (salt okunur, tablo yok): para hareketleri (tahsilat/faiz/diğer giriş = alacak; ödeme/masraf/
  diğer çıkış = borç; virman carisiz), çek/senet (açılış: alınan alacak / verilen borç; ciro: ciro edilen borç; karşılıksız: ilk
  cari borç (alınan) / alacak (verilen) + cirodan döndüyse ciranta alacak; ciro geri alınınca ciranta alacak; iade ters kayıt),
  POS (tahsilat alacak / iade borç), firma kartıyla cariye harcama borç / iade alacak, alış faturası alacak (toplam). Kolonlar:
  source_type (1-5, `ACC_TX_SRC_*`), source_id, document_id, document_no, borç / alacak, cari + para birimi bazında yürüyen
  bakiye. id = kaynak id * 100 + tip * 10 + parça (benzersiz). Yetki 1038 (yönetici / satış / satın alma okuma).
- Kod: `AccAccountTransaction` (Account modülü, salt okunur entity). `TfrmAccAccountTransactions` popup "Detay Göster" →
  `OpenSourceDocument`: kaynak servisin `BusinessFindById(..., APermissionControl = True)` ile okur (okuma yetkisi yoksa
  EAuthorizationExceptionRead), kaynağın kendi giriş formunu inceleme modunda açar (form servisi sahiplenir; güncelle / sil
  yetkileri formda ayrıca denetlenir; kayıt sonrası hareket listesi yenilenir). Çek/senet satırında çek/senet belgesi açılır.
  Hesap kartları popup "Cari Hareketleri" (SetFixedAccount), Muhasebe menüsü action.
- Doğrulama: derleme 0 hata / uyarı yok; entegrasyon 1347 pass / 0 fail (borç/alacak, benzersiz id, bakiye, her kaynak
  servisle açılır, TEST kullanıcısı deny_read ile fatura açamaz / is_read ile para hareketini açar); UI tam 1326 pass / 0 fail
  (+ 5 kaynak tipinin her biri doğru formu inceleme modunda açıyor: UiTest.tpl TestShowSources). Dump'lar yenilendi.
- Not: satış faturası / irsaliye modülü yazıldığında view'a + AccLookup + OpenSourceDocument'a eklenmeli.

## Ana ekran (dashboard) göstergeleri (2026-10-12, commit 268ec7e; görsel tasarım 2026-10-14)
- Katmanlar: `SysDashboard` (Domain: KPI_* / CHART_* anahtarları, TDashboardKpi: Count / Count2 / Amounts / Level / Ratio / Trend,
  TDashboardChart), `SysDashboard.Repository` (salt okuma toplama sorguları, CURRENT_DATE), `SysDashboard.Service`
  (GetKpis / GetCharts: yalnız kullanıcının OKUMA yetkisi olan modüller hesaplanır, super user hepsini görür; bir göstergenin
  hatası loglanır, diğerlerini engellemez). Form `ufrmDashboard`: çalışma anında kaydırılabilir alan, 5 dk'da bir yenileme
  (yalnız form aktifken), araç çubuğunda Yenile + "Güncellendi: hh:nn".
- Göstergeler (bölüm): Finans (kur, kasa / banka bakiyesi, bugünkü para hareketleri, alınan / verilen çek-senet, POS bu ay,
  kredi kartı borcu), Satın alma (talep, açık sipariş, bu ay sipariş / mal kabul / fatura), Satış (eski sls_order / sls_offer
  sayımı), Stok (minimum altı, bugünkü hareket, kart sayısı), Cari (alacak / borç: vw_acc_account_transaction, aktif cari),
  Genel (personel, kullanıcı). Kart tıklanınca ilgili liste action'ı açılır (yetki yoksa action pasif, kart tıklanmaz).
- Görsel tasarım (2026-10-14, kullanıcı: "tamamen metin tabanlı, anlaşılmıyor"): `Forms/Core/Base/DashboardControls.pas`
  (GDI+ çift tampon, Segoe Fluent Icons / MDL2 ikon fontu): TDashWelcome (selam + tarih etkin dilde + kritik / uyarı
  sayısı etiketleri), TDashSection (ikonlu bölüm başlığı), TDashTile (ikon dairesi, Bilgi / Dikkat / Kritik etiketi, büyük
  değer, kart içi küçük trend grafiği, oran çubuğu + yüzde), TDashChart (sütun / çizgi, lejant, ızgara, fareyle değer balonu,
  veri yoksa boş durum). "Genel Bakış" grafikleri: para giriş / çıkış (son 14 gün, varsayılan para birimi
  fn_default_currency), çek / senet vadeleri (8 hafta, gecikmişler ilk haftada), stok giriş / çıkış (14 gün), USD / EUR kur
  (son 30 kur günü). Trend: kur (son 14 kayıt), para hareketi ve stok hareketi günlük sayıları. Oran: vadesi yakın belge,
  limit kullanımı, onaylı talep, geciken sipariş, minimum altı stok, aktif cari / personel / kullanıcı.
- Görsel doğrulama: scratchpad'de DashPreview.dpr (bileşenleri örnek veriyle PNG'ye çizer); uygulama içinde çalıştırılmadı.
- Not: satış (sls_) modülü taşındığında KpiAction'a satış action'ları eklenmeli; yeni gösterge = repository metodu +
  servis Add(yetki) + KpiTitle / KpiTexts / KpiIcon / KpiSection + 4 dilde anahtar.

## UI test adımları (2026-10-14)
- Test betikleri iki makinede çalışır: `ERP/Tests/env.sh` Delphi'yi (Studio 37.0 yoksa 23.0) ve PostgreSQL 18 + güncel şemalı
  ths_erp portunu (5432 / 5433) bulur; gen.py portu şablona yazar (`{{PORT}}`). Bu PC'de 5432 eski bir PG14 kopyası.
- Uygulama Ayarları (tek kayıt, sekmeli) UI testine eklendi (`TestAppSettingForm`): açılış (inceleme), yerleşim, Tab sırası,
  3 dil, salt okunur inceleme, sekme geçişi, alanlar = DB satırı, güncelle + aynı değerle onay (satır değişmez), zorunlu
  alanlar (doğru sekme), helper (şehir), onaysız kapat -> rollback. 19 / 19 geçti.
- Tab sırası testi (`TUi.TabOrderProblems`, her giriş formunda + uygulama ayarlarında): kap bazında; aynı satırda sağa, aşağı
  ya da sağdaki sütunun başına geçiş kabul (iki sütunlu formlar sütun sütun); geri sıçrama ve TabStop = False düzenlenebilir
  alan hata. Bulunan tek hata: ufrmSysGridColumn (min değer satırı sırası + toplam tipi açılır kutusu FormCreate'te
  chkIsFetch'in üstüne taşınıyordu) -> DFM'de düzeltildi, çalışma anı konumlandırma silindi.
- Dashboard UI testi yeni kart bileşenlerine uyarlandı (23 kart, 4 grafik, kısıtlı kullanıcı 3 kart + 1 grafik).
- Sonuç: entegrasyon 1367 pass / 0 fail; UI tam 1430 pass / 1 fail (SysGridColumn, düzeltildi; tekil test 14 / 14) / 1 warn
  (TfrmPurRequests boş kayıt kabul: talep no otomatik, diğer alanlar isteğe bağlı -> tasarım gereği).

## KALDIĞIM YER (2026-10-14 sonu)
- Yapılanlar commit edildi (1060 silme + vergi hesapları, görsel dashboard, UI test adımları).
- Kullanıcı yapacak: uygulamada dashboard'u elle kontrol (Iceberg Classico temasıyla zemin rengi, fare tekerleği ile kaydırma,
  grafik balonları), Sistem > Grid Kolon giriş formu yerleşimi.
- SONRAKİ ADIM: sls_ (satış) modülü. Testleri her değişiklikten sonra çalıştır: `ERP/Tests/Integration/build.sh` +
  `%TEMP%\ths_it\bin\IntegrationTest.exe` ve `ERP/Tests/Ui/build.sh` + `%TEMP%\ths_ui\bin\UiTest.exe`.

## Kalan
- Uygulamayı açıp elle test (UI akışları derlendi, çalıştırılarak denenmedi): özellikle sekmeli stok kartı, karta özel hesaplar, reçete ekranları.
- Muhasebe fişi kesimi (voucher) vw_stk_inventory_account üzerinden hesap almalı; reçete maliyet hesabı (hammadde ort. maliyet + işçilik) ve üretim emri / stk_transaction.production_id bağlantısı henüz yok.
- Legacy Forms/Production/ufrmUrtReceteler.* ve Forms/DetailedInputForms/Production (kayıtsız) silinecek.
- 2026-10-14 kullanıcı kararları uygulandı: gider tipi 1 işçilik / 2 makine / 3 genel üretim gideri (zaten bu şekildeydi, değişiklik yok);
  1060 bom-settings yetkisi DB'den silindi (+ MODULE_RCT_RECETE_AYAR sabiti); acc_set_tax_rate %10 alış/alış iade ve %20 satış/satış iade
  hesapları düzeltildi (satış 391 / satış iade 191 / alış 191 / alış iade 391). Dump'lar yenilendi.
- 2026-10-09 değişiklikleri 4371ce2 ile commit edildi. sls_ (satış) modülü, uçtan uca UI testi ve bulunan hatalar düzeltilene
  kadar bekletiliyor (kullanıcı kararı, 2026-10-10).
- vw_sys_user.user_password kaldırma (login hash'i tablodan ayrı sorgu ile almalı)
- Diğer translation view'larında locale stratejisi (vw_sys_city, vw_sys_country, vw_sys_uom*, vw_emp_* ...) ve de-DE çeviri eksikleri
  (vw_emp_person_type locale NULL → personel tipi adı boş)
- emp_transportation.route UI dışında
- sys_city FK kuralları (ON UPDATE SET NULL), ufrmSysUomGroup DFM adı (frmSysUomType), Dashboard boş action'lar / SetSession,
  ölü Core/Base dosyaları

## Hatalar / Engeller
- Bu PC'de güncel DB 5433'te; GlobalSettings.ini DBPortNo=5432 (diğer makine değeri) ve 5432'de 2023'ten kalma eski ths_erp var
  (yalnız geçmiş referansı; değişiklik yapılmaz). Uygulama bu ini ile eski DB'ye bağlanır.
- db_schema.sql git'te "-text": pg_dump -s -f sonrası her LF -> CRLF yapılmalı (fonksiyon gövdelerindeki CRLF dahil, körlemesine), yoksa tüm dosya değişmiş görünür.
- `Ths.exe` açıkken link F2039 → derleme `/p:DCC_ExeOutput=%TEMP%\ths_build_out` ile yapılıyor.
