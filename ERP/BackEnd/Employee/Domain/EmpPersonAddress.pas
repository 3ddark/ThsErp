unit EmpPersonAddress;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('emp_person_address')]
  TEmpPersonAddress = class(TEntity)
  private
    FEmpEmployeeId: Int64;
    FSysAddressId: Int64;
    FAddressType: string;
    FIsPrimary: Boolean;
    FValidFrom: TDate;
    FValidTo: TDate;

    // View (vw_emp_person_address) okunabilir alanları
    FEmployeeFullName: string;
    FAddressText: string;
  public
    [Column('emp_employee_id')]
    property EmpEmployeeId: Int64 read FEmpEmployeeId write FEmpEmployeeId;

    [Column('sys_address_id')]
    property SysAddressId: Int64 read FSysAddressId write FSysAddressId;

    [Column('address_type')]
    [MaxLength(16), Required(TLangKeys.TValidation.Required, True)]
    property AddressType: string read FAddressType write FAddressType;

    [Column('is_primary')]
    property IsPrimary: Boolean read FIsPrimary write FIsPrimary;

    [Column('valid_from')]
    property ValidFrom: TDate read FValidFrom write FValidFrom;

    [Column('valid_to')]
    property ValidTo: TDate read FValidTo write FValidTo;

    [NotMapped]
    property EmployeeFullName: string read FEmployeeFullName write FEmployeeFullName;

    [NotMapped]
    property AddressText: string read FAddressText write FAddressText;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpPersonAddress;
  end;

implementation

constructor TEmpPersonAddress.Create;
begin
  inherited;
end;

destructor TEmpPersonAddress.Destroy;
begin
  inherited;
end;

function TEmpPersonAddress.Clone: TEmpPersonAddress;
begin
  Result := TEmpPersonAddress.Create;
  Result.Id := Self.Id;
  Result.EmpEmployeeId := Self.EmpEmployeeId;
  Result.SysAddressId := Self.SysAddressId;
  Result.AddressType := Self.AddressType;
  Result.IsPrimary := Self.IsPrimary;
  Result.ValidFrom := Self.ValidFrom;
  Result.ValidTo := Self.ValidTo;
  Result.EmployeeFullName := Self.EmployeeFullName;
  Result.AddressText := Self.AddressText;
end;

end.
