unit SysUser;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes, PrsPerson;

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
    FPerson: TPrsPerson;
  public
    [Column('username')]
    property Username: string read FUsername write FUsername;

    [Column('user_password')]
    property UserPassword: string read FUserPassword write FUserPassword;

    [Column('active')]
    property Active: Boolean read FActive write FActive;

    [Column('manager')]
    property Manager: Boolean read FManager write FManager;

    [Column('super_user')]
    property SuperUser: Boolean read FSuperUser write FSuperUser;

    [Column('ip_address')]
    property IpAddress: string read FIpAddress write FIpAddress;

    [Column('mac_address')]
    property MacAddress: string read FMacAddress write FMacAddress;

    [Column('person_id')]
    property PersonId: Int64 read FPersonId write FPersonId;

    [BelongsTo('PersonId')]
    property Person: TPrsPerson read FPerson write FPerson;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysUser.Create();
begin
  inherited;
end;

destructor TSysUser.Destroy;
begin
  if Assigned(Person) then
    FreeAndNil(Person);
  inherited;
end;

end.
