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
  SysDashboard, SysDashboard.Service, DashboardControls,
  SysMenu, SysMenu.Service, NavigationTree, ScreenCode,
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
  ufrmPrdBoms, PrdBom.Service, PrdBom,
  ufrmPrdLabours, PrdLabour.Service, PrdLabour,
  ufrmPrdPacketRaws, PrdPacketRaw.Service, PrdPacketRaw,
  ufrmPrdPacketLabours, PrdPacketLabour.Service, PrdPacketLabour,
  FinLookup,
  ufrmFinChequeNotes, FinChequeNote.Service, FinChequeNote,
  ufrmFinChequeNoteTransactions, FinChequeNoteTransaction.Service, FinChequeNoteTransaction,
  ufrmFinCreditCards, FinCreditCard.Service, FinCreditCard,
  ufrmFinCreditCardTransactions, FinCreditCardTransaction.Service, FinCreditCardTransaction,
  ufrmFinPosTerminals, FinPosTerminal.Service, FinPosTerminal,
  ufrmFinPosTransactions, FinPosTransaction.Service, FinPosTransaction,
  ufrmFinMoneyAccounts, FinMoneyAccount.Service, FinMoneyAccount,
  ufrmFinMoneyTransactions, FinMoneyTransaction.Service, FinMoneyTransaction,
  ufrmFinMoneyLedgers, FinMoneyLedger.Service, FinMoneyLedger,
  PurLookup,
  ufrmPurRequests, PurRequest.Service, PurRequest,
  ufrmPurRequestDetails, PurRequestDetail.Service, PurRequestDetail,
  ufrmPurOrders, PurOrder.Service, PurOrder,
  ufrmPurOrderDetails, PurOrderDetail.Service, PurOrderDetail,
  ufrmPurReceipts, PurReceipt.Service, PurReceipt,
  ufrmPurReceiptDetails, PurReceiptDetail.Service, PurReceiptDetail,
  ufrmPurInvoices, PurInvoice.Service, PurInvoice,
  ufrmPurInvoiceDetails, PurInvoiceDetail.Service, PurInvoiceDetail,
  ufrmFinCompanyBankAccounts, FinCompanyBankAccount.Service, FinCompanyBankAccount,
  ufrmAccAccountTransactions, AccAccountTransaction.Service, AccAccountTransaction,
  LocalizationManager;

type
  TfrmDashboard = class(TfrmBase)
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
    actsys_region: TAction;
    actsys_unit_type: TAction;
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
    actprd_bom: TAction;
    actprd_labour: TAction;
    actprd_packet_raw: TAction;
    actprd_packet_labour: TAction;
    mnimenu_production: TMenuItem;
    mniprd_bom: TMenuItem;
    mniprd_labour: TMenuItem;
    mniprd_packet_raw: TMenuItem;
    mniprd_packet_labour: TMenuItem;
    actacc_account_transactions: TAction;
    mniacc_account_transactions: TMenuItem;
    actfin_company_bank_accounts: TAction;
    mnifin_sep5: TMenuItem;
    mnifin_company_bank_accounts: TMenuItem;
    actpur_requests: TAction;
    actpur_request_lines: TAction;
    actpur_orders: TAction;
    actpur_order_lines: TAction;
    actpur_receipts: TAction;
    actpur_receipt_lines: TAction;
    actpur_invoices: TAction;
    actpur_invoice_lines: TAction;
    mnipur_requests: TMenuItem;
    mnipur_request_lines: TMenuItem;
    mnipur_sep1: TMenuItem;
    mnipur_orders: TMenuItem;
    mnipur_order_lines: TMenuItem;
    mnipur_sep2: TMenuItem;
    mnipur_receipts: TMenuItem;
    mnipur_receipt_lines: TMenuItem;
    mnipur_sep3: TMenuItem;
    mnipur_invoices: TMenuItem;
    mnipur_invoice_lines: TMenuItem;
    actfin_money_accounts: TAction;
    actfin_money_transactions: TAction;
    actfin_money_ledger: TAction;
    mnifin_sep3: TMenuItem;
    mnifin_money_accounts: TMenuItem;
    mnifin_money_transactions: TMenuItem;
    mnifin_money_ledger: TMenuItem;
    actfin_customer_cheques: TAction;
    actfin_own_cheques: TAction;
    actfin_customer_notes: TAction;
    actfin_debit_notes: TAction;
    actfin_cheque_notes: TAction;
    actfin_cheque_note_transactions: TAction;
    actfin_credit_cards: TAction;
    actfin_credit_card_transactions: TAction;
    actfin_pos_terminals: TAction;
    actfin_pos_transactions: TAction;
    mnimenu_finance: TMenuItem;
    mnifin_customer_cheques: TMenuItem;
    mnifin_own_cheques: TMenuItem;
    mnifin_customer_notes: TMenuItem;
    mnifin_debit_notes: TMenuItem;
    mnifin_cheque_notes: TMenuItem;
    mnifin_cheque_note_transactions: TMenuItem;
    mnifin_sep1: TMenuItem;
    mnifin_credit_cards: TMenuItem;
    mnifin_credit_card_transactions: TMenuItem;
    mnifin_sep2: TMenuItem;
    mnifin_pos_terminals: TMenuItem;
    mnifin_pos_transactions: TMenuItem;
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
    procedure actprd_bomExecute(Sender: TObject);
    procedure actprd_labourExecute(Sender: TObject);
    procedure actprd_packet_rawExecute(Sender: TObject);
    procedure actprd_packet_labourExecute(Sender: TObject);
    procedure actacc_account_transactionsExecute(Sender: TObject);
    procedure actfin_company_bank_accountsExecute(Sender: TObject);
    procedure actpur_requestsExecute(Sender: TObject);
    procedure actpur_request_linesExecute(Sender: TObject);
    procedure actpur_ordersExecute(Sender: TObject);
    procedure actpur_order_linesExecute(Sender: TObject);
    procedure actpur_receiptsExecute(Sender: TObject);
    procedure actpur_receipt_linesExecute(Sender: TObject);
    procedure actpur_invoicesExecute(Sender: TObject);
    procedure actpur_invoice_linesExecute(Sender: TObject);
    procedure actfin_money_accountsExecute(Sender: TObject);
    procedure actfin_money_transactionsExecute(Sender: TObject);
    procedure actfin_money_ledgerExecute(Sender: TObject);
    procedure actfin_customer_chequesExecute(Sender: TObject);
    procedure actfin_own_chequesExecute(Sender: TObject);
    procedure actfin_customer_notesExecute(Sender: TObject);
    procedure actfin_debit_notesExecute(Sender: TObject);
    procedure actfin_cheque_notesExecute(Sender: TObject);
    procedure actfin_cheque_note_transactionsExecute(Sender: TObject);
    procedure actfin_credit_cardsExecute(Sender: TObject);
    procedure actfin_credit_card_transactionsExecute(Sender: TObject);
    procedure actfin_pos_terminalsExecute(Sender: TObject);
    procedure actfin_pos_transactionsExecute(Sender: TObject);
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
    procedure actch_bankalarExecute(Sender: TObject);
    procedure actch_banka_subeleriExecute(Sender: TObject);
    procedure actacc_transfer_codeExecute(Sender: TObject);
    procedure actset_prs_tasima_servisleriExecute(Sender: TObject);
    procedure actsys_decimal_placeExecute(Sender: TObject);
    procedure actsys_permission_templateExecute(Sender: TObject);
    procedure actsys_permission_template_rightExecute(Sender: TObject);
    procedure actsys_user_permission_templateExecute(Sender: TObject);
  private
    FIsFormShow: Boolean;
    FF6Pressed: Boolean;
    // ana ekran göstergeleri (çalışma anında oluşturulur)
    FKpis: TArray<TDashboardKpi>;
    FCharts: TArray<TDashboardChart>;
    FKpiLoadedAt: TDateTime;
    FKpiScroll: TScrollBox;
    FBtnKpiRefresh: TButton;
    FLblKpiUpdated: TLabel;
    FKpiTimer: TTimer;
    // sol menü ağacı (sys_menu) + ekran kodları
    FNav: TNavMenuPanel;
    FNavSplitter: TSplitter;
    FBtnNavToggle: TNavToggleButton;
    FActionCodes: TDictionary<string, Integer>;
    procedure BuildNavPanel;
    procedure LoadMenu;
    procedure NavOpenItem(const AItem: TSysMenuItem);
    procedure NavToggleClick(Sender: TObject);
    procedure ActionListExecute(Action: TBasicAction; var Handled: Boolean);
    procedure BuildKpiArea;
    procedure LoadKpis;
    procedure RenderKpis;
    procedure CreateKpiCard(AParent: TWinControl; AIndex: Integer);
    procedure CreateChart(AParent: TWinControl; AIndex: Integer);
    procedure KpiMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint; var Handled: Boolean);
    function KpiAction(const AKey: string): TAction;
    procedure KpiCardClick(Sender: TObject);
    procedure KpiRefreshClick(Sender: TObject);
    procedure KpiTimerTimer(Sender: TObject);
    procedure KpiScrollResize(Sender: TObject);
    procedure LayoutKpiCards;
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
begin
  TfrmAbout.Create(Application).ShowModal;
  RefreshUserPermissions(False);
