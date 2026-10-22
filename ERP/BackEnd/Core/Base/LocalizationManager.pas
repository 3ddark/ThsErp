unit LocalizationManager;

interface

uses
  System.SysUtils, System.JSON, System.IOUtils, System.Generics.Collections,
  System.Classes;

type
  TLangKeys = record
  public
    type
      TValidation = record
        const Required = 'validation.required';
        const MinLength = 'validation.minlength';
        const MaxLength = 'validation.maxlength';
        const Range = 'validation.range';
        const Email = 'validation.email';
        const RegEx = 'validation.regex';
        const RequiredFieldsEmpty = 'validation.required_fields_empty';
        const NegativeValueNotAllowed = 'validation.negative_value_not_allowed';
        const MustBePositive = 'validation.must_be_positive';
        const VatRateUndefined = 'validation.vat_rate_undefined';
      end;

      TGeneral = record
        const AddRecord = 'btn.add_record';
        const Save = 'btn.save';
        const Confirm = 'btn.confirm';
        const Update = 'btn.update';
        const Delete = 'btn.delete';
        const DeleteRecord = 'btn.delete_record';
        const Close = 'btn.close';
        const Cancel = 'btn.cancel';
        const Yes = 'btn.yes';
        const No = 'btn.no';
        const OK = 'btn.ok';
        const Confirmation = 'btn.confirmation';
        const Login = 'btn.login';

        const FilterHint = 'grid.filter_hint';
        const RecordsCount = 'grid.records_count';
        const Period = 'grid.period';
        const KeyF6 = 'grid.key_f6';
        const KeyF7 = 'grid.key_f7';
        const KeyF11 = 'grid.key_f11';
        const PageFirst = 'grid.page_first';
        const PagePrevious = 'grid.page_previous';
        const PageNext = 'grid.page_next';
        const PageLast = 'grid.page_last';
        const PageNumber = 'grid.page_number';
        const PageSize = 'grid.page_size';
        const PageAll = 'grid.page_all';
        const QuickAll = 'grid.quick_all';
        const PageInfo = 'grid.page_info';
      end;

      TPopupMenu = record
        const Preview = 'popup.preview';
        const Duplicate = 'popup.duplicate';
        const Filter = 'popup.filter';
        const FilterExclude = 'popup.filter_exclude';
        const FilterBack = 'popup.filter_back';
        const FilterRemove = 'popup.filter_remove';
        const ExportExcel = 'popup.export_excel';
        const ExportCsv = 'popup.export_csv';
        const Print = 'popup.print';
        const RemoveSort = 'popup.remove_sort';
      end;

      TDetailForm = record
        const LineAdd = 'detail_form.line_add';
        const LineEdit = 'detail_form.line_edit';
        const LineDelete = 'detail_form.line_delete';
        const MsgDeleteLine = 'detail_form.msg_delete_line';
        const CsvFilter = 'detail_form.csv_filter';
        const TabLines = 'detail_form.tab_lines';
        const HeaderHide = 'detail_form.header_hide';
        const HeaderShow = 'detail_form.header_show';
        const LineNoUnique = 'detail_form.line_no_unique';
      end;

      // Belge adresi düzenleyici (Detail.Address)
      TDocumentAddress = record
        const BtnFromAccount = 'document_address.btn_from_account';
        const BtnClear = 'document_address.btn_clear';
        const BtnFromBilling = 'document_address.btn_from_billing';
      end;

      TUnitOfWork = record
        const NotInitialized = 'unitofwork.not_initialized';
        const ConstructorNotFound = 'unitofwork.constructor_not_found';
      end;

      TMessage = record
        const ConfirmDelete = 'msg.confirm_delete';
        const ConfirmUpdate = 'msg.confirm_update_record';
        const UserConfirmationTitle = 'msg.title.user_confirmation';
        const ActiveTransactionExist = 'msg.active_transaction_exist';
        const InformationTitle = 'msg.title.information';
        const ConfirmCloseWindow = 'msg.confirm_close_window';
        const RecordDeletedWhileReview = 'msg.record_deleted_while_review';
        const MustContainOnlyOneRecord = 'msg.must_contain_only_one_record';
        const ValidationErrorTitle = 'msg.title.validation_error';
        const UpdateConfirmation = 'msg.title.update_confirmation';
        const ConfirmExitApp = 'msg.confirm_exit_app';
        const NewVersionAvailable = 'msg.new_version_available';
        const UpdateRecommended = 'msg.update_recommended';
        const UserUpdateConfirmation = 'msg.title.user_update_confirmation';
        const WarningTitle = 'msg.title.warning';
        const FinishEditingBeforeLangChange = 'msg.finish_editing_before_lang_change';
        const RecordNotFoundD = 'Record not found: %d';
        const RecordNotFoundS = 'Record not found: %s';
        const UnknownPermissionType = 'Unknown PermissionType: %d';
        const DataIsNotLoaded = 'Data is not loaded';
      end;

      TLogin = record
        const UserNotFound = 'login.user_not_found';
        const UserInactive = 'login.user_inactive';
        const InvalidPassword = 'login.invalid_password';
        const UpdateAvailable = 'login.update_available';
        const UpdateTitle = 'login.update_title';
        const WindowTitle = 'login.window_title';
        const Username = 'login.username';
        const Password = 'login.password';
        const DbHost = 'login.db_host';
        const DbHostHint = 'login.db_host_hint';
        const DbName = 'login.db_name';
        const DbPort = 'login.db_port';
        const SaveSettings = 'login.save_settings';
        const DbUser = 'login.db_user';
        const DbPassword = 'login.db_password';
        const ProcessId = 'login.process_id';
        const IpAddress = 'login.ip_address';
        const Version = 'login.version';
        const Theme = 'login.theme';
        const Language = 'login.language';
      end;

      TSecurity = record
        const InvalidOperator = 'security.invalid_operator';
        const InvalidFieldName = 'security.invalid_field_name';
        const UserNotAuthenticated = 'security.user_not_authenticated';
        const AccessDenied = 'security.access_denied';
        const AccessDeniedCode = 'security.access_denied_code';
      end;

      TDashboard = record
        const MenuLanguage = 'dashboard.menu.language';
        const MenuLanguageChanger = 'dashboard.menu.language_changer';
        const MenuSystem = 'dashboard.menu.system';
        const MenuPurchasing = 'dashboard.menu.purchasing';
        const MenuSales = 'dashboard.menu.sales';
        const MenuAccounting = 'dashboard.menu.accounting';
        const MenuStock = 'dashboard.menu.stock';
        const MenuProduction = 'dashboard.menu.production';
        const MenuFinance = 'dashboard.menu.finance';
        const MenuPersonnel = 'dashboard.menu.personnel';
        const MenuAbout = 'dashboard.menu.about';
        const MenuSettings = 'dashboard.menu.settings';
        const NavSearchHint = 'dashboard.nav.search_hint';
        const NavNoResult = 'dashboard.nav.no_result';
        const NavToggleHint = 'dashboard.nav.toggle_hint';
        const NavFavorites = 'dashboard.nav.favorites';
        const NavRecent = 'dashboard.nav.recent';
        const NavAddFavorite = 'dashboard.nav.add_favorite';
        const NavRemoveFavorite = 'dashboard.nav.remove_favorite';
        const ActionMenus = 'dashboard.action.menus';
        const ActionAuditLog = 'dashboard.action.audit_log';
        const NavPaletteHint = 'dashboard.nav.palette_hint';
        const TabHome = 'dashboard.tab.home';
        const TabbedView = 'dashboard.tab.tabbed_view';
        const TabbedViewHint = 'dashboard.tab.tabbed_view_hint';
        const TabDetach = 'dashboard.tab.detach';
        const MenuOffers = 'dashboard.menu.offers';
        const MenuOrders = 'dashboard.menu.orders';
        const MenuWaybills = 'dashboard.menu.waybills';
        const MenuInvoices = 'dashboard.menu.invoices';
        const MenuChangePassword = 'dashboard.menu.change_password';
        const MenuRefreshPermissions = 'dashboard.menu.refresh_permissions';
        const MsgPermissionsRefreshed = 'dashboard.msg.permissions_refreshed';
        const MsgUserInactive = 'dashboard.msg.user_inactive';
        const MenuDbMonitor = 'dashboard.menu.db_monitor';
        const MenuDbBackup = 'dashboard.menu.db_backup';
        const MenuUpdate = 'dashboard.menu.update';

        const ActionUsers = 'dashboard.action.users';
        const ActionAccessRights = 'dashboard.action.access_rights';
        const ActionAppSettings = 'dashboard.action.app_settings';
        const ActionGridColumns = 'dashboard.action.grid_columns';
        const ActionGridFilters = 'dashboard.action.grid_filters';
        const ActionGridSorts = 'dashboard.action.grid_sorts';
        const ActionPermissionGroups = 'dashboard.action.permission_groups';
        const ActionPermissions = 'dashboard.action.permissions';
        const ActionCountries = 'dashboard.action.countries';
        const ActionCities = 'dashboard.action.cities';
        const ActionDecimalPlace = 'dashboard.action.decimal_place';
        const ActionRegions = 'dashboard.action.regions';
        const ActionUnitTypes = 'dashboard.action.unit_types';
        const ActionUnits = 'dashboard.action.units';
        const ActionCurrencies = 'dashboard.action.currencies';
        const ActionLanguages = 'dashboard.action.languages';
        const TabGeneral = 'dashboard.tab.general';
        const TabSales = 'dashboard.tab.sales';
        const TabStock = 'dashboard.tab.stock';
        const TabAccounts = 'dashboard.tab.accounts';
        const TabEmployee = 'dashboard.tab.personnel';
        const TabRecipes = 'dashboard.tab.recipes';
        const TabAccounting = 'dashboard.tab.accounting';
        const BtnOffers = 'dashboard.btn.offers';
        const BtnOrders = 'dashboard.btn.orders';
        const BtnOfferReports = 'dashboard.btn.offer_reports';
        const BtnOrderReports = 'dashboard.btn.order_reports';
        const BtnRegion = 'dashboard.btn.region';
        const BtnBanks = 'dashboard.btn.banks';
        const BtnBankBranches = 'dashboard.btn.bank_branches';
        const BtnAccountGroups = 'dashboard.btn.account_groups';
        const BtnAccountPlans = 'dashboard.btn.account_plans';
        const BtnSubAccount = 'dashboard.btn.sub_account';
        const BtnAccountCard = 'dashboard.btn.account_card';
        const BtnTaxRates = 'dashboard.btn.tax_rates';
        const BtnRecipes = 'dashboard.btn.recipes';
        const BtnLaborCosts = 'dashboard.btn.labor_costs';
        const BtnPacketRawMaterials = 'dashboard.btn.packet_raw_materials';
        const ActionPermissionTemplates = 'dashboard.action.permission_templates';
        const ActionPermissionTemplateRights = 'dashboard.action.permission_template_rights';
        const ActionUserPermissionTemplates = 'dashboard.action.user_permission_templates';
        const KpiSecFinance = 'dashboard.kpi.sec_finance';
        const KpiSecPurchasing = 'dashboard.kpi.sec_purchasing';
        const KpiSecSales = 'dashboard.kpi.sec_sales';
        const KpiSecStock = 'dashboard.kpi.sec_stock';
        const KpiSecAccounts = 'dashboard.kpi.sec_accounts';
        const KpiSecGeneral = 'dashboard.kpi.sec_general';
        const KpiFxRates = 'dashboard.kpi.fx_rates';
        const KpiCashBalance = 'dashboard.kpi.cash_balance';
        const KpiBankBalance = 'dashboard.kpi.bank_balance';
        const KpiMoneyToday = 'dashboard.kpi.money_today';
        const KpiChequesReceivable = 'dashboard.kpi.cheques_receivable';
        const KpiChequesPayable = 'dashboard.kpi.cheques_payable';
        const KpiPosMonth = 'dashboard.kpi.pos_month';
        const KpiCardDebt = 'dashboard.kpi.card_debt';
        const KpiPurRequests = 'dashboard.kpi.pur_requests';
        const KpiPurOrdersOpen = 'dashboard.kpi.pur_orders_open';
        const KpiPurOrdersMonth = 'dashboard.kpi.pur_orders_month';
        const KpiPurReceiptsMonth = 'dashboard.kpi.pur_receipts_month';
        const KpiPurInvoicesMonth = 'dashboard.kpi.pur_invoices_month';
        const KpiSlsOrdersMonth = 'dashboard.kpi.sls_orders_month';
        const KpiSlsOffersMonth = 'dashboard.kpi.sls_offers_month';
        const KpiStockCritical = 'dashboard.kpi.stock_critical';
        const KpiStockTx = 'dashboard.kpi.stock_tx';
        const KpiStockCards = 'dashboard.kpi.stock_cards';
        const KpiAccReceivable = 'dashboard.kpi.acc_receivable';
        const KpiAccPayable = 'dashboard.kpi.acc_payable';
        const KpiAccounts = 'dashboard.kpi.accounts';
        const KpiEmployees = 'dashboard.kpi.employees';
        const KpiUsers = 'dashboard.kpi.users';
        const KpiFmtRateDate = 'dashboard.kpi.fmt_rate_date';
        const KpiFmtRateOld = 'dashboard.kpi.fmt_rate_old';
        const KpiFmtAccounts = 'dashboard.kpi.fmt_accounts';
        const KpiFmtMoneyToday = 'dashboard.kpi.fmt_money_today';
        const KpiFmtDocsDue = 'dashboard.kpi.fmt_docs_due';
        const KpiFmtMonthTx = 'dashboard.kpi.fmt_month_tx';
        const KpiFmtCards = 'dashboard.kpi.fmt_cards';
        const KpiFmtDrafts = 'dashboard.kpi.fmt_drafts';
        const KpiFmtRequests = 'dashboard.kpi.fmt_requests';
        const KpiFmtOrdersOpen = 'dashboard.kpi.fmt_orders_open';
        const KpiFmtCount = 'dashboard.kpi.fmt_count';
        const KpiFmtToday = 'dashboard.kpi.fmt_today';
        const KpiFmtInvoicesDue = 'dashboard.kpi.fmt_invoices_due';
        const KpiFmtNegative = 'dashboard.kpi.fmt_negative';
        const KpiFmtThisMonth = 'dashboard.kpi.fmt_this_month';
        const KpiFmtSellable = 'dashboard.kpi.fmt_sellable';
        const KpiFmtPassive = 'dashboard.kpi.fmt_passive';
        const KpiFmtTotal = 'dashboard.kpi.fmt_total';
        const KpiNoRecord = 'dashboard.kpi.no_record';
        const KpiNoData = 'dashboard.kpi.no_data';
        const KpiRefresh = 'dashboard.kpi.refresh';
        const KpiLastUpdate = 'dashboard.kpi.last_update';
        const KpiOpenHint = 'dashboard.kpi.open_hint';
        const KpiSecOverview = 'dashboard.kpi.sec_overview';
        const KpiWelcome = 'dashboard.kpi.welcome';
        const KpiAllGood = 'dashboard.kpi.all_good';
        const KpiFmtCritical = 'dashboard.kpi.fmt_critical';
        const KpiFmtWarnings = 'dashboard.kpi.fmt_warnings';
        const KpiBadgeInfo = 'dashboard.kpi.badge_info';
        const KpiBadgeWarning = 'dashboard.kpi.badge_warning';
        const KpiBadgeDanger = 'dashboard.kpi.badge_danger';
        const KpiFmtPercent = 'dashboard.kpi.fmt_percent';
        const KpiChartMoneyFlow = 'dashboard.kpi.chart_money_flow';
        const KpiChartChequeDue = 'dashboard.kpi.chart_cheque_due';
        const KpiChartStockFlow = 'dashboard.kpi.chart_stock_flow';
        const KpiChartFxTrend = 'dashboard.kpi.chart_fx_trend';
        const KpiChartSubMoney = 'dashboard.kpi.chart_sub_money';
        const KpiChartSubCheque = 'dashboard.kpi.chart_sub_cheque';
        const KpiChartSubStock = 'dashboard.kpi.chart_sub_stock';
        const KpiChartSubFx = 'dashboard.kpi.chart_sub_fx';
        const KpiChartEmpty = 'dashboard.kpi.chart_empty';
        const KpiLegendIn = 'dashboard.kpi.legend_in';
        const KpiLegendOut = 'dashboard.kpi.legend_out';
        const KpiLegendReceived = 'dashboard.kpi.legend_received';
        const KpiLegendGiven = 'dashboard.kpi.legend_given';
        const MenuEInvSettings = 'dashboard.menu.einv_settings';
        const ActionAccVouchers = 'dashboard.action.acc_vouchers';
      end;

      TGridColumn = record
        const ColId = 'grid_column.col_id';
      end;

      //System Module
      TSysAccessRight = record
        const TitlePlural = 'sys_access_right.title_plural';
        const TitleSingular = 'sys_access_right.title_singular';
        const ColSysPermissionId = 'sys_access_right.col_sys_permission_id';
        const ColRead = 'sys_access_right.col_is_read';
        const ColAdd = 'sys_access_right.col_is_add';
        const ColUpdate = 'sys_access_right.col_is_update';
        const ColDelete = 'sys_access_right.col_is_delete';
        const ColSpecial = 'sys_access_right.col_is_special';
        const ColSysUserId = 'sys_access_right.col_sys_user_id';

        const MenuCopUserRights = 'sys_access_right.popup.copy_user_rights';

        const MsgSelectSourceUser = 'sys_access_right.msg.select_source_user';
        const MsgSelectTargetUser = 'sys_access_right.msg.select_target_user';
        const MsgSourceTargetSame = 'sys_access_right.msg.source_target_same';
        const MsgConfirmCopy = 'sys_access_right.msg.confirm_copy';
        const MsgCopySuccess = 'sys_access_right.msg.copy_success';
        const MsgCopyError = 'sys_access_right.msg.copy_error';
        const MsgNoAccessRightToRead = 'sys_access_right.msg.no_access_right_to_read';
        const MsgNoAccessRightToAdd = 'sys_access_right.msg.no_access_right_to_add';
        const MsgNoAccessRightToUpdate = 'sys_access_right.msg.no_access_right_to_update';
        const MsgNoAccessRightToDelete = 'sys_access_right.msg.no_access_right_to_delete';
        const MsgNoAccessRightToSpecial = 'sys_access_right.msg.no_access_right_to_special';
        const MsgPermissionUserUnique = 'sys_access_right.msg.permission_user_unique';
        const ColDenyRead = 'sys_access_right.col_deny_read';
        const ColDenyAdd = 'sys_access_right.col_deny_add';
        const ColDenyUpdate = 'sys_access_right.col_deny_update';
        const ColDenyDelete = 'sys_access_right.col_deny_delete';
        const ColDenySpecial = 'sys_access_right.col_deny_special';
        const LblGrant = 'sys_access_right.lbl_grant';
        const LblDeny = 'sys_access_right.lbl_deny';
        const MsgGrantDenyConflict = 'sys_access_right.msg.grant_deny_conflict';
      end;

      TSysAddress = record
        const TitlePlural = 'sys_address.title_plural';
        const TitleSingular = 'sys_address.title_singular';

        const ColCountry = 'sys_address.col_country';
        const ColCity = 'sys_address.col_city';
        const ColDistrict = 'sys_address.col_district';
        const ColNeighborhood = 'sys_address.col_neighborhood';
        const ColQuarter = 'sys_address.col_quarter';
        const ColRoad = 'sys_address.col_road';
        const ColStreet = 'sys_address.col_street';
        const ColBuildingName = 'sys_address.col_building_name';
        const ColDoorNumber = 'sys_address.col_door_number';
        const ColZipCode = 'sys_address.col_zip_code';
        const ColWeb = 'sys_address.col_web';
        const ColEmail = 'sys_address.col_email';
      end;

      TSysApplicationSetting = record
        const TitlePlural = 'sys_application_setting.title_plural';
        const TitleSingular = 'sys_application_setting.title_singular';
        const TabGeneral = 'sys_application_setting.tab.general';
        const TabAddress = 'sys_application_setting.tab.address';
        const TabService = 'sys_application_setting.tab.service';
        const TabOther = 'sys_application_setting.tab.other';
        const TabVisual = 'sys_application_setting.tab.visual';
        const ColCompanyTitle = 'sys_application_setting.col_company_title';
        const ColPhone = 'sys_application_setting.col_phone';
        const ColFax = 'sys_application_setting.col_fax';
        const ColLogo = 'sys_application_setting.col_logo';
        const ColTaxpayerType = 'sys_application_setting.col_taxpayer_type';
        const ColTaxpayerName = 'sys_application_setting.col_taxpayer_name';
        const ColTaxpayerSurname = 'sys_application_setting.col_taxpayer_surname';
        const ColTaxNo = 'sys_application_setting.col_tax_no';
        const ColTaxAuthority = 'sys_application_setting.col_tax_authority';
        const ColMailHost = 'sys_application_setting.col_mail_host';
        const ColMailUser = 'sys_application_setting.col_mail_user';
        const ColMailPassword = 'sys_application_setting.col_mail_password';
        const ColMailSmtpPort = 'sys_application_setting.col_mail_smtp_port';
        const ColSmsHost = 'sys_application_setting.col_sms_host';
        const ColSmsUser = 'sys_application_setting.col_sms_user';
        const ColSmsPassword = 'sys_application_setting.col_sms_password';
        const ColSmsTitle = 'sys_application_setting.col_sms_title';
        const ColPathStockCardImage = 'sys_application_setting.col_path_stock_card_image';
        const ColPathPersonnelCardImage = 'sys_application_setting.col_path_personnel_card_image';
        const ColPathUpdate = 'sys_application_setting.col_path_update';
        const ColGridColor1 = 'sys_application_setting.col_grid_color_1';
        const ColGridColor2 = 'sys_application_setting.col_grid_color_2';
        const ColGridColorActive = 'sys_application_setting.col_grid_color_active';
        const ColCryptKey = 'sys_application_setting.col_crypt_key';
        const ColPeriod = 'sys_application_setting.col_period';
        const ColAppVersion = 'sys_application_setting.col_app_version';
        const AddressCityRequired = 'sys_application_setting.address_city.required';
        const InvalidDirectory = 'sys_application_setting.invalid_directory';
      end;

      TSysCity = record
        const TitlePlural = 'sys_city.title_plural';
        const TitleSingular = 'sys_city.title_singular';
        const ColCityName = 'sys_city.col_city_name';
        const ColCarPlateCode = 'sys_city.col_car_plate_code';
        const ColSysCountryId = 'sys_city.col_sys_country_id';
        const ColSysRegionId = 'sys_city.col_sys_region_id';
        const CityCountryUnique = 'sys_city.city_country.unique';
        const CountryRequired = 'sys_city.country.required';
      end;

      TSysCountry = record
        const TitlePlural = 'sys_country.title_plural';
        const TitleSingular = 'sys_country.title_singular';
        const CodeUnique = 'sys_country.code.unique';
        const ColCountryCode = 'sys_country.col_country_code';
        const ColIsoYear = 'sys_country.col_iso_year';
        const ColIsoCctld = 'sys_country.col_iso_cctld';
        const ColIsEuMember = 'sys_country.col_is_eu_member';
        const ColCountryName = 'sys_country.col_country_name';
      end;

      TSysCurrency = record
        const TitleSingular = 'sys_currency.title_singular';
        const TitlePlural = 'sys_currency.title_plural';
        const LblCode = 'sys_currency.lbl_code';
        const LblSymbol = 'sys_currency.lbl_symbol';
        const ColId = 'sys_currency.col_id';
        const ColCode = 'sys_currency.col_code';
        const ColSymbol = 'sys_currency.col_symbol';
        const ColDescription = 'sys_currency.col_description';
        const CurrencyUnique = 'sys_currency.currency.unique';
      end;

      TSysDecimalPlace = record
        const TitlePlural = 'sys_decimal_place.title_plural';
        const TitleSingular = 'sys_decimal_place.title_singular';
        const ColQuantity = 'sys_decimal_place.col_quantity';
        const ColPrice = 'sys_decimal_place.col_price';
        const ColTotal = 'sys_decimal_place.col_total';
        const ColStockQuantity = 'sys_decimal_place.col_stock_quantity';
        const ColExchangeRate = 'sys_decimal_place.col_exchange_rate';
        const NameMinLength = 'sys_decimal_place.name.minlength';
        const Range = 'sys_decimal_place.range';
      end;

      TSysGridColumn = record
        const TitleSingular = 'sys_grid_column.title_singular';
        const TitlePlural = 'sys_grid_column.title_plural';
        const ColId = 'sys_grid_column.col_id';
        const ColTableName = 'sys_grid_column.col_table_name';
        const ColColumnName = 'sys_grid_column.col_column_name';
        const ColColumnWidth = 'sys_grid_column.col_column_width';
        const ColColumnOrder = 'sys_grid_column.col_column_order';
        const ColIsShow = 'sys_grid_column.col_is_show';
        const ColIsFetch = 'sys_grid_column.col_is_fetch';
        const ColAggregateType = 'sys_grid_column.col_aggregate_type';
        const ColDataFormat = 'sys_grid_column.col_data_format';
        const ColIsShowHelper = 'sys_grid_column.col_is_show_helper';
        const ColMinValue = 'sys_grid_column.col_min_value';
        const ColMinValueColor = 'sys_grid_column.col_min_value_color';
        const ColMaxValue = 'sys_grid_column.col_max_value';
        const ColMaxValueColor = 'sys_grid_column.col_max_value_color';
        const ColMaxValuePercent = 'sys_grid_column.col_max_value_percent';
        const ColBarColor = 'sys_grid_column.col_bar_color';
        const ColBarBkColor = 'sys_grid_column.col_bar_bk_color';
        const ColBarTextColor = 'sys_grid_column.col_bar_text_color';
        const TableNameColumnName = 'sys_grid_column.table_name_column_name.unique';
        const TableNameColumnOrder = 'sys_grid_column.table_name_column_order.unique';
      end;

      TAggregateType = record
        const None = 'aggregate_type.none';
        const Sum = 'aggregate_type.sum';
        const Count = 'aggregate_type.count';
        const Average = 'aggregate_type.average';
        const Min = 'aggregate_type.min';
        const Max = 'aggregate_type.max';
      end;

      TSysGrid = record
        const ColColumnName = 'sys_grid.col_column_name';
        const LblSortDirection = 'sys_grid.lbl_sort_direction';
        const LblSortList = 'sys_grid.lbl_sort_list';
        const SortAsc = 'sys_grid.sort_asc';
        const SortDesc = 'sys_grid.sort_desc';
        const BtnAdd = 'sys_grid.btn_add';
        const BtnDelete = 'sys_grid.btn_delete';
        const BtnMoveUp = 'sys_grid.btn_move_up';
        const BtnMoveDown = 'sys_grid.btn_move_down';
        const BtnClear = 'sys_grid.btn_clear';
        const LblOperator = 'sys_grid.lbl_operator';
        const LblValue = 'sys_grid.lbl_value';
        const LblConjunction = 'sys_grid.lbl_conjunction';
        const ChkNot = 'sys_grid.chk_not';
        const LblFilterList = 'sys_grid.lbl_filter_list';
        const OpEqual = 'sys_grid.op_equal';
        const OpNotEqual = 'sys_grid.op_not_equal';
        const OpGreater = 'sys_grid.op_greater';
        const OpGreaterEqual = 'sys_grid.op_greater_equal';
        const OpLess = 'sys_grid.op_less';
        const OpLessEqual = 'sys_grid.op_less_equal';
        const OpLike = 'sys_grid.op_like';
        const OpNotLike = 'sys_grid.op_not_like';
        const OpStartsWith = 'sys_grid.op_starts_with';
        const OpEndsWith = 'sys_grid.op_ends_with';
        const OpIsNull = 'sys_grid.op_is_null';
        const OpIsNotNull = 'sys_grid.op_is_not_null';
        const OpIn = 'sys_grid.op_in';
        const OpNotIn = 'sys_grid.op_not_in';
        const WarnSelectColumn = 'sys_grid.warn_select_column';
        const WarnInvalidColumn = 'sys_grid.warn_invalid_column';
        const WarnEnterValue = 'sys_grid.warn_enter_value';
        const SecInvalidSort = 'sys_grid.sec_invalid_sort';
        const SecInvalidFilter = 'sys_grid.sec_invalid_filter';
      end;

      TSysGridFilter = record
        const TitleSingular = 'sys_grid_filter.title_singular';
        const TitlePlural = 'sys_grid_filter.title_plural';
        const ColId = 'sys_grid_filter.col_id';
        const ColTableName = 'sys_grid_filter.col_table_name';
        const ColFilterContent = 'sys_grid_filter.col_filter_content';
        const TableNameUnique = 'sys_grid_filter.table_name.unique';
        const ColColumnName = 'sys_grid.col_column_name';
        const LblOperator = 'sys_grid.lbl_operator';
        const LblValue = 'sys_grid.lbl_value';
        const LblConjunction = 'sys_grid.lbl_conjunction';
        const ChkNot = 'sys_grid.chk_not';
        const LblFilterList = 'sys_grid.lbl_filter_list';
        const OpEqual = 'sys_grid.op_equal';
        const OpNotEqual = 'sys_grid.op_not_equal';
        const OpGreater = 'sys_grid.op_greater';
        const OpGreaterEqual = 'sys_grid.op_greater_equal';
        const OpLess = 'sys_grid.op_less';
        const OpLessEqual = 'sys_grid.op_less_equal';
        const OpLike = 'sys_grid.op_like';
        const OpNotLike = 'sys_grid.op_not_like';
        const OpStartsWith = 'sys_grid.op_starts_with';
        const OpEndsWith = 'sys_grid.op_ends_with';
        const OpIsNull = 'sys_grid.op_is_null';
        const OpIsNotNull = 'sys_grid.op_is_not_null';
        const OpIn = 'sys_grid.op_in';
        const OpNotIn = 'sys_grid.op_not_in';
        const BtnAdd = 'sys_grid.btn_add';
        const BtnDelete = 'sys_grid.btn_delete';
        const BtnMoveUp = 'sys_grid.btn_move_up';
        const BtnMoveDown = 'sys_grid.btn_move_down';
        const BtnClear = 'sys_grid.btn_clear';
        const WarnSelectColumn = 'sys_grid.warn_select_column';
        const WarnInvalidColumn = 'sys_grid.warn_invalid_column';
        const WarnEnterValue = 'sys_grid.warn_enter_value';
        const SecInvalidFilter = 'sys_grid.sec_invalid_filter';
      end;

      TSysGridSort = record
        const TitleSingular = 'sys_grid_sort.title_singular';
        const TitlePlural = 'sys_grid_sort.title_plural';
        const ColId = 'sys_grid_sort.col_id';
        const ColTableName = 'sys_grid_sort.col_table_name';
        const ColSortContent = 'sys_grid_sort.col_sort_content';
        const TableNameUnique = 'sys_grid_sort.table_name.unique';
        const ColColumnName = 'sys_grid.col_column_name';
        const LblSortDirection = 'sys_grid.lbl_sort_direction';
        const LblSortList = 'sys_grid.lbl_sort_list';
        const SortAsc = 'sys_grid.sort_asc';
        const SortDesc = 'sys_grid.sort_desc';
        const BtnAdd = 'sys_grid.btn_add';
        const BtnDelete = 'sys_grid.btn_delete';
        const BtnMoveUp = 'sys_grid.btn_move_up';
        const BtnMoveDown = 'sys_grid.btn_move_down';
        const BtnClear = 'sys_grid.btn_clear';
        const WarnSelectColumn = 'sys_grid.warn_select_column';
        const WarnInvalidColumn = 'sys_grid.warn_invalid_column';
        const SecInvalidSort = 'sys_grid.sec_invalid_sort';
      end;

      TSysLanguage = record
        const TitlePlural = 'sys_language.title_plural';
        const TitleSingular = 'sys_language.title_singular';
        const ColId = 'sys_language.col_id';
        const ColLocale = 'sys_language.col_locale';
        const ColNativeName = 'sys_language.col_native_name';
        const LblLocale = 'sys_language.lbl_locale';
        const LblNativeName = 'sys_language.lbl_native_name';
        const LocaleRequired = 'sys_language.locale.required';
        const LocaleUnique = 'sys_language.locale.unique';
      end;

      TSysMenu = record
        const TitlePlural = 'sys_menu.title_plural';
        const TitleSingular = 'sys_menu.title_singular';
        const ColMenuCode = 'sys_menu.col_menu_code';
        const ColMenuName = 'sys_menu.col_menu_name';
        const ColParentPath = 'sys_menu.col_parent_path';
        const ColKeywords = 'sys_menu.col_keywords';
        const ColPermission = 'sys_menu.col_permission';
        const ColPermissionCode = 'sys_menu.col_permission_code';
        const ColIsActive = 'sys_menu.col_is_active';
        const ColActionName = 'sys_menu.col_action_name';
        const ColMenuKey = 'sys_menu.col_menu_key';
        const MsgCodeRange = 'sys_menu.msg.code_range';
        const MsgFolderRule = 'sys_menu.msg.folder_rule';
        const MsgParentMissing = 'sys_menu.msg.parent_missing';
        const MsgImmutable = 'sys_menu.msg.immutable';
        const MsgNoDelete = 'sys_menu.msg.no_delete';
        const CodeUnique = 'sys_menu.code_unique';
        const KeyUnique = 'sys_menu.key_unique';
        const ActionUnique = 'sys_menu.action_unique';
      end;

      TSysAuditLog = record
        const TitlePlural = 'sys_audit_log.title_plural';
        const TitleSingular = 'sys_audit_log.title_singular';
        const TitleRecordHistory = 'sys_audit_log.title_record_history';
        const ColChangedAt = 'sys_audit_log.col_changed_at';
        const ColAppUser = 'sys_audit_log.col_app_user';
        const ColAction = 'sys_audit_log.col_action';
        const ColTableName = 'sys_audit_log.col_table_name';
        const ColRecordNo = 'sys_audit_log.col_record_no';
        const ColChangedColumns = 'sys_audit_log.col_changed_columns';
        const ColPeriodYear = 'sys_audit_log.col_period_year';
        const ColDbName = 'sys_audit_log.col_db_name';
        const ColDbUser = 'sys_audit_log.col_db_user';
        const ColClientAddr = 'sys_audit_log.col_client_addr';
        const ColApplicationName = 'sys_audit_log.col_application_name';
        const ColTransactionId = 'sys_audit_log.col_transaction_id';
        const ColReceivedAt = 'sys_audit_log.col_received_at';
        const ColField = 'sys_audit_log.col_field';
        const ColOldValue = 'sys_audit_log.col_old_value';
        const ColNewValue = 'sys_audit_log.col_new_value';
        const ActionInsert = 'sys_audit_log.action_insert';
        const ActionUpdate = 'sys_audit_log.action_update';
        const ActionDelete = 'sys_audit_log.action_delete';
        const ReadOnly = 'sys_audit_log.read_only';
        const MenuRecordHistory = 'sys_audit_log.popup.record_history';
        const MenuSameRecord = 'sys_audit_log.popup.same_record';
        const MenuAllPeriods = 'sys_audit_log.popup.all_periods';
        const LblPending = 'sys_audit_log.lbl_pending';
        const MsgNoChanges = 'sys_audit_log.msg.no_changes';
      end;

      TSysPermission = record
        const TitlePlural = 'sys_permission.title_plural';
        const TitleSingular = 'sys_permission.title_singular';
        const ColPermissionCode = 'sys_permission.col_permission_code';
        const ColKey = 'sys_permission.col_permission_key';
        const ColPermissionName = 'sys_permission.col_permission_name';
        const ColGroupId = 'sys_permission.col_group_id';
        const CodePositive = 'sys_permission.code.positive';
        const GroupRequired = 'sys_permission.group.required';
        const KeyUnique = 'sys_permission.key_unique';
        const CodeUnique = 'sys_permission.code_unique';
      end;

      TSysPermissionGroup = record
        const TitlePlural = 'sys_permission_group.title_plural';
        const TitleSingular = 'sys_permission_group.title_singular';
        const ColGroupKey = 'sys_permission_group.col_group_key';
        const ColGroupName = 'sys_permission_group.col_group_name';
        const ColLocale = 'sys_permission_group.col_locale';
        const LblKey = 'sys_permission_group.lbl_key';
        const GroupKeyUnique = 'sys_permission_group.group_key_unique';
        const KeyRequired = 'sys_permission_group.key.required';
      end;

      TSysRegion = record
        const TitlePlural = 'sys_region.title_plural';
        const TitleSingular = 'sys_region.title_singular';
        const ColRegionName = 'sys_region.region_name';
        const RegionNameUnique = 'sys_region.region_name.unique';
      end;

      TSysUom = record
        const TitlePlural = 'sys_uom.title_plural';
        const TitleSingular = 'sys_uom.title_singular';
        const UnitCode = 'sys_uom.unit_code';
        const UnitEinv = 'sys_uom.unit_einv';
        const DecimalPlace = 'sys_uom.decimal';
        const MeasureType = 'sys_uom.measure_type';
        const Multiplier = 'sys_uom.multiplier';
        const ColId = 'sys_uom.col_id';
        const ColUnit = 'sys_uom.col_unit';
        const ColUnitEinv = 'sys_uom.col_unit_einv';
        const ColMeasureTypeId = 'sys_uom.col_measure_type_id';
        const ColUomName = 'sys_uom.col_uom_name';
        const ColDecimal = 'sys_uom.col_decimal';
        const ColMultiplier = 'sys_uom.col_multiplier';
        const UnitCodeUnique = 'sys_uom.unit_code_unique';
      end;

      TSysUomGroup = record
        const TitlePlural = 'sys_uom_group.title_plural';
        const TitleSingular = 'sys_uom_group.title_singular';
        const ColKey = 'sys_uom_group.col_key';
        const ColName = 'sys_uom_group.col_name';
        const ColLocale = 'sys_uom_group.col_locale';
        const KeyUnique = 'sys_uom_group.key_unique';
      end;

      TSysUser = record
        const TitlePlural = 'sys_user.title_plural';
        const TitleSingular = 'sys_user.title_singular';

        const ColUserName = 'sys_user.col_username';
        const ColUserPassword = 'sys_user.col_user_password';
        const ColActive = 'sys_user.col_active';
        const ColManager = 'sys_user.col_manager';
        const ColSuperUser = 'sys_user.col_super_user';
        const ColIpAddress = 'sys_user.col_ip_address';
        const ColMacAddress = 'sys_user.col_mac_address';
        const ColEmployeeId = 'sys_user.col_employee_id';

        const UsernameUnique = 'sys_user.username_unique';
        const MenuPermissionTemplates = 'sys_user.popup.permission_templates';
        const MenuAccessRights = 'sys_user.popup.access_rights';
        const MenuResetPassword = 'sys_user.popup.reset_password';
        const TitleResetPassword = 'sys_user.title_reset_password';
        const TitleChangePassword = 'sys_user.title_change_password';
        const LblOldPassword = 'sys_user.lbl_old_password';
        const LblNewPassword = 'sys_user.lbl_new_password';
        const LblNewPasswordConfirm = 'sys_user.lbl_new_password_confirm';
        const PasswordMismatch = 'sys_user.msg.password_mismatch';
        const PasswordResetDone = 'sys_user.msg.password_reset_done';
        const PasswordChangeDone = 'sys_user.msg.password_change_done';
        const OldPasswordInvalid = 'sys_user.msg.old_password_invalid';
      end;

      TSysPermissionTemplate = record
        const TitlePlural = 'sys_permission_template.title_plural';
        const TitleSingular = 'sys_permission_template.title_singular';
        const ColTemplateKey = 'sys_permission_template.col_template_key';
        const ColTemplateName = 'sys_permission_template.col_template_name';
        const ColDescription = 'sys_permission_template.col_description';
        const ColActive = 'sys_permission_template.col_active';
        const ColRightCount = 'sys_permission_template.col_right_count';
        const ColUserCount = 'sys_permission_template.col_user_count';
        const TemplateKeyUnique = 'sys_permission_template.template_key_unique';
        const MenuRights = 'sys_permission_template.popup.rights';
        const MenuUsers = 'sys_permission_template.popup.users';
      end;

      TSysPermissionTemplateRight = record
        const TitlePlural = 'sys_permission_template_right.title_plural';
        const TitleSingular = 'sys_permission_template_right.title_singular';
        const TemplatePermissionUnique = 'sys_permission_template_right.template_permission_unique';
        const MenuAddMissing = 'sys_permission_template_right.popup.add_missing';
        const MenuGrantAll = 'sys_permission_template_right.popup.grant_all';
        const MenuRevokeAll = 'sys_permission_template_right.popup.revoke_all';
        const MsgSelectTemplate = 'sys_permission_template_right.msg.select_template';
        const MsgAddedCount = 'sys_permission_template_right.msg.added_count';
        const MsgConfirmAll = 'sys_permission_template_right.msg.confirm_all';
      end;

      TSysUserPermissionTemplate = record
        const TitlePlural = 'sys_user_permission_template.title_plural';
        const TitleSingular = 'sys_user_permission_template.title_singular';
        const UserTemplateUnique = 'sys_user_permission_template.user_template_unique';
      end;

      TSysViewTable = record
        const TitlePlural = 'sys_view_tables.title_plural';
        const ColId = 'sys_view_tables.col_id';
        const ColTableName = 'sys_view_tables.col_table_name';
        const ColTableType = 'sys_view_tables.col_table_type';
      end;



      //Account Module
      TAccOption = record
        const TaxpayerLegal = 'acc_option.taxpayer_legal';
        const TaxpayerReal = 'acc_option.taxpayer_real';
        const SrcMoney = 'acc_option.src_money';
        const SrcChequeNote = 'acc_option.src_cheque_note';
        const SrcPos = 'acc_option.src_pos';
        const SrcCreditCard = 'acc_option.src_credit_card';
        const SrcPurInvoice = 'acc_option.src_pur_invoice';
        const SrcSlsInvoice = 'acc_option.src_sls_invoice';
        const VoucherAdjustment = 'acc_option.voucher_adjustment';
        const VoucherReceipt = 'acc_option.voucher_receipt';
        const VoucherPayment = 'acc_option.voucher_payment';
        const VoucherOpening = 'acc_option.voucher_opening';
        const VoucherClosing = 'acc_option.voucher_closing';
      end;

      TAccSetAccountType = record
        const TitlePlural = 'acc_set_account_type.title_plural';
        const TitleSingular = 'acc_set_account_type.title_singular';
        const ColAccountTypeKey = 'acc_set_account_type.col_account_type_key';
        const ColAccountTypeName = 'acc_set_account_type.col_account_type_name';
        const AccountTypeKeyUnique = 'acc_set_account_type.account_type_key_unique';
      end;

      TAccSetOwnershipType = record
        const TitlePlural = 'acc_set_ownership_type.title_plural';
        const TitleSingular = 'acc_set_ownership_type.title_singular';
        const ColOwnershipTypeKey = 'acc_set_ownership_type.col_ownership_type_key';
        const ColOwnershipTypeName = 'acc_set_ownership_type.col_ownership_type_name';
        const OwnershipTypeKeyUnique = 'acc_set_ownership_type.ownership_type_key_unique';
      end;

      TAccSetCompanyLegalForm = record
        const TitlePlural = 'acc_set_company_legal_form.title_plural';
        const TitleSingular = 'acc_set_company_legal_form.title_singular';
        const ColLegalFormKey = 'acc_set_company_legal_form.col_legal_form_key';
        const ColLegalFormName = 'acc_set_company_legal_form.col_legal_form_name';
        const ColOwnershipType = 'acc_set_company_legal_form.col_ownership_type';
        const LegalFormKeyUnique = 'acc_set_company_legal_form.legal_form_key_unique';
      end;

      TAccGroup = record
        const TitlePlural = 'acc_group.title_plural';
        const TitleSingular = 'acc_group.title_singular';
        const ColName = 'acc_group.col_name';
        const NameUnique = 'acc_group.name_unique';
      end;

      TAccRegion = record
        const TitlePlural = 'acc_region.title_plural';
        const TitleSingular = 'acc_region.title_singular';
        const ColName = 'acc_region.col_name';
        const NameUnique = 'acc_region.name_unique';
      end;

      TAccBank = record
        const TitlePlural = 'acc_bank.title_plural';
        const TitleSingular = 'acc_bank.title_singular';
        const ColBankName = 'acc_bank.col_bank_name';
        const ColSwiftCode = 'acc_bank.col_swift_code';
        const MenuBranches = 'acc_bank.popup.branches';
        const BankNameUnique = 'acc_bank.bank_name_unique';
      end;

      TAccBankBranch = record
        const TitlePlural = 'acc_bank_branch.title_plural';
        const TitleSingular = 'acc_bank_branch.title_singular';
        const ColBank = 'acc_bank_branch.col_bank';
        const ColBranchCode = 'acc_bank_branch.col_branch_code';
        const ColBranchName = 'acc_bank_branch.col_branch_name';
        const ColCity = 'acc_bank_branch.col_city';
        const BranchCodeUnique = 'acc_bank_branch.branch_code_unique';
      end;

      TAccAccountPlan = record
        const TitlePlural = 'acc_account_plan.title_plural';
        const TitleSingular = 'acc_account_plan.title_singular';
        const ColCode = 'acc_account_plan.col_code';
        const ColName = 'acc_account_plan.col_name';
        const ColLevel = 'acc_account_plan.col_level';
        const CodeUnique = 'acc_account_plan.code_unique';
      end;

      TAccExchangeRate = record
        const TitlePlural = 'acc_exchange_rate.title_plural';
        const TitleSingular = 'acc_exchange_rate.title_singular';
        const ColRateDate = 'acc_exchange_rate.col_rate_date';
        const ColCurrency = 'acc_exchange_rate.col_currency';
        const ColRate = 'acc_exchange_rate.col_rate';
        const ColForexBuying = 'acc_exchange_rate.col_forex_buying';
        const ColForexSelling = 'acc_exchange_rate.col_forex_selling';
        const ColBanknoteBuying = 'acc_exchange_rate.col_banknote_buying';
        const ColBanknoteSelling = 'acc_exchange_rate.col_banknote_selling';
        const ColSource = 'acc_exchange_rate.col_source';
        const MenuTcmb = 'acc_exchange_rate.popup.tcmb';
        const TcmbImported = 'acc_exchange_rate.msg.tcmb_imported';
        const TcmbFailed = 'acc_exchange_rate.msg.tcmb_failed';
        const RateDateCurrencyUnique = 'acc_exchange_rate.rate_date_currency_unique';
      end;

      TAccSetTaxRate = record
        const TitlePlural = 'acc_set_tax_rate.title_plural';
        const TitleSingular = 'acc_set_tax_rate.title_singular';
        const ColTaxRate = 'acc_set_tax_rate.col_tax_rate';
        const ColSalesAccount = 'acc_set_tax_rate.col_sales_account';
        const ColSalesReturnAccount = 'acc_set_tax_rate.col_sales_return_account';
        const ColPurchaseAccount = 'acc_set_tax_rate.col_purchase_account';
        const ColPurchaseReturnAccount = 'acc_set_tax_rate.col_purchase_return_account';
        const TaxRateUnique = 'acc_set_tax_rate.tax_rate_unique';
      end;

      TAccTransferCode = record
        const TitlePlural = 'acc_transfer_code.title_plural';
        const TitleSingular = 'acc_transfer_code.title_singular';
        const ColTransferCode = 'acc_transfer_code.col_transfer_code';
        const ColDescription = 'acc_transfer_code.col_description';
        const ColAccount = 'acc_transfer_code.col_account';
        const ColAccountName = 'acc_transfer_code.col_account_name';
        const TransferCodeUnique = 'acc_transfer_code.transfer_code_unique';
      end;

      TAccVoucher = record
        const TitlePlural = 'acc_voucher.title_plural';
        const TitleSingular = 'acc_voucher.title_singular';
        const ColJournalNo = 'acc_voucher.col_journal_no';
        const ColJournalDate = 'acc_voucher.col_journal_date';
        const JournalNoUnique = 'acc_voucher.journal_no_unique';
        const ColVoucherNo = 'acc_voucher.col_voucher_no';
        const ColVoucherDate = 'acc_voucher.col_voucher_date';
        const ColVoucherType = 'acc_voucher.col_voucher_type';
        const ColDescription = 'acc_voucher.col_description';
        const ColTotalDebit = 'acc_voucher.col_total_debit';
        const ColTotalCredit = 'acc_voucher.col_total_credit';
        const ColDifference = 'acc_voucher.col_difference';
        const ColLineCount = 'acc_voucher.col_line_count';
        const MenuLines = 'acc_voucher.popup.lines';
        const NoUnique = 'acc_voucher.no_unique';
        const NotBalanced = 'acc_voucher.not_balanced';
        const NoLines = 'acc_voucher.no_lines';
      end;

      TAccVoucherDetail = record
        const TitlePlural = 'acc_voucher_detail.title_plural';
        const TitleSingular = 'acc_voucher_detail.title_singular';
        const ColVoucher = 'acc_voucher_detail.col_voucher';
        const ColLineNo = 'acc_voucher_detail.col_line_no';
        const ColAccAccountId = 'acc_voucher_detail.col_acc_account_id';
        const ColAccountCode = 'acc_voucher_detail.col_account_code';
        const ColAccountName = 'acc_voucher_detail.col_account_name';
        const ColDescription = 'acc_voucher_detail.col_description';
        const ColDebit = 'acc_voucher_detail.col_debit';
        const ColCredit = 'acc_voucher_detail.col_credit';
        const AmountRule = 'acc_voucher_detail.amount_rule';
        const DetailAccountOnly = 'acc_voucher_detail.detail_account_only';
      end;

      TAccAccount = record
        const TitlePlural = 'acc_account.title_plural';
        const TitleSingular = 'acc_account.title_singular';
        const ColCode = 'acc_account.col_code';
        const ColName = 'acc_account.col_name';
        const ColAccountType = 'acc_account.col_account_type';
        const ColGroup = 'acc_account.col_group';
        const ColRegion = 'acc_account.col_region';
        const ColRootCode = 'acc_account.col_root_code';
        const ColSubCode = 'acc_account.col_sub_code';
        const ColIban = 'acc_account.col_iban';
        const ColIbanCurrency = 'acc_account.col_iban_currency';
        const ColDiscountRate = 'acc_account.col_discount_rate';
        const ColEInvoiceActive = 'acc_account.col_e_invoice_active';
        const ColEInvoicePkAlias = 'acc_account.col_e_invoice_pk_alias';
        const ColEInvoiceGbAlias = 'acc_account.col_e_invoice_gb_alias';
        const ColEDespatchPkAlias = 'acc_account.col_e_despatch_pk_alias';
        const ColEDespatchGbAlias = 'acc_account.col_e_despatch_gb_alias';
        const ColIsPassive = 'acc_account.col_is_passive';
        const ColNotes = 'acc_account.col_notes';
        const ColTaxpayerType = 'acc_account.col_taxpayer_type';
        const ColTaxpayerName = 'acc_account.col_taxpayer_name';
        const ColTaxpayerName2 = 'acc_account.col_taxpayer_name2';
        const ColTaxpayerSurname = 'acc_account.col_taxpayer_surname';
        const ColTaxOffice = 'acc_account.col_tax_office';
        const ColTaxNo = 'acc_account.col_tax_no';
        const ColNaceCode = 'acc_account.col_nace_code';
        const ColAuthorizedPerson1 = 'acc_account.col_authorized_person1';
        const ColAuthorizedPhone1 = 'acc_account.col_authorized_phone1';
        const ColAuthorizedPerson2 = 'acc_account.col_authorized_person2';
        const ColAuthorizedPhone2 = 'acc_account.col_authorized_phone2';
        const ColAuthorizedPerson3 = 'acc_account.col_authorized_person3';
        const ColAuthorizedPhone3 = 'acc_account.col_authorized_phone3';
        const ColFax = 'acc_account.col_fax';
        const ColAccountantPhone = 'acc_account.col_accountant_phone';
        const ColAccountantEmail = 'acc_account.col_accountant_email';
        const ColAccountantAuthorized = 'acc_account.col_accountant_authorized';
        const MenuAddresses = 'acc_account.popup.addresses';
        const CodeUnique = 'acc_account.code_unique';
        const MenuTransactions = 'acc_account.popup.transactions';
        const ColEDespatchActive = 'acc_account.col_e_despatch_active';
        const TabGeneral = 'acc_account.tab_general';
        const AddressBilling = 'acc_account.address_billing';
        const AddressShipping = 'acc_account.address_shipping';
        const AddressLegal = 'acc_account.address_legal';
        const AddressOther = 'acc_account.address_other';
        const AddressCity = 'acc_account.address_city';
        const TabTaxpayer = 'acc_account.tab_taxpayer';
        const TabContact = 'acc_account.tab_contact';
        const ColCitizenNo = 'acc_account.col_citizen_no';
        const TaxNoDigits = 'acc_account.tax_no_digits';
        const CodeFormat = 'acc_account.code_format';
        const CodeParentMissing = 'acc_account.code_parent_missing';
        const CodeNotInPlan = 'acc_account.code_not_in_plan';
        const CodePlanLevel = 'acc_account.code_plan_level';
        const CodeHasChildren = 'acc_account.code_has_children';
      end;

      TAccAccountAddress = record
        const TitlePlural = 'acc_account_address.title_plural';
        const TitleSingular = 'acc_account_address.title_singular';
        const ColAccount = 'acc_account_address.col_account';
        const ColAddress = 'acc_account_address.col_address';
        const ColAddressType = 'acc_account_address.col_address_type';
        const ColIsPrimary = 'acc_account_address.col_is_primary';
        const ColValidFrom = 'acc_account_address.col_valid_from';
        const ColValidTo = 'acc_account_address.col_valid_to';
        const ColAccountCode = 'acc_account_address.col_account_code';
        const ValidDateRange = 'acc_account_address.valid_date_range';
      end;

      //Employee Module
      TEmpEmployee = record
        const TitlePlural = 'emp_employee.title_plural';
        const TitleSingular = 'emp_employee.title_singular';
        const ColFullName = 'emp_employee.col_full_name';
        const ColName = 'emp_employee.col_name';
        const ColSurname = 'emp_employee.col_surname';
        const ColPhone1 = 'emp_employee.col_phone1';
        const ColPhone2 = 'emp_employee.col_phone2';
        const ColPersonType = 'emp_employee.col_person_type';
        const ColUnitName = 'emp_employee.col_unit_name';
        const ColSectionName = 'emp_employee.col_section_name';
        const ColTaskName = 'emp_employee.col_task_name';
        const ColBirthDate = 'emp_employee.col_birth_date';
        const ColBloodType = 'emp_employee.col_blood_type';
        const ColGender = 'emp_employee.col_gender';
        const ColMilitaryStatus = 'emp_employee.col_military_status';
        const ColMaritalStatus = 'emp_employee.col_marital_status';
        const ColChild = 'emp_employee.col_child';
        const ColRelativeName = 'emp_employee.col_relative_name';
        const ColRelativePhone = 'emp_employee.col_relative_phone';
        const ColShoeSize = 'emp_employee.col_shoe_size';
        const ColClothingSize = 'emp_employee.col_clothing_size';
        const ColNotes = 'emp_employee.col_notes';
        const ColTransportation = 'emp_employee.col_transportation';
        const ColSpecialNotes = 'emp_employee.col_special_notes';
        const ColSalaryAmount = 'emp_employee.col_salary_amount';
        const ColBonusCount = 'emp_employee.col_bonus_count';
        const ColBonusAmount = 'emp_employee.col_bonus_amount';
        const ColIdDocumentNo = 'emp_employee.col_id_document_no';
        const ColActive = 'emp_employee.col_active';
        const MenuDriverLicences = 'emp_employee.popup.driver_licences';
        const MenuLanguageAbilities = 'emp_employee.popup.language_abilities';
        const MenuAddresses = 'emp_employee.popup.addresses';
      end;

      // Sabit seçenekler (EmpLookup)
      TEmpOption = record
        const GenderMale = 'emp_option.gender_male';
        const GenderFemale = 'emp_option.gender_female';
        const MilitaryCompleted = 'emp_option.military_completed';
        const MilitaryExempt = 'emp_option.military_exempt';
        const MilitaryNotCompleted = 'emp_option.military_not_completed';
        const MaritalSingle = 'emp_option.marital_single';
        const MaritalMarried = 'emp_option.marital_married';
        const LevelBasic = 'emp_option.level_basic';
        const LevelIntermediate = 'emp_option.level_intermediate';
        const LevelGood = 'emp_option.level_good';
        const LevelFluent = 'emp_option.level_fluent';
        const RangeError = 'emp_option.range_error';
      end;

      TEmpPersonType = record
        const TitlePlural = 'emp_person_type.title_plural';
        const TitleSingular = 'emp_person_type.title_singular';
        const ColPersonTypeKey = 'emp_person_type.col_person_type_key';
        const ColPersonType = 'emp_person_type.col_person_type';
        const PersonTypeKeyUnique = 'emp_person_type.person_type_key_unique';
      end;

      TEmpSection = record
        const TitlePlural = 'emp_section.title_plural';
        const TitleSingular = 'emp_section.title_singular';
        const ColSectionKey = 'emp_section.col_section_key';
        const ColSectionName = 'emp_section.col_section_name';
        const SectionKeyUnique = 'emp_section.section_key_unique';
      end;

      TEmpTask = record
        const TitlePlural = 'emp_task.title_plural';
        const TitleSingular = 'emp_task.title_singular';
        const ColTaskKey = 'emp_task.col_task_key';
        const ColTaskName = 'emp_task.col_task_name';
        const TaskKeyUnique = 'emp_task.task_key_unique';
      end;

      TEmpUnit = record
        const TitlePlural = 'emp_unit.title_plural';
        const TitleSingular = 'emp_unit.title_singular';
        const ColUnitKey = 'emp_unit.col_unit_key';
        const ColUnitName = 'emp_unit.col_unit_name';
        const ColSection = 'emp_unit.col_section';
        const UnitKeyUnique = 'emp_unit.unit_key_unique';
        const ColSectionId = 'emp_unit.section_id';
      end;

      TEmpLanguage = record
        const TitlePlural = 'emp_language.title_plural';
        const TitleSingular = 'emp_language.title_singular';
        const ColLanguageName = 'emp_language.col_language_name';
        const LanguageNameUnique = 'emp_language.language_name_unique';
      end;

      TEmpDriverLicenseType = record
        const TitlePlural = 'emp_driver_license_type.title_plural';
        const TitleSingular = 'emp_driver_license_type.title_singular';
        const ColLicenseName = 'emp_driver_license_type.col_license_name';
        const LicenseNameUnique = 'emp_driver_license_type.license_name_unique';
      end;

      TEmpTransportation = record
        const TitlePlural = 'emp_transportation.title_plural';
        const TitleSingular = 'emp_transportation.title_singular';
        const ColCarNo = 'emp_transportation.col_car_no';
        const ColCarName = 'emp_transportation.col_car_name';
        const ColRouteDescription = 'emp_transportation.col_route_description';
        const CarNoUnique = 'emp_transportation.car_no_unique';
      end;

      TEmpDriverAbility = record
        const TitlePlural = 'emp_driver_ability.title_plural';
        const TitleSingular = 'emp_driver_ability.title_singular';
        const ColEmployee = 'emp_driver_ability.col_employee';
        const ColLicenseName = 'emp_driver_ability.col_license_name';
        const EmployeeLicenseUnique = 'emp_driver_ability.employee_license_unique';
      end;

      TEmpLanguageAbility = record
        const TitlePlural = 'emp_person_language_ability.title_plural';
        const TitleSingular = 'emp_person_language_ability.title_singular';
        const ColEmployee = 'emp_person_language_ability.col_employee';
        const ColLanguageName = 'emp_person_language_ability.col_language_name';
        const ColReadLevel = 'emp_person_language_ability.col_read_level';
        const ColWriteLevel = 'emp_person_language_ability.col_write_level';
        const ColSpeakLevel = 'emp_person_language_ability.col_speak_level';
        const EmployeeLanguageUnique = 'emp_person_language_ability.employee_language_unique';
      end;

      TEmpPersonAddress = record
        const TitlePlural = 'emp_person_address.title_plural';
        const TitleSingular = 'emp_person_address.title_singular';
        const ColEmployee = 'emp_person_address.col_employee';
        const ColAddress = 'emp_person_address.col_address';
        const ColAddressType = 'emp_person_address.col_address_type';
        const ColIsPrimary = 'emp_person_address.col_is_primary';
        const ColValidFrom = 'emp_person_address.col_valid_from';
        const ColValidTo = 'emp_person_address.col_valid_to';
        const ValidDateRange = 'emp_person_address.valid_date_range';
      end;

      //Stock Module
      TStkOption = record
        const TransactionIn = 'stk_option.transaction_in';
        const TransactionOut = 'stk_option.transaction_out';
        const TransactionTransfer = 'stk_option.transaction_transfer';
      end;

      TStkGroup = record
        const TitlePlural = 'stk_group.title_plural';
        const TitleSingular = 'stk_group.title_singular';
        const ColName = 'stk_group.col_name';
        const ColVatRate = 'stk_group.col_vat_rate';
        const ColRawMaterialStockAccount = 'stk_group.col_raw_material_stock_account';
        const ColRawMaterialUsageAccount = 'stk_group.col_raw_material_usage_account';
        const ColSemiProductAccount = 'stk_group.col_semi_product_account';
        const NameUnique = 'stk_group.name_unique';
      end;

      TStkWarehouse = record
        const TitlePlural = 'stk_warehouse.title_plural';
        const TitleSingular = 'stk_warehouse.title_singular';
        const ColWarehouseName = 'stk_warehouse.col_warehouse_name';
        const ColDefaultRawMaterial = 'stk_warehouse.col_default_raw_material';
        const ColDefaultProduction = 'stk_warehouse.col_default_production';
        const ColDefaultSales = 'stk_warehouse.col_default_sales';
        const WarehouseNameUnique = 'stk_warehouse.warehouse_name_unique';
        const DefaultWarehouseExists = 'stk_warehouse.default_warehouse_exists';
      end;

      TStkProductType = record
        const TitlePlural = 'stk_product_type.title_plural';
        const TitleSingular = 'stk_product_type.title_singular';
        const ColProductTypeName = 'stk_product_type.col_product_type_name';
        const ColDescription = 'stk_product_type.col_description';
        const ColActive = 'stk_product_type.col_active';
        const ProductTypeNameUnique = 'stk_product_type.product_type_name_unique';
      end;

      TStkKindFamily = record
        const TitlePlural = 'stk_kind_family.title_plural';
        const TitleSingular = 'stk_kind_family.title_singular';
        const ColFamily = 'stk_kind_family.col_family';
        const ColDescription = 'stk_kind_family.col_description';
        const ColActive = 'stk_kind_family.col_active';
        const MenuProperties = 'stk_kind_family.popup.properties';
        const FamilyUnique = 'stk_kind_family.family_unique';
      end;

      TStkKindProperty = record
        const TitlePlural = 'stk_kind_property.title_plural';
        const TitleSingular = 'stk_kind_property.title_singular';
        const ColKind = 'stk_kind_property.col_kind';
        const ColDescription = 'stk_kind_property.col_description';
        const ColFamily = 'stk_kind_property.col_family';
        const ColS1 = 'stk_kind_property.col_s1';
        const ColS2 = 'stk_kind_property.col_s2';
        const ColS3 = 'stk_kind_property.col_s3';
        const ColS4 = 'stk_kind_property.col_s4';
        const ColS5 = 'stk_kind_property.col_s5';
        const ColS6 = 'stk_kind_property.col_s6';
        const ColS7 = 'stk_kind_property.col_s7';
        const ColS8 = 'stk_kind_property.col_s8';
        const ColS9 = 'stk_kind_property.col_s9';
        const ColS10 = 'stk_kind_property.col_s10';
        const ColI1 = 'stk_kind_property.col_i1';
        const ColI2 = 'stk_kind_property.col_i2';
        const ColI3 = 'stk_kind_property.col_i3';
        const ColI4 = 'stk_kind_property.col_i4';
        const ColI5 = 'stk_kind_property.col_i5';
        const ColD1 = 'stk_kind_property.col_d1';
        const ColD2 = 'stk_kind_property.col_d2';
        const ColD3 = 'stk_kind_property.col_d3';
        const ColD4 = 'stk_kind_property.col_d4';
        const ColD5 = 'stk_kind_property.col_d5';
        const KindUnique = 'stk_kind_property.kind_unique';
      end;

      TStkInventory = record
        const TitlePlural = 'stk_inventory.title_plural';
        const TitleSingular = 'stk_inventory.title_singular';
        const ColCode = 'stk_inventory.col_code';
        const ColName = 'stk_inventory.col_name';
        const ColGroup = 'stk_inventory.col_group';
        const ColProductType = 'stk_inventory.col_product_type';
        const ColUom = 'stk_inventory.col_uom';
        const ColSellable = 'stk_inventory.col_sellable';
        const ColBuyingPrice = 'stk_inventory.col_buying_price';
        const ColBuyingCurrency = 'stk_inventory.col_buying_currency';
        const ColBuyingDiscount = 'stk_inventory.col_buying_discount';
        const ColSalesPrice = 'stk_inventory.col_sales_price';
        const ColSalesCurrency = 'stk_inventory.col_sales_currency';
        const ColSalesDiscount = 'stk_inventory.col_sales_discount';
        const ColExportPrice = 'stk_inventory.col_export_price';
        const ColExportCurrency = 'stk_inventory.col_export_currency';
        const ColSpecialCode = 'stk_inventory.col_special_code';
        const ColBrand = 'stk_inventory.col_brand';
        const ColWidth = 'stk_inventory.col_width';
        const ColLength = 'stk_inventory.col_length';
        const ColHeight = 'stk_inventory.col_height';
        const ColWeight = 'stk_inventory.col_weight';
        const ColSupplyDuration = 'stk_inventory.col_supply_duration';
        const ColMinStockAmount = 'stk_inventory.col_min_stock_amount';
        const ColCountry = 'stk_inventory.col_country';
        const ColHsNo = 'stk_inventory.col_hs_no';
        const ColDiibProductDescription = 'stk_inventory.col_diib_product_description';
        const ColProductOverview = 'stk_inventory.col_product_overview';
        const ColCurrentQuantity = 'stk_inventory.col_current_quantity';
        const ColAverageCost = 'stk_inventory.col_average_cost';
        const MenuKindInfo = 'stk_inventory.popup.kind_info';
        const MenuTransactions = 'stk_inventory.popup.transactions';
        const CodeUnique = 'stk_inventory.code_unique';
        const Image = 'stk_inventory.image';
        const ImageLoad = 'stk_inventory.image_load';
        const ImageClear = 'stk_inventory.image_clear';
        const ImageTooLarge = 'stk_inventory.image_too_large';
        const TabGeneral = 'stk_inventory.tab_general';
        const TabMonetary = 'stk_inventory.tab_monetary';
        const TabKind = 'stk_inventory.tab_kind';
        const TabAccounting = 'stk_inventory.tab_accounting';
        const TabSummary = 'stk_inventory.tab_summary';
        const ColVatRate = 'stk_inventory.col_vat_rate';
        const ColRawMaterialStockAccount = 'stk_inventory.col_raw_material_stock_account';
        const ColRawMaterialUsageAccount = 'stk_inventory.col_raw_material_usage_account';
        const ColSemiProductAccount = 'stk_inventory.col_semi_product_account';
        const ColSalesAccount = 'stk_inventory.col_sales_account';
        const ColSalesReturnAccount = 'stk_inventory.col_sales_return_account';
        const ColPurchaseAccount = 'stk_inventory.col_purchase_account';
        const ColPurchaseReturnAccount = 'stk_inventory.col_purchase_return_account';
        const LblOverride = 'stk_inventory.lbl_override';
        const LblDefault = 'stk_inventory.lbl_default';
        const AccountingInfo = 'stk_inventory.msg.accounting_info';
        const AccountNotFound = 'stk_inventory.account_not_found';
        const KindNotDefined = 'stk_inventory.msg.kind_not_defined';
        const KindEdit = 'stk_inventory.kind_edit';
        const SaveFirst = 'stk_inventory.msg.save_first';
        const ColWarehouse = 'stk_inventory.col_warehouse';
        const ColQuantity = 'stk_inventory.col_quantity';
        const WarehouseStocks = 'stk_inventory.warehouse_stocks';
        const ColProperty = 'stk_inventory.col_property';
        const ColValue = 'stk_inventory.col_value';
        const ColGtipCode = 'stk_inventory.col_gtip_code';
        const ColGtipName = 'stk_inventory.col_gtip_name';
      end;

      TStkCardKindInfo = record
        const TitlePlural = 'stk_card_kind_info.title_plural';
        const TitleSingular = 'stk_card_kind_info.title_singular';
        const ColInventory = 'stk_card_kind_info.col_inventory';
        const ColKind = 'stk_card_kind_info.col_kind';
        const ColS1 = 'stk_card_kind_info.col_s1';
        const ColS2 = 'stk_card_kind_info.col_s2';
        const ColS3 = 'stk_card_kind_info.col_s3';
        const ColS4 = 'stk_card_kind_info.col_s4';
        const ColS5 = 'stk_card_kind_info.col_s5';
        const ColS6 = 'stk_card_kind_info.col_s6';
        const ColS7 = 'stk_card_kind_info.col_s7';
        const ColS8 = 'stk_card_kind_info.col_s8';
        const ColS9 = 'stk_card_kind_info.col_s9';
        const ColS10 = 'stk_card_kind_info.col_s10';
        const ColI1 = 'stk_card_kind_info.col_i1';
        const ColI2 = 'stk_card_kind_info.col_i2';
        const ColI3 = 'stk_card_kind_info.col_i3';
        const ColI4 = 'stk_card_kind_info.col_i4';
        const ColI5 = 'stk_card_kind_info.col_i5';
        const ColD1 = 'stk_card_kind_info.col_d1';
        const ColD2 = 'stk_card_kind_info.col_d2';
        const ColD3 = 'stk_card_kind_info.col_d3';
        const ColD4 = 'stk_card_kind_info.col_d4';
        const ColD5 = 'stk_card_kind_info.col_d5';
        const ColInventoryCode = 'stk_card_kind_info.col_inventory_code';
        const InventoryUnique = 'stk_card_kind_info.inventory_unique';
      end;

      TStkTransaction = record
        const TitlePlural = 'stk_transaction.title_plural';
        const TitleSingular = 'stk_transaction.title_singular';
        const ColTransactionDate = 'stk_transaction.col_transaction_date';
        const ColTransactionType = 'stk_transaction.col_transaction_type';
        const ColInventory = 'stk_transaction.col_inventory';
        const ColFromWarehouse = 'stk_transaction.col_from_warehouse';
        const ColToWarehouse = 'stk_transaction.col_to_warehouse';
        const ColQuantity = 'stk_transaction.col_quantity';
        const ColAmount = 'stk_transaction.col_amount';
        const ColAmountForeign = 'stk_transaction.col_amount_foreign';
        const ColCurrency = 'stk_transaction.col_currency';
        const ColIsOpening = 'stk_transaction.col_is_opening';
        const ColDescription = 'stk_transaction.col_description';
        const ColInventoryCode = 'stk_transaction.col_inventory_code';
        const QuantityPositive = 'stk_transaction.quantity_positive';
        const FromWarehouseRequired = 'stk_transaction.from_warehouse_required';
        const ToWarehouseRequired = 'stk_transaction.to_warehouse_required';
        const WarehousesSame = 'stk_transaction.warehouses_same';
        const OpeningOnlyIncoming = 'stk_transaction.opening_only_incoming';
        const ReceiptLinked = 'stk_transaction.receipt_linked';
        const SalesLinked = 'stk_transaction.sales_linked';
      end;

      TStkInventorySummary = record
        const TitlePlural = 'stk_inventory_summary.title_plural';
        const TitleSingular = 'stk_inventory_summary.title_singular';
        const ColInventory = 'stk_inventory_summary.col_inventory';
        const ColCurrentQuantity = 'stk_inventory_summary.col_current_quantity';
        const ColAverageCost = 'stk_inventory_summary.col_average_cost';
        const ColOpeningQuantity = 'stk_inventory_summary.col_opening_quantity';
        const ColOpeningPrice = 'stk_inventory_summary.col_opening_price';
        const ColOpeningAmount = 'stk_inventory_summary.col_opening_amount';
        const ColIncomingQuantity = 'stk_inventory_summary.col_incoming_quantity';
        const ColIncomingAmount = 'stk_inventory_summary.col_incoming_amount';
        const ColOutgoingQuantity = 'stk_inventory_summary.col_outgoing_quantity';
        const ColOutgoingAmount = 'stk_inventory_summary.col_outgoing_amount';
        const ColLastBuyDate = 'stk_inventory_summary.col_last_buy_date';
        const ColLastBuyQuantity = 'stk_inventory_summary.col_last_buy_quantity';
        const ColLastBuyPrice = 'stk_inventory_summary.col_last_buy_price';
        const ColLastBuyCurrency = 'stk_inventory_summary.col_last_buy_currency';
        const ColLastBuyExchangeRate = 'stk_inventory_summary.col_last_buy_exchange_rate';
        const ColInventoryCode = 'stk_inventory_summary.col_inventory_code';
      end;

      TPrdOption = record
        const CostLabour = 'prd_option.cost_labour';
        const CostMachine = 'prd_option.cost_machine';
        const CostOverhead = 'prd_option.cost_overhead';
      end;

      TPrdLabour = record
        const TitlePlural = 'prd_labour.title_plural';
        const TitleSingular = 'prd_labour.title_singular';
        const ColCode = 'prd_labour.col_code';
        const ColName = 'prd_labour.col_name';
        const ColCostType = 'prd_labour.col_cost_type';
        const ColSysUomId = 'prd_labour.col_sys_uom_id';
        const ColUnitPrice = 'prd_labour.col_unit_price';
        const ColCurrency = 'prd_labour.col_currency';
        const ColAccAccountCode = 'prd_labour.col_acc_account_code';
        const CodeUnique = 'prd_labour.code_unique';
      end;

      TPrdBom = record
        const TitlePlural = 'prd_bom.title_plural';
        const TitleSingular = 'prd_bom.title_singular';
        const ColStkInventoryId = 'prd_bom.col_stk_inventory_id';
        const ColBomName = 'prd_bom.col_bom_name';
        const ColBaseQuantity = 'prd_bom.col_base_quantity';
        const ColIsDefault = 'prd_bom.col_is_default';
        const ColIsActive = 'prd_bom.col_is_active';
        const ColDescription = 'prd_bom.col_description';
        const ColInventoryCode = 'prd_bom.col_inventory_code';
        const ColInventoryName = 'prd_bom.col_inventory_name';
        const ColRawCount = 'prd_bom.col_raw_count';
        const ColLabourCount = 'prd_bom.col_labour_count';
        const BomNameUnique = 'prd_bom.bom_name_unique';
        const DefaultExists = 'prd_bom.default_exists';
        const MenuRaws = 'prd_bom.popup.raws';
        const MenuByProducts = 'prd_bom.popup.by_products';
        const MenuLabours = 'prd_bom.popup.labours';
        const MenuPacketRaws = 'prd_bom.popup.packet_raws';
        const MenuPacketLabours = 'prd_bom.popup.packet_labours';
      end;

      TPrdBomRaw = record
        const TitlePlural = 'prd_bom_raw.title_plural';
        const TitleSingular = 'prd_bom_raw.title_singular';
        const ColPrdBomId = 'prd_bom_raw.col_prd_bom_id';
        const ColStkInventoryId = 'prd_bom_raw.col_stk_inventory_id';
        const ColSubPrdBomId = 'prd_bom_raw.col_sub_prd_bom_id';
        const ColQuantity = 'prd_bom_raw.col_quantity';
        const ColScrapRate = 'prd_bom_raw.col_scrap_rate';
        const ColBomName = 'prd_bom_raw.col_bom_name';
        const ColInventoryCode = 'prd_bom_raw.col_inventory_code';
        const ColInventoryName = 'prd_bom_raw.col_inventory_name';
        const ColSubBomName = 'prd_bom_raw.col_sub_bom_name';
        const ColGrossQuantity = 'prd_bom_raw.col_gross_quantity';
        const InventoryUnique = 'prd_bom_raw.inventory_unique';
        const SubBomSelf = 'prd_bom_raw.sub_bom_self';
        const RawIsProduct = 'prd_bom_raw.raw_is_product';
        const ColLineNo = 'prd_bom_raw.col_line_no';
      end;

      TPrdBomByProduct = record
        const TitlePlural = 'prd_bom_by_product.title_plural';
        const TitleSingular = 'prd_bom_by_product.title_singular';
        const ColPrdBomId = 'prd_bom_by_product.col_prd_bom_id';
        const ColStkInventoryId = 'prd_bom_by_product.col_stk_inventory_id';
        const ColQuantity = 'prd_bom_by_product.col_quantity';
        const ColBomName = 'prd_bom_by_product.col_bom_name';
        const ColInventoryCode = 'prd_bom_by_product.col_inventory_code';
        const ColInventoryName = 'prd_bom_by_product.col_inventory_name';
        const InventoryUnique = 'prd_bom_by_product.inventory_unique';
        const ColLineNo = 'prd_bom_by_product.col_line_no';
      end;

      TPrdBomLabour = record
        const TitlePlural = 'prd_bom_labour.title_plural';
        const TitleSingular = 'prd_bom_labour.title_singular';
        const ColPrdBomId = 'prd_bom_labour.col_prd_bom_id';
        const ColPrdLabourId = 'prd_bom_labour.col_prd_labour_id';
        const ColQuantity = 'prd_bom_labour.col_quantity';
        const ColBomName = 'prd_bom_labour.col_bom_name';
        const ColLabourCode = 'prd_bom_labour.col_labour_code';
        const ColLabourName = 'prd_bom_labour.col_labour_name';
        const ColUnitPrice = 'prd_bom_labour.col_unit_price';
        const ColCurrency = 'prd_bom_labour.col_currency';
        const ColTotalAmount = 'prd_bom_labour.col_total_amount';
        const LabourUnique = 'prd_bom_labour.labour_unique';
        const ColLineNo = 'prd_bom_labour.col_line_no';
      end;

      TPrdPacketRaw = record
        const TitlePlural = 'prd_packet_raw.title_plural';
        const TitleSingular = 'prd_packet_raw.title_singular';
        const ColPacketName = 'prd_packet_raw.col_packet_name';
        const ColItemCount = 'prd_packet_raw.col_item_count';
        const PacketNameUnique = 'prd_packet_raw.packet_name_unique';
        const MenuDetails = 'prd_packet_raw.popup.details';
      end;

      TPrdPacketRawDetail = record
        const TitlePlural = 'prd_packet_raw_detail.title_plural';
        const TitleSingular = 'prd_packet_raw_detail.title_singular';
        const ColPrdPacketRawId = 'prd_packet_raw_detail.col_prd_packet_raw_id';
        const ColStkInventoryId = 'prd_packet_raw_detail.col_stk_inventory_id';
        const ColSubPrdBomId = 'prd_packet_raw_detail.col_sub_prd_bom_id';
        const ColQuantity = 'prd_packet_raw_detail.col_quantity';
        const ColPacketName = 'prd_packet_raw_detail.col_packet_name';
        const ColInventoryCode = 'prd_packet_raw_detail.col_inventory_code';
        const ColInventoryName = 'prd_packet_raw_detail.col_inventory_name';
        const ColSubBomName = 'prd_packet_raw_detail.col_sub_bom_name';
        const InventoryUnique = 'prd_packet_raw_detail.inventory_unique';
        const ColLineNo = 'prd_packet_raw_detail.col_line_no';
      end;

      TPrdPacketLabour = record
        const TitlePlural = 'prd_packet_labour.title_plural';
        const TitleSingular = 'prd_packet_labour.title_singular';
        const ColPacketName = 'prd_packet_labour.col_packet_name';
        const ColItemCount = 'prd_packet_labour.col_item_count';
        const PacketNameUnique = 'prd_packet_labour.packet_name_unique';
        const MenuDetails = 'prd_packet_labour.popup.details';
      end;

      TPrdPacketLabourDetail = record
        const TitlePlural = 'prd_packet_labour_detail.title_plural';
        const TitleSingular = 'prd_packet_labour_detail.title_singular';
        const ColPrdPacketLabourId = 'prd_packet_labour_detail.col_prd_packet_labour_id';
        const ColPrdLabourId = 'prd_packet_labour_detail.col_prd_labour_id';
        const ColQuantity = 'prd_packet_labour_detail.col_quantity';
        const ColPacketName = 'prd_packet_labour_detail.col_packet_name';
        const ColLabourCode = 'prd_packet_labour_detail.col_labour_code';
        const ColLabourName = 'prd_packet_labour_detail.col_labour_name';
        const ColUnitPrice = 'prd_packet_labour_detail.col_unit_price';
        const ColCurrency = 'prd_packet_labour_detail.col_currency';
        const ColTotalAmount = 'prd_packet_labour_detail.col_total_amount';
        const LabourUnique = 'prd_packet_labour_detail.labour_unique';
        const ColLineNo = 'prd_packet_labour_detail.col_line_no';
      end;

      TPrdBomPacketRaw = record
        const TitlePlural = 'prd_bom_packet_raw.title_plural';
        const TitleSingular = 'prd_bom_packet_raw.title_singular';
        const ColPrdBomId = 'prd_bom_packet_raw.col_prd_bom_id';
        const ColPrdPacketRawId = 'prd_bom_packet_raw.col_prd_packet_raw_id';
        const ColQuantity = 'prd_bom_packet_raw.col_quantity';
        const ColBomName = 'prd_bom_packet_raw.col_bom_name';
        const ColPacketName = 'prd_bom_packet_raw.col_packet_name';
        const PacketUnique = 'prd_bom_packet_raw.packet_unique';
        const ColLineNo = 'prd_bom_packet_raw.col_line_no';
      end;

      TPrdBomPacketLabour = record
        const TitlePlural = 'prd_bom_packet_labour.title_plural';
        const TitleSingular = 'prd_bom_packet_labour.title_singular';
        const ColPrdBomId = 'prd_bom_packet_labour.col_prd_bom_id';
        const ColPrdPacketLabourId = 'prd_bom_packet_labour.col_prd_packet_labour_id';
        const ColQuantity = 'prd_bom_packet_labour.col_quantity';
        const ColBomName = 'prd_bom_packet_labour.col_bom_name';
        const ColPacketName = 'prd_bom_packet_labour.col_packet_name';
        const PacketUnique = 'prd_bom_packet_labour.packet_unique';
        const ColLineNo = 'prd_bom_packet_labour.col_line_no';
      end;

      //Finance Module
      TFinOption = record
        const DocCheque = 'fin_option.doc_cheque';
        const DocNote = 'fin_option.doc_note';
        const DirReceived = 'fin_option.dir_received';
        const DirGiven = 'fin_option.dir_given';
        const StatusInPortfolio = 'fin_option.status_in_portfolio';
        const StatusEndorsed = 'fin_option.status_endorsed';
        const StatusAtBankCollection = 'fin_option.status_at_bank_collection';
        const StatusAtBankCollateral = 'fin_option.status_at_bank_collateral';
        const StatusCollected = 'fin_option.status_collected';
        const StatusBounced = 'fin_option.status_bounced';
        const StatusReturned = 'fin_option.status_returned';
        const StatusPaid = 'fin_option.status_paid';
        const StatusIssued = 'fin_option.status_issued';
        const CardTxSpending = 'fin_option.card_tx_spending';
        const CardTxPayment = 'fin_option.card_tx_payment';
        const CardTxRefund = 'fin_option.card_tx_refund';
        const PosTxCollection = 'fin_option.pos_tx_collection';
        const PosTxRefund = 'fin_option.pos_tx_refund';
      end;

      TFinChequeNote = record
        const TitlePlural = 'fin_cheque_note.title_plural';
        const TitleSingular = 'fin_cheque_note.title_singular';
        const ColDocKind = 'fin_cheque_note.col_doc_kind';
        const ColDirection = 'fin_cheque_note.col_direction';
        const ColPortfolioNo = 'fin_cheque_note.col_portfolio_no';
        const ColSerialNo = 'fin_cheque_note.col_serial_no';
        const ColIssueDate = 'fin_cheque_note.col_issue_date';
        const ColDueDate = 'fin_cheque_note.col_due_date';
        const ColAmount = 'fin_cheque_note.col_amount';
        const ColCurrency = 'fin_cheque_note.col_currency';
        const ColAccAccountId = 'fin_cheque_note.col_acc_account_id';
        const ColDrawerName = 'fin_cheque_note.col_drawer_name';
        const ColDrawerTaxNo = 'fin_cheque_note.col_drawer_tax_no';
        const ColIssuePlace = 'fin_cheque_note.col_issue_place';
        const ColAccBankId = 'fin_cheque_note.col_acc_bank_id';
        const ColAccBankBranchId = 'fin_cheque_note.col_acc_bank_branch_id';
        const ColBankAccountNo = 'fin_cheque_note.col_bank_account_no';
        const ColGuarantorName = 'fin_cheque_note.col_guarantor_name';
        const ColStatus = 'fin_cheque_note.col_status';
        const ColNotes = 'fin_cheque_note.col_notes';
        const ColAccountCode = 'fin_cheque_note.col_account_code';
        const ColAccountName = 'fin_cheque_note.col_account_name';
        const ColBankName = 'fin_cheque_note.col_bank_name';
        const ColBranchName = 'fin_cheque_note.col_branch_name';
        const ColCurrentHolder = 'fin_cheque_note.col_current_holder';
        const ColDaysToDue = 'fin_cheque_note.col_days_to_due';
        const ColStatusDate = 'fin_cheque_note.col_status_date';
        const TitleCustomerCheques = 'fin_cheque_note.title_customer_cheques';
        const TitleOwnCheques = 'fin_cheque_note.title_own_cheques';
        const TitleCustomerNotes = 'fin_cheque_note.title_customer_notes';
        const TitleDebitNotes = 'fin_cheque_note.title_debit_notes';
        const MenuTransactions = 'fin_cheque_note.popup.transactions';
        const SerialUnique = 'fin_cheque_note.serial_unique';
        const PortfolioNoUnique = 'fin_cheque_note.portfolio_no_unique';
        const BankRequired = 'fin_cheque_note.bank_required';
        const DueBeforeIssue = 'fin_cheque_note.due_before_issue';
        const BranchBank = 'fin_cheque_note.branch_bank';
        const HasTransactions = 'fin_cheque_note.has_transactions';
        const KeyFieldsLocked = 'fin_cheque_note.key_fields_locked';
        const ColFinCompanyBankAccountId = 'fin_cheque_note.col_fin_company_bank_account_id';
        const ColCompanyBankIban = 'fin_cheque_note.col_company_bank_iban';
        const CompanyBankPassive = 'fin_cheque_note.company_bank_passive';
        const CompanyBankUsage = 'fin_cheque_note.company_bank_usage';
        const CompanyBankCurrency = 'fin_cheque_note.company_bank_currency';
      end;

      TFinChequeNoteTransaction = record
        const TitlePlural = 'fin_cheque_note_transaction.title_plural';
        const TitleSingular = 'fin_cheque_note_transaction.title_singular';
        const ColFinChequeNoteId = 'fin_cheque_note_transaction.col_fin_cheque_note_id';
        const ColTransactionDate = 'fin_cheque_note_transaction.col_transaction_date';
        const ColTransactionType = 'fin_cheque_note_transaction.col_transaction_type';
        const ColAccAccountId = 'fin_cheque_note_transaction.col_acc_account_id';
        const ColAccBankId = 'fin_cheque_note_transaction.col_acc_bank_id';
        const ColDescription = 'fin_cheque_note_transaction.col_description';
        const ColPortfolioNo = 'fin_cheque_note_transaction.col_portfolio_no';
        const ColSerialNo = 'fin_cheque_note_transaction.col_serial_no';
        const ColAccountCode = 'fin_cheque_note_transaction.col_account_code';
        const ColAccountName = 'fin_cheque_note_transaction.col_account_name';
        const ColBankName = 'fin_cheque_note_transaction.col_bank_name';
        const ColDocKind = 'fin_cheque_note_transaction.col_doc_kind';
        const ColDirection = 'fin_cheque_note_transaction.col_direction';
        const ColDueDate = 'fin_cheque_note_transaction.col_due_date';
        const ColAmount = 'fin_cheque_note_transaction.col_amount';
        const ColCurrency = 'fin_cheque_note_transaction.col_currency';
        const OnlyLast = 'fin_cheque_note_transaction.only_last';
        const OpeningLocked = 'fin_cheque_note_transaction.opening_locked';
        const NoteChanged = 'fin_cheque_note_transaction.note_changed';
        const InvalidTransition = 'fin_cheque_note_transaction.invalid_transition';
        const DateBeforePrevious = 'fin_cheque_note_transaction.date_before_previous';
      end;

      TFinCreditCard = record
        const TitlePlural = 'fin_credit_card.title_plural';
        const TitleSingular = 'fin_credit_card.title_singular';
        const ColCardName = 'fin_credit_card.col_card_name';
        const ColAccBankId = 'fin_credit_card.col_acc_bank_id';
        const ColCardHolder = 'fin_credit_card.col_card_holder';
        const ColCardLastDigits = 'fin_credit_card.col_card_last_digits';
        const ColCardLimit = 'fin_credit_card.col_card_limit';
        const ColStatementDay = 'fin_credit_card.col_statement_day';
        const ColPaymentDay = 'fin_credit_card.col_payment_day';
        const ColCurrency = 'fin_credit_card.col_currency';
        const ColAccAccountCode = 'fin_credit_card.col_acc_account_code';
        const ColIsActive = 'fin_credit_card.col_is_active';
        const ColNotes = 'fin_credit_card.col_notes';
        const ColBankName = 'fin_credit_card.col_bank_name';
        const ColAccountName = 'fin_credit_card.col_account_name';
        const ColTotalSpending = 'fin_credit_card.col_total_spending';
        const ColTotalPayment = 'fin_credit_card.col_total_payment';
        const ColBalance = 'fin_credit_card.col_balance';
        const ColAvailableLimit = 'fin_credit_card.col_available_limit';
        const MenuTransactions = 'fin_credit_card.popup.transactions';
        const NameUnique = 'fin_credit_card.name_unique';
        const HasTransactions = 'fin_credit_card.has_transactions';
        const LastDigitsInvalid = 'fin_credit_card.last_digits_invalid';
        const DayInvalid = 'fin_credit_card.day_invalid';
      end;

      TFinCreditCardTransaction = record
        const TitlePlural = 'fin_credit_card_transaction.title_plural';
        const TitleSingular = 'fin_credit_card_transaction.title_singular';
        const ColFinCreditCardId = 'fin_credit_card_transaction.col_fin_credit_card_id';
        const ColTransactionDate = 'fin_credit_card_transaction.col_transaction_date';
        const ColTransactionType = 'fin_credit_card_transaction.col_transaction_type';
        const ColAccAccountId = 'fin_credit_card_transaction.col_acc_account_id';
        const ColAmount = 'fin_credit_card_transaction.col_amount';
        const ColInstallmentCount = 'fin_credit_card_transaction.col_installment_count';
        const ColDescription = 'fin_credit_card_transaction.col_description';
        const ColCardName = 'fin_credit_card_transaction.col_card_name';
        const ColCurrency = 'fin_credit_card_transaction.col_currency';
        const ColAccountCode = 'fin_credit_card_transaction.col_account_code';
        const ColAccountName = 'fin_credit_card_transaction.col_account_name';
        const ColInstallmentAmount = 'fin_credit_card_transaction.col_installment_amount';
        const CardPassive = 'fin_credit_card_transaction.card_passive';
        const InstallmentRange = 'fin_credit_card_transaction.installment_range';
        const InstallmentOnlySpending = 'fin_credit_card_transaction.installment_only_spending';
        const LimitExceeded = 'fin_credit_card_transaction.limit_exceeded';
      end;

      TFinPosTerminal = record
        const TitlePlural = 'fin_pos_terminal.title_plural';
        const TitleSingular = 'fin_pos_terminal.title_singular';
        const ColPosName = 'fin_pos_terminal.col_pos_name';
        const ColAccBankId = 'fin_pos_terminal.col_acc_bank_id';
        const ColTerminalNo = 'fin_pos_terminal.col_terminal_no';
        const ColCommissionRate = 'fin_pos_terminal.col_commission_rate';
        const ColBlockedDays = 'fin_pos_terminal.col_blocked_days';
        const ColCurrency = 'fin_pos_terminal.col_currency';
        const ColAccAccountCode = 'fin_pos_terminal.col_acc_account_code';
        const ColIsActive = 'fin_pos_terminal.col_is_active';
        const ColNotes = 'fin_pos_terminal.col_notes';
        const ColBankName = 'fin_pos_terminal.col_bank_name';
        const ColAccountName = 'fin_pos_terminal.col_account_name';
        const ColTotalAmount = 'fin_pos_terminal.col_total_amount';
        const ColTotalCommission = 'fin_pos_terminal.col_total_commission';
        const ColTotalNet = 'fin_pos_terminal.col_total_net';
        const MenuTransactions = 'fin_pos_terminal.popup.transactions';
        const NameUnique = 'fin_pos_terminal.name_unique';
        const HasTransactions = 'fin_pos_terminal.has_transactions';
        const RateRange = 'fin_pos_terminal.rate_range';
        const BlockedDaysRange = 'fin_pos_terminal.blocked_days_range';
      end;

      TFinPosTransaction = record
        const TitlePlural = 'fin_pos_transaction.title_plural';
        const TitleSingular = 'fin_pos_transaction.title_singular';
        const ColFinPosTerminalId = 'fin_pos_transaction.col_fin_pos_terminal_id';
        const ColTransactionDate = 'fin_pos_transaction.col_transaction_date';
        const ColTransactionType = 'fin_pos_transaction.col_transaction_type';
        const ColAccAccountId = 'fin_pos_transaction.col_acc_account_id';
        const ColAmount = 'fin_pos_transaction.col_amount';
        const ColInstallmentCount = 'fin_pos_transaction.col_installment_count';
        const ColCommissionRate = 'fin_pos_transaction.col_commission_rate';
        const ColCommissionAmount = 'fin_pos_transaction.col_commission_amount';
        const ColNetAmount = 'fin_pos_transaction.col_net_amount';
        const ColValueDate = 'fin_pos_transaction.col_value_date';
        const ColCardHolder = 'fin_pos_transaction.col_card_holder';
        const ColCardLastDigits = 'fin_pos_transaction.col_card_last_digits';
        const ColDescription = 'fin_pos_transaction.col_description';
        const ColPosName = 'fin_pos_transaction.col_pos_name';
        const ColCurrency = 'fin_pos_transaction.col_currency';
        const ColAccountCode = 'fin_pos_transaction.col_account_code';
        const ColAccountName = 'fin_pos_transaction.col_account_name';
        const PosPassive = 'fin_pos_transaction.pos_passive';
        const InstallmentRange = 'fin_pos_transaction.installment_range';
        const RateRange = 'fin_pos_transaction.rate_range';
        const LastDigitsInvalid = 'fin_pos_transaction.last_digits_invalid';
        const ValueDateBefore = 'fin_pos_transaction.value_date_before';
      end;

      //Finance Module (cash / bank)
      TFinMoneyOption = record
        const KindCash = 'fin_money_option.kind_cash';
        const KindBank = 'fin_money_option.kind_bank';
        const TxCollection = 'fin_money_option.tx_collection';
        const TxPayment = 'fin_money_option.tx_payment';
        const TxTransfer = 'fin_money_option.tx_transfer';
        const TxExpense = 'fin_money_option.tx_expense';
        const TxInterest = 'fin_money_option.tx_interest';
        const TxOtherIn = 'fin_money_option.tx_other_in';
        const TxOtherOut = 'fin_money_option.tx_other_out';
        const MethodCash = 'fin_money_option.method_cash';
        const MethodWire = 'fin_money_option.method_wire';
        const MethodEft = 'fin_money_option.method_eft';
        const MethodFast = 'fin_money_option.method_fast';
        const MethodSwift = 'fin_money_option.method_swift';
        const DirIn = 'fin_money_option.dir_in';
        const DirOut = 'fin_money_option.dir_out';
      end;

      TFinMoneyAccount = record
        const TitlePlural = 'fin_money_account.title_plural';
        const TitleSingular = 'fin_money_account.title_singular';
        const ColAccountKind = 'fin_money_account.col_account_kind';
        const ColCode = 'fin_money_account.col_code';
        const ColName = 'fin_money_account.col_name';
        const ColAccBankId = 'fin_money_account.col_acc_bank_id';
        const ColAccBankBranchId = 'fin_money_account.col_acc_bank_branch_id';
        const ColAccountNo = 'fin_money_account.col_account_no';
        const ColIban = 'fin_money_account.col_iban';
        const ColCurrency = 'fin_money_account.col_currency';
        const ColAccAccountCode = 'fin_money_account.col_acc_account_code';
        const ColIsActive = 'fin_money_account.col_is_active';
        const ColNotes = 'fin_money_account.col_notes';
        const ColBankName = 'fin_money_account.col_bank_name';
        const ColBranchName = 'fin_money_account.col_branch_name';
        const ColAccountName = 'fin_money_account.col_account_name';
        const ColTotalIn = 'fin_money_account.col_total_in';
        const ColTotalOut = 'fin_money_account.col_total_out';
        const ColBalance = 'fin_money_account.col_balance';
        const MenuLedger = 'fin_money_account.popup.ledger';
        const MenuTransactions = 'fin_money_account.popup.transactions';
        const CodeUnique = 'fin_money_account.code_unique';
        const NameUnique = 'fin_money_account.name_unique';
        const IbanUnique = 'fin_money_account.iban_unique';
        const IbanInvalid = 'fin_money_account.iban_invalid';
        const BankRequired = 'fin_money_account.bank_required';
        const BranchBank = 'fin_money_account.branch_bank';
        const HasTransactions = 'fin_money_account.has_transactions';
        const CurrencyLocked = 'fin_money_account.currency_locked';
      end;

      TFinMoneyTransaction = record
        const TitlePlural = 'fin_money_transaction.title_plural';
        const TitleSingular = 'fin_money_transaction.title_singular';
        const ColFinMoneyAccountId = 'fin_money_transaction.col_fin_money_account_id';
        const ColTransactionDate = 'fin_money_transaction.col_transaction_date';
        const ColTransactionType = 'fin_money_transaction.col_transaction_type';
        const ColTransferMethod = 'fin_money_transaction.col_transfer_method';
        const ColAccAccountId = 'fin_money_transaction.col_acc_account_id';
        const ColTargetFinMoneyAccountId = 'fin_money_transaction.col_target_fin_money_account_id';
        const ColAmount = 'fin_money_transaction.col_amount';
        const ColDocumentNo = 'fin_money_transaction.col_document_no';
        const ColCounterpartyName = 'fin_money_transaction.col_counterparty_name';
        const ColCounterpartyIban = 'fin_money_transaction.col_counterparty_iban';
        const ColDescription = 'fin_money_transaction.col_description';
        const ColMoneyAccountName = 'fin_money_transaction.col_money_account_name';
        const ColCurrency = 'fin_money_transaction.col_currency';
        const ColAccountCode = 'fin_money_transaction.col_account_code';
        const ColAccountName = 'fin_money_transaction.col_account_name';
        const ColTargetMoneyAccountName = 'fin_money_transaction.col_target_money_account_name';
        const ColAccountKind = 'fin_money_transaction.col_account_kind';
        const AccountPassive = 'fin_money_transaction.account_passive';
        const SameAccount = 'fin_money_transaction.same_account';
        const CurrencyMismatch = 'fin_money_transaction.currency_mismatch';
        const IbanInvalid = 'fin_money_transaction.iban_invalid';
        const CashInsufficient = 'fin_money_transaction.cash_insufficient';
      end;

      TFinMoneyLedger = record
        const TitlePlural = 'fin_money_ledger.title_plural';
        const TitleSingular = 'fin_money_ledger.title_singular';
        const ColFinMoneyTransactionId = 'fin_money_ledger.col_fin_money_transaction_id';
        const ColFinMoneyAccountId = 'fin_money_ledger.col_fin_money_account_id';
        const ColTransactionDate = 'fin_money_ledger.col_transaction_date';
        const ColTransactionType = 'fin_money_ledger.col_transaction_type';
        const ColTransferMethod = 'fin_money_ledger.col_transfer_method';
        const ColDirection = 'fin_money_ledger.col_direction';
        const ColAmountIn = 'fin_money_ledger.col_amount_in';
        const ColAmountOut = 'fin_money_ledger.col_amount_out';
        const ColBalance = 'fin_money_ledger.col_balance';
        const ColOtherFinMoneyAccountId = 'fin_money_ledger.col_other_fin_money_account_id';
        const ColAccAccountId = 'fin_money_ledger.col_acc_account_id';
        const ColDocumentNo = 'fin_money_ledger.col_document_no';
        const ColCounterpartyName = 'fin_money_ledger.col_counterparty_name';
        const ColDescription = 'fin_money_ledger.col_description';
        const ColMoneyAccountName = 'fin_money_ledger.col_money_account_name';
        const ColCurrency = 'fin_money_ledger.col_currency';
        const ColOtherMoneyAccountName = 'fin_money_ledger.col_other_money_account_name';
        const ColAccountCode = 'fin_money_ledger.col_account_code';
        const ColAccountName = 'fin_money_ledger.col_account_name';
        const ReadOnly = 'fin_money_ledger.read_only';
      end;

      //Purchasing Module
      TPurOption = record
        const ReqDraft = 'pur_option.req_draft';
        const ReqApproved = 'pur_option.req_approved';
        const ReqRejected = 'pur_option.req_rejected';
        const ReqOrdered = 'pur_option.req_ordered';
        const ReqClosed = 'pur_option.req_closed';
        const OrdDraft = 'pur_option.ord_draft';
        const OrdApproved = 'pur_option.ord_approved';
        const OrdPartial = 'pur_option.ord_partial';
        const OrdReceived = 'pur_option.ord_received';
        const OrdCancelled = 'pur_option.ord_cancelled';
      end;

      TPurRequest = record
        const TitlePlural = 'pur_request.title_plural';
        const TitleSingular = 'pur_request.title_singular';
        const ColRequestNo = 'pur_request.col_request_no';
        const ColRequestDate = 'pur_request.col_request_date';
        const ColEmpEmployeeId = 'pur_request.col_emp_employee_id';
        const ColRequiredDate = 'pur_request.col_required_date';
        const ColStatus = 'pur_request.col_status';
        const ColDescription = 'pur_request.col_description';
        const ColEmployeeName = 'pur_request.col_employee_name';
        const ColLineCount = 'pur_request.col_line_count';
        const MenuLines = 'pur_request.popup.lines';
        const MenuApprove = 'pur_request.popup.approve';
        const MenuToDraft = 'pur_request.popup.to_draft';
        const MenuReject = 'pur_request.popup.reject';
        const MenuClose = 'pur_request.popup.close';
        const MenuToOrder = 'pur_request.popup.to_order';
        const NoUnique = 'pur_request.no_unique';
        const DraftOnly = 'pur_request.draft_only';
        const NoLines = 'pur_request.no_lines';
        const HasOrders = 'pur_request.has_orders';
        const RequiredDate = 'pur_request.required_date';
        const InvalidStatus = 'pur_request.invalid_status';
      end;

      TPurRequestDetail = record
        const TitlePlural = 'pur_request_detail.title_plural';
        const TitleSingular = 'pur_request_detail.title_singular';
        const ColPurRequestId = 'pur_request_detail.col_pur_request_id';
        const ColStkInventoryId = 'pur_request_detail.col_stk_inventory_id';
        const ColQuantity = 'pur_request_detail.col_quantity';
        const ColOrderedQuantity = 'pur_request_detail.col_ordered_quantity';
        const ColRequiredDate = 'pur_request_detail.col_required_date';
        const ColDescription = 'pur_request_detail.col_description';
        const ColRequestNo = 'pur_request_detail.col_request_no';
        const ColInventoryCode = 'pur_request_detail.col_inventory_code';
        const ColInventoryName = 'pur_request_detail.col_inventory_name';
        const ColUomCode = 'pur_request_detail.col_uom_code';
        const ColRemainingQuantity = 'pur_request_detail.col_remaining_quantity';
        const ColRequestStatus = 'pur_request_detail.col_request_status';
        const DraftOnly = 'pur_request_detail.draft_only';
        const InventoryUnique = 'pur_request_detail.inventory_unique';
        const ColLineNo = 'pur_request_detail.col_line_no';
        const LineUnique = 'pur_request_detail.line_unique';
      end;

      TPurOrder = record
        const TitlePlural = 'pur_order.title_plural';
        const TitleSingular = 'pur_order.title_singular';
        const ColOrderNo = 'pur_order.col_order_no';
        const ColOrderDate = 'pur_order.col_order_date';
        const ColAccAccountId = 'pur_order.col_acc_account_id';
        const ColSupplierRefNo = 'pur_order.col_supplier_ref_no';
        const ColDeliveryDate = 'pur_order.col_delivery_date';
        const ColStkWarehouseId = 'pur_order.col_stk_warehouse_id';
        const ColCurrency = 'pur_order.col_currency';
        const ColExchangeRate = 'pur_order.col_exchange_rate';
        const ColPaymentTermDays = 'pur_order.col_payment_term_days';
        const ColStatus = 'pur_order.col_status';
        const ColGrossAmount = 'pur_order.col_gross_amount';
        const ColDiscountAmount = 'pur_order.col_discount_amount';
        const ColNetAmount = 'pur_order.col_net_amount';
        const ColVatAmount = 'pur_order.col_vat_amount';
        const ColTotalAmount = 'pur_order.col_total_amount';
        const ColDescription = 'pur_order.col_description';
        const ColAccountCode = 'pur_order.col_account_code';
        const ColAccountName = 'pur_order.col_account_name';
        const ColWarehouseName = 'pur_order.col_warehouse_name';
        const ColLineCount = 'pur_order.col_line_count';
        const MenuLines = 'pur_order.popup.lines';
        const MenuReceipts = 'pur_order.popup.receipts';
        const MenuApprove = 'pur_order.popup.approve';
        const MenuToDraft = 'pur_order.popup.to_draft';
        const MenuCancel = 'pur_order.popup.cancel';
        const MenuToReceipt = 'pur_order.popup.to_receipt';
        const NoUnique = 'pur_order.no_unique';
        const NoLines = 'pur_order.no_lines';
        const HasReceipts = 'pur_order.has_receipts';
        const DeleteStatus = 'pur_order.delete_status';
        const NotEditable = 'pur_order.not_editable';
        const KeyFieldsLocked = 'pur_order.key_fields_locked';
        const PaymentTerm = 'pur_order.payment_term';
        const DeliveryDate = 'pur_order.delivery_date';
        const RequestNotApproved = 'pur_order.request_not_approved';
        const NothingToOrder = 'pur_order.nothing_to_order';
        const InvalidStatus = 'pur_order.invalid_status';
      end;

      TPurOrderDetail = record
        const TitlePlural = 'pur_order_detail.title_plural';
        const TitleSingular = 'pur_order_detail.title_singular';
        const ColPurOrderId = 'pur_order_detail.col_pur_order_id';
        const ColLineNo = 'pur_order_detail.col_line_no';
        const ColStkInventoryId = 'pur_order_detail.col_stk_inventory_id';
        const ColQuantity = 'pur_order_detail.col_quantity';
        const ColUnitPrice = 'pur_order_detail.col_unit_price';
        const ColDiscountRate = 'pur_order_detail.col_discount_rate';
        const ColVatRate = 'pur_order_detail.col_vat_rate';
        const ColGrossAmount = 'pur_order_detail.col_gross_amount';
        const ColDiscountAmount = 'pur_order_detail.col_discount_amount';
        const ColNetAmount = 'pur_order_detail.col_net_amount';
        const ColVatAmount = 'pur_order_detail.col_vat_amount';
        const ColTotalAmount = 'pur_order_detail.col_total_amount';
        const ColReceivedQuantity = 'pur_order_detail.col_received_quantity';
        const ColDeliveryDate = 'pur_order_detail.col_delivery_date';
        const ColPurRequestDetailId = 'pur_order_detail.col_pur_request_detail_id';
        const ColDescription = 'pur_order_detail.col_description';
        const ColOrderNo = 'pur_order_detail.col_order_no';
        const ColCurrency = 'pur_order_detail.col_currency';
        const ColInventoryCode = 'pur_order_detail.col_inventory_code';
        const ColInventoryName = 'pur_order_detail.col_inventory_name';
        const ColUomCode = 'pur_order_detail.col_uom_code';
        const ColRequestNo = 'pur_order_detail.col_request_no';
        const ColRemainingQuantity = 'pur_order_detail.col_remaining_quantity';
        const ColOrderStatus = 'pur_order_detail.col_order_status';
        const RateRange = 'pur_order_detail.rate_range';
        const LineUnique = 'pur_order_detail.line_unique';
        const DraftOnly = 'pur_order_detail.draft_only';
        const InventoryMismatch = 'pur_order_detail.inventory_mismatch';
      end;

      TPurReceipt = record
        const TitlePlural = 'pur_receipt.title_plural';
        const TitleSingular = 'pur_receipt.title_singular';
        const ColReceiptNo = 'pur_receipt.col_receipt_no';
        const ColReceiptDate = 'pur_receipt.col_receipt_date';
        const ColAccAccountId = 'pur_receipt.col_acc_account_id';
        const ColStkWarehouseId = 'pur_receipt.col_stk_warehouse_id';
        const ColWaybillNo = 'pur_receipt.col_waybill_no';
        const ColPurOrderId = 'pur_receipt.col_pur_order_id';
        const ColCurrency = 'pur_receipt.col_currency';
        const ColDescription = 'pur_receipt.col_description';
        const ColAccountCode = 'pur_receipt.col_account_code';
        const ColAccountName = 'pur_receipt.col_account_name';
        const ColWarehouseName = 'pur_receipt.col_warehouse_name';
        const ColOrderNo = 'pur_receipt.col_order_no';
        const ColLineCount = 'pur_receipt.col_line_count';
        const ColTotalAmount = 'pur_receipt.col_total_amount';
        const MenuLines = 'pur_receipt.popup.lines';
        const MenuToInvoice = 'pur_receipt.popup.to_invoice';
        const NoUnique = 'pur_receipt.no_unique';
        const OrderSupplier = 'pur_receipt.order_supplier';
        const OrderStatus = 'pur_receipt.order_status';
        const KeyFieldsLocked = 'pur_receipt.key_fields_locked';
        const HasInvoices = 'pur_receipt.has_invoices';
        const NothingToReceive = 'pur_receipt.nothing_to_receive';
      end;

      TPurReceiptDetail = record
        const TitlePlural = 'pur_receipt_detail.title_plural';
        const TitleSingular = 'pur_receipt_detail.title_singular';
        const ColPurReceiptId = 'pur_receipt_detail.col_pur_receipt_id';
        const ColStkInventoryId = 'pur_receipt_detail.col_stk_inventory_id';
        const ColQuantity = 'pur_receipt_detail.col_quantity';
        const ColUnitPrice = 'pur_receipt_detail.col_unit_price';
        const ColPurOrderDetailId = 'pur_receipt_detail.col_pur_order_detail_id';
        const ColDescription = 'pur_receipt_detail.col_description';
        const ColReceiptNo = 'pur_receipt_detail.col_receipt_no';
        const ColCurrency = 'pur_receipt_detail.col_currency';
        const ColInventoryCode = 'pur_receipt_detail.col_inventory_code';
        const ColInventoryName = 'pur_receipt_detail.col_inventory_name';
        const ColUomCode = 'pur_receipt_detail.col_uom_code';
        const ColOrderNo = 'pur_receipt_detail.col_order_no';
        const ColAmount = 'pur_receipt_detail.col_amount';
        const ColOrderLineNo = 'pur_receipt_detail.col_order_line_no';
        const ColInvoicedQuantity = 'pur_receipt_detail.col_invoiced_quantity';
        const ColRemainingInvoiceQuantity = 'pur_receipt_detail.col_remaining_invoice_quantity';
        const InventoryMismatch = 'pur_receipt_detail.inventory_mismatch';
        const OrderMismatch = 'pur_receipt_detail.order_mismatch';
        const Invoiced = 'pur_receipt_detail.invoiced';
        const OverReceipt = 'pur_receipt_detail.over_receipt';
        const ColLineNo = 'pur_receipt_detail.col_line_no';
        const LineUnique = 'pur_receipt_detail.line_unique';
      end;

      TPurInvoice = record
        const TitlePlural = 'pur_invoice.title_plural';
        const TitleSingular = 'pur_invoice.title_singular';
        const ColInvoiceNo = 'pur_invoice.col_invoice_no';
        const ColInvoiceDate = 'pur_invoice.col_invoice_date';
        const ColAccAccountId = 'pur_invoice.col_acc_account_id';
        const ColDueDate = 'pur_invoice.col_due_date';
        const ColCurrency = 'pur_invoice.col_currency';
        const ColExchangeRate = 'pur_invoice.col_exchange_rate';
        const ColGrossAmount = 'pur_invoice.col_gross_amount';
        const ColDiscountAmount = 'pur_invoice.col_discount_amount';
        const ColNetAmount = 'pur_invoice.col_net_amount';
        const ColVatAmount = 'pur_invoice.col_vat_amount';
        const ColTotalAmount = 'pur_invoice.col_total_amount';
        const ColDescription = 'pur_invoice.col_description';
        const ColAccountCode = 'pur_invoice.col_account_code';
        const ColAccountName = 'pur_invoice.col_account_name';
        const ColLineCount = 'pur_invoice.col_line_count';
        const MenuLines = 'pur_invoice.popup.lines';
        const NoUnique = 'pur_invoice.no_unique';
        const DueDate = 'pur_invoice.due_date';
        const KeyFieldsLocked = 'pur_invoice.key_fields_locked';
        const NothingToInvoice = 'pur_invoice.nothing_to_invoice';
      end;

      TPurInvoiceDetail = record
        const TitlePlural = 'pur_invoice_detail.title_plural';
        const TitleSingular = 'pur_invoice_detail.title_singular';
        const ColPurInvoiceId = 'pur_invoice_detail.col_pur_invoice_id';
        const ColLineNo = 'pur_invoice_detail.col_line_no';
        const ColStkInventoryId = 'pur_invoice_detail.col_stk_inventory_id';
        const ColQuantity = 'pur_invoice_detail.col_quantity';
        const ColUnitPrice = 'pur_invoice_detail.col_unit_price';
        const ColDiscountRate = 'pur_invoice_detail.col_discount_rate';
        const ColVatRate = 'pur_invoice_detail.col_vat_rate';
        const ColGrossAmount = 'pur_invoice_detail.col_gross_amount';
        const ColDiscountAmount = 'pur_invoice_detail.col_discount_amount';
        const ColNetAmount = 'pur_invoice_detail.col_net_amount';
        const ColVatAmount = 'pur_invoice_detail.col_vat_amount';
        const ColTotalAmount = 'pur_invoice_detail.col_total_amount';
        const ColPurReceiptDetailId = 'pur_invoice_detail.col_pur_receipt_detail_id';
        const ColDescription = 'pur_invoice_detail.col_description';
        const ColInvoiceNo = 'pur_invoice_detail.col_invoice_no';
        const ColCurrency = 'pur_invoice_detail.col_currency';
        const ColInventoryCode = 'pur_invoice_detail.col_inventory_code';
        const ColInventoryName = 'pur_invoice_detail.col_inventory_name';
        const ColUomCode = 'pur_invoice_detail.col_uom_code';
        const ColReceiptNo = 'pur_invoice_detail.col_receipt_no';
        const RateRange = 'pur_invoice_detail.rate_range';
        const LineUnique = 'pur_invoice_detail.line_unique';
        const InventoryMismatch = 'pur_invoice_detail.inventory_mismatch';
        const SupplierMismatch = 'pur_invoice_detail.supplier_mismatch';
        const OverInvoice = 'pur_invoice_detail.over_invoice';
      end;

      //Finance Module (company bank accounts)
      TFinCompanyBankAccount = record
        const TitlePlural = 'fin_company_bank_account.title_plural';
        const TitleSingular = 'fin_company_bank_account.title_singular';
        const ColAccBankId = 'fin_company_bank_account.col_acc_bank_id';
        const ColBranchCode = 'fin_company_bank_account.col_branch_code';
        const ColBranchName = 'fin_company_bank_account.col_branch_name';
        const ColSysCityId = 'fin_company_bank_account.col_sys_city_id';
        const ColAccountNo = 'fin_company_bank_account.col_account_no';
        const ColIban = 'fin_company_bank_account.col_iban';
        const ColCurrency = 'fin_company_bank_account.col_currency';
        const ColAccountHolder = 'fin_company_bank_account.col_account_holder';
        const ColShowOnCheque = 'fin_company_bank_account.col_show_on_cheque';
        const ColShowOnNote = 'fin_company_bank_account.col_show_on_note';
        const ColShowOnPrint = 'fin_company_bank_account.col_show_on_print';
        const ColSortOrder = 'fin_company_bank_account.col_sort_order';
        const ColIsActive = 'fin_company_bank_account.col_is_active';
        const ColDescription = 'fin_company_bank_account.col_description';
        const ColBankName = 'fin_company_bank_account.col_bank_name';
        const ColCityName = 'fin_company_bank_account.col_city_name';
        const ColPrintText = 'fin_company_bank_account.col_print_text';
        const ColSwiftCode = 'fin_company_bank_account.col_swift_code';
        const IbanInvalid = 'fin_company_bank_account.iban_invalid';
        const IbanUnique = 'fin_company_bank_account.iban_unique';
        const SortRange = 'fin_company_bank_account.sort_range';
        const InUse = 'fin_company_bank_account.in_use';
        const CurrencyLocked = 'fin_company_bank_account.currency_locked';
      end;

      //Account Module (account transactions)
      TAccAccountTransaction = record
        const TitlePlural = 'acc_account_transaction.title_plural';
        const TitleSingular = 'acc_account_transaction.title_singular';
        const ColAccAccountId = 'acc_account_transaction.col_acc_account_id';
        const ColTransactionDate = 'acc_account_transaction.col_transaction_date';
        const ColSourceType = 'acc_account_transaction.col_source_type';
        const ColSourceId = 'acc_account_transaction.col_source_id';
        const ColDocumentId = 'acc_account_transaction.col_document_id';
        const ColDocumentNo = 'acc_account_transaction.col_document_no';
        const ColDescription = 'acc_account_transaction.col_description';
        const ColCurrency = 'acc_account_transaction.col_currency';
        const ColDebit = 'acc_account_transaction.col_debit';
        const ColCredit = 'acc_account_transaction.col_credit';
        const ColBalance = 'acc_account_transaction.col_balance';
        const ColAccountCode = 'acc_account_transaction.col_account_code';
        const ColAccountName = 'acc_account_transaction.col_account_name';
        const MenuShowSource = 'acc_account_transaction.popup.show_source';
        const ReadOnly = 'acc_account_transaction.read_only';
        const UnknownSource = 'acc_account_transaction.unknown_source';
      end;

      //Sales Module
      TSlsOption = record
        const OffDraft = 'sls_option.off_draft';
        const OffSent = 'sls_option.off_sent';
        const OffRejected = 'sls_option.off_rejected';
        const OffOrdered = 'sls_option.off_ordered';
        const OffClosed = 'sls_option.off_closed';
        const OrdDraft = 'sls_option.ord_draft';
        const OrdApproved = 'sls_option.ord_approved';
        const OrdPartial = 'sls_option.ord_partial';
        const OrdDelivered = 'sls_option.ord_delivered';
        const OrdCancelled = 'sls_option.ord_cancelled';
        const DspWaiting = 'sls_option.dsp_waiting';
        const DspClosed = 'sls_option.dsp_closed';
        const SaleDomestic = 'sls_option.sale_domestic';
        const SaleExport = 'sls_option.sale_export';
        const SaleExportRegistered = 'sls_option.sale_export_registered';
        const SaleExempt = 'sls_option.sale_exempt';
        const SaleWithholding = 'sls_option.sale_withholding';
      end;

      TSlsOffer = record
        const TitlePlural = 'sls_offer.title_plural';
        const TitleSingular = 'sls_offer.title_singular';
        const ColOfferNo = 'sls_offer.col_offer_no';
        const ColOfferDate = 'sls_offer.col_offer_date';
        const ColValidUntil = 'sls_offer.col_valid_until';
        const ColAccAccountId = 'sls_offer.col_acc_account_id';
        const ColCustomerRefNo = 'sls_offer.col_customer_ref_no';
        const ColEmpEmployeeId = 'sls_offer.col_emp_employee_id';
        const ColCurrency = 'sls_offer.col_currency';
        const ColExchangeRate = 'sls_offer.col_exchange_rate';
        const ColPaymentTermDays = 'sls_offer.col_payment_term_days';
        const ColStatus = 'sls_offer.col_status';
        const ColGrossAmount = 'sls_offer.col_gross_amount';
        const ColDiscountAmount = 'sls_offer.col_discount_amount';
        const ColNetAmount = 'sls_offer.col_net_amount';
        const ColVatAmount = 'sls_offer.col_vat_amount';
        const ColTotalAmount = 'sls_offer.col_total_amount';
        const ColDescription = 'sls_offer.col_description';
        const ColAccountCode = 'sls_offer.col_account_code';
        const ColAccountName = 'sls_offer.col_account_name';
        const ColEmployeeName = 'sls_offer.col_employee_name';
        const ColLineCount = 'sls_offer.col_line_count';
        const ColBillingAddress = 'sls_offer.col_billing_address';
        const ColShippingAddress = 'sls_offer.col_shipping_address';
        const ColBaseCurrency = 'sls_offer.col_base_currency';
        const ColUsdRate = 'sls_offer.col_usd_rate';
        const ColEurRate = 'sls_offer.col_eur_rate';
        const ColTotalAmountBase = 'sls_offer.col_total_amount_base';
        const TabGeneral = 'sls_offer.tab_general';
        const ColDeliveryDate = 'sls_offer.col_delivery_date';
        const ColEinvPaymentMeansId = 'sls_offer.col_einv_payment_means_id';
        const ColEinvDeliveryTermId = 'sls_offer.col_einv_delivery_term_id';
        const ColTaxOffice = 'sls_offer.col_tax_office';
        const ColTaxNo = 'sls_offer.col_tax_no';
        const ColTaxOfficeNo = 'sls_offer.col_tax_office_no';
        const ColSaleType = 'sls_offer.col_sale_type';
        const ColDeliveryTermIncoterms = 'sls_offer.col_delivery_term_incoterms';
        const MenuLines = 'sls_offer.popup.lines';
        const MenuSend = 'sls_offer.popup.send';
        const MenuToDraft = 'sls_offer.popup.to_draft';
        const MenuReject = 'sls_offer.popup.reject';
        const MenuClose = 'sls_offer.popup.close';
        const MenuToOrder = 'sls_offer.popup.to_order';
        const QuickDraft = 'sls_offer.quick.draft';
        const QuickSent = 'sls_offer.quick.sent';
        const QuickOrdered = 'sls_offer.quick.ordered';
        const QuickClosed = 'sls_offer.quick.closed';
        const NoUnique = 'sls_offer.no_unique';
        const DraftOnly = 'sls_offer.draft_only';
        const NoLines = 'sls_offer.no_lines';
        const HasOrders = 'sls_offer.has_orders';
        const ValidUntil = 'sls_offer.valid_until';
        const DeliveryDate = 'sls_offer.delivery_date';
        const DeliveryTerm = 'sls_offer.delivery_term';
        const PaymentTerm = 'sls_offer.payment_term';
        const InvalidStatus = 'sls_offer.invalid_status';
        const AddressAccount = 'sls_offer.address_account';
        const AddressCity = 'sls_offer.address_city';
        const NoExchangeRate = 'sls_offer.no_exchange_rate';
      end;

      TSlsOfferDetail = record
        const TitlePlural = 'sls_offer_detail.title_plural';
        const TitleSingular = 'sls_offer_detail.title_singular';
        const ColSlsOfferId = 'sls_offer_detail.col_sls_offer_id';
        const ColLineNo = 'sls_offer_detail.col_line_no';
        const ColStkInventoryId = 'sls_offer_detail.col_stk_inventory_id';
        const ColQuantity = 'sls_offer_detail.col_quantity';
        const ColUnitPrice = 'sls_offer_detail.col_unit_price';
        const ColDiscountRate = 'sls_offer_detail.col_discount_rate';
        const ColVatRate = 'sls_offer_detail.col_vat_rate';
        const ColGrossAmount = 'sls_offer_detail.col_gross_amount';
        const ColDiscountAmount = 'sls_offer_detail.col_discount_amount';
        const ColNetAmount = 'sls_offer_detail.col_net_amount';
        const ColVatAmount = 'sls_offer_detail.col_vat_amount';
        const ColTotalAmount = 'sls_offer_detail.col_total_amount';
        const ColOrderedQuantity = 'sls_offer_detail.col_ordered_quantity';
        const ColDescription = 'sls_offer_detail.col_description';
        const ColOfferNo = 'sls_offer_detail.col_offer_no';
        const ColCurrency = 'sls_offer_detail.col_currency';
        const ColInventoryCode = 'sls_offer_detail.col_inventory_code';
        const ColInventoryName = 'sls_offer_detail.col_inventory_name';
        const ColUomCode = 'sls_offer_detail.col_uom_code';
        const ColRemainingQuantity = 'sls_offer_detail.col_remaining_quantity';
        const ColOfferStatus = 'sls_offer_detail.col_offer_status';
        const RateRange = 'sls_offer_detail.rate_range';
        const LineUnique = 'sls_offer_detail.line_unique';
        const DraftOnly = 'sls_offer_detail.draft_only';
        const VatRateUndefined = 'sls_offer_detail.vat_rate_undefined';
      end;

      TSlsOrder = record
        const TitlePlural = 'sls_order.title_plural';
        const TitleSingular = 'sls_order.title_singular';
        const ColOrderNo = 'sls_order.col_order_no';
        const ColOrderDate = 'sls_order.col_order_date';
        const ColAccAccountId = 'sls_order.col_acc_account_id';
        const ColCustomerRefNo = 'sls_order.col_customer_ref_no';
        const ColDeliveryDate = 'sls_order.col_delivery_date';
        const ColStkWarehouseId = 'sls_order.col_stk_warehouse_id';
        const ColEmpEmployeeId = 'sls_order.col_emp_employee_id';
        const ColCurrency = 'sls_order.col_currency';
        const ColExchangeRate = 'sls_order.col_exchange_rate';
        const ColPaymentTermDays = 'sls_order.col_payment_term_days';
        const ColStatus = 'sls_order.col_status';
        const ColGrossAmount = 'sls_order.col_gross_amount';
        const ColDiscountAmount = 'sls_order.col_discount_amount';
        const ColNetAmount = 'sls_order.col_net_amount';
        const ColVatAmount = 'sls_order.col_vat_amount';
        const ColTotalAmount = 'sls_order.col_total_amount';
        const ColDescription = 'sls_order.col_description';
        const ColAccountCode = 'sls_order.col_account_code';
        const ColAccountName = 'sls_order.col_account_name';
        const ColWarehouseName = 'sls_order.col_warehouse_name';
        const ColEmployeeName = 'sls_order.col_employee_name';
        const ColLineCount = 'sls_order.col_line_count';
        const MenuLines = 'sls_order.popup.lines';
        const MenuDispatches = 'sls_order.popup.dispatches';
        const MenuApprove = 'sls_order.popup.approve';
        const MenuToDraft = 'sls_order.popup.to_draft';
        const MenuCancel = 'sls_order.popup.cancel';
        const MenuToDispatch = 'sls_order.popup.to_dispatch';
        const MenuToInvoice = 'sls_order.popup.to_invoice';
        const QuickUnapproved = 'sls_order.quick.unapproved';
        const QuickPending = 'sls_order.quick.pending';
        const QuickDelivered = 'sls_order.quick.delivered';
        const NoUnique = 'sls_order.no_unique';
        const NoLines = 'sls_order.no_lines';
        const HasDeliveries = 'sls_order.has_deliveries';
        const DeleteStatus = 'sls_order.delete_status';
        const NotEditable = 'sls_order.not_editable';
        const KeyFieldsLocked = 'sls_order.key_fields_locked';
        const PaymentTerm = 'sls_order.payment_term';
        const DeliveryDate = 'sls_order.delivery_date';
        const OfferNotSent = 'sls_order.offer_not_sent';
        const NothingToOrder = 'sls_order.nothing_to_order';
        const InvalidStatus = 'sls_order.invalid_status';
      end;

      TSlsOrderDetail = record
        const TitlePlural = 'sls_order_detail.title_plural';
        const TitleSingular = 'sls_order_detail.title_singular';
        const ColSlsOrderId = 'sls_order_detail.col_sls_order_id';
        const ColLineNo = 'sls_order_detail.col_line_no';
        const ColStkInventoryId = 'sls_order_detail.col_stk_inventory_id';
        const ColQuantity = 'sls_order_detail.col_quantity';
        const ColUnitPrice = 'sls_order_detail.col_unit_price';
        const ColDiscountRate = 'sls_order_detail.col_discount_rate';
        const ColVatRate = 'sls_order_detail.col_vat_rate';
        const ColGrossAmount = 'sls_order_detail.col_gross_amount';
        const ColDiscountAmount = 'sls_order_detail.col_discount_amount';
        const ColNetAmount = 'sls_order_detail.col_net_amount';
        const ColVatAmount = 'sls_order_detail.col_vat_amount';
        const ColTotalAmount = 'sls_order_detail.col_total_amount';
        const ColDeliveredQuantity = 'sls_order_detail.col_delivered_quantity';
        const ColDeliveryDate = 'sls_order_detail.col_delivery_date';
        const ColSlsOfferDetailId = 'sls_order_detail.col_sls_offer_detail_id';
        const ColDescription = 'sls_order_detail.col_description';
        const ColOrderNo = 'sls_order_detail.col_order_no';
        const ColCurrency = 'sls_order_detail.col_currency';
        const ColInventoryCode = 'sls_order_detail.col_inventory_code';
        const ColInventoryName = 'sls_order_detail.col_inventory_name';
        const ColUomCode = 'sls_order_detail.col_uom_code';
        const ColOfferNo = 'sls_order_detail.col_offer_no';
        const ColRemainingQuantity = 'sls_order_detail.col_remaining_quantity';
        const ColOrderStatus = 'sls_order_detail.col_order_status';
        const RateRange = 'sls_order_detail.rate_range';
        const LineUnique = 'sls_order_detail.line_unique';
        const DraftOnly = 'sls_order_detail.draft_only';
        const InventoryMismatch = 'sls_order_detail.inventory_mismatch';
      end;

      TSlsDispatch = record
        const TitlePlural = 'sls_dispatch.title_plural';
        const TitleSingular = 'sls_dispatch.title_singular';
        const ColDispatchNo = 'sls_dispatch.col_dispatch_no';
        const ColDispatchDate = 'sls_dispatch.col_dispatch_date';
        const ColAccAccountId = 'sls_dispatch.col_acc_account_id';
        const ColStkWarehouseId = 'sls_dispatch.col_stk_warehouse_id';
        const ColSlsOrderId = 'sls_dispatch.col_sls_order_id';
        const ColCurrency = 'sls_dispatch.col_currency';
        const ColDescription = 'sls_dispatch.col_description';
        const ColAccountCode = 'sls_dispatch.col_account_code';
        const ColAccountName = 'sls_dispatch.col_account_name';
        const ColWarehouseName = 'sls_dispatch.col_warehouse_name';
        const ColOrderNo = 'sls_dispatch.col_order_no';
        const ColLineCount = 'sls_dispatch.col_line_count';
        const ColTotalAmount = 'sls_dispatch.col_total_amount';
        const MenuLines = 'sls_dispatch.popup.lines';
        const MenuToInvoice = 'sls_dispatch.popup.to_invoice';
        const NoUnique = 'sls_dispatch.no_unique';
        const OrderCustomer = 'sls_dispatch.order_customer';
        const OrderStatus = 'sls_dispatch.order_status';
        const KeyFieldsLocked = 'sls_dispatch.key_fields_locked';
        const HasInvoices = 'sls_dispatch.has_invoices';
        const NothingToDispatch = 'sls_dispatch.nothing_to_dispatch';
        const ColStatus = 'sls_dispatch.col_status';
        const QuickWaiting = 'sls_dispatch.quick.waiting';
        const QuickClosed = 'sls_dispatch.quick.closed';
        const ColEinvProfileId = 'sls_dispatch.col_einv_profile_id';
        const ColProfileCode = 'sls_dispatch.col_profile_code';
        const ColEinvUuid = 'sls_dispatch.col_einv_uuid';
        const ColEinvStatus = 'sls_dispatch.col_einv_status';
        const ColEinvNo = 'sls_dispatch.col_einv_no';
        const ColDespatchTime = 'sls_dispatch.col_despatch_time';
        const ColCarrierAccAccountId = 'sls_dispatch.col_carrier_acc_account_id';
        const ColCarrierCode = 'sls_dispatch.col_carrier_code';
        const ColCarrierName = 'sls_dispatch.col_carrier_name';
        const ColEinvVehicleId = 'sls_dispatch.col_einv_vehicle_id';
        const ColVehiclePlate = 'sls_dispatch.col_vehicle_plate';
        const ColTrailer1EinvVehicleId = 'sls_dispatch.col_trailer1_einv_vehicle_id';
        const ColTrailer1Plate = 'sls_dispatch.col_trailer1_plate';
        const ColTrailer2EinvVehicleId = 'sls_dispatch.col_trailer2_einv_vehicle_id';
        const ColTrailer2Plate = 'sls_dispatch.col_trailer2_plate';
        const ColDriver1EinvDriverId = 'sls_dispatch.col_driver1_einv_driver_id';
        const ColDriver1Name = 'sls_dispatch.col_driver1_name';
        const ColDriver2EinvDriverId = 'sls_dispatch.col_driver2_einv_driver_id';
        const ColDriver2Name = 'sls_dispatch.col_driver2_name';
        const ColAccountEDespatchActive = 'sls_dispatch.col_account_e_despatch_active';
        const ColEinvXmlValid = 'sls_dispatch.col_einv_xml_valid';
        const TabGeneral = 'sls_dispatch.tab_general';
        const TabEDespatch = 'sls_dispatch.tab_edespatch';
        const EInvLocked = 'sls_dispatch.einv_locked';
        const EInvProfileKind = 'sls_dispatch.einv_profile_kind';
        const EInvInactive = 'sls_dispatch.einv_inactive';
        const TransportRequired = 'sls_dispatch.transport_required';
        const VehicleIsTrailer = 'sls_dispatch.vehicle_is_trailer';
        const TrailerNotTrailer = 'sls_dispatch.trailer_not_trailer';
        const TrailerDuplicate = 'sls_dispatch.trailer_duplicate';
        const DriverDuplicate = 'sls_dispatch.driver_duplicate';
        const MsgEInvNoDocument = 'sls_dispatch.msg_einv_no_document';
      end;

      TSlsDispatchDetail = record
        const TitlePlural = 'sls_dispatch_detail.title_plural';
        const TitleSingular = 'sls_dispatch_detail.title_singular';
        const ColSlsDispatchId = 'sls_dispatch_detail.col_sls_dispatch_id';
        const ColStkInventoryId = 'sls_dispatch_detail.col_stk_inventory_id';
        const ColQuantity = 'sls_dispatch_detail.col_quantity';
        const ColUnitPrice = 'sls_dispatch_detail.col_unit_price';
        const ColSlsOrderDetailId = 'sls_dispatch_detail.col_sls_order_detail_id';
        const ColDescription = 'sls_dispatch_detail.col_description';
        const ColDispatchNo = 'sls_dispatch_detail.col_dispatch_no';
        const ColCurrency = 'sls_dispatch_detail.col_currency';
        const ColInventoryCode = 'sls_dispatch_detail.col_inventory_code';
        const ColInventoryName = 'sls_dispatch_detail.col_inventory_name';
        const ColUomCode = 'sls_dispatch_detail.col_uom_code';
        const ColOrderNo = 'sls_dispatch_detail.col_order_no';
        const ColAmount = 'sls_dispatch_detail.col_amount';
        const ColOrderLineNo = 'sls_dispatch_detail.col_order_line_no';
        const ColInvoicedQuantity = 'sls_dispatch_detail.col_invoiced_quantity';
        const ColRemainingInvoiceQuantity = 'sls_dispatch_detail.col_remaining_invoice_quantity';
        const InventoryMismatch = 'sls_dispatch_detail.inventory_mismatch';
        const OrderMismatch = 'sls_dispatch_detail.order_mismatch';
        const Invoiced = 'sls_dispatch_detail.invoiced';
        const OverDelivery = 'sls_dispatch_detail.over_delivery';
        const ColLineNo = 'sls_dispatch_detail.col_line_no';
        const LineUnique = 'sls_dispatch_detail.line_unique';
      end;

      TSlsInvoice = record
        const TitlePlural = 'sls_invoice.title_plural';
        const TitleSingular = 'sls_invoice.title_singular';
        const ColInvoiceNo = 'sls_invoice.col_invoice_no';
        const ColInvoiceDate = 'sls_invoice.col_invoice_date';
        const ColAccAccountId = 'sls_invoice.col_acc_account_id';
        const ColDueDate = 'sls_invoice.col_due_date';
        const ColStkWarehouseId = 'sls_invoice.col_stk_warehouse_id';
        const ColCurrency = 'sls_invoice.col_currency';
        const ColExchangeRate = 'sls_invoice.col_exchange_rate';
        const ColGrossAmount = 'sls_invoice.col_gross_amount';
        const ColDiscountAmount = 'sls_invoice.col_discount_amount';
        const ColNetAmount = 'sls_invoice.col_net_amount';
        const ColVatAmount = 'sls_invoice.col_vat_amount';
        const ColTotalAmount = 'sls_invoice.col_total_amount';
        const ColDescription = 'sls_invoice.col_description';
        const ColAccountCode = 'sls_invoice.col_account_code';
        const ColAccountName = 'sls_invoice.col_account_name';
        const ColWarehouseName = 'sls_invoice.col_warehouse_name';
        const ColLineCount = 'sls_invoice.col_line_count';
        const MenuLines = 'sls_invoice.popup.lines';
        const NoUnique = 'sls_invoice.no_unique';
        const DueDate = 'sls_invoice.due_date';
        const KeyFieldsLocked = 'sls_invoice.key_fields_locked';
        const NothingToInvoice = 'sls_invoice.nothing_to_invoice';
        const WarehouseRequired = 'sls_invoice.warehouse_required';
        const OrderStatus = 'sls_invoice.order_status';
        const ColEinvProfileId = 'sls_invoice.col_einv_profile_id';
        const ColEinvInvoiceTypeId = 'sls_invoice.col_einv_invoice_type_id';
        const ColEinvUuid = 'sls_invoice.col_einv_uuid';
        const ColEinvStatus = 'sls_invoice.col_einv_status';
        const ColEinvTaxExemptionId = 'sls_invoice.col_einv_tax_exemption_id';
        const ColEinvDeliveryTermId = 'sls_invoice.col_einv_delivery_term_id';
        const ColEinvTransportModeId = 'sls_invoice.col_einv_transport_mode_id';
        const ColEinvPaymentMeansId = 'sls_invoice.col_einv_payment_means_id';
        const ColCustomsDeclarationNo = 'sls_invoice.col_customs_declaration_no';
        const ColGtbRefNo = 'sls_invoice.col_gtb_ref_no';
        const ColActualExportDate = 'sls_invoice.col_actual_export_date';
        const ColWithholdingAmount = 'sls_invoice.col_withholding_amount';
        const ColProfileCode = 'sls_invoice.col_profile_code';
        const ColInvoiceTypeCode = 'sls_invoice.col_invoice_type_code';
        const ColTaxExemptionCode = 'sls_invoice.col_tax_exemption_code';
        const ColTaxExemptionName = 'sls_invoice.col_tax_exemption_name';
        const ColDeliveryTermCode = 'sls_invoice.col_delivery_term_code';
        const ColTransportModeName = 'sls_invoice.col_transport_mode_name';
        const ColPaymentMeansName = 'sls_invoice.col_payment_means_name';
        const ColPayableAmount = 'sls_invoice.col_payable_amount';
        const ColAccountEInvoiceActive = 'sls_invoice.col_account_e_invoice_active';
        const TabGeneral = 'sls_invoice.tab_general';
        const TabEInvoice = 'sls_invoice.tab_einvoice';
        const EInvLocked = 'sls_invoice.einv_locked';
        const EInvProfileKind = 'sls_invoice.einv_profile_kind';
        const EInvInactive = 'sls_invoice.einv_inactive';
        const ExemptionTypeMismatch = 'sls_invoice.exemption_type_mismatch';
        const WithholdingRequired = 'sls_invoice.withholding_required';
        const WithholdingNotAllowed = 'sls_invoice.withholding_not_allowed';
        const WithholdingNoVat = 'sls_invoice.withholding_no_vat';
        const DeliveryNotIncoterms = 'sls_invoice.delivery_not_incoterms';
        const LineGtipRequired = 'sls_invoice.line_gtip_required';
        const LineDiibRequired = 'sls_invoice.line_diib_required';
        const ExemptionNeedsZeroVat = 'sls_invoice.exemption_needs_zero_vat';
        const LinePackageRequired = 'sls_invoice.line_package_required';
        const DiibHolderMismatch = 'sls_invoice.diib_holder_mismatch';
        const DiibGtipMismatch = 'sls_invoice.diib_gtip_mismatch';
        const DiibExpired = 'sls_invoice.diib_expired';
        const ColEinvNo = 'sls_invoice.col_einv_no';
        const ColEinvXmlValid = 'sls_invoice.col_einv_xml_valid';
        const MenuEInvPreview = 'sls_invoice.menu_einv_preview';
        const MenuEInvSaveXml = 'sls_invoice.menu_einv_save_xml';
        const MenuEInvRegenerate = 'sls_invoice.menu_einv_regenerate';
        const MenuEInvValidation = 'sls_invoice.menu_einv_validation';
        const MsgEInvNoDocument = 'sls_invoice.msg_einv_no_document';
        const MsgEInvValid = 'sls_invoice.msg_einv_valid';
        const MsgEInvInvalid = 'sls_invoice.msg_einv_invalid';
      end;

      TSlsInvoiceDetail = record
        const TitlePlural = 'sls_invoice_detail.title_plural';
        const TitleSingular = 'sls_invoice_detail.title_singular';
        const ColSlsInvoiceId = 'sls_invoice_detail.col_sls_invoice_id';
        const ColLineNo = 'sls_invoice_detail.col_line_no';
        const ColStkInventoryId = 'sls_invoice_detail.col_stk_inventory_id';
        const ColQuantity = 'sls_invoice_detail.col_quantity';
        const ColUnitPrice = 'sls_invoice_detail.col_unit_price';
        const ColDiscountRate = 'sls_invoice_detail.col_discount_rate';
        const ColVatRate = 'sls_invoice_detail.col_vat_rate';
        const ColGrossAmount = 'sls_invoice_detail.col_gross_amount';
        const ColDiscountAmount = 'sls_invoice_detail.col_discount_amount';
        const ColNetAmount = 'sls_invoice_detail.col_net_amount';
        const ColVatAmount = 'sls_invoice_detail.col_vat_amount';
        const ColTotalAmount = 'sls_invoice_detail.col_total_amount';
        const ColSlsDispatchDetailId = 'sls_invoice_detail.col_sls_dispatch_detail_id';
        const ColSlsOrderDetailId = 'sls_invoice_detail.col_sls_order_detail_id';
        const ColDescription = 'sls_invoice_detail.col_description';
        const ColInvoiceNo = 'sls_invoice_detail.col_invoice_no';
        const ColCurrency = 'sls_invoice_detail.col_currency';
        const ColInventoryCode = 'sls_invoice_detail.col_inventory_code';
        const ColInventoryName = 'sls_invoice_detail.col_inventory_name';
        const ColUomCode = 'sls_invoice_detail.col_uom_code';
        const ColDispatchNo = 'sls_invoice_detail.col_dispatch_no';
        const ColOrderNo = 'sls_invoice_detail.col_order_no';
        const RateRange = 'sls_invoice_detail.rate_range';
        const LineUnique = 'sls_invoice_detail.line_unique';
        const InventoryMismatch = 'sls_invoice_detail.inventory_mismatch';
        const CustomerMismatch = 'sls_invoice_detail.customer_mismatch';
        const SourceConflict = 'sls_invoice_detail.source_conflict';
        const WarehouseRequired = 'sls_invoice_detail.warehouse_required';
        const OrderStatus = 'sls_invoice_detail.order_status';
        const OverInvoice = 'sls_invoice_detail.over_invoice';
        const OverDelivery = 'sls_invoice_detail.over_delivery';
        const ColEinvGtipId = 'sls_invoice_detail.col_einv_gtip_id';
        const ColEinvWithholdingId = 'sls_invoice_detail.col_einv_withholding_id';
        const ColWithholdingAmount = 'sls_invoice_detail.col_withholding_amount';
        const ColSellerEinvDiibLineId = 'sls_invoice_detail.col_seller_einv_diib_line_id';
        const ColBuyerEinvDiibLineId = 'sls_invoice_detail.col_buyer_einv_diib_line_id';
        const ColEinvPackagingTypeId = 'sls_invoice_detail.col_einv_packaging_type_id';
        const ColPackageNo = 'sls_invoice_detail.col_package_no';
        const ColPackageQuantity = 'sls_invoice_detail.col_package_quantity';
        const ColPackageBrand = 'sls_invoice_detail.col_package_brand';
        const ColGtipCode = 'sls_invoice_detail.col_gtip_code';
        const ColWithholdingCode = 'sls_invoice_detail.col_withholding_code';
        const ColWithholdingRate = 'sls_invoice_detail.col_withholding_rate';
        const ColSellerDiibLineCode = 'sls_invoice_detail.col_seller_diib_line_code';
        const ColBuyerDiibLineCode = 'sls_invoice_detail.col_buyer_diib_line_code';
        const ColDiibProductDescription = 'sls_invoice_detail.col_diib_product_description';
        const ColPackagingTypeCode = 'sls_invoice_detail.col_packaging_type_code';
        const ColUomEinvCode = 'sls_invoice_detail.col_uom_einv_code';
        const TabEInvoice = 'sls_invoice_detail.tab_einvoice';
      end;

      //e-Document Module (UBL-TR code lists, GTIP, DIIB)
      TEInvOption = record
        const DocInvoice = 'einv_option.doc_invoice';
        const DocDespatch = 'einv_option.doc_despatch';
        const ExgrpVatPartial = 'einv_option.exgrp_vat_partial';
        const ExgrpVatFull = 'einv_option.exgrp_vat_full';
        const ExgrpOther = 'einv_option.exgrp_other';
        const ExgrpSct = 'einv_option.exgrp_sct';
        const ExgrpLodging = 'einv_option.exgrp_lodging';
        const ExgrpSpecialBase = 'einv_option.exgrp_special_base';
        const ExgrpExportReg = 'einv_option.exgrp_export_reg';
        const DiibOwn = 'einv_option.diib_own';
        const DiibCustomer = 'einv_option.diib_customer';
        const DiibLineExport = 'einv_option.diib_line_export';
        const DiibLineImport = 'einv_option.diib_line_import';
        const StatusDraft = 'einv_option.status_draft';
        const StatusQueued = 'einv_option.status_queued';
        const StatusSent = 'einv_option.status_sent';
        const StatusAccepted = 'einv_option.status_accepted';
        const StatusRejected = 'einv_option.status_rejected';
        const StatusError = 'einv_option.status_error';
        const StatusCancelled = 'einv_option.status_cancelled';
        const SeriesInvoice = 'einv_option.series_invoice';
        const SeriesArchive = 'einv_option.series_archive';
        const SeriesDespatch = 'einv_option.series_despatch';
      end;

      TEInvProfile = record
        const TitlePlural = 'einv_profile.title_plural';
        const TitleSingular = 'einv_profile.title_singular';
        const ColCode = 'einv_profile.col_code';
        const ColName = 'einv_profile.col_name';
        const ColDocumentKind = 'einv_profile.col_document_kind';
        const ColRequiresExportInfo = 'einv_profile.col_requires_export_info';
        const ColIsActive = 'einv_profile.col_is_active';
        const CodeUnique = 'einv_profile.code_unique';
        const InUse = 'einv_profile.in_use';
      end;

      TEInvInvoiceType = record
        const TitlePlural = 'einv_invoice_type.title_plural';
        const TitleSingular = 'einv_invoice_type.title_singular';
        const ColCode = 'einv_invoice_type.col_code';
        const ColName = 'einv_invoice_type.col_name';
        const ColRequiresExemption = 'einv_invoice_type.col_requires_exemption';
        const ColRequiresWithholding = 'einv_invoice_type.col_requires_withholding';
        const ColIsReturn = 'einv_invoice_type.col_is_return';
        const ColIsActive = 'einv_invoice_type.col_is_active';
        const CodeUnique = 'einv_invoice_type.code_unique';
        const InUse = 'einv_invoice_type.in_use';
      end;

      TEInvTaxExemption = record
        const TitlePlural = 'einv_tax_exemption.title_plural';
        const TitleSingular = 'einv_tax_exemption.title_singular';
        const ColCode = 'einv_tax_exemption.col_code';
        const ColName = 'einv_tax_exemption.col_name';
        const ColExemptionGroup = 'einv_tax_exemption.col_exemption_group';
        const ColEinvInvoiceTypeId = 'einv_tax_exemption.col_einv_invoice_type_id';
        const ColRequiresGtip = 'einv_tax_exemption.col_requires_gtip';
        const ColRequiresDiib = 'einv_tax_exemption.col_requires_diib';
        const ColRequiresZeroVat = 'einv_tax_exemption.col_requires_zero_vat';
        const ColIsActive = 'einv_tax_exemption.col_is_active';
        const ColInvoiceTypeCode = 'einv_tax_exemption.col_invoice_type_code';
        const CodeUnique = 'einv_tax_exemption.code_unique';
        const InUse = 'einv_tax_exemption.in_use';
      end;

      TEInvTaxType = record
        const TitlePlural = 'einv_tax_type.title_plural';
        const TitleSingular = 'einv_tax_type.title_singular';
        const ColCode = 'einv_tax_type.col_code';
        const ColName = 'einv_tax_type.col_name';
        const ColShortName = 'einv_tax_type.col_short_name';
        const ColIsActive = 'einv_tax_type.col_is_active';
        const CodeUnique = 'einv_tax_type.code_unique';
      end;

      TEInvWithholding = record
        const TitlePlural = 'einv_withholding.title_plural';
        const TitleSingular = 'einv_withholding.title_singular';
        const ColCode = 'einv_withholding.col_code';
        const ColName = 'einv_withholding.col_name';
        const ColRate = 'einv_withholding.col_rate';
        const ColIsActive = 'einv_withholding.col_is_active';
        const CodeUnique = 'einv_withholding.code_unique';
        const InUse = 'einv_withholding.in_use';
        const RateRange = 'einv_withholding.rate_range';
      end;

      TEInvDeliveryTerm = record
        const TitlePlural = 'einv_delivery_term.title_plural';
        const TitleSingular = 'einv_delivery_term.title_singular';
        const ColCode = 'einv_delivery_term.col_code';
        const ColName = 'einv_delivery_term.col_name';
        const ColIsIncoterms = 'einv_delivery_term.col_is_incoterms';
        const ColIsActive = 'einv_delivery_term.col_is_active';
        const CodeUnique = 'einv_delivery_term.code_unique';
        const InUse = 'einv_delivery_term.in_use';
      end;

      TEInvTransportMode = record
        const TitlePlural = 'einv_transport_mode.title_plural';
        const TitleSingular = 'einv_transport_mode.title_singular';
        const ColCode = 'einv_transport_mode.col_code';
        const ColName = 'einv_transport_mode.col_name';
        const ColIsActive = 'einv_transport_mode.col_is_active';
        const CodeUnique = 'einv_transport_mode.code_unique';
        const InUse = 'einv_transport_mode.in_use';
      end;

      TEInvPackagingType = record
        const TitlePlural = 'einv_packaging_type.title_plural';
        const TitleSingular = 'einv_packaging_type.title_singular';
        const ColCode = 'einv_packaging_type.col_code';
        const ColName = 'einv_packaging_type.col_name';
        const ColIsActive = 'einv_packaging_type.col_is_active';
        const CodeUnique = 'einv_packaging_type.code_unique';
        const InUse = 'einv_packaging_type.in_use';
      end;

      TEInvPaymentMeans = record
        const TitlePlural = 'einv_payment_means.title_plural';
        const TitleSingular = 'einv_payment_means.title_singular';
        const ColCode = 'einv_payment_means.col_code';
        const ColName = 'einv_payment_means.col_name';
        const ColIsActive = 'einv_payment_means.col_is_active';
        const CodeUnique = 'einv_payment_means.code_unique';
        const InUse = 'einv_payment_means.in_use';
      end;

      TEInvGtip = record
        const TitlePlural = 'einv_gtip.title_plural';
        const TitleSingular = 'einv_gtip.title_singular';
        const ColCode = 'einv_gtip.col_code';
        const ColName = 'einv_gtip.col_name';
        const ColIsActive = 'einv_gtip.col_is_active';
        const CodeUnique = 'einv_gtip.code_unique';
        const InUse = 'einv_gtip.in_use';
        const CodeInvalid = 'einv_gtip.code_invalid';
      end;

      TEInvDiib = record
        const TitlePlural = 'einv_diib.title_plural';
        const TitleSingular = 'einv_diib.title_singular';
        const ColDocumentNo = 'einv_diib.col_document_no';
        const ColHolderType = 'einv_diib.col_holder_type';
        const ColAccAccountId = 'einv_diib.col_acc_account_id';
        const ColIssueDate = 'einv_diib.col_issue_date';
        const ColValidUntil = 'einv_diib.col_valid_until';
        const ColDescription = 'einv_diib.col_description';
        const ColIsActive = 'einv_diib.col_is_active';
        const ColAccountCode = 'einv_diib.col_account_code';
        const ColAccountName = 'einv_diib.col_account_name';
        const ColLineCount = 'einv_diib.col_line_count';
        const MenuLines = 'einv_diib.popup.lines';
        const DocumentNoUnique = 'einv_diib.document_no_unique';
        const AccountRequired = 'einv_diib.account_required';
        const DateRange = 'einv_diib.date_range';
        const InUse = 'einv_diib.in_use';
      end;

      TEInvDiibLine = record
        const TitlePlural = 'einv_diib_line.title_plural';
        const TitleSingular = 'einv_diib_line.title_singular';
        const ColEinvDiibId = 'einv_diib_line.col_einv_diib_id';
        const ColLineCode = 'einv_diib_line.col_line_code';
        const ColLineKind = 'einv_diib_line.col_line_kind';
        const ColEinvGtipId = 'einv_diib_line.col_einv_gtip_id';
        const ColProductDescription = 'einv_diib_line.col_product_description';
        const ColStkInventoryId = 'einv_diib_line.col_stk_inventory_id';
        const ColQuantity = 'einv_diib_line.col_quantity';
        const ColSysUomId = 'einv_diib_line.col_sys_uom_id';
        const ColIsActive = 'einv_diib_line.col_is_active';
        const ColDocumentNo = 'einv_diib_line.col_document_no';
        const ColHolderType = 'einv_diib_line.col_holder_type';
        const ColAccAccountId = 'einv_diib_line.col_acc_account_id';
        const ColAccountName = 'einv_diib_line.col_account_name';
        const ColGtipCode = 'einv_diib_line.col_gtip_code';
        const ColGtipName = 'einv_diib_line.col_gtip_name';
        const ColInventoryCode = 'einv_diib_line.col_inventory_code';
        const ColInventoryName = 'einv_diib_line.col_inventory_name';
        const ColUnitCode = 'einv_diib_line.col_unit_code';
        const ColUomEinvCode = 'einv_diib_line.col_uom_einv_code';
        const ColDiibIsActive = 'einv_diib_line.col_diib_is_active';
        const ColValidUntil = 'einv_diib_line.col_valid_until';
        const LineCodeUnique = 'einv_diib_line.line_code_unique';
        const QuantityNegative = 'einv_diib_line.quantity_negative';
        const InUse = 'einv_diib_line.in_use';
        const ColLineNo = 'einv_diib_line.col_line_no';
      end;

      //e-Document Series
      TEInvSeries = record
        const TitlePlural = 'einv_series.title_plural';
        const TitleSingular = 'einv_series.title_singular';
        const ColCode = 'einv_series.col_code';
        const ColName = 'einv_series.col_name';
        const ColSeriesScope = 'einv_series.col_series_scope';
        const ColIsDefault = 'einv_series.col_is_default';
        const ColIsActive = 'einv_series.col_is_active';
        const ColLastNumber = 'einv_series.col_last_number';
        const CodeUnique = 'einv_series.code_unique';
        const InUse = 'einv_series.in_use';
        const CodeFormat = 'einv_series.code_format';
      end;

      //e-Document XML
      TEInvDocument = record
        const TitlePlural = 'einv_document.title_plural';
        const TitleSingular = 'einv_document.title_singular';
        const ColSlsInvoiceId = 'einv_document.col_sls_invoice_id';
        const ColEinvUuid = 'einv_document.col_einv_uuid';
        const ColEinvNo = 'einv_document.col_einv_no';
        const ColXmlContent = 'einv_document.col_xml_content';
        const ColIsValid = 'einv_document.col_is_valid';
        const ColValidationMessage = 'einv_document.col_validation_message';
        const ColGeneratedAt = 'einv_document.col_generated_at';
        const ColInvoiceNo = 'einv_document.col_invoice_no';
        const RoleSupplier = 'einv_document.einv_document.role_supplier';
        const RoleCustomer = 'einv_document.einv_document.role_customer';
        const RoleExportBuyer = 'einv_document.einv_document.role_export_buyer';
        const MsgPartyNotFound = 'einv_document.einv_document.msg_party_not_found';
        const MsgTaxNo = 'einv_document.einv_document.msg_tax_no';
        const MsgPersonName = 'einv_document.einv_document.msg_person_name';
        const MsgPartyName = 'einv_document.einv_document.msg_party_name';
        const MsgTaxOffice = 'einv_document.einv_document.msg_tax_office';
        const MsgAddressCity = 'einv_document.einv_document.msg_address_city';
        const MsgCityOnly = 'einv_document.einv_document.msg_city_only';
        const MsgEInvNo = 'einv_document.einv_document.msg_einv_no';
        const MsgUuid = 'einv_document.einv_document.msg_uuid';
        const MsgProfile = 'einv_document.einv_document.msg_profile';
        const MsgInvoiceType = 'einv_document.einv_document.msg_invoice_type';
        const MsgNoLines = 'einv_document.einv_document.msg_no_lines';
        const MsgUnitCode = 'einv_document.einv_document.msg_unit_code';
        const MsgExchangeRate = 'einv_document.einv_document.msg_exchange_rate';
        const MsgSchemaMissing = 'einv_document.einv_document.msg_schema_missing';
        const MsgSchemaInvalid = 'einv_document.einv_document.msg_schema_invalid';
        const MsgValidatorError = 'einv_document.einv_document.msg_validator_error';
        const RoleDespatchSupplier = 'einv_document.einv_document.role_despatch_supplier';
        const RoleDeliveryCustomer = 'einv_document.einv_document.role_delivery_customer';
        const RoleCarrier = 'einv_document.einv_document.role_carrier';
        const MsgTransport = 'einv_document.einv_document.msg_transport';
        const MsgDespatchNoLines = 'einv_document.einv_document.msg_despatch_no_lines';
      end;

      //PostgreSQL constraint errors (Db.ErrorTranslator)
      TDbError = record
        const Title = 'db_error.title';
        const FkInUse = 'db_error.fk_in_use';
        const FkMissing = 'db_error.fk_missing';
        const Unique = 'db_error.unique';
        const NotNull = 'db_error.not_null';
        const Check = 'db_error.check';
        const TechnicalDetail = 'db_error.technical_detail';
      end;

      //e-Despatch transport definitions (vehicles, drivers)
      TEInvVehicle = record
        const TitlePlural = 'einv_vehicle.title_plural';
        const TitleSingular = 'einv_vehicle.title_singular';
        const ColPlateNo = 'einv_vehicle.col_plate_no';
        const ColIsTrailer = 'einv_vehicle.col_is_trailer';
        const ColDescription = 'einv_vehicle.col_description';
        const ColIsActive = 'einv_vehicle.col_is_active';
        const PlateUnique = 'einv_vehicle.plate_unique';
        const PlateInvalid = 'einv_vehicle.plate_invalid';
        const InUse = 'einv_vehicle.in_use';
      end;

      TEInvDriver = record
        const TitlePlural = 'einv_driver.title_plural';
        const TitleSingular = 'einv_driver.title_singular';
        const ColFirstName = 'einv_driver.col_first_name';
        const ColFamilyName = 'einv_driver.col_family_name';
        const ColNationalId = 'einv_driver.col_national_id';
        const ColPhone = 'einv_driver.col_phone';
        const ColIsActive = 'einv_driver.col_is_active';
        const ColFullName = 'einv_driver.col_full_name';
        const NationalIdUnique = 'einv_driver.national_id_unique';
        const NationalIdInvalid = 'einv_driver.national_id_invalid';
        const InUse = 'einv_driver.in_use';
      end;

      //Integration (API) services - framework
      TSysOption = record
        const EnvTest = 'sys_option.env_test';
        const EnvLive = 'sys_option.env_live';
      end;

      TSysApiService = record
        const TitlePlural = 'sys_api_service.title_plural';
        const TitleSingular = 'sys_api_service.title_singular';
        const ColSysApplicationSettingId = 'sys_api_service.col_sys_application_setting_id';
        const ColServiceKind = 'sys_api_service.col_service_kind';
        const ColProviderCode = 'sys_api_service.col_provider_code';
        const ColEnvironment = 'sys_api_service.col_environment';
        const ColBaseUrl = 'sys_api_service.col_base_url';
        const ColUsername = 'sys_api_service.col_username';
        const ColTimeoutSeconds = 'sys_api_service.col_timeout_seconds';
        const ColOptions = 'sys_api_service.col_options';
        const ColDescription = 'sys_api_service.col_description';
        const ColIsActive = 'sys_api_service.col_is_active';
        const ColHasPassword = 'sys_api_service.col_has_password';
        const ColHasApiKey = 'sys_api_service.col_has_api_key';
        const ColPassword = 'sys_api_service.col_password';
        const ColApiKey = 'sys_api_service.col_api_key';
        const ColClearSecrets = 'sys_api_service.col_clear_secrets';
        const KindUnique = 'sys_api_service.kind_unique';
        const KindInvalid = 'sys_api_service.kind_invalid';
        const OptionsInvalid = 'sys_api_service.options_invalid';
        const TimeoutRange = 'sys_api_service.timeout_range';
        const NoCompany = 'sys_api_service.no_company';
      end;

      //e-Document settings per company (series, sender alias, API service)
      TEInvDocumentSetting = record
        const TitlePlural = 'einv_document_setting.title_plural';
        const TitleSingular = 'einv_document_setting.title_singular';
        const ColSysApplicationSettingId = 'einv_document_setting.col_sys_application_setting_id';
        const ColSeriesScope = 'einv_document_setting.col_series_scope';
        const ColEinvSeriesId = 'einv_document_setting.col_einv_series_id';
        const ColSysApiServiceId = 'einv_document_setting.col_sys_api_service_id';
        const ColSenderAlias = 'einv_document_setting.col_sender_alias';
        const ColReceiverAlias = 'einv_document_setting.col_receiver_alias';
        const AliasFormat = 'einv_document_setting.alias_format';
        const ColSeriesCode = 'einv_document_setting.col_series_code';
        const ColSeriesName = 'einv_document_setting.col_series_name';
        const ColServiceKind = 'einv_document_setting.col_service_kind';
        const ColProviderCode = 'einv_document_setting.col_provider_code';
        const ColEnvironment = 'einv_document_setting.col_environment';
        const ScopeUnique = 'einv_document_setting.scope_unique';
        const SeriesScope = 'einv_document_setting.series_scope';
        const NoCompany = 'einv_document_setting.no_company';
      end;

      //e-Document integrator (send / status / GIB taxpayer query)
      TEInvIntegration = record
        const NoService = 'einv_integration.no_service';
        const ServiceInactive = 'einv_integration.service_inactive';
        const UnknownProvider = 'einv_integration.unknown_provider';
        const NotEDocument = 'einv_integration.not_edocument';
        const NotSendable = 'einv_integration.not_sendable';
        const NotSent = 'einv_integration.not_sent';
        const NoSeries = 'einv_integration.no_series';
        const XmlInvalid = 'einv_integration.xml_invalid';
        const NoSenderAlias = 'einv_integration.no_sender_alias';
        const NoReceiverAlias = 'einv_integration.no_receiver_alias';
        const SendFailed = 'einv_integration.send_failed';
        const Sent = 'einv_integration.sent';
        const StatusResult = 'einv_integration.status_result';
        const TaxNoInvalid = 'einv_integration.tax_no_invalid';
        const TaxpayerNotFound = 'einv_integration.taxpayer_not_found';
        const TaxpayerFound = 'einv_integration.taxpayer_found';
        const TaxpayerApplied = 'einv_integration.taxpayer_applied';
        const ConnectionOk = 'einv_integration.connection_ok';
        const ConfirmSend = 'einv_integration.confirm_send';
        const MenuSend = 'einv_integration.popup.send';
        const MenuQueryStatus = 'einv_integration.popup.query_status';
        const MenuTestConnection = 'einv_integration.popup.test_connection';
        const BtnQueryTaxpayer = 'einv_integration.btn_query_taxpayer';
      end;
  end;

  TLocalizationManager = class
  private
    class var FLock: TObject;
    class var FInstance: TLocalizationManager;
    class var FCurrentLanguage: string;
    class var FTranslations: TDictionary<string, TDictionary<string, string>>;

    class procedure InitializeTranslations;
    class procedure LoadDefaultTranslations;
    class constructor Create;
    class destructor Destroy;
    constructor Create;
  public
    class function Instance: TLocalizationManager;
    class function NormalizeLanguageCode(const ALanguageCode: string): string;
    class function GetLanguageFilePath(const ALanguageCode: string): string;
    class function LanguageFileExists(const ALanguageCode: string): Boolean;
    class procedure EnsureLanguageLoaded(const ALanguageCode: string);
    class procedure SetLanguage(const ALanguageCode: string);
    class function GetCurrentLanguage: string;
    class function Translate(const AKey: string; const ADefault: string = ''): string; overload;
    class function Translate(const AKey: string; const AParams: array of const; const ADefault: string = ''): string; overload;
    class function GetAvailableLanguages: TArray<string>;
    class procedure AddTranslation(const ALanguageCode, AKey, AValue: string);
    class procedure LoadTranslationsFromFile(const AFileName: string);
    class procedure LoadTranslationsFromDirectory(const ADirPath: string);
  end;

