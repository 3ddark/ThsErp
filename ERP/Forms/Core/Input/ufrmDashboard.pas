unit ufrmDashboard;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.Variants, System.Math, System.StrUtils, System.Actions,
  System.Classes, System.SysUtils, System.DateUtils, System.Rtti, System.Generics.Collections,
  System.ImageList, System.Threading, Winapi.ShellAPI, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.Themes, Vcl.ComCtrls, Vcl.Menus, Vcl.ActnList, Vcl.AppEvnts,
  Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Dialogs,
  Vcl.ToolWin, Vcl.ImgList, Vcl.StdActns, Vcl.CategoryButtons, Vcl.WinXCtrls,
  Vcl.Imaging.pngimage, Data.DB, FireDAC.Comp.Client,
  udm, ufrmBase, Entity, ufrmGrid, ufrmGridBase, ufrmInputSimpleDB, Service, FormHost,

  ConnectionManager, Logger, MetaProvider, SharedFormTypes, FilterCriterion,
  AppContext, UserContext, UnitOfWork,
  SysDashboard, SysDashboard.Service, DashboardControls,
  SysMenu, SysMenu.Service, NavigationTree, ScreenCode,
  ufrmSysMenus, SysUserSetting, SysUserSetting.Service,
  ufrmSysApiServices, SysApiService, SysApiService.Service,
  ufrmEInvDocumentSettings, EInvDocumentSetting, EInvDocumentSetting.Service,
  ufrmSysAuditLogs, SysAuditLog, SysAuditLog.Service,
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
  ufrmAccVouchers, AccVoucher.Service, AccVoucher,
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
  ufrmPurOrders, PurOrder.Service, PurOrder,
  ufrmPurReceipts, PurReceipt.Service, PurReceipt,
  ufrmPurInvoices, PurInvoice.Service, PurInvoice,
  ufrmPurQuotations, PurQuotation.Service, PurQuotation,
  ufrmPurQuotationComparisons, PurQuotationComparison.Service, PurQuotationComparison,
  ufrmQcReceiptLines, QcReceiptLine.Service, QcReceiptLine,
  ufrmQcInspections, QcInspection.Service, QcInspection,
  ufrmQcRules, QcRule.Service, QcRule,
  ufrmQcSetting, QcSetting.Service, QcSetting,
  ufrmSlsOffers, SlsOffer.Service, SlsOffer,
  ufrmSlsOrders, SlsOrder.Service, SlsOrder,
  ufrmSlsDispatches, SlsDispatch.Service, SlsDispatch,
  ufrmSlsInvoices, SlsInvoice.Service, SlsInvoice,
  ufrmFinCompanyBankAccounts, FinCompanyBankAccount.Service, FinCompanyBankAccount,
  ufrmAccAccountTransactions, AccAccountTransaction.Service, AccAccountTransaction,
  ufrmEInvDiibs, EInvDiib.Service, EInvDiib,
  ufrmEInvProfiles, EInvProfile.Service, EInvProfile,
  ufrmEInvInvoiceTypes, EInvInvoiceType.Service, EInvInvoiceType,
  ufrmEInvTaxExemptions, EInvTaxExemption.Service, EInvTaxExemption,
  ufrmEInvTaxTypes, EInvTaxType.Service, EInvTaxType,
  ufrmEInvWithholdings, EInvWithholding.Service, EInvWithholding,
  ufrmEInvDeliveryTerms, EInvDeliveryTerm.Service, EInvDeliveryTerm,
  ufrmEInvTransportModes, EInvTransportMode.Service, EInvTransportMode,
  ufrmEInvPackagingTypes, EInvPackagingType.Service, EInvPackagingType,
  ufrmEInvPaymentMeansList, EInvPaymentMeans.Service, EInvPaymentMeans,
  ufrmEInvSeriesList, EInvSeries.Service, EInvSeries,
  ufrmEInvVehicles, EInvVehicle.Service, EInvVehicle,
  ufrmEInvDrivers, EInvDriver.Service, EInvDriver,
  ufrmEInvGtips, EInvGtip.Service, EInvGtip,
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
    actacc_voucher: TAction;
    actsys_currency: TAction;
    actsys_unit: TAction;
    actsys_region: TAction;
    actsys_unit_type: TAction;
    mm1: TMainMenu;
    mnimenu_about: TMenuItem;
    mnisys_update_password: TMenuItem;
    mnisys_refresh_permissions: TMenuItem;
    mnisys_refresh_permissions_sep: TMenuItem;
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
    mnisls_offers: TMenuItem;
    mnisls_orders: TMenuItem;
    mnisls_dispatches: TMenuItem;
    mnisls_invoices: TMenuItem;
    mnisls_sep1: TMenuItem;
    mnisls_sep2: TMenuItem;
    mnisls_sep3: TMenuItem;
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
    actpur_orders: TAction;
    actpur_receipts: TAction;
    actpur_invoices: TAction;
    actpur_quotations: TAction;
    actpur_quotation_comparisons: TAction;
    actqc_receipt_lines: TAction;
    actqc_inspections: TAction;
    actqc_rules: TAction;
    actqc_setting: TAction;
    actsls_offers: TAction;
    actsls_orders: TAction;
    actsls_dispatches: TAction;
    actsls_invoices: TAction;
    actsls_diibs: TAction;
    actsls_einv_profiles: TAction;
    actsls_einv_invoice_types: TAction;
    actsls_einv_tax_exemptions: TAction;
    actsls_einv_tax_types: TAction;
    actsls_einv_withholdings: TAction;
    actsls_einv_delivery_terms: TAction;
    actsls_einv_transport_modes: TAction;
    actsls_einv_packaging_types: TAction;
    actsls_einv_payment_means: TAction;
    actsls_einv_series: TAction;
    actsls_einv_vehicles: TAction;
    actsls_einv_drivers: TAction;
    actstk_gtips: TAction;
    mnisls_diibs: TMenuItem;
    mnisls_einv_profiles: TMenuItem;
    mnisls_einv_invoice_types: TMenuItem;
    mnisls_einv_tax_exemptions: TMenuItem;
    mnisls_einv_tax_types: TMenuItem;
    mnisls_einv_withholdings: TMenuItem;
    mnisls_einv_delivery_terms: TMenuItem;
    mnisls_einv_transport_modes: TMenuItem;
    mnisls_einv_packaging_types: TMenuItem;
    mnisls_einv_payment_means: TMenuItem;
    mnisls_einv_series: TMenuItem;
    mnisls_einv_vehicles: TMenuItem;
    mnisls_einv_drivers: TMenuItem;
    mnistk_gtips: TMenuItem;
    mnisls_sep4: TMenuItem;
    mnisls_einv_settings: TMenuItem;
    mnipur_requests: TMenuItem;
    mnipur_sep1: TMenuItem;
    mnipur_orders: TMenuItem;
    mnipur_sep2: TMenuItem;
    mnipur_receipts: TMenuItem;
    mnipur_sep3: TMenuItem;
    mnipur_invoices: TMenuItem;
    mnipur_sep4: TMenuItem;
    mnipur_quotations: TMenuItem;
    mnipur_quotation_comparisons: TMenuItem;
    mnipur_sep5: TMenuItem;
    mnipur_quality: TMenuItem;
    mniqc_receipt_lines: TMenuItem;
    mniqc_inspections: TMenuItem;
    mniqc_rules: TMenuItem;
    mniqc_setting: TMenuItem;
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
    mniacc_voucher: TMenuItem;
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
    actsys_menu: TAction;
    mnisys_menu: TMenuItem;
    actsys_api_services: TAction;
    mnisys_api_services: TMenuItem;
    actsls_einv_document_settings: TAction;
    mnisls_einv_document_settings: TMenuItem;
    actsys_audit_log: TAction;
    mnisys_audit_log: TMenuItem;

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
    procedure actsys_aboutExecute(Sender: TObject);
    procedure actsys_update_passwordExecute(Sender: TObject);
    procedure actsys_refresh_permissionsExecute(Sender: TObject);
    procedure actsys_updateExecute(Sender: TObject);
    procedure actsys_countryExecute(Sender: TObject);
    procedure actsys_cityExecute(Sender: TObject);
    procedure actacc_exchange_rateExecute(Sender: TObject);
    procedure actacc_voucherExecute(Sender: TObject);
    procedure actsys_currencyExecute(Sender: TObject);
    procedure actsys_unitExecute(Sender: TObject);
    procedure actch_hesap_karti_araExecute(Sender: TObject);
    procedure actch_hesap_kartiExecute(Sender: TObject);
    procedure actch_bolgeExecute(Sender: TObject);
    procedure actset_ch_firma_tipiExecute(Sender: TObject);
    procedure actset_ch_firma_turuExecute(Sender: TObject);
    procedure actset_ch_grupExecute(Sender: TObject);
    procedure actset_ch_hesap_planiExecute(Sender: TObject);
    procedure actset_ch_hesap_tipiExecute(Sender: TObject);
    procedure actsys_unit_typeExecute(Sender: TObject);
    procedure actsys_regionExecute(Sender: TObject);
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
    procedure actpur_ordersExecute(Sender: TObject);
    procedure actpur_receiptsExecute(Sender: TObject);
    procedure actpur_invoicesExecute(Sender: TObject);
    procedure actpur_quotationsExecute(Sender: TObject);
    procedure actpur_quotation_comparisonsExecute(Sender: TObject);
    procedure actqc_receipt_linesExecute(Sender: TObject);
    procedure actqc_inspectionsExecute(Sender: TObject);
    procedure actqc_rulesExecute(Sender: TObject);
    procedure actqc_settingExecute(Sender: TObject);
    procedure actsls_offersExecute(Sender: TObject);
    procedure actsls_ordersExecute(Sender: TObject);
    procedure actsls_dispatchesExecute(Sender: TObject);
    procedure actsls_invoicesExecute(Sender: TObject);
    procedure actsls_diibsExecute(Sender: TObject);
    procedure actsls_einv_profilesExecute(Sender: TObject);
    procedure actsls_einv_invoice_typesExecute(Sender: TObject);
    procedure actsls_einv_tax_exemptionsExecute(Sender: TObject);
    procedure actsls_einv_tax_typesExecute(Sender: TObject);
    procedure actsls_einv_withholdingsExecute(Sender: TObject);
    procedure actsls_einv_delivery_termsExecute(Sender: TObject);
    procedure actsls_einv_transport_modesExecute(Sender: TObject);
    procedure actsls_einv_packaging_typesExecute(Sender: TObject);
    procedure actsls_einv_payment_meansExecute(Sender: TObject);
    procedure actsls_einv_seriesExecute(Sender: TObject);
    procedure actsls_einv_vehiclesExecute(Sender: TObject);
    procedure actsls_einv_driversExecute(Sender: TObject);
    procedure actstk_gtipsExecute(Sender: TObject);
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
    procedure actsys_menuExecute(Sender: TObject);
    procedure actsys_api_servicesExecute(Sender: TObject);
    procedure actsls_einv_document_settingsExecute(Sender: TObject);
    procedure actsys_audit_logExecute(Sender: TObject);
  private
    type
      // sekmeye alınan formun ayrı pencere ayarları (sekmeden ayrılınca geri yüklenir)
      TDockedForm = record
        Sheet: TTabSheet;
        BorderStyle: TFormBorderStyle;
        Height: Integer;
        MinWidth, MinHeight, MaxWidth, MaxHeight: Integer;
      end;
  private
    FIsFormShow: Boolean;
    FF6Pressed: Boolean;
    FRateUpdateStarted: Boolean;
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
    FAppEvents: TApplicationEvents;
    FNavStateLoaded: Boolean;
    // işlem geçmişi kuyruğu (audit_outbox) -> ths_audit aktarımı
    FAuditTimer: TTimer;
    // açılan liste ekranları: sekmeli mod (ana ekranda sekme) / ayrı pencere; kullanıcı ayarı nav.tabbed
    FPages: TPageControl;
    FHomeSheet: TTabSheet;
    FTabPopup: TPopupMenu;
    FMniTabDetach: TMenuItem;
    FMniTabClose: TMenuItem;
    FChkTabbed: TCheckBox;
    FTabbed: Boolean;
    FDocked: TDictionary<TForm, TDockedForm>;
    procedure BuildTabs;
    function HostForm(AForm: TForm): Boolean;
    procedure DockForm(AForm: TForm);
    procedure UndockForm(AForm: TForm);
    procedure SetTabbed(AValue: Boolean);
    function DockedFormOf(ASheet: TTabSheet): TForm;
    procedure TabsChange(Sender: TObject);
    procedure TabsMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TabCloseClick(Sender: TObject);
    procedure TabDetachClick(Sender: TObject);
    procedure ChkTabbedClick(Sender: TObject);
    procedure AppIdle(Sender: TObject; var Done: Boolean);
    procedure AuditTimerTimer(Sender: TObject);
    procedure FlushAudit;
    // Günün kuru yoksa TCMB'den (arka planda indirilir, ana thread'de yazılır); hata yalnız loglanır
    procedure StartExchangeRateUpdate;
    procedure AppShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure AppException(Sender: TObject; E: Exception);
    procedure ShowCommandPalette;
    procedure LoadNavState;
    procedure SaveNavState;
    procedure BuildNavPanel;
    procedure LoadMenu;
    procedure NavOpenItem(const AItem: TSysMenuItem);
    procedure NavToggleFavorite(const AItem: TSysMenuItem; AFavorite: Boolean);
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
  protected
    procedure DoClose(var Action: TCloseAction); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
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
  ufrmAbout, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Constants, Ths.Globals, Ths.DialogHelper,
  Db.ErrorTranslator, Tcmb.ExchangeRates;

