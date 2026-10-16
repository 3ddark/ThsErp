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

## Sol menü ağacı + ekran kodları (2026-10-15, NB61 makinesi: DB 5433, RAD Studio 23.0)
- Kullanıcı kararları: Ribbon yok; solda aranabilir ağaç. Menü kodu ile yetki kodu AYRI (yetki kodları değişmedi).
  Açılan ekranların başlığının sonunda kod: "Müşteri Çekleri [300301]". Ana menü (TMainMenu) şimdilik duruyor.
- DB: `sys_menu` (menu_code MMGGSS UNIQUE, generated parent_code FK, menu_key, action_name, sys_permission_id, is_active;
  klasör/ekran CHECK'leri, audit trigger) + `sys_menu_translation` (menu_name, keywords; tr/en/de) + `vw_sys_menu`.
  103 satır: 7 modül (60 Satış henüz yok), 18 grup, 78 ekran (dashboard'daki 77 SetAction + 100108 Şifre Değiştir).
  Kod şeması: modül 10 Sistem / 20 Muhasebe / 30 Finans / 40 Stok / 50 Satın Alma / 60 Satış / 70 Üretim / 80 Personel;
  grup 01 kartlar, 02 hareketler, 03 belgeler (finansta çek/senet), 04 belge kalemleri, 05 liste ayarları, 08 raporlar,
  09 ayarlar. Üreteç: scratchpad gen_menu.py (adlar dashboard action başlıklarının JSON çevirilerinden). Yedek:
  ths_erp_before_sys_menu.dump.
- Kod: `SysMenu` (TSysMenuItem kaydı) / `SysMenu.Repository` / `SysMenu.Service` (GetMenu: Allowed = okuma yetkisi);
  `Forms/Core/Base/NavigationTree.pas` (TNavMenuPanel: TSearchBox + sahibi çizilen TTreeView, modül ikonları, kod sütunu,
  arama: ad / anahtar kelime / üst klasör / kod öneki, Türkçe harf katlama; TNavToggleButton); `Forms/Core/Base/ScreenCode.pas`
  (TScreenCodes.RunWithCode + Screen.OnActiveFormChange + WM_SETTEXT kancası; modal olmayan alt formlar kodu devralır).
  Dashboard: 77 satırlık SetAction listesi kaldırıldı -> LoadMenu (sys_menu'dan action Enabled), actlstMain.OnExecute ->
  RunWithCode, dil değişiminde menü yeniden okunur, Ctrl+K / Ctrl+F arama, Esc aramayı temizler, araç çubuğunda menü düğmesi.
  actprs_personeller başlığı artık çevriliyor (önceden DFM'deki sabit Türkçe). Grafikler satıra tek sayıda kart sığınca
  satırı dolduruyor.
- Test: UI 1451 pass / 0 fail / 1 warn (bilinen PurRequests); dashboard testine 18 menü adımı (arama, kod + Enter, başlıkta kod,
  devralma, dil değişimi, kısıtlı kullanıcı, ekran görüntüleri UiTest-dashboard(-nav).png). Entegrasyon 1370 pass / 0 fail
  (+ CheckMenu: super user / TEST / şablon + override senaryosunda Allowed = etkin okuma yetkisi). Derleme 0 hata.
- Yapılmadı / sonraki: favoriler + son kullanılanlar (yapıldı, aşağıda), Ctrl+K komut paleti (her ekrandan),
  sys_menu bakım ekranı, ana menüde kod gösterimi, panel genişliği / açık klasörlerin kullanıcı bazında saklanması.
  Uygulama içinde elle denenmedi (kullanıcı IDE'de Shift+F9 Build + dene).

## Favoriler + son kullanılanlar (2026-10-15, commit 4fdeee5 sonrası)
- DB: `sys_user_menu` (sys_user_id + sys_menu_id UNIQUE, is_favorite, open_count >= 0, last_opened_at; FK'ler CASCADE,
  audit yok). Yedek: scratchpad ths_erp_before_user_menu.dump.
- Kod: TSysMenuItem + IsFavorite / OpenCount / LastOpenedAt; repository GetItems(locale, user) LEFT JOIN, SetFavorite /
  RegisterOpen (upsert), GetScreenId (klasör favori olamaz); servis CurrentUserId (oturum yoksa hata).
  TNavMenuPanel: arama boşken üstte Favoriler (yıldız) + Son Kullanılanlar (son 7) kısayol klasörleri (Data < 0,
  IsShortcutNode), favori ekranda sağda yıldız, sağ tık "Favorilere Ekle / Çıkar" + Ctrl+D, SetFavorite / MarkOpened ağacı
  seçim ve kaydırma konumu korunarak yeniler. Dashboard: NavToggleFavorite, ActionListExecute sonunda RegisterOpen (hata
  yalnız loglanır). 4 yeni dil anahtarı.
- Bilinen sınırlama: yazma ana bağlantıda; başka bir ekranın açık transaction'ı (güncelleme modu) iptal edilirse o sırada
  yapılan favori / açılma kaydı da geri alınır (oturum içinde ağaçta görünür, sonraki girişte kaybolur).
- Test: entegrasyon CheckMenuPrefs (ekle / sayaç / çıkar / klasör reddi / başka kullanıcının tercihi görünmez, rollback);
  UI: son kullanılanlar, Ctrl+D ekle / çıkar (DB), seçim korunuyor, dil değişiminde klasör adı; UiTest-dashboard-fav.png.

## Kalan menü işleri (2026-10-15, commit 5424571)
- DB (yedek scratchpad ths_erp_before_menu_admin.dump): yetki 1111 'menu' (system grubu, tr/en/de, yönetici şablonu tam,
  tüm kullanıcılara sys_access_right), menü satırı 100910 "Menü Ekranları" (actsys_menu), vw_sys_menu + permission_name /
  parent_path, sys_grid_column satırları (vw_sys_menu), `sys_user_setting` tablosu.
- Bakım ekranı: SysMenu Domain'e TSysMenu + TSysMenuTranslation entity; SysMenu.Repository TRepository<TSysMenu> oldu
  (CRUD + ağaç okuması + favoriler aynı sınıfta); SysMenu.Service TCrudService<TSysMenu> (yetki 1111; GetMenu / SetFavorite /
  RegisterOpen aynen); SysMenu.Exception (7 kural). ufrmSysMenus (kopya yok) + ufrmSysMenu (iki çeviri kutusu: ad, arama
  kelimeleri; kod / anahtar / action yalnız yeni kayıtta açık). Pasif satır: ağaçtan kalkar, action kapanır, pasif klasörün
  altı da pasif (GetMenu etkin IsActive).
- Komut paleti: NavigationTree.pas TNavCommandPalette (modal, kenarsız; kod / ad / yol / yıldız; boş sorguda favori + son
  kullanılanlar) + TNavMenuPanel.Search / PathOf. Dashboard TApplicationEvents.OnShortCut: Ctrl+K ana ekranda ağaç araması,
  başka ekranda palet, modal açıkken yok.
- Panel durumu: SysUserSetting (Domain anahtar sabitleri / Repository / Service); dashboard LoadNavState (SetSession'da bir
  kez) / SaveNavState (DoClose; form yok edilirken bağlantı kapalı olduğu için). TNavMenuPanel.ExpandedKeys.
- Test: entegrasyon CheckMenuAdmin (13 kural adımı; beklenen hata sonrası servis transaction'ı geri aldığı için test yeni
  transaction açar — ilk denemede bu yüzden test verisi canlı DB'ye sızdı, elle onarıldı) + generic/perm TSysMenu;
  UI: palet (kod, kelime, boş sorgu), ExpandedKeys, kullanıcı ayarı, pasif klasör.

## İşlem geçmişi ayrı DB'de: ths_audit (2026-10-15, /goal "audit ayrı DB + dönem DB planı"; DESKTOP-JF3LUBB, 5432)
- Sorun: audit() her satırı aynı DB'deki public.audit'e text olarak yazıyordu (DB şişiyor). Karar: ortak `ths_audit` DB'si
  (sunucu başına bir tane; tüm dönem / firma DB'leri yazar), aktarım postgres_fdw ile; tetikleyici uzağa YAZMAZ.
- ths_audit: `audit_log` PARTITION BY LIST (period_year) (audit_log_2026 …; yıl bölümü `audit_database` kaydının BEFORE
  tetikleyicisiyle otomatik, yarış korumalı), kolonlar period_year / db_name / db_family / source_id / table_schema /
  table_name / row_id / action / changed_at / transaction_id / db_user / app_user / client_addr / application_name /
  old_data / new_data jsonb / received_at; UNIQUE (period_year, db_name, source_id, changed_at); indeksler (db_family,
  table_name, row_id), changed_at, (app_user, changed_at), id. Rol `ths_audit_writer` (yalnız SELECT + INSERT; UPDATE /
  DELETE yok). Dosyalar: ERP/audit_schema.sql + ERP/audit.dump (diğer makinede rol + DB + pg_restore, CLAUDE.md §5).
- ths_erp: `audit_outbox` (yerel kuyruk), yeni `audit()` (SECURITY DEFINER; I tam yeni, D tam eski, U yalnız değişen
  kolonlar, değişmeyen UPDATE atlanır; ths_erp.user_name artık zorunlu değil), `audit_flush(batch, max) -> moved, error_message`
  (SKIP LOCKED, paketler, hata = -1 ve kuyruk korunur, kaynak kaydı / sayaç savepoint'te: FDW uzak transaction'ı
  REPEATABLE READ olduğundan eşzamanlı aktarım serileştirme hatası veriyordu), `audit_configure(host, port, db)`,
  `fn_active_period()` (sys_application_setting.active_period; 2023'tü -> 2026 yapıldı), `fn_db_family()`
  (sondaki [_]YYYY atılır), şema `audit_remote` (yabancı tablolar), `vw_sys_audit_log` (row_id -> record_no,
  changed_columns). Eski 554 audit satırı ths_audit'e taşındı, public.audit silindi. Yedek: scratchpad
  ths_erp_before_audit_db.dump.
- Yetki 1112 audit-log (system; yönetici şablonu yalnız okuma; tüm kullanıcılara access_right), menü 100800 Raporlar +
  100801 İşlem Geçmişi (actsys_audit_log), sys_grid_column + sys_grid_sort (id DESC).
- Kod: SysAuditLog Domain / Exception / Repository / Service (salt okunur; Flush açık transaction varken atlar;
  IsAudited önbellekli pg_trigger; DbFamily; ActivePeriod), ufrmSysAuditLogs (aktif dönem + bu firma; popup "Bu Kaydın Tüm
  Geçmişi", "Tüm Dönemler"; çift tık -> ufrmSysAuditLogDetail: alan / eski / yeni tablosu), TfrmGrid'e genel
  "İşlem Geçmişi" popup'ı (Ctrl+H; tetikleyicili tablo + 1112 okuma; kanca GRecordHistoryAvailable / GRecordHistoryShow).
  Dashboard: 60 sn zamanlayıcı + SetSession + liste açılışı + kapanışta FlushAudit (hata yalnız loglanır). 29 dil anahtarı x 4.
- Test: derleme Win64 Debug 0 hata (dokunulan birimlerde uyarı yok); entegrasyon 1428 pass / 0 fail (`IntegrationTest.exe audit`:
  18 adım; rollback uzak satırları da geri alıyor); `ERP/Tests/Audit/test_periods.sh` 24 / 24 (iki geçici dönem DB'si +
  geçici audit DB: bölümler, kayıt, iki dönemlik kayıt geçmişi, audit DB kapalı, 3 eşzamanlı aktarım, tekrar aktarım,
  dönem değişimi 2028, yazıcı rol silemez); UI tam 1495 pass / 0 fail / 1 warn (bilinen PurRequests). UI harness artık
  ths_erp_it'i ayrı `ths_audit_it`'e bağlar (gerçek ths_audit'e test satırı gitmez); UiDriver: BtnAccept özelliği olmayan
  (TfrmBase) ayrıntı pencerelerinde nil koruması.
- Dönem DB planı (uygulanmadı, rules/database.md "Period (year) databases"): firma + yıl başına DB (ths_erp2026 …), yıl sonu:
  kuyruğu boşalt -> TEMPLATE ile kopya -> outbox TRUNCATE + active_period + hareket verisi devri; girişte dönem seçimi.
  Mevcut ths_erp şimdiden dönem DB'si gibi çalışıyor (aile ths_erp, dönem 2026).
- Elle denenmedi (UI): Sistem > Raporlar > İşlem Geçmişi, herhangi bir sistem listesinde Ctrl+H, ayrıntı penceresi.

## KALDIĞIM YER (2026-10-15)
- Menü işleri tamamlandı: ağaç + kodlar (4fdeee5), favoriler / son kullanılanlar (5791656), bakım ekranı + Ctrl+K paleti +
  panel durumu (5424571). Kullanıcı elle denemeli: Ctrl+K başka ekrandayken, Sistem > Ayarlar > Menü Ekranları
  (ad / kelime / pasif), panel genişliği uygulama yeniden açılınca korunuyor mu.
- İşlem geçmişi ths_audit'e taşındı (yukarıdaki bölüm); kullanıcı IDE'de Shift+F9 Build + İşlem Geçmişi / Ctrl+H denemeli.
  Diğer makinede: ths_audit_writer rolü + ths_audit DB'si + pg_restore ERP/audit.dump (CLAUDE.md §5), sonra db.dump.
  Audit işleri (kod + dump + kurallar + testler) 2026-10-15'te commit + push edildi.
  Test DB'leri: ths_erp_it + ths_audit_it (UI harness yeniden kurar); geçici dönem test DB'leri test sonunda silinir.
- Satış (sls_) modülü tamamlandı (yukarıdaki bölüm). SONRAKİ ADIM: kullanıcıyla belirlenecek (öneriler 'Kalan / sonraki') (yeni ekranlar için sys_menu satırı zorunlu: 60xxxx, modül satırı 600000 + gruplar). Testleri her değişiklikten sonra çalıştır: `ERP/Tests/Integration/build.sh` +
  `%TEMP%\ths_it\bin\IntegrationTest.exe` ve `ERP/Tests/Ui/build.sh` + `%TEMP%\ths_ui\bin\UiTest.exe`.

## Satış (sls_) modülü (2026-10-15)
- Kullanıcı kararları: pur_ aynası yapı (acc_account_id / stk_inventory_id FK, kalemde tek KDV, başlık toplamları kalemlerden,
  durum smallint + SlsLookup; eski 5'li KDV / USD-EUR kuru / adres kopyası kolonları ve sls_*_status tabloları kalkar).
  Akış: teklif -> sipariş -> sevk irsaliyesi -> satış faturası. Stok çıkışı irsaliye kaleminde; irsaliyesiz faturada fatura
  kalemi stok düşer (irsaliyeli fatura).
- Tablolar boştu (veri kaybı yok). Eski kod: BackEnd/Order SatSiparis*, BackEnd/Offer, Forms/Offer, Forms/Order, DetailedInputForms/Offer|Order.
- DB (2026-10-15; yedek scratchpad a937082d…/ths_erp_before_sales.dump; script sales.sql + acc_view.sql): 8 tablo
  sls_offer/_detail (ordered_quantity), sls_order/_detail (delivered_quantity), sls_dispatch/_detail, sls_invoice/_detail
  (stk_warehouse_id irsaliyesiz kalemler için; kalemde sls_dispatch_detail_id XOR sls_order_detail_id); 8 vw_sls_*;
  stk_transaction.sls_dispatch_detail_id / sls_invoice_detail_id (UNIQUE, CASCADE, tip 2); vw_acc_account_transaction'a
  satış faturası (source_type 6, borç, id*100+60); yetkiler 1090 teklif / 1091 sipariş / 1092 irsaliye / 1093 fatura
  (357xxx silindi; yönetici tam, sales r/a/u/d, production 1091+1092 okuma); menü 600000 / 600300 (01-04) / 600400 (01-04).
- Kod (üreteç: scratchpad a937082d…/sls_config.py = sls/p0..p9 birleşimi + gen_erp.py, gen_lang.py, register.py):
  8 entity Domain/Exception/Repository/Service + Output/Input form; SlsLookup (ST/SS/SI/SF önekleri, durumlar,
  CanChangeOfferStatus/OrderStatus). Akış: teklif taslak -> gönderildi (kalem şart) -> CreateFromOffer (fiyat/iskonto/KDV,
  müşteri, temsilci, kur, vade tekliften) -> sipariş onay -> TSlsDispatchService.CreateFromOrder (ambar: sevk ambarı ya da
  seçilen; net fiyat) ya da TSlsInvoiceService.CreateFromOrder (irsaliyeli fatura) -> CreateFromDispatch (sipariş fiyatı).
  Sipariş durumu 3/4 otomatik; teklif 4 otomatik; iptal/sipariş silme teklifi yeniden açar. Fatura no SF+6, global UNIQUE.
  Popup'lar: teklif Kalemler/Gönderildi/Taslağa Al/Müşteri Reddetti/Kapat/Siparişe Dönüştür; sipariş Kalemler/Sevk
  İrsaliyeleri/Onayla/Taslağa Al/İptal/Sevk İrsaliyesi Oluştur/İrsaliyeli Fatura Oluştur; irsaliye Kalemler/Faturaya
  Dönüştür; fatura Kalemler. Dashboard Satışlar menüsü + actsls_* (eski boş actsat_* yöntemleri silindi), KPI'lar yeni
  kolonlarla (sipariş iptal / teklif red hariç), cari hareketlerde "Detay Göster" satış faturasını açar, stok hareketi
  servisi satış bağlantılı hareketi kilitler. Legacy BackEnd/Order, BackEnd/Offer, Forms/Offer, Forms/Order silindi
  (DetailedInputForms'a dokunulmadı).
- Doğrulama: msbuild Win64 Debug 0 hata (yeni birimlerde uyarı yok); entegrasyon 1552 pass / 0 fail (TestSales: 37 akış
  adımı + 15 kural ihlali; canlı DB satır sayıları değişmedi); UI tam koşu 1656 pass / 0 fail / 1 warn (bilinen PurRequests);
  UI harness: satış seed'i, kopyada belge no / kaynak bağlantıları karşılaştırılmaz. db_schema.sql + db.dump yenilendi.
- Elle denenmedi (UI): popup akışları (Siparişe Dönüştür, Sevk İrsaliyesi / İrsaliyeli Fatura Oluştur, Faturaya Dönüştür).
- Kalan / sonraki: satış faturası muhasebe fişi ve e-fatura, satış iadesi, fiyat listeleri / müşteri iskontosu, sevk adresi,
  negatif stok kontrolü (şimdilik engellenmiyor), çıktılar (teklif / irsaliye / fatura baskısı).

## Liste sayfalama (2026-10-15, /goal "ufrmGrid ve türetilmiş sayfalar için pagination")
- TfrmGrid<> sunucu tarafı sayfalama (varsayılan açık, 93 liste ekranının hepsi): FormShow sorgunun ORDER BY'sız gövdesini
  + parametrelerini saklar; her sayfa gövde + hızlı filtre / popup filtre + başlık sıralaması + taban sıralama + id
  LIMIT/OFFSET. Kayıt sayısı + alt toplamlar tek SQL'de tüm filtreli kayıtlar üzerinden; Excel/CSV ve CollectVisibleIds de.
  Alt çubuk: « ‹ [sayfa] / n › » "x - y / toplam" + sayfa boyutu (50/100/250/500/1000/Tümü; kullanıcı başına
  sys_user_setting grid.page_size, varsayılan 100). Ctrl+PgUp/PgDn. Kayıt sonrası RefreshParentGrid kaydın sayfasına gider,
  kolon düzeni korunur. Kapatmak için FormShow öncesi PagingEnabled := False (eski istemci tarafı davranış). Kural: rules/forms.md.
  Yeni anahtarlar grid.page_* (4 dil).
- Doğrulama: msbuild Win64 Debug 0 hata / ufrmGrid'de uyarı yok; UI tam koşu 1749 pass / 0 fail / 1 warn (bilinen PurRequests);
  yeni UI adımı "paging" (93 liste): sayfa boyutu 1 ile sayfa geçişi, son sayfa, kayda odaklanma, başlık sıralaması,
  hızlı filtre, her görünen kolonda popup Filtrele + kaldır.
- Elle denenmedi: çubuğun görünümü / yerleşimi, arama gecikmesi hissi, sayfa boyutu ayarının yeniden girişte korunması.

## Hızlı filtre (2026-10-15)
- TfrmGrid<>: AddQuickFilter / SetQuickFilterCaption / SelectQuickFilter / SetQuickCondition (:qc0… parametreli koşul taban
  sorguya AND; sayfa, kayıt sayısı, alt toplamlar, Excel/CSV, CollectVisibleIds; istemci tarafı modda da). Radyo düğmeleri
  başlık çubuğunda filtre kutusunun sağında. LoadFooterColumnsFromDB artık koddaki DefineFooterColumns'u silmiyor.
- Satış Teklif (Tümü/Taslak/Gönderilen/Siparişe Dönen/Reddedilen-Kapanan) ve Sipariş (Tümü/Onaysızlar/Bekleyenler/Gidenler)
  listeleri + net / KDV / genel toplam alt toplamları. Yeni anahtarlar grid.quick_all, sls_offer.quick.*, sls_order.quick.* (4 dil).
- Doğrulama: msbuild Win64 Debug 0 hata; UI tam koşu 1749 pass / 0 fail / 1 warn; paging adımı hızlı filtreleri de geziyor.
- Elle denenmedi: radyo düğmelerinin görünümü / genişliği; farklı para birimli belgelerin toplamı tek sayı (kur çevrimi yok).
- Commit 2511c87 (sayfalama + hızlı filtre + satış toplamları) main'e push edildi.
- Dump'lar yenilendi (2026-10-15 23:45, port 5432): db_schema.sql / audit_schema.sql (şema değişmedi, yalnız \restrict
  satırı), db.dump, audit.dump. Commit + push auto mode denetimince engellendi (tam veri dump'ının GitHub'a gitmesi);
  kullanıcı kendisi yapacak ya da izin kuralı ekleyecek. Bekleyen: `git add ERP/db_schema.sql ERP/db.dump
  ERP/audit_schema.sql ERP/audit.dump && git commit -m "chore: refresh ths_erp and ths_audit dumps" && git push`.
  ERP/Ths.res IDE derlemesinden değişik, commit'e alınmıyor.
- Sonraki olası işler: listeler varsayılan "Bekleyenler" ile açılsın mı (SelectQuickFilter), diğer belge listelerine
  (satınalma teklif/sipariş, irsaliye, fatura) hızlı filtre + toplam, toplamlarda kur çevrimi.

## Ortam kurulumu NB61 (2026-10-16, PG18 5433)
- ths_audit_writer rolü + ths_audit (tr-TR libc) oluşturuldu, ERP/audit.dump yüklendi (852 satır).
- ths_erp DROP (FORCE) + CREATE (tr-TR libc) + ERP/db.dump (2026-10-15 23:45) restore; 119 tablo / 101 view.
- audit_server portu 5432 geliyordu (bu PC'de 5432 = eski PG14) → `audit_configure('localhost', 5433, 'ths_audit')`.
  Trigger → outbox → flush → vw_sys_audit_log rollback içinde doğrulandı. GlobalSettings.ini DBPortNo=5433 yapıldı (diğer makinede 5432 gerekir).
- ths_erp_it (UI test DB'si) dokunulmadı; UI harness yeniden kurar.

## ufrmGrid bölündü (2026-10-16, NB61)
- TfrmGrid<TE, TS> (ufrmGrid, ~170 satır) artık yalnız Service / Table köprüsü; tipten bağımsız her şey generic olmayan
  `ufrmGridBase.TfrmGridBase`'te, o da `Forms/Core/Base/Grid/Grid.{Types,Sql,Paging,PagingBar,QuickFilter,Footer,Columns,
  Export,ColumnSelector}` birimlerine devreder (rules/forms.md "Layering"). Public API aynı; 93 liste formu değişmedi.
- Yan düzeltmeler: LoadLayout kolon sıralamada kayan indeks yerine kolon nesnesi; Ctrl+başlık tıklaması boş sıralamada
  da ekliyor; istemci modunda desteklenmeyen tipte boş filtre satırı eklenmiyor; footer'da alanı olmayan kolon AV'si yok;
  ölü kod (getFilterEditData, RefreshDataFirst, OnFilterDataset, AutoPopulateSysGridFilter/Sort, yorum blokları) silindi;
  ufrmGrid'deki UpperCaseTr/LowerCaseTr kopyaları kaldırıldı (Ths.Globals).
- Win32 Debug kod boyutu 23,36 MB -> 16,88 MB. UI tam koşu 1749 pass / 0 fail / 1 warn (öncesiyle aynı).
- SONRAKİ: generic Detaylar (master-detail) formu — kullanıcı tarif edecek.

## Detaylı form (master-detail) altyapısı (2026-10-16, NB61)
- Kullanıcı kararları: satırlar bellekte, Onayla'da başlık + satırlar tek transaction; TDBGrid + FDMemTable + hücre
  çizim API'si; SlsOffer örneği; eski ufrmSlsOffer + ufrmSlsOfferDetails (Kalemler listesi / popup) silindi;
  boyama yalnız kayıt durumuna göre (yeni / değişmiş).
- Backend: Service.IDetailChanges + TCrudService.BusinessSaveWithDetails(AEntity, ADetails, AWithCommit, APermission)
  + AfterSaveDetails; DetailChanges.TDetailChanges<TD, TDS>.
- UI: ufrmInputDetailedDB (TfrmInputDetailedDB<>), ufrmInputLineDB (TfrmInputLineDB<>), Forms/Core/Base/Detail/
  Detail.Grid (TDetailGrid) + Detail.Lines (TDetailSet<>, ILineForm). Kural: rules/forms.md "Master / detail".
- SlsOffer: ufrmSlsOfferDetail (başlık + kalemler), ufrmSlsOfferLine (kalem satırı). Dashboard actsls_offer_lines silindi;
  sys_menu 600401 pasif (kod kalıcı); LoadMenu pasif satırda eksik action'ı hata loglamıyor. 6 dil anahtarı x 4 (detail_form.*).
- Test: entegrasyon TestSalesOfferDocument 14 adım, paket 1566 pass / 0 fail.
- Sonraki adaylar: diğer belgeler (sipariş, irsaliye, fatura, satınalma, reçete sekmeli, fiş borç/alacak yan yana).

## Belge = başlık + kalemler (aggregate) — kararlar ve yol planı (2026-10-16)
Hedef kullanım: `Offer := OfferSvc.BusinessFindById(id, …)` başlık + kalemleri getirir (`Offer.Lines[0].InventoryCode`,
`Line.Header.OfferNo`); servis metotları kalemleri / toplamları bellekte günceller; `OfferSvc.BusinessSaveWithDetails(Offer,
…)` başlık + tüm kalemleri tek transaction'da yazar. Detaylı form yalnız `TSlsOffer` alır, grid `Table.Lines`'ı gösterir.

Kararlar (kullanıcı, 2026-10-16):
- Domain yalnız veri: `TSlsOffer.Lines: TObjectList<TSlsOfferDetail>` (sahip), kalemde başlığa zayıf referans (`Header`),
  `TDetailEntity.Deleted`. Domain'de iş mantığı yok; hesap / kalem ekleme-çıkarma / kayıt **serviste**.
- Repository'ler elle yazılmış SQL (ORM yok; `RepositoryORM.pas` kullanılmıyor, eski emek olarak bekletiliyor).
- Tek liste durum modeli: `Id > 0` güncelle, `Id > 0 + Deleted` sil, `Id < 0` (geçici, servis -1, -2 … verir) ekle,
  `Id < 0 + Deleted` DB'ye gitmez (listeden çıkar). Silme yalnız `Deleted` ile (DB ile karşılaştırma yok → eksik
  yüklenmiş belge kalem kaybettirmez).
- `Deleted` ayrı taban sınıfta: `Entity.TDetailEntity` (TEntity'ye eklenmez).
- Kayıt sonrası belge aynı nesneye yeniden okunur (`Reload`: gerçek id'ler, view alanları, DB'de türeyen değerler).
- Hata: rollback + yeni kalemlerin geçici id'leri geri, `Deleted` korunur, yeni başlığın id'si 0.
- Değişmeyen kalemler de güncellenir (audit trigger no-op update'i yazmıyor; toplu update tek gidiş); `Modified` yok.
- Yeni kalemler tek tek `INSERT … RETURNING id` (array DML id döndürmez; stok bağlantısı da id ister); silme / güncelleme
  batch.
- Kalem servisi açık kalır (istisnai ekranlarda koddan tek kalem işlemi). Yan işler (stok hareketi, stok özeti, sipariş
  miktarları) tek yerde yazılır, iki yol da onu çağırır: kalem hook'u (kalem başına, gerçek id ile: `UpsertStockTransaction`)
  + belge hook'u (etkilenen stok / sipariş başına bir kez). Cari hareket hook değil (`vw_acc_account_transaction`
  türetiyor). Toplamlar hook değil: kayıttan önce servis bellekte `Recalculate`.
- Birden çok kalem listeli belgeler (PrdPacket ham madde + işçilik) için kayıt yardımcısı liste başına çağrılır.
- İskonto uygulama yalnız örnekti (kapsam dışı). Sınıf adları aynı (`…Detail`), özellik adı `Lines`.

Yol planı:
- Faz 1 altyapı (Core/Base): `TDetailEntity`, `DetailList` (aktif kalemler, geçici id, kaydetme yardımcısı + geri alma
  günlüğü, değer kopyalama), `TCrudService.BusinessSaveWithDetails(AEntity, AWithCommit, APermission)` + `PrepareCopy`.
- Faz 2 SlsOffer (pilot): domain, kalem repo `FindByOfferIds`, servis (NewLine / AddLine / RemoveLine / Recalculate /
  Reload / PrepareCopy / kayıt), form `Table.Lines`; entegrasyon testi (form dışı akış, sil + ekle, satır no takası,
  rollback, taslak dışı ret, kopya).
- Faz 3: satış sipariş → fatura (kalem hook'unun ilk gerçek sınavı, erken) → irsaliye; satınalma talep / sipariş / mal
  kabul / fatura.
- Faz 4: AccVoucher (borç / alacak dengesi), PrdPacket (iki liste).
- Faz 5: temizlik (`CalculateLine` servis katmanına, SQL `RecalculateTotals` kontrol amaçlı ya da kaldır, kurallar).

Durum (2026-10-16, NB61): Faz 1 + Faz 2 TAMAM.
- Core/Base: `Entity.TDetailEntity` (Deleted, HeaderEntity), yeni `DetailList.pas` (TDetailList: Active / NextTempId /
  Attach / Remove / MarkAllNew / Save / AcceptSaved, TDetailSaveLog, CopyEntityValues), `TCrudService.BusinessSaveWithDetails
  (AEntity, AWithCommit, APermission)` + `PrepareCopy` (sanal; eski IDetailChanges / AfterSaveDetails ve
  `DetailChanges.pas` silindi).
- SlsOffer: `TSlsOffer.Lines` + `TSlsOfferDetailHelper.Header` (class helper, SlsOffer biriminde), derin Clone;
  `TSlsOfferDetailRepository.FindByOfferIds`; `TSlsOfferDetailService.CheckLine` (tek kalem + belge yolu ortak);
  `TSlsOfferService` CreateLine / AddLine / NewLine / RemoveLine / ActiveLines / RecalculateLine / RecalculateTotals /
  Recalculate / PrepareCopy / LoadLines / Reload / BusinessSaveWithDetails; BusinessFindById ve FindById(…, True) kalemli.
  Belge hook'u: RefreshOrderedQuantities.
- DB: `sls_offer_detail_line_key` DEFERRABLE INITIALLY DEFERRED (satır no takası); db_schema.sql + db.dump yenilendi
  (ths_audit değişmedi).
- UI: `TDetailSet<TD>` (veri tutmaz; Table.Lines + servis geri çağrıları), `TfrmInputDetailedDB.AddDetail<TD>` yeni imza,
  RefreshDetails, kopya = Service.PrepareCopy; `ufrmSlsOfferDetail` / `ufrmSlsOffers` buna göre. Kurallar:
  rules/backend.md "Documents", rules/forms.md "Master / detail".
- Doğrulama: msbuild Win32 Debug 0 hata (dokunulan birimlerde uyarı yok); entegrasyon 1578 pass / 0 fail
  (TestSalesOfferDocument 26 adım: form dışı oku-değiştir-sil-ekle-kaydet, Reload, satır no takası, mükerrer satır no,
  rollback + geçici id geri, taslak dışı ret, derin kopya + PrepareCopy); UI tam koşu 1729 pass / 0 fail / 1 warn
  (bilinen PurRequests; önceki koşu 1749 pass — 20 adım farkının nedeni incelenmedi, FAIL yok).
- Elle denenmedi (UI): teklif ekranında kalem ekle / aç / sil, renkler, toplamların canlı güncellenmesi, kopya.
- Kullanıcı geri bildirimi (2026-10-16) uygulandı: teklif kalem formunda hesaplanan tutarlar edit değil, panelde etiket
  (`Forms/Core/Base/Detail/Detail.Totals.TTotalsPanel`, başlık formunda da); miktar yanında ölçü birimi, fiyat yanında
  para birimi; KDV tanımlı oranlardan combo (`acc_set_tax_rate`, servis `CheckVatRate`, yeni anahtar
  `sls_offer_detail.vat_rate_undefined` x4); iskonto 100'ü aşamaz (anında 100'e çekilir); miktar / fiyat / iskonto / KDV
  değiştikçe tutarlar anında hesaplanır; başlıkta para birimi değişince kalemlere ve toplamlara yansır.
  Yeni belge formlarında aynı kalıp kullanılacak.
- Commit 814ce46 (teklif belgesi + kalem formu düzeltmeleri) main'e push edildi.

Ortak belge tabanı + sipariş (2026-10-16, kullanıcı: "ortak belge olsun"):
- `BackEnd/Core/Base/DocumentService.pas` `TDocumentService<TH, TL>` (TCrudService<TH> türevi): kalem işlemleri,
  Recalculate, PrepareCopy, LoadLines, Reload, BusinessSaveWithDetails (kilit, eski kalemler, CheckLines(…, AOldLines),
  satır no, ValidateAll, toplamlar, Save + AfterLineSaved, AfterDocumentSaved(…, AOldLines), commit, Reload).
  TSlsOfferService bu tabana taşındı (davranış aynı, testler aynı).
- Sipariş: `TSlsOrder.Lines` + `TSlsOrderDetailHelper.Header`, `TSlsOrderDetail = class(TDetailEntity)`;
  `TSlsOrderDetailRepository.FindByOrderIds`, `TSlsOfferDetailRepository.OfferIdsOfDetails`;
  `TSlsOrderDetailService.CheckLine` (+ GetVatRates / GetUomCode); `TSlsOrderService` = TDocumentService: kalemler yalnız
  taslakta (onaylıda başlık değişir; yeni / silinen / değişen kalem → DraftOnly), teslim edilen miktar DB'den,
  teklif kalemi stok uyumu, KDV tanımlı oranlardan, belge hook'u eski + yeni teklif bağlantılarının siparişe aktarılan
  miktarı / durumu; kopya teklif bağlantısını düşürür; `CreateFromOffer` belgeyi bellekte kurup aynı kayıtla yazar.
- DB: `sls_order_detail_line_key` DEFERRABLE INITIALLY DEFERRED; `sys_menu` 600402 (sipariş kalemleri) pasif.
- UI: `ufrmSlsOrder` -> `ufrmSlsOrderDetail` (TfrmInputDetailedDB, toplam paneli, DetailsEditable = taslak),
  eski kalem formu `ufrmSlsOrderDetail` -> `ufrmSlsOrderLine` (TfrmInputLineDB, teklif kalemi formuyla aynı kalıp +
  teslim tarihi, panelde teslim edilen / teklif no); `ufrmSlsOrderDetails` (kalem listesi) ve dashboard
  actsls_order_lines silindi; sipariş listesinde "Kalemler" popup'ı kalktı; teklif "Siparişe Dönüştür" yeni siparişi
  belge ekranında açar.
- Test: entegrasyon TestSalesOrderDocument 16 adım; paket 1595 pass / 0 fail.

İrsaliye / fatura kararları (kullanıcı, 2026-10-16):
- İrsaliyede durum var: faturaya dönüşmeyen irsaliye "Bekliyor", faturaya dönünce "Kapandı" (sls_dispatch'te kolon yok,
  eklenecek; kısmi faturalama için ara durum değerlendirilecek).
- e-İrsaliye ve e-Fatura gelecek; kullanıcı resmi dokümanları verecek. Fatura durum modeli ve e-belge alanları
  dokümanlarla birlikte tasarlanacak (şimdiden uydurulmayacak).

- SONRAKİ: irsaliye + fatura (TDocumentService; kalem hook'u UpsertStockTransaction, belge hook'u stok özeti + sipariş
  teslim miktarları; irsaliye durumu) — e-belge dokümanları gelince. Ardından üretim / reçete değerlendirmesi.
- (eski not) Faz 3 — satış siparişi, sonra fatura (kalem hook'u: UpsertStockTransaction; belge hook'u: stok özeti +
  sipariş teslim miktarları).

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
