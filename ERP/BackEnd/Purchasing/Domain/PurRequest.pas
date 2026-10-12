unit PurRequest;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('pur_request')]
  TPurRequest = class(TEntity)
  private
    FRequestNo: string;
    FRequestDate: TDate;
    FEmpEmployeeId: Int64;
    FRequiredDate: TDate;
    FStatus: SmallInt;
    FDescription: string;

    // View (vw_pur_request) okunabilir alanları
    FEmployeeName: string;
  public
    [Column('request_no')]
    [MaxLength(16)]
    property RequestNo: string read FRequestNo write FRequestNo;

    [Column('request_date')]
    [Required()]
    property RequestDate: TDate read FRequestDate write FRequestDate;

    [Column('emp_employee_id')]
    property EmpEmployeeId: Int64 read FEmpEmployeeId write FEmpEmployeeId;

    [Column('required_date')]
    property RequiredDate: TDate read FRequiredDate write FRequiredDate;

    [Column('status')]
    property Status: SmallInt read FStatus write FStatus;

    [Column('description')]
    [MaxLength(256)]
    property Description: string read FDescription write FDescription;

    [NotMapped]
    property EmployeeName: string read FEmployeeName write FEmployeeName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPurRequest;
  end;

implementation

constructor TPurRequest.Create;
begin
  inherited;
  FRequestDate := Date;
  FStatus := 1;
end;

destructor TPurRequest.Destroy;
begin
  inherited;
end;

function TPurRequest.Clone: TPurRequest;
begin
  Result := TPurRequest.Create;
  Result.Id := Self.Id;
  Result.RequestNo := Self.RequestNo;
  Result.RequestDate := Self.RequestDate;
  Result.EmpEmployeeId := Self.EmpEmployeeId;
  Result.RequiredDate := Self.RequiredDate;
  Result.Status := Self.Status;
  Result.Description := Self.Description;
  Result.EmployeeName := Self.EmployeeName;
end;

end.