// Ana thread'de: bülten kur tablosuna. Başka ekranın açık transaction'ı varsa yazılmaz (sonraki açılışta yeniden denenir).
procedure SaveTcmbBulletin(const ABulletin: TTcmbBulletin);
var
  LSvc: TAccExchangeRateService;
  LCount: Integer;
begin
  try
    if not TAppContext.IsInitialized or TUnitOfWork.Instance.InTransaction then
    begin
      GLogger.Warning('TCMB kurları yazılmadı: açık transaction var');
      Exit;
    end;
    LSvc := TAccExchangeRateService.Create;
    try
      LCount := LSvc.ImportTcmbBulletin(ABulletin, False);
    finally
      LSvc.Free;
    end;
    GLogger.InfoFmt('TCMB kurları alındı: %s, %d kayıt', [DateToStr(ABulletin.BulletinDate), LCount]);
  except
    on E: Exception do
      GLogger.ErrorFmt('TCMB kurları yazılamadı: %s', [E.Message]);
  end;
end;

procedure TfrmDashboard.actsys_aboutExecute(Sender: TObject);
begin
  TfrmAbout.Create(Application).ShowModal;
  RefreshUserPermissions(False);
end;

procedure TfrmDashboard.actacc_voucherExecute(Sender: TObject);
begin
  TfrmAccVouchers.Create(Self, TAccVoucherService.Create, TAccVoucher.Create).Show;
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

