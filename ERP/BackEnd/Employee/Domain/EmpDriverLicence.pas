unit EmpDriverLicence;

interface

{$I Ths.inc}

uses
  System.SysUtils, FireDAC.Comp.Client, Entity, Repository, EntityAttributes,
  EmpDriverLicenceType;

type
  [Table('emp_driver_ability')]
  TEmpDriverLicence = class(TEntity)
  private
    FDriverLicenseId: Int64;
    FEhliyet: TEmpDriverLicenseType;
    FPersonId: Int64;
  public
    [Column('driver_license_id')]
    Property DriverLicenseId: Int64 read FDriverLicenseId write FDriverLicenseId;

    [BelongsTo('DriverLicenseId')]
    Property Ehliyet: TEmpDriverLicenseType read FEhliyet write FEhliyet;

    [Column('person_id')]
    Property PersonId: Int64 read FPersonId write FPersonId;

    destructor Destroy; override;
    constructor Create; override;
  end;

implementation

constructor TEmpDriverLicence.Create;
begin
  inherited;
end;

destructor TEmpDriverLicence.Destroy;
begin
  inherited;
end;

end.


