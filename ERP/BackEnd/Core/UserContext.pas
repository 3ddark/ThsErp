unit UserContext;

interface

uses
  System.SysUtils, System.Generics.Collections, SysUser, SysAccessRight;

type
  TAccessType = (atRead, atAdd, atUpdate, atDelete, atSpecial);

  TUserContext = class
  private
    FUser: TSysUser;
    FPermissions: TDictionary<Integer, TSysAccessRight>;
    FOwnsUser: Boolean;

    function GetPermission(AKey: Integer): TSysAccessRight;
  public
    constructor Create(AUser: TSysUser; AOwnsUser: Boolean = True);
    destructor Destroy; override;

    procedure AddPermission(AKey: Integer; APermission: TSysAccessRight);
    procedure AddPermissions(APermissionsList: TDictionary<Integer, TSysAccessRight>);
    function HasPermission(AKey: Integer; AAccessType: TAccessType): Boolean;
    function TryGetPermission(AKey: Integer; out APermission: TSysAccessRight): Boolean;

    procedure ClearPermissions;
    function GetUserId: Integer;
    function GetUsername: string;

    property User: TSysUser read FUser;
    property Permissions[AKey: Integer]: TSysAccessRight read GetPermission;
  end;

implementation

constructor TUserContext.Create(AUser: TSysUser; AOwnsUser: Boolean);
begin
  inherited Create;

  if not Assigned(AUser) then
    raise EArgumentNilException.Create('AUser cannot be nil');

  FUser := AUser;
  FOwnsUser := AOwnsUser;
  FPermissions := TDictionary<Integer, TSysAccessRight>.Create;
end;

destructor TUserContext.Destroy;
begin
  ClearPermissions;
  FreeAndNil(FPermissions);

  if FOwnsUser and Assigned(FUser) then
    FreeAndNil(FUser);

  inherited;
end;

procedure TUserContext.AddPermission(AKey: Integer; APermission: TSysAccessRight);
var
  LExisting: TSysAccessRight;
begin
  if not Assigned(APermission) then
    raise EArgumentNilException.Create('APermission cannot be nil');

  if FPermissions.TryGetValue(AKey, LExisting) then
  begin
    LExisting.IsRead := APermission.IsRead;
    LExisting.IsAdd := APermission.IsAdd;
    LExisting.IsUpdate := APermission.IsUpdate;
    LExisting.IsDelete := APermission.IsDelete;
    LExisting.IsSpecial := APermission.IsSpecial;
  end
  else
  begin
    FPermissions.Add(AKey, APermission);
  end;
end;

procedure TUserContext.AddPermissions(APermissionsList: TDictionary<Integer, TSysAccessRight>);
var
  LPair: TPair<Integer, TSysAccessRight>;
begin
  if not Assigned(APermissionsList) then
    Exit;

  for LPair in APermissionsList do
    AddPermission(LPair.Key, LPair.Value);
end;

function TUserContext.HasPermission(AKey: Integer; AAccessType: TAccessType): Boolean;
var
  LPermission: TSysAccessRight;
begin
  Result := False;

  if not FPermissions.TryGetValue(AKey, LPermission) then
    Exit;

  case AAccessType of
    atRead:    Result := LPermission.IsRead;
    atAdd:     Result := LPermission.IsAdd;
    atUpdate:  Result := LPermission.IsUpdate;
    atDelete:  Result := LPermission.IsDelete;
    atSpecial: Result := LPermission.IsSpecial;
  end;
end;

function TUserContext.TryGetPermission(AKey: Integer; out APermission: TSysAccessRight): Boolean;
begin
  Result := FPermissions.TryGetValue(AKey, APermission);
end;

function TUserContext.GetPermission(AKey: Integer): TSysAccessRight;
begin
  if not FPermissions.TryGetValue(AKey, Result) then
    Result := nil;
end;

procedure TUserContext.ClearPermissions;
var
  LPermission: TSysAccessRight;
begin
  for LPermission in FPermissions.Values do
    LPermission.Free;

  FPermissions.Clear;
end;

function TUserContext.GetUserId: Integer;
begin
  if Assigned(FUser) then
    Result := FUser.Id
  else
    Result := 0;
end;

function TUserContext.GetUsername: string;
begin
  if Assigned(FUser) then
    Result := FUser.Username
  else
    Result := '';
end;

end.