procedure TfrmDashboard.actpur_ordersExecute(Sender: TObject);
begin
  TfrmPurOrders.Create(Self, TPurOrderService.Create, TPurOrder.Create).Show;
end;

procedure TfrmDashboard.actpur_receiptsExecute(Sender: TObject);
begin
  TfrmPurReceipts.Create(Self, TPurReceiptService.Create, TPurReceipt.Create).Show;
end;

procedure TfrmDashboard.actpur_invoicesExecute(Sender: TObject);
begin
  TfrmPurInvoices.Create(Self, TPurInvoiceService.Create, TPurInvoice.Create).Show;
end;

procedure TfrmDashboard.actpur_quotationsExecute(Sender: TObject);
begin
  TfrmPurQuotations.Create(Self, TPurQuotationService.Create, TPurQuotation.Create).Show;
end;

procedure TfrmDashboard.actpur_quotation_comparisonsExecute(Sender: TObject);
begin
  TfrmPurQuotationComparisons.Create(Self, TPurQuotationComparisonService.Create, TPurQuotationComparison.Create).Show;
end;

procedure TfrmDashboard.actqc_receipt_linesExecute(Sender: TObject);
begin
  TfrmQcReceiptLines.Create(Self, TQcReceiptLineService.Create, TQcReceiptLine.Create).Show;
end;

procedure TfrmDashboard.actqc_inspectionsExecute(Sender: TObject);
begin
  TfrmQcInspections.Create(Self, TQcInspectionService.Create, TQcInspection.Create).Show;
end;

procedure TfrmDashboard.actqc_rulesExecute(Sender: TObject);
begin
  TfrmQcRules.Create(Self, TQcRuleService.Create, TQcRule.Create).Show;
end;

procedure TfrmDashboard.actqc_settingExecute(Sender: TObject);
var
  LService: TQcSettingService;
  LSetting: TQcSetting;
  LMode: TInputFormMode;
begin
  // Firma başına tek kayıt: varsa inceleme modunda, yoksa yeni kayıt olarak aç
  LService := TQcSettingService.Create;
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
    LSetting := TQcSetting.Create;
    LMode := ifmNewRecord;
  end;

  TfrmQcSetting.Create(Self, LService, LSetting, LMode, nil, ivmNormal, True).Show;
end;

procedure TfrmDashboard.actsls_offersExecute(Sender: TObject);
begin
  TfrmSlsOffers.Create(Self, TSlsOfferService.Create, TSlsOffer.Create).Show;
end;

procedure TfrmDashboard.actsls_ordersExecute(Sender: TObject);
begin
  TfrmSlsOrders.Create(Self, TSlsOrderService.Create, TSlsOrder.Create).Show;
end;

procedure TfrmDashboard.actsls_dispatchesExecute(Sender: TObject);
begin
  TfrmSlsDispatches.Create(Self, TSlsDispatchService.Create, TSlsDispatch.Create).Show;
end;

procedure TfrmDashboard.actsls_invoicesExecute(Sender: TObject);
begin
  TfrmSlsInvoices.Create(Self, TSlsInvoiceService.Create, TSlsInvoice.Create).Show;
end;

procedure TfrmDashboard.actsls_diibsExecute(Sender: TObject);
begin
  TfrmEInvDiibs.Create(Self, TEInvDiibService.Create, TEInvDiib.Create).Show;
end;

procedure TfrmDashboard.actsls_einv_profilesExecute(Sender: TObject);
begin
  TfrmEInvProfiles.Create(Self, TEInvProfileService.Create, TEInvProfile.Create).Show;
end;

procedure TfrmDashboard.actsls_einv_invoice_typesExecute(Sender: TObject);
begin
  TfrmEInvInvoiceTypes.Create(Self, TEInvInvoiceTypeService.Create, TEInvInvoiceType.Create).Show;
end;

procedure TfrmDashboard.actsls_einv_tax_exemptionsExecute(Sender: TObject);
begin
  TfrmEInvTaxExemptions.Create(Self, TEInvTaxExemptionService.Create, TEInvTaxExemption.Create).Show;
end;

procedure TfrmDashboard.actsls_einv_tax_typesExecute(Sender: TObject);
begin
  TfrmEInvTaxTypes.Create(Self, TEInvTaxTypeService.Create, TEInvTaxType.Create).Show;
end;

procedure TfrmDashboard.actsls_einv_withholdingsExecute(Sender: TObject);
begin
  TfrmEInvWithholdings.Create(Self, TEInvWithholdingService.Create, TEInvWithholding.Create).Show;