end;

procedure TfrmDashboard.actacc_exchange_rateExecute(Sender: TObject);
begin
  TfrmAccExchangeRates.Create(Self, TAccExchangeRateService.Create, TAccExchangeRate.Create).Show;
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

procedure TfrmDashboard.actprd_bomExecute(Sender: TObject);
begin
  TfrmPrdBoms.Create(Self, TPrdBomService.Create, TPrdBom.Create).Show;
end;

procedure TfrmDashboard.actprd_labourExecute(Sender: TObject);
begin
  TfrmPrdLabours.Create(Self, TPrdLabourService.Create, TPrdLabour.Create).Show;
end;

procedure TfrmDashboard.actprd_packet_rawExecute(Sender: TObject);
begin
  TfrmPrdPacketRaws.Create(Self, TPrdPacketRawService.Create, TPrdPacketRaw.Create).Show;
end;

procedure TfrmDashboard.actprd_packet_labourExecute(Sender: TObject);
begin
  TfrmPrdPacketLabours.Create(Self, TPrdPacketLabourService.Create, TPrdPacketLabour.Create).Show;
end;

procedure TfrmDashboard.actacc_account_transactionsExecute(Sender: TObject);
begin
  TfrmAccAccountTransactions.Create(Self, TAccAccountTransactionService.Create, TAccAccountTransaction.Create).Show;
end;

procedure TfrmDashboard.actfin_company_bank_accountsExecute(Sender: TObject);
begin
  TfrmFinCompanyBankAccounts.Create(Self, TFinCompanyBankAccountService.Create, TFinCompanyBankAccount.Create).Show;
end;

procedure TfrmDashboard.actpur_requestsExecute(Sender: TObject);
begin
  TfrmPurRequests.Create(Self, TPurRequestService.Create, TPurRequest.Create).Show;
end;

procedure TfrmDashboard.actpur_request_linesExecute(Sender: TObject);
begin
  TfrmPurRequestDetails.Create(Self, TPurRequestDetailService.Create, TPurRequestDetail.Create).Show;
end;

procedure TfrmDashboard.actpur_ordersExecute(Sender: TObject);
begin
  TfrmPurOrders.Create(Self, TPurOrderService.Create, TPurOrder.Create).Show;
end;

procedure TfrmDashboard.actpur_order_linesExecute(Sender: TObject);
begin
  TfrmPurOrderDetails.Create(Self, TPurOrderDetailService.Create, TPurOrderDetail.Create).Show;
end;

procedure TfrmDashboard.actpur_receiptsExecute(Sender: TObject);
begin
  TfrmPurReceipts.Create(Self, TPurReceiptService.Create, TPurReceipt.Create).Show;
end;

procedure TfrmDashboard.actpur_receipt_linesExecute(Sender: TObject);
begin
  TfrmPurReceiptDetails.Create(Self, TPurReceiptDetailService.Create, TPurReceiptDetail.Create).Show;
end;

procedure TfrmDashboard.actpur_invoicesExecute(Sender: TObject);
begin
  TfrmPurInvoices.Create(Self, TPurInvoiceService.Create, TPurInvoice.Create).Show;
end;

procedure TfrmDashboard.actpur_invoice_linesExecute(Sender: TObject);
begin
  TfrmPurInvoiceDetails.Create(Self, TPurInvoiceDetailService.Create, TPurInvoiceDetail.Create).Show;
end;

procedure TfrmDashboard.actfin_money_accountsExecute(Sender: TObject);
begin
  TfrmFinMoneyAccounts.Create(Self, TFinMoneyAccountService.Create, TFinMoneyAccount.Create).Show;
end;

procedure TfrmDashboard.actfin_money_transactionsExecute(Sender: TObject);
begin
  TfrmFinMoneyTransactions.Create(Self, TFinMoneyTransactionService.Create, TFinMoneyTransaction.Create).Show;
end;

procedure TfrmDashboard.actfin_money_ledgerExecute(Sender: TObject);
begin
  TfrmFinMoneyLedgers.Create(Self, TFinMoneyLedgerService.Create, TFinMoneyLedger.Create).Show;
end;

procedure TfrmDashboard.actfin_customer_chequesExecute(Sender: TObject);
var
  LFrm: TfrmFinChequeNotes;
begin
  LFrm := TfrmFinChequeNotes.Create(Self, TFinChequeNoteService.Create, TFinChequeNote.Create);
  LFrm.SetFixedKind(FIN_DOC_CHEQUE, FIN_DIR_RECEIVED);
  LFrm.Show;
end;

procedure TfrmDashboard.actfin_own_chequesExecute(Sender: TObject);
var
  LFrm: TfrmFinChequeNotes;
begin
  LFrm := TfrmFinChequeNotes.Create(Self, TFinChequeNoteService.Create, TFinChequeNote.Create);
  LFrm.SetFixedKind(FIN_DOC_CHEQUE, FIN_DIR_GIVEN);
  LFrm.Show;
end;

procedure TfrmDashboard.actfin_customer_notesExecute(Sender: TObject);
var
  LFrm: TfrmFinChequeNotes;
begin
  LFrm := TfrmFinChequeNotes.Create(Self, TFinChequeNoteService.Create, TFinChequeNote.Create);
  LFrm.SetFixedKind(FIN_DOC_NOTE, FIN_DIR_RECEIVED);
  LFrm.Show;
end;

procedure TfrmDashboard.actfin_debit_notesExecute(Sender: TObject);
var
  LFrm: TfrmFinChequeNotes;
begin
  LFrm := TfrmFinChequeNotes.Create(Self, TFinChequeNoteService.Create, TFinChequeNote.Create);
  LFrm.SetFixedKind(FIN_DOC_NOTE, FIN_DIR_GIVEN);
  LFrm.Show;
end;

procedure TfrmDashboard.actfin_cheque_notesExecute(Sender: TObject);
begin
  TfrmFinChequeNotes.Create(Self, TFinChequeNoteService.Create, TFinChequeNote.Create).Show;
end;

procedure TfrmDashboard.actfin_cheque_note_transactionsExecute(Sender: TObject);
begin
  TfrmFinChequeNoteTransactions.Create(Self, TFinChequeNoteTransactionService.Create, TFinChequeNoteTransaction.Create).Show;
end;

procedure TfrmDashboard.actfin_credit_cardsExecute(Sender: TObject);
begin
  TfrmFinCreditCards.Create(Self, TFinCreditCardService.Create, TFinCreditCard.Create).Show;
end;

procedure TfrmDashboard.actfin_credit_card_transactionsExecute(Sender: TObject);
begin
  TfrmFinCreditCardTransactions.Create(Self, TFinCreditCardTransactionService.Create, TFinCreditCardTransaction.Create).Show;
end;

