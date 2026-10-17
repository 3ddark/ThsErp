unit EInvTransportMode;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('einv_transport_mode')]
  TEInvTransportMode = class(TEntity)
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

    function Clone: TEInvTransportMode;
  end;

implementation

constructor TEInvTransportMode.Create;
begin
  inherited;
  FIsActive := True;
end;

destructor TEInvTransportMode.Destroy;
begin
  inherited;
end;

function TEInvTransportMode.Clone: TEInvTransportMode;
begin
  Result := TEInvTransportMode.Create;
  Result.Id := Self.Id;
  Result.Code := Self.Code;
  Result.Name := Self.Name;
  Result.IsActive := Self.IsActive;
end;

end.