end;

procedure TfrmDashboard.actsls_einv_delivery_termsExecute(Sender: TObject);
begin
  TfrmEInvDeliveryTerms.Create(Self, TEInvDeliveryTermService.Create, TEInvDeliveryTerm.Create).Show;
end;

procedure TfrmDashboard.actsls_einv_transport_modesExecute(Sender: TObject);
begin
  TfrmEInvTransportModes.Create(Self, TEInvTransportModeService.Create, TEInvTransportMode.Create).Show;
end;

procedure TfrmDashboard.actsls_einv_packaging_typesExecute(Sender: TObject);
begin
  TfrmEInvPackagingTypes.Create(Self, TEInvPackagingTypeService.Create, TEInvPackagingType.Create).Show;
end;

procedure TfrmDashboard.actsls_einv_payment_meansExecute(Sender: TObject);
begin
  TfrmEInvPaymentMeansList.Create(Self, TEInvPaymentMeansService.Create, TEInvPaymentMeans.Create).Show;
end;

procedure TfrmDashboard.actsls_einv_seriesExecute(Sender: TObject);
begin
  TfrmEInvSeriesList.Create(Self, TEInvSeriesService.Create, TEInvSeries.Create).Show;
end;

procedure TfrmDashboard.actsls_einv_vehiclesExecute(Sender: TObject);
begin
  TfrmEInvVehicles.Create(Self, TEInvVehicleService.Create, TEInvVehicle.Create).Show;
end;

procedure TfrmDashboard.actsls_einv_driversExecute(Sender: TObject);
begin
  TfrmEInvDrivers.Create(Self, TEInvDriverService.Create, TEInvDriver.Create).Show;
end;

procedure TfrmDashboard.actstk_gtipsExecute(Sender: TObject);
begin
  TfrmEInvGtips.Create(Self, TEInvGtipService.Create, TEInvGtip.Create).Show;
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

procedure TfrmDashboard.actsys_menuExecute(Sender: TObject);
begin
  TfrmSysMenus.Create(Self, TSysMenuService.Create, TSysMenu.Create).Show;
end;

procedure TfrmDashboard.actsys_api_servicesExecute(Sender: TObject);
begin
  TfrmSysApiServices.Create(Self, TSysApiServiceService.Create, TSysApiService.Create).Show;
end;

procedure TfrmDashboard.actsls_einv_document_settingsExecute(Sender: TObject);
begin
  TfrmEInvDocumentSettings.Create(Self, TEInvDocumentSettingService.Create, TEInvDocumentSetting.Create).Show;
end;

procedure TfrmDashboard.actsys_audit_logExecute(Sender: TObject);
var
  LFrm: TfrmSysAuditLogs;
begin
  // açmadan önce bekleyen kayıtlar aktarılır: liste son işlemleri de göstersin
  FlushAudit;
  LFrm := TfrmSysAuditLogs.Create(Self, TSysAuditLogService.Create, TSysAuditLog.Create);
  LFrm.SetCurrentPeriod;
  LFrm.Show;
end;

procedure TfrmDashboard.StartExchangeRateUpdate;
var
  LSvc: TAccExchangeRateService;
  LNeeded: Boolean;
begin
  if FRateUpdateStarted or not TAppContext.IsInitialized or not Assigned(TAppContext.Instance.CurrentUser) then
    Exit;
  FRateUpdateStarted := True;
  try
    LSvc := TAccExchangeRateService.Create;
    try
      LNeeded := LSvc.NeedsTcmbUpdate(Date);
    finally
      LSvc.Free;
    end;
  except
    on E: Exception do
    begin
      GLogger.ErrorFmt('Kur kontrolü yapılamadı: %s', [E.Message]);
      Exit;
    end;
  end;
  if not LNeeded then
    Exit;

  // indirme + ayrıştırma arka planda (bağlantı yoksa açılış beklemez); DB yazımı ana thread'de
  TTask.Run(
    procedure
    var
      LBulletin: TTcmbBulletin;
      LError: string;
    begin
      try
        LBulletin := TTcmbClient.Fetch;
        TThread.Queue(nil,
          procedure
          begin
            SaveTcmbBulletin(LBulletin);
          end);
      except
        on E: Exception do
        begin
          LError := E.Message;
          TThread.Queue(nil,
            procedure
            begin
              GLogger.WarningFmt('TCMB kurları indirilemedi: %s', [LError]);
            end);
        end;
      end;
    end);
end;

// Yerel kuyruk (audit_outbox) ortak ths_audit veritabanına taşınır. Açık transaction varken servis atlar;
// audit DB'ye ulaşılamazsa satırlar kuyrukta kalır (yalnız log), sonraki denemede taşınır.
procedure TfrmDashboard.FlushAudit;
var
  LSvc: TSysAuditLogService;
  LRes: TAuditFlushResult;
begin
  if not TAppContext.IsInitialized or not Assigned(TAppContext.Instance.CurrentUser) then
    Exit;
  try
    LSvc := TSysAuditLogService.Create;
    try
      LRes := LSvc.Flush;
    finally
      LSvc.Free;
    end;
    if LRes.Moved < 0 then
      GLogger.WarningFmt('İşlem geçmişi aktarılamadı (kuyrukta bekliyor): %s', [LRes.ErrorMessage])
    else if LRes.Moved > 0 then
      GLogger.InfoFmt('İşlem geçmişi aktarıldı: %d satır', [LRes.Moved]);
  except
    on E: Exception do
      GLogger.ErrorFmt('İşlem geçmişi aktarımı hatası: %s', [E.Message]);
  end;
end;

procedure TfrmDashboard.AuditTimerTimer(Sender: TObject);
begin
  FlushAudit;
end;

procedure TfrmDashboard.actsys_userExecute(Sender: TObject);
begin
  TfrmSysUsers.Create(Self, TSysUserService.Create, TSysUser.Create).Show;
end;

