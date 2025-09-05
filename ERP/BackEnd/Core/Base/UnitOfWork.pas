unit UnitOfWork;

interface

uses
  SysUtils, Classes, FireDAC.Comp.Client, FireDAC.Phys,FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error,
  StkCinsAileRepository;

type
  TUnitOfWork = class
  private
    class var FInstance: TUnitOfWork;
    class var FLock: TObject;
  private
    FConnection: TFDConnection;

    FStkCinsAileRepository: TStkCinsAileRepository;

    function GetStkCinsAileRepository: TStkCinsAileRepository;
    function GetConnection: TFDConnection;
  protected
    constructor Create(AConnection: TFDConnection);
  public
    destructor Destroy; override;

    class procedure Initialize(AConnection: TFDConnection);
    class function Instance: TUnitOfWork;

    procedure BeginTransaction;
    procedure Commit;
    procedure Rollback;

    property Connection: TFDConnection read GetConnection;

    property StkCinsAileRepository: TStkCinsAileRepository read GetStkCinsAileRepository;
  end;

implementation

constructor TUnitOfWork.Create(AConnection: TFDConnection);
begin
  Self.FConnection := AConnection;
end;

destructor TUnitOfWork.Destroy;
begin
  FreeAndNil(FStkCinsAileRepository);

  inherited;
end;

function TUnitOfWork.GetConnection: TFDConnection;
begin
  Result := FInstance.FConnection;
end;

procedure TUnitOfWork.BeginTransaction;
begin
  FInstance.FConnection.StartTransaction;
end;

procedure TUnitOfWork.Commit;
begin
  FInstance.FConnection.Commit;
end;

procedure TUnitOfWork.Rollback;
begin
  FInstance.FConnection.Rollback;
end;

function TUnitOfWork.GetStkCinsAileRepository: TStkCinsAileRepository;
begin
  if FStkCinsAileRepository = nil then
    FStkCinsAileRepository := TStkCinsAileRepository.Create(FInstance.FConnection);
  Result := FStkCinsAileRepository;
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
