unit EmpPersonAddress;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes, EmpPerson, SysAddress;

type
  [Table('emp_person_address')]
  TEmpPersonAddress = class(TEntity)
  private
    FPersonId: Int64;
    FPerson: TEmpPerson;
    FAddressId: Int64;
    FAddress: TSysAddress;
    FAddressType: string;
    FIsPrimary: Boolean;
    FValidFrom: TDate;
    FValidTo: TDate;
  public
    [Column('person_id')]
    property PersonId: Int64 read FPersonId write FPersonId;

    [BelongsTo('PersonId')]
    property Person: TEmpPerson read FPerson write FPerson;

    [Column('address_id')]
    property AddressId: Int64 read FAddressId write FAddressId;

    [BelongsTo('AddressId')]
    property Address: TSysAddress read FAddress write FAddress;

    [Column('address_type')]
    property AddressType: string read FAddressType write FAddressType;

    [Column('is_primary')]
    property IsPrimary: Boolean read FIsPrimary write FIsPrimary;

    [Column('valid_from')]
    property ValidFrom: TDate read FValidFrom write FValidFrom;

    [Column('valid_to')]
    property ValidTo: TDate read FValidTo write FValidTo;
  end;

implementation

end.
