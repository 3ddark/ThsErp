unit ServiceContainer;

interface

uses
  BaseService, StkKindFamilyService, StkKindFamily;

type
  TServiceContainer = class
  private
    class var FInstance: TServiceContainer;
    class var FLock: TObject;
  private
    FStkCinsAileService: IBaseService<TStkKindFamily>;

    function GetStkCinsAileService: IBaseService<TStkKindFamily>;
  protected
    constructor Create;
  public
    destructor Destroy; override;

    class function Instance: TServiceContainer;

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

initialization
  TServiceContainer.FLock := TObject.Create;

finalization
  TServiceContainer.FInstance.Free;
  TServiceContainer.FLock.Free;

end.
