unit SysApplicationSetting;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes, SysAddress, SysCurrency, Rest.Json;

type
  TSysApplicationSettingOtherSettings = class(TObject)
  private
    FStockCardImagePath: string;
    FPersonnelCardImagePath: string;
    FUpdatePath: string;
  public
    property StockCardImagePath: string read FStockCardImagePath write FStockCardImagePath;
    property PersonnelCardImagePath: string read FPersonnelCardImagePath write FPersonnelCardImagePath;
    property UpdatePath: string read FUpdatePath write FUpdatePath;

    constructor Create;

    function Clone: TSysApplicationSettingOtherSettings;
  end;

  [Table('sys_application_setting')]
  TSysApplicationSetting = class(TEntity)
  private
    FCompanyTitle: string;
    FTaxpayerSurname: string;
    FSmsTitle: string;
    FFax: string;
    FCryptKey: string;
    FTaxpayertype: string;
    FSysAddressId: Int64;
    FTaxAuthority: string;
    FActivePeriod: SmallInt;
    FSmsPassword: string;
    FMailPassword: string;
    FPhone: string;
    FOtherSettings: string;
    FSmsHost: string;
    FSmsUser: string;
    FMailHost: string;
    FMailUser: string;
    FTaxpayerName: string;
    FGridColor2: Integer;
    FGridColorActive: Integer;
    FGridColor1: Integer;
    FLogo: TArray<Byte>;
    FSysCurrency: TSysCurrency;
    FAppCurrency: string;
    FMailSmtpPort: Integer;
    FAppVersion: string;
    FTaxNo: string;
    FSysAddress: TSysAddress;
    FOtherSettingsObj: TSysApplicationSettingOtherSettings;
  public
    [Column('company_title')]
    [Required('sysapplicationsetting.companytitle.required', True)]
    property CompanyTitle: string read FCompanyTitle write FCompanyTitle;

    [Column('phone')]
    [Required('sysapplicationsetting.phone.required', True)]
    property Phone: string read FPhone write FPhone;

    [Column('fax')]
    property Fax: string read FFax write FFax;

    [Column('tax_authority')]
    property TaxAuthority: string read FTaxAuthority write FTaxAuthority;

    [Column('tax_no')]
    property TaxNo: string read FTaxNo write FTaxNo;

    [Column('active_period')]
    [Required('sysapplicationsetting.activeperiod.required', True)]
    property ActivePeriod: SmallInt read FActivePeriod write FActivePeriod;

    [Column('mail_host')]
    property MailHost: string read FMailHost write FMailHost;

    [Column('mail_user')]
    property MailUser: string read FMailUser write FMailUser;

    [Column('mail_password')]
    property MailPassword: string read FMailPassword write FMailPassword;

    [Column('mail_smtp_port')]
    property MailSmtpPort: Integer read FMailSmtpPort write FMailSmtpPort;

    [Column('grid_color_1')]
    [Required('sysapplicationsetting.gridcolor1.required', True)]
    property GridColor1: Integer read FGridColor1 write FGridColor1;

    [Column('grid_color_2')]
    [Required('sysapplicationsetting.gridcolor1.required', True)]
    property GridColor2: Integer read FGridColor2 write FGridColor2;

    [Column('grid_color_active')]
    [Required('sysapplicationsetting.gridcoloractive.required', True)]
    property GridColorActive: Integer read FGridColorActive write FGridColorActive;

    [Column('crypt_key')]
    [Required('sysapplicationsetting.cryptkey.required', True)]
    property CryptKey: string read FCryptKey write FCryptKey;

    [Column('sms_host')]
    property SmsHost: string read FSmsHost write FSmsHost;

    [Column('sms_user')]
    property SmsUser: string read FSmsUser write FSmsUser;

    [Column('sms_password')]
    property SmsPassword: string read FSmsPassword write FSmsPassword;

    [Column('sms_title')]
    property SmsTitle: string read FSmsTitle write FSmsTitle;

    [Column('app_version')]
    property AppVersion: string read FAppVersion write FAppVersion;

    [Column('app_currency')]
    property AppCurrency: string read FAppCurrency write FAppCurrency;

    [BelongsTo('AppCurrency')]
    property SysCurrency: TSysCurrency read FSysCurrency write FSysCurrency;

    [Column('sys_address_id')]
    property SysAddressId: Int64 read FSysAddressId write FSysAddressId;

    [BelongsTo('SysAddressId')]
    property SysAddress: TSysAddress read FSysAddress write FSysAddress;

    [Column('other_settings')]
    property OtherSettings: string read FOtherSettings write FOtherSettings;

    procedure DeserializeOtherSettings;
    procedure SerializeOtherSettings;

    [Column('taxpayer_name')]
    property TaxpayerName: string read FTaxpayerName write FTaxpayerName;

    [Column('taxpayer_surname')]
    property TaxpayerSurname: string read FTaxpayerSurname write FTaxpayerSurname;

    [Column('taxpayer_type')]
    property Taxpayertype: string read FTaxpayertype write FTaxpayertype;

    [Column('logo')]
    property Logo: TArray<Byte> read FLogo write FLogo;

    property OtherSettingsObj: TSysApplicationSettingOtherSettings read FOtherSettingsObj;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSysApplicationSetting;
  end;

