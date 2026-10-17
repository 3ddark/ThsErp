unit EInvPaymentMeans;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('einv_payment_means')]
  TEInvPaymentMeans = class(TEntity)
  private
    FCode: string;
    FName: string;
    FIsActive: Boolean;
  public
    [Column('code')]
    [MaxLength(8), Required(TLangKeys.TValidation.Required, True)]
    property Code: string read FCode write FCode;

    [Column('name')]
    [MaxLength(128), Required(TLangKeys.TValidation.Required, True)]
    property Name: string read FName write FName;

    [Column('is_active')]
    property IsActive: Boolean read FIsActive write FIsActive;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEInvPaymentMeans;
  end;

implementation

constructor TEInvPaymentMeans.Create;
begin
  inherited;
  FIsActive := True;
end;

destructor TEInvPaymentMeans.Destroy;
begin
  inherited;
end;

function TEInvPaymentMeans.Clone: TEInvPaymentMeans;
begin
  Result := TEInvPaymentMeans.Create;
  Result.Id := Self.Id;
  Result.Code := Self.Code;
  Result.Name := Self.Name;
  Result.IsActive := Self.IsActive;
end;

end.
