unit ufrmDashboard;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.Variants, System.Math, System.StrUtils, System.Actions,
  System.Classes, System.SysUtils, System.DateUtils, System.Rtti, System.Generics.Collections,
  System.ImageList, System.Threading, Winapi.ShellAPI, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.ComCtrls, Vcl.Menus, Vcl.ActnList, Vcl.AppEvnts,
  Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Dialogs,
  Vcl.ToolWin, Vcl.ImgList, Vcl.StdActns, Vcl.CategoryButtons, Vcl.WinXCtrls,
  Vcl.Imaging.pngimage, Data.DB, FireDAC.Comp.Client, udm, ufrmBase, ufrmGrid,

  ConnectionManager, Logger, MetaProvider, SharedFormTypes, FilterCriterion,
  AppContext, UserContext, UnitOfWork,
  ufrmSysCities, SysCity.Service, SysCity,
  ufrmSysCountries, SysCountry.Service, SysCountry,
  ufrmSysCurrencies, SysCurrency.Service, SysCurrency,
  ufrmSysLanguages, SysLanguage.Service, SysLanguage.Repository, SysLanguage,
  ufrmSysRegions, SysRegion.Service, SysRegion,
  ufrmSysPermissionGroups, SysPermissionGroup.Service, SysPermissionGroup,
  ufrmSysPermissions, SysPermission.Service, SysPermission,
  ufrmSysUomGroups, SysUomGroup.Service, SysUomGroup,
  ufrmSysUoms, SysUom.Service, SysUom,
  ufrmSysApplicationSetting, SysApplicationSetting.Service, SysApplicationSetting,
  ufrmSysUsers, SysUser.Service, SysUser,
  ufrmSysAccessRights, SysAccessRight.Service, SysAccessRight,
  ufrmSysGridColumns, SysGridColumn.Service, SysGridColumn,
  ufrmSysGridFilters, SysGridFilter.Service, SysGridFilter,
  ufrmSysGridSorts, SysGridSort.Service, SysGridSort,
  ufrmAccBanks, AccBank.Service, AccBank,
  ufrmAccBankBranches, AccBankBranch.Service, AccBankBranch,
  LocalizationManager;

type
  TfrmDashboard = class(TfrmBase)
    PageControl1: TPageControl;
    tsgeneral: TTabSheet;
    tssales: TTabSheet;
    tsstock: TTabSheet;
    tsaccount: TTabSheet;
    tsemployee: TTabSheet;
    btnch_hesap_karti: TButton;
    actlstMain: TActionList;
    actsys_permission_group: TAction;
    actsys_permission: TAction;
    actsys_user: TAction;
    actsys_access_right: TAction;
    actsys_grid_column: TAction;
    actsys_grid_filter_sort: TAction;
    actsys_application_setting: TAction;
    actsys_database_status: TAction;
    actsys_about: TAction;
    actsys_update_password: TAction;
    actsys_update: TAction;
    tmrcheck_is_update_required: TTimer;
    pnlToolbar: TPanel;
    lblTitle: TLabel;
    actsys_country: TAction;
    actsys_city: TAction;
    actacc_exchange_rate: TAction;
    actsys_currency: TAction;
    actsys_unit: TAction;
    btnch_hesap_karti_ara: TButton;
    actsys_region: TAction;
    btnch_banka: TButton;
    btnch_banka_subesi: TButton;
    btnset_ch_grup: TButton;
    btnset_ch_hesap_plani: TButton;
    btnset_ch_vergi_orani: TButton;
    btnch_bolge: TButton;
    btnstk_stok_karti: TButton;
    btnstk_cins_ozelligi: TButton;
    btnstk_stok_ambar: TButton;
    btnstk_stok_grubu: TButton;
    btnsat_teklif: TButton;
    btnsat_siparis: TButton;
    btnsat_teklif_rapor: TButton;
    btnsat_siparis_rapor: TButton;
    btnprs_personel: TButton;
    tsbom: TTabSheet;
    btnrct_recete: TButton;
    btnrct_iscilik_gideri: TButton;
    btnrct_paket_hammadde: TButton;
    tsaccounting: TTabSheet;
    btnAccDovizKuru: TButton;
    actsys_unit_type: TAction;
    btnsys_olcu_birimleri: TButton;
    btnsys_para_birimleri: TButton;
    actsys_do_database_backup: TAction;
    mm1: TMainMenu;
    mnimenu_about: TMenuItem;
    mnisys_update_password: TMenuItem;
    mnisys_database_status: TMenuItem;
    mnisys_do_database_backup: TMenuItem;
    mnisys_about: TMenuItem;
    N3: TMenuItem;
    mnimenu_system: TMenuItem;
    mnisys_access_right: TMenuItem;
    mnisys_application_setting: TMenuItem;
    mnisys_city: TMenuItem;
    mnisys_country: TMenuItem;
    mnisys_grid_column: TMenuItem;
    mnisys_grid_filter_sort: TMenuItem;
    mnisys_region: TMenuItem;
    mnisys_resource: TMenuItem;
    mnisys_resource_group: TMenuItem;
    mnisys_uom: TMenuItem;
    mnisys_uom_type: TMenuItem;
    mnisys_user: TMenuItem;
    mnisys_update: TMenuItem;
    N2: TMenuItem;
    mniSystemSubSettings: TMenuItem;
    mniN7: TMenuItem;
    mniN8: TMenuItem;
    mniN9: TMenuItem;
    mniN10: TMenuItem;
    mnisys_currency: TMenuItem;
    mnimenu_sales: TMenuItem;
    mnimenu_purchase: TMenuItem;
    mnimenu_accounting: TMenuItem;
    mnimenu_stock: TMenuItem;
    mnipur_offer: TMenuItem;
    mnipur_order: TMenuItem;
    mnipur_dispatch_note: TMenuItem;
    mnipur_invoice: TMenuItem;
    mniacc_bank: TMenuItem;
    mniacc_bank_branch: TMenuItem;
    actstk_ambarlar: TAction;
    actstk_cins_ozellikleri: TAction;
    actstk_gruplar: TAction;
    actstk_hareketler: TAction;
    actstk_stok_kartlari: TAction;
    actstk_stok_karti_ozetleri: TAction;
    mnistk_warehouse: TMenuItem;
    mnistk_group: TMenuItem;
    mniAccountingSubSettings: TMenuItem;
    actset_ch_vergi_orani: TAction;
    mniset_acc_vat_rate: TMenuItem;
    mnimenu_employee: TMenuItem;
    mniEmployeeSubSettings: TMenuItem;
    mniset_prs_departments: TMenuItem;
    mniset_prs_units: TMenuItem;
    mniset_prs_tasks: TMenuItem;
    actset_prs_bolumler: TAction;
    actset_prs_birimler: TAction;
    actset_prs_gorevler: TAction;
    actset_prs_ehliyetler: TAction;
    actset_prs_lisanlar: TAction;
    actset_prs_lisan_seviyeleri: TAction;
    actset_prs_personel_tipleri: TAction;
    mniset_prs_driver_licences: TMenuItem;
    mniset_prs_languages: TMenuItem;
    mniset_prs_language_levels: TMenuItem;
    mniset_prs_person_types: TMenuItem;
    actprs_lisan_bilgileri: TAction;
    actprs_ehliyetler: TAction;
    actprs_personeller: TAction;
    mniprs_driver_licences: TMenuItem;
    mniprs_languages: TMenuItem;
    mniprs_persons: TMenuItem;
    actals_teklifler: TAction;
    actch_bankalar: TAction;
    actch_banka_subeleri: TAction;
    actset_prs_tasima_servisleri: TAction;
    mniset_prs_shuttle_services: TMenuItem;
    btnTest: TButton;
    mniN1: TMenuItem;
    mnisys_language: TMenuItem;
    actsys_language: TAction;
    mnimenu_language: TMenuItem;

    procedure DynamicLangMenuItemClick(Sender: TObject);
    procedure BuildLanguageMenu;
    procedure ChangeLanguage(const ALocale: string);
    procedure ApplyLocalization; override;