implementation

uses
  Logger, MetaProvider;

class constructor TLocalizationManager.Create;
begin
  FLock := TObject.Create;
  FCurrentLanguage := 'tr-tr';
  FTranslations := TDictionary<string, TDictionary<string, string>>.Create;
  InitializeTranslations;
end;

class destructor TLocalizationManager.Destroy;
var
  LanguageDict: TDictionary<string, string>;
begin
  if Assigned(FTranslations) then
  begin
    for LanguageDict in FTranslations.Values do
      LanguageDict.Free;
    FreeAndNil(FTranslations);
  end;
  if Assigned(FLock) then
    FreeAndNil(FLock);
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
end;

constructor TLocalizationManager.Create;
begin
  inherited Create;
end;

class function TLocalizationManager.Instance: TLocalizationManager;
begin
  if not Assigned(FInstance) then
    FInstance := TLocalizationManager.Create;
  Result := FInstance;
end;

class procedure TLocalizationManager.InitializeTranslations;
begin
  LoadDefaultTranslations;
  // Eager loading removed - language JSON files are now lazy-loaded on demand when SetLanguage is called
end;

class function TLocalizationManager.NormalizeLanguageCode(const ALanguageCode: string): string;
begin
  Result := LowerCase(Trim(ALanguageCode));
  if Result = '' then
    Result := 'tr-tr';
