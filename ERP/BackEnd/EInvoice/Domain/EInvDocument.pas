unit EInvDocument;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('einv_document')]
  TEInvDocument = class(TEntity)
  private
    FSlsInvoiceId: Int64;
    FEinvUuid: string;
    FEinvNo: string;
    FXmlContent: string;
    FIsValid: Boolean;
    FValidationMessage: string;

    // View (vw_einv_document) okunabilir alanları
    FGeneratedAt: string;
    FInvoiceNo: string;
    FSlsDispatchId: Int64;
    FDispatchNo: string;

    // Gönderim durumu (servis yazar: TEInvDocumentRepository.SaveTransmission)
    FProviderCode: string;
    FProviderRef: string;
    FSentAt: string;
    FStatusCode: Integer;
    FStatusMessage: string;
    FStatusAt: string;
  public
    // kaynak belge: satış faturası ya da satış irsaliyesi (tam olarak biri; DB CHECK)
    [Column('sls_invoice_id')]
    property SlsInvoiceId: Int64 read FSlsInvoiceId write FSlsInvoiceId;

    [Column('sls_dispatch_id')]
    property SlsDispatchId: Int64 read FSlsDispatchId write FSlsDispatchId;

    [Column('einv_uuid')]
    [MaxLength(36), Required(TLangKeys.TValidation.Required, True)]
    property EinvUuid: string read FEinvUuid write FEinvUuid;

    [Column('einv_no')]
    [MaxLength(16), Required(TLangKeys.TValidation.Required, True)]
    property EinvNo: string read FEinvNo write FEinvNo;

    [Column('xml_content')]
    [Required(TLangKeys.TValidation.Required, True)]
    property XmlContent: string read FXmlContent write FXmlContent;

    [Column('is_valid')]
    property IsValid: Boolean read FIsValid write FIsValid;

    [Column('validation_message')]
    property ValidationMessage: string read FValidationMessage write FValidationMessage;

    [NotMapped]
    property GeneratedAt: string read FGeneratedAt write FGeneratedAt;

    [NotMapped]
    property InvoiceNo: string read FInvoiceNo write FInvoiceNo;

    [NotMapped]
    property DispatchNo: string read FDispatchNo write FDispatchNo;

    [NotMapped]
    property ProviderCode: string read FProviderCode write FProviderCode;

    [NotMapped]
    property ProviderRef: string read FProviderRef write FProviderRef;

    [NotMapped]
    property SentAt: string read FSentAt write FSentAt;

    [NotMapped]
    property StatusCode: Integer read FStatusCode write FStatusCode;

    [NotMapped]
    property StatusMessage: string read FStatusMessage write FStatusMessage;

    [NotMapped]
    property StatusAt: string read FStatusAt write FStatusAt;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEInvDocument;
  end;

implementation

constructor TEInvDocument.Create;
begin
  inherited;
end;

destructor TEInvDocument.Destroy;
begin
  inherited;
end;

function TEInvDocument.Clone: TEInvDocument;
begin
  Result := TEInvDocument.Create;
  Result.Id := Self.Id;
  Result.SlsInvoiceId := Self.SlsInvoiceId;
  Result.EinvUuid := Self.EinvUuid;
  Result.EinvNo := Self.EinvNo;
  Result.XmlContent := Self.XmlContent;
  Result.IsValid := Self.IsValid;
  Result.ValidationMessage := Self.ValidationMessage;
  Result.GeneratedAt := Self.GeneratedAt;
  Result.InvoiceNo := Self.InvoiceNo;
  Result.SlsDispatchId := Self.SlsDispatchId;
  Result.DispatchNo := Self.DispatchNo;
  Result.ProviderCode := Self.ProviderCode;
  Result.ProviderRef := Self.ProviderRef;
  Result.SentAt := Self.SentAt;
  Result.StatusCode := Self.StatusCode;
  Result.StatusMessage := Self.StatusMessage;
  Result.StatusAt := Self.StatusAt;
end;

end.
