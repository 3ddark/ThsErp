unit LocalizationManager;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Classes;

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
      end;

      TLogin = record
        const UserNotFound = 'login.user_not_found';
        const UserInactive = 'login.user_inactive';
        const InvalidPassword = 'login.invalid_password';
        const UpdateAvailable = 'login.update_available';
        const UpdateTitle = 'login.update_title';
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
        const MenuDbMonitor = 'dashboard.menu.db_monitor';
        const MenuDbBackup = 'dashboard.menu.db_backup';
        const MenuUpdate = 'dashboard.menu.update';

        const ActionUsers = 'dashboard.action.users';
        const ActionAccessRights = 'dashboard.action.access_rights';
        const ActionAppSettings = 'dashboard.action.app_settings';
        const ActionGridColumns = 'dashboard.action.grid_columns';
        const ActionGridFilters = 'dashboard.action.grid_filters';
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
      end;

      TGridColumn = record
        const ColId = 'grid_column.col_id';
      end;

      //System Module
      TSysAccessRight = record
        const TitlePlural = 'sys_access_right.title_plural';
        const TitleSingular = 'sys_access_right.title_singular';

        const ColUserId = 'sys_access_right.col_user_id';
        const ColPermissionId = 'sys_access_right.col_permission_id';
        const ColRead = 'sys_access_right.col_is_read';
        const ColAdd = 'sys_access_right.col_is_add';
        const ColUpdate = 'sys_access_right.col_is_update';
        const ColDelete = 'sys_access_right.col_is_delete';
        const ColSpecial = 'sys_access_right.col_is_special';

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

      end;

      TSysCity = record
        const TitlePlural = 'sys_city.title_plural';
        const TitleSingular = 'sys_city.title_singular';
        const ColCityName = 'sys_city.col_city_name';
        const ColPlateCode = 'sys_city.col_plate_code';
        const ColCountryId = 'sys_city.col_country_id';
        const ColRegionId = 'sys_city.col_region_id';
        const CityCountryUnique = 'sys_city.city_country.unique';
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
        const TableNameColumnName = 'sys_grid_column.table_name_column_name.unique';
        const TableNameColumnOrder = 'sys_grid_column.table_name_column_order.unique';
      end;

      TSysGridFilter = record
        const TableNameUnique = 'sys_grid_filter.table_name.unique';
      end;

      TSysGridSort = record

      end;

      TSysLanguage = record
        const TitlePlural = 'sys_language.title_plural';
        const TitleSingular = 'sys_language.title_singular';
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
        const ColCode = 'sys_permission.col_permission_code';
        const ColKey = 'sys_permission.col_permission_key';
        const ColPermissionName = 'sys_permission.col_permission_name';
        const ColGroupKey = 'sys_permission.col_group_key';
        const ColGroupName = 'sys_permission.col_group_name';
        const LblCode = 'sys_permission.lbl_code';
        const LblKey = 'sys_permission.lbl_key';
        const LblNameEN = 'sys_permission.lbl_name_en';
        const LblNameTR = 'sys_permission.lbl_name_tr';
        const LblGroupId = 'sys_permission.lbl_group_id';
        const CodeRequired = 'sys_permission.code.required';
        const CodePositive = 'sys_permission.code.positive';
        const KeyRequired = 'sys_permission.key.required';
        const GroupRequired = 'sys_permission.group.required';
        const KeyUnique = 'sys_permission.key_unique';
      end;

      TSysPermissionGroup = record
        const TitlePlural = 'sys_permission_group.title_plural';
        const TitleSingular = 'sys_permission_group.title_singular';
        const ColGroupKey = 'sys_permission_group.col_group_key';
        const ColGroupName = 'sys_permission_group.col_group_name';
        const ColLocale = 'sys_permission_group.col_locale';
        const LblKey = 'sys_permission_group.lbl_key';
        const LblNameEN = 'sys_permission_group.lbl_name_en';
        const LblNameTR = 'sys_permission_group.lbl_name_tr';
        const KeyRequired = 'sys_permission_group.key.required';
        const NameRequired = 'sys_permission_group.name.required';
        const GroupKeyUnique = 'sys_permission_group.group_key_unique';
      end;

      TSysRegion = record
        const TitlePlural = 'sys_region.title.title_plural';
        const TitleSingular = 'sys_region.title.singular';
        const ColRegionName = 'sys_region.region_name';
        const RegionNameUnique = 'sys_region.region_name.unique';
      end;

      TSysUom = record
        const TitlePlural = 'sys_uom.title_plural';
        const TitleSingular = 'sys_uom.title_singular';
        const UnitCodeUnique = 'sys_uom.unit_code_unique';
      end;

      TSysUomGroup = record
        const TitlePlural = 'sys_umo_group.title_plural';
        const TitleSingular = 'sys_umo_group.title_singular';
        const ColKey = 'sys_umo_group.col_key';
        const ColName = 'sys_umo_group.col_name';
        const ColLocale = 'sys_umo_group.col_locale';
        const KeyUnique = 'sys_umo_group.key_unique';
      end;

      TSysUser = record
        const TitlePlural = 'sys_user.title_plural';
        const TitleSingular = 'sys_user.title_singular';

        const ColUserName = 'sys_user.col_username';

        const UsernameUnique = 'sys_user.username_unique';
      end;


      //Employee Module
      TEmpEmployee = record
        const TitlePlural = 'emp_person.title_plural';
        const TitleSingular = 'emp_person.title_singular';
        const ColFullName = 'emp_person.col_full_name';
      end;

      //Stock Module
      TStock = record
        const GroupNameRequired = 'stock.group_name.required';
        const CodeRequired = 'stock.code.required';
        const NameRequired = 'stock.name.required';
        const ProductTypeNameRequired = 'stock.product_type_name.required';
        const SkuRequired = 'stock.sku.required';
        const QuantityMustBePositive = 'stock.quantity.must_be_positive';
        const WarehouseNameRequired = 'stock.warehouse_name.required';
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
  System.JSON, System.IOUtils, MetaProvider;