procedure TfrmDashboard.actfin_pos_terminalsExecute(Sender: TObject);
begin
  TfrmFinPosTerminals.Create(Self, TFinPosTerminalService.Create, TFinPosTerminal.Create).Show;
end;

procedure TfrmDashboard.actfin_pos_transactionsExecute(Sender: TObject);
begin
  TfrmFinPosTransactions.Create(Self, TFinPosTransactionService.Create, TFinPosTransaction.Create).Show;
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
  FActionCodes.Free;
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
  // menü adları DB'den etkin dilde
  LoadMenu;

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


  if Assigned(mnimenu_production) then
    mnimenu_production.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuProduction, 'Production');
  if Assigned(actprd_bom) then
    actprd_bom.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.TitlePlural, 'BoMs');
  if Assigned(actprd_labour) then
    actprd_labour.Caption := TLocalizationManager.Translate(TLangKeys.TPrdLabour.TitlePlural, 'Labours / Costs');
  if Assigned(actprd_packet_raw) then
    actprd_packet_raw.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRaw.TitlePlural, 'Raw Material Packets');
  if Assigned(actprd_packet_labour) then
    actprd_packet_labour.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketLabour.TitlePlural, 'Labour Packets');
  if Assigned(actacc_account_transactions) then
    actacc_account_transactions.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccountTransaction.TitlePlural, 'Account Transactions');
  if Assigned(actfin_company_bank_accounts) then
    actfin_company_bank_accounts.Caption := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.TitlePlural, 'Company Bank Accounts');
  if Assigned(actpur_requests) then
    actpur_requests.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.TitlePlural, 'Purchase Requests');
  if Assigned(actpur_request_lines) then
    actpur_request_lines.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.TitlePlural, 'Request Lines');
  if Assigned(actpur_orders) then
    actpur_orders.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.TitlePlural, 'Purchase Orders');
  if Assigned(actpur_order_lines) then
    actpur_order_lines.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.TitlePlural, 'Order Lines');
  if Assigned(actpur_receipts) then
    actpur_receipts.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.TitlePlural, 'Goods Receipts');
  if Assigned(actpur_receipt_lines) then
    actpur_receipt_lines.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.TitlePlural, 'Receipt Lines');
  if Assigned(actpur_invoices) then
    actpur_invoices.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.TitlePlural, 'Purchase Invoices');
  if Assigned(actpur_invoice_lines) then
    actpur_invoice_lines.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.TitlePlural, 'Invoice Lines');
  if Assigned(actfin_money_accounts) then
    actfin_money_accounts.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.TitlePlural, 'Cash / Bank Accounts');
  if Assigned(actfin_money_transactions) then
    actfin_money_transactions.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.TitlePlural, 'Receipts / Payments / Transfers');
  if Assigned(actfin_money_ledger) then
    actfin_money_ledger.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyLedger.TitlePlural, 'Cash / Bank Statement');
  if Assigned(mnimenu_finance) then
    mnimenu_finance.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuFinance, 'Finance');
  if Assigned(actfin_customer_cheques) then
    actfin_customer_cheques.Caption := TFinLookup.ChequeNoteListTitle(FIN_DOC_CHEQUE, FIN_DIR_RECEIVED);
  if Assigned(actfin_own_cheques) then
    actfin_own_cheques.Caption := TFinLookup.ChequeNoteListTitle(FIN_DOC_CHEQUE, FIN_DIR_GIVEN);
  if Assigned(actfin_customer_notes) then
    actfin_customer_notes.Caption := TFinLookup.ChequeNoteListTitle(FIN_DOC_NOTE, FIN_DIR_RECEIVED);
  if Assigned(actfin_debit_notes) then
    actfin_debit_notes.Caption := TFinLookup.ChequeNoteListTitle(FIN_DOC_NOTE, FIN_DIR_GIVEN);
  if Assigned(actfin_cheque_notes) then
    actfin_cheque_notes.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.TitlePlural, 'Cheques / Notes');
  if Assigned(actfin_cheque_note_transactions) then
    actfin_cheque_note_transactions.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.TitlePlural, 'Cheque / Note Transactions');
  if Assigned(actfin_credit_cards) then
    actfin_credit_cards.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.TitlePlural, 'Company Credit Cards');
  if Assigned(actfin_credit_card_transactions) then
    actfin_credit_card_transactions.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.TitlePlural, 'Credit Card Transactions');
  if Assigned(actfin_pos_terminals) then
    actfin_pos_terminals.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.TitlePlural, 'POS Terminals');
  if Assigned(actfin_pos_transactions) then
    actfin_pos_transactions.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.TitlePlural, 'POS Collections');

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

  if Assigned(actprs_personeller) then
    actprs_personeller.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.TitlePlural, 'Employees');
  if Assigned(FNav) then
    FNav.ApplyTexts(
      TLocalizationManager.Translate(TLangKeys.TDashboard.NavSearchHint, 'Search screen name or code (Ctrl+K)'),
      TLocalizationManager.Translate(TLangKeys.TDashboard.NavNoResult, 'No matching screen'));
  if Assigned(FBtnNavToggle) then
    FBtnNavToggle.Hint := TLocalizationManager.Translate(TLangKeys.TDashboard.NavToggleHint, 'Show / hide menu');

  if Assigned(FKpiScroll) then
    RenderKpis;
end;

procedure TfrmDashboard.FormCreate(Sender: TObject);
begin
  inherited;

  btnClose.Visible := True;
  pnlBottom.Visible := False;
  stbBase.Visible := True;
  pnlBottom.Visible := True;

  FActionCodes := TDictionary<string, Integer>.Create;
  actlstMain.OnExecute := ActionListExecute;
  BuildNavPanel;
end;

procedure TfrmDashboard.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // Ctrl+K / Ctrl+F: menüde ara
  if (Shift = [ssCtrl]) and ((Key = Ord('K')) or (Key = Ord('F'))) and Assigned(FNav) then
  begin
    Key := 0;
    if not FNav.Visible then
      NavToggleClick(nil);
    FNav.FocusSearch;
    Exit;
  end;
  // F6 başka bir formda basılıp (liste/giriş formu KeyDown'da kapanır) burada bırakılırsa uygulama kapatma sorulmasın
  if Key = VK_F6 then
    FF6Pressed := True;
end;

procedure TfrmDashboard.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_ESCAPE) then
  begin
    // menüdeyken Esc aramayı temizler, uygulama kapatma sorulmaz
    if Assigned(FNav) and FNav.HandleEscape then
    begin
      Key := #0;
      Exit;
    end;
    inherited;
  end;
end;

procedure TfrmDashboard.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_F6) and FF6Pressed then
  begin
    FF6Pressed := False;
    inherited;
  end;
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

// Menü / buton erişimi: okuma hakkı olmayan ekranın action'ı pasif (menü öğesi, ağaç, kart birlikte).
// Action -> yetki eşlemesi sys_menu'dan gelir (LoadMenu); ekranın kendisi (TfrmGrid) ve servisler ayrıca kontrol eder.
procedure TfrmDashboard.ApplyActionPermissions;
begin
  if not TAppContext.IsInitialized then
    Exit;
  LoadMenu;
end;

// sys_menu: ağaç + action yetkileri + ekran kodları. sys_menu'da olmayan action'lara (Hakkında, Güncelle ...) dokunulmaz.
procedure TfrmDashboard.LoadMenu;
var
  LSvc: TSysMenuService;
  LItems: TArray<TSysMenuItem>;
  LItem: TSysMenuItem;
  LComp: TComponent;
