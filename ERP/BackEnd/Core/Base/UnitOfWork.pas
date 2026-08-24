unit UnitOfWork;

interface

uses
  System.Generics.Collections, System.Rtti, System.SysUtils, Classes,
  FireDAC.Comp.Client, FireDAC.Phys,FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error,
  SharedFormTypes, Entity, Repository, SysPermission;

type
  IUnitOfWork = interface
    ['{68AEA695-44AC-449B-892D-488310A0954C}']
    function GetConnection: TFDConnection;

    procedure BeginTransaction;
    procedure Commit;
    procedure Rollback;
    function InTransaction: Boolean;

    function IsAuthorized(APermissionCode: Integer; APermissionType: TPermissionType; APermissionControl: Boolean): Boolean; overload;
    function IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean): Boolean; overload;

    property Connection: TFDConnection read GetConnection;
  end;

  TUnitOfWork = class(TInterfacedObject, IUnitOfWork)
  private
    class var FInstance: TUnitOfWork;
    class var FLock: TObject;
    FRepositoryCache: TDictionary<TClass, IInterface>;
  private
    FConnection: TFDConnection;
    function GetConnection: TFDConnection;
  protected
    constructor Create(AConnection: TFDConnection);
  public
    destructor Destroy; override;

    class procedure Initialize(AConnection: TFDConnection);
    class function Instance: TUnitOfWork;

    function GetRepository<T: TEntity, constructor; R: class, constructor>: IRepository<T>;

    procedure BeginTransaction;
    procedure Commit;
    procedure Rollback;
    procedure SavePoint(const AName: string);
    procedure RollbackToSavePoint(const AName: string);
    function InTransaction: Boolean;

    function IsAuthorized(APermissionCode: Integer; APermissionType: TPermissionType; APermissionControl: Boolean): Boolean; overload;
    function IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean): Boolean; overload;

    /// <summary>
    /// Yetki kontrolünü sistem erişim yetkisi servisine yönlendirir.
    /// </summary>
    /// <remarks>
    /// Yetki kontrolünün gerçek uygulaması
    /// <c>TSysAccessRightService.EnsureAuthorized</c> metodunda gerçekleştirilir.
    /// </remarks>
    procedure EnsureAuthorized(APermissionCode: Integer; APermissionType: TPermissionType; APermissionControl: Boolean);

    property Connection: TFDConnection read GetConnection;
  end;

implementation

uses
  Logger, SysAccessRight, SysAccessRight.Service, SysAccessRight.Repository;

constructor TUnitOfWork.Create(AConnection: TFDConnection);
begin
  FRepositoryCache := TDictionary<TClass, IInterface>.Create;
  Self.FConnection := AConnection;
end;

destructor TUnitOfWork.Destroy;
begin
  FRepositoryCache.Free;
  inherited;
end;

function TUnitOfWork.GetConnection: TFDConnection;
begin
  Result := FConnection;
end;

function TUnitOfWork.GetRepository<T, R>: IRepository<T>;
var
  LRepo: IInterface;
  LKey: TClass;
  LContext: TRttiContext;
  LRttiType: TRttiType;
  LRttiMethod: TRttiMethod;
begin
  if not Assigned(FConnection) then
    raise Exception.Create('TRepositoryManager initialize edilmeden kullanılamaz!');

  LKey := R;

  if not FRepositoryCache.TryGetValue(LKey, LRepo) then
  begin
    LContext := TRttiContext.Create;
    try
      LRttiType := LContext.GetType(R);
      LRttiMethod := LRttiType.GetMethod('Create');
      if not Assigned(LRttiMethod) or (Length(LRttiMethod.GetParameters) <> 1) then
        raise Exception.CreateFmt('%s uygun constructor bulamadı!', [R.ClassName]);
      LRepo := LRttiMethod.Invoke(LRttiType.AsInstance.MetaclassType, [FConnection]).AsInterface as IRepository<T>;
    finally
      LContext.Free;
    end;

    FRepositoryCache.Add(LKey, LRepo);
  end;

  Result := LRepo as IRepository<T>;
end;

procedure TUnitOfWork.BeginTransaction;
begin
  FConnection.StartTransaction;
  GLogger.Info('TRANSACTION BEGIN');
end;

procedure TUnitOfWork.Commit;
begin
  FConnection.Commit;
  GLogger.Info('TRANSACTION COMMIT');
end;

procedure TUnitOfWork.Rollback;
begin
  FInstance.FConnection.Rollback;
  GLogger.Info('TRANSACTION ROLLBACK');
end;

procedure TUnitOfWork.RollbackToSavePoint(const AName: string);
begin
  if InTransaction then
    FInstance.FConnection.ExecSQL('ROLLBACK TO SAVEPOINT ' + AName);
end;

procedure TUnitOfWork.SavePoint(const AName: string);
begin
  if InTransaction then
    FInstance.FConnection.ExecSQL('SAVEPOINT ' + AName);
end;

function TUnitOfWork.InTransaction: Boolean;
begin
  Result := FInstance.Connection.InTransaction;
end;

function TUnitOfWork.IsAuthorized(APermissionCode: Integer; APermissionType: TPermissionType; APermissionControl: Boolean): Boolean;
var
  LSvcAccess: TSysAccessRightService;
begin
  LSvcAccess := TSysAccessRightService.Create;
  try
    Result := LSvcAccess.IsAuthorized(APermissionCode, APermissionType, APermissionControl);
  finally
    LSvcAccess.Free;
  end;
end;

function TUnitOfWork.IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean): Boolean;
begin
  Result := IsAuthorized(0, APermissionType, APermissionControl);
end;

procedure TUnitOfWork.EnsureAuthorized(APermissionCode: Integer; APermissionType: TPermissionType; APermissionControl: Boolean);
var
  LSvcAccess: TSysAccessRightService;
begin
  LSvcAccess := TSysAccessRightService.Create;
  try
    LSvcAccess.EnsureAuthorized(APermissionCode, APermissionType, APermissionControl);
  finally
    LSvcAccess.Free;
  end;
end;

class procedure TUnitOfWork.Initialize(AConnection: TFDConnection);
begin
  if FInstance = nil then
  begin
    TMonitor.Enter(FLock);
    try
      if FInstance = nil then
        FInstance := TUnitOfWork.Create(AConnection);
    finally
      TMonitor.Exit(FLock);
    end;
  end;
end;

class function TUnitOfWork.Instance: TUnitOfWork;
begin
  if FInstance = nil then
    raise Exception.Create('TUnitOfWork not initialized. Call Initialize(AConnection) first.');
  Result := FInstance;
end;

initialization
  TUnitOfWork.FLock := TObject.Create;

finalization
  TUnitOfWork.FInstance.Free;
  TUnitOfWork.FLock.Free;

end.
