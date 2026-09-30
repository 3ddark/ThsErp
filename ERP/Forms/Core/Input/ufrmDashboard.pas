unit ufrmDashboard;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.Variants, System.Math, System.StrUtils, System.Actions,
  System.Classes, System.SysUtils, System.DateUtils, System.Rtti, System.Generics.Collections,
  System.ImageList, System.Threading, Winapi.ShellAPI, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.Themes, Vcl.ComCtrls, Vcl.Menus, Vcl.ActnList, Vcl.AppEvnts,
  Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Dialogs,
  Vcl.ToolWin, Vcl.ImgList, Vcl.StdActns, Vcl.CategoryButtons, Vcl.WinXCtrls,
  Vcl.Imaging.pngimage, Data.DB, FireDAC.Comp.Client,
  udm, ufrmBase, Entity, ufrmGrid, ufrmInputSimpleDB, Service,

  ConnectionManager, Logger, MetaProvider, SharedFormTypes, FilterCriterion,
  AppContext, UserContext, UnitOfWork,
  ufrmSysCities, SysCity.Service, SysCity,
  ufrmSysCountries, SysCountry.Service, SysCountry,
  ufrmSysCurrencies, SysCurrency.Service, SysCurrency,
  ufrmSysDecimalPlace, SysDecimalPlace.Service, SysDecimalPlace,
  ufrmSysLanguages, SysLanguage.Service, SysLanguage.Repository, SysLanguage,
  ufrmSysRegions, SysRegion.Service, SysRegion,
  ufrmSysPermissionGroups, SysPermissionGroup.Service, SysPermissionGroup,
  ufrmSysPermissions, SysPermission.Service, SysPermission,
  ufrmSysUomGroups, SysUomGroup.Service, SysUomGroup,
  ufrmSysUoms, SysUom.Service, SysUom,
  ufrmSysApplicationSetting, SysApplicationSetting.Service, SysApplicationSetting,
  ufrmSysUsers, SysUser.Service, SysUser,
  ufrmSysUserPassword,
  ufrmSysAccessRights, SysAccessRight.Service, SysAccessRight,
  ufrmSysGridColumns, SysGridColumn.Service, SysGridColumn,
  ufrmSysGridFilters, SysGridFilter.Service, SysGridFilter,
  ufrmSysGridSorts, SysGridSort.Service, SysGridSort,
  ufrmSysPermissionTemplates, SysPermissionTemplate.Service, SysPermissionTemplate,
  ufrmSysPermissionTemplateRights, SysPermissionTemplateRight.Service, SysPermissionTemplateRight,
  ufrmSysUserPermissionTemplates, SysUserPermissionTemplate.Service, SysUserPermissionTemplate,
  ufrmEmpEmployees, EmpEmployee.Service, EmpEmployee,
  ufrmEmpPersonTypes, EmpPersonType.Service, EmpPersonType,
  ufrmEmpSections, EmpSection.Service, EmpSection,
  ufrmEmpUnits, EmpUnit.Service, EmpUnit,
  ufrmEmpTasks, EmpTask.Service, EmpTask,
  ufrmEmpTransportations, EmpTransportation.Service, EmpTransportation,
  ufrmEmpLanguages, EmpLanguage.Service, EmpLanguage,
  ufrmEmpDriverLicenceTypes, EmpDriverLicenceType.Service, EmpDriverLicenceType,
  ufrmEmpDriverLicences, EmpDriverLicence.Service, EmpDriverLicence,
  ufrmEmpLanguageAbilities, EmpLanguageAbility.Service, EmpLanguageAbility,
  ufrmAccBanks, AccBank.Service, AccBank,
  ufrmAccBankBranches, AccBankBranch.Service, AccBankBranch,
  ufrmAccAccounts, AccAccount.Service, AccAccount, AccLookup,
  AccSetAccountType.Service, AccSetAccountType,
  ufrmAccSetAccountTypes, ufrmAccSetOwnershipTypes, AccSetOwnershipType.Service, AccSetOwnershipType,
  ufrmAccSetCompanyLegalForms, AccSetCompanyLegalForm.Service, AccSetCompanyLegalForm,
  ufrmAccGroups, AccGroup.Service, AccGroup,
  ufrmAccRegions, AccRegion.Service, AccRegion,
  ufrmAccAccountPlans, AccAccountPlan.Service, AccAccountPlan,
  ufrmAccExchangeRates, AccExchangeRate.Service, AccExchangeRate,
  ufrmAccSetTaxRates, AccSetTaxRate.Service, AccSetTaxRate,
  ufrmAccTransferCodes, AccTransferCode.Service, AccTransferCode,
  ufrmStkInventories, StkInventory.Service, StkInventory,
  ufrmStkTransactions, StkTransaction.Service, StkTransaction,
  ufrmStkInventorySummaries, StkInventorySummary.Service, StkInventorySummary,
  ufrmStkWarehouses, StkWarehouse.Service, StkWarehouse,
  ufrmStkGroups, StkGroup.Service, StkGroup,
  ufrmStkProductTypes, StkProductType.Service, StkProductType,
  ufrmStkKindFamilies, StkKindFamily.Service, StkKindFamily,
  ufrmStkKindProperties, StkKindProperty.Service, StkKindProperty,
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
    actsys_grid_filter: TAction;
    actsys_grid_sort: TAction;
    actsys_application_setting: TAction;
    actsys_database_status: TAction;
    actsys_about: TAction;
    actsys_update_password: TAction;
    actsys_refresh_permissions: TAction;
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
    mnisys_refresh_permissions: TMenuItem;
    mnisys_refresh_permissions_sep: TMenuItem;
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
    mnisys_grid_filter: TMenuItem;
    mnisys_grid_sort: TMenuItem;
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
    mnipur_waybill: TMenuItem;
    mnipur_invoice: TMenuItem;
    mniacc_bank: TMenuItem;
    mniacc_bank_branch: TMenuItem;
    actstk_ambarlar: TAction;
    actstk_cins_ozellikleri: TAction;
    actstk_gruplar: TAction;
    actstk_hareketler: TAction;
    actstk_stok_kartlari: TAction;
    actstk_stok_karti_ozetleri: TAction;
    actstk_product_types: TAction;
    actstk_kind_families: TAction;
    mnistk_warehouse: TMenuItem;
    mnistk_group: TMenuItem;
    mnistk_inventory: TMenuItem;
    mnistk_transaction: TMenuItem;
    mnistk_inventory_summary: TMenuItem;
    mnistk_product_type: TMenuItem;
    mnistk_kind_family: TMenuItem;
    mnistk_kind_property: TMenuItem;
    mniStockSubSettings: TMenuItem;
    mniAccountingSubSettings: TMenuItem;
    actset_ch_vergi_orani: TAction;
    mniset_acc_vat_rate: TMenuItem;
    mniacc_account: TMenuItem;
    mniacc_account_intermediate: TMenuItem;
    mniacc_exchange_rate: TMenuItem;
    mniacc_account_plan: TMenuItem;
    mniacc_group: TMenuItem;
    mniacc_region: TMenuItem;
    mniacc_account_type: TMenuItem;
    mniacc_ownership_type: TMenuItem;
    mniacc_company_legal_form: TMenuItem;
    mniacc_transfer_code: TMenuItem;
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
    actset_prs_personel_tipleri: TAction;
    mniset_prs_driver_licences: TMenuItem;
    mniset_prs_languages: TMenuItem;
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
    actch_hesap_karti: TAction;
    actch_hesap_karti_ara: TAction;
    actch_bolge: TAction;
    actset_ch_grup: TAction;
    actset_ch_hesap_plani: TAction;
    actset_ch_hesap_tipi: TAction;
    actset_ch_firma_turu: TAction;
    actset_ch_firma_tipi: TAction;
    actacc_transfer_code: TAction;
    actset_prs_tasima_servisleri: TAction;
    mniset_prs_shuttle_services: TMenuItem;
    btnTest: TButton;
    mniN1: TMenuItem;
    mnisys_language: TMenuItem;
    actsys_language: TAction;
    mnimenu_language: TMenuItem;
    actsys_decimal_place: TAction;
    mniN2: TMenuItem;
    mnisys_decimal_place: TMenuItem;
    actsys_permission_template: TAction;
    actsys_permission_template_right: TAction;
    actsys_user_permission_template: TAction;
    mnisys_permission_template: TMenuItem;
    mnisys_permission_template_right: TMenuItem;
    mnisys_user_permission_template: TMenuItem;

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
    procedure ApplyActionPermissions;
    function ReloadCurrentUser: Boolean;
    procedure RefreshUserPermissions(AShowInfo: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure ResetSession(pPanelGroupboxPagecontrolTabsheet: TWinControl);
    procedure tmrcheck_is_update_requiredTimer(Sender: TObject);
    procedure actsys_permission_groupExecute(Sender: TObject);
    procedure actsys_permissionExecute(Sender: TObject);
    procedure actsys_userExecute(Sender: TObject);
    procedure actsys_access_rightExecute(Sender: TObject);
    procedure actsys_grid_columnExecute(Sender: TObject);
    procedure actsys_grid_filterExecute(Sender: TObject);
    procedure actsys_grid_sortExecute(Sender: TObject);
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
    procedure actsys_refresh_permissionsExecute(Sender: TObject);
    procedure actsys_updateExecute(Sender: TObject);
    procedure actsys_countryExecute(Sender: TObject);
    procedure actsys_cityExecute(Sender: TObject);
    procedure actacc_exchange_rateExecute(Sender: TObject);
    procedure actset_prs_bolumExecute(Sender: TObject);
    procedure actset_prs_lisanExecute(Sender: TObject);
    procedure actset_prs_gorevExecute(Sender: TObject);
    procedure actset_prs_birimExecute(Sender: TObject);
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
    procedure actstk_product_typesExecute(Sender: TObject);
    procedure actstk_kind_familiesExecute(Sender: TObject);
    procedure actset_ch_vergi_oraniExecute(Sender: TObject);
    procedure actset_prs_bolumlerExecute(Sender: TObject);
    procedure actset_prs_birimlerExecute(Sender: TObject);
    procedure actset_prs_gorevlerExecute(Sender: TObject);
    procedure actprs_ehliyetlerExecute(Sender: TObject);
    procedure actprs_lisan_bilgileriExecute(Sender: TObject);
    procedure actprs_personellerExecute(Sender: TObject);
    procedure actset_prs_lisanlarExecute(Sender: TObject);
    procedure actset_prs_ehliyetlerExecute(Sender: TObject);
    procedure actset_prs_personel_tipleriExecute(Sender: TObject);
    procedure actals_tekliflerExecute(Sender: TObject);
    procedure actch_bankalarExecute(Sender: TObject);
    procedure actch_banka_subeleriExecute(Sender: TObject);
    procedure actacc_transfer_codeExecute(Sender: TObject);
    procedure actset_prs_tasima_servisleriExecute(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure actsys_decimal_placeExecute(Sender: TObject);
    procedure actsys_permission_templateExecute(Sender: TObject);
    procedure actsys_permission_template_rightExecute(Sender: TObject);
    procedure actsys_user_permission_templateExecute(Sender: TObject);
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
  ufrmAbout, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Constants, Ths.Globals;

procedure TfrmDashboard.actsys_aboutExecute(Sender: TObject);
var
  LTs: TTabSheet;
begin
  LTs := PageControl1.ActivePage;
  TfrmAbout.Create(Application).ShowModal;
  RefreshUserPermissions(False);

  if LTs.TabVisible then
    PageControl1.ActivePage := LTs;
end;

procedure TfrmDashboard.actacc_exchange_rateExecute(Sender: TObject);
begin
  TfrmAccExchangeRates.Create(Self, TAccExchangeRateService.Create, TAccExchangeRate.Create).Show;
end;

procedure TfrmDashboard.actals_tekliflerExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actacc_transfer_codeExecute(Sender: TObject);
begin
  TfrmAccTransferCodes.Create(Self, TAccTransferCodeService.Create, TAccTransferCode.Create).Show;
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
  TfrmAccRegions.Create(Self, TAccRegionService.Create, TAccRegion.Create).Show;
end;

procedure TfrmDashboard.actch_hesap_kartiExecute(Sender: TObject);
begin
  TfrmAccAccounts.Create(Self, TAccAccountService.Create, TAccAccount.Create).Show;
end;

procedure TfrmDashboard.actch_hesap_karti_araExecute(Sender: TObject);
var
  LTypeSvc: TAccSetAccountTypeService;
  LType: TAccSetAccountType;
  LTypeName: string;
  LFrm: TfrmAccAccounts;
begin
  // Ara hesaplar: hesap kartı listesi hesap tipine göre sabit filtreli açılır
  LTypeName := '';
  LTypeSvc := TAccSetAccountTypeService.Create;
  try
    LType := LTypeSvc.FindById(ACC_ACCOUNT_TYPE_INTERMEDIATE, False);
    try
      if Assigned(LType) then
        LTypeName := LType.AccountTypeName;
    finally
      LType.Free;
    end;
  finally
    LTypeSvc.Free;
  end;

  LFrm := TfrmAccAccounts.Create(Self, TAccAccountService.Create, TAccAccount.Create);
  LFrm.SetFixedAccountType(ACC_ACCOUNT_TYPE_INTERMEDIATE, LTypeName);
  LFrm.Show;
end;

procedure TfrmDashboard.actsys_refresh_permissionsExecute(Sender: TObject);
begin
  RefreshUserPermissions(True);
end;

// Oturumdaki kullanıcının DB'deki güncel durumu (super user, aktiflik, yönetici...) yerinde güncellenir.
// Nesne değiştirilmez: TSysUser oturum bilgisi (ActiveLanguage vb.) de taşır.
function TfrmDashboard.ReloadCurrentUser: Boolean;
var
  LSvc: TSysUserService;
  LUser: TSysUser;
begin
  Result := True;
  if not Assigned(TAppContext.Instance.CurrentUser) or not Assigned(TAppContext.Instance.CurrentUser.User) then
    Exit;

  LSvc := TSysUserService.Create;
  try
    LUser := LSvc.FindById(TAppContext.Instance.CurrentUser.GetUserId, False);
    try
      if not Assigned(LUser) or not LUser.Active then
        Exit(False);

      TAppContext.Instance.CurrentUser.User.Active := LUser.Active;
      TAppContext.Instance.CurrentUser.User.SuperUser := LUser.SuperUser;
      TAppContext.Instance.CurrentUser.User.Manager := LUser.Manager;
    finally
      LUser.Free;
    end;
  finally
    LSvc.Free;
  end;
end;

// Hak değişikliklerini uygular: gelen hakların menüleri açılır, gidenlerinki pasif olur.
// Açık ekranlar etkilenmez; onlarda işlem anında servis yine güncel yetkiyi kontrol eder.
procedure TfrmDashboard.RefreshUserPermissions(AShowInfo: Boolean);
begin
  // Dashboard login'den önce oluşturulur; oturum yokken yenilenecek bir şey yok
  if not TAppContext.IsInitialized or not TAppContext.Instance.IsAuthenticated then
    Exit;

  try
    if not ReloadCurrentUser then
    begin
      ShowMessage(TLocalizationManager.Translate(TLangKeys.TDashboard.MsgUserInactive,
        'Your user account has been deactivated or deleted. The application will close.'));
      Application.Terminate;
      Exit;
    end;
  except
    on E: Exception do
      GLogger.ErrorFmt('Kullanıcı bilgisi yenilenemedi: %s', [E.Message]);
  end;

  SetSession;

  if AShowInfo then
    ShowMessage(TLocalizationManager.Translate(TLangKeys.TDashboard.MsgPermissionsRefreshed, 'Your permissions have been refreshed.'));
end;

procedure TfrmDashboard.actsys_update_passwordExecute(Sender: TObject);
begin
  TfrmSysUserPassword.ShowChange(Self);
end;

procedure TfrmDashboard.actodeme_baslangic_donemleriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_birimlerExecute(Sender: TObject);
begin
  TfrmEmpUnits.Create(Self, TEmpUnitService.Create, TEmpUnit.Create).Show;
end;

procedure TfrmDashboard.actset_prs_bolumlerExecute(Sender: TObject);
begin
  TfrmEmpSections.Create(Self, TEmpSectionService.Create, TEmpSection.Create).Show;
end;

procedure TfrmDashboard.actset_prs_ehliyetlerExecute(Sender: TObject);
begin
  TfrmEmpDriverLicenceTypes.Create(Self, TEmpDriverLicenseTypeService.Create, TEmpDriverLicenseType.Create).Show;
end;

procedure TfrmDashboard.actset_prs_gorevlerExecute(Sender: TObject);
begin
  TfrmEmpTasks.Create(Self, TEmpTaskService.Create, TEmpTask.Create).Show;
end;

procedure TfrmDashboard.actprs_ehliyetlerExecute(Sender: TObject);
begin
  TfrmEmpDriverLicences.Create(Self, TEmpDriverLicenceService.Create, TEmpDriverLicence.Create).Show;
end;

procedure TfrmDashboard.actprs_lisan_bilgileriExecute(Sender: TObject);
begin
  TfrmEmpLanguageAbilities.Create(Self, TEmpLanguageAbilityService.Create, TEmpLanguageAbility.Create).Show;
end;

procedure TfrmDashboard.actprs_personellerExecute(Sender: TObject);
begin
  TfrmEmpEmployees.Create(Self, TEmpEmployeeService.Create, TEmpEmployee.Create).Show;
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
  TfrmAccSetCompanyLegalForms.Create(Self, TAccSetCompanyLegalFormService.Create, TAccSetCompanyLegalForm.Create).Show;
end;

procedure TfrmDashboard.actset_ch_firma_turuExecute(Sender: TObject);
begin
  TfrmAccSetOwnershipTypes.Create(Self, TAccSetOwnershipTypeService.Create, TAccSetOwnershipType.Create).Show;
end;

procedure TfrmDashboard.actset_ch_grupExecute(Sender: TObject);
begin
  TfrmAccGroups.Create(Self, TAccGroupService.Create, TAccGroup.Create).Show;
end;

procedure TfrmDashboard.actset_ch_hesap_planiExecute(Sender: TObject);
begin
  TfrmAccAccountPlans.Create(Self, TAccAccountPlanService.Create, TAccAccountPlan.Create).Show;
end;

procedure TfrmDashboard.actset_ch_hesap_tipiExecute(Sender: TObject);
begin
  TfrmAccSetAccountTypes.Create(Self, TAccSetAccountTypeService.Create, TAccSetAccountType.Create).Show;
end;

procedure TfrmDashboard.actset_ch_vergi_oraniExecute(Sender: TObject);
begin
  TfrmAccSetTaxRates.Create(Self, TAccSetTaxRateService.Create, TAccSetTaxRate.Create).Show;
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
  TfrmEmpLanguages.Create(Self, TEmpLanguageService.Create, TEmpLanguage.Create).Show;
end;

procedure TfrmDashboard.actset_prs_personel_tipleriExecute(Sender: TObject);
begin
  TfrmEmpPersonTypes.Create(Self, TEmpPersonTypeService.Create, TEmpPersonType.Create).Show;
end;

procedure TfrmDashboard.actset_prs_tasima_servisleriExecute(Sender: TObject);
begin
  TfrmEmpTransportations.Create(Self, TEmpTransportationService.Create, TEmpTransportation.Create).Show;
end;

procedure TfrmDashboard.actstk_product_typesExecute(Sender: TObject);
begin
  TfrmStkProductTypes.Create(Self, TStkProductTypeService.Create, TStkProductType.Create).Show;
end;

procedure TfrmDashboard.actstk_kind_familiesExecute(Sender: TObject);
begin
  TfrmStkKindFamilies.Create(Self, TStkKindFamilyService.Create, TStkKindFamily.Create).Show;
end;

procedure TfrmDashboard.actstk_ambarlarExecute(Sender: TObject);
begin
  TfrmStkWarehouses.Create(Self, TStkWarehouseService.Create, TStkWarehouse.Create).Show;
end;

procedure TfrmDashboard.actstk_cins_ozellikleriExecute(Sender: TObject);
begin
  TfrmStkKindProperties.Create(Self, TStkKindPropertyService.Create, TStkKindProperty.Create).Show;
end;

procedure TfrmDashboard.actstk_gruplarExecute(Sender: TObject);
begin
  TfrmStkGroups.Create(Self, TStkGroupService.Create, TStkGroup.Create).Show;
end;

procedure TfrmDashboard.actstk_hareketlerExecute(Sender: TObject);
begin
  TfrmStkTransactions.Create(Self, TStkTransactionService.Create, TStkTransaction.Create).Show;
end;

procedure TfrmDashboard.actstk_stok_hareketiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actstk_stok_karti_ozetleriExecute(Sender: TObject);
begin
  TfrmStkInventorySummaries.Create(Self, TStkInventorySummaryService.Create, TStkInventorySummary.Create).Show;
end;

procedure TfrmDashboard.actstk_stok_kartlariExecute(Sender: TObject);
begin
  TfrmStkInventories.Create(Self, TStkInventoryService.Create, TStkInventory.Create).Show;
end;

procedure TfrmDashboard.actsys_cityExecute(Sender: TObject);
begin
  TfrmSysCities.Create(Self, TSysCityService.Create, TSysCity.Create).Show;
end;

procedure TfrmDashboard.actsys_grid_columnExecute(Sender: TObject);
begin
  TfrmSysGridColumns.Create(Self, TSysGridColumnService.Create, TSysGridColumn.Create).Show;
end;

procedure TfrmDashboard.actsys_grid_filterExecute(Sender: TObject);
begin
  TfrmSysGridFilters.Create(Self, TSysGridFilterService.Create, TSysGridFilter.Create).Show;
end;

procedure TfrmDashboard.actsys_grid_sortExecute(Sender: TObject);
begin
  TfrmSysGridSorts.Create(Self, TSysGridSortService.Create, TSysGridSort.Create).Show;
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
  TfrmSysUomGroups.Create(Self, TSysUomGroupService.Create, TSysUomGroup.Create).Show;
end;

procedure TfrmDashboard.actsys_unitExecute(Sender: TObject);
begin
  TfrmSysUoms.Create(Self, TSysUomService.Create, TSysUom.Create).Show;
end;

procedure TfrmDashboard.actsys_currencyExecute(Sender: TObject);
begin
  TfrmSysCurrencies.Create(Self, TSysCurrencyService.Create, TSysCurrency.Create).Show;
end;

procedure TfrmDashboard.actsys_decimal_placeExecute(Sender: TObject);
var
  LSvc         : TSysDecimalPlaceService;
  LDecimalPlace: TSysDecimalPlace;
  LFilter      : TFilterCriteria;
begin
  LSvc    := TSysDecimalPlaceService.Create;
  LFilter := TFilterCriteria.Create;
  try
    LDecimalPlace := LSvc.FindOne(LFilter, False);
    if LDecimalPlace = nil then
      TfrmSysDecimalPlace.Create(
        Self,
        LSvc,
        TSysDecimalPlace.Create,
        ifmNewRecord, nil, ivmNormal, True).Show
    else
      TfrmSysDecimalPlace.Create(
        Self,
        LSvc,
        LDecimalPlace,
        ifmRewiev, nil, ivmNormal, True).Show;
    LSvc := nil; // Ownership transferred to form
  finally
    LFilter.Free;
    LSvc.Free;
  end;
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
var
  LService: TSysApplicationSettingService;
  LSetting: TSysApplicationSetting;
  LMode: TInputFormMode;
begin
  // Tablo tek kayıt tutar: varsa inceleme modunda, yoksa yeni kayıt olarak aç
  LService := TSysApplicationSettingService.Create;
  try
    LSetting := LService.BusinessFindSetting(False, False, True);
  except
    LService.Free;
    raise;
  end;

  if Assigned(LSetting) then
    LMode := ifmRewiev
  else
  begin
    LSetting := TSysApplicationSetting.Create;
    LMode := ifmNewRecord;
  end;

  TfrmSysApplicationSetting.Create(Self, LService, LSetting, LMode, nil, ivmNormal, True).Show;
end;

procedure TfrmDashboard.actsys_permission_templateExecute(Sender: TObject);
begin
  TfrmSysPermissionTemplates.Create(Self, TSysPermissionTemplateService.Create, TSysPermissionTemplate.Create).Show;
end;

procedure TfrmDashboard.actsys_permission_template_rightExecute(Sender: TObject);
begin
  TfrmSysPermissionTemplateRights.Create(Self, TSysPermissionTemplateRightService.Create, TSysPermissionTemplateRight.Create).Show;
end;

procedure TfrmDashboard.actsys_user_permission_templateExecute(Sender: TObject);
begin
  TfrmSysUserPermissionTemplates.Create(Self, TSysUserPermissionTemplateService.Create, TSysUserPermissionTemplate.Create).Show;
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
    TLocalizationManager.Translate(TLangKeys.TMessage.ConfirmUpdate, 'Are you sure you want to proceed with the update?'),
    mtConfirmation, mbYesNo,
    [
      TLocalizationManager.Translate(TLangKeys.TGeneral.Yes, 'Yes'),
      TLocalizationManager.Translate(TLangKeys.TGeneral.No, 'No')
    ],
    mbNo,
    TLocalizationManager.Translate(TLangKeys.TMessage.UpdateConfirmation, 'Confirmation')
  ) = mrYes
  then
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
    TLocalizationManager.Translate(TLangKeys.TMessage.ConfirmExitApp, 'The application will be terminated. Are you sure you want to continue?'),
    mtConfirmation, mbYesNo,
    [
      TLocalizationManager.Translate(TLangKeys.TGeneral.Yes, 'Yes'),
      TLocalizationManager.Translate(TLangKeys.TGeneral.No, 'No')
    ],
    mbNo,
    TLocalizationManager.Translate(TLangKeys.TGeneral.Confirmation, 'Confirmation')
  ) = mrYes
  then
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

  if APP_VERSION <> LSurum then
  begin
    LMr := CustomMsgDlg(
      TLocalizationManager.Translate(TLangKeys.TMessage.NewVersionAvailable, 'There is a new update for the program. Would you like to update now?') + AddLBs(2) +
      TLocalizationManager.Translate(TLangKeys.TMessage.UpdateRecommended, 'Due to system errors or critical updates, it is recommended that you update as soon as possible.'),
      mtConfirmation,
      mbYesNo,
      [
        TLocalizationManager.Translate('btn.update_now', 'Yes Update'),
        TLocalizationManager.Translate('btn.update_later', 'No Update later')
      ],
      mbNo,
      TLocalizationManager.Translate(TLangKeys.TMessage.UserUpdateConfirmation, 'Confirmation')
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

  mnimenu_language.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuLanguageChanger, 'Lisan / Language');
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
          if not TLocalizationManager.LanguageFileExists(LLang.Locale) then
            Continue;

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
  LLocalizable: ILocalizable;
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
      TLocalizationManager.Translate(TLangKeys.TMessage.FinishEditingBeforeLangChange, 'Please complete your save/cancel actions on the open editing screens before changing the language.'),
      mtWarning, [mbOK],
      [TLocalizationManager.Translate(TLangKeys.TGeneral.OK, 'Ok')],
      mbOK,
      TLocalizationManager.Translate(TLangKeys.TMessage.WarningTitle, 'Warning')
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
    if (LForm = Self) then
      Continue;

    if Supports(LForm, ILocalizable, LLocalizable) then
      LLocalizable.ApplyLocalization;
  end;
