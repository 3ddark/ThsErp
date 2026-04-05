unit SysApplicationSetting;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes, SysAddress;

type
  [Table('sys_application_settings')]
  TSysApplicationSetting = class(TEntity)
  private
    FCompanyTitle: string;
    FTaxpayerSurname: string;
    FSmsTitle: string;
    FFax: string;
    FCryptKey: string;
    FTaxpayertype: string;
    FAddressId: Int64;
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
    FAppCurrency: string;
    FMailSmtpPort: Integer;
    FAppVersion: string;
    FTaxNo: string;
    FAddress: TSysAddress;
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

    [Column('address_id')]
    property AddressId: Int64 read FAddressId write FAddressId;

    [BelongsTo('address_id', 'id')]
    property Address: TSysAddress read FAddress write FAddress;

    [Column('other_settings')]
    property OtherSettings: string read FOtherSettings write FOtherSettings;//json data

    [Column('taxpayer_name')]
    property TaxpayerName: string read FTaxpayerName write FTaxpayerName;

    [Column('taxpayer_surname')]
    property TaxpayerSurname: string read FTaxpayerSurname write FTaxpayerSurname;

    [Column('taxpayer_type')]
    property Taxpayertype: string read FTaxpayertype write FTaxpayertype;

    [Column('logo')]
    property Logo: TArray<Byte> read FLogo write FLogo;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysApplicationSetting.Create();
begin
  inherited;
end;

destructor TSysApplicationSetting.Destroy;
begin
  inherited;
end;

end.
