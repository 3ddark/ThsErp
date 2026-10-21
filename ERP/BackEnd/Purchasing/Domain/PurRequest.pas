unit PurRequest;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, PurRequestDetail;

type
  [Table('pur_request')]
  TPurRequest = class(TEntity)
  private
    // Kalemler (sahiplenir): servis yükler / yazar; durum TDetailEntity (Id işareti + Deleted)
    FLines: TObjectList<TPurRequestDetail>;
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

    // Kolon değil (nesne özelliği): BusinessFindById ile dolar, BusinessSaveWithDetails ile yazılır
    property Lines: TObjectList<TPurRequestDetail> read FLines;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPurRequest;
  end;

  // Kalemden başlığa tipli erişim: Line.Header.RequestNo (HeaderEntity zayıf referans, sahiplenmez)
  TPurRequestDetailHelper = class helper for TPurRequestDetail
  private
    function GetHeader: TPurRequest;
    procedure SetHeader(const Value: TPurRequest);
  public
    property Header: TPurRequest read GetHeader write SetHeader;
  end;

implementation

{ TPurRequestDetailHelper }

function TPurRequestDetailHelper.GetHeader: TPurRequest;
begin
  Result := TPurRequest(HeaderEntity);
end;

procedure TPurRequestDetailHelper.SetHeader(const Value: TPurRequest);
begin
  HeaderEntity := Value;
end;

{ TPurRequest }

constructor TPurRequest.Create;
begin
  inherited;
  FLines := TObjectList<TPurRequestDetail>.Create(True);
  FRequestDate := Date;
  FStatus := 1;
end;

destructor TPurRequest.Destroy;
begin
  FLines.Free;
  inherited;
end;

// Kalemler dahil derin kopya; kopyanın kalemleri kopya başlığa bağlanır
function TPurRequest.Clone: TPurRequest;
var
  LLine, LCopy: TPurRequestDetail;
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
  for LLine in Self.FLines do
  begin
    LCopy := LLine.Clone;
    LCopy.HeaderEntity := Result;
    Result.FLines.Add(LCopy);
  end;
end;

end.