end;

procedure TfrmDashboard.ApplyLocalization;
begin
  inherited;
  if Assigned(btnClose) then
    btnClose.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.Close, 'Close');

  if Assigned(mnimenu_language) then
    mnimenu_language.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuLanguage, 'Lisan | Language');

  {$REGION 'SystemMenu'}
  if Assigned(mnimenu_system) then
    mnimenu_system.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuSystem, 'System');
      if Assigned(actsys_user) then
        actsys_user.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionUsers, 'Users');
      if Assigned(actsys_access_right) then
        actsys_access_right.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionAccessRights, 'User Access Rights');

      if Assigned(actsys_application_setting) then
        actsys_application_setting.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionAppSettings, 'Aplication Setting');

      if Assigned(actsys_grid_column) then
        actsys_grid_column.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionGridColumns, 'Grid Columns');
      if Assigned(actsys_grid_filter) then
        actsys_grid_filter.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionGridFilters, 'Grid Filters');
      if Assigned(actsys_grid_sort) then
        actsys_grid_sort.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionGridSorts, 'Grid Sorts');

      if Assigned(actsys_permission_group) then
        actsys_permission_group.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionPermissionGroups, 'Permission Groups');
      if Assigned(actsys_permission) then
        actsys_permission.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionPermissions, 'Permissions');
      if Assigned(actsys_permission_template) then
        actsys_permission_template.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionPermissionTemplates, 'Permission Templates');
      if Assigned(actsys_permission_template_right) then
        actsys_permission_template_right.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionPermissionTemplateRights, 'Template Rights');
      if Assigned(actsys_user_permission_template) then
        actsys_user_permission_template.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionUserPermissionTemplates, 'User Permission Templates');

      if Assigned(mniSystemSubSettings) then
        mniSystemSubSettings.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuSettings, 'Setting');
          if Assigned(actsys_region) then
            actsys_region.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionRegions, 'Regions');
          if Assigned(actsys_country) then
            actsys_country.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionCountries, 'Countries');
          if Assigned(actsys_city) then
            actsys_city.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionCities, 'Cities');

          if Assigned(actsys_decimal_place) then
            actsys_decimal_place.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionDecimalPlace, 'DecimalPlace');

          if Assigned(actsys_unit_type) then
            actsys_unit_type.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionUnitTypes, 'Measurement Types');
          if Assigned(actsys_unit) then
            actsys_unit.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionUnits, 'Measurements');
          if Assigned(actsys_currency) then
            actsys_currency.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionCurrencies, 'Currencies');

          if Assigned(actsys_language) then
            actsys_language.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionLanguages, 'Languages');
  {$ENDREGION}

  {$REGION 'PurchasingMenu'}
  if Assigned(mnimenu_purchase) then
    mnimenu_purchase.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuPurchasing, 'Purchasing');
      if Assigned(mnipur_offer) then
        mnipur_offer.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuOffers, 'Offers');
      if Assigned(mnipur_order) then
        mnipur_order.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuOrders, 'Orders');
      if Assigned(mnipur_waybill) then
        mnipur_waybill.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuWaybills, 'Waybills');
      if Assigned(mnipur_invoice) then
        mnipur_invoice.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuInvoices, 'Invoices');
  {$ENDREGION}

  {$REGION 'SalesMenu'}
  if Assigned(mnimenu_sales) then
    mnimenu_sales.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuSales, 'Sales');
  {$ENDREGION}

  {$REGION 'AccountingMenu'}
  if Assigned(mnimenu_accounting) then
    mnimenu_accounting.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuAccounting, 'Accounting');
      if Assigned(mniAccountingSubSettings) then
        mniAccountingSubSettings.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuSettings, 'Setting');
      if Assigned(actch_hesap_karti) then
        actch_hesap_karti.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.TitlePlural, 'Account Cards');
      if Assigned(actch_bolge) then
        actch_bolge.Caption := TLocalizationManager.Translate(TLangKeys.TAccRegion.TitlePlural, 'Account Regions');
      if Assigned(actset_ch_grup) then
        actset_ch_grup.Caption := TLocalizationManager.Translate(TLangKeys.TAccGroup.TitlePlural, 'Account Groups');
      if Assigned(actset_ch_hesap_plani) then
        actset_ch_hesap_plani.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccountPlan.TitlePlural, 'Account Plans');
      if Assigned(actset_ch_hesap_tipi) then
        actset_ch_hesap_tipi.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetAccountType.TitlePlural, 'Account Types');
      if Assigned(actset_ch_firma_turu) then
        actset_ch_firma_turu.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetOwnershipType.TitlePlural, 'Ownership Types');
      if Assigned(actset_ch_firma_tipi) then
        actset_ch_firma_tipi.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetCompanyLegalForm.TitlePlural, 'Company Legal Forms');
      if Assigned(actacc_transfer_code) then
        actacc_transfer_code.Caption := TLocalizationManager.Translate(TLangKeys.TAccTransferCode.TitlePlural, 'Transfer Codes');
      if Assigned(actch_hesap_karti_ara) then
        actch_hesap_karti_ara.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.BtnSubAccount, 'Sub Account Cards');
      if Assigned(actacc_exchange_rate) then
        actacc_exchange_rate.Caption := TLocalizationManager.Translate(TLangKeys.TAccExchangeRate.TitlePlural, 'Exchange Rates');
      if Assigned(actset_ch_vergi_orani) then
        actset_ch_vergi_orani.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetTaxRate.TitlePlural, 'Tax Rates');
      if Assigned(actch_bankalar) then
        actch_bankalar.Caption := TLocalizationManager.Translate(TLangKeys.TAccBank.TitlePlural, 'Banks');
      if Assigned(actch_banka_subeleri) then
        actch_banka_subeleri.Caption := TLocalizationManager.Translate(TLangKeys.TAccBankBranch.TitlePlural, 'Bank Branches');
  {$ENDREGION}

  {$REGION 'StockMenu'}
  if Assigned(mnimenu_stock) then
    mnimenu_stock.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuStock, 'Stocks');
  if Assigned(actstk_stok_kartlari) then
    actstk_stok_kartlari.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.TitlePlural, 'Stock Cards');
  if Assigned(actstk_hareketler) then
    actstk_hareketler.Caption := TLocalizationManager.Translate(TLangKeys.TStkTransaction.TitlePlural, 'Stock Transactions');
  if Assigned(actstk_stok_karti_ozetleri) then
    actstk_stok_karti_ozetleri.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.TitlePlural, 'Stock Summaries');
  if Assigned(actstk_ambarlar) then
    actstk_ambarlar.Caption := TLocalizationManager.Translate(TLangKeys.TStkWarehouse.TitlePlural, 'Warehouses');
  if Assigned(actstk_gruplar) then
    actstk_gruplar.Caption := TLocalizationManager.Translate(TLangKeys.TStkGroup.TitlePlural, 'Stock Groups');
  if Assigned(actstk_product_types) then
    actstk_product_types.Caption := TLocalizationManager.Translate(TLangKeys.TStkProductType.TitlePlural, 'Product Types');
  if Assigned(actstk_kind_families) then
    actstk_kind_families.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindFamily.TitlePlural, 'Kind Families');
  if Assigned(actstk_cins_ozellikleri) then
    actstk_cins_ozellikleri.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.TitlePlural, 'Kind Properties');
  if Assigned(mniStockSubSettings) then
    mniStockSubSettings.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuSettings, 'Setting');
  {$ENDREGION}


  {$REGION 'PersonMenu'}
  if Assigned(mnimenu_employee) then
    mnimenu_employee.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuPersonnel, 'Personnels');
      if Assigned(mniEmployeeSubSettings) then
        mniEmployeeSubSettings.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuSettings, 'Setting');
      if Assigned(actprs_ehliyetler) then
        actprs_ehliyetler.Caption := TLocalizationManager.Translate(TLangKeys.TEmpDriverAbility.TitlePlural, 'Employee Driver Licenses');
      if Assigned(actprs_lisan_bilgileri) then
        actprs_lisan_bilgileri.Caption := TLocalizationManager.Translate(TLangKeys.TEmpLanguageAbility.TitlePlural, 'Employee Languages');
      if Assigned(actset_prs_bolumler) then
        actset_prs_bolumler.Caption := TLocalizationManager.Translate(TLangKeys.TEmpSection.TitlePlural, 'Sections');
      if Assigned(actset_prs_birimler) then
        actset_prs_birimler.Caption := TLocalizationManager.Translate(TLangKeys.TEmpUnit.TitlePlural, 'Units');
      if Assigned(actset_prs_gorevler) then
        actset_prs_gorevler.Caption := TLocalizationManager.Translate(TLangKeys.TEmpTask.TitlePlural, 'Tasks');
      if Assigned(actset_prs_ehliyetler) then
        actset_prs_ehliyetler.Caption := TLocalizationManager.Translate(TLangKeys.TEmpDriverLicenseType.TitlePlural, 'Driver License Types');
      if Assigned(actset_prs_lisanlar) then
        actset_prs_lisanlar.Caption := TLocalizationManager.Translate(TLangKeys.TEmpLanguage.TitlePlural, 'Foreign Languages');
      if Assigned(actset_prs_personel_tipleri) then
        actset_prs_personel_tipleri.Caption := TLocalizationManager.Translate(TLangKeys.TEmpPersonType.TitlePlural, 'Employee Types');
      if Assigned(actset_prs_tasima_servisleri) then
        actset_prs_tasima_servisleri.Caption := TLocalizationManager.Translate(TLangKeys.TEmpTransportation.TitlePlural, 'Shuttle Services');
  {$ENDREGION}

  {$REGION 'AboutMenu'}
  if Assigned(mnimenu_about) then
    mnimenu_about.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuAbout, 'About');
      if Assigned(actsys_refresh_permissions) then
        actsys_refresh_permissions.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuRefreshPermissions, 'Refresh My Permissions');
      if Assigned(mnisys_update_password) then
        mnisys_update_password.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuChangePassword, 'Change Password');
      if Assigned(mnisys_database_status) then
        mnisys_database_status.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuDbMonitor, 'Database Status');
      if Assigned(mnisys_do_database_backup) then
        mnisys_do_database_backup.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuDbBackup, 'Backup Database');
      if Assigned(mnisys_update) then
        mnisys_update.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuUpdate, 'Update');
      if Assigned(mnisys_about) then
        mnisys_about.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuAbout, 'About');
  {$ENDREGION}


  // PageControl Tabs
  if Assigned(tsgeneral) then
    tsgeneral.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.TabGeneral, 'General');
  if Assigned(tssales) then
    tssales.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.TabSales, 'Sales');
  if Assigned(tsstock) then
    tsstock.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.TabStock, 'Stocks');
  if Assigned(tsaccount) then
    tsaccount.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.TabAccounts, 'Accounts');
  if Assigned(tsemployee) then
    tsemployee.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.TabEmployee, 'Employee');
  if Assigned(tsbom) then
    tsbom.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.TabRecipes, 'BoM');
  if Assigned(tsaccounting) then
    tsaccounting.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.TabAccounting, 'Accounting');


  // Tab Buttons
  if Assigned(btnsat_teklif) then
    btnsat_teklif.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.BtnOffers, 'Offers');
  if Assigned(btnsat_siparis) then
    btnsat_siparis.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.BtnOrders, 'Orders');
  if Assigned(btnsat_teklif_rapor) then
    btnsat_teklif_rapor.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.BtnOfferReports, 'Offer Reports');
  if Assigned(btnsat_siparis_rapor) then
    btnsat_siparis_rapor.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.BtnOrderReports, 'Order Reports');
  if Assigned(btnch_bolge) then
    btnch_bolge.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.BtnRegion, 'Region');
  if Assigned(btnch_banka) then
    btnch_banka.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.BtnBanks, 'Banks');
  if Assigned(btnch_banka_subesi) then
    btnch_banka_subesi.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.BtnBankBranches, 'Bank Branches');
  if Assigned(btnset_ch_grup) then
    btnset_ch_grup.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.BtnAccountGroups, 'Account Groups');
  if Assigned(btnset_ch_hesap_plani) then
    btnset_ch_hesap_plani.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.BtnAccountPlans, 'Account Plans');
  if Assigned(btnch_hesap_karti_ara) then
    btnch_hesap_karti_ara.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.BtnSubAccount, 'Sub Account Cards');
  if Assigned(btnch_hesap_karti) then
    btnch_hesap_karti.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.BtnAccountCard, 'Account Cards');
  if Assigned(btnset_ch_vergi_orani) then
    btnset_ch_vergi_orani.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.BtnTaxRates, 'Vat Rates');
  if Assigned(btnrct_recete) then
    btnrct_recete.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.BtnRecipes, 'BoM');
  if Assigned(btnrct_iscilik_gideri) then
    btnrct_iscilik_gideri.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.BtnLaborCosts, 'Labours');
  if Assigned(btnrct_paket_hammadde) then
    btnrct_paket_hammadde.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.BtnPacketRawMaterials, 'Packet Raw Materials');

  // Status Bar Panels
  if stbBase.Panels.Count >= STATUS_KEY_F4+1 then
    stbBase.Panels.Items[STATUS_KEY_F4].Text := 'F4 ' + TLocalizationManager.Translate(TLangKeys.TGeneral.Delete, 'Delete');
  if stbBase.Panels.Count >= STATUS_KEY_F5+1 then
    stbBase.Panels.Items[STATUS_KEY_F5].Text := 'F5 ' + TLocalizationManager.Translate(TLangKeys.TGeneral.Confirm, 'Accept');
  if stbBase.Panels.Count >= STATUS_KEY_F6+1 then
    stbBase.Panels.Items[STATUS_KEY_F6].Text := 'F6 ' + TLocalizationManager.Translate(TLangKeys.TGeneral.Cancel, 'Cancel');
  if stbBase.Panels.Count >= STATUS_KEY_F7+1 then
    stbBase.Panels.Items[STATUS_KEY_F7].Text := 'F7 ' + TLocalizationManager.Translate(TLangKeys.TGeneral.AddRecord, 'Add Record');
  if stbBase.Panels.Count >= STATUS_KEY_F11+1 then
    stbBase.Panels.Items[STATUS_KEY_F11].Text := TLocalizationManager.Translate(TLangKeys.TGeneral.KeyF11, 'F11 Opacity');
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

  // FIX: Panel eklemeyi bir kez yap
  if stbBase.Panels.Count = 0 then
  begin
    AddPanel(80, psOwnerDraw); // STATUS_RECORD_COUNT
    AddPanel(80, psOwnerDraw); // STATUS_SQL_SERVER
    AddPanel(80, psOwnerDraw); // STATUS_DATE
    AddPanel(80, psOwnerDraw); // STATUS_USERNAME
    AddPanel(80, psOwnerDraw); // STATUS_KEY_F4
    AddPanel(80, psOwnerDraw); // STATUS_KEY_F5
    AddPanel(80, psOwnerDraw); // STATUS_KEY_F6
    AddPanel(80, psOwnerDraw); // STATUS_KEY_F7 / F11
  end;

  if TConnectionManager.Instance.IsConnected(ContextMain) then
  begin
    if stbBase.Panels.Count > STATUS_SQL_SERVER then
      stbBase.Panels.Items[STATUS_SQL_SERVER].Text := TConnectionManager.Instance.GetConnection(ContextMain).Params.Values['Server'];

    if stbBase.Panels.Count > STATUS_DATE then
      stbBase.Panels.Items[STATUS_DATE].Text := DateToStr(Now);
  end;

  if Assigned(TAppContext.Instance.CurrentUser) and (stbBase.Panels.Count > STATUS_USERNAME) then
    stbBase.Panels.Items[STATUS_USERNAME].Text := TAppContext.Instance.CurrentUser.GetUsername;

  ApplyLocalization;
  Self.Caption := getFormCaptionByLang(Self.Name, Self.Caption);

  mnimenu_system.Visible := True;
  tsemployee.TabVisible  := False;
  tsaccount.TabVisible   := False;
  tsstock.TabVisible     := False;
  tssales.TabVisible     := False;
  tsgeneral.TabVisible   := False;

  FocusedFirstControl(PageControl1.ActivePage);

  tmrcheck_is_update_required.Enabled := True;
  Caption := Caption + ' v' + APP_VERSION;

  SetSession;
  FIsFormShow := False;

  // FIX: TUnitOfWork.Initialize login'de zaten çağrıldı
  // Burada tekrar çağırmak gerekmiyor — sadece bağlantı kontrolü
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

