unit SetPrsDriverLicenceType;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('set_prs_driver_licence_types')]
  TSetPrsDriverLicenseType = class(TEntity)
  private
    FLicenseName: string;
  public
    [Column('license_name')]
    Property LicenseName: string read FLicenseName write FLicenseName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetPrsDriverLicenseType.Create;
begin
  inherited;
end;

destructor TSetPrsDriverLicenseType.Destroy;
begin

  inherited;
end;

end.
