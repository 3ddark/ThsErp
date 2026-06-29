unit SysUser;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes, EmpPerson;

type
  [Table('sys_users')]
  TSysUser = class(TEntity)
  private
    FUsername: string;
    FPersonId: Int64;
    FManager: Boolean;
    FSuperUser: Boolean;
    FMacAddress: string;
    FUserPassword: string;
    FIpAddress: string;
    FActive: Boolean;
    FPerson: TEmpPerson;
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

    [Column('person_id'), Required()]
    property PersonId: Int64 read FPersonId write FPersonId;

    [BelongsTo('PersonId')]
    property Person: TEmpPerson read FPerson write FPerson;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysUser.Create();
begin
  inherited;
  FActive := True;
  FManager := False;
  FSuperUser := False;
  FIpAddress := '127.0.0.1';
end;

destructor TSysUser.Destroy;
begin
  if Assigned(Person) then
    FreeAndNil(Person);
  inherited;
end;

end.