/// <summary>
///   Kullanıcının erişim yetkisine göre yapılacak işlemler burada olacak
/// </summary>
/// <remarks>
///   Login olan kullanıcıya ait haklara göre yapılacak işlemler burada yapılıyor.
///   Ana formda kullanıcının sahip olduğu yetkilere göre butonlar açılıyor.
/// </remarks>
/// <example>
///   Yeni Kayıt Ekle Buton başlığı için ButtonAdd
/// </example>
    procedure SetSession;
    procedure FormActivate(Sender: TObject);
    procedure ResetSession(pPanelGroupboxPagecontrolTabsheet: TWinControl);
    procedure tmrcheck_is_update_requiredTimer(Sender: TObject);
    procedure actsys_permission_groupExecute(Sender: TObject);
    procedure actsys_permissionExecute(Sender: TObject);
    procedure actsys_userExecute(Sender: TObject);
    procedure actsys_access_rightExecute(Sender: TObject);
    procedure actsys_grid_columnExecute(Sender: TObject);
    procedure actsys_grid_filter_sortExecute(Sender: TObject);
    procedure actsys_languageExecute(Sender: TObject);
    procedure actsys_application_settingExecute(Sender: TObject);
    procedure actquality_form_mail_recieversExecute(Sender: TObject);
    procedure actodeme_baslangic_donemleriExecute(Sender: TObject);
    procedure actset_teklif_tipleriExecute(Sender: TObject);
    procedure actteklif_durumlariExecute(Sender: TObject);
    procedure actset_efatura_fatura_tipiExecute(Sender: TObject);
    procedure actset_efatura_istisna_koduExecute(Sender: TObject);
    procedure actsys_aboutExecute(Sender: TObject);
    procedure actsys_update_passwordExecute(Sender: TObject);
    procedure actsys_updateExecute(Sender: TObject);
    procedure actsys_countryExecute(Sender: TObject);
    procedure actsys_cityExecute(Sender: TObject);
    procedure actacc_exchange_rateExecute(Sender: TObject);
    procedure actset_prs_bolumExecute(Sender: TObject);
    procedure actset_prs_lisanExecute(Sender: TObject);
    procedure actset_prs_gorevExecute(Sender: TObject);
    procedure actset_prs_birimExecute(Sender: TObject);
    procedure actlstMainExecute(Action: TBasicAction; var Handled: Boolean);
    procedure actsys_currencyExecute(Sender: TObject);
    procedure actsys_unitExecute(Sender: TObject);
    procedure actset_bbk_calisma_durumuExecute(Sender: TObject);
    procedure actset_bbk_finans_durumuExecute(Sender: TObject);
    procedure actset_bbk_firma_tipiExecute(Sender: TObject);
    procedure actsat_teklifExecute(Sender: TObject);
    procedure actrct_receteExecute(Sender: TObject);
    procedure actch_hesap_karti_araExecute(Sender: TObject);
    procedure actch_hesap_kartiExecute(Sender: TObject);
    procedure actch_bolgeExecute(Sender: TObject);
    procedure actset_ch_firma_tipiExecute(Sender: TObject);
    procedure actset_ch_firma_turuExecute(Sender: TObject);
    procedure actset_ch_grupExecute(Sender: TObject);
    procedure actset_ch_hesap_planiExecute(Sender: TObject);
    procedure actset_ch_hesap_tipiExecute(Sender: TObject);
    procedure actstk_stok_hareketiExecute(Sender: TObject);
    procedure actsat_siparis_raporExecute(Sender: TObject);
    procedure actsat_siparisExecute(Sender: TObject);
    procedure actrct_iscilik_gideriExecute(Sender: TObject);
    procedure actrct_paket_hammaddeExecute(Sender: TObject);
    procedure actsys_unit_typeExecute(Sender: TObject);
    procedure actsys_regionExecute(Sender: TObject);
    procedure actset_einv_odeme_sekliExecute(Sender: TObject);
    procedure actset_einv_paket_tipiExecute(Sender: TObject);
    procedure actset_einv_tasima_ucretiExecute(Sender: TObject);
    procedure actset_einv_teslim_sekliExecute(Sender: TObject);
    procedure actstk_ambarlarExecute(Sender: TObject);
    procedure actstk_gruplarExecute(Sender: TObject);
    procedure actstk_hareketlerExecute(Sender: TObject);
    procedure actstk_stok_kartlariExecute(Sender: TObject);
    procedure actstk_stok_karti_ozetleriExecute(Sender: TObject);
    procedure actstk_cins_ozellikleriExecute(Sender: TObject);
    procedure actset_ch_vergi_oraniExecute(Sender: TObject);
    procedure actset_prs_bolumlerExecute(Sender: TObject);
    procedure actset_prs_birimlerExecute(Sender: TObject);
    procedure actset_prs_gorevlerExecute(Sender: TObject);
    procedure actprs_ehliyetlerExecute(Sender: TObject);
    procedure actprs_lisan_bilgileriExecute(Sender: TObject);
    procedure actprs_personellerExecute(Sender: TObject);
    procedure actset_prs_lisanlarExecute(Sender: TObject);
    procedure actset_prs_ehliyetlerExecute(Sender: TObject);
    procedure actset_prs_lisan_seviyeleriExecute(Sender: TObject);
    procedure actset_prs_personel_tipleriExecute(Sender: TObject);
    procedure actals_tekliflerExecute(Sender: TObject);
    procedure actch_bankalarExecute(Sender: TObject);
    procedure actch_banka_subeleriExecute(Sender: TObject);
    procedure actset_prs_tasima_servisleriExecute(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
  private
    FIsFormShow: Boolean;
  published
    procedure btnCloseClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormKeyPress(Sender: TObject; var Key: Char); override;
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure FormShow(Sender: TObject); override;
  public
    destructor Destroy; override;

    procedure UpdateApplicationExe;
  end;

var
  frmDashboard: TfrmDashboard;

implementation

{$R *.dfm}

uses
  Vcl.Themes,
  ufrmAbout,
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Constants,
  Ths.Globals;

procedure TfrmDashboard.actsys_aboutExecute(Sender: TObject);
var
  LTs: TTabSheet;
begin
  LTs := PageControl1.ActivePage;
  TfrmAbout.Create(Application).ShowModal;
  SetSession;

  if LTs.TabVisible then
    PageControl1.ActivePage := LTs;
end;

procedure TfrmDashboard.actacc_exchange_rateExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actals_tekliflerExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actch_bankalarExecute(Sender: TObject);
begin
  TfrmAccBanks.Create(Self, TAccBankService.Create, TAccBank.Create).Show;
end;

procedure TfrmDashboard.actch_banka_subeleriExecute(Sender: TObject);
begin
  TfrmAccBankBranches.Create(Self, TAccBankBranchService.Create, TAccBankBranch.Create).Show;
end;

procedure TfrmDashboard.actch_bolgeExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actch_hesap_kartiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actch_hesap_karti_araExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsys_update_passwordExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actlstMainExecute(Action: TBasicAction; var Handled: Boolean);
begin
//  if SV.Opened then
//    SV.Opened := not SV.Opened;
end;

procedure TfrmDashboard.actodeme_baslangic_donemleriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_birimlerExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_bolumlerExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_ehliyetlerExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_gorevlerExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actprs_ehliyetlerExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actprs_lisan_bilgileriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actprs_personellerExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsat_siparisExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsat_siparis_raporExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsat_teklifExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_bbk_calisma_durumuExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_bbk_finans_durumuExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_bbk_firma_tipiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_ch_firma_tipiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_ch_firma_turuExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_ch_grupExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_ch_hesap_planiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_ch_hesap_tipiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_ch_vergi_oraniExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_efatura_fatura_tipiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_efatura_istisna_koduExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_einv_odeme_sekliExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_einv_paket_tipiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_einv_tasima_ucretiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_einv_teslim_sekliExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_birimExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_bolumExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_gorevExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_lisanExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_lisanlarExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_lisan_seviyeleriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_personel_tipleriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_tasima_servisleriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actstk_ambarlarExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actstk_cins_ozellikleriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actstk_gruplarExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actstk_hareketlerExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actstk_stok_hareketiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actstk_stok_karti_ozetleriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actstk_stok_kartlariExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsys_cityExecute(Sender: TObject);
begin
  TfrmSysCities.Create(Self, TSysCityService.Create, TSysCity.Create).Show;
end;

procedure TfrmDashboard.actsys_grid_columnExecute(Sender: TObject);
begin
  TfrmSysGridColumns.Create(Self, TSysGridColumnService.Create, TSysGridColumn.Create).Show;
end;

procedure TfrmDashboard.actsys_grid_filter_sortExecute(Sender: TObject);
begin
  TfrmSysGridFilters.Create(Self, TSysGridFilterService.Create, TSysGridFilter.Create).Show;
end;

procedure TfrmDashboard.actsys_countryExecute(Sender: TObject);
begin
  TfrmSysCountries.Create(Self, TSysCountryService.Create, TSysCountry.Create).Show;
end;

procedure TfrmDashboard.actsys_regionExecute(Sender: TObject);
begin
  TfrmSysRegions.Create(Self, TSysRegionService.Create, TSysRegion.Create).Show;
end;

procedure TfrmDashboard.actsys_unit_typeExecute(Sender: TObject);
begin
  TfrmSysUomTypes.Create(Self, TSysUomGroupService.Create, TSysUomGroup.Create).Show;
end;

procedure TfrmDashboard.actsys_unitExecute(Sender: TObject);
begin
  TfrmSysUoms.Create(Self, TSysUomService.Create, TSysUom.Create).Show;
end;

procedure TfrmDashboard.actsys_currencyExecute(Sender: TObject);
begin
  TfrmSysCurrencies.Create(Self, TSysCurrencyService.Create, TSysCurrency.Create).Show;
end;

procedure TfrmDashboard.actsys_languageExecute(Sender: TObject);
begin
  TfrmSysLanguages.Create(Self, TSysLanguageService.Create, TSysLanguage.Create).Show;
end;

procedure TfrmDashboard.actsys_permissionExecute(Sender: TObject);
begin
  TfrmSysPermissions.Create(Self, TSysPermissionService.Create, TSysPermission.Create).Show;
end;

procedure TfrmDashboard.actsys_permission_groupExecute(Sender: TObject);
begin
  TfrmSysPermissionGroups.Create(Self, TSysPermissionGroupService.Create, TSysPermissionGroup.Create).Show;
end;

procedure TfrmDashboard.actsys_application_settingExecute(Sender: TObject);
begin
  TfrmSysApplicationSetting.Create(Self, TSysApplicationSettingService.Create, TSysApplicationSetting.Create, ifmRewiev, nil).Show;
end;

procedure TfrmDashboard.actsys_userExecute(Sender: TObject);
begin
  TfrmSysUsers.Create(Self, TSysUserService.Create, TSysUser.Create).Show;
end;

procedure TfrmDashboard.actsys_access_rightExecute(Sender: TObject);
begin
  TfrmSysAccessRights.Create(Self, TSysAccessRightService.Create, TSysAccessRight.Create).Show;
end;

procedure TfrmDashboard.actteklif_durumlariExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_teklif_tipleriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actquality_form_mail_recieversExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsys_updateExecute(Sender: TObject);
begin
  if CustomMsgDlg(
    TLocalizationManager.Translate('msg.confirm_update', 'Güncelleme işlemini yapmak istediğinize emin misiniz?'),
    mtConfirmation, mbYesNo,
    [
      TLocalizationManager.Translate(TLangKeys.TGeneral.Yes, 'Evet'),
      TLocalizationManager.Translate(TLangKeys.TGeneral.No, 'Hayır')
    ],
    mbNo,
    TLocalizationManager.Translate('msg.title.update_confirmation', 'Güncelleme Onayı')
  ) = mrYes then
    UpdateApplicationExe;
end;

procedure TfrmDashboard.actrct_iscilik_gideriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actrct_paket_hammaddeExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actrct_receteExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.btnCloseClick(Sender: TObject);
begin
  if CustomMsgDlg(
    TLocalizationManager.Translate('msg.confirm_exit_app', 'Uygulama sonlandırılacak. Devam etmek istediğinize emin misiniz?'),
    mtConfirmation, mbYesNo,
    [
      TLocalizationManager.Translate(TLangKeys.TGeneral.Yes, 'Evet'),
      TLocalizationManager.Translate(TLangKeys.TGeneral.No, 'Hayır')
    ],
    mbNo,
    TLocalizationManager.Translate(TLangKeys.TGeneral.Confirmation, 'Onay')
  ) = mrYes then
    inherited;
end;

procedure TfrmDashboard.btnTestClick(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.tmrcheck_is_update_requiredTimer(Sender: TObject);
var
  LSurum: string;
  LMr: Integer;
begin
  Exit;
  //interval 1 minute
  if APP_VERSION <> LSurum then
  begin
    LMr := CustomMsgDlg(
      TLocalizationManager.Translate('msg.new_version_available', 'Programda yeni bir güncelleme var. Şimdi güncellemek ister misiniz?') + AddLBs(2) +
      TLocalizationManager.Translate('msg.update_recommended', 'Sistemsel hatalar veya kritik güncellemeler yapıldığı için güncellemeyi bir an önce yapmanız önerilir.'),
      mtConfirmation,
      mbYesNo,
      [
        TLocalizationManager.Translate('btn.update_now', 'Evet Güncelle'),
        TLocalizationManager.Translate('btn.update_later', 'Hayır Sonra Güncelle')
      ],
      mbNo,
      TLocalizationManager.Translate('msg.title.user_update_confirmation', 'Kullanıcı Güncelleme Onayı')
    );
    if LMr = mrYes then
      UpdateApplicationExe
    else
      tmrcheck_is_update_required.Enabled := False;
  end;
end;

procedure TfrmDashboard.UpdateApplicationExe;
const
  SEVENZIP = '7z.dll';
  SETT_NAME = 'GlobalSettings.ini';
  FLD_SETTINGS = 'Settings';
  FLD_REPORT = 'Reports';
  FLD_RESOURCE = 'Resource';
  FLD_LIB = 'Lib';
var
  Path: string;
  LAppName, LAppNameBak: string;
begin
  LAppName := ExtractFileName(Application.ExeName);
  LAppNameBak := LAppName.Replace(FILE_EXT_EXE, FILE_EXT_BAK);
  Path := GUygulamaAnaDizin;
(*
  if GSysApplicationSettingsOther.PathUpdate.Value <> '' then
  begin
    if  FileExists(GSysApplicationSettingsOther.PathUpdate.Value + PathDelim + LAppNameBak)
    and FileExists(GSysApplicationSettingsOther.PathUpdate.Value + PathDelim + FLD_SETTINGS + PathDelim + SETT_NAME)
    then
    begin
      //The application.exe file is kept with the .bak extension for the possibility of virus infection in the Server.
      DeleteFile(Path + PathDelim + LAppNameBak); //delete local file .bak extension
      RenameFile(Application.ExeName, Path + PathDelim + LAppNameBak);  //rename local file extension .exe to .bak

      LNewName := GSysApplicationSettingsOther.PathUpdate.Value + PathDelim + LAppNameBak;
      LOldName := Path + PathDelim + LAppName;
      CopyFile(PWideChar(LNewName), PWideChar(LOldName), true); //copy remote .bak to local .exe

      if DeleteFile(Path + FLD_SETTINGS + PathDelim + SETT_NAME) then //delete local settings file
      begin
        LNewName := GSysApplicationSettingsOther.PathUpdate.Value + PathDelim + FLD_SETTINGS + PathDelim + SETT_NAME;
        LOldName := Path + FLD_SETTINGS + PathDelim + SETT_NAME;
        CopyFile(PWideChar(LNewName), PWideChar(LOldName), True); //copy remote settings file to local settings
      end
      else
        raise Exception.Create('Ayar dosyası güncellenemedi!!!');


      LNewName := GSysApplicationSettingsOther.PathUpdate.Value + PathDelim + FLD_REPORT + PathDelim;
      LOldName := Path + FLD_REPORT + PathDelim;
      CopyFolder(LNewName, LOldName); //copy remote report files to local folder

      LNewName := GSysApplicationSettingsOther.PathUpdate.Value + PathDelim + FLD_RESOURCE + PathDelim;
      LOldName := Path + FLD_RESOURCE + PathDelim;
      CopyFolder(LNewName, LOldName); //copy remote resource files to local folder

      //lib klasörü yoksa kopyala
      if not DirectoryExists(Path + FLD_LIB) then
      begin
        LNewName := GSysApplicationSettingsOther.PathUpdate.Value + PathDelim + FLD_LIB + PathDelim;
        LOldName := Path + FLD_LIB + PathDelim;
        CopyFolder(LNewName, LOldName); //copy remote library files to local folder
      end;

      //7z.dll yoksa kopyala
      if not FileExists(Path + FLD_LIB + PathDelim + SEVENZIP)  //local de yoksa
         and FileExists(GSysApplicationSettingsOther.PathUpdate.Value + PathDelim + FLD_LIB + PathDelim + SEVENZIP)  //sunucuda varsa
      then
      begin
        LNewName := GSysApplicationSettingsOther.PathUpdate.Value + PathDelim + FLD_LIB + PathDelim + SEVENZIP;
        LOldName := Path + FLD_LIB + PathDelim + SEVENZIP;
        CopyFile(PWideChar(LNewName), PWideChar(LOldName), True); //copy remote settings file to local settings
      end;

      ShellExecute(Handle, 'OPEN', PChar(Application.ExeName), nil, nil, SW_SHOW);  //open updated new file app

      Application.Terminate;
    end
    else
      raise Exception.Create(GSysApplicationSettingsOther.PathUpdate.Value + AddLBs(2) + 'Güncelleme klasöründe dosyalar bulunamadı');
  end
  else
    raise Exception.Create('Güncelleme klasörü sistemde tanımlı değil!!!');
*)
end;

destructor TfrmDashboard.Destroy;
begin
  //
  inherited;
end;

procedure TfrmDashboard.FormActivate(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.DynamicLangMenuItemClick(Sender: TObject);
var
  LLocale: string;
begin
  if Sender is TMenuItem then
  begin
    LLocale := TMenuItem(Sender).Hint;
    if LLocale <> '' then
      ChangeLanguage(LLocale);
  end;
end;

procedure TfrmDashboard.BuildLanguageMenu;
var
  LSvc: TSysLanguageService;
  LLangList: TList<TSysLanguage>;
  LLang: TSysLanguage;
  LMenuItem: TMenuItem;
  LCaptionText: string;
begin
  if not Assigned(mnimenu_language) then
  begin
    mnimenu_language := TMenuItem.Create(mm1);
    mm1.Items.Add(mnimenu_language);
  end;

  mnimenu_language.Caption := TLocalizationManager.Translate('menu.language', 'Lisan / Language');
  mnimenu_language.Clear;

  if not (TConnectionManager.Instance.GetConnection(ContextMain).Connected) then
    Exit;

  try
    LSvc := TSysLanguageService.Create;
    try
      LLangList := LSvc.Find(nil, False);
      try
        for LLang in LLangList do
        begin
          LMenuItem := TMenuItem.Create(mnimenu_language);
          if Trim(LLang.NativeName) <> '' then
            LCaptionText := Format('%s (%s)', [LLang.NativeName, LLang.Locale])
          else
            LCaptionText := LLang.Locale;

          LMenuItem.Caption := LCaptionText;
          LMenuItem.Hint := LLang.Locale;
          LMenuItem.OnClick := DynamicLangMenuItemClick;
          mnimenu_language.Add(LMenuItem);
        end;
      finally
        LLangList.Free;
      end;
    finally
      LSvc.Free;
    end;
  except
    on E: Exception do
      GLogger.Error('BuildLanguageMenu failed: ' + E.Message);
  end;
end;

procedure TfrmDashboard.ChangeLanguage(const ALocale: string);
var
  i: Integer;
  LForm: TForm;
  LHasEditingForm: Boolean;
begin
  LHasEditingForm := False;
  for i := 0 to Screen.FormCount - 1 do
  begin
    LForm := Screen.Forms[i];
    if (LForm <> Self) and (LForm is TfrmBase) then
    begin
      if (TfrmBase(LForm).FormMode in [ifmUpdate, ifmNewRecord, ifmCopyNewRecord]) then
      begin
        LHasEditingForm := True;
        Break;
      end;
    end;
  end;

  if LHasEditingForm then
  begin
    CustomMsgDlg(
      TLocalizationManager.Translate('msg.finish_editing_before_lang_change', 'Lütfen lisan değiştirmeden önce açık düzenleme ekranlarındaki kaydetme/iptal işlemlerinizi tamamlayın.'),
      mtWarning, [mbOK],
      [TLocalizationManager.Translate(TLangKeys.TGeneral.OK, 'Tamam')],
      mbOK,
      TLocalizationManager.Translate('msg.title.warning', 'Uyarı')
    );
    Exit;
  end;

  TLocalizationManager.SetLanguage(ALocale);
  if Assigned(TAppContext.Instance.CurrentUser) then
    TAppContext.Instance.CurrentUser.ActiveLanguage := ALocale;

  ApplyLocalization;

  for i := 0 to Screen.FormCount - 1 do
  begin
    LForm := Screen.Forms[i];
    if (LForm <> Self) and (LForm is TfrmBase) then
      TfrmBase(LForm).ApplyLocalization;
  end;
end;

procedure TfrmDashboard.ApplyLocalization;
begin
  inherited;
  if Assigned(btnClose) then
    btnClose.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.Close, 'Kapat');

  // Language menu caption
  if Assigned(mnimenu_language) then
    mnimenu_language.Caption := TLocalizationManager.Translate('menu.language', 'Lisan / Language');

  // Main menu top-level items
  if Assigned(mnimenu_system) then
    mnimenu_system.Caption := TLocalizationManager.Translate('dashboard.menu.system', 'Sistem');
  if Assigned(mnimenu_purchase) then
    mnimenu_purchase.Caption := TLocalizationManager.Translate('dashboard.menu.purchasing', 'Alımlar');
  if Assigned(mnimenu_sales) then
    mnimenu_sales.Caption := TLocalizationManager.Translate('dashboard.menu.sales', 'Satışlar');
  if Assigned(mnimenu_accounting) then
    mnimenu_accounting.Caption := TLocalizationManager.Translate('dashboard.menu.accounting', 'Muhasebe');
  if Assigned(mnimenu_stock) then
    mnimenu_stock.Caption := TLocalizationManager.Translate('dashboard.menu.stock', 'Stoklar');
  if Assigned(mnimenu_employee) then
    mnimenu_employee.Caption := TLocalizationManager.Translate('dashboard.menu.personnel', 'Personel');
  if Assigned(mnimenu_about) then
    mnimenu_about.Caption := TLocalizationManager.Translate('dashboard.menu.about', 'Hakkında');

  // Submenu items & section headers
  if Assigned(mniSystemSubSettings) then
    mniSystemSubSettings.Caption := TLocalizationManager.Translate('dashboard.menu.settings', 'Ayarlar');
  if Assigned(mniAccountingSubSettings) then
    mniAccountingSubSettings.Caption := TLocalizationManager.Translate('dashboard.menu.settings', 'Ayarlar');
  if Assigned(mniEmployeeSubSettings) then
    mniEmployeeSubSettings.Caption := TLocalizationManager.Translate('dashboard.menu.settings', 'Ayarlar');
  if Assigned(mnipur_offer) then
    mnipur_offer.Caption := TLocalizationManager.Translate('dashboard.menu.proposals', 'Teklifler');
  if Assigned(mnipur_order) then
    mnipur_order.Caption := TLocalizationManager.Translate('dashboard.menu.orders', 'Siparişler');
  if Assigned(mnipur_dispatch_note) then
    mnipur_dispatch_note.Caption := TLocalizationManager.Translate('dashboard.menu.waybills', 'İrsaliyeler');
  if Assigned(mnipur_invoice) then
    mnipur_invoice.Caption := TLocalizationManager.Translate('dashboard.menu.invoices', 'Faturalar');
  if Assigned(mnisys_update_password) then
    mnisys_update_password.Caption := TLocalizationManager.Translate('dashboard.menu.change_password', 'Şifre Değiştir');
  if Assigned(mnisys_database_status) then
    mnisys_database_status.Caption := TLocalizationManager.Translate('dashboard.menu.db_monitor', 'Veritabanı Durumu');
  if Assigned(mnisys_do_database_backup) then
    mnisys_do_database_backup.Caption := TLocalizationManager.Translate('dashboard.menu.db_backup', 'Veritabanı Yedek Al');
  if Assigned(mnisys_update) then
    mnisys_update.Caption := TLocalizationManager.Translate('dashboard.menu.update', 'Güncelleme');
  if Assigned(mnisys_about) then
    mnisys_about.Caption := TLocalizationManager.Translate('dashboard.menu.about', 'Hakkında');

  // Actions (updates both linked actions and menu items / action buttons)
  if Assigned(actsys_user) then
    actsys_user.Caption := TLocalizationManager.Translate('dashboard.action.users', 'Kullanıcılar');
  if Assigned(actsys_access_right) then
    actsys_access_right.Caption := TLocalizationManager.Translate('dashboard.action.access_rights', 'Kullanıcı Erişim Hakları');
  if Assigned(actsys_application_setting) then
    actsys_application_setting.Caption := TLocalizationManager.Translate('dashboard.action.app_settings', 'Uygulama Ayarları');
  if Assigned(actsys_grid_column) then
    actsys_grid_column.Caption := TLocalizationManager.Translate('dashboard.action.grid_columns', 'Grid Kolonları');
  if Assigned(actsys_grid_filter_sort) then
    actsys_grid_filter_sort.Caption := TLocalizationManager.Translate('dashboard.action.grid_filters', 'Grid Filtre ve Sıralamalar');

  if Assigned(actsys_permission_group) then
    actsys_permission_group.Caption := TLocalizationManager.Translate(TLangKeys.TPermissionGroup.TitlePlural, 'Yetki Grupları');
  if Assigned(actsys_permission) then
    actsys_permission.Caption := TLocalizationManager.Translate(TLangKeys.TPermission.TitlePlural, 'Yetkiler');
  if Assigned(actsys_country) then
    actsys_country.Caption := TLocalizationManager.Translate('dashboard.action.countries', 'Ülkeler');
  if Assigned(actsys_city) then
    actsys_city.Caption := TLocalizationManager.Translate('dashboard.action.cities', 'Şehirler');
  if Assigned(actsys_region) then
    actsys_region.Caption := TLocalizationManager.Translate('dashboard.action.regions', 'Bölgeler');
  if Assigned(actsys_unit_type) then
    actsys_unit_type.Caption := TLocalizationManager.Translate('dashboard.action.unit_types', 'Ölçü Birimi Tipleri');
  if Assigned(actsys_unit) then
    actsys_unit.Caption := TLocalizationManager.Translate('dashboard.action.units', 'Ölçü Birimleri');
  if Assigned(actsys_currency) then
    actsys_currency.Caption := TLocalizationManager.Translate('dashboard.action.currencies', 'Para Birimleri');

  if Assigned(actsys_language) then
    actsys_language.Caption := TLocalizationManager.Translate('dashboard.action.languages', 'Lisanlar');
  if Assigned(actstk_stok_kartlari) then
    actstk_stok_kartlari.Caption := TLocalizationManager.Translate('dashboard.action.stock_cards', 'Stok Kartları');
  if Assigned(actstk_cins_ozellikleri) then
    actstk_cins_ozellikleri.Caption := TLocalizationManager.Translate('dashboard.action.type_properties', 'Cins Özellikleri');
  if Assigned(actstk_ambarlar) then
    actstk_ambarlar.Caption := TLocalizationManager.Translate('dashboard.action.warehouses', 'Ambarlar');
  if Assigned(actstk_gruplar) then
    actstk_gruplar.Caption := TLocalizationManager.Translate('dashboard.action.stock_groups', 'Stok Grupları');
//  if Assigned(actsat_teklifler) then
//    actsat_teklifler.Caption := TLocalizationManager.Translate('dashboard.action.sales_proposals', 'Satış Teklifleri');
//  if Assigned(actsat_siparis) then
//    actsat_siparis.Caption := TLocalizationManager.Translate('dashboard.action.sales_orders', 'Satış Siparişleri');
//  if Assigned(actsat_siparis_rapor) then
//    actsat_siparis_rapor.Caption := TLocalizationManager.Translate('dashboard.action.order_reports', 'Sipariş Raporları');
  if Assigned(actals_teklifler) then
    actals_teklifler.Caption := TLocalizationManager.Translate('dashboard.action.purchase_proposals', 'Satın Alma Teklifleri');
  if Assigned(actch_bankalar) then
    actch_bankalar.Caption := TLocalizationManager.Translate('dashboard.action.banks', 'Bankalar');
  if Assigned(actch_banka_subeleri) then
    actch_banka_subeleri.Caption := TLocalizationManager.Translate('dashboard.action.bank_branches', 'Banka Şubeleri');
  if Assigned(actset_ch_vergi_orani) then
    actset_ch_vergi_orani.Caption := TLocalizationManager.Translate('dashboard.action.tax_rates', 'Vergi Oranları');
  if Assigned(actprs_personeller) then
    actprs_personeller.Caption := TLocalizationManager.Translate('dashboard.action.employees', 'Personel Bilgileri');
  if Assigned(actprs_ehliyetler) then
    actprs_ehliyetler.Caption := TLocalizationManager.Translate('dashboard.action.employee_licenses', 'Personel Ehliyetleri');
  if Assigned(actprs_lisan_bilgileri) then
    actprs_lisan_bilgileri.Caption := TLocalizationManager.Translate('dashboard.action.employee_languages', 'Personel Lisan Bilgileri');
  if Assigned(actset_prs_bolumler) then
    actset_prs_bolumler.Caption := TLocalizationManager.Translate('dashboard.action.departments', 'Bölümler');
  if Assigned(actset_prs_birimler) then
    actset_prs_birimler.Caption := TLocalizationManager.Translate('dashboard.action.units', 'Birimler');
  if Assigned(actset_prs_gorevler) then
    actset_prs_gorevler.Caption := TLocalizationManager.Translate('dashboard.action.positions', 'Görevler');
  if Assigned(actset_prs_ehliyetler) then
    actset_prs_ehliyetler.Caption := TLocalizationManager.Translate('dashboard.action.license_types', 'Ehliyetler');
  if Assigned(actset_prs_lisanlar) then
    actset_prs_lisanlar.Caption := TLocalizationManager.Translate('dashboard.action.languages', 'Lisanlar');
  if Assigned(actset_prs_lisan_seviyeleri) then
    actset_prs_lisan_seviyeleri.Caption := TLocalizationManager.Translate('dashboard.action.language_levels', 'Lisan Seviyeleri');
  if Assigned(actset_prs_personel_tipleri) then
    actset_prs_personel_tipleri.Caption := TLocalizationManager.Translate('dashboard.action.personnel_types', 'Personel Tipleri');
  if Assigned(actset_prs_tasima_servisleri) then
    actset_prs_tasima_servisleri.Caption := TLocalizationManager.Translate('dashboard.action.shuttles', 'Taşıma Servisleri');
  if Assigned(actacc_exchange_rate) then
    actacc_exchange_rate.Caption := TLocalizationManager.Translate('dashboard.action.exchange_rates', 'Döviz Kurları');

  // PageControl Tabs
  if Assigned(tsgeneral) then
    tsgeneral.Caption := TLocalizationManager.Translate('dashboard.tab.general', 'Genel');
  if Assigned(tssales) then
    tssales.Caption := TLocalizationManager.Translate('dashboard.tab.sales', 'Satışlar');
  if Assigned(tsstock) then
    tsstock.Caption := TLocalizationManager.Translate('dashboard.tab.stock', 'Stoklar');
  if Assigned(tsaccount) then
    tsaccount.Caption := TLocalizationManager.Translate('dashboard.tab.accounts', 'Hesaplar');
  if Assigned(tsemployee) then
    tsemployee.Caption := TLocalizationManager.Translate('dashboard.tab.personnel', 'Personel');
  if Assigned(tsbom) then
    tsbom.Caption := TLocalizationManager.Translate('dashboard.tab.recipes', 'Reçeteler');
  if Assigned(tsaccounting) then
    tsaccounting.Caption := TLocalizationManager.Translate('dashboard.tab.accounting', 'Muhasebe');

  // Tab Buttons
  if Assigned(btnsat_teklif) then
    btnsat_teklif.Caption := TLocalizationManager.Translate('dashboard.btn.proposals', 'Teklifler');
  if Assigned(btnsat_siparis) then
    btnsat_siparis.Caption := TLocalizationManager.Translate('dashboard.btn.orders', 'Siparişler');
  if Assigned(btnsat_teklif_rapor) then
    btnsat_teklif_rapor.Caption := TLocalizationManager.Translate('dashboard.btn.proposal_reports', 'Teklif Raporu');
  if Assigned(btnsat_siparis_rapor) then
    btnsat_siparis_rapor.Caption := TLocalizationManager.Translate('dashboard.btn.order_reports', 'Sipariş Raporu');
  if Assigned(btnch_bolge) then
    btnch_bolge.Caption := TLocalizationManager.Translate('dashboard.btn.region', 'Bölge');
  if Assigned(btnch_banka) then
    btnch_banka.Caption := TLocalizationManager.Translate('dashboard.btn.banks', 'Bankalar');
  if Assigned(btnch_banka_subesi) then
    btnch_banka_subesi.Caption := TLocalizationManager.Translate('dashboard.btn.bank_branches', 'Banka Şubeleri');
  if Assigned(btnset_ch_grup) then
    btnset_ch_grup.Caption := TLocalizationManager.Translate('dashboard.btn.account_groups', 'Hesap Grupları');
  if Assigned(btnset_ch_hesap_plani) then
    btnset_ch_hesap_plani.Caption := TLocalizationManager.Translate('dashboard.btn.chart_of_accounts', 'Hesap Planları');
  if Assigned(btnch_hesap_karti_ara) then
    btnch_hesap_karti_ara.Caption := TLocalizationManager.Translate('dashboard.btn.search_account', 'Hesap Kartı Ara');
  if Assigned(btnch_hesap_karti) then
    btnch_hesap_karti.Caption := TLocalizationManager.Translate('dashboard.btn.account_card', 'Hesap Kartı');
  if Assigned(btnset_ch_vergi_orani) then
    btnset_ch_vergi_orani.Caption := TLocalizationManager.Translate('dashboard.btn.tax_rates', 'Vergi Oranları');
  if Assigned(btnrct_recete) then
    btnrct_recete.Caption := TLocalizationManager.Translate('dashboard.btn.recipes', 'Reçeteler');
  if Assigned(btnrct_iscilik_gideri) then
    btnrct_iscilik_gideri.Caption := TLocalizationManager.Translate('dashboard.btn.labor_costs', 'İşçilik Giderleri');
  if Assigned(btnrct_paket_hammadde) then
    btnrct_paket_hammadde.Caption := TLocalizationManager.Translate('dashboard.btn.raw_materials', 'Paket Hammaddeler');

  // Status Bar Panels
  if stbBase.Panels.Count >= STATUS_KEY_F4+1 then
    stbBase.Panels.Items[STATUS_KEY_F4].Text := 'F4 ' + TLocalizationManager.Translate(TLangKeys.TGeneral.Delete, 'Sil');
  if stbBase.Panels.Count >= STATUS_KEY_F5+1 then
    stbBase.Panels.Items[STATUS_KEY_F5].Text := 'F5 ' + TLocalizationManager.Translate(TLangKeys.TGeneral.Confirm, 'Onayla');
  if stbBase.Panels.Count >= STATUS_KEY_F6+1 then
    stbBase.Panels.Items[STATUS_KEY_F6].Text := 'F6 ' + TLocalizationManager.Translate(TLangKeys.TGeneral.Cancel, 'İptal');
  if stbBase.Panels.Count >= STATUS_KEY_F7+1 then
    stbBase.Panels.Items[STATUS_KEY_F7].Text := 'F7 ' + TLocalizationManager.Translate(TLangKeys.TGeneral.AddRecord, 'Kayıt Ekle');
  if stbBase.Panels.Count >= STATUS_KEY_F11+1 then
    stbBase.Panels.Items[STATUS_KEY_F11].Text := TLocalizationManager.Translate(TLangKeys.TGeneral.KeyF11, 'F11 Şeffaflık');
end;

procedure TfrmDashboard.FormCreate(Sender: TObject);
begin
  inherited;

  btnClose.Visible := True;
  pnlBottom.Visible := False;
  stbBase.Visible := True;
  pnlBottom.Visible := True;
end;

procedure TfrmDashboard.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  //Key := 0;
end;

procedure TfrmDashboard.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_ESCAPE) then
    inherited;
end;

procedure TfrmDashboard.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F6 then
    inherited;
end;

procedure TfrmDashboard.FormShow(Sender: TObject);
  procedure addPanel(AWidth: Integer; AStyle: TStatusPanelStyle);
  begin
    with stbBase.Panels.Add do
    begin
      Width := AWidth;
      Style := AStyle;
    end;
  end;
begin
  inherited;

  addPanel(80, psOwnerDraw);
  addPanel(80, psOwnerDraw);
  addPanel(80, psOwnerDraw);
  addPanel(80, psOwnerDraw);
  addPanel(80, psOwnerDraw);
  addPanel(80, psOwnerDraw);
  addPanel(80, psOwnerDraw);
  addPanel(80, psOwnerDraw);

  if stbBase.Panels.Count >= STATUS_SQL_SERVER+1 then

    if TConnectionManager.Instance.GetConnection(ContextMain).Connected then
      stbBase.Panels.Items[STATUS_SQL_SERVER].Text := TConnectionManager.Instance.GetConnection(ContextMain).Params.Values['Server'];

  if stbBase.Panels.Count >= STATUS_DATE+1 then
    if TConnectionManager.Instance.GetConnection(ContextMain).Connected then
      stbBase.Panels.Items[STATUS_DATE].Text := DateToStr(Now);

  if stbBase.Panels.Count >= STATUS_USERNAME+1 then

    if TConnectionManager.Instance.GetConnection(ContextMain).Connected then
      stbBase.Panels.Items[STATUS_USERNAME].Text := TAppContext.Instance.CurrentUser.GetUsername;

  ApplyLocalization;


  Self.Caption := getFormCaptionByLang(Self.Name, Self.Caption);

//  if GSysKullanici.IsYonetici.Value then
//  begin
    mnimenu_system.Visible := True;
//  end
//  else
  begin
//    mnimenu_system.Visible := False;

    tsemployee.TabVisible := False;
    tsaccount.TabVisible := False;
    tsstock.TabVisible := False;
    tssales.TabVisible := False;
    tsgeneral.TabVisible := False;
  end;

  FocusedFirstControl(PageControl1.ActivePage);

  tmrcheck_is_update_required.Enabled := True;

  Caption := Caption + ' v' + APP_VERSION;

  SetSession();
  FIsFormShow := False;

  TUnitOfWork.Initialize(TConnectionManager.Instance.GetConnection(ContextMain));
  BuildLanguageMenu;
end;

procedure TfrmDashboard.ResetSession(pPanelGroupboxPagecontrolTabsheet: TWinControl);
var
  n1: Integer;
  PanelContainer: TWinControl;

  procedure DisableButtons(Sender: TWinControl);
  var
    n2: Integer;
  begin
    if (Sender.ClassType = TButton) then
    begin
      TButton(Sender).Enabled := False;
    end
    else
    begin
      for n2 := 0 to Sender.ControlCount -1 do
      begin
        if Sender.Controls[n2].ClassType = TButton then
          TButton(Sender.Controls[n2]).Enabled := False
      end;
    end;
  end;

begin
  PanelContainer := nil;

  if pPanelGroupboxPagecontrolTabsheet = nil then
    PanelContainer := pnlMain
  else
  begin
    if pPanelGroupboxPagecontrolTabsheet.ClassType = TPanel then
      PanelContainer := pPanelGroupboxPagecontrolTabsheet as TPanel
    else if pPanelGroupboxPagecontrolTabsheet.ClassType = TGroupBox then
      PanelContainer := pPanelGroupboxPagecontrolTabsheet as TGroupBox
    else if pPanelGroupboxPagecontrolTabsheet.ClassType = TPageControl then
      PanelContainer := pPanelGroupboxPagecontrolTabsheet as TPageControl
    else if pPanelGroupboxPagecontrolTabsheet.ClassType = TTabSheet then
      PanelContainer := pPanelGroupboxPagecontrolTabsheet as TTabSheet;
  end;

  for n1 := 0 to PanelContainer.ControlCount -1 do
  begin
    if PanelContainer.Controls[n1].ClassType = TPanel then
      DisableButtons(PanelContainer.Controls[n1] as TPanel);

    if PanelContainer.Controls[n1].ClassType = TGroupBox then
      DisableButtons(PanelContainer.Controls[n1] as TGroupBox);

    if PanelContainer.Controls[n1].ClassType = TPageControl then
      ResetSession( (PanelContainer.Controls[n1] as TPageControl) );
//        for nIndex2 := 0 to (PanelContainer.Controls[nIndex] as TPageControl).PageCount-1 do
//          DisableButtons((PanelContainer.Controls[nIndex] as TPageControl).Pages[nIndex2]);

    if PanelContainer.Controls[n1].ClassType = TTabSheet then
//        DisableButtons(PanelContainer.Controls[nIndex] as TTabSheet);
      ResetSession( (PanelContainer.Controls[n1] as TTabSheet) );

    if PanelContainer.Controls[n1].ClassType = TButton then
      DisableButtons( TButton(PanelContainer.Controls[n1]) );
  end;
end;

procedure TfrmDashboard.SetSession;
//var
//  LRights: TSysErisimHakki;
//  n1: Integer;
begin
  ResetSession(pnlMain);
  btnTest.Enabled := True;
  btnsys_olcu_birimleri.Enabled := True;
  btnsys_para_birimleri.Enabled := True;
(*  LRights := TSysErisimHakki.Create(GDataBase);
  try
    LRights.SelectToList(' AND ' + LRights.TableName + '.' + LRights.KullaniciID.FieldName + '=' + VarToStr(GSysKullanici.Id.Value), False, False);
    for n1 := 0 to LRights.List.Count-1 do
    begin
      if (TSysErisimHakki(LRights.List[n1]).IsOkuma.Value)
      or (TSysErisimHakki(LRights.List[n1]).IsEkleme.Value)
      or (TSysErisimHakki(LRights.List[n1]).IsGuncelleme.Value)
      or (TSysErisimHakki(LRights.List[n1]).IsSilme.Value)
      or (TSysErisimHakki(LRights.List[n1]).IsOzel.Value)
      then
      begin
        //Genel
        if CheckStringInArray(MODULE_SISTEM, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_SISTEM_AYAR then
          begin
            //
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_SISTEM_DIGER then
          begin
            btnsys_olcu_birimleri.Enabled := True;
            btnsys_para_birimleri.Enabled := True;
          end;

        //Genel
        if CheckStringInArray(MODULE_GENEL, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
        begin
          if not tsStock.TabVisible then
            tsStock.TabVisible := True;

          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_BBK_AYAR then
          begin
            //
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_BBK_KAYIT then
          begin
            btnbbk_kayit.Enabled := True;
          end;
        end

        //Cari Hesap
        else if CheckStringInArray(MODULE_CH, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
        begin
          if not tsaccount.TabVisible then
            tsaccount.TabVisible := True;

          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_CH_AYAR then
          begin
            btnset_ch_grup.Enabled := True;
            btnset_ch_hesap_plani.Enabled := True;
            btnset_ch_vergi_orani.Enabled := True;
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_CH_KAYIT then
          begin
            btnch_banka.Enabled := True;
            btnch_banka_subesi.Enabled := True;
            btnch_bolge.Enabled := True;
            btnch_hesap_karti.Enabled := True;
            btnch_hesap_karti_ara.Enabled := True;
          end;
        end

        //Muhasebe
        else if CheckStringInArray(MODULE_MHS, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
        begin
          if not tsaccounting.TabVisible then
            tsaccounting.TabVisible := True;

          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_MHS_AYAR then
          begin

          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_MHS_DOVIZ_KURU then
          begin
            btnAccDovizKuru.Enabled := True;
          end;
        end

        //Stok Kartı
        else if CheckStringInArray(MODULE_STK, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
        begin
          if not tsStock.TabVisible then
            tsStock.TabVisible := True;

          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_STK_KAYIT then
          begin
            btnstk_stok_karti.Enabled := True;
            btnstk_cins_ozelligi.Enabled := True;
            btnstk_stok_ambar.Enabled := True;
            btnstk_stok_grubu.Enabled := True;
          end;
        end
        //Reçete
        else if CheckStringInArray(MODULE_RCT, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
        begin
          if not tsbom.TabVisible then
            tsbom.TabVisible := True;

          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_RCT_RECETE_AYAR then
          begin
            btnrct_paket_hammadde.Enabled := True;
            btnrct_iscilik_gideri.Enabled := True;
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_RCT_RECETE_KAYIT then
          begin
            btnrct_recete.Enabled := True;
          end;
        end
        //Personel
        else if CheckStringInArray(MODULE_PERSONEL, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
        begin
          if not tsemployee.TabVisible then
            tsemployee.TabVisible := True;
          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_PRS_AYAR then
          begin

          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_PRS_KAYIT then
          begin
            btnprs_personel.Enabled := True;
          end
        end
        //Satış
        else if CheckStringInArray(MODULE_TSIF, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
        begin
          if not tssales.TabVisible then
            tssales.TabVisible := True;

          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_TSIF_AYAR then
          begin
//            actset_efatura_fatura_tipi.Enabled := True;
//            actset_efatura_iletisim_kanali.Enabled := True;
//            actset_efatura_istisna_kodu.Enabled := True;
//            actset_teklif_tipleri.Enabled := True;
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_SAT_TEK_KAYIT then
          begin
            btnsat_teklif.Enabled := True;
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_SAT_SIP_KAYIT then
          begin
            btnsat_siparis.Enabled := True;
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_SAT_TEK_RAPOR then
          begin
            btnsat_teklif_rapor.Enabled := True;
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_SAT_SIP_RAPOR then
          begin
            btnsat_siparis_rapor.Enabled := True;
          end
        end
      end;
    end;
  finally
    FreeAndNil(LRights);
  end;
*)
end;

Initialization

finalization
  if TConnectionManager.Instance <> nil then
    FreeAndNil(TConnectionManager.Instance);
  TAppContext.Finalize;

end.
