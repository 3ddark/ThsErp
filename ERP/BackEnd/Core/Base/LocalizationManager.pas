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
        const MenuSystem = 'dashboard.menu.system';
        const MenuPurchasing = 'dashboard.menu.purchasing';
        const MenuSales = 'dashboard.menu.sales';
        const MenuAccounting = 'dashboard.menu.accounting';
        const MenuStock = 'dashboard.menu.stock';
        const MenuPersonnel = 'dashboard.menu.personnel';
        const MenuAbout = 'dashboard.menu.about';
        const MenuSettings = 'dashboard.menu.settings';
      end;

      //System Module
      TSysAccessRight = record
        const NoAccessRightToRead = 'sys_access_right.no_access_right_to_read';
        const NoAccessRightToAdd = 'sys_access_right.no_access_right_to_add';
        const NoAccessRightToUpdate = 'sys_access_right.no_access_right_to_update';
        const NoAccessRightToDelete = 'sys_access_right.no_access_right_to_delete';
        const NoAccessRightToSpecial = 'sys_access_right.no_access_right_to_special';
        const PermissionUserUnique = 'sys_access_right.permission_user_unique';
      end;

      TSysAddress = record

      end;

      TSysApplicationSetting = record

      end;

      TSysCity = record
        const CityCountryUnique = 'sys_city.city_country.unique';
      end;

      TSysCountry = record
        const CodeRequired = 'sys_country.code.required';
        const CodeLength = 'sys_country.code.length';
        const NameRequired = 'sys_country.name.required';
        const NameMinLength = 'sys_country.name.minlength';
        const NameMaxLength = 'sys_country.name.maxlength';
        const CodeUnique = 'sys_country.code.unique';
      end;

      TSysCurrency = record
        const CurrencyUnique = 'sys_currency.currency.unique';
      end;

      TSysDecimalPlace = record
        const TitlePlural = 'sys_decimal_place.title_plural';
        const TitleSingular = 'sys_decimal_place.title_singular';
        const ColId = 'sys_decimal_place.col_id';
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
        const TitlePlural = 'permission.title_plural';
        const TitleSingular = 'permission.title_singular';
        const ColCode = 'permission.col_code';
        const ColKey = 'permission.col_key';
        const ColName = 'permission.col_name';
        const ColGroupKey = 'permission.col_group_key';
        const ColGroupName = 'permission.col_group_name';
        const LblCode = 'permission.lbl_code';
        const LblKey = 'permission.lbl_key';
        const LblNameEN = 'permission.lbl_name_en';
        const LblNameTR = 'permission.lbl_name_tr';
        const LblGroupId = 'permission.lbl_group_id';
        const CodeRequired = 'permission.code.required';
        const CodePositive = 'permission.code.positive';
        const KeyRequired = 'permission.key.required';
        const GroupRequired = 'permission.group.required';
        const KeyUnique = 'sys_permission.key_unique';
      end;

      TSysPermissionGroup = record
        const TitlePlural = 'permission_group.title_plural';
        const TitleSingular = 'permission_group.title_singular';
        const ColKey = 'permission_group.col_key';
        const ColName = 'permission_group.col_name';
        const ColLocale = 'permission_group.col_locale';
        const LblKey = 'permission_group.lbl_key';
        const LblNameEN = 'permission_group.lbl_name_en';
        const LblNameTR = 'permission_group.lbl_name_tr';
        const KeyRequired = 'permission_group.key.required';
        const NameRequired = 'permission_group.name.required';
        const KeyUnique = 'sys_permission_group.key_unique';
      end;

      TSysRegion = record
        const NameUnique = 'sys_region.name.unique';
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
        const UsernameUnique = 'sys_user.username_unique';
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
