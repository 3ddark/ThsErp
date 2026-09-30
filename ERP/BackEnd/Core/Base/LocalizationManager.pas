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
        const MenuPersonnel = 'dashboard.menu.personnel';
        const MenuAbout = 'dashboard.menu.about';
        const MenuSettings = 'dashboard.menu.settings';
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
      end;

      TAccVoucherDetail = record
        const TitlePlural = 'acc_voucher_detail.title_plural';
        const TitleSingular = 'acc_voucher_detail.title_singular';
        const ColVoucher = 'acc_voucher_detail.col_voucher';
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
        const ColEInvoicePackageName = 'acc_account.col_e_invoice_package_name';
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
