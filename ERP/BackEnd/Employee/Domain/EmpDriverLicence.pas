unit EmpDriverLicence;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('emp_driver_ability')]
  TEmpDriverLicence = class(TEntity)
  private
    FEmpEmployeeId: Int64;
    FEmpDriverLicenseTypeId: Int64;

    // View (vw_emp_driver_ability) okunabilir alanları
    FEmployeeFullName: string;
    FLicenseName: string;
  public
    [Column('emp_employee_id')]
    property EmpEmployeeId: Int64 read FEmpEmployeeId write FEmpEmployeeId;

    [Column('emp_driver_license_type_id')]
    property EmpDriverLicenseTypeId: Int64 read FEmpDriverLicenseTypeId write FEmpDriverLicenseTypeId;

    [NotMapped]
    property EmployeeFullName: string read FEmployeeFullName write FEmployeeFullName;

    [NotMapped]
    property LicenseName: string read FLicenseName write FLicenseName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpDriverLicence;
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

function TEmpDriverLicence.Clone: TEmpDriverLicence;
begin
  Result := TEmpDriverLicence.Create;
  Result.Id := Self.Id;
  Result.EmpEmployeeId := Self.EmpEmployeeId;
  Result.EmpDriverLicenseTypeId := Self.EmpDriverLicenseTypeId;
  Result.EmployeeFullName := Self.EmployeeFullName;
  Result.LicenseName := Self.LicenseName;
end;

end.