implementation

function TSysApplicationSettingOtherSettings.Clone: TSysApplicationSettingOtherSettings;
begin
  Result := TSysApplicationSettingOtherSettings.Create;
  Result.StockCardImagePath := Self.StockCardImagePath;
  Result.PersonnelCardImagePath := Self.PersonnelCardImagePath;
  Result.UpdatePath := Self.UpdatePath;
end;

constructor TSysApplicationSettingOtherSettings.Create;
begin
  inherited;
  FStockCardImagePath := '';
  FPersonnelCardImagePath := '';
  FUpdatePath := '';
end;

constructor TSysApplicationSetting.Create();
begin
  inherited;
  FSysAddress := nil;
  FSysCurrency := nil;
  FOtherSettingsObj := TSysApplicationSettingOtherSettings.Create;
end;

destructor TSysApplicationSetting.Destroy;
begin
  if Assigned(FOtherSettingsObj) then
    FOtherSettingsObj.Free;
  FSysCurrency.Free;
  FSysAddress.Free;
  inherited;
end;

function TSysApplicationSetting.Clone: TSysApplicationSetting;
begin
  Result := TSysApplicationSetting.Create;

  Result.CompanyTitle := Self.CompanyTitle;
  Result.TaxpayerSurname := Self.TaxpayerSurname;
  Result.SmsTitle := Self.SmsTitle;
  Result.Fax := Self.Fax;
  Result.CryptKey := Self.CryptKey;
  Result.Taxpayertype := Self.Taxpayertype;
  Result.SysAddressId := Self.SysAddressId;
  Result.TaxAuthority := Self.TaxAuthority;
  Result.ActivePeriod := Self.ActivePeriod;
  Result.SmsPassword := Self.SmsPassword;
  Result.MailPassword := Self.MailPassword;
  Result.Phone := Self.Phone;
  Result.OtherSettings := Self.OtherSettings;
  Result.SmsHost := Self.SmsHost;
  Result.SmsUser := Self.SmsUser;
  Result.MailHost := Self.MailHost;
  Result.MailUser := Self.MailUser;
  Result.TaxpayerName := Self.TaxpayerName;
  Result.GridColor2 := Self.GridColor2;
  Result.GridColorActive := Self.GridColorActive;
  Result.GridColor1 := Self.GridColor1;
  Result.Logo := Self.Logo;

  if Assigned(Self.SysCurrency) then
    Result.SysCurrency := Self.SysCurrency.Clone;

  Result.AppCurrency := Self.AppCurrency;
  Result.MailSmtpPort := Self.MailSmtpPort;
  Result.AppVersion := Self.AppVersion;
  Result.TaxNo := Self.TaxNo;

  if Assigned(Self.SysAddress) then
    Result.SysAddress := Self.SysAddress.Clone;

    //read only prop !!!
//  Result.OtherSettingsObj := Self.OtherSettingsObj.Clone;
end;

procedure TSysApplicationSetting.DeserializeOtherSettings;
begin
  if Trim(FOtherSettings) = '' then
    Exit;
  try
    FOtherSettingsObj := TJson.JsonToObject<TSysApplicationSettingOtherSettings>(Trim(FOtherSettings));
    if not Assigned(FOtherSettingsObj) then
      FOtherSettingsObj := TSysApplicationSettingOtherSettings.Create;
  except
    FOtherSettingsObj.Free;
    FOtherSettingsObj := TSysApplicationSettingOtherSettings.Create;
  end;
end;

procedure TSysApplicationSetting.SerializeOtherSettings;
begin
  if not Assigned(FOtherSettingsObj) then
    Exit;
  FOtherSettings := TJson.ObjectToJsonString(FOtherSettingsObj);
end;

end.