begin
  if not TAppContext.IsInitialized or not Assigned(TAppContext.Instance.CurrentUser) then
    Exit;

  try
    LSvc := TSysMenuService.Create;
    try
      LItems := LSvc.GetMenu;
    finally
      LSvc.Free;
    end;
  except
    on E: Exception do
    begin
      GLogger.ErrorFmt('Menü okunamadı: %s', [E.Message]);
      Exit;
    end;
  end;

  FActionCodes.Clear;
  for LItem in LItems do
  begin
    if LItem.IsFolder then
      Continue;
    LComp := FindComponent(LItem.ActionName);
    if not (LComp is TAction) then
    begin
      GLogger.ErrorFmt('Menü ekranının action''ı yok: %d %s', [LItem.MenuCode, LItem.ActionName]);
      Continue;
    end;
    FActionCodes.AddOrSetValue(LItem.ActionName, LItem.MenuCode);
    // ResetSession butonları doğrudan pasif yapabiliyor; değer değişmezse action istemcilere yaymaz
    TAction(LComp).Enabled := not LItem.Allowed;
    TAction(LComp).Enabled := LItem.Allowed;
  end;

  if Assigned(FNav) then
    FNav.SetItems(LItems);
end;

procedure TfrmDashboard.SetSession;
//var
//  LRights: TSysErisimHakki;
//  n1: Integer;
begin
  ResetSession(pnlMain);
  ApplyActionPermissions;
  // ana ekran göstergeleri: yalnız okuma yetkisi olan modüller (servis filtreler)
  LoadKpis;
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

{ ---------------------------------------------------------------- Sol menü / ekran kodları }

procedure TfrmDashboard.BuildNavPanel;
begin
  if Assigned(FNav) then
    Exit;

  FNav := TNavMenuPanel.Create(Self);
  FNav.Parent := Self;
  FNav.Align := alLeft;
  FNav.Left := 0;
  FNav.ParentBackground := False;
  FNav.Color := clWindow;
  FNav.CreateControls;
  FNav.OnOpenItem := NavOpenItem;

  FNavSplitter := TSplitter.Create(Self);
  FNavSplitter.Parent := Self;
  FNavSplitter.Align := alLeft;
  FNavSplitter.Left := FNav.Left + FNav.Width + 1;
  FNavSplitter.Width := 4;
  FNavSplitter.MinSize := 180;
  FNavSplitter.ResizeStyle := rsUpdate;

  FBtnNavToggle := TNavToggleButton.Create(Self);
  FBtnNavToggle.Parent := pnlToolbar;
  FBtnNavToggle.Align := alLeft;
  FBtnNavToggle.Left := 0;
  FBtnNavToggle.AlignWithMargins := True;
  FBtnNavToggle.Margins.SetBounds(6, 5, 0, 5);
  FBtnNavToggle.OnClick := NavToggleClick;
end;

procedure TfrmDashboard.NavToggleClick(Sender: TObject);
begin
  FNav.Visible := not FNav.Visible;
  FNavSplitter.Visible := FNav.Visible;
  if FNav.Visible then
    FNavSplitter.Left := FNav.Left + FNav.Width + 1;
end;

procedure TfrmDashboard.NavOpenItem(const AItem: TSysMenuItem);
var
  LComp: TComponent;
begin
  LComp := FindComponent(AItem.ActionName);
  if (LComp is TAction) and TAction(LComp).Enabled then
    TAction(LComp).Execute;
end;

// Her dashboard action'ı (ana menü, sol ağaç, gösterge kartı) buradan geçer: sys_menu'daki ekranlar
// kodlarıyla açılır, böylece açılan formun başlığına ekran kodu eklenir.
procedure TfrmDashboard.ActionListExecute(Action: TBasicAction; var Handled: Boolean);
var
  LCode: Integer;
begin
  if not Assigned(FActionCodes) or not FActionCodes.TryGetValue(Action.Name, LCode) or not Assigned(Action.OnExecute) then
    Exit;
  Handled := True;
  TScreenCodes.RunWithCode(LCode,
    procedure
    begin
      Action.OnExecute(Action);
    end);
end;

{ ---------------------------------------------------------------- Ana ekran göstergeleri }

const
  KPI_CARD_WIDTH  = 260;
  KPI_CARD_HEIGHT = 176;
  KPI_CHART_HEIGHT = 270;
  KPI_SECTION_COUNT = 6;   // finans, satın alma, satış, stok, cari, genel
  KPI_REFRESH_MS = 5 * 60 * 1000;

function KpiSection(const AKey: string): Integer;
begin
  if MatchStr(AKey, [KPI_FX_RATES, KPI_CASH_BALANCE, KPI_BANK_BALANCE, KPI_MONEY_TODAY, KPI_CHEQUES_RECEIVABLE,
    KPI_CHEQUES_PAYABLE, KPI_POS_MONTH, KPI_CARD_DEBT]) then
    Result := 0
  else if MatchStr(AKey, [KPI_PUR_REQUESTS, KPI_PUR_ORDERS_OPEN, KPI_PUR_ORDERS_MONTH, KPI_PUR_RECEIPTS_MONTH, KPI_PUR_INVOICES_MONTH]) then
    Result := 1
  else if MatchStr(AKey, [KPI_SLS_ORDERS_MONTH, KPI_SLS_OFFERS_MONTH]) then
    Result := 2
  else if MatchStr(AKey, [KPI_STOCK_CRITICAL, KPI_STOCK_TX_TODAY, KPI_STOCK_CARDS]) then
    Result := 3
  else if MatchStr(AKey, [KPI_ACC_RECEIVABLE, KPI_ACC_PAYABLE, KPI_ACCOUNTS]) then
    Result := 4
  else
    Result := 5;
end;

function KpiSectionTitle(ASection: Integer): string;
begin
  case ASection of
    0: Result := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiSecFinance, 'Finance');
    1: Result := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiSecPurchasing, 'Purchasing');
    2: Result := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiSecSales, 'Sales');
    3: Result := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiSecStock, 'Stock');
    4: Result := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiSecAccounts, 'Accounts');
  else
    Result := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiSecGeneral, 'General');
  end;
end;

function KpiTitle(const AKey: string): string;
type
  TTitle = record Key, LangKey, Default: string; end;
const
  TITLES: array[0..22] of TTitle = (
    (Key: KPI_FX_RATES; LangKey: TLangKeys.TDashboard.KpiFxRates; Default: 'Exchange Rates'),
    (Key: KPI_CASH_BALANCE; LangKey: TLangKeys.TDashboard.KpiCashBalance; Default: 'Cash Balance'),
    (Key: KPI_BANK_BALANCE; LangKey: TLangKeys.TDashboard.KpiBankBalance; Default: 'Bank Balance'),
    (Key: KPI_MONEY_TODAY; LangKey: TLangKeys.TDashboard.KpiMoneyToday; Default: 'Today''s Receipts'),
    (Key: KPI_CHEQUES_RECEIVABLE; LangKey: TLangKeys.TDashboard.KpiChequesReceivable; Default: 'Customer Cheques / Notes'),
    (Key: KPI_CHEQUES_PAYABLE; LangKey: TLangKeys.TDashboard.KpiChequesPayable; Default: 'Own Cheques / Notes Due'),
    (Key: KPI_POS_MONTH; LangKey: TLangKeys.TDashboard.KpiPosMonth; Default: 'POS Collections This Month'),
    (Key: KPI_CARD_DEBT; LangKey: TLangKeys.TDashboard.KpiCardDebt; Default: 'Credit Card Debt'),
    (Key: KPI_PUR_REQUESTS; LangKey: TLangKeys.TDashboard.KpiPurRequests; Default: 'Purchase Requests'),
    (Key: KPI_PUR_ORDERS_OPEN; LangKey: TLangKeys.TDashboard.KpiPurOrdersOpen; Default: 'Open Purchase Orders'),
    (Key: KPI_PUR_ORDERS_MONTH; LangKey: TLangKeys.TDashboard.KpiPurOrdersMonth; Default: 'Purchase Orders This Month'),
    (Key: KPI_PUR_RECEIPTS_MONTH; LangKey: TLangKeys.TDashboard.KpiPurReceiptsMonth; Default: 'Goods Receipts This Month'),
    (Key: KPI_PUR_INVOICES_MONTH; LangKey: TLangKeys.TDashboard.KpiPurInvoicesMonth; Default: 'Purchase Invoices This Month'),
    (Key: KPI_SLS_ORDERS_MONTH; LangKey: TLangKeys.TDashboard.KpiSlsOrdersMonth; Default: 'Sales Orders This Month'),
    (Key: KPI_SLS_OFFERS_MONTH; LangKey: TLangKeys.TDashboard.KpiSlsOffersMonth; Default: 'Sales Offers This Month'),
    (Key: KPI_STOCK_CRITICAL; LangKey: TLangKeys.TDashboard.KpiStockCritical; Default: 'Below Minimum Stock'),
    (Key: KPI_STOCK_TX_TODAY; LangKey: TLangKeys.TDashboard.KpiStockTx; Default: 'Stock Movements Today'),
    (Key: KPI_STOCK_CARDS; LangKey: TLangKeys.TDashboard.KpiStockCards; Default: 'Stock Cards'),
    (Key: KPI_ACC_RECEIVABLE; LangKey: TLangKeys.TDashboard.KpiAccReceivable; Default: 'Receivables'),
    (Key: KPI_ACC_PAYABLE; LangKey: TLangKeys.TDashboard.KpiAccPayable; Default: 'Payables'),
    (Key: KPI_ACCOUNTS; LangKey: TLangKeys.TDashboard.KpiAccounts; Default: 'Active Accounts'),
    (Key: KPI_EMPLOYEES; LangKey: TLangKeys.TDashboard.KpiEmployees; Default: 'Active Employees'),
    (Key: KPI_USERS; LangKey: TLangKeys.TDashboard.KpiUsers; Default: 'Active Users'));
