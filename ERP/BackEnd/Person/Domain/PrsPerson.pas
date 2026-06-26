unit PrsPerson;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes, System.Generics.Collections,
  SetPrsPersonType, SetPrsUnit, SetPrsTask, SysAddress;

const
  C_Gender: array [0..1] of string = ('MAN', 'WOMAN');
  C_MaritalStatus: array [0..1] of string = ('SINGLE', 'MARRIED');
  C_MilitaryStatus: array [0..2] of string = ('DID', 'EXEMPT', 'DID NOT');

type
  TCinsiyet = (Man = 0, Woman = 1);
  TMedeniDurumu = (Single = 0, Married = 1);
  TAskerlikDurumu = (Did = 0, Exempt = 1, Didnot = 2);

  [Table('prs_persons')]
  TPrsPerson = class(TEntity)
  private
    FName: string;
    FSurname: string;
    FFullName: string;
    FPhone1: string;
    FPhone2: string;
    FPersonTypeId: Int64;
    FPersonType: TSetPrsPersonType;
    FUnit: TSetPrsUnit;
    FUnitId: Int64;
    FTaskId: Int64;
    FTask: TSetPrsTask;
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
    property PersonType: TSetPrsPersonType read FPersonType write FPersonType;

    [Column('unit_id')]
    property UnitId: Int64 read FUnitId write FUnitId;

    [BelongsTo('UnitId')]
    property Unit_: TSetPrsUnit read FUnit write FUnit;

    [Column('task_id')]
    property TaskId: Int64 read FTaskId write FTaskId;

    [BelongsTo('TaskId')]
    property Task: TSetPrsTask read FTask write FTask;

    [Column('birth')]
    property Birth: TDate read FBirth write FBirth;

    [Column('blood')]
    property Blood: string read FBlood write FBlood;

    [Column('gender')]
    property Gender: SmallInt read FGender write FGender;

    [Column('military_status')]
    property MilitaryStatus: SmallInt read FMilitaryStatus write FMilitaryStatus;

    [Column('marital_status')]
    property MaritalStatus: SmallInt read FMaritalStatus write FMaritalStatus;

    [Column('child')]
    property Child: SmallInt read FChild write FChild;

    [Column('related_name')]
    property RelatedName: string read FRelatedName write FRelatedName;

    [Column('related_phone')]
    property RelatedPhone: string read FRelatedPhone write FRelatedPhone;

    [Column('shoe')]
    property Shoe: SmallInt read FShoe write FShoe;

    [Column('dress')]
    property Dress: string read FDress write FDress;

    [Column('notes')]
    property Notes: string read FNotes write FNotes;

    [Column('transportation_id')]
    property TransportationId: Int64 read FTransportationId write FTransportationId;

    [Column('special_notes')]
    property SpecialNotes: string read FSpecialNotes write FSpecialNotes;

    [Column('salary')]
    property Salary: Currency read FSalary write FSalary;

    [Column('number_of_bonus')]
    property NumberOfBonus: SmallInt read FNumberOfBonus write FNumberOfBonus;

    [Column('bonus')]
    property Bonus: Currency read FBonus write FBonus;

    [Column('identification')]
    property Identification: string read FIdentification write FIdentification;

    [Column('address_id')]
    property AddressId: Int64 read FAddressId write FAddressId;

    [BelongsTo('AddressId')]
    property Address: TSysAddress read FAddress write FAddress;

    [Column('active')]
    property Active: Boolean read FActive write FActive;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TPrsPerson.Create;
begin
  inherited;
end;

destructor TPrsPerson.Destroy;
begin
  inherited;
end;

end.
