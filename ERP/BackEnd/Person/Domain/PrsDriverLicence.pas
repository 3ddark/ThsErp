unit PrsDriverLicence;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes, SetPrsDriverLicenceType;

type
  [Table('prs_driver_abilities')]
  TPrsDriverLicence = class(TEntity)
  private
    FDriverLicenseId: Int64;
    FEhliyet: TSetPrsDriverLicenseType;
    FPersonId: Int64;
  public
    [Column('driver_license_id')]
    Property DriverLicenseId: Int64 read FDriverLicenseId write FDriverLicenseId;

    [BelongsTo('DriverLicenseId')]
    Property Ehliyet: TSetPrsDriverLicenseType read FEhliyet write FEhliyet;

    [Column('person_id')]
    Property PersonId: Int64 read FPersonId write FPersonId;

    destructor Destroy; override;
    constructor Create; override;
  end;

implementation

constructor TPrsDriverLicence.Create;
begin
  inherited;
end;

destructor TPrsDriverLicence.Destroy;
begin
  inherited;
end;

end.