procedure TfrmDashboard.actsys_access_rightExecute(Sender: TObject);
begin
  TfrmSysAccessRights.Create(Self, TSysAccessRightService.Create, TSysAccessRight.Create).Show;
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
  GFormHost := nil;
  // sekmedeki formlar bileşenlerle birlikte yok edilir: Notification artık sekme silmesin
  FreeAndNil(FDocked);
  FActionCodes.Free;
  inherited;
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
          if Assigned(actsys_menu) then
            actsys_menu.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionMenus, 'Menu Screens');
          if Assigned(actsys_api_services) then
            actsys_api_services.Caption := TLocalizationManager.Translate(TLangKeys.TSysApiService.TitlePlural, 'Integration Services');
          if Assigned(actsls_einv_document_settings) then
            actsls_einv_document_settings.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.TitlePlural, 'e-Document Settings');
          if Assigned(actsys_audit_log) then
            actsys_audit_log.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionAuditLog, 'Audit Log');
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
      if Assigned(actacc_voucher) then
        actacc_voucher.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.ActionAccVouchers, 'Accounting Vouchers');
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
  if Assigned(actpur_orders) then
    actpur_orders.Caption := TLocalizationManager.Translate(TLangKeys.TPurOrder.TitlePlural, 'Purchase Orders');
  if Assigned(actpur_receipts) then
    actpur_receipts.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceipt.TitlePlural, 'Goods Receipts');
  if Assigned(actpur_invoices) then
    actpur_invoices.Caption := TLocalizationManager.Translate(TLangKeys.TPurInvoice.TitlePlural, 'Purchase Invoices');
  if Assigned(actpur_quotations) then
    actpur_quotations.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotation.TitlePlural, 'Purchase Quotations');
  if Assigned(actpur_quotation_comparisons) then
    actpur_quotation_comparisons.Caption := TLocalizationManager.Translate(TLangKeys.TPurQuotationComparison.TitlePlural, 'Quotation Comparison');
  if Assigned(mnipur_quality) then
    mnipur_quality.Caption := TLocalizationManager.Translate(TLangKeys.TQcSetting.ModuleName, 'Incoming Quality Control');
  if Assigned(actqc_receipt_lines) then
    actqc_receipt_lines.Caption := TLocalizationManager.Translate(TLangKeys.TQcReceiptLine.TitlePlural, 'Receipts Awaiting Inspection');
  if Assigned(actqc_inspections) then
    actqc_inspections.Caption := TLocalizationManager.Translate(TLangKeys.TQcInspection.TitlePlural, 'Quality Inspections');
  if Assigned(actqc_rules) then
    actqc_rules.Caption := TLocalizationManager.Translate(TLangKeys.TQcRule.TitlePlural, 'Quality Control Rules');
  if Assigned(actqc_setting) then
    actqc_setting.Caption := TLocalizationManager.Translate(TLangKeys.TQcSetting.TitleSingular, 'Quality Control Settings');
  if Assigned(actsls_offers) then
    actsls_offers.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOffer.TitlePlural, 'Sales Offers');
  if Assigned(actsls_orders) then
    actsls_orders.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOrder.TitlePlural, 'Sales Orders');
  if Assigned(actsls_dispatches) then
    actsls_dispatches.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.TitlePlural, 'Delivery Notes');
  if Assigned(actsls_invoices) then
    actsls_invoices.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.TitlePlural, 'Sales Invoices');
  if Assigned(actsls_diibs) then
    actsls_diibs.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.TitlePlural, 'DIIB Certificates');
  if Assigned(actsls_einv_profiles) then
    actsls_einv_profiles.Caption := TLocalizationManager.Translate(TLangKeys.TEInvProfile.TitlePlural, 'e-Document Profiles');
  if Assigned(actsls_einv_invoice_types) then
    actsls_einv_invoice_types.Caption := TLocalizationManager.Translate(TLangKeys.TEInvInvoiceType.TitlePlural, 'e-Invoice Types');
  if Assigned(actsls_einv_tax_exemptions) then
    actsls_einv_tax_exemptions.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.TitlePlural, 'Tax Exemption Codes');
  if Assigned(actsls_einv_tax_types) then
    actsls_einv_tax_types.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTaxType.TitlePlural, 'Tax Type Codes');
  if Assigned(actsls_einv_withholdings) then
    actsls_einv_withholdings.Caption := TLocalizationManager.Translate(TLangKeys.TEInvWithholding.TitlePlural, 'Withholding Codes');
  if Assigned(actsls_einv_delivery_terms) then
    actsls_einv_delivery_terms.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDeliveryTerm.TitlePlural, 'Delivery Terms');
  if Assigned(actsls_einv_transport_modes) then
    actsls_einv_transport_modes.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTransportMode.TitlePlural, 'Transport Modes');
  if Assigned(actsls_einv_packaging_types) then
    actsls_einv_packaging_types.Caption := TLocalizationManager.Translate(TLangKeys.TEInvPackagingType.TitlePlural, 'Packaging Types');
  if Assigned(actsls_einv_payment_means) then
    actsls_einv_payment_means.Caption := TLocalizationManager.Translate(TLangKeys.TEInvPaymentMeans.TitlePlural, 'Payment Means');
  if Assigned(actsls_einv_series) then
    actsls_einv_series.Caption := TLocalizationManager.Translate(TLangKeys.TEInvSeries.TitlePlural, 'e-Document Series');
  if Assigned(actsls_einv_vehicles) then
    actsls_einv_vehicles.Caption := TLocalizationManager.Translate(TLangKeys.TEInvVehicle.TitlePlural, 'Vehicles / Trailers');
  if Assigned(actsls_einv_drivers) then
    actsls_einv_drivers.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDriver.TitlePlural, 'Drivers');
  if Assigned(actstk_gtips) then
    actstk_gtips.Caption := TLocalizationManager.Translate(TLangKeys.TEInvGtip.TitlePlural, 'GTIP Codes');
  if Assigned(mnisls_einv_settings) then
    mnisls_einv_settings.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.MenuEInvSettings, 'e-Document Settings');
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
      TLocalizationManager.Translate(TLangKeys.TDashboard.NavNoResult, 'No matching screen'),
      TLocalizationManager.Translate(TLangKeys.TDashboard.NavFavorites, 'Favorites'),
      TLocalizationManager.Translate(TLangKeys.TDashboard.NavRecent, 'Recently Used'),
      TLocalizationManager.Translate(TLangKeys.TDashboard.NavAddFavorite, 'Add to Favorites'),
      TLocalizationManager.Translate(TLangKeys.TDashboard.NavRemoveFavorite, 'Remove from Favorites'));
  if Assigned(FBtnNavToggle) then
    FBtnNavToggle.Hint := TLocalizationManager.Translate(TLangKeys.TDashboard.NavToggleHint, 'Show / hide menu');
  if Assigned(FPages) then
  begin
    FHomeSheet.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.TabHome, 'Home');
    FMniTabDetach.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.TabDetach, 'Show in Separate Window');
    FMniTabClose.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.Close, 'Close');
    FChkTabbed.Caption := TLocalizationManager.Translate(TLangKeys.TDashboard.TabbedView, 'Tabbed View');
    FChkTabbed.Hint := TLocalizationManager.Translate(TLangKeys.TDashboard.TabbedViewHint,
      'On: screens open as tabs in the main window. Off: every screen opens in its own window.');
    Canvas.Font.Assign(FChkTabbed.Font);
    FChkTabbed.Width := Canvas.TextWidth(FChkTabbed.Caption) + 24;
  end;

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
  BuildTabs;
  // Ctrl+K her ekrandan (komut paleti)
  FAppEvents := TApplicationEvents.Create(Self);
  FAppEvents.OnShortCut := AppShortCut;
  // yakalanmayan hatalar: PostgreSQL constraint hataları anlaşılır mesaja çevrilir
  FAppEvents.OnException := AppException;
  FAppEvents.OnIdle := AppIdle;

  FAuditTimer := TTimer.Create(Self);
  FAuditTimer.Interval := 60 * 1000;
  FAuditTimer.OnTimer := AuditTimerTimer;
  FAuditTimer.Enabled := True;
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
  // sekmedeki ekranın işlemediği Esc uygulama kapatmayı sormasın
  if Assigned(Screen.ActiveControl) and (GetParentForm(Screen.ActiveControl, False) <> Self) then
    Exit;
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
  StartExchangeRateUpdate;

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
      // kaldırılan ekranın satırı pasif kalır (kodlar kalıcı): yalnız aktif satırda action eksikliği hata
      if LItem.IsActive then
        GLogger.ErrorFmt('Menü ekranının action''ı yok: %d %s', [LItem.MenuCode, LItem.ActionName]);
      Continue;
    end;
    FActionCodes.AddOrSetValue(LItem.ActionName, LItem.MenuCode);
    // ResetSession butonları doğrudan pasif yapabiliyor; değer değişmezse action istemcilere yaymaz.
    // Pasif menü satırının (ya da pasif klasörün altındaki) ekranı da kapalı.
    TAction(LComp).Enabled := not (LItem.Allowed and LItem.IsActive);
    TAction(LComp).Enabled := LItem.Allowed and LItem.IsActive;
  end;

  if Assigned(FNav) then
    FNav.SetItems(LItems);
