unit EInvTaxExemption;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('einv_tax_exemption')]
  TEInvTaxExemption = class(TEntity)
  private
    FCode: string;
    FName: string;
    FExemptionGroup: SmallInt;
    FEinvInvoiceTypeId: Int64;
    FRequiresGtip: Boolean;
    FRequiresDiib: Boolean;
    FRequiresZeroVat: Boolean;
    FIsActive: Boolean;

    // View (vw_einv_tax_exemption) okunabilir alanları
    FInvoiceTypeCode: string;
  public
    [Column('code')]
    [MaxLength(8), Required(TLangKeys.TValidation.Required, True)]
    property Code: string read FCode write FCode;

    [Column('name')]
    [MaxLength(512), Required(TLangKeys.TValidation.Required, True)]
    property Name: string read FName write FName;

    [Column('exemption_group')]
    [Required()]
    property ExemptionGroup: SmallInt read FExemptionGroup write FExemptionGroup;

    [Column('einv_invoice_type_id')]
    property EinvInvoiceTypeId: Int64 read FEinvInvoiceTypeId write FEinvInvoiceTypeId;

    [Column('requires_gtip')]
    property RequiresGtip: Boolean read FRequiresGtip write FRequiresGtip;

    [Column('requires_diib')]
    property RequiresDiib: Boolean read FRequiresDiib write FRequiresDiib;

    // KDV istisnası: faturada en az bir %0 KDV'li kalem ister (ÖTV / özel matrah / 555 gibi kodlarda kapalı)
    [Column('requires_zero_vat')]
    property RequiresZeroVat: Boolean read FRequiresZeroVat write FRequiresZeroVat;

    [Column('is_active')]
    property IsActive: Boolean read FIsActive write FIsActive;

    [NotMapped]
    property InvoiceTypeCode: string read FInvoiceTypeCode write FInvoiceTypeCode;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEInvTaxExemption;
  end;

implementation

constructor TEInvTaxExemption.Create;
begin
  inherited;
  FIsActive := True;
end;

destructor TEInvTaxExemption.Destroy;
begin
  inherited;
end;

function TEInvTaxExemption.Clone: TEInvTaxExemption;
begin
  Result := TEInvTaxExemption.Create;
  Result.Id := Self.Id;
  Result.Code := Self.Code;
  Result.Name := Self.Name;
  Result.ExemptionGroup := Self.ExemptionGroup;
  Result.EinvInvoiceTypeId := Self.EinvInvoiceTypeId;
  Result.RequiresGtip := Self.RequiresGtip;
  Result.RequiresDiib := Self.RequiresDiib;
  Result.RequiresZeroVat := Self.RequiresZeroVat;
  Result.IsActive := Self.IsActive;
  Result.InvoiceTypeCode := Self.InvoiceTypeCode;
end;

end.
