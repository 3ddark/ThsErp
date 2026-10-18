unit EInvDriver;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('einv_driver')]
  TEInvDriver = class(TEntity)
  private
    FFirstName: string;
    FFamilyName: string;
    FNationalId: string;
    FPhone: string;
    FIsActive: Boolean;

    // View (vw_einv_driver) okunabilir alanları
    FFullName: string;
  public
    [Column('first_name')]
    [MaxLength(64), Required(TLangKeys.TValidation.Required, True)]
    property FirstName: string read FFirstName write FFirstName;

    [Column('family_name')]
    [MaxLength(64), Required(TLangKeys.TValidation.Required, True)]
    property FamilyName: string read FFamilyName write FFamilyName;

    [Column('national_id')]
    [MaxLength(11), Required(TLangKeys.TValidation.Required, True)]
    property NationalId: string read FNationalId write FNationalId;

    [Column('phone')]
    [MaxLength(32)]
    property Phone: string read FPhone write FPhone;

    [Column('is_active')]
    property IsActive: Boolean read FIsActive write FIsActive;

    [NotMapped]
    property FullName: string read FFullName write FFullName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEInvDriver;
  end;

implementation

constructor TEInvDriver.Create;
begin
  inherited;
  FIsActive := True;
end;

destructor TEInvDriver.Destroy;
begin
  inherited;
end;

function TEInvDriver.Clone: TEInvDriver;
begin
  Result := TEInvDriver.Create;
  Result.Id := Self.Id;
  Result.FirstName := Self.FirstName;
  Result.FamilyName := Self.FamilyName;
  Result.NationalId := Self.NationalId;
  Result.Phone := Self.Phone;
  Result.IsActive := Self.IsActive;
  Result.FullName := Self.FullName;
end;

end.
