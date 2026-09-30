unit EmpEmployee;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes, LocalizationManager;

type
  [Table('emp_employee')]
  TEmpEmployee = class(TEntity)
  private
    FName: string;
    FSurname: string;
    FFullName: string;
    FPhone1: string;
    FPhone2: string;
    FEmpPersonTypeId: Int64;
    FEmpUnitId: Int64;
    FEmpTaskId: Int64;
    FBirthDate: TDate;
    FBloodType: string;
    FGender: SmallInt;
    FMilitaryStatus: SmallInt;
    FMaritalStatus: SmallInt;
    FChild: SmallInt;
    FRelativeName: string;
    FRelativePhone: string;
    FShoeSize: SmallInt;
    FClothingSize: string;
    FNotes: string;
    FEmpTransportationId: Int64;
    FSpecialNotes: string;
    FSalaryAmount: Currency;
    FBonusCount: Integer;
    FBonusAmount: Currency;
    FIdDocumentNo: string;
    FActive: Boolean;

    // View (vw_emp_employee) okunabilir alanları
    FPersonType: string;
    FEmpUnitName: string;
    FSectionName: string;
    FTaskName: string;
    FTransportationName: string;
  public
    [Column('name')]
    [Required(TLangKeys.TValidation.Required, True)]
    property Name: string read FName write FName;

    [Column('surname')]
    [Required(TLangKeys.TValidation.Required, True)]
    property Surname: string read FSurname write FSurname;

    [Column('full_name')]
    property FullName: string read FFullName write FFullName;

    [Column('phone1')]
    property Phone1: string read FPhone1 write FPhone1;

    [Column('phone2')]
    property Phone2: string read FPhone2 write FPhone2;

    [Column('emp_person_type_id')]
    [Required(TLangKeys.TValidation.Required, True)]
    property EmpPersonTypeId: Int64 read FEmpPersonTypeId write FEmpPersonTypeId;

    [Column('emp_unit_id')]
    [Required(TLangKeys.TValidation.Required, True)]
    property EmpUnitId: Int64 read FEmpUnitId write FEmpUnitId;

    [Column('emp_task_id')]
    [Required(TLangKeys.TValidation.Required, True)]
    property EmpTaskId: Int64 read FEmpTaskId write FEmpTaskId;

    [Column('birth_date')]
    property BirthDate: TDate read FBirthDate write FBirthDate;

    [Column('blood_type')]
    [MaxLength(8)]
    property BloodType: string read FBloodType write FBloodType;          // EmpLookup elkBloodType, '' = NULL

    [Column('gender')]
    property Gender: SmallInt read FGender write FGender;

    [Column('military_status')]
    property MilitaryStatus: SmallInt read FMilitaryStatus write FMilitaryStatus;

    [Column('marital_status')]
    property MaritalStatus: SmallInt read FMaritalStatus write FMaritalStatus;

    [Column('child')]
    property Child: SmallInt read FChild write FChild;

    [Column('relative_name')]
    property RelativeName: string read FRelativeName write FRelativeName;

    [Column('relative_phone')]
    property RelativePhone: string read FRelativePhone write FRelativePhone;

    [Column('shoe_size')]
    property ShoeSize: SmallInt read FShoeSize write FShoeSize;

    [Column('clothing_size')]
    [MaxLength(8)]
    property ClothingSize: string read FClothingSize write FClothingSize; // EmpLookup elkClothingSize, '' = NULL

    [Column('notes')]
    property Notes: string read FNotes write FNotes;

    [Column('emp_transportation_id')]
    property EmpTransportationId: Int64 read FEmpTransportationId write FEmpTransportationId;

    [Column('special_notes')]
    property SpecialNotes: string read FSpecialNotes write FSpecialNotes;

    [Column('salary_amount')]
    property SalaryAmount: Currency read FSalaryAmount write FSalaryAmount;

    [Column('bonus_count')]
    property BonusCount: Integer read FBonusCount write FBonusCount;

    [Column('bonus_amount')]
    property BonusAmount: Currency read FBonusAmount write FBonusAmount;

    [Column('id_document_no')]
    property IdDocumentNo: string read FIdDocumentNo write FIdDocumentNo;

    [Column('active')]
    property Active: Boolean read FActive write FActive;

    [NotMapped]
    property PersonType: string read FPersonType write FPersonType;

    [NotMapped]
    property EmpUnitName: string read FEmpUnitName write FEmpUnitName;

    [NotMapped]
    property SectionName: string read FSectionName write FSectionName;

    [NotMapped]
    property TaskName: string read FTaskName write FTaskName;

    [NotMapped]
    property TransportationName: string read FTransportationName write FTransportationName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpEmployee;
  end;

implementation

constructor TEmpEmployee.Create;
begin
  inherited;
  FActive := True;
end;

destructor TEmpEmployee.Destroy;
begin
  inherited;
end;

function TEmpEmployee.Clone: TEmpEmployee;
begin
  Result := TEmpEmployee.Create;
  Result.Id := Self.Id;
  Result.Name := Self.Name;
  Result.Surname := Self.Surname;
  Result.FullName := Self.FullName;
  Result.Phone1 := Self.Phone1;
  Result.Phone2 := Self.Phone2;
  Result.EmpPersonTypeId := Self.EmpPersonTypeId;
  Result.EmpUnitId := Self.EmpUnitId;
  Result.EmpTaskId := Self.EmpTaskId;
  Result.BirthDate := Self.BirthDate;
  Result.BloodType := Self.BloodType;
  Result.Gender := Self.Gender;
  Result.MilitaryStatus := Self.MilitaryStatus;
  Result.MaritalStatus := Self.MaritalStatus;
  Result.Child := Self.Child;
  Result.RelativeName := Self.RelativeName;
  Result.RelativePhone := Self.RelativePhone;
  Result.ShoeSize := Self.ShoeSize;
  Result.ClothingSize := Self.ClothingSize;
  Result.Notes := Self.Notes;
  Result.EmpTransportationId := Self.EmpTransportationId;
  Result.SpecialNotes := Self.SpecialNotes;
  Result.SalaryAmount := Self.SalaryAmount;
  Result.BonusCount := Self.BonusCount;
  Result.BonusAmount := Self.BonusAmount;
  Result.IdDocumentNo := Self.IdDocumentNo;
  Result.Active := Self.Active;
  Result.PersonType := Self.PersonType;
  Result.EmpUnitName := Self.EmpUnitName;
  Result.SectionName := Self.SectionName;
  Result.TaskName := Self.TaskName;
  Result.TransportationName := Self.TransportationName;
end;

end.