var
  LItem: TTitle;
begin
  for LItem in TITLES do
    if LItem.Key = AKey then
      Exit(TLocalizationManager.Translate(LItem.LangKey, LItem.Default));
  Result := AKey;
end;

function KpiFmt(const ALangKey, ADefault: string; const AArgs: array of const): string;
begin
  Result := Format(TLocalizationManager.Translate(ALangKey, ADefault), AArgs);
end;

// Para birimi bazında tutarlar: her biri ayrı satır (en çok AMax)
function KpiAmounts(const AAmounts: TArray<TDashboardAmount>; const AFormat: string; AMax: Integer; const ASeparator: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Min(Length(AAmounts), AMax) - 1 do
  begin
    if Result <> '' then
      Result := Result + ASeparator;
    Result := Result + FormatFloat(AFormat, AAmounts[I].Amount) + ' ' + AAmounts[I].Currency;
  end;
end;

procedure KpiTexts(const K: TDashboardKpi; out AValue, ADetail: string);
const
  MONEY = '#,##0.00';
  ZERO = '0,00';
var
  LAmounts: string;
begin
  LAmounts := KpiAmounts(K.Amounts, MONEY, 3, sLineBreak);
  if LAmounts = '' then
    LAmounts := ZERO;
  AValue := '';
  ADetail := '';
  if K.Key = KPI_FX_RATES then
  begin
    if K.Count = 0 then
      AValue := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiNoRecord, 'No records')
    else
    begin
      // kurda para birimi başta: "USD 41,2904"
      AValue := '';
      for var I := 0 to Min(Length(K.Amounts), 3) - 1 do
      begin
        if AValue <> '' then
          AValue := AValue + sLineBreak;
        AValue := AValue + K.Amounts[I].Currency + '  ' + FormatFloat('#,##0.0000', K.Amounts[I].Amount);
      end;
      if K.Level = dlWarning then
        ADetail := KpiFmt(TLangKeys.TDashboard.KpiFmtRateOld, 'Rates not updated today (%s)', [DateToStr(K.RefDate)])
      else
        ADetail := KpiFmt(TLangKeys.TDashboard.KpiFmtRateDate, 'Rate date: %s', [DateToStr(K.RefDate)]);
    end;
  end
  else if MatchStr(K.Key, [KPI_CASH_BALANCE, KPI_BANK_BALANCE, KPI_ACC_RECEIVABLE, KPI_ACC_PAYABLE]) then
  begin
    AValue := LAmounts;
    ADetail := KpiFmt(TLangKeys.TDashboard.KpiFmtAccounts, '%d account(s)', [K.Count]);
  end
  else if K.Key = KPI_MONEY_TODAY then
  begin
    AValue := LAmounts;
    ADetail := KpiFmt(TLangKeys.TDashboard.KpiFmtMoneyToday, '%d transaction(s), %d collection(s)', [K.Count, K.Count2]);
  end
  else if MatchStr(K.Key, [KPI_CHEQUES_RECEIVABLE, KPI_CHEQUES_PAYABLE]) then
  begin
    AValue := LAmounts;
    ADetail := KpiFmt(TLangKeys.TDashboard.KpiFmtDocsDue, '%d document(s), %d due within 7 days', [K.Count, K.Count2]);
  end
  else if K.Key = KPI_POS_MONTH then
  begin
    AValue := LAmounts;
    ADetail := KpiFmt(TLangKeys.TDashboard.KpiFmtMonthTx, '%d transaction(s) this month', [K.Count]);
  end
  else if K.Key = KPI_CARD_DEBT then
  begin
    AValue := LAmounts;
    ADetail := KpiFmt(TLangKeys.TDashboard.KpiFmtCards, '%d card(s), %d near the limit', [K.Count, K.Count2]);
  end
  else if K.Key = KPI_PUR_REQUESTS then
  begin
    AValue := KpiFmt(TLangKeys.TDashboard.KpiFmtDrafts, '%d draft', [K.Count]);
    ADetail := KpiFmt(TLangKeys.TDashboard.KpiFmtRequests, '%d approved, waiting for an order', [K.Count2]);
  end
  else if K.Key = KPI_PUR_ORDERS_OPEN then
  begin
    AValue := LAmounts;
    ADetail := KpiFmt(TLangKeys.TDashboard.KpiFmtOrdersOpen, '%d order(s), %d late', [K.Count, K.Count2]);
  end
  else if K.Key = KPI_PUR_INVOICES_MONTH then
  begin
    AValue := LAmounts;
    ADetail := KpiFmt(TLangKeys.TDashboard.KpiFmtInvoicesDue, '%d invoice(s), %d due within 7 days', [K.Count, K.Count2]);
  end
  else if MatchStr(K.Key, [KPI_PUR_ORDERS_MONTH, KPI_SLS_ORDERS_MONTH, KPI_SLS_OFFERS_MONTH]) then
  begin
    AValue := KpiFmt(TLangKeys.TDashboard.KpiFmtCount, '%d', [K.Count]);
    ADetail := KpiAmounts(K.Amounts, MONEY, 2, ' / ');
  end
  else if K.Key = KPI_PUR_RECEIPTS_MONTH then
  begin
    AValue := KpiFmt(TLangKeys.TDashboard.KpiFmtCount, '%d', [K.Count]);
    ADetail := KpiFmt(TLangKeys.TDashboard.KpiFmtToday, 'Today: %d', [K.Count2]);
  end
  else if K.Key = KPI_STOCK_CRITICAL then
  begin
    AValue := KpiFmt(TLangKeys.TDashboard.KpiFmtCount, '%d', [K.Count]);
    ADetail := KpiFmt(TLangKeys.TDashboard.KpiFmtNegative, '%d item(s) with negative stock', [K.Count2]);
  end
  else if K.Key = KPI_STOCK_TX_TODAY then
  begin
    AValue := KpiFmt(TLangKeys.TDashboard.KpiFmtCount, '%d', [K.Count]);
    ADetail := KpiFmt(TLangKeys.TDashboard.KpiFmtThisMonth, 'This month: %d', [K.Count2]);
  end
  else if K.Key = KPI_STOCK_CARDS then
  begin
    AValue := KpiFmt(TLangKeys.TDashboard.KpiFmtCount, '%d', [K.Count]);
    ADetail := KpiFmt(TLangKeys.TDashboard.KpiFmtSellable, '%d sellable', [K.Count2]);
  end
  else if K.Key = KPI_ACCOUNTS then
  begin
    AValue := KpiFmt(TLangKeys.TDashboard.KpiFmtCount, '%d', [K.Count]);
    ADetail := KpiFmt(TLangKeys.TDashboard.KpiFmtPassive, '%d passive', [K.Count2]);
  end
  else
  begin
    AValue := KpiFmt(TLangKeys.TDashboard.KpiFmtCount, '%d', [K.Count]);
    ADetail := KpiFmt(TLangKeys.TDashboard.KpiFmtTotal, 'Total: %d', [K.Count2]);
  end;
