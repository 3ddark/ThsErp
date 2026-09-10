unit EmpPerson;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes, System.Generics.Collections,
  EmpPersonType, EmpUnit, EmpTask, SysAddress;

const
  C_Gender: array [0..1] of string = ('MAN', 'WOMAN');
  C_MaritalStatus: array [0..1] of string = ('SINGLE', 'MARRIED');
  C_MilitaryStatus: array [0..2] of string = ('DID', 'EXEMPT', 'DID NOT');

type
  TCinsiyet = (Man = 0, Woman = 1);
  TMedeniDurumu = (Single = 0, Married = 1);
  TAskerlikDurumu = (Did = 0, Exempt = 1, Didnot = 2);

  [Table('emp_person')]
  TEmpPerson = class(TEntity)
  private
    FName: string;
    FSurname: string;
    FFullName: string;
    FPhone1: string;
    FPhone2: string;
    FPersonTypeId: Int64;
    FPersonType: TEmpPersonType;
    FUnit: TEmpUnit;
    FUnitId: Int64;
    FTaskId: Int64;
    FTask: TEmpTask;
    FBirth: TDate;
    FBlood: string;
    FGender: SmallInt;
    FMilitaryStatus: SmallInt;
    FMaritalStatus: SmallInt;
    FChild: SmallInt;
    FRelatedName: string;
    FRelatedPhone: string;
    FShoe: SmallInt;
    FDress: string;
    FNotes: string;
    FTransportationId: Int64;
    FSpecialNotes: string;
    FSalary: Currency;
    FNumberOfBonus: SmallInt;
    FBonus: Currency;
    FIdentification: string;
    FAddressId: Int64;
    FActive: Boolean;
    FAddress: TSysAddress;
  public
    [Column('name')]
    property Name: string read FName write FName;

    [Column('surname')]
    property Surname: string read FSurname write FSurname;

    [Column('full_name')]
    property FullName: string read FFullName write FFullName;

    [Column('phone1')]
    property Phone1: string read FPhone1 write FPhone1;

    [Column('phone2')]
    property Phone2: string read FPhone2 write FPhone2;

    [Column('person_type_id')]
    property PersonTypeId: Int64 read FPersonTypeId write FPersonTypeId;

    [BelongsTo('PersonTypeId')]
    property PersonType: TEmpPersonType read FPersonType write FPersonType;

    [Column('unit_id')]
    property UnitId: Int64 read FUnitId write FUnitId;

    [BelongsTo('UnitId')]
    property Unit_: TEmpUnit read FUnit write FUnit;

    [Column('task_id')]
    property TaskId: Int64 read FTaskId write FTaskId;

    [BelongsTo('TaskId')]
    property Task: TEmpTask read FTask write FTask;

    [Column('birth_date')]
    property Birth: TDate read FBirth write FBirth;

    [Column('blood_type')]
    property Blood: string read FBlood write FBlood;

    [Column('gender')]
    property Gender: SmallInt read FGender write FGender;

    [Column('military_status')]
    property MilitaryStatus: SmallInt read FMilitaryStatus write FMilitaryStatus;

    [Column('marital_status')]
    property MaritalStatus: SmallInt read FMaritalStatus write FMaritalStatus;

    [Column('child')]
    property Child: SmallInt read FChild write FChild;

    [Column('relative_name')]
    property RelatedName: string read FRelatedName write FRelatedName;

    [Column('relative_phone')]
    property RelatedPhone: string read FRelatedPhone write FRelatedPhone;

    [Column('shoe_size')]
    property Shoe: SmallInt read FShoe write FShoe;

    [Column('clothing_size')]
    property Dress: string read FDress write FDress;

    [Column('notes')]
    property Notes: string read FNotes write FNotes;

    [Column('transportation_id')]
    property TransportationId: Int64 read FTransportationId write FTransportationId;

    [Column('special_notes')]
    property SpecialNotes: string read FSpecialNotes write FSpecialNotes;

    [Column('salary_amount')]
    property Salary: Currency read FSalary write FSalary;

    [Column('bonus_count')]
    property NumberOfBonus: SmallInt read FNumberOfBonus write FNumberOfBonus;

    [Column('bonus_amount')]
    property Bonus: Currency read FBonus write FBonus;

    [Column('id_document_no')]
    property Identification: string read FIdentification write FIdentification;

    [Column('address_id')]
    property AddressId: Int64 read FAddressId write FAddressId;

    [BelongsTo('AddressId')]
    property Address: TSysAddress read FAddress write FAddress;

    [Column('active')]
    property Active: Boolean read FActive write FActive;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpPerson;
  end;

implementation

constructor TEmpPerson.Create;
begin
  inherited;
end;

destructor TEmpPerson.Destroy;
begin
  inherited;
end;

function TEmpPerson.Clone: TEmpPerson;
begin
  Result := TEmpPerson.Create;
  Result.Name := Self.Name;
  Result.Surname := Self.Surname;
  Result.FullName := Self.FullName;
  Result.Phone1 := Self.Phone1;
  Result.Phone2 := Self.Phone2;
  Result.PersonTypeId := Self.PersonTypeId;
  Result.UnitId := Self.UnitId;
  Result.TaskId := Self.TaskId;
  Result.Birth := Self.Birth;
  Result.Blood := Self.Blood;
  Result.Gender := Self.Gender;
  Result.MilitaryStatus := Self.MilitaryStatus;
  Result.MaritalStatus := Self.MaritalStatus;
  Result.Child := Self.Child;
  Result.RelatedName := Self.RelatedName;
  Result.FRelatedPhone := Self.RelatedPhone;
  Result.Shoe := Self.Shoe;
  Result.Dress := Self.Dress;
  Result.Notes := Self.Notes;
  Result.TransportationId := Self.TransportationId;
  Result.SpecialNotes := Self.SpecialNotes;
  Result.Salary := Self.Salary;
  Result.NumberOfBonus := Self.NumberOfBonus;
  Result.Bonus := Self.Bonus;
  Result.Identification := Self.Identification;
  Result.AddressId := Self.AddressId;
  Result.Active := Self.Active;

  if Assigned(Self.PersonType) then
    Result.PersonType := Self.PersonType.Clone;

  if Assigned(Self.Unit_) then
    Result.Unit_ := Self.Unit_.Clone;

  if Assigned(Self.Task) then
    Result.Task := Self.Task.Clone;

  if Assigned(Self.Address) then
    Result.Address := Self.Address.Clone;
end;

end.

