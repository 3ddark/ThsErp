unit SysUser;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes, EmpEmployee;

type
  [Table('sys_user')]
  TSysUser = class(TEntity)
  private
    FUsername: string;
    FEmpEmployeeId: Int64;
    FManager: Boolean;
    FSuperUser: Boolean;
    FMacAddress: string;
    FUserPassword: string;
    FIpAddress: string;
    FActive: Boolean;
    FEmpEmployee: TEmpEmployee;
    FPersonName: string;
    FPersonSurname: string;
    FActiveLanguage: string;
    function GetPersonName: string;
    function GetPersonSurname: string;
  public
    [Column('username'), MaxLength(64), Required()]
    property Username: string read FUsername write FUsername;

    [Column('user_password'), Required()]
    property UserPassword: string read FUserPassword write FUserPassword;

    [Column('active'), Required()]
    property Active: Boolean read FActive write FActive;

    [Column('manager'), Required()]
    property Manager: Boolean read FManager write FManager;

    [Column('super_user'), Required()]
    property SuperUser: Boolean read FSuperUser write FSuperUser;

    [Column('ip_address'), MaxLength(32), Required()]
    property IpAddress: string read FIpAddress write FIpAddress;

    [Column('mac_address'), MaxLength(32)]
    property MacAddress: string read FMacAddress write FMacAddress;

    [Column('emp_employee_id'), Required()]
    property EmpEmployeeId: Int64 read FEmpEmployeeId write FEmpEmployeeId;

    [BelongsTo('EmpEmployeeId')]
    property EmpEmployee: TEmpEmployee read FEmpEmployee write FEmpEmployee;

    property PersonName: string read GetPersonName write FPersonName;
    property PersonSurname: string read GetPersonSurname write FPersonSurname;

    property ActiveLanguage: string read FActiveLanguage write FActiveLanguage;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSysUser;
  end;

implementation

constructor TSysUser.Create();
begin
  inherited;
  FEmpEmployee := nil;

  FActive := True;
  FManager := False;
  FSuperUser := False;
  FIpAddress := '127.0.0.1';
end;

destructor TSysUser.Destroy;
begin
  FEmpEmployee.Free;
  inherited;
end;

function TSysUser.Clone: TSysUser;
begin
  Result := TSysUser.Create;
  Result.Id := Self.Id;
  Result.Username := Self.Username;
  Result.EmpEmployeeId := Self.EmpEmployeeId;
  Result.SuperUser := Self.SuperUser;
  Result.MacAddress := Self.MacAddress;
  Result.UserPassword := Self.UserPassword;
  Result.IpAddress := Self.IpAddress;
  Result.Active := Self.Active;
  Result.Manager := Self.Manager;
  Result.ActiveLanguage := Self.ActiveLanguage;
  Result.PersonName := Self.PersonName;
  Result.PersonSurname := Self.PersonSurname;

  if Assigned(Self.EmpEmployee) then
    Result.EmpEmployee := Self.EmpEmployee.Clone;
end;

function TSysUser.GetPersonName: string;
begin
  if FPersonName <> '' then
    Result := FPersonName
  else if Assigned(FEmpEmployee) then
    Result := FEmpEmployee.Name
  else
    Result := '';
end;

function TSysUser.GetPersonSurname: string;
begin
  if FPersonSurname <> '' then
    Result := FPersonSurname
  else if Assigned(FEmpEmployee) then
    Result := FEmpEmployee.Surname
  else
    Result := '';
end;

end.