end;

function KpiLevelColor(ALevel: TDashboardLevel): TColor;
begin
  case ALevel of
    dlInfo:    Result := RGB(37, 99, 235);   // mavi
    dlWarning: Result := RGB(217, 119, 6);   // turuncu
    dlDanger:  Result := RGB(220, 38, 38);   // kırmızı
  else
    Result := RGB(22, 163, 74);              // yeşil
  end;
end;

function KpiLevelBadge(ALevel: TDashboardLevel): string;
begin
  case ALevel of
    dlInfo:    Result := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiBadgeInfo, 'Info');
    dlWarning: Result := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiBadgeWarning, 'Attention');
    dlDanger:  Result := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiBadgeDanger, 'Critical');
  else
    Result := '';
  end;
end;

// Bölüm rengi (ikon, küçük grafik, oran çubuğu)
function KpiSectionColor(ASection: Integer): TColor;
begin
  case ASection of
    0: Result := RGB(16, 163, 127);   // finans
    1: Result := RGB(234, 128, 40);   // satın alma
    2: Result := RGB(124, 92, 230);   // satış
    3: Result := RGB(37, 128, 230);   // stok
    4: Result := RGB(219, 68, 110);   // cari
  else
    Result := RGB(96, 112, 135);      // genel
  end;
end;

function KpiSectionIcon(ASection: Integer): string;
begin
  case ASection of
    0: Result := ICON_BANK;
    1: Result := ICON_CART;
    2: Result := ICON_BAG;
    3: Result := ICON_BOX;
    4: Result := ICON_PEOPLE;
  else
    Result := ICON_HOME;
  end;
end;

function KpiIcon(const AKey: string): string;
begin
  if AKey = KPI_FX_RATES then Result := ICON_EXCHANGE
  else if AKey = KPI_CASH_BALANCE then Result := ICON_CASH
  else if AKey = KPI_BANK_BALANCE then Result := ICON_BANK
  else if AKey = KPI_MONEY_TODAY then Result := ICON_INOUT
  else if AKey = KPI_CHEQUES_RECEIVABLE then Result := ICON_DOCUMENT
  else if AKey = KPI_CHEQUES_PAYABLE then Result := ICON_PAGE
  else if AKey = KPI_POS_MONTH then Result := ICON_TERMINAL
  else if AKey = KPI_CARD_DEBT then Result := ICON_CARD
  else if AKey = KPI_PUR_REQUESTS then Result := ICON_LIST
  else if AKey = KPI_PUR_ORDERS_OPEN then Result := ICON_CART
  else if AKey = KPI_PUR_ORDERS_MONTH then Result := ICON_CALENDAR
  else if AKey = KPI_PUR_RECEIPTS_MONTH then Result := ICON_BOX
  else if AKey = KPI_PUR_INVOICES_MONTH then Result := ICON_REPORT
  else if AKey = KPI_SLS_ORDERS_MONTH then Result := ICON_BAG
  else if AKey = KPI_SLS_OFFERS_MONTH then Result := ICON_TAG
  else if AKey = KPI_STOCK_CRITICAL then Result := ICON_WARNING
  else if AKey = KPI_STOCK_TX_TODAY then Result := ICON_CYCLE
  else if AKey = KPI_STOCK_CARDS then Result := ICON_LIBRARY
  else if AKey = KPI_ACC_RECEIVABLE then Result := ICON_TREND_UP
  else if AKey = KPI_ACC_PAYABLE then Result := ICON_PIE
  else if AKey = KPI_ACCOUNTS then Result := ICON_PEOPLE
  else if AKey = KPI_EMPLOYEES then Result := ICON_PERSON
  else if AKey = KPI_USERS then Result := ICON_KEY
  else Result := ICON_CHART;
end;

// Kartın açacağı ekran (action); okuma yetkisi yoksa action zaten pasif
function TfrmDashboard.KpiAction(const AKey: string): TAction;
var
  LName: string;
begin
  if MatchStr(AKey, [KPI_FX_RATES, CHART_FX_TREND]) then LName := 'actacc_exchange_rate'
  else if MatchStr(AKey, [KPI_CASH_BALANCE, KPI_BANK_BALANCE]) then LName := 'actfin_money_accounts'
  else if MatchStr(AKey, [KPI_MONEY_TODAY, CHART_MONEY_FLOW]) then LName := 'actfin_money_transactions'
  else if MatchStr(AKey, [KPI_CHEQUES_RECEIVABLE, KPI_CHEQUES_PAYABLE, CHART_CHEQUE_DUE]) then LName := 'actfin_cheque_notes'
  else if AKey = KPI_POS_MONTH then LName := 'actfin_pos_transactions'
  else if AKey = KPI_CARD_DEBT then LName := 'actfin_credit_cards'
  else if AKey = KPI_PUR_REQUESTS then LName := 'actpur_requests'
  else if MatchStr(AKey, [KPI_PUR_ORDERS_OPEN, KPI_PUR_ORDERS_MONTH]) then LName := 'actpur_orders'
  else if AKey = KPI_PUR_RECEIPTS_MONTH then LName := 'actpur_receipts'
  else if AKey = KPI_PUR_INVOICES_MONTH then LName := 'actpur_invoices'
  else if AKey = KPI_STOCK_CRITICAL then LName := 'actstk_stok_karti_ozetleri'
  else if MatchStr(AKey, [KPI_STOCK_TX_TODAY, CHART_STOCK_FLOW]) then LName := 'actstk_hareketler'
  else if AKey = KPI_STOCK_CARDS then LName := 'actstk_stok_kartlari'
  else if MatchStr(AKey, [KPI_ACC_RECEIVABLE, KPI_ACC_PAYABLE]) then LName := 'actacc_account_transactions'
  else if AKey = KPI_ACCOUNTS then LName := 'actch_hesap_karti'
  else if AKey = KPI_EMPLOYEES then LName := 'actprs_personeller'
  else if AKey = KPI_USERS then LName := 'actsys_user'
  else LName := '';  // satış: modül henüz taşınmadı
  Result := nil;
  if LName <> '' then
    if FindComponent(LName) is TAction then
      Result := TAction(FindComponent(LName));
end;

procedure TfrmDashboard.BuildKpiArea;
begin
  if Assigned(FKpiScroll) then
    Exit;

  FKpiScroll := TScrollBox.Create(Self);
  FKpiScroll.Parent := pnlMain;
  FKpiScroll.Align := alClient;
  FKpiScroll.BorderStyle := bsNone;
  FKpiScroll.ParentColor := False;
  FKpiScroll.ParentBackground := False;
  FKpiScroll.Color := DASH_BACKGROUND;
  // VCL teması zemin rengini ezmesin (kartlar bu renk üzerine çizilir)
  FKpiScroll.StyleElements := FKpiScroll.StyleElements - [seClient];
  FKpiScroll.DoubleBuffered := True;
  FKpiScroll.VertScrollBar.Tracking := True;
  FKpiScroll.HorzScrollBar.Visible := False;
  FKpiScroll.OnResize := KpiScrollResize;
  // kartlar odak almaz: tekerlek mesajı forma gelir
  if not Assigned(OnMouseWheel) then
    OnMouseWheel := KpiMouseWheel;

  FBtnKpiRefresh := TButton.Create(Self);
  FBtnKpiRefresh.Parent := pnlToolbar;
  FBtnKpiRefresh.Align := alRight;
  FBtnKpiRefresh.AlignWithMargins := True;
  FBtnKpiRefresh.Margins.SetBounds(4, 6, 8, 6);
  FBtnKpiRefresh.Width := 100;
  FBtnKpiRefresh.OnClick := KpiRefreshClick;

  FLblKpiUpdated := TLabel.Create(Self);
  FLblKpiUpdated.Parent := pnlToolbar;
  FLblKpiUpdated.Align := alRight;
  FLblKpiUpdated.AlignWithMargins := True;
  FLblKpiUpdated.Margins.SetBounds(4, 2, 8, 2);
  FLblKpiUpdated.Layout := tlCenter;
  FLblKpiUpdated.Left := FBtnKpiRefresh.Left - 10;

  FKpiTimer := TTimer.Create(Self);
  FKpiTimer.Enabled := False;
  FKpiTimer.Interval := KPI_REFRESH_MS;
  FKpiTimer.OnTimer := KpiTimerTimer;
