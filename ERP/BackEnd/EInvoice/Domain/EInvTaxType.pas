unit EInvTaxType;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('einv_tax_type')]
  TEInvTaxType = class(TEntity)
  private
    FCode: string;
    FName: string;
    FShortName: string;
    FIsActive: Boolean;
  public
    [Column('code')]
    [MaxLength(8), Required(TLangKeys.TValidation.Required, True)]
    property Code: string read FCode write FCode;

    [Column('name')]
    [MaxLength(128), Required(TLangKeys.TValidation.Required, True)]
    property Name: string read FName write FName;

    [Column('short_name')]
    [MaxLength(32)]
    property ShortName: string read FShortName write FShortName;

    [Column('is_active')]
    property IsActive: Boolean read FIsActive write FIsActive;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEInvTaxType;
  end;

implementation

constructor TEInvTaxType.Create;
begin
  inherited;
  FIsActive := True;
end;

destructor TEInvTaxType.Destroy;
begin
  inherited;
end;

function TEInvTaxType.Clone: TEInvTaxType;
begin
  Result := TEInvTaxType.Create;
  Result.Id := Self.Id;
  Result.Code := Self.Code;
  Result.Name := Self.Name;
  Result.ShortName := Self.ShortName;
  Result.IsActive := Self.IsActive;
end;

end.
