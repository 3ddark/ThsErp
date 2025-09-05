unit ServiceContainer;

interface

uses
  BaseService, StkCinsAileService;

type
  TServiceContainer = class
  private
    class var FInstance: TServiceContainer;
    class var FLock: TObject;
  private
    FStkCinsAileService: IBaseService;

    function GetStkCinsAileService: IBaseService;
  protected
    constructor Create; // dýþarýdan çaðrýlamasýn
  public
    destructor Destroy; override;

    class function Instance: TServiceContainer;

    property StkCinsAileService: IBaseService read GetStkCinsAileService;
  end;

implementation

constructor TServiceContainer.Create;
begin
  inherited Create;
end;

destructor TServiceContainer.Destroy;
begin
  // interface’ler referans sayýmý ile otomatik temizlenecek
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

function TServiceContainer.GetStkCinsAileService: IBaseService;
begin
  if FStkCinsAileService = nil then
    FStkCinsAileService := TStkCinsAileService.Create();
  Result := FStkCinsAileService;
end;

initialization
  TServiceContainer.FLock := TObject.Create;

finalization
  TServiceContainer.FInstance.Free;
  TServiceContainer.FLock.Free;

end.