end;

procedure TfrmDashboard.LoadKpis;
var
  LSvc: TSysDashboardService;
begin
  if not TAppContext.IsInitialized or not Assigned(TAppContext.Instance.CurrentUser) then
    Exit;

  Screen.Cursor := crHourGlass;
  try
    try
      LSvc := TSysDashboardService.Create;
      try
        FKpis := LSvc.GetKpis;
        FCharts := LSvc.GetCharts;
      finally
        LSvc.Free;
      end;
      FKpiLoadedAt := Now;
    except
      on E: Exception do
      begin
        FKpis := [];
        FCharts := [];
        GLogger.ErrorFmt('Ana ekran göstergeleri yüklenemedi: %s', [E.Message]);
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  RenderKpis;
  if Assigned(FKpiTimer) then
    FKpiTimer.Enabled := True;
end;

// Kart genişliği pencereye göre: satırdaki kart sayısı = sığan en az KPI_CARD_WIDTH genişlikli kart;
// grafikler iki kart genişliğinde (tek kart sığıyorsa tam satır)
procedure TfrmDashboard.LayoutKpiCards;
var
  I, J, LPerRow, LWidth, LChartWidth, LAvail: Integer;
  LFlow: TFlowPanel;
begin
  if not Assigned(FKpiScroll) then
    Exit;
  LAvail := FKpiScroll.ClientWidth - 20 - GetSystemMetrics(SM_CXVSCROLL);
  LPerRow := Max(1, LAvail div (KPI_CARD_WIDTH + 12));
  LWidth := Max(KPI_CARD_WIDTH, LAvail div LPerRow - 12);
  // grafik iki kart genişliğinde; satırdaki grafik sayısı = kart sayısı / 2 (tek kalan boşluk grafiklere dağılır)
  LChartWidth := Max(KPI_CARD_WIDTH * 2 + 12, LAvail div Max(1, LPerRow div 2) - 12);
  for I := 0 to FKpiScroll.ControlCount - 1 do
    if FKpiScroll.Controls[I] is TFlowPanel then
    begin
      LFlow := TFlowPanel(FKpiScroll.Controls[I]);
      LFlow.DisableAlign;
      try
        for J := 0 to LFlow.ControlCount - 1 do
          if (LFlow.Controls[J] is TDashChart) and (LPerRow >= 2) then
            LFlow.Controls[J].Width := LChartWidth
          else
            LFlow.Controls[J].Width := LWidth;
      finally
        LFlow.EnableAlign;
      end;
    end;
end;

procedure TfrmDashboard.KpiScrollResize(Sender: TObject);
begin
  LayoutKpiCards;
end;

procedure TfrmDashboard.KpiMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint; var Handled: Boolean);
begin
  if not Assigned(FKpiScroll) or not FKpiScroll.Visible then
    Exit;
  if not PtInRect(FKpiScroll.ClientRect, FKpiScroll.ScreenToClient(Mouse.CursorPos)) then
    Exit;
  FKpiScroll.VertScrollBar.Position := FKpiScroll.VertScrollBar.Position - WheelDelta div 2;
  Handled := True;
end;

procedure TfrmDashboard.KpiRefreshClick(Sender: TObject);
begin
  LoadKpis;
end;

procedure TfrmDashboard.KpiTimerTimer(Sender: TObject);
begin
  // modal pencere / başka iş varken arka planda yenileme yapılmaz
  if Application.Active and (Screen.ActiveForm = Self) then
    LoadKpis;
end;

procedure TfrmDashboard.KpiCardClick(Sender: TObject);
var
  LIndex: Integer;
  LKey: string;
  LAction: TAction;
begin
  LIndex := (Sender as TControl).Tag;
  if Sender is TDashChart then
  begin
    if (LIndex < 0) or (LIndex > High(FCharts)) then
      Exit;
    LKey := FCharts[LIndex].Key;
  end
  else
  begin
    if (LIndex < 0) or (LIndex > High(FKpis)) then
      Exit;
    LKey := FKpis[LIndex].Key;
  end;
  LAction := KpiAction(LKey);
  if Assigned(LAction) and LAction.Enabled then
    LAction.Execute;
end;

procedure TfrmDashboard.CreateKpiCard(AParent: TWinControl; AIndex: Integer);
var
  K: TDashboardKpi;
  LTile: TDashTile;
  LData: TDashTileData;
  LAction: TAction;
begin
  K := FKpis[AIndex];
  KpiTexts(K, LData.ValueText, LData.Detail);
  LData.Title := KpiTitle(K.Key);
  LData.Icon := KpiIcon(K.Key);
  LData.Accent := KpiSectionColor(KpiSection(K.Key));
  LData.Badge := KpiLevelBadge(K.Level);
  LData.BadgeColor := KpiLevelColor(K.Level);
  if K.Level = dlDanger then
    LData.ValueColor := KpiLevelColor(dlDanger)
  else
    LData.ValueColor := RGB(31, 42, 55);
  LData.Ratio := K.Ratio;
  if K.Ratio >= 0 then
    LData.RatioText := Format(TLocalizationManager.Translate(TLangKeys.TDashboard.KpiFmtPercent, '%d%%'), [Round(K.Ratio * 100)])
  else
    LData.RatioText := '';
  LData.Trend := K.Trend;

  LAction := KpiAction(K.Key);
  LTile := TDashTile.Create(AParent);
  LTile.Parent := AParent;
  LTile.Width := KPI_CARD_WIDTH;
  LTile.Height := KPI_CARD_HEIGHT;
  LTile.AlignWithMargins := True;
  LTile.Margins.SetBounds(6, 6, 6, 6);
  LTile.Tag := AIndex;
  LTile.Clickable := Assigned(LAction) and LAction.Enabled;
  if LTile.Clickable then
  begin
    LTile.OnClick := KpiCardClick;
    LTile.ShowHint := True;
    LTile.Hint := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiOpenHint, 'Click to open the list');
  end;
  LTile.SetData(LData);
end;

procedure TfrmDashboard.CreateChart(AParent: TWinControl; AIndex: Integer);
var
  C: TDashboardChart;
  LChart: TDashChart;
  LData: TDashChartData;
  LAction: TAction;