end;

procedure TfrmDashboard.SetSession;
begin
  // sol menü genişliği / görünürlüğü / açık klasörler: oturum başında bir kez (menü yüklenmeden önce)
  if not FNavStateLoaded then
    LoadNavState;
  ResetSession(pnlMain);
  ApplyActionPermissions;
  // ana ekran göstergeleri: yalnız okuma yetkisi olan modüller (servis filtreler)
  LoadKpis;
  // önceki oturumlardan / girişten kalan işlem geçmişi
  FlushAudit;
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
  FNav.OnToggleFavorite := NavToggleFavorite;

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

// Ctrl+K: ana ekrandayken sol menünün araması (menü gizliyse palet), başka bir ekrandayken komut paleti.
// Modal pencere (seçim listesi, mesaj, paletin kendisi) açıkken kullanılmaz.
procedure TfrmDashboard.AppException(Sender: TObject; E: Exception);
var
  LMsg: string;
begin
  if E is EAbort then
    Exit;
  LMsg := TDbErrorTranslator.Translate(E);
  if LMsg = '' then
  begin
    Application.ShowException(E);
    Exit;
  end;
  GLogger.ErrorFmt('%s: %s', [E.ClassName, E.Message]);
  TThsDialogHelper.CustomMsgDlg(LMsg, mtError, [mbOK],
    [TLocalizationManager.Translate(TLangKeys.TGeneral.OK, 'Ok')], mbOK,
    TLocalizationManager.Translate(TLangKeys.TDbError.Title, 'Database Rule'));
end;

procedure TfrmDashboard.AppShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  if (Msg.CharCode <> Ord('K')) or (GetKeyState(VK_CONTROL) >= 0) or (GetKeyState(VK_SHIFT) < 0)
    or (GetKeyState(VK_MENU) < 0) then
    Exit;
  if not FNavStateLoaded or not Assigned(FNav) then
    Exit;
  if Assigned(Screen.ActiveForm) and (fsModal in Screen.ActiveForm.FormState) then
    Exit;
  Handled := True;
  if (Screen.ActiveForm = Self) and FNav.Visible then
    FNav.FocusSearch
  else
    ShowCommandPalette;
end;

procedure TfrmDashboard.ShowCommandPalette;
var
  LItem: TSysMenuItem;
  LOwner: TComponent;
begin
  LOwner := Screen.ActiveForm;
  if LOwner = nil then
    LOwner := Self;
  if TNavCommandPalette.Execute(LOwner, FNav,
    TLocalizationManager.Translate(TLangKeys.TDashboard.NavPaletteHint, 'Type the name or code of the screen to open — Enter opens, Esc closes'),
    TLocalizationManager.Translate(TLangKeys.TDashboard.NavNoResult, 'No matching screen'), LItem) then
    NavOpenItem(LItem);
end;

procedure TfrmDashboard.LoadNavState;
var
  LSvc: TSysUserSettingService;
  LValues: TDictionary<string, string>;
  LValue, LPart: string;
  LKeys: TArray<Integer>;
begin
  if not TAppContext.IsInitialized or not TAppContext.Instance.IsAuthenticated or not Assigned(FNav) then
    Exit;
  FNavStateLoaded := True;
  try
    LSvc := TSysUserSettingService.Create;
    try
      LValues := LSvc.GetValues('nav.');
      try
        if LValues.TryGetValue(USER_SETTING_NAV_WIDTH, LValue) then
          FNav.Width := EnsureRange(StrToIntDef(LValue, FNav.Width), 180, 600);
        if LValues.TryGetValue(USER_SETTING_NAV_EXPANDED, LValue) then
        begin
          LKeys := [];
          for LPart in LValue.Split([','], TStringSplitOptions.ExcludeEmpty) do
            if StrToIntDef(LPart, 0) > 0 then
              LKeys := LKeys + [StrToInt(LPart)];
          FNav.ExpandedKeys := LKeys;
        end;
        if LValues.TryGetValue(USER_SETTING_NAV_VISIBLE, LValue) and (LValue = '0') and FNav.Visible then
          NavToggleClick(nil);
        if LValues.TryGetValue(USER_SETTING_NAV_TABBED, LValue) then
          SetTabbed(LValue <> '0');
      finally
        LValues.Free;
      end;
    finally
      LSvc.Free;
    end;
  except
    on E: Exception do
      GLogger.ErrorFmt('Menü ayarları okunamadı: %s', [E.Message]);
  end;
