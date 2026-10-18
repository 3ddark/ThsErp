unit SysApiService;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('sys_api_service')]
  TSysApiService = class(TEntity)
  private
    FSysApplicationSettingId: Int64;
    FServiceKind: string;
    FProviderCode: string;
    FEnvironment: SmallInt;
    FBaseUrl: string;
    FUsername: string;
    FTimeoutSeconds: SmallInt;
    FOptions: string;
    FDescription: string;
    FIsActive: Boolean;
    FPassword: string;
    FApiKey: string;
    FPasswordEnc: string;
    FApiKeyEnc: string;
    FClearSecrets: Boolean;
    FHasPassword: Boolean;
    FHasApiKey: Boolean;
  public
    [Column('sys_application_setting_id')]
    property SysApplicationSettingId: Int64 read FSysApplicationSettingId write FSysApplicationSettingId;

    [Column('service_kind')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property ServiceKind: string read FServiceKind write FServiceKind;

    [Column('provider_code')]
    [MaxLength(32)]
    property ProviderCode: string read FProviderCode write FProviderCode;

    [Column('environment')]
    [Required()]
    property Environment: SmallInt read FEnvironment write FEnvironment;

    [Column('base_url')]
    [MaxLength(512)]
    property BaseUrl: string read FBaseUrl write FBaseUrl;

    [Column('username')]
    [MaxLength(128)]
    property Username: string read FUsername write FUsername;

    [Column('timeout_seconds')]
    property TimeoutSeconds: SmallInt read FTimeoutSeconds write FTimeoutSeconds;

    [Column('options')]
    [MaxLength(8000)]
    property Options: string read FOptions write FOptions;

    [Column('description')]
    [MaxLength(256)]
    property Description: string read FDescription write FDescription;

    [Column('is_active')]
    property IsActive: Boolean read FIsActive write FIsActive;

    // Gizli bilgiler: formdan düz metin (boş = değişmez), servis şifreler (PasswordEnc / ApiKeyEnc); ClearSecrets
    // kayıtlı olanları siler. View yalnız var / yok gösterir (HasPassword / HasApiKey); çözülmüş değer yalnız
    // TApiServiceConfigs üzerinden okunur.
    [NotMapped]
    property Password: string read FPassword write FPassword;

    [NotMapped]
    property ApiKey: string read FApiKey write FApiKey;

    [NotMapped]
    property PasswordEnc: string read FPasswordEnc write FPasswordEnc;

    [NotMapped]
    property ApiKeyEnc: string read FApiKeyEnc write FApiKeyEnc;

    [NotMapped]
    property ClearSecrets: Boolean read FClearSecrets write FClearSecrets;

    [NotMapped]
    property HasPassword: Boolean read FHasPassword write FHasPassword;

    [NotMapped]
    property HasApiKey: Boolean read FHasApiKey write FHasApiKey;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSysApiService;
  end;

implementation

constructor TSysApiService.Create;
begin
  inherited;
  FIsActive := True;
  FEnvironment := 1;
  FTimeoutSeconds := 60;
  FOptions := '{}';
end;

destructor TSysApiService.Destroy;
begin
  inherited;
end;

function TSysApiService.Clone: TSysApiService;
begin
  Result := TSysApiService.Create;
  Result.Id := Self.Id;
  Result.SysApplicationSettingId := Self.SysApplicationSettingId;
  Result.ServiceKind := Self.ServiceKind;
  Result.ProviderCode := Self.ProviderCode;
  Result.Environment := Self.Environment;
  Result.BaseUrl := Self.BaseUrl;
  Result.Username := Self.Username;
  Result.TimeoutSeconds := Self.TimeoutSeconds;
  Result.Options := Self.Options;
  Result.Description := Self.Description;
  Result.IsActive := Self.IsActive;
  Result.Password := Self.Password;
  Result.ApiKey := Self.ApiKey;
  Result.PasswordEnc := Self.PasswordEnc;
  Result.ApiKeyEnc := Self.ApiKeyEnc;
  Result.ClearSecrets := Self.ClearSecrets;
  Result.HasPassword := Self.HasPassword;
  Result.HasApiKey := Self.HasApiKey;
end;

end.