begin
  C := FCharts[AIndex];
  LData.Kind := dckColumns;
  LData.DateFormat := 'dd.mm';
  LData.ValueFormat := '#,##0.00';
  LData.Points := C.Points;
  LData.EmptyText := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiChartEmpty, 'No records in this period');
  if C.Key = CHART_MONEY_FLOW then
  begin
    LData.Title := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiChartMoneyFlow, 'Money In / Out');
    LData.Subtitle := Format(TLocalizationManager.Translate(TLangKeys.TDashboard.KpiChartSubMoney, 'Last 14 days, in %s'), [C.Currency]);
    LData.Series1 := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiLegendIn, 'In');
    LData.Series2 := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiLegendOut, 'Out');
    LData.Color1 := RGB(16, 163, 127);
    LData.Color2 := RGB(232, 93, 93);
  end
  else if C.Key = CHART_CHEQUE_DUE then
  begin
    LData.Title := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiChartChequeDue, 'Cheque / Note Due Dates');
    LData.Subtitle := Format(TLocalizationManager.Translate(TLangKeys.TDashboard.KpiChartSubCheque, 'Next 8 weeks (weekly), in %s'), [C.Currency]);
    LData.Series1 := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiLegendReceived, 'Received');
    LData.Series2 := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiLegendGiven, 'Given');
    LData.Color1 := RGB(16, 163, 127);
    LData.Color2 := RGB(232, 93, 93);
  end
  else if C.Key = CHART_STOCK_FLOW then
  begin
    LData.Title := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiChartStockFlow, 'Stock Movements');
    LData.Subtitle := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiChartSubStock, 'Last 14 days, number of movements');
    LData.Series1 := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiLegendIn, 'In');
    LData.Series2 := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiLegendOut, 'Out');
    LData.Color1 := RGB(37, 128, 230);
    LData.Color2 := RGB(234, 128, 40);
    LData.ValueFormat := '#,##0';
  end
  else
  begin
    LData.Kind := dckLines;
    LData.Title := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiChartFxTrend, 'Exchange Rates');
    LData.Subtitle := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiChartSubFx, 'Last 30 rate days');
    LData.Series1 := 'USD';
    LData.Series2 := 'EUR';
    LData.Color1 := RGB(37, 99, 235);
    LData.Color2 := RGB(124, 92, 230);
    LData.ValueFormat := '#,##0.0000';
  end;

  LAction := KpiAction(C.Key);
  LChart := TDashChart.Create(AParent);
  LChart.Parent := AParent;
  LChart.Width := KPI_CARD_WIDTH * 2 + 12;
  LChart.Height := KPI_CHART_HEIGHT;
  LChart.AlignWithMargins := True;
  LChart.Margins.SetBounds(6, 6, 6, 6);
  LChart.Tag := AIndex;
  LChart.Clickable := Assigned(LAction) and LAction.Enabled;
  if LChart.Clickable then
    LChart.OnClick := KpiCardClick;
  LChart.SetData(LData);
end;

procedure TfrmDashboard.RenderKpis;
var
  LSection, I, LOrder, LCritical, LWarning: Integer;
  LHasAny: Boolean;
  LWelcome: TDashWelcome;
  LHeader: TDashSection;
  LEmpty: TLabel;
  LFlow: TFlowPanel;
  LChips: TArray<TDashChip>;
  LChip: TDashChip;
  LName: string;
  LFmt: TFormatSettings;

  procedure AddTop(AControl: TControl; ALeft, ATop, ARight: Integer);
  begin
    AControl.Parent := FKpiScroll;
    AControl.Align := alTop;
    AControl.AlignWithMargins := True;
    AControl.Margins.SetBounds(ALeft, ATop, ARight, 0);
    // alTop sırası Top değerine göre: her eklenen bir öncekinin altına
    AControl.Top := LOrder;
    Inc(LOrder, 1000);
  end;

  function NewFlow: TFlowPanel;
  begin
    Result := TFlowPanel.Create(FKpiScroll);
    AddTop(Result, 10, 2, 10);
    Result.BevelOuter := bvNone;
    Result.ParentColor := True;
    Result.ParentBackground := False;
    Result.StyleElements := Result.StyleElements - [seClient];
    Result.DoubleBuffered := True;
    Result.AutoWrap := True;
    Result.AutoSize := True;
  end;

  procedure AddSection(const ATitle, AIcon: string; AColor: TColor);
  begin
    LHeader := TDashSection.Create(FKpiScroll);
    AddTop(LHeader, 14, 14, 16);
    LHeader.SetData(ATitle, AIcon, AColor);
  end;

begin
  BuildKpiArea;
  FBtnKpiRefresh.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiRefresh, 'Refresh');
  if FKpiLoadedAt > 0 then
    FLblKpiUpdated.Caption := Format(TLocalizationManager.Translate(TLangKeys.TDashboard.KpiLastUpdate, 'Updated: %s'),
      [FormatDateTime('hh:nn', FKpiLoadedAt)])
  else
    FLblKpiUpdated.Caption := '';

  FKpiScroll.DisableAlign;
  try
    while FKpiScroll.ControlCount > 0 do
      FKpiScroll.Controls[0].Free;
    LOrder := 0;

    // karşılama bandı: ad + tarih (etkin dilde) + kritik / uyarı sayısı
    LName := '';
    if TAppContext.IsInitialized and Assigned(TAppContext.Instance.CurrentUser) then
    begin
      if Assigned(TAppContext.Instance.CurrentUser.User) then
        LName := Trim(TAppContext.Instance.CurrentUser.User.PersonName);
      if LName = '' then
        LName := TAppContext.Instance.CurrentUser.GetUsername;
      try
        LFmt := TFormatSettings.Create(TAppContext.Instance.CurrentUser.ActiveLanguage);
      except
        LFmt := FormatSettings;
      end;
    end
    else
      LFmt := FormatSettings;
    LCritical := 0;
    LWarning := 0;
    for I := 0 to High(FKpis) do
      case FKpis[I].Level of
        dlDanger:  Inc(LCritical);
        dlWarning: Inc(LWarning);
      end;
    LChips := [];
    if LCritical > 0 then
    begin
      LChip.Text := Format(TLocalizationManager.Translate(TLangKeys.TDashboard.KpiFmtCritical, '%d critical'), [LCritical]);
      LChip.Color := KpiLevelColor(dlDanger);
      LChips := LChips + [LChip];
    end;
    if LWarning > 0 then
    begin
      LChip.Text := Format(TLocalizationManager.Translate(TLangKeys.TDashboard.KpiFmtWarnings, '%d warning(s)'), [LWarning]);
      LChip.Color := KpiLevelColor(dlWarning);
      LChips := LChips + [LChip];
    end;
    if (Length(LChips) = 0) and (Length(FKpis) > 0) then
    begin
      LChip.Text := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiAllGood, 'All good');
      LChip.Color := KpiLevelColor(dlNormal);
      LChips := LChips + [LChip];
    end;
    LWelcome := TDashWelcome.Create(FKpiScroll);
    AddTop(LWelcome, 16, 14, 16);
    LWelcome.SetData(Format(TLocalizationManager.Translate(TLangKeys.TDashboard.KpiWelcome, 'Welcome, %s'), [LName]),
      FormatDateTime('dddd, d mmmm yyyy', Date, LFmt), LChips);

    // genel bakış grafikleri
    if Length(FCharts) > 0 then
    begin
      AddSection(TLocalizationManager.Translate(TLangKeys.TDashboard.KpiSecOverview, 'Overview'), ICON_CHART, RGB(37, 99, 235));
      LFlow := NewFlow;
      for I := 0 to High(FCharts) do
        CreateChart(LFlow, I);
    end;

    LHasAny := False;
    for LSection := 0 to KPI_SECTION_COUNT - 1 do
    begin
      LFlow := nil;
      for I := 0 to High(FKpis) do
      begin
        if KpiSection(FKpis[I].Key) <> LSection then
          Continue;
        if LFlow = nil then
        begin
          AddSection(KpiSectionTitle(LSection), KpiSectionIcon(LSection), KpiSectionColor(LSection));
          LFlow := NewFlow;
          LHasAny := True;
        end;
        CreateKpiCard(LFlow, I);
      end;
    end;

    if not LHasAny then
    begin
      LEmpty := TLabel.Create(FKpiScroll);
      AddTop(LEmpty, 16, 24, 16);
      LEmpty.Font.Size := 11;
      LEmpty.Font.Color := clGrayText;
      LEmpty.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.KpiNoData, 'There is no summary you are allowed to view.');
    end;

    // alt boşluk
    LEmpty := TLabel.Create(FKpiScroll);
    AddTop(LEmpty, 0, 0, 0);
    LEmpty.AutoSize := False;
    LEmpty.Height := 16;
    LEmpty.Caption := '';
  finally
    FKpiScroll.EnableAlign;
  end;
  LayoutKpiCards;
end;

Initialization

finalization
  if TConnectionManager.Instance <> nil then
    FreeAndNil(TConnectionManager.Instance);
  TAppContext.Finalize;

end.
