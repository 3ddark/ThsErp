unit ServiceContainer;

interface

uses
  BaseService,
  SysViewColumn.Service, SysViewColumn,
  SysCity.Service, SysCity,
  SysRegion.Service, SysRegion,
  StkKindFamilyService, StkKindFamily;

type
  TServiceContainer = class
  private
    class var FInstance: TServiceContainer;
    class var FLock: TObject;
  private
    FSysViewColumnService: IBaseService<TSysViewColumn>;
    FSysCityService: IBaseService<TSysCity>;
    FSysRegionService: IBaseService<TSysRegion>;

    FStkCinsAileService: IBaseService<TStkKindFamily>;

    function GetSysViewColumnService: IBaseService<TSysViewColumn>;
    function GetSysCityService: IBaseService<TSysCity>;
    function GetSysRegionService: IBaseService<TSysRegion>;
    function GetStkCinsAileService: IBaseService<TStkKindFamily>;
  protected
    constructor Create;
  public
    destructor Destroy; override;

    class function Instance: TServiceContainer;

    property SysViewColumnService: IBaseService<TSysViewColumn> read GetSysViewColumnService;
    property SysCityService: IBaseService<TSysCity> read GetSysCityService;
    property SysRegionService: IBaseService<TSysRegion> read GetSysRegionService;
    property StkCinsAileService: IBaseService<TStkKindFamily> read GetStkCinsAileService;
  end;

implementation

constructor TServiceContainer.Create;
begin
  inherited Create;
end;

destructor TServiceContainer.Destroy;
begin
  // interface ler referans sayimi ile otomatik temizlenecek
  inherited;
end;

class function TServiceContainer.Instance: TServiceContainer;
begin
  if FInstance = nil then
  begin
    TMonitor.Enter(FLock);
    try
      if FInstance = nil then
        FInstance := TServiceContainer.Create;
    finally
      TMonitor.Exit(FLock);
    end;
  end;
  Result := FInstance;
end;

function TServiceContainer.GetStkCinsAileService: IBaseService<TStkKindFamily>;
begin
  if FStkCinsAileService = nil then
    FStkCinsAileService := TStkKindFamilyService.Create();
  Result := FStkCinsAileService;
end;

function TServiceContainer.GetSysCityService: IBaseService<TSysCity>;
begin
  if FSysCityService = nil then
    FSysCityService := TSysCityService.Create();
  Result := FSysCityService;
end;

function TServiceContainer.GetSysRegionService: IBaseService<TSysRegion>;
begin
  if FSysRegionService = nil then
    FSysRegionService := TSysRegionService.Create();
  Result := FSysRegionService;
end;

function TServiceContainer.GetSysViewColumnService: IBaseService<TSysViewColumn>;
begin
  if FSysViewColumnService = nil then
    FSysViewColumnService := TSysViewColumnService.Create();
  Result := FSysViewColumnService;
end;

initialization
  TServiceContainer.FLock := TObject.Create;

finalization
  TServiceContainer.FInstance.Free;
  TServiceContainer.FLock.Free;

end.
