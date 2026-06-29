unit EmpDriverLicenceType;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('emp_driver_licence_types')]
  TEmpDriverLicenseType = class(TEntity)
  private
    FLicenseName: string;
  public
    [Column('license_name')]
    Property LicenseName: string read FLicenseName write FLicenseName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TEmpDriverLicenseType.Create;
begin
  inherited;
end;

destructor TEmpDriverLicenseType.Destroy;
begin

  inherited;
end;

end.