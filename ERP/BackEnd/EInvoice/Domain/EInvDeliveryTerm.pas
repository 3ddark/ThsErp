unit EInvDeliveryTerm;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('einv_delivery_term')]
  TEInvDeliveryTerm = class(TEntity)
  private
    FCode: string;
    FName: string;
    FIsIncoterms: Boolean;
    FIsActive: Boolean;
  public
    [Column('code')]
    [MaxLength(8), Required(TLangKeys.TValidation.Required, True)]
    property Code: string read FCode write FCode;

    [Column('name')]
    [MaxLength(128), Required(TLangKeys.TValidation.Required, True)]
    property Name: string read FName write FName;

    [Column('is_incoterms')]
    property IsIncoterms: Boolean read FIsIncoterms write FIsIncoterms;

    [Column('is_active')]
    property IsActive: Boolean read FIsActive write FIsActive;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEInvDeliveryTerm;
  end;

implementation

constructor TEInvDeliveryTerm.Create;
begin
  inherited;
  FIsActive := True;
end;

destructor TEInvDeliveryTerm.Destroy;
begin
  inherited;
end;

function TEInvDeliveryTerm.Clone: TEInvDeliveryTerm;
begin
  Result := TEInvDeliveryTerm.Create;
  Result.Id := Self.Id;
  Result.Code := Self.Code;
  Result.Name := Self.Name;
  Result.IsIncoterms := Self.IsIncoterms;
  Result.IsActive := Self.IsActive;
end;

end.
