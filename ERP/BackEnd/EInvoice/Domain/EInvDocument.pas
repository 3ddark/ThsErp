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
  public
    [Column('sls_invoice_id')]
    [Required()]
    property SlsInvoiceId: Int64 read FSlsInvoiceId write FSlsInvoiceId;

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
end;

end.
