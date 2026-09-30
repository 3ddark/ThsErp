# Claude Resume State

## Goal
Modül modül stabilizasyon: System + yetki mimarisi, Employee, Account, Stock tamamlandı; sıradaki modül (prd_ / sls_) seçilecek.

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

## Kalan
- Uygulamayı açıp elle test (UI akışları derlendi, çalıştırılarak denenmedi).
- vw_sys_user.user_password kaldırma (login hash'i tablodan ayrı sorgu ile almalı)
- Diğer translation view'larında locale stratejisi (vw_sys_city, vw_sys_country, vw_sys_uom*, vw_emp_* ...) ve de-DE çeviri eksikleri
  (vw_emp_person_type locale NULL → personel tipi adı boş)
- emp_transportation.route UI dışında
- sys_city FK kuralları (ON UPDATE SET NULL), ufrmSysUomGroup DFM adı (frmSysUomType), Dashboard boş action'lar / SetSession,
  ölü Core/Base dosyaları

## Hatalar / Engeller
- `Ths.exe` açıkken link F2039 → derleme `/p:DCC_ExeOutput=%TEMP%\ths_build_out` ile yapılıyor.