end;

procedure TfrmDashboard.SaveNavState;
var
  LSvc: TSysUserSettingService;
  LKeys: TArray<Integer>;
  LText: string;
  LKey: Integer;
begin
  if not FNavStateLoaded or not Assigned(FNav) then
    Exit;
  try
    LSvc := TSysUserSettingService.Create;
    try
      LSvc.SetValue(USER_SETTING_NAV_VISIBLE, IfThen(FNav.Visible, '1', '0'));
      LSvc.SetValue(USER_SETTING_NAV_WIDTH, IntToStr(FNav.Width));
      LSvc.SetValue(USER_SETTING_NAV_TABBED, IfThen(FTabbed, '1', '0'));
      LKeys := FNav.ExpandedKeys;
      LText := '';
      for LKey in LKeys do
        LText := LText + IfThen(LText = '', '', ',') + IntToStr(LKey);
      LSvc.SetValue(USER_SETTING_NAV_EXPANDED, LText);
    finally
      LSvc.Free;
    end;
  except
    on E: Exception do
      GLogger.ErrorFmt('Menü ayarları kaydedilemedi: %s', [E.Message]);
  end;
end;

// Uygulama kapanırken (ana form) sol menü durumu kaydedilir: bağlantı form yok edilmeden önce kapanır
procedure TfrmDashboard.DoClose(var Action: TCloseAction);
begin
  inherited;
  if Action <> caNone then
  begin
    SaveNavState;
    FlushAudit;
  end;
end;

{ ---------------------------------------------------------------- Sekmeli ekranlar }

// Ana ekran (göstergeler) ilk, kapatılamayan sekme; liste ekranları TfrmGridBase.Show -> GFormHost ile eklenir
procedure TfrmDashboard.BuildTabs;
begin
  if Assigned(FPages) then
    Exit;

  FDocked := TDictionary<TForm, TDockedForm>.Create;

  FPages := TPageControl.Create(Self);
  FPages.Parent := pnlMain;
  FPages.Align := alClient;
  FPages.OnChange := TabsChange;
  FPages.OnMouseUp := TabsMouseUp;

  FHomeSheet := TTabSheet.Create(Self);
  FHomeSheet.PageControl := FPages;

  FTabPopup := TPopupMenu.Create(Self);
  FMniTabDetach := TMenuItem.Create(FTabPopup);
  FMniTabDetach.OnClick := TabDetachClick;
  FTabPopup.Items.Add(FMniTabDetach);
  FMniTabClose := TMenuItem.Create(FTabPopup);
  FMniTabClose.OnClick := TabCloseClick;
  FTabPopup.Items.Add(FMniTabClose);

  FChkTabbed := TCheckBox.Create(Self);
  FChkTabbed.Parent := pnlToolbar;
  FChkTabbed.Align := alRight;
  FChkTabbed.AlignWithMargins := True;
  FChkTabbed.Margins.SetBounds(4, 6, 12, 6);
  FChkTabbed.ShowHint := True;
  FChkTabbed.Checked := True;
  FChkTabbed.OnClick := ChkTabbedClick;

  FTabbed := True;
  GFormHost := HostForm;
end;

function TfrmDashboard.HostForm(AForm: TForm): Boolean;
begin
  Result := FTabbed and Assigned(FDocked) and Visible and not (csDestroying in ComponentState);
  if Result then
    DockForm(AForm);
end;

procedure TfrmDashboard.DockForm(AForm: TForm);
var
  LInfo: TDockedForm;
  LWasVisible: Boolean;
  LOnShow: TNotifyEvent;
begin
  LInfo.BorderStyle := AForm.BorderStyle;
  LInfo.Height := AForm.Height;
  LInfo.MinWidth := AForm.Constraints.MinWidth;
  LInfo.MinHeight := AForm.Constraints.MinHeight;
  LInfo.MaxWidth := AForm.Constraints.MaxWidth;
  LInfo.MaxHeight := AForm.Constraints.MaxHeight;
  LInfo.Sheet := TTabSheet.Create(Self);
  LInfo.Sheet.PageControl := FPages;
  LInfo.Sheet.Caption := AForm.Caption;
  FDocked.Add(AForm, LInfo);
  AForm.FreeNotification(Self);

  // açık pencere sekmeye alınırken pencere yeniden oluşur: OnShow (sorgu / alt bilgi kurulumu) tekrar çalışmasın
  LWasVisible := AForm.Visible;
  LOnShow := AForm.OnShow;
  if LWasVisible then
    AForm.OnShow := nil;
  try
    // pencere boyut sınırları sekmede geçerli değil (sekme formdan küçük olabilir)
    AForm.Constraints.MinWidth := 0;
    AForm.Constraints.MinHeight := 0;
    AForm.Constraints.MaxWidth := 0;
    AForm.Constraints.MaxHeight := 0;
    AForm.Position := poDesigned;
    AForm.BorderStyle := bsNone;
    AForm.Parent := LInfo.Sheet;
    AForm.Align := alClient;
  finally
    AForm.OnShow := LOnShow;
  end;
  // sekme Show'dan önce etkin olmalı: FormShow'daki odak (ActiveControl / SetFocus) görünmeyen sekmede hata verir
  FPages.ActivePage := LInfo.Sheet;

  if not LWasVisible then
  begin
    // sekmedeki form etkinleşmez (aktif form ana ekran kalır): ekran kodu burada verilir
    TScreenCodes.AttachTo(AForm);
    AForm.Show;
  end;
  // başlık FormShow'da (dil) belli olur
  LInfo.Sheet.Caption := AForm.Caption;
  TabsChange(FPages);
end;

procedure TfrmDashboard.UndockForm(AForm: TForm);
var
  LInfo: TDockedForm;
  LOnShow: TNotifyEvent;
begin
  if not FDocked.TryGetValue(AForm, LInfo) then
    Exit;
  FDocked.Remove(AForm);

  LOnShow := AForm.OnShow;
  AForm.OnShow := nil;
  try
    AForm.Align := alNone;
    AForm.Parent := nil;
    AForm.BorderStyle := LInfo.BorderStyle;
    AForm.Constraints.MinWidth := LInfo.MinWidth;
    AForm.Constraints.MinHeight := LInfo.MinHeight;
    AForm.Constraints.MaxWidth := LInfo.MaxWidth;
    AForm.Constraints.MaxHeight := LInfo.MaxHeight;
    AForm.Height := Max(LInfo.Height, LInfo.MinHeight);
    if AForm is TfrmGridBase then
      TfrmGridBase(AForm).AdjustFormWidth;
    AForm.SetBounds(Left + (Width - AForm.Width) div 2, Top + (Height - AForm.Height) div 2, AForm.Width, AForm.Height);
  finally
    AForm.OnShow := LOnShow;
  end;
  LInfo.Sheet.Free;
  AForm.BringToFront;
