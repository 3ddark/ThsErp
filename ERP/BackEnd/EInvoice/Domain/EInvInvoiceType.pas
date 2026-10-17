unit EInvInvoiceType;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('einv_invoice_type')]
  TEInvInvoiceType = class(TEntity)
  private
    FCode: string;
    FName: string;
    FRequiresExemption: Boolean;
    FRequiresWithholding: Boolean;
    FIsReturn: Boolean;
    FIsActive: Boolean;
  public
    [Column('code')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property Code: string read FCode write FCode;

    [Column('name')]
    [MaxLength(128), Required(TLangKeys.TValidation.Required, True)]
    property Name: string read FName write FName;

    [Column('requires_exemption')]
    property RequiresExemption: Boolean read FRequiresExemption write FRequiresExemption;

    [Column('requires_withholding')]
    property RequiresWithholding: Boolean read FRequiresWithholding write FRequiresWithholding;

    [Column('is_return')]
    property IsReturn: Boolean read FIsReturn write FIsReturn;

    [Column('is_active')]
    property IsActive: Boolean read FIsActive write FIsActive;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEInvInvoiceType;
  end;

implementation

constructor TEInvInvoiceType.Create;
begin
  inherited;
  FIsActive := True;
end;

destructor TEInvInvoiceType.Destroy;
begin
  inherited;
end;

function TEInvInvoiceType.Clone: TEInvInvoiceType;
begin
  Result := TEInvInvoiceType.Create;
  Result.Id := Self.Id;
  Result.Code := Self.Code;
  Result.Name := Self.Name;
  Result.RequiresExemption := Self.RequiresExemption;
  Result.RequiresWithholding := Self.RequiresWithholding;
  Result.IsReturn := Self.IsReturn;
  Result.IsActive := Self.IsActive;
end;

end.