// Menü / buton erişimi: okuma hakkı olmayan ekranın action'ı pasif (menü öğesi ve buton birlikte).
// Ekranın kendisi (TfrmGrid) ve servisler ayrıca kontrol eder.
procedure TfrmDashboard.ApplyActionPermissions;
var
  LIsSuperUser: Boolean;
  LCodes: TArray<Integer>;
  LSvc: TSysAccessRightService;

  procedure SetAction(AAction: TAction; APermissionCode: Integer);
  var
    LCode: Integer;
    LAllowed: Boolean;
  begin
    if not Assigned(AAction) then
      Exit;
    LAllowed := LIsSuperUser;
    if not LAllowed then
      for LCode in LCodes do
        if LCode = APermissionCode then
        begin
          LAllowed := True;
          Break;
        end;
    // ResetSession butonları doğrudan pasif yapabiliyor; değer değişmezse action istemcilere yaymaz
    AAction.Enabled := not LAllowed;
    AAction.Enabled := LAllowed;
  end;

begin
  if not TAppContext.IsInitialized then
    Exit;

  LIsSuperUser := Assigned(TAppContext.Instance.CurrentUser) and TAppContext.Instance.CurrentUser.IsSuperUser;
  LCodes := [];
  if not LIsSuperUser then
  begin
    LSvc := TSysAccessRightService.Create;
    try
      try
        LCodes := LSvc.GetReadablePermissionCodes;
      except
        on E: Exception do
          GLogger.ErrorFmt('Menü yetkileri okunamadı: %s', [E.Message]);
      end;
    finally
      LSvc.Free;
    end;
  end;

  SetAction(actsys_city, PERMISSION_SYS_CITY);
  SetAction(actsys_country, PERMISSION_SYS_COUNTRY);
  SetAction(actsys_region, PERMISSION_SYS_REGION);
  SetAction(actsys_currency, PERMISSION_SYS_CURRENCY);
  SetAction(actsys_unit_type, PERMISSION_SYS_UOM_GROUP);
  SetAction(actsys_unit, PERMISSION_SYS_UOM);
  SetAction(actsys_language, PERMISSION_SYS_LANGUAGE);
  SetAction(actsys_decimal_place, PERMISSION_SYS_DECIMAL_PLACE);
  SetAction(actsys_user, PERMISSION_SYS_USER);
  SetAction(actsys_access_right, PERMISSION_SYS_ACCESS_RIGHT);
  SetAction(actsys_permission, PERMISSION_SYS_PERMISSION);
  SetAction(actsys_permission_group, PERMISSION_SYS_PERMISSION_GROUP);
  SetAction(actsys_permission_template, PERMISSION_SYS_PERMISSION_TEMPLATE);
  SetAction(actsys_permission_template_right, PERMISSION_SYS_PERMISSION_TEMPLATE);
  SetAction(actsys_user_permission_template, PERMISSION_SYS_USER_PERMISSION_TEMPLATE);
  SetAction(actsys_application_setting, PERMISSION_SYS_APPLICATION_SETTING);
  SetAction(actsys_grid_column, PERMISSION_SYS_GRID_COLUMN);
  SetAction(actsys_grid_filter, PERMISSION_SYS_GRID_FILTER);
  SetAction(actsys_grid_sort, PERMISSION_SYS_GRID_SORT);
  SetAction(actprs_personeller, PERMISSION_EMP_EMPLOYEE);
  SetAction(actprs_ehliyetler, PERMISSION_EMP_EMPLOYEE);
  SetAction(actprs_lisan_bilgileri, PERMISSION_EMP_EMPLOYEE);
  SetAction(actset_prs_personel_tipleri, PERMISSION_EMP_PERSON_TYPE);
  SetAction(actset_prs_bolumler, PERMISSION_EMP_SECTION);
  SetAction(actset_prs_birimler, PERMISSION_EMP_UNIT);
  SetAction(actset_prs_gorevler, PERMISSION_EMP_TASK);
  SetAction(actset_prs_tasima_servisleri, PERMISSION_EMP_TRANSPORTATION);
  SetAction(actset_prs_lisanlar, PERMISSION_EMP_LANGUAGE);
  SetAction(actset_prs_ehliyetler, PERMISSION_EMP_DRIVER_LICENSE_TYPE);
  SetAction(actch_bankalar, PERMISSION_ACC_BANK);
  SetAction(actch_banka_subeleri, PERMISSION_ACC_BANK);
  SetAction(actch_hesap_karti, PERMISSION_ACC_ACCOUNT);
  SetAction(actch_hesap_karti_ara, PERMISSION_ACC_ACCOUNT);
  SetAction(actch_bolge, PERMISSION_ACC_REGION);
  SetAction(actset_ch_grup, PERMISSION_ACC_GROUP);
  SetAction(actset_ch_hesap_plani, PERMISSION_ACC_ACCOUNT_PLAN);
  SetAction(actset_ch_hesap_tipi, PERMISSION_ACC_ACCOUNT_TYPE);
  SetAction(actset_ch_firma_turu, PERMISSION_ACC_OWNERSHIP_TYPE);
  SetAction(actset_ch_firma_tipi, PERMISSION_ACC_COMPANY_LEGAL_FORM);
  SetAction(actacc_transfer_code, PERMISSION_ACC_TRANSFER_CODE);
  SetAction(actacc_exchange_rate, PERMISSION_ACC_EXCHANGE_RATE);
  SetAction(actset_ch_vergi_orani, PERMISSION_ACC_TAX_RATE);
  SetAction(actstk_stok_kartlari, PERMISSION_STK_INVENTORY);
  SetAction(actstk_hareketler, PERMISSION_STK_TRANSACTION);
  SetAction(actstk_stok_karti_ozetleri, PERMISSION_STK_INVENTORY_SUMMARY);
  SetAction(actstk_ambarlar, PERMISSION_STK_WAREHOUSE);
  SetAction(actstk_gruplar, PERMISSION_STK_GROUP);
  SetAction(actstk_product_types, PERMISSION_STK_PRODUCT_TYPE);
  SetAction(actstk_kind_families, PERMISSION_STK_KIND_FAMILY);
  SetAction(actstk_cins_ozellikleri, PERMISSION_STK_KIND_PROPERTY);
end;

procedure TfrmDashboard.SetSession;
//var
//  LRights: TSysErisimHakki;
//  n1: Integer;
begin
  ResetSession(pnlMain);
  ApplyActionPermissions;
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
