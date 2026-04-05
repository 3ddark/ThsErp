unit AppContext;

interface

uses
  System.SysUtils, System.SyncObjs, FireDAC.Comp.Client, UserContext;

type
  TAppContext = class
  private
    class var FInstance: TAppContext;
    class var FLock: TCriticalSection;

    FDBConnection: TFDConnection;
    FCurrentUser: TUserContext;
    FOwnsConnection: Boolean;

    constructor CreatePrivate(AConnection: TFDConnection; AOwnsConnection: Boolean);
    function GetConnection: TFDConnection;
    function GetCurrentUser: TUserContext;
  public
    class constructor Create;
    class destructor Destroy;

    class procedure Initialize(AConnection: TFDConnection; AOwnsConnection: Boolean = False);
    class procedure Finalize;
    class function Instance: TAppContext;

    procedure SetCurrentUser(AUser: TUserContext);
    procedure ClearCurrentUser;
    function IsAuthenticated: Boolean;
    function ApplicationPath: string;


    destructor Destroy; override;

    property DBConnection: TFDConnection read GetConnection;
    property CurrentUser: TUserContext read GetCurrentUser;
  end;

implementation

class constructor TAppContext.Create;
begin
  FLock := TCriticalSection.Create;
  FInstance := nil;
end;

class destructor TAppContext.Destroy;
begin
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
  FreeAndNil(FLock);
end;

constructor TAppContext.CreatePrivate(AConnection: TFDConnection; AOwnsConnection: Boolean);
begin
  inherited Create;
  FDBConnection := AConnection;
  FOwnsConnection := AOwnsConnection;
  FCurrentUser := nil;
end;

destructor TAppContext.Destroy;
begin
  ClearCurrentUser;

  if FOwnsConnection and Assigned(FDBConnection) then
    FreeAndNil(FDBConnection);

  inherited;
end;

class procedure TAppContext.Initialize(AConnection: TFDConnection; AOwnsConnection: Boolean);
begin
  FLock.Enter;
  try
    if Assigned(FInstance) then
      raise Exception.Create('AppContext already initialized. Call Finalize first.');

    if not Assigned(AConnection) then
      raise EArgumentNilException.Create('AConnection cannot be nil');

    FInstance := TAppContext.CreatePrivate(AConnection, AOwnsConnection);
  finally
    FLock.Leave;
  end;
end;

class procedure TAppContext.Finalize;
begin
  FLock.Enter;
  try
    if Assigned(FInstance) then
      FreeAndNil(FInstance);
  finally
    FLock.Leave;
  end;
end;

function TAppContext.GetConnection: TFDConnection;
begin
  Result := FInstance.FDBConnection;
end;

function TAppContext.GetCurrentUser: TUserContext;
begin
  Result := FInstance.FCurrentUser;
end;

class function TAppContext.Instance: TAppContext;
begin
  if not Assigned(FInstance) then
    raise Exception.Create('AppContext not initialized. Call Initialize first.');
  Result := FInstance;
end;

procedure TAppContext.SetCurrentUser(AUser: TUserContext);
begin
  FLock.Enter;
  try
    ClearCurrentUser;
    FCurrentUser := AUser;
  finally
    FLock.Leave;
  end;
end;

function TAppContext.ApplicationPath: string;
begin
  Result := ParamStr(0);
end;

procedure TAppContext.ClearCurrentUser;
begin
  if Assigned(FCurrentUser) then
  begin
    FCurrentUser.Free;
    FCurrentUser := nil;
  end;
end;

function TAppContext.IsAuthenticated: Boolean;
begin
  Result := Assigned(FCurrentUser) and Assigned(FCurrentUser.User);
end;

end.