end;

class function TLocalizationManager.GetLanguageFilePath(const ALanguageCode: string): string;
var
  LangKey: string;
  AppDir : string;
begin
  Result := '';
  LangKey := NormalizeLanguageCode(ALanguageCode);
  AppDir := ExtractFilePath(ParamStr(0));

  Result := TPath.Combine(AppDir, 'Resource\Localization\' + ALanguageCode + '.json');
  if TFile.Exists(Result) then Exit;

  Result := TPath.Combine(AppDir, 'Resource\Localization\' + LangKey + '.json');
  if TFile.Exists(Result) then Exit;

  Result := TPath.GetFullPath(TPath.Combine(AppDir, '..\..\Resource\Localization\' + ALanguageCode + '.json'));
  if TFile.Exists(Result) then Exit;

  Result := TPath.GetFullPath(TPath.Combine(AppDir, '..\..\Resource\Localization\' + LangKey + '.json'));
  if TFile.Exists(Result) then Exit;

  Result := '';
end;

class function TLocalizationManager.LanguageFileExists(const ALanguageCode: string): Boolean;
begin
  Result := GetLanguageFilePath(ALanguageCode) <> '';
end;

class procedure TLocalizationManager.EnsureLanguageLoaded(const ALanguageCode: string);
var
  LangKey : string;
  FilePath: string;
  LDict   : TDictionary<string, string>;
begin
  LangKey := NormalizeLanguageCode(ALanguageCode);

  if FTranslations.TryGetValue(LangKey, LDict) and (LDict.Count > 0) then
    Exit;

  FilePath := GetLanguageFilePath(ALanguageCode);
  if FilePath <> '' then
    LoadTranslationsFromFile(FilePath)
  else
    GLogger.WarningFmt('Localization file not found: %s', [ALanguageCode]);
end;

class procedure TLocalizationManager.LoadDefaultTranslations;
begin
  EnsureLanguageLoaded('en-US');
  EnsureLanguageLoaded('tr-TR');
end;

class procedure TLocalizationManager.SetLanguage(const ALanguageCode: string);
var
  LangKey: string;
begin
  TMonitor.Enter(FLock);
  try
    LangKey := NormalizeLanguageCode(ALanguageCode);
    EnsureLanguageLoaded(LangKey);
    FCurrentLanguage := LangKey;
    TMetaProviderManager.SetLanguage(LangKey);
  finally
    TMonitor.Exit(FLock);
  end;
end;

class function TLocalizationManager.GetCurrentLanguage: string;
begin
  TMonitor.Enter(FLock);
  try
    Result := FCurrentLanguage;
  finally
    TMonitor.Exit(FLock);
  end;
end;

class function TLocalizationManager.Translate(const AKey: string; const ADefault: string): string;
var
  LDict: TDictionary<string, string>;
begin
  TMonitor.Enter(FLock);
  try
    if FTranslations.TryGetValue(FCurrentLanguage, LDict) and LDict.TryGetValue(AKey, Result) then
      Exit;

    // Fallback to English (en-us)
    if (FCurrentLanguage <> 'en-us') and FTranslations.TryGetValue('en-us', LDict) and LDict.TryGetValue(AKey, Result) then
      Exit;

    if ADefault <> '' then
      Result := ADefault
    else
      Result := AKey;
  finally
    TMonitor.Exit(FLock);
  end;
end;

class function TLocalizationManager.Translate(const AKey: string; const AParams: array of const; const ADefault: string): string;
var
  Template: string;
begin
  Template := Translate(AKey, ADefault);
  try
    Result := Format(Template, AParams);
  except
    Result := Template;
  end;
end;

class function TLocalizationManager.GetAvailableLanguages: TArray<string>;
begin
  TMonitor.Enter(FLock);
  try
    Result := FTranslations.Keys.ToArray;
  finally
    TMonitor.Exit(FLock);
  end;
end;

class procedure TLocalizationManager.AddTranslation(const ALanguageCode, AKey, AValue: string);
begin
  TMonitor.Enter(FLock);
  try
    if not FTranslations.ContainsKey(ALanguageCode) then
      FTranslations.Add(ALanguageCode, TDictionary<string, string>.Create);

    FTranslations[ALanguageCode].AddOrSetValue(AKey, AValue);
  finally
    TMonitor.Exit(FLock);
  end;
end;

class procedure TLocalizationManager.LoadTranslationsFromFile(const AFileName: string);
var
  JsonText    : string;
  JsonObj     : TJSONObject;
  LangPair    : TJSONPair;
  TransPair   : TJSONPair;
  LangObj     : TJSONObject;
  LanguageCode: string;
  FileLangCode: string;
begin
  if not TFile.Exists(AFileName) then
    Exit;

  FileLangCode := LowerCase(TPath.GetFileNameWithoutExtension(AFileName));

  try
    JsonText := TFile.ReadAllText(AFileName, TEncoding.UTF8);
  except
    on E: Exception do
    begin
      GLogger.ErrorFmt('Lokalizasyon dosyası okunamadı [%s]: %s', [AFileName, E.Message]);
      Exit;
    end;
  end;

  JsonObj := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
  if not Assigned(JsonObj) then
  begin
    GLogger.ErrorFmt('Geçersiz JSON [%s]', [AFileName]);
    Exit;
  end;

  try
    TMonitor.Enter(FLock);
    try
      for LangPair in JsonObj do
      begin
        if LangPair.JsonValue is TJSONObject then
        begin
          LanguageCode := LangPair.JsonString.Value;
          LangObj      := LangPair.JsonValue as TJSONObject;

          if not FTranslations.ContainsKey(LanguageCode) then
            FTranslations.Add(LanguageCode, TDictionary<string, string>.Create);

          for TransPair in LangObj do
            FTranslations[LanguageCode].AddOrSetValue(TransPair.JsonString.Value, TransPair.JsonValue.Value);
        end
        else
        begin
          if not FTranslations.ContainsKey(FileLangCode) then
            FTranslations.Add(FileLangCode, TDictionary<string, string>.Create);

          FTranslations[FileLangCode].AddOrSetValue(LangPair.JsonString.Value, LangPair.JsonValue.Value);
        end;
      end;
    finally
      TMonitor.Exit(FLock);
    end;
  finally
    JsonObj.Free;
  end;
end;

class procedure TLocalizationManager.LoadTranslationsFromDirectory(const ADirPath: string);
var
  FileName: string;
begin
  if not TDirectory.Exists(ADirPath) then
    Exit;

  for FileName in TDirectory.GetFiles(ADirPath, '*.json') do
    LoadTranslationsFromFile(FileName);
end;

end.