end;

procedure TfrmDashboard.SetTabbed(AValue: Boolean);
var
  LForms: TArray<TForm>;
  LForm: TForm;
  I: Integer;
begin
  FTabbed := AValue;
  FChkTabbed.Checked := AValue;
  if AValue then
  begin
    // açık liste ekranları sekmeye alınır (seçim listeleri / modal pencereler hariç)
    LForms := [];
    for I := 0 to Screen.FormCount - 1 do
      if (Screen.Forms[I] is TfrmGridBase) and Screen.Forms[I].Visible
        and not (fsModal in Screen.Forms[I].FormState) and not TfrmGridBase(Screen.Forms[I]).IsHelper
        and not FDocked.ContainsKey(Screen.Forms[I]) then
        LForms := LForms + [Screen.Forms[I]];
    for LForm in LForms do
      DockForm(LForm);
  end
  else
    for LForm in FDocked.Keys.ToArray do
      UndockForm(LForm);
  // ayrı pencere modunda tek sayfa (ana ekran) sekme başlığı olmadan gösterilir
  FHomeSheet.TabVisible := AValue;
  if not AValue then
    FPages.ActivePage := FHomeSheet;
end;

function TfrmDashboard.DockedFormOf(ASheet: TTabSheet): TForm;
var
  LPair: TPair<TForm, TDockedForm>;
begin
  Result := nil;
  if Assigned(FDocked) then
    for LPair in FDocked do
      if LPair.Value.Sheet = ASheet then
        Exit(LPair.Key);
end;

procedure TfrmDashboard.TabsChange(Sender: TObject);
var
  LForm: TForm;
begin
  LForm := DockedFormOf(FPages.ActivePage);
  if Assigned(LForm) and LForm.CanFocus then
    LForm.SetFocus;
end;

procedure TfrmDashboard.TabsMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
  LPt: TPoint;
begin
  if Button <> mbRight then
    Exit;
  LIndex := FPages.IndexOfTabAt(X, Y);
  if (LIndex < 0) or (FPages.Pages[LIndex] = FHomeSheet) then
    Exit;
  FPages.ActivePageIndex := LIndex;
  TabsChange(FPages);
  LPt.X := X;
  LPt.Y := Y;
  LPt := FPages.ClientToScreen(LPt);
  FTabPopup.Popup(LPt.X, LPt.Y);
end;

procedure TfrmDashboard.TabCloseClick(Sender: TObject);
var
  LForm: TForm;
begin
  LForm := DockedFormOf(FPages.ActivePage);
  if Assigned(LForm) then
    LForm.Close;
end;

procedure TfrmDashboard.TabDetachClick(Sender: TObject);
var
  LForm: TForm;
begin
  LForm := DockedFormOf(FPages.ActivePage);
  if Assigned(LForm) then
    UndockForm(LForm);
end;

procedure TfrmDashboard.ChkTabbedClick(Sender: TObject);
begin
  if FChkTabbed.Checked <> FTabbed then
    SetTabbed(FChkTabbed.Checked);
end;

// Başlık sonradan değişebilir (ekran kodu, dil, sabit filtre adı): sekme başlığı formu izler
procedure TfrmDashboard.AppIdle(Sender: TObject; var Done: Boolean);
var
  LPair: TPair<TForm, TDockedForm>;
begin
  if Assigned(FDocked) then
    for LPair in FDocked do
      if LPair.Value.Sheet.Caption <> LPair.Key.Caption then
        LPair.Value.Sheet.Caption := LPair.Key.Caption;
end;

// Sekmedeki form kapanınca (caFree) sekmesi de kaldırılır
procedure TfrmDashboard.Notification(AComponent: TComponent; Operation: TOperation);
var
  LInfo: TDockedForm;
begin
  inherited;
  if (Operation = opRemove) and Assigned(FDocked) and (AComponent is TForm)
    and FDocked.TryGetValue(TForm(AComponent), LInfo) then
  begin
    FDocked.Remove(TForm(AComponent));
    if not (csDestroying in ComponentState) then
      LInfo.Sheet.Free;
  end;
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

// Favori kullanıcının kendi tercihi (sys_user_menu); önce kaydedilir, sonra ağaç güncellenir
procedure TfrmDashboard.NavToggleFavorite(const AItem: TSysMenuItem; AFavorite: Boolean);
var
  LSvc: TSysMenuService;
begin
  LSvc := TSysMenuService.Create;
  try
    LSvc.SetFavorite(AItem.MenuCode, AFavorite);
  finally
    LSvc.Free;
  end;
  FNav.SetFavorite(AItem.MenuCode, AFavorite);
end;

// Her dashboard action'ı (ana menü, sol ağaç, gösterge kartı) buradan geçer: sys_menu'daki ekranlar
// kodlarıyla açılır, böylece açılan formun başlığına ekran kodu eklenir.
procedure TfrmDashboard.ActionListExecute(Action: TBasicAction; var Handled: Boolean);
var
  LCode: Integer;
  LSvc: TSysMenuService;
begin
  if not Assigned(FActionCodes) or not FActionCodes.TryGetValue(Action.Name, LCode) or not Assigned(Action.OnExecute) then
    Exit;
  Handled := True;
  TScreenCodes.RunWithCode(LCode,
    procedure
    begin
      Action.OnExecute(Action);
    end);

  // son kullanılanlar: kaydedilemezse ekran yine açık kalır, yalnız loglanır
  try
    LSvc := TSysMenuService.Create;
    try
      LSvc.RegisterOpen(LCode);
    finally
      LSvc.Free;
    end;
  except
    on E: Exception do
      GLogger.ErrorFmt('Son kullanılan ekran kaydedilemedi (%d): %s', [LCode, E.Message]);
  end;
  if Assigned(FNav) then
    FNav.MarkOpened(LCode);
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
  else if AKey = KPI_SLS_ORDERS_MONTH then LName := 'actsls_orders'
  else if AKey = KPI_SLS_OFFERS_MONTH then LName := 'actsls_offers'
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
  FKpiScroll.Parent := FHomeSheet;
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
  if not Assigned(FKpiScroll) or not FKpiScroll.Showing then
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
  if Application.Active and (Screen.ActiveForm = Self) and (FPages.ActivePage = FHomeSheet) then
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
