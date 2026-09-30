unit EmpLanguageAbility;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('emp_person_language_ability')]
  TEmpLanguageAbility = class(TEntity)
  private
    FEmpEmployeeId: Int64;
    FEmpLanguageId: Int64;
    FReadLevel: SmallInt;
    FWriteLevel: SmallInt;
    FSpeakLevel: SmallInt;

    // View (vw_emp_person_language_ability) okunabilir alanları
    FEmployeeFullName: string;
    FLanguageName: string;
  public
    [Column('emp_employee_id')]
    property EmpEmployeeId: Int64 read FEmpEmployeeId write FEmpEmployeeId;

    [Column('emp_language_id')]
    property EmpLanguageId: Int64 read FEmpLanguageId write FEmpLanguageId;

    [Column('read_level')]
    property ReadLevel: SmallInt read FReadLevel write FReadLevel;

    [Column('write_level')]
    property WriteLevel: SmallInt read FWriteLevel write FWriteLevel;

    [Column('speak_level')]
    property SpeakLevel: SmallInt read FSpeakLevel write FSpeakLevel;

    [NotMapped]
    property EmployeeFullName: string read FEmployeeFullName write FEmployeeFullName;

    [NotMapped]
    property LanguageName: string read FLanguageName write FLanguageName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpLanguageAbility;
  end;

implementation

constructor TEmpLanguageAbility.Create;
begin
  inherited;
end;

destructor TEmpLanguageAbility.Destroy;
begin
  inherited;
end;

function TEmpLanguageAbility.Clone: TEmpLanguageAbility;
begin
  Result := TEmpLanguageAbility.Create;
  Result.Id := Self.Id;
  Result.EmpEmployeeId := Self.EmpEmployeeId;
  Result.EmpLanguageId := Self.EmpLanguageId;
  Result.ReadLevel := Self.ReadLevel;
  Result.WriteLevel := Self.WriteLevel;
  Result.SpeakLevel := Self.SpeakLevel;
  Result.EmployeeFullName := Self.EmployeeFullName;
  Result.LanguageName := Self.LanguageName;
end;

end.
