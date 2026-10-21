unit EInvDocumentSetting;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('einv_document_setting')]
  TEInvDocumentSetting = class(TEntity)
  private
    FSysApplicationSettingId: Int64;
    FSeriesScope: SmallInt;
    FEinvSeriesId: Int64;
    FSysApiServiceId: Int64;
    FSenderAlias: string;
    FReceiverAlias: string;

    // View (vw_einv_document_setting) okunabilir alanları
    FSeriesCode: string;
    FSeriesName: string;
    FServiceKind: string;
    FProviderCode: string;
  public
    [Column('sys_application_setting_id')]
    property SysApplicationSettingId: Int64 read FSysApplicationSettingId write FSysApplicationSettingId;

    [Column('series_scope')]
    [Required()]
    property SeriesScope: SmallInt read FSeriesScope write FSeriesScope;

    [Column('einv_series_id')]
    property EinvSeriesId: Int64 read FEinvSeriesId write FEinvSeriesId;

    [Column('sys_api_service_id')]
    property SysApiServiceId: Int64 read FSysApiServiceId write FSysApiServiceId;

    // GİB etiketleri (e-Arşivde yok): gönderici birim (GB) giden belgelerde, posta kutusu (PK) gelen belgelerde
    [Column('sender_alias')]
    [MaxLength(256)]
    property SenderAlias: string read FSenderAlias write FSenderAlias;

    [Column('receiver_alias')]
    [MaxLength(256)]
    property ReceiverAlias: string read FReceiverAlias write FReceiverAlias;

    [NotMapped]
    property SeriesCode: string read FSeriesCode write FSeriesCode;

    [NotMapped]
    property SeriesName: string read FSeriesName write FSeriesName;

    [NotMapped]
    property ServiceKind: string read FServiceKind write FServiceKind;

    [NotMapped]
    property ProviderCode: string read FProviderCode write FProviderCode;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEInvDocumentSetting;
  end;

implementation

constructor TEInvDocumentSetting.Create;
begin
  inherited;
end;

destructor TEInvDocumentSetting.Destroy;
begin
  inherited;
end;

function TEInvDocumentSetting.Clone: TEInvDocumentSetting;
begin
  Result := TEInvDocumentSetting.Create;
  Result.Id := Self.Id;
  Result.SysApplicationSettingId := Self.SysApplicationSettingId;
  Result.SeriesScope := Self.SeriesScope;
  Result.EinvSeriesId := Self.EinvSeriesId;
  Result.SysApiServiceId := Self.SysApiServiceId;
  Result.SenderAlias := Self.SenderAlias;
  Result.ReceiverAlias := Self.ReceiverAlias;
  Result.SeriesCode := Self.SeriesCode;
  Result.SeriesName := Self.SeriesName;
  Result.ServiceKind := Self.ServiceKind;
  Result.ProviderCode := Self.ProviderCode;
end;

end.