class constructor TLocalizationManager.Create;
begin
  FLock := TObject.Create;
  FCurrentLanguage := 'en';
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
var
  Idx: Integer;
begin
  Result := LowerCase(Trim(ALanguageCode));
  Idx := Pos('-', Result);
  if Idx > 1 then
    Result := Copy(Result, 1, Idx - 1);
  Idx := Pos('_', Result);
  if Idx > 1 then
    Result := Copy(Result, 1, Idx - 1);
  if Result = '' then
    Result := 'tr';
end;

class procedure TLocalizationManager.EnsureLanguageLoaded(const ALanguageCode: string);
var
  LangKey: string;
  FilePath: string;
begin
  LangKey := NormalizeLanguageCode(ALanguageCode);

  // If translation dictionary for this language already has loaded file entries, skip reloading
  if FTranslations.ContainsKey(LangKey) and (FTranslations[LangKey].Count > 10) then
    Exit;

  FilePath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Resource\Localization\' + LangKey + '.json');
  if not TFile.Exists(FilePath) then
    FilePath := TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\..\Resource\Localization\' + LangKey + '.json'));

  if TFile.Exists(FilePath) then
    LoadTranslationsFromFile(FilePath);
end;

class procedure TLocalizationManager.LoadDefaultTranslations;
begin
  EnsureLanguageLoaded('en');
  EnsureLanguageLoaded('tr');
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
begin
  TMonitor.Enter(FLock);
  try
    if FTranslations.ContainsKey(FCurrentLanguage) and
       FTranslations[FCurrentLanguage].ContainsKey(AKey)
    then
      Result := FTranslations[FCurrentLanguage][AKey]
    else if FTranslations.ContainsKey('en') and
            FTranslations['en'].ContainsKey(AKey)
    then
      Result := FTranslations['en'][AKey]
    else if ADefault <> '' then
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
  JsonText: string;
  JsonObj, LangObj: TJSONObject;
  LangPair: TJSONPair;
  TransPair: TJSONPair;
  LanguageCode, FileLangCode: string;
begin
  if not TFile.Exists(AFileName) then
    Exit;

  FileLangCode := LowerCase(TPath.GetFileNameWithoutExtension(AFileName));

  try
    JsonText := TFile.ReadAllText(AFileName, TEncoding.UTF8);
    JsonObj := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
    if Assigned(JsonObj) then
    begin
      try
        TMonitor.Enter(FLock);
        try
          for LangPair in JsonObj do
          begin
            if LangPair.JsonValue is TJSONObject then
            begin
              LanguageCode := LangPair.JsonString.Value;
              LangObj := LangPair.JsonValue as TJSONObject;

              if not FTranslations.ContainsKey(LanguageCode) then
                FTranslations.Add(LanguageCode, TDictionary<string, string>.Create);

              for TransPair in LangObj do
                FTranslations[LanguageCode].AddOrSetValue(
                  TransPair.JsonString.Value,
                  TransPair.JsonValue.Value);
            end
            else
            begin
              if not FTranslations.ContainsKey(FileLangCode) then
                FTranslations.Add(FileLangCode, TDictionary<string, string>.Create);

              FTranslations[FileLangCode].AddOrSetValue(
                LangPair.JsonString.Value,
                LangPair.JsonValue.Value);
            end;
          end;
        finally
          TMonitor.Exit(FLock);
        end;
      finally
        JsonObj.Free;
      end;
    end;
  except
    // JSON parsing error - ignore and use defaults
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
