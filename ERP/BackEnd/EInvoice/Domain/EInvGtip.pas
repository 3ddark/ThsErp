unit EInvGtip;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('einv_gtip')]
  TEInvGtip = class(TEntity)
  private
    FCode: string;
    FName: string;
    FIsActive: Boolean;
  public
    [Column('code')]
    [MaxLength(16), Required(TLangKeys.TValidation.Required, True)]
    property Code: string read FCode write FCode;

    [Column('name')]
    [MaxLength(512), Required(TLangKeys.TValidation.Required, True)]
    property Name: string read FName write FName;

    [Column('is_active')]
    property IsActive: Boolean read FIsActive write FIsActive;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEInvGtip;
  end;

implementation

constructor TEInvGtip.Create;
begin
  inherited;
  FIsActive := True;
end;

destructor TEInvGtip.Destroy;
begin
  inherited;
end;

function TEInvGtip.Clone: TEInvGtip;
begin
  Result := TEInvGtip.Create;
  Result.Id := Self.Id;
  Result.Code := Self.Code;
  Result.Name := Self.Name;
  Result.IsActive := Self.IsActive;
end;

end.
